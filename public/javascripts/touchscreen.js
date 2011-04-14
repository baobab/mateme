/***************************************************************************
  *
  * Baobab Touchscreen Toolkit
  *
  * A library for transforming HTML pages into touch-friendly user interfaces.
  *
  * (c) 2011 Baobab Health Trust (http://www.baobabhealth.org)
  *
  * For lincense details, see the README.md file
  *
  **************************************************************************/


/* Touchscreen Toolkit Settings */
tstRequireNextClickByDefault  = true;
tstConfirmCancel              = true;
tstEnableDateSelector         = false;

// Restrospective functionality doesn't belong here
// should be in pmis.js only
if (typeof(tstRetrospectiveMode) == "undefined")
  tstRetrospectiveMode = false;

/* end of Settings*/

// --- Global vars

tstLastPressTime = null;
var selectionHeight = 50;

var doListSuggestions = true;

tstPages            = new Array();
tstPageValues       = new Array();
tstPageNames        = new Array();
tstCurrentPage      = 0;
tstFormElements     = null;
tstInputTarget      = null;
tstShiftPressed     = false;
tstFormLabels       = null;
tstSearchPage       = false;
tstSearchPostParams = new Array();

tstMultipleSplitChar = ";";

var tstKeyboard;
var tstNextButton;

/* tstMessageBoxType defines types of Touchscreen Toolkit Message Boxes:
*
*  tstMessageBoxType.OKOnly      :   Displays OK button only.
*  tstMessageBoxType.OKCancel    :   Displays OK and Cancel buttons.
*  tstMessageBoxType.YesNo       :   Displays Yes and No buttons.
*  tstMessageBoxType.YesNoCancel :   Displays Yes, No, and Cancel buttons.
*/

var tstMessageBoxType = {
  OKOnly:{},
  OKCancel:{},
  YesNo:{},
  YesNoCancel:{}
}

// --------------------------------------

function $(elementID){
  return document.getElementById(elementID);
}

function selectedValue(elementID){
  element = $(elementID)
  return elementSelectedValue(element)
}

function elementSelectedValue(element){
  if (element != null){
    if (element.getAttribute("type") == "text") {
      return element.value
    }
    if (element.getAttribute("multiple") == "multiple") {
      var result = "";
      for (var i=0; i < element.options.length; i++) {
        if (element.options[i].selected) {
          result += tstMultipleSplitChar + element.options[i].text;
        }
      }
      return result.substring(1, result.length);
    } else {
      if (element.selectedIndex >= 0  && element.options.length > 0) {
        return element.options[element.selectedIndex].text
      }
    }
  }
  return null;
}


var touchscreenInterfaceEnabled = 0;
var contentContainer = null;

function loadTouchscreenToolkit() {
  contentContainer = document.getElementById("content");

  if (document.forms.length>0) {
    tstFormElements = getFormElements();
    tstFormLabels = document.forms[0].getElementsByTagName("label");
  }
  if (window.location.href.search(/\/patient\/patient_search_names/) != -1) {
    tstSearchPage = true;
  }
  disableTextSelection(); //For Opera

  addLaunchButton();

  if (typeof($) == 'undefined') {
    $ = function(elementId) {
      return document.getElementById(elementId);
    };
  }

  enableTouchscreenInterface();

  tstKeyboard = $('keyboard');
}


function addLaunchButton(){
  if (document.forms.length > 0) {
    var launchButton = document.createElement('div');
    launchButton.setAttribute('id','launchButton');
    launchButton.addEventListener("mousedown", toggleTouchscreenInterface, false);
    launchButton.addEventListener("click", toggleTouchscreenInterface, false);
    launchButton.innerHTML = "Enable Touchscreen UI";
    contentContainer.appendChild(launchButton);
  }
}

function toggleTouchscreenInterface(){
  if(touchscreenInterfaceEnabled == 0){
    enableTouchscreenInterface();
  }
  else{
    disableTouchscreenInterface();
  }
}

function touchScreenEditFinish(element){
  element.style.background=element.getAttribute('originalColor')
}

function createInputPage(pageNumber){
  var inputPage = document.createElement("div");
  var pageStyleClass;
  var formElement = getCurrentFormElement(pageNumber);
  if (formElement)
    pageStyleClass = formElement.getAttribute("tt_pageStyleClass");

  if (!pageStyleClass)
    pageStyleClass = "";

  inputPage.setAttribute('class','inputPage ' + pageStyleClass);
  inputPage.setAttribute('id','page'+pageNumber);

  var backButton = $('backButton');
  //create back button if not on first page
  if (pageNumber>0) {
    var prevPageNo = pageNumber-1;
    backButton.setAttribute("onMouseDown", "gotoPage("+prevPageNo+")");
    backButton.style.display = 'block';
  } else {
    backButton.style.display = 'none';
  }

  if(pageNumber==0){ // display the first page
    inputPage.setAttribute('style','display:block');
    inputTargetPageNumber = 0;
  }

  // hidden trigger button for calendar
  inputPage.innerHTML += "<div id='trigger1' />";

  staticControls = $('tt_staticControls');
  staticControls.setAttribute('class','staticControlsPage'+pageNumber+' '+pageStyleClass )

  return inputPage;
}

function createButtons() {
  var pageNumber = tstCurrentPage;

  var buttonsDiv = document.createElement('div');
  buttonsDiv.setAttribute("id", "buttons");
  buttonsDiv.setAttribute("class", "buttonsDiv");

  // Show/Hide Captured Data
  buttonsDiv.innerHTML = "<button id='showDataButton' class='button gray navButton' onMouseDown='toggleShowProgress()'><span>Show Data</span></button>";

  //create next/finish button
  buttonsDiv.innerHTML += "<button id='nextButton' class='button green navButton' onMouseDown='gotoNextPage()'><span>Next</span></button>";

  //create back button
  buttonsDiv.innerHTML += "<button id='backButton' class='button blue navButton'><span>Back</span></button>";

  //create clear button or new patient button if on search page
  if (!tstSearchPage) {
    buttonsDiv.innerHTML += "<button id='clearButton' class='button blue navButton' onMouseDown='clearInput()'><span>Clear</span></button>";
  } else {
    var buttonLabel = "New Patient";
    if (tstSearchMode && (tstSearchMode == "guardian")) {
      buttonLabel = "New Guardian";
    }

    buttonsDiv.innerHTML += "<button id='newPatientButton' class='button navButton' onMouseDown='document.forms[0].submit()'><span>"+buttonLabel+"</span></button>";
  }

  // create div for extra buttons
  buttonsDiv.innerHTML += "<div id='tt_extraButtons'></div>";

  //create cancel button
  buttonsDiv.innerHTML += "<button class='button navButton red' id='cancelButton' onMouseDown='confirmCancelEntry(" + (typeof(save_state) != "undefined"?"true":"") + ");'><span>Cancel</span></button>";

  return buttonsDiv
}

// TODO Look for optimization opportunities
function getElementsByTagNames(parentNode, tagNames){
  var returnValue = new Array;
  var tagFound = false;
  if (typeof parentNode != "object") return null;
  if (typeof parentNode.tagName != "string") return null;

  for(var i=0; i<tagNames.length; i++){
    if(parentNode.tagName == tagNames[i]){
      returnValue.push(parentNode);
      tagFound = true;
    }
  }
  if (!tagFound) {
    for(var c=0; c<parentNode.childNodes.length; c++){
      var result = getElementsByTagNames(parentNode.childNodes[c],tagNames);
      if (!result) continue;
      for(var j=0; j<result.length; j++){
        returnValue.push(result[j]);
      }
    }
  }
  if (returnValue.length > 0){
    return returnValue;
  }
}

function getFormElements(){
  // taking 25.139 ms before
  // now takes 2.615
  var formElements = document.forms[0].elements;
  var relevantFormElements = new Array();

  for(var i=0;i<formElements.length;i++){
    if (formElements[i].getAttribute("type") != "hidden" && formElements[i].getAttribute("type") != "submit") {
      relevantFormElements.push(formElements[i])
    }
  }

  return relevantFormElements
}

function getCurrentFormElement(aPageNum) {
  if (!tstFormElements || !tstPages)
    return null;

  return tstFormElements[tstPages[aPageNum]]
}

function enableTouchscreenInterface(){
  if (!tstFormElements) return;

  var numberOfInputElements = tstFormElements.length;
  var pageNum = 0;
  tstPages = new Array();

  // This code parses the existing forms and tries to build a wizard like UI
  for(var i=0;i<numberOfInputElements;i++){
    if (!tstSearchPage) {
      // create one page for the 3 date elements
      // called 445 times on staging page
      var formElementName = tstFormElements[i].getAttribute("name");
      if (formElementName.match(/2i|3i|\[month\]|\[day\]/)){
        continue;
      }
    }

    tstPages[pageNum] = i;
    tstPageNames[pageNum] = tstFormElements[i].name;
    tstPageValues[pageNum] = tstFormElements[i].value;
    if (tstFormElements[i].getAttribute("type") == "radio") {
      var selectOptions = document.getElementsByName(tstFormElements[i].name);
      // skip other inputs referring to this radio element
      i += selectOptions.length-1;
    }
    pageNum++;
  }

  // Ugly hack that allows css selection by either name or number
  var staticControlWrapper = document.createElement("div")
  staticControlWrapper.setAttribute("id","tt_staticControlsWrapper")
  contentContainer.appendChild(staticControlWrapper);

  var staticControl = document.createElement("div")
  staticControl.setAttribute("id","tt_staticControls")


  staticControl.appendChild(createKeyboardDiv());
  staticControl.appendChild(createProgressArea());
  staticControl.appendChild(createButtons());

  staticControl.innerHTML += "<div id='messageBar' class='messageBar'></div>";
  staticControl.innerHTML += "<div id='confirmationBar' class='touchscreenPopup'></div>";

  staticControlWrapper.appendChild(staticControl);

  tstNextButton = $("nextButton");
  tstMessageBar = $('messageBar');
  gotoPage(0, false);

  document.forms[0].style.display = "none";
  touchscreenInterfaceEnabled = 1;
  document.getElementById('launchButton').innerHTML = "Disable Touchscreen UI";
}

function populateInputPage(pageNum) {
  var i = tstPages[pageNum];

  inputPage  = createInputPage(pageNum);
  inputPage.setAttribute("style", "display: block;");

  // Try and find contextual information from *above* the input element
  var previousSibling = tstFormElements[i].previousSibling;
  var inputDiv = document.createElement("div");
  inputDiv.setAttribute("id", "inputFrame"+pageNum);
  inputDiv.setAttribute("class", "inputFrameClass");
  var infoBar = getInfoBar(tstFormElements[i], pageNum);
  var helpText = getHelpText(tstFormElements[i], pageNum);
  inputPage.appendChild(infoBar);
  inputPage.appendChild(helpText);

  var lastInsertedNode = inputPage.appendChild(inputDiv);

  var wrapperPage = document.createElement("div")
  wrapperID = helpText.innerHTML.replace(/ /g, "_").toLowerCase();
  wrapperID = wrapperID.replace(/\(|\)|\.|,/g,"")

  // Major ugly hacks
  identifier = wrapperID.split("<")[0]
  if (identifier == ""){
    splitResult = wrapperID.split(">")
    identifier = splitResult[splitResult.length-1]
  }
  wrapperPage.setAttribute('id','tt_page_'+identifier);
  wrapperPage.setAttribute('class','inputPage');
  wrapperPage.appendChild(inputPage);

  $('tt_staticControlsWrapper').setAttribute('class','tt_controls_'+identifier);

  // input
  var touchscreenInputNode;

  switch(tstFormElements[i].tagName){
    case "INPUT":
      if (tstFormElements[i].getAttribute("type") == "radio" ||
        tstFormElements[i].getAttribute("type") == "checkbox") {
        // handle it the same way as a SELECT
        touchscreenInputNode = inputDiv.appendChild(document.createElement("input"));

        // since we're not cloning this, we need to copy every attribute
        for (var a=0; a<tstFormElements[i].attributes.length; a++) {
          touchscreenInputNode.setAttribute(tstFormElements[i].attributes[a].name,
            tstFormElements[i].attributes[a].value);
        }
        touchscreenInputNode.setAttribute('type','text');
      } else {
        touchscreenInputNode = inputDiv.appendChild(tstFormElements[i].cloneNode(true));
      }
      break;

    case "SELECT":
      touchscreenInputNode = inputDiv.appendChild(document.createElement("input"));
      touchscreenInputNode.setAttribute('type','text');

      // since we are not cloning this, we need to copy every attribute
      for (var a=0; a<tstFormElements[i].attributes.length; a++) {
        touchscreenInputNode.setAttribute(tstFormElements[i].attributes[a].name,
          tstFormElements[i].attributes[a].value);
      }
      break;
  }

  setTouchscreenAttributes(touchscreenInputNode, tstFormElements[i], pageNum);
  if (tstFormElements[i].value)
    touchscreenInputNode.value = tstFormElements[i].value;

  tstInputTarget = touchscreenInputNode;

  // options
  inputDiv.appendChild(getOptions());

  contentContainer.appendChild(wrapperPage);

  tstInputTarget.addEventListener("keyup", checkKey, false)
  tstInputTarget.focus();

  // show message if any
  var flashMessage = "";
  var flashElement = $("flash_notice");
  if (flashElement){
    flashMessage += flashElement.innerHTML;
    flashElement.innerHTML = "";
  }

  flashElement = $("flash_error");
  if (flashElement){
    flashMessage += flashElement.innerHTML;
    flashElement.innerHTML = "";
  }

  if (flashMessage.length > 0) {
    showMessage(flashMessage);
  }

}

function addScrollButtons() {
  // add custom scroll bars
  var scrollButton = document.createElement('div');
  scrollButton.setAttribute("class", "scrollDownButton");
  scrollButton.innerHTML = "V";
  inputPage.appendChild(scrollButton);

  scrollButton = document.createElement('div');
  scrollButton.setAttribute("class", "scrollUpButton");
  scrollButton.innerHTML = "^";
  inputPage.appendChild(scrollButton);
}

function showAjaxResponse(aHttpRequest) {
  $('options').innerHTML = aHttpRequest.responseText;
}

function getFormPostParams() {
  var params = "";
  for (var i=0; i<tstFormElements.length; i++) {
    if (tstFormElements[i].id) {
      params += tstFormElements[i].id + "=" + tstFormElements[i].value + "&";
    } else if (tstFormElements[i].name)
      params += tstFormElements[i].name + "=" + tstFormElements[i].value + "&";
  }
  return params;
}

function setTouchscreenAttributes(aInputNode, aFormElement, aPageNum) {
  aFormElement.setAttribute('touchscreenInputID',aPageNum);
  aInputNode.setAttribute('refersToTouchscreenInputID',aPageNum);
  aInputNode.setAttribute('page',aPageNum);
  aInputNode.setAttribute('id','touchscreenInput'+aPageNum);
  aInputNode.setAttribute('class','touchscreenTextInput');
  aInputNode.setAttribute("v", aFormElement.getAttribute("validationRegexp"));
  if (aInputNode.type == "password") aInputNode.value = "";
}

function getInfoBar(inputElement, aPageNum) {
  var infoBarClass = "infoBarClass";
  var infoBar = document.createElement("div");
  infoBar.setAttribute('id','infoBar'+aPageNum);
  infoBar.setAttribute('class',infoBarClass);
  infoBar.setAttribute('refersToTouchscreenInputID',aPageNum);
  if(inputElement.getAttribute("infoBar") != null){
    infoBar.innerHTML = inputElement.getAttribute("infoBar");
  }
  return infoBar;
}

function getHelpText(inputElement, aPageNum) {
  var helpTextClass;
  if (tstSearchPage) {
    helpTextClass = "helpTextSearchPage";
  } else {
    helpTextClass = "helpTextClass";
  }

  var helpText = document.createElement("label");
  helpText.setAttribute('id','helpText'+aPageNum);
  helpText.setAttribute('class',helpTextClass);
  helpText.setAttribute('refersToTouchscreenInputID',aPageNum);
  helpText.setAttribute('for','touchscreenInput'+aPageNum);
  if(inputElement.getAttribute("helpText") != null){
    helpText.innerHTML = inputElement.getAttribute("helpText");
  }
  else {
    var labels = inputElement.form.getElementsByTagName("label");
    for(var i=0;i<labels.length;i++){
      if(labels[i].getAttribute("for") == inputElement.id){
        helpText.innerHTML = labels[i].innerHTML;
        break;
      } else if (isDateElement(inputElement)) {
        var re = new RegExp(labels[i].getAttribute("for"));
        if (inputElement.name.search(re) != -1) {
          helpText.innerHTML = labels[i].innerHTML;
          break;
        }

      }
    }
  }

  if (helpText.innerHTML == "") {
    // generate helpText for Rails' datetime_select
    var inputName = inputElement.name;
    var re = /([^\[]*)\[([^\(]*)\(([^\)]*)/ig; // TODO What is this RE for?
    var str = re.exec(inputName);
    if (str == null) {
      str = re.exec(inputName); // i don't why we need this!
    }
    if (str != null) {
      helpText.innerHTML = getLabel(str[1]+"_"+str[2]);

      switch (str[3]) {
        /*				case "1i":
					helpText.innerHTML = str[1]+" Year";
					break;
				case "2i":
					helpText.innerHTML = str[1]+" Month";
					break;
				case "3i":
					helpText.innerHTML = str[1]+" Date";
					break;
 */
        case "4i":
          helpText.innerHTML += " Hour";
          break;
        case "5i":
          helpText.innerHTML += " Minutes";
          break;
      }

    }
  }
  return helpText;
}

function getOptions() {
  var pageNum = tstCurrentPage;
  var i = tstPages[pageNum]
  var optionsClass = "";
  if (tstSearchPage) {
    optionsClass = "optionsSearchPage";
  } else {
    optionsClass = "options"
  }

  var viewPort = document.createElement("div")
  viewPort.setAttribute('id','viewport')
  viewPort.setAttribute('class',optionsClass);

  var options = document.createElement("div");
  options.setAttribute('id','options');
  options.setAttribute('class','scrollable');
  options.setAttribute('refersToTouchscreenInputID',pageNum);

  if (!tstSearchPage) {
    if(tstFormElements[i].getAttribute("ajaxURL") != null){
      ajaxRequest(options,tstFormElements[i].getAttribute("ajaxURL")+tstFormElements[i].value);
    }
    else {
      if(tstFormElements[i].tagName == "SELECT") {
        var selectOptions = tstFormElements[i].getElementsByTagName("option");
        loadSelectOptions(selectOptions, options);
        var val = elementSelectedValue(tstFormElements[i]);
        if (val == null) val = "";
        tstInputTarget.value = val;
        if (tstFormElements[i].multiple) tstInputTarget.setAttribute("multiple", "multiple");
      } else if (tstFormElements[i].getAttribute("type") == "radio") {
        var selectOptions = document.getElementsByName(tstFormElements[i].name);
        for(var j=0;j<selectOptions.length;j++){
          if (selectOptions[j].checked) tstInputTarget.value = selectOptions[j].value;
        }
        loadOptions(selectOptions, options);
      } else if (tstFormElements[i].getAttribute("type") == "checkbox") {
        loadOptions([{
          value: "Yes"
        }, {
          value: "No"
        }], options);
        if (tstFormElements[i].checked) tstInputTarget.value = "Yes";
        else tstInputTarget.value = "No";
      } else {
        viewPort.setAttribute('style', 'display:none');
      }
    }
  }

  if (options.firstChild && tstInputTarget.value.length>0) {
    highlightSelection(options.firstChild.childNodes, tstInputTarget);
  }

  viewPort.appendChild(options)
  return viewPort
}

function scrollUp(element){
  scrollableDiv = element.getElementsByTagName("div")[2]
  scrollableDiv.scrollTop = scrollableDiv.scrollTop - scrollableDiv.clientHeight
}

function scrollDown(element){
  scrollableDiv = element.getElementsByTagName("div")[2]
  scrollableDiv.scrollTop = scrollableDiv.scrollTop + scrollableDiv.clientHeight
}

function getLabel(anElementId) {
  var labelText = "";
  var labels = contentContainer.getElementsByTagName("label");
  for(var i=0;i<labels.length;i++){
    if(labels[i].getAttribute("for") == anElementId){
      labelText = labels[i].innerHTML;
    }
  }
  return labelText;
}

function createProgressArea() {
  // progressArea
  var numberOfPages = 0;
  numberOfPages = tstPages.length; //getNumberOfPages();
  var currentPage = tstCurrentPage; //getCurrentPage();
  var progressAreaBody = document.createElement("div");
  progressAreaBody.setAttribute('id','progressAreaBody');
  progressAreaBody.setAttribute('class','progressAreaBody');

  var progressArea = document.createElement("div");
  progressArea.setAttribute('id','progressArea');
  if (tstSearchPage)
    progressArea.setAttribute('class','progressAreaSearchPage');
  else
    progressArea.setAttribute('class','progressArea');

  progressArea.innerHTML = "<div id='progressAreaHeader' class='progressAreaHeader'>Captured Data</div>";
  for (var e=0; e<numberOfPages; e++) {
    var inputIndex = document.createElement("div");
    inputIndex.setAttribute("id", "progressAreaPage"+e);
    //		inputIndex.innerHTML += (e+1)+". "+tstPageNames[e]+": <div class='progressInputValue'>"+tstPageValues[e]+"</div>";
    inputIndex.innerHTML += (e+1)+". "+getHelpText(tstFormElements[tstPages[e]], e).innerHTML+": <div class='progressInputValue'>"+tstPageValues[e]+"</div>";
    if (e == currentPage) {
      inputIndex.setAttribute('class', 'currentIndex');
    }
    inputIndex.setAttribute("onMouseDown", 'gotoPage('+e+', true)');
    progressAreaBody.appendChild(inputIndex);
  }
  progressArea.appendChild(progressAreaBody);
  return progressArea
}

function toggleShowProgress() {
  var progressArea = $('progressArea');
  var progressAreaHeader = $('progressAreaHeader');
  var progressAreaBody = $('progressAreaBody');
  var showProgressButton = $('showDataButton');

  if (progressArea.style.display != 'block') {
    progressAreaBody.style.overflow = 'scroll';
    progressArea.style.display = 'block';
    showProgressButton.innerHTML = 'Hide Data';
  } else {
    progressAreaBody.style.overflow = 'hidden';
    progressArea.style.display = 'none';
    showProgressButton.innerHTML = 'Show Data';
  }
}

function loadSelectOptions(selectOptions, options) {
  var optionsList = "<ul>";
  var selectOptionCount = selectOptions.length;
  for(var j=0;j<selectOptionCount;j++){
    //njih
    if (selectOptions[j].text.length < 1) {
      continue;
    }

    // inherit mouse down options
    mouseDownAction = selectOptions[j].getAttribute("onmousedown")
    mouseDownAction += ';updateTouchscreenInputForSelect(this);';

    optionsList += '<li onmousedown="'+ mouseDownAction +'"';
    if (selectOptions[j].value) {
      optionsList += " id='option"+selectOptions[j].value +"' tstValue='"+selectOptions[j].value +"'";
    }
    //njih
    optionsList += ">" + selectOptions[j].text + "</li>\n";
  }
  optionsList += "</ul>";
  options.innerHTML = optionsList;
}

function loadOptions(selectOptions, options) {
  var optionsList = "<ul>";
  var selectOptionCount = selectOptions.length;
  for(var j=0;j<selectOptionCount;j++){
    optionsList += "<li onmousedown='updateTouchscreenInputForSelect(this)'>" + selectOptions[j].value + "</li>\n";
  }
  optionsList += "</ul>";
  options.innerHTML = optionsList;
}

function elementToTouchscreenInput(aFormElement, aInputDiv) {
  var aTouchscreenInputNode = aInputDiv.appendChild(document.createElement("input"));
  aTouchscreenInputNode.setAttribute('type','text');

  // since we're not cloning this, we need to copy every attribute
  for (var a=0; a<aFormElement.attributes.length; a++) {
    aTouchscreenInputNode.setAttribute(aFormElement.attributes[a].name,
      aFormElement.attributes[a].value);
  }
  return aTouchscreenInputNode;
}

function unhighlight(element){
  element.style.backgroundColor = "none"
}

// TODO make these into 1 function
function updateTouchscreenInputForSelect(element){
  var inputTarget = tstInputTarget;
  var multiple = inputTarget.getAttribute("multiple") == "multiple";

  if (multiple) {
    var val_arr = inputTarget.value.split(tstMultipleSplitChar);
    var val = "";
    if (element.value.length>1)
      val = element.value;
    //njih
    else if (element.innerHTML.length>1)
      val = unescape(element.innerHTML);
    // Check if the item is already included
    var idx = val_arr.toString().indexOf(val);
    if (idx == -1)
      val_arr.push(val);
    else
      //val_arr.splice(idx, 1);
      val_arr = removeFromArray(val_arr, val);
    inputTarget.value = val_arr.join(tstMultipleSplitChar);
    if (inputTarget.value.indexOf(tstMultipleSplitChar) == 0)
      inputTarget.value = inputTarget.value.substring(1, inputTarget.value.length);
  } else {
    if (element.value.length>1)
      inputTarget.value = element.value;
    else if (element.innerHTML.length>1)
      inputTarget.value = element.innerHTML;
  }

  highlightSelection(element.parentNode.childNodes, inputTarget)
  tt_update(inputTarget);
  checkRequireNextClick();
}

function updateTouchscreenInput(element){
  var inputTarget = tstInputTarget;

  if (element.value.length>1)
    inputTarget.value = element.value;
  else if (element.innerHTML.length>1)
    inputTarget.value = element.innerHTML;

  highlightSelection(element.parentNode.childNodes, inputTarget)
  tt_update(inputTarget);
  checkRequireNextClick();
}

function removeFromArray(anArray, aValue) {
  var newArray = new Array();
  for (i=0; i<anArray.length; i++) {
    if (anArray[i] != aValue)
      newArray.push(anArray[i]);
  }
  return newArray;
}

function checkRequireNextClick() {
  var requireNext = tstInputTarget.getAttribute("tt_requireNextClick");
  if (requireNext == 'false' || !tstRequireNextClickByDefault) {
    setTimeout(gotoNextPage, 200);
  }
}

function valueIncludedInOptions(val, options) {
  for (var i = 0; i < options.length; i++) {
    if (val == options[i].value) return true;
    if (val == options[i].text) return true;
  }
  return false;
}

function optionIncludedInValue(opt, val_arr) {
  // If lots of things are selected this could be bad... but indexOf is js 1.6+
  for (var i = 0; i < val_arr.length; i++) {
    if (opt == val_arr[i]) return true;
  }
  return false;
}

function highlightSelection(options, inputElement){
  var val_arr = new Array();
  var multiple = inputElement.getAttribute("multiple") == "multiple";
  if (multiple)
    val_arr = inputElement.value.split(tstMultipleSplitChar);
  else
    val_arr.push(inputElement.value);
  for(i=0;i<options.length;i++){
    if(options[i].style){
      //njih
      if(optionIncludedInValue(unescape(options[i].innerHTML), val_arr)){
        options[i].style.backgroundColor = "lightblue"
        if (options[i].getAttribute("tstValue")) {
          inputElement.setAttribute("tstValue", options[i].getAttribute("tstValue"));
        }
      }
      else{
        options[i].style.backgroundColor = ""
      }
    }
  }
}

function ajaxRequest(aElement, aUrl) {
  var httpRequest = new XMLHttpRequest();
  httpRequest.onreadystatechange = function() {
    handleResult(aElement, httpRequest);
  };
  try {
    httpRequest.open('GET', aUrl, true);
    httpRequest.send(null);
  } catch(e){
  }
}

function handleResult(optionsList, aXMLHttpRequest) {
  if (!aXMLHttpRequest) return;

  if (!optionsList) return;

  if (aXMLHttpRequest.readyState == 4 && aXMLHttpRequest.status == 200) {
    optionsList.innerHTML = aXMLHttpRequest.responseText;
    if(optionsList.getElementsByTagName("li")[0] != null){
      var optionNodes = optionsList.getElementsByTagName("li");
      var optionNodeCount = optionNodes.length;
      for(var i=0;i<optionNodeCount;i++){
        var onmousedown = optionNodes[i].getAttribute("onmousedown");
        optionNodes[i].setAttribute("onmousedown", onmousedown + ";updateTouchscreenInput(this);");
        if (optionNodes[i].getAttribute("tstValue") == tstInputTarget.value) {
          tstInputTarget.value = optionNodes[i].innerHTML;
          optionNodes[i].style.backgroundColor = "lightblue";
          if (optionNodes[i].hasAttribute("tstValue"))
            tstInputTarget.setAttribute('tstValue', optionNodes[i].getAttribute("tstValue"));
          break;
        } else if (optionNodes[i].innerHTML == tstInputTarget.value) {
          optionNodes[i].style.backgroundColor = "lightblue";
        }
      }
    }
    optionsList.innerHTML = "<ul>"+optionsList.innerHTML+"</ul>"
  }
}

function tt_update(sourceElement){
  var sourceValue = null;
  if (!sourceElement) return;

  if (sourceElement.getAttribute("tstValue")) {
    sourceValue = sourceElement.getAttribute("tstValue");
  } else {
    sourceValue = sourceElement.value;
  }
  var targetElement = returnElementWithAttributeValue("touchscreenInputID", sourceElement.getAttribute("refersToTouchscreenInputID"), tstFormElements);
  targetElement.focus();
  switch (sourceElement.tagName){
    //  switch (targetElement.tagName){
    case "INPUT":
      if (targetElement.type == "text" || targetElement.type == "password")  {
        targetElement.value = sourceValue;
      } else if (targetElement.type == "radio") {
        var radioElements = document.getElementsByName(targetElement.name);
        for (var i=0; i<radioElements.length; i++) {
          if (radioElements[i].value == sourceValue) {
            radioElements[i].checked = true;
          }
        }
      } else if (targetElement.type == "checkbox") {
        if (sourceValue.toLowerCase().substring(0,1) == "y") {
          targetElement.checked = true;
        } else {
          targetElement.checked = false;
        }
      } else if (targetElement.tagName == "SELECT") {

        if (isDateElement(targetElement) && (sourceValue.length>0) &&
          !tstSearchPage && tstEnableDateSelector) {
          sourceValue = tstInputTarget.value;
          var railsDate = new RailsDate(targetElement);
          railsDate.update(sourceValue);
        } else {
          targetElement.value = sourceValue;

          if (targetElement.getAttribute("multiple") == "multiple") {
            var val_arr = new Array();
            val_arr = sourceElement.value.split(tstMultipleSplitChar);
            for(i=0;i<targetElement.options.length;i++){
              if(optionIncludedInValue(targetElement.options[i].text, val_arr)) {
                targetElement.options[i].selected = true;
              } else
                targetElement.options[i].selected = false;

            }
          }
        }

      }
      break;
    case "SELECT":
  /*
      var val_arr = new Array();
      if (targetElement.multiple)
        val_arr = sourceElement.value.split(tstMultipleSplitChar);
      else
        val_arr.push(sourceElement.value);
      for(i=0;i<targetElement.options.length;i++){
        if(optionIncludedInValue(targetElement.options[i].value, val_arr)){
          targetElement.options[i].selected = true;
          if (!targetElement.multiple) break;
        } else targetElement.options[i].selected = false;
      }
      break;
      */
  }
}

function returnElementWithAttributeValue(attributeName, attributeValue, elementList){
  var i;
  for (i=0; i<elementList.length; i++){
    var value = elementList[i].getAttribute(attributeName);
    if(value == attributeValue){
      return elementList[i];
    }
  }
  return null;
}

function joinDateValues(aDateElement) {
  if (!isDateElement(aDateElement)) {
    return "";
  }
  var strDate = "";  //sourceValue.split('/');

  var re = /([^\[]*)\[([^\(]*)\(([^\)]*)/ig; // detect patient[birthdate(1i)] patient[birthdate(2i)]
  var str = re.exec(aDateElement.name);
  if (str == null) {
    str = re.exec(aDateElement.name); // i don't know why we need this!
  }
  if (str) {
    // handle format: patient[birthdate(1i)], patient[birthdate(2i)], patient[birthdate(3i)]
    var strLen = str[1].length;
    // detect date
    var dayElement = document.getElementsByName(str[1]+'['+str[2]+'(3i)]')[0];
    if (!dayElement) {
      dayElement = document.getElementsByName(str[1].substr(0,strLen-4)+'date['+str[2]+'(3i)]')[0];
    }

    if (dayElement) {
      var dayValue = dayElement.value;
      if (dayValue.length == 1) {
        dayValue = "0"+dayValue;
      }
    }

    // detect month
    var monthElement = document.getElementsByName(str[1]+'['+str[2]+'(2i)]')[0];
    if (!monthElement) {
      monthElement = document.getElementsByName(str[1].substr(0,strLen-4)+'month['+str[2]+'(2i)]')[0];
    }
    if (monthElement) {
      var monthValue = monthElement.value;
      if (monthValue.length == 1) {
        monthValue = "0"+monthValue;
      }
    }
    var railsDate = new RailsDate(aDateElement)
    monthElement = railsDate.getMonthElement();

    var yearElement = railsDate.getYearElement();
    //var yearValue = document.getElementsByName(str[1]+'['+str[2]+'(1i)]')[0].value;
    var yearValue = yearElement.value;
    if (!isNaN(dayValue) && !isNaN(monthValue && !isNaN(yearValue))) {
      strDate = dayValue+'/'+monthValue+'/'+yearValue;
    }

  } else {
    // handle date[year], date[month], date[day]
    var nameLength = aDateElement.name.length;
    var baseName = aDateElement.name.substr(0, nameLength-6);
    if (aDateElement.name.search(/\[year\]/) != -1) {
      strDate = document.getElementsByName(baseName+"[day]")[0].value + '/';
      strDate += document.getElementsByName(baseName+"[month]")[0].value + '/';
      strDate += document.getElementsByName(baseName+"[year]")[0].value;
    }
  }

  if (strDate.length != 10 && aDateElement.value) return aDateElement.value;
  if (strDate.length != 10) return "";
  else return strDate;
}

// args: page number to load, validate: true/false
function gotoPage(destPage, validate){
  var currentPage = tstCurrentPage;
  var currentInput = $("touchscreenInput"+currentPage);

  if (currentInput) {
    //    if ($('dateselector') != null && typeof ds != 'undefined')
    //      ds.update(currentInput);
    if (validate) {
      if (!inputIsValid()) return;
      //if (!inputIsAcceptable()) return;

      if(dispatchFlag()) return;
    }
    tt_update(currentInput);
    tstPageValues[currentPage] = currentInput.value;

    // Progress Indicator -- disabled
    /*
var currentPageIndex = $("progressAreaPage"+currentPage);
if (currentPageIndex) {
  // remove current index mark
  currentPageIndex.innerHTML = (currentPage+1)+". "+
             getHelpText(tstFormElements[tstPages[currentPage]], currentPage).innerHTML+
             ": <div class='progressInputValue'>"+progressAreaFormat(currentInput)+"</div>";
  currentPageIndex.removeAttribute("class");
}
*/
  }
// tt_OnUnload
  var unloadElementId = 'touchscreenInput';
  if (currentPage < destPage) {
    unloadElementId = 'touchscreenInput'+(destPage-1);
  } else if (currentPage > destPage) {
    unloadElementId = 'touchscreenInput'+(destPage+1);
  }

  var unloadElement = $(unloadElementId);
  if (unloadElement) {
    var onUnloadCode = unloadElement.getAttribute('tt_OnUnload');
    if (onUnloadCode) {
      eval(onUnloadCode);
    }
  }

  if(destPage < tstPages.length){
    var condition = tstFormElements[tstPages[destPage]].getAttribute("condition");
    // skip destination page when a condition is false
    if (condition) {
      if (!eval(condition)) {
        tstCurrentPage = destPage;
        if (currentPage <= destPage) {
          gotoPage(destPage+1);
        } else if (destPage > 0) {
          gotoPage(destPage-1);		// reverse skipping
        }
        return;
      }
    }
    try {
      var thisPage = $('page'+currentPage);
      var pageWrapper = thisPage.parentNode;
      pageWrapper.parentNode.removeChild(pageWrapper);
    } catch(e) {
      var pages = document.getElementsByClassName('inputPage');
      for(var i=0; i<pages.length; i++) {
        pages[i].parentNode.removeChild(pages[i]);
      }
    }

    inputTargetPageNumber = destPage;
    tstCurrentPage = destPage;
    populateInputPage(destPage);
    $("progressAreaPage"+destPage).setAttribute("class", "currentIndex");

    var nextButton = tstNextButton;
    if (destPage+1 == tstPages.length) {
      nextButton.innerHTML = "<span>Finish</span>";
    } else {
      nextButton.innerHTML = "<span>Next</span>";
    }
    showBestKeyboard(destPage);

    // manage whether or not scroll bars are displayed TODO
    var missingDisabled = tstInputTarget.getAttribute("tt_missingDisabled");
    var requireNextClick = tstInputTarget.getAttribute("tt_requireNextClick");

    // Make sure the next button is setup for right defaults
    nextButton.setAttribute("onMouseDown", "gotoNextPage()");
    // if in fast mode and not retrospective mode and missing is not disabled
    if (requireNextClick == "false") {
      if (tstRetrospectiveMode != "true"){
        nextButton.innerHTML=""
        nextButton.setAttribute("onMouseDown", "return false");
      }
      else if (missingDisabled != true){
        nextButton.innerHTML="<span>Skip</span>"
      }
    }

    // execute JS code when a field's page has just been loaded
    if (tstInputTarget.getAttribute("tt_onLoad")) {
      eval(tstInputTarget.getAttribute("tt_onLoad"));
    }

  }
  else{

    var popupBox = $("popupBox");
    if (popupBox) {
      popupBox.style.visibility = "visible";
    }

    document.forms[0].submit();
  }
}


function inputIsValid() {
  // don't leave current page if no value has been entered
  var ttInput = new TTInput(tstCurrentPage);
  var validateResult = ttInput.validate();
  var messageBar = $("messageBar");
  messageBar.innerHTML = "";

  if (validateResult.length > 0 && !tstSearchPage) {
    var message = validateResult;

    if (ttInput.shouldConfirm) {

      messageBar.innerHTML += "<p>" + ((message.match(/^Value\s/))?(message.replace(/^Value\s/, "The value <br /><b><i>" +
        ttInput.value + "</i></b><br /> is ")):message) + ".<br />Are you sure about this value?</p><div style='display: block;'><button class='button' style='float: left;' onclick='this.offsetParent.style.display=\"none\"; gotoPage(tstCurrentPage+1, false);' onmousedown='this.offsetParent.style.display=\"none\"; gotoPage(tstCurrentPage+1, false);'><span>Yes</span></button><button class='button' style='float: right; right: 3px;' onmousedown='this.offsetParent.style.display=\"none\"; '><span>No</span></button>";

      messageBar.style.display = "block";

    } else {
      showMessage(message)
    }
    return false;
  }
  return true;
}

function confirmValue() {
  var confirmationBar = $("confirmationBar");
  confirmationBar.innerHTML = "Username: ";
  var username = document.createElement("input");
  username.setAttribute("id", "confirmUsername");
  username.setAttribute("type", "text");
  username.setAttribute("textCase", "lower");
  confirmationBar.appendChild(username);

  confirmationBar.innerHTML += "<div style='display: block;'><input type='submit' value='OK' class='button' style='float: left;' onclick='validateConfirmUsername()' onmousedown='validateConfirmUsername()'/><input type='submit' value='Cancel' class='button' style='float: right; right: 3px;' onmousedown='cancelConfirmValue()' />";

  confirmationBar.style.display = "block";
  tstInputTarget = $("confirmUsername");
  if (typeof(barcodeFocusTimeoutId) != "undefined")
    window.clearTimeout(barcodeFocusTimeoutId);
  tstInputTarget.focus();
  tstKeyboard.innerHTML = "";

  if (!$("popupKeyboard")) {
    var popupKeyboard = document.createElement("div");
    popupKeyboard.setAttribute("id", "popupKeyboard");
    popupKeyboard.setAttribute("class", "keyboard");
    popupKeyboard.innerHTML = getPreferredKeyboard();
    contentContainer.appendChild(popupKeyboard);
  }
  $("backspace").style.display = "inline";
  hideMessage();
}

function validateConfirmUsername() {
  var username = $('confirmUsername');
  if (username.value == tstUsername) {
    cancelConfirmValue();
    gotoPage(tstCurrentPage+1, false);
  } else {
    showMessage("Username entered is invalid");
  }
}

function cancelConfirmValue() {
  $("confirmationBar").style.display = "none";
  tstInputTarget = $("touchscreenInput"+tstCurrentPage);
  if (typeof(focusForBarcodeInput) != "undefined")
    focusForBarcodeInput();

  contentContainer.removeChild($("popupKeyboard"));
  showBestKeyboard(tstCurrentPage);
}

function clearInput(){
  $('touchscreenInput'+tstCurrentPage).value = "";

  if(doListSuggestions){
    listSuggestions(tstCurrentPage);
  }
}

function showMessage(aMessage) {
  var messageBar = tstMessageBar;
  messageBar.innerHTML = aMessage;
  if (aMessage.length > 0) {
    messageBar.style.display = 'block'
    window.setTimeout("hideMessage()",3000)
  }
}

function hideMessage(){
  tstMessageBar.style.display = 'none'
}

function disableTouchscreenInterface(){
  // delete touchscreen tstPages
  contentContainer.removeChild($('page'+tstCurrentPage));
  contentContainer.removeChild($('keyboard'));
  contentContainer.removeChild($('progressArea'));
  contentContainer.removeChild($('buttons'));
  document.forms[0].style.display = 'block';

  touchscreenInterfaceEnabled = 0;
  document.getElementById('launchButton').innerHTML = "Enable Touchscreen UI";
}

function confirmCancelEntry(save) {     // If you want to save state set save = true
  if (tstConfirmCancel) {
    tstMessageBar.innerHTML = "Are you sure you want to Cancel?<br/>" +
    "<button onmousedown='hideMessage(); cancelEntry();'><span>Yes</span></button>" +
    (save?"<button onmousedown='var completeField = document.createElement(\"input\"); \n\
            completeField.type = \"hidden\"; completeField.value = \"false\"; completeField.name = \"complete\"; \n\
            document.forms[0].appendChild(completeField); document.forms[0].submit(); hideMessage();'><span>Save</span></button>":"") +
    "<button onmousedown='hideMessage();'><span>No</span></button>";
    tstMessageBar.style.display = "block";
  } else {
    cancelEntry();
  }

}

function cancelEntry() {

  var inputElements = document.getElementsByTagName("input");
  for (i in inputElements) {
    inputElements[i].value = "";
  }

  window.location.href = window.tt_cancel_destination || "/people";       //"/patient/menu?no_auto_load_forms=true";/* specially for dmht */
}

// format the given element's value for display on the Progress Indicator
// TODO: Crop long values
function progressAreaFormat(anElement) {
  if (anElement.getAttribute("type") == "password") {
    return "****";
  } else {
    return anElement.value;
  }
}

function toggleShift() {
  tstShiftPressed = !tstShiftPressed;
}

function showBestKeyboard(aPageNum) {
  var inputElement = tstFormElements[tstPages[aPageNum]];
  if (isDateElement(inputElement)) {
    var thisDate = new RailsDate(inputElement);
    if (tstSearchPage) {
      if (thisDate.isDayOfMonthElement()) getDatePicker();
      else $("keyboard").innerHTML = getNumericKeyboard();
    }	else {
      getDatePicker();
    }
    return;
  }
  var optionCount = $('options').getElementsByTagName("li").length;
  if ((optionCount > 0 && optionCount < 6 && inputElement.tagName == "SELECT") || (inputElement.getAttribute("multiple") == "multiple")) {
    $("keyboard").innerHTML = "";
    return;
  }

  switch (inputElement.getAttribute("field_type")) {
    case "alpha":
      $("keyboard").innerHTML = getPreferredKeyboard();
      break;
    case "number":
      $("keyboard").innerHTML = getNumericKeyboard();
      break;
    case "date":
      getDatePicker();
      break;
    case "boolean":
      $("keyboard").innerHTML = "";
      break;
    default:
      $("keyboard").innerHTML = getPreferredKeyboard();
      break;
  }
}

// check if this element's name is for a Rails' datetime_select
function isDateElement(aElement) {
  if (aElement.getAttribute("field_type") == "date")
    return true;

  var thisRailsDate = new RailsDate(aElement);
  if (thisRailsDate.isYearElement())
    return true;

  if (thisRailsDate.isMonthElement())
    return true;

  if (thisRailsDate.isDayOfMonthElement())
    return true;

  return false;

/*
// for date[year] dates
if (aElement.name.search(/\[year\]/gi) != -1)
return true;

if (aElement.id.search(/_day$/) != -1)
return true;

// for person[date(1i)] dates
var re = /([^\[]*)\[([^\(]*)\(([^\)]*)/ig;
var str = re.exec(aElement.name);
if (str == null) {
str = re.exec(aElement.name); // i don't know why we need this!
}
if (str == null) {
return false;
}	else {
return true;
}
//return (str[2] != null);
*/
}

// return whether this element represents a year, month or day of month
function getDatePart(aElementName) {
  var re = /[^\[]*\[([^\(]*)\(([^\)]*)/ig; // TODO What is this RE for?
  var str = re.exec(aElementName);
  if (str == null) {
    str = re.exec(aElementName); // i don't why we need this!
  }
  if (str != null) {
    return str[2];
  } else {
    return "";
  }
}



function gotoNextPage() {
  gotoPage(tstCurrentPage+1, true);
}

function	disableTextSelection() {
  if (navigator.userAgent.search(/opera/gi) != -1) {
    var theBody = contentContainer;
    theBody.onmousedown = disableSelect;
    theBody.onmousemove = disableSelect;
  }
}

function disableSelect(aElement)
{
  if (aElement && aElement.preventDefault)
    aElement.preventDefault();
  else if (window.event)
    window.event.returnValue = false;
}

function toggleMe(element){
  currentColor =  element.style.backgroundColor;
  if(currentColor == 'darkblue'){
    element.style.backgroundColor = "white";
    element.style.color = "black";
  }
  else{
    element.style.backgroundColor = "darkblue";
    element.style.color = "white";
  }
}

function addOption(optionText){
  document.getElementById('selections').innerHTML += "<div name='option' class='selectionOption' onMouseDown='toggleMe(this)'>"+optionText+"</div>";
}

function createKeyboardDiv(){
  var keyboard = $("keyboard");
  if (keyboard) keyboard.innerHTML = "";
  else {
    keyboard = document.createElement("div");
    keyboard.setAttribute('class','keyboard');
    keyboard.setAttribute('id','keyboard');
  }
  return keyboard;
}

function getQwertyKeyboard(){
  var keyboard;
  keyboard =
  "<span class='qwertyKeyboard'>" +
  "<span class='buttonLine'>" +
  getButtons("QWERTYUIOP") +
  getButtonString('backspace','Delete') +
  //		getButtonString('date','Date') +
  "</span><span style='padding-left:15px' class='buttonLine'>" +
  getButtons("ASDFGHJKL") +
  getButtonString('apostrophe',"'") +
  getButtonString('space','&nbsp;') +
  "</span><span style='padding-left:25px' class='buttonLine'>" +
  getButtons("ZXCVBNM,.") +
  getButtonString('abc','A-Z') +
  getButtonString('num','0-9') +
  getButtonString('SHIFT','aA') +
  "</span>" +
  "</span>"
  return keyboard;
}

function getABCKeyboard(){
  //	var keyboard = createKeyboardDiv();
  keyboard =
  "<span class='abcKeyboard'>" +
  "<span class='buttonLine'>" +
  getButtons("ABCDEFGH") +
  getButtonString('backspace','Delete') +
  getButtonString('num','0-9') +
  "</span><span class='buttonLine'>" +
  getButtons("IJKLMNOP") +
  getButtonString('apostrophe',"'") +
  getButtonString('SHIFT','aA') +
  getButtonString('Unknown','Unknown') +
  "</span><span class='buttonLine'>" +
  getButtons("QRSTUVWXYZ") +
  getButtonString('space','&nbsp;') +
  getButtonString('qwerty','qwerty') +
  "</span>" +
  "</span>";
  return keyboard;
}

function getNumericKeyboard(){
  var keyboard =
  "<span class='numericKeyboard'>" +
  "<span id='buttonLine1' class='buttonLine'>" +
  getButtons("123") +
  getCharButtonSetID("+","plus") +
  getCharButtonSetID("-","minus") +
  getCharButtonSetID("/","slash") +
  getCharButtonSetID("*","star") +
  getButtonString('abc','A-Z') +
  getButtonString('date','Date') +
  "</span><span id='buttonLine2' class='buttonLine'>" +
  getButtons("456") +
  getCharButtonSetID("%","percent") +
  getCharButtonSetID("=","equals") +
  getCharButtonSetID("<","lessthan") +
  getCharButtonSetID(">","greaterthan") +
  getButtonString('qwerty','qwerty') +
  "</span><span id='buttonLine3' class='buttonLine'>" +
  getButtons("789") +
  getCharButtonSetID("0","zero") +
  getCharButtonSetID(".","decimal") +
  getCharButtonSetID(",","comma") +
  getButtonString('backspace','Delete') +
  getButtonString('Unknown','Unknown') +
  getButtonString('SHIFT','aA') +
  "</span>"
  return keyboard;
}

function getDatePicker() {
  if (typeof(DateSelector) == "undefined")
    return;

  var inputElement = tstFormElements[tstPages[tstCurrentPage]];
  var keyboardDiv = $('keyboard');
  keyboardDiv.innerHTML = "";

  var railsDate = new RailsDate(inputElement);
  if (railsDate.isDayOfMonthElement()) {
    getDayOfMonthPicker(railsDate.getYearElement().value, railsDate.getMonthElement().value);
    return;
  }

  var defaultDate = joinDateValues(inputElement);
  defaultDate = defaultDate.replace("-", "/", "g");
  var arrDate = defaultDate.split('/');
  $("touchscreenInput"+tstCurrentPage).value = defaultDate;

  if (!isNaN(Date.parse(defaultDate))) {
    ds = new DateSelector({
      element: keyboardDiv,
      target: tstInputTarget,
      year: arrDate[0],
      month: arrDate[1],
      date: arrDate[2],
      format: "dd/MM/yyyy"
    });
  } else {
    ds = new DateSelector({
      element: keyboardDiv,
      target: tstInputTarget,
      format: "dd/MMM/yyyy"
    });
  }

  $("options").innerHTML = "";
}

function getYearPicker() {
  ds = new DateSelector({
    element: $("keyboard"),
    target: tstInputTarget,
    format: "yyyy"
  });
}

function getMonthPicker() {
  ds = new DateSelector({
    element: $("keyboard"),
    target: tstInputTarget,
    format: "MM"
  });
}

function getDayOfMonthPicker(aYear, aMonth) {
  var keyboard =$('keyboard')
  keyboard.innerHTML = "";
  numberOfDays = DateUtil.getLastDate(aYear,aMonth-1).getDate();

  for(var i=1;i <= numberOfDays;i++){
    keyboard.innerHTML += getButtonString(i,i);

    /* set minimum width for the button to 80 pixels */
    button = document.getElementById(i);
    button.setAttribute("style","min-width:80px;");

    /* break on the seventh button, implying the end of the week*/
    if(i%7 == 0) keyboard.innerHTML +="<span><br/></span>";
  }
  keyboard.innerHTML += getButtonString("Unknown","Unknown")

  if (tstInputTarget.value > numberOfDays) {
    tstInputTarget.value = numberOfDays;
  }
  tstInputTarget.setAttribute("singleButtonMode", "true");
/*
if (aYear && aMonth)
ds = new DateSelector({element: $("keyboard"), target: tstInputTarget, year: aYear, month: aMonth, format: "dd" });
else if (aMonth)
ds = new DateSelector({element: $("keyboard"), target: tstInputTarget, month: aMonth, format: "dd" });
else
ds = new DateSelector({element: $("keyboard"), target: tstInputTarget, format: "dd" });
*/
}

function getButtons(chars){
  var buttonLine = "";
  for(var i=0; i<chars.length; i++){
    character = chars.substring(i,i+1)
    buttonLine += getCharButtonSetID(character,character)
  }
  return buttonLine;
}

function getCharButtonSetID(character,id){
  return '<button onMouseDown="press(\''+character+'\');" class="keyboardButton" id="'+id+'"><span>' +character+ '</span></button>';
}

function getButtonString(id,string){
  return "<button \
onMouseDown='press(this.id);' \
class='keyboardButton' \
id='"+id+"'><span>"+
  string +
  "</span></button>";
}

function press(pressedChar){
  var now = new Date();
  var diff = tstLastPressTime && now.getTime() - tstLastPressTime.getTime();

  if (diff && diff < 80 ) {
    return;
  }

  inputTarget = tstInputTarget;
  var singleButtonMode = inputTarget.getAttribute("singleButtonMode");
  if (singleButtonMode)
    inputTarget.value = "";

  if (pressedChar.length == 1) {
    inputTarget.value += getRightCaseValue(pressedChar);

  } else {
    switch (pressedChar) {
      case 'backspace':
        inputTarget.value = inputTarget.value.substring(0,inputTarget.value.length-1);
        break;
      case 'done':
        touchScreenEditFinish(inputTarget);
        break;
      case 'space':
        inputTarget.value += ' ';
        break;
      case 'apostrophe':
        inputTarget.value += "'";
        break;
      case 'abc':
        tstUserKeyboardPref = 'abc';
        $('keyboard').innerHTML = getPreferredKeyboard();
        if (typeof(saveUserKeyboardPref) != 'undefined'){
          saveUserKeyboardPref('abc');
        }
        break;
      case 'qwerty':
        tstUserKeyboardPref = 'qwerty';
        $('keyboard').innerHTML = getPreferredKeyboard();
        if (typeof(saveUserKeyboardPref) != 'undefined'){
          saveUserKeyboardPref('qwerty');
        }
        break;
      case 'num':
        $('keyboard').innerHTML = getNumericKeyboard();
        break;
      case 'date':
        getDatePicker();
        break;
      case 'SHIFT':
        toggleShift();
        break;
      case 'Unknown':
        inputTarget.value = "Unknown";
        break;

      default:
        if (tstShiftPressed) pressedChar = pressedChar.toUpperCase();
        inputTarget.value += pressedChar;
    }
  }

  if(doListSuggestions){
    listSuggestions(inputTargetPageNumber);
  }

  tstLastPressTime = new Date();
}

//ugly hack but it works!
// refresh options
function listSuggestions(inputTargetPageNumber) {
  if (inputTargetPageNumber == undefined) {
    return;
  }
  var inputElement = $('touchscreenInput'+inputTargetPageNumber);

  if(inputElement.getAttribute("ajaxURL") != null){
    ajaxRequest($('options'),inputElement.getAttribute("ajaxURL")+inputElement.value);
  }
  else{
    var optionsList = document.getElementById('options');
    options = optionsList.getElementsByTagName("li");
    var searchTerm = new RegExp(inputElement.value,"i");
    for(var i=0; i<options.length; i++){
      if(options[i].innerHTML.search(searchTerm) == -1){
        options[i].style.display = "none";
      }
      else{
        options[i].style.display = "block";
      }
    }
  }
}

//function matchOptions(stringToMatch){
function matchOptions(){
  stringToMatch = document.getElementById("inputContainer").innerHTML;
  options = document.getElementsByName('option');
  for(var i=0;i<options.length; i++){
    if(options[i].textContent.toLowerCase().indexOf(stringToMatch.toLowerCase()) == 0){
      document.getElementById("selections").style.top = -i * selectionHeight + "px";
      return;
    }
  }
}

function enableValidKeyboardButtons() {

  var inputElement = $('touchscreenInput'+inputTargetPageNumber);
  var patternStr = "(a-zA-Z0-9,.+()%])+";  // defualt validation pattern


  if (inputElement.getAttribute("validationRegexp")) {
    patternStr = inputElement.getAttribute("validationRegexp");
  };
  var availableKeys = "abcdefghijklmnopqrstuvwxyz0123456789.,;/%*+-";
  var validateUrl = "/cgi-bin/validate.cgi?p="+patternStr+"&keys="+availableKeys+"&s="+inputElement.value;

  httpRequest = new XMLHttpRequest();
  httpRequest.overrideMimeType('text/xml');
  httpRequest.onreadystatechange = function() {
    if (httpRequest.readyState == 4) {
      if (httpRequest.status == 200) {
        enableKeys(httpRequest.responseText, availableKeys);
      } else {
        // there was a problem with the request so we enable all keys
        enableKeys(availableKeys, availableKeys);
      }
    }
  };
  httpRequest.open('GET', validateUrl, true);
  httpRequest.send(null);
}

function enableKeys(validKeys, allKeys) {
  allKeys = allKeys.toUpperCase();
  validKeys = validKeys.toUpperCase();
  var keyButton;
  var keyboardElement = $("keyboard");
  // disable all keys
  for (var i=0;i<allKeys.length; i++) {
    if (keyButton = $(allKeys.substring(i,i+1))) {
      keyButton.style.backgroundColor = "";
      keyButton.style.color = "gray";
      keyButton.disabled = true;
    }
  }
  // enable only valid keys
  for (var i=0;i<validKeys.length; i++) {
    if (keyButton = $(validKeys.substring(i,i+1))) {
      keyButton.style.color = "black";
      keyButton.disabled = false;
    }
  }
}

function getRightCaseValue(aChar) {
  var newChar = '';
  var inputElement = tstInputTarget;
  var fieldCase = inputElement.getAttribute("textCase");

  switch (fieldCase) {
    case "lower":
      newChar = aChar.toLowerCase();
      break;
    case "upper":
      newChar = aChar.toUpperCase();
      break;
    case "mixed":
      if (tstShiftPressed)
        newChar = aChar.toUpperCase();
      else
        newChar = aChar.toLowerCase();
      break;
    default:		// Capitalise First Letter
      if (inputElement.value.length == 0 || tstShiftPressed)
        newChar = aChar.toUpperCase();
      else
        newChar = aChar.toLowerCase();
  }
  return newChar;
}

function stripLeadingZeroes(aNum) {
  var len = aNum.length;
  var newNum = aNum;
  while (newNum.substr(0,1) == '0') {
    newNum = newNum.substr(1,len-1)

  }
  return newNum;
}

function escape(s) {
  s = s.replace(">", "&gt;");
  s = s.replace("<", "&lt;");
  s = s.replace("\"", "&quot;");
  s = s.replace("'", "&apos;");
  s = s.replace("&", "&amp;");
  return s;
}

function unescape(s) {
  s = s.replace("&gt;", ">");
  s = s.replace("&lt;", "<");
  s = s.replace("&quot;", "\"");
  s = s.replace("&apos;", "'");
  s = s.replace("&amp;", "&");
  return s;
}

function checkKey(anEvent) {
  if (anEvent.keyCode == 13) {
    gotoNextPage();
    return;
  }
  if (anEvent.keyCode == 27) {
    confirmCancelEntry();
    return;
  }

  if(doListSuggestions){
    listSuggestions(inputTargetPageNumber);
  }

  tstLastPressTime = new Date();
}


function validateRule(aNumber) {
  var aRule = aNumber.getAttribute("validationRule")
  if (aRule==null) return ""

  var re = new RegExp(aRule)
  if (aNumber.value.search(re) ==-1){
    var aMsg= aNumber.getAttribute("validationMessage")
    if (aMsg ==null || aMsg=="")
      return "Please enter a valid value"
    else
      return aMsg
  }
  return ""
}


// Touchscreen Input element
var TTInput = function(aPageNum) {
  this.element = $("touchscreenInput"+aPageNum);
  this.formElement = tstFormElements[tstPages[aPageNum]]
  this.value = this.element.value;

  if (isDateElement(this.formElement)) {
    this.formElement.value = this.element.value; // update date value before validation so we can use RailsDate
    var rDate = new RailsDate(this.formElement);
    this.value = rDate.getDayOfMonthElement().value+"/"+rDate.getMonthElement().value+"/"+rDate.getYearElement().value;
  }
  this.shouldConfirm = false;
};
TTInput.prototype = {
  //  return error msg when input value is invalid, blank otherwise
  validate: function() {
    var errorMsg = "";

    // validate existence
    errorMsg = this.validateExistence();
    if (errorMsg.length > 0) return errorMsg;

    if (this.value.length > 0 || !this.element.getAttribute('optional')){

      // validates using reg exp
      errorMsg = this.validateRule();
      if (errorMsg.length > 0) return errorMsg;

      // check validation code
      errorMsg = this.validateCode();
      if (errorMsg.length > 0) return errorMsg;

      // check ranges
      errorMsg = this.validateRange();
      if (errorMsg.length > 0) return errorMsg;

      // check existence in select options
      if (!isDateElement(this.formElement)) {
        errorMsg = this.validateSelectOptions();
        if (errorMsg.length > 0) return errorMsg;
      } else {
        var railsDate = new RailsDate(this.formElement);
        if (railsDate.isDayOfMonthElement()) {
          errorMsg = this.validateSelectOptions();
          if (errorMsg.length > 0) return errorMsg;
        }
      }
    }


    return "";
  },

  validateExistence: function() {
    // check for existence
    this.value = this.element.value
    if (this.value.length<1 && this.element.getAttribute("optional") == null) {
      return "You must enter a value to continue";
    }
    return "";
  },

  //
  validateRule: function() {
    return validateRule(this.element)
  },

  // validate using specified JS code
  validateCode: function() {
    var code = this.element.getAttribute('validationCode');
    var msg = this.element.getAttribute('validationMessage') || "Please enter a valid value";
    msg  += "<br> <a onmousedown='javascript:confirmValue()' href='javascript:;'>Authorise</a> </br>";

    if (!code || eval(code)) {
      return "";
    } else {
      return msg;
    }
  },

  validateRange: function() {
    var minValue = null;
    var maxValue = null;
    var absMinValue = null;
    var absMaxValue = null;
    var tooSmall = false;
    var tooBig = false;
    this.shouldConfirm = false;

    if (isDateElement(this.formElement)) {
      this.value.match(/(\d+)\/(\d+)\/(\d+)/);
      //var thisDate = new Date(this.value);
      var thisDate = new Date(RegExp.$3,parseFloat(RegExp.$2)-1, RegExp.$1);
      minValue = this.element.getAttribute("min");
      maxValue = this.element.getAttribute("max");
      absMinValue = this.element.getAttribute("absoluteMin");
      absMaxValue = this.element.getAttribute("absoluteMax");

      if (absMinValue) {
        absMinValue = absMinValue.replace(/-/g, '/');
        var minDate = new Date(absMinValue);
        if (minDate && (thisDate.valueOf() < minDate.valueOf())) {
          tooSmall = true;
          minValue = absMinValue;
        }
      }
      if (absMaxValue) {
        absMaxValue = absMaxValue.replace(/-/g, '/');
        var maxDate = new Date(absMaxValue);
        if (maxDate && (thisDate.valueOf() > maxDate.valueOf())) {
          tooBig = true;
          maxValue = absMaxValue;
        }
      }
      if (!tooSmall && !tooBig) {
        if (minValue) {
          minValue = minValue.replace(/-/g, '/');
          var minDate = new Date(minValue);
          if (minDate && (thisDate.valueOf() < minDate.valueOf())) {
            tooSmall = true;
            this.shouldConfirm = true;
          }
        }
        if (maxValue) {
          maxValue = maxValue.replace(/-/g, '/');
          var maxDate = new Date(maxValue);
          if (maxDate && (thisDate.valueOf() > maxDate.valueOf())) {
            tooBig = true;
            this.shouldConfirm = true;
          }
        }
      }

    } else if (this.element.getAttribute("field_type") == "number") {
      //this.value = this.getNumberFromString(this.value);
      var numValue = null;
      if (!isNaN(this.getNumberFromString(this.element.value)))
        numValue = this.getNumberFromString(this.element.value);
      else if (!isNaN(this.getNumberFromString(this.formElement.value)))
        numValue = this.getNumberFromString(this.formElement.value);
      else
        return "";


      minValue = this.getNumberFromString(this.element.getAttribute("min"));
      maxValue = this.getNumberFromString(this.element.getAttribute("max"));
      absMinValue = this.getNumberFromString(this.element.getAttribute("absoluteMin"));
      absMaxValue = this.getNumberFromString(this.element.getAttribute("absoluteMax"));

      if (!isNaN(numValue) && !isNaN(absMinValue)) {
        if (numValue < absMinValue) {
          tooSmall = true;
          minValue = absMinValue;
        }
      }
      if (!isNaN(numValue) && !isNaN(absMaxValue)) {
        if (numValue > absMaxValue) {
          tooBig = true;
          maxValue = absMaxValue;
        }
      }
      if (!tooBig && !tooSmall) {
        if (!isNaN(numValue) && !isNaN(minValue)) {
          if (numValue < minValue) {
            tooSmall = true;
            this.shouldConfirm = true;
          }
        }
        if (!isNaN(numValue) && !isNaN(maxValue)) {
          if (numValue > maxValue) {
            tooBig = true;
            this.shouldConfirm = true;
          }
        }
      }
    }

    if (tooSmall || tooBig) {
      if (!isNaN(minValue) && !isNaN(maxValue))
        return "Value out of Range: "+minValue+" - "+maxValue;
      if (tooSmall) return "Value smaller than minimum: "+ minValue;
      if (tooBig) return "Value bigger than maximum: "+ maxValue;
    }
    return "";
  },

  validateSelectOptions: function() {
    this.value = this.element.value
    var tagName = this.formElement.tagName;
    var suggestURL = this.formElement.getAttribute("ajaxURL") || "";
    var allowFreeText = this.formElement.getAttribute("allowFreeText") || "false";
    var optional = this.formElement.getAttribute("optional") || "false";

    if (tagName == "SELECT" || suggestURL != "" && allowFreeText != "true") {
      if (optional == "true" && this.value == "") {
        return "";
      }

      var isAValidEntry = false;

      var selectOptions = null;
      if (this.formElement.tagName == "SELECT") {
        selectOptions = this.formElement.getElementsByTagName("OPTION");
        var val_arr = new Array();
        var multiple = this.formElement.getAttribute("multiple") == "multiple";
        if (multiple)
          val_arr = this.value.split(tstMultipleSplitChar);
        else
          val_arr.push(this.value);
        isAValidEntry = true;
        for(var i=0; i<val_arr.length;i++){
          if(!valueIncludedInOptions(val_arr[i], selectOptions)){
            isAValidEntry = false;
          }
          break;
        }
      } else {
        selectOptions = $("options").getElementsByTagName("LI");
        for (var i=0; i<selectOptions.length; i++) {
          if (selectOptions[i].value == this.value ||
            selectOptions[i].text == this.value ||
            selectOptions[i].innerHTML == this.value) {
            isAValidEntry = true;
            break;
          }
        }
      }


      if (!isAValidEntry)
        return "Please select value from list (not: " + this.element.value + ")";

    }
    return "";
  },

  getNumberFromString: function(strValue) {
    var num = "";
    if (strValue != null && strValue.length > 0) {
      strValue.match(/(\d+\.*\d*)/);
      num = RegExp.$1;
    }
    return parseFloat(num);
  },
  /*
* The flag() function dispatches message flags from a TTInput object.
* To use it, add a 'JSON' flag in the options list of a given TTInput object.
* Syntax:
*  1. a string:
*      :flag => '{"message":"This is a TTInput flag message", "condition":"expression"}'
*  2. Using Rails JSON Object
*      :flag => ({:message=>'This is a TTInput flag message', :condition => 'expression'}).to_json
*/
  flag: function(){
    var flag    = this.element.getAttribute("flag");
    if (flag){
      flag    = JSON.parse(flag);
      value   = (this.element.value || this.formElement.value);

      // return if  the message, the condition and the value is missing
      if(!(flag['message'] && flag['condition'] && value)) return false;

      if (value.match(flag['condition'])){
        dispatchMessage(flag['message'], tstMessageBoxType.OKOnly);
        return true;
      }
    }
    return false;
  }

}



// Rails Date: object for parsing and manipulating Rails Dates
var RailsDate = function(aDateElement) {
  this.element = aDateElement;
};

RailsDate.prototype = {
  // return true if the anELement is stores day part of a date
  isDayOfMonthElement: function() {
    if (this.element.name.match(/\[day\]|3i|_day$/))
      return true;

    return false;
  },

  // return true if the anELement is stores month part of a date
  isMonthElement: function() {
    if (this.element.name.match(/\[month\]|2i/))
      return true;

    return false;
  },

  // return true if the anELement is stores year part of a date
  isYearElement: function() {
    if (this.element.name.match(/\[year\]|1i/))
      return true;

    return false;
  },

  // return the month element in the same set as anElement
  getDayOfMonthElement: function() {
    if (this.isDayOfMonthElement())
      return this.element;

    var dayElement = null;

    var re = /([^\[]*)\[([^\(]*)\(([^\)]*)/ig; // detect patient[birthdate(1i)]
    var str = re.exec(this.element.name);
    if (str == null) {
      str = re.exec(this.element.name); // i don't know why we need this!
    }
    if (str) {
      var strLen = str[1].length;
      var elementName = "";

      // check name_date[nameday(3i)]
      if ((str[1].search(/year$/) != -1) && (str[2].search(/year$/) != -1)) {
        str[1] = str[1].replace(/year$/, "date");
        str[2] = str[2].replace(/year$/, "day");
        elementName = str[1]+"["+str[2]+'(3i)]';
        dayElement = document.getElementsByName(elementName)[0];

      } else if ((str[1].search(/month$/) != -1) && (str[2].search(/month$/) != -1)) {
        str[1] = str[1].replace(/month$/, "date");
        str[2] = str[2].replace(/month$/, "day");
        elementName = str[1]+"["+str[2]+'(3i)]';
        dayElement = document.getElementsByName(elementName)[0];
      }

      if (!dayElement) {		// check name_date[name(3i)]
        if (str[1].search(/year$/) != -1 ) {
          elementName = str[1].replace(/year$/, "date")+"["+str[2]+'(3i)]';
          dayElement = document.getElementsByName(elementName)[0];
        } else if (str[1].search(/month$/) != -1 ) {
          elementName = str[1].replace(/month$/, "date")+'['+str[2]+'(3i)]';
          dayElement = document.getElementsByName(elementName)[0];
        }
      }

      if (!dayElement) {
        // patient[birthdate(1i)]
        if (this.isYearElement() &&
          (this.element.name == str[1]+'['+str[2]+'(1i)]')) {
          dayElement = document.getElementsByName(str[1]+'['+str[2]+'(3i)]')[0];

        } else if (this.isMonthElement() &&
          (this.element.name == str[1]+'['+str[2]+'(2i)]')) {
          dayElement = document.getElementsByName(str[1]+'['+str[2]+'(3i)]')[0];
        }
      }

    } else {
      // handle date[year], date[month], date[day]
      var nameLength = this.element.name.length;
      var elementName = "";

      if (this.element.name.search(/\[year\]/) != -1) {
        elementName = this.element.name.replace(/\[year\]/,"[day]");
        dayElement = document.getElementsByName(elementName)[0];

      } else if (this.element.name.search(/\[month\]/) != -1 ) {
        elementName = this.element.name.replace(/\[month\]/,"[day]");
        dayElement = document.getElementsByName(elementName)[0];
      }
    }
    // detect patient_year, patient_month, patient_day
    if (!dayElement && this.element.id.search(/_year$/)) {
      var elementId = this.element.id.replace(/_year$/, "_day");
      dayElement = $(elementId);

    } else if (!dayElement && this.element.id.search(/_month$/)) {
      var elementId = this.element.id.replace(/_month$/, "_day");
      dayElement = $(elementId);
    }

    return dayElement;
  },


  // return the month element in the same set as anElement
  getMonthElement: function() {
    if (this.isMonthElement()) return this.element;
    var monthElement = null;

    var re = /([^\[]*)\[([^\(]*)\(([^\)]*)/ig; // detect patient[birthdate(1i)]
    var str = re.exec(this.element.name);
    if (str == null) {
      str = re.exec(this.element.name); // i don't know why we need this!
    }
    if (str) {
      var strLen = str[1].length;
      var elementName = "";

      if (!monthElement) {		// name_month[namemonth(2i)]
        if ((str[1].search(/year$/) != -1) && (str[2].search(/year/) != -1)) {
          str[1] = str[1].replace(/year$/, "month");
          str[2] = str[2].replace(/year$/, "month");
          elementName = str[1]+"["+str[2]+'(2i)]';
          monthElement = document.getElementsByName(elementName)[0];

        } else if ((str[1].search(/date$/) != -1) && (str[2].search(/day$/) != -1)) {
          str[1] = str[1].replace(/date$/, "month");
          str[2] = str[2].replace(/day$/, "month");
          elementName = str[1]+"["+str[2]+'(2i)]';
          monthElement = document.getElementsByName(elementName)[0];
        }
      }

      if (!monthElement) {		// name_month[name(2i)]
        if (str[1].search(/year$/) != -1 ) {
          elementName = str[1].replace(/year$/, "month")+'['+str[2]+'(2i)]';
          monthElement = document.getElementsByName(elementName)[0];
        } else if (str[1].search(/date$/) != -1 ) {
          elementName = str[1].replace(/date$/, "month")+'['+str[2]+'(2i)]';
          monthElement = document.getElementsByName(elementName)[0];
        }
      }

      if (!monthElement) {		// name[name(2i)]
        if (this.isYearElement() &&
          (this.element.name == str[1]+'['+str[2]+'(1i)]')) {
          monthElement = document.getElementsByName(str[1]+'['+str[2]+'(2i)]')[0];

        } else if (this.isDayOfMonthElement() &&
          (this.element.name == str[1]+'['+str[2]+'(3i)]')) {
          monthElement = document.getElementsByName(str[1]+'['+str[2]+'(2i)]')[0];
        }
      }

    } else {
      // handle date[year], date[month], date[day]
      var nameLength = this.element.name.length;
      var elementName = "";

      if (this.element.name.search(/\[year\]/) != -1) {
        elementName = this.element.name.replace(/\[year\]/,"[month]");
        monthElement = document.getElementsByName(elementName)[0];

      } else if (this.element.name.search(/\[day\]/) != -1 ) {
        elementName = this.element.name.replace(/\[day\]/,"[month]");
        monthElement = document.getElementsByName(elementName)[0];
      }
    }
    // detect patient_day
    if (!monthElement && this.element.id.search(/_day$/)) {
      var elementId = this.element.id.replace(/_day$/, "_month");
      monthElement = $(elementId);
    }

    return monthElement;
  },

  // return the month element in the same set as anElement
  getYearElement: function() {
    if (this.isYearElement()) return this.element;
    var yearElement = null;

    var re = /([^\[]*)\[([^\(]*)\(([^\)]*)/ig; // detect patient[birthdate(1i)]
    var str = re.exec(this.element.name);
    if (str == null) {
      str = re.exec(this.element.name); // i don't know why we need this!
    }
    if (str) {
      var strLen = str[1].length;
      var elementName = "";

      if (!yearElement) {
        if ((str[1].search(/month$/) != -1) && (str[2].search(/month/) != -1)) {
          str[1] = str[1].replace(/month$/, "year");
          str[2] = str[2].replace(/month$/, "year");
          elementName = str[1]+"["+str[2]+'(1i)]';

        } else if ((str[1].search(/date$/) != -1) && (str[2].search(/day$/) != -1)) {
          str[1] = str[1].replace(/date$/, "year");
          str[2] = str[2].replace(/day$/, "year");
          elementName = str[1]+"["+str[2]+'(1i)]';
        }
        yearElement = document.getElementsByName(elementName)[0];
      }

      if (!yearElement) {
        if (str[1].search(/month$/) != -1 ) {
          elementName = str[1].replace(/month$/, "year")+'['+str[2]+'(1i)]';
        } else if (str[1].search(/date$/) != -1 ) {
          elementName = str[1].replace(/date$/, "year")+'['+str[2]+'(1i)]';
        }
        yearElement = document.getElementsByName(elementName)[0];
      }

      if (!yearElement) {
        yearElement = document.getElementsByName(str[1]+'['+str[2]+'(1i)]')[0];
      }

    } else {
      // handle date[year], date[month], date[day]
      var nameLength = this.element.name.length;
      var elementName = "";

      if (this.element.name.search(/\[month\]/) != -1) {
        elementName = this.element.name.replace(/\[month\]/,"[year]");
        yearElement = document.getElementsByName(elementName)[0];

      } else if (this.element.name.search(/\[day\]/) != -1 ) {
        elementName = this.element.name.replace(/\[day\]/,"[year]");
        yearElement = document.getElementsByName(elementName)[0];
      }
    }
    // detect patient_day
    if (!yearElement && this.element.id.search(/_day$/)) {
      var elementId = this.element.id.replace(/_day$/, "_year");
      yearElement = $(elementId);
    }

    return yearElement;
  },

  update: function(aValue) {
    if (this.isDayOfMonthElement()) {
      if (aValue.toLowerCase() == "unknown") {
        //this.element.value = "Unknown"
        this.element.value = aValue
      } else {
        this.element.value = stripLeadingZeroes(aValue);
      }
      return;
    }
    var dayElement = this.getDayOfMonthElement();
    var monthElement = this.getMonthElement();
    var yearElement = this.getYearElement();

    if (aValue.toLowerCase() == "unknown") {
      dayElement.value = "Unknown";
      monthElement.value = "Unknown";
      yearElement.value = "Unknown";
    }

    var dateArray = aValue.split('/');
    if (dayElement && !isNaN(dateArray[0])) {
      dayElement.value = stripLeadingZeroes(dateArray[0]);
    }

    if (monthElement && !isNaN(dateArray[1]))
      monthElement.value = stripLeadingZeroes(dateArray[1]);

    if (yearElement && !isNaN(dateArray[2]))
      yearElement.value = dateArray[2];

  }


};

// Add trim() method to String Class
String.prototype.trim = function()
{
  return this.replace(/^\s+|\s+$/g, '');
};

function getPreferredKeyboard(){
  if (typeof(tstUserKeyboardPref) != 'undefined' && tstUserKeyboardPref == 'qwerty') {
    return getQwertyKeyboard()
  }
  else{
    return getABCKeyboard()
  }
}

window.addEventListener("load", loadTouchscreenToolkit, false);

/*
* The dispatchMessage(message, messageBoxType) displays a 'message' with a custom message box
* The message box can be any of the types defined by tstMessageBoxType
* i.e. tstMessageBoxType.OKOnly,   tstMessageBoxType.OKCancel,
*      tstMessageBoxType.YesNo,    tstMessageBoxType.YesNoCancel
*
* By default, dispatchMessage(msg, messageBoxType) displays an OKCancel message box if:
*  a. the messageBoxType is not specified
*  b. the messageBoxType parameter does not match any of the message box types defined by tstMessageBoxType
*/

function dispatchMessage(message, messageBoxType) {

  var buttons = "";

  /* if there is no message return false */
  if(!message) return false;

  switch(messageBoxType){
    case tstMessageBoxType.OKOnly:
      buttons = "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\"; gotoPage(tstCurrentPage+1, false);'> <span> OK </span> </button>"
      break;

    case tstMessageBoxType.OKCancel:
      buttons = "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\"; gotoPage(tstCurrentPage+1, false);'> <span> OK </span> </button>" +
      "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\";'> <span> Cancel </span> </button>"
      break;

    case tstMessageBoxType.YesNo:
      buttons = "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\"; gotoPage(tstCurrentPage+1, false);'> <span> Yes </span> </button>" +
      "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\";'> <span>No</span> </button>"
      break;

    case tstMessageBoxType.YesNoCancel:
      buttons = "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\"; gotoPage(tstCurrentPage+1, false);'> <span> Yes </span> </button>" +
      "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\";'> <span> No </span> </button>" +
      "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\";'> <span> Cancel </span> </button>"
      break;

    default:
      buttons = "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\"; gotoPage(tstCurrentPage+1, false);'> <span> OK </span> </button>" +
      "<button class = 'button' onclick = 'this.offsetParent.style.display=\"none\";'> <span> Cancel </span> </button>"
      break;

  }
  /* TODO: consider adding style = 'text-lign: left;' to the message div */
  message =  "<div  style = 'margin:20px;'>" + message + "</div>"
  tstMessageBar.innerHTML = message + buttons

  tstMessageBar.style.display = "block";

  return true;
}

/*
* The dispatchFlag() function returns 'true' or 'false' depending on
* whether a TTInput flag is raised on the current page.
*/
function dispatchFlag(){
  var thisPage = new TTInput(tstCurrentPage);

  return thisPage.flag();
}

