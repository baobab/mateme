/*******************************************************************************
 *
 * Baobab Touchscreen Toolkit
 *
 * A library for transforming HTML pages into touch-friendly user interfaces.
 *
 * (c) 2011 Baobab Health Trust (http://www.baobabhealth.org)
 *
 * For license details, see the README.md file
 *
 ******************************************************************************/

/* Touchscreen Toolkit Settings */
tstRequireNextClickByDefault  = true;
tstConfirmCancel              = true;
tstEnableDateSelector         = false;

//Restrospective functionality doesn't belong here
//should be in pmis.js only
if (typeof(tstRetrospectiveMode) == "undefined")
    tstRetrospectiveMode = false;

/* end of Settings */

//--- Global vars

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

var tstDualViewOptions = [];

/*
 * tstMessageBoxType defines types of Touchscreen Toolkit Message Boxes:
 *
 * tstMessageBoxType.OKOnly : Displays OK button only.
 * tstMessageBoxType.OKCancel : Displays OK and Cancel buttons.
 * tstMessageBoxType.YesNo : Displays Yes and No buttons.
 * tstMessageBoxType.YesNoCancel : Displays Yes, No, and Cancel buttons.
 */

var tstMessageBoxType = {
    OKOnly:{},
    OKCancel:{},
    YesNo:{},
    YesNoCancel:{}
}

var touchscreenInterfaceEnabled = 0;
var contentContainer = null;

var tstTimerHandle = null;
var tstTimerFunctionCall = "";

var tstMultipleSelected = {};

var ajaxGeneralRequestResult;

var tstInternalCurrentDate = (new Date().getFullYear()) + "-" + padZeros((new Date().getMonth() + 1),2) + "-" + 
padZeros((new Date().getDate()), 2);

//--------------------------------------
// Default method in module to access element id changed to __$ to avoid
// conflicts with other libraries like jQuery. The same is recommended for use
// in your pages as much as possible. Where there are conflicts, comment out
// this method [$()] and use the other one [__$()].
function $(elementID){
    return document.getElementById(elementID);
}

function __$(elementID){
    return document.getElementById(elementID);
}

function selectedValue(elementID){
    element = __$(elementID)
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

function loadTouchscreenToolkit() {
    if(document.getElementById("loadingProgressMessage")){
        document.body.removeChild(document.getElementById("loadingProgressMessage"));
    }

    contentContainer = document.getElementById("content");

    if (document.forms.length>0) {
        tstFormElements = getFormElements();
        tstFormLabels = document.forms[0].getElementsByTagName("label");
        for(var i = 0; i < tstFormElements.length; i++){
            tstMultipleSelected[i] = {};
        }
    }
    if (window.location.href.search(/\/patient\/patient_search_names/) != -1) {
        tstSearchPage = true;
    }
    disableTextSelection(); // For Opera

    addLaunchButton();

    if (typeof(__$) == 'undefined') {
        __$ = function(elementId) {
            return document.getElementById(elementId);
        };
    }

    enableTouchscreenInterface();

    tstKeyboard = __$('keyboard');
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

    var backButton = __$('backButton');
    // create back button if not on first page
    if (pageNumber>0) {
        var prevPageNo = pageNumber-1;
        backButton.setAttribute("onMouseDown", "gotoPage("+prevPageNo+", null, true)");
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

    staticControls = __$('tt_staticControls');
    staticControls.setAttribute('class','staticControlsPage'+pageNumber+' '+pageStyleClass )

    return inputPage;
}

function createButtons() {
    var pageNumber = tstCurrentPage;

    var buttonsDiv = document.createElement('div');
    buttonsDiv.setAttribute("id", "buttons");
    buttonsDiv.setAttribute("class", "buttonsDiv");

    // Show/Hide Captured Data
    buttonsDiv.innerHTML = "<button id='showDataButton' class='button blue navButton' onMouseDown='toggleShowProgress()'><span>Show Data</span></button>";

    // create next/finish button
    buttonsDiv.innerHTML += "<button id='nextButton' class='button green navButton' onMouseDown='gotoNextPage()'><span>Next</span></button>";

    // create back button
    buttonsDiv.innerHTML += "<button id='backButton' class='button blue navButton'><span>Back</span></button>";

    // create clear button or new patient button if on search page
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

    // create cancel button
    buttonsDiv.innerHTML += "<button class='button navButton red' id='cancelButton' onMouseDown='confirmCancelEntry(" + (typeof(save_state) != "undefined"?"true":"") + ");'><span>Cancel</span></button>";

    return buttonsDiv
}

//TODO Look for optimization opportunities
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

    tstNextButton = __$("nextButton");
    tstMessageBar = __$('messageBar');
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

    __$('tt_staticControlsWrapper').setAttribute('class','tt_controls_'+identifier);

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

        case "TEXTAREA":
            touchscreenInputNode = inputDiv.appendChild(tstFormElements[i].cloneNode(true));
            break;
    }

    setTouchscreenAttributes(touchscreenInputNode, tstFormElements[i], pageNum);

    if (tstFormElements[i].value) {
        if (tstFormElements[i].tagName == "SELECT") {
            try {
                touchscreenInputNode.value = tstFormElements[i].options[tstFormElements[i].selectedIndex].innerHTML;
            } catch(e) {
                touchscreenInputNode.value = tstFormElements[i].value;
            }
        } else {
            touchscreenInputNode.value = tstFormElements[i].value;
        }
    }

    tstInputTarget = touchscreenInputNode;

    // options
    inputDiv.appendChild(getOptions());

    contentContainer.appendChild(wrapperPage);

    tstInputTarget.addEventListener("keyup", checkKey, false)
    tstInputTarget.focus();

    // show message if any
    var flashMessage = "";
    var flashElement = __$("flash_notice");
    if (flashElement){
        flashMessage += flashElement.innerHTML;
        flashElement.innerHTML = "";
    }

    flashElement = __$("flash_error");
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

function assignSelectOptionsFromSuggestions(formElement, options) {
    formElement.innerHTML = '';
    var lis = options.getElementsByTagName("li");
    for (var i=0; i<lis.length; i++) {
        var li = lis[i];
        var value = li.getAttribute("value") || li.getAttribute("tstValue") || li.innerHTML;
        var option = document.createElement("option");
        option.setAttribute("value", value);
        option.innerHTML = li.innerHTML;
        formElement.appendChild(option);
    }
}

function showAjaxResponse(aHttpRequest) {
    __$('options').innerHTML = aHttpRequest.responseText;
}

function getFormPostParams() {
    var params = "";
    for (var i=0; i<tstFormElements.length; i++) {
        if (tstFormElements[i].id) {
            params += tstFormElements[i].id + "=" + tstFormElements[i].value + "&";
        }else if (tstFormElements[i].name)
            params += tstFormElements[i].name + "=" + tstFormElements[i].value + "&";
    }
    return params;
}

function setTouchscreenAttributes(aInputNode, aFormElement, aPageNum) {
    aFormElement.setAttribute('touchscreenInputID',aPageNum);
    aInputNode.setAttribute('refersToTouchscreenInputID',aPageNum);
    aInputNode.setAttribute('page',aPageNum);
    aInputNode.setAttribute('id','touchscreenInput'+aPageNum);

    // Invoke different CSS declaration for TEXTAREA control
    if(aFormElement.tagName == "TEXTAREA" ){
        aInputNode.setAttribute('class','touchscreenTextAreaInput');
        aInputNode.setAttribute('cols','56');
        aInputNode.setAttribute('rows','8');
    } else {
        aInputNode.setAttribute('class','touchscreenTextInput');
    }

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
    }else {
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
                /*
			 * case "1i": helpText.innerHTML = str[1]+" Year"; break; case "2i":
			 * helpText.innerHTML = str[1]+" Month"; break; case "3i":
			 * helpText.innerHTML = str[1]+" Date"; break;
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
            var val = tstFormElements[i].value;
            if (tstFormElements[i].value) {
                if (tstFormElements[i].tagName == "SELECT")
                    try {
                        val = tstFormElements[i].options[tstFormElements[i].selectedIndex].innerHTML;
                    } catch(e) {
                        val = tstFormElements[i].value;
                    }
            }

            //tstFormElements[tstPages[tstCurrentPage]].getAttribute("ajaxURL") != ''

            if (tstFormElements[i].getAttribute("ajaxURL") != ''){
                ajaxRequest(options,tstFormElements[i].getAttribute("ajaxURL")+val);
            // ajaxRequest(tstFormElements[i],tstFormElements[i].getAttribute("ajaxURL")+val);
            }
        }
        else {
            if(tstFormElements[i].tagName == "SELECT") {
                var selectOptions = tstFormElements[i].getElementsByTagName("option");

                if(selectOptions.length > 0){
                    // Append an empty option first
                    if(selectOptions[0].innerHTML.trim().length > 0){
                        tstFormElements[i].innerHTML = "<option></option>" + tstFormElements[i].innerHTML;
                    }
                }

                if(tstFormElements[i].getAttribute("dualView") != undefined &&
                    tstFormElements[i].getAttribute("dualViewOptions") != undefined){
                    loadSelectOptions(selectOptions, options, tstFormElements[i].getAttribute("dualViewOptions"));
                } else {
                    loadSelectOptions(selectOptions, options);
                }
                
                var val = elementSelectedValue(tstFormElements[i]);
                if (val == null) val = "";
                tstInputTarget.value = val;
                if (tstFormElements[i].multiple) tstInputTarget.setAttribute("multiple", "multiple");
            }else if (tstFormElements[i].getAttribute("type") == "radio") {
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
    numberOfPages = tstPages.length; // getNumberOfPages();
    var currentPage = tstCurrentPage; // getCurrentPage();
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
        // inputIndex.innerHTML += (e+1)+". "+tstPageNames[e]+": <div
        // class='progressInputValue'>"+tstPageValues[e]+"</div>";
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
    var progressArea = __$('progressArea');
    var progressAreaHeader = __$('progressAreaHeader');
    var progressAreaBody = __$('progressAreaBody');
    var showProgressButton = __$('showDataButton');

    if (progressArea.style.display != 'block') {
        progressAreaBody.style.overflow = 'scroll';
        progressArea.style.display = 'block';
        showProgressButton.innerHTML = 'Hide Data';
    }
    else {
        progressAreaBody.style.overflow = 'hidden';
        progressArea.style.display = 'none';
        showProgressButton.innerHTML = 'Show Data';
    }
}

function loadSelectOptions(selectOptions, options, dualViewOptions) {    
    if(dualViewOptions != undefined || dualViewOptions != null) {
        tstDualViewOptions = eval(dualViewOptions);
        setTimeout("addSummary(" + selected + ")", 0);
    }

    if(tstFormElements[tstCurrentPage].getAttribute("selectAll")){         
        setTimeout("addSelectAllButton()", 0);     
    }
    
    var optionsList = "<ul id='tt_currentUnorderedListOptions'>";  // <li id='default'> </li>";
    var selectOptionCount = selectOptions.length;
    var selected = -1;

    options.innerHTML = "";

    for(var j=0;j<selectOptionCount;j++){
        // njih
        if (selectOptions[j].text.length < 1) {
            continue;
        }

        // inherit mouse down options
        mouseDownAction = selectOptions[j].getAttribute("onmousedown")
        mouseDownAction += '; updateTouchscreenInputForSelect(' +
        (tstFormElements[tstCurrentPage].getAttribute("multiple") ? '__$(\'optionValue\' + this.id), this' : 'this') + 
        '); ' + 
        (dualViewOptions ? 'changeSummary(this.id);' : '');
        
        optionsList += '<li id=\'' + (j-1) + '\' ';
        if (selectOptions[j].value) {
            optionsList += " id=\"option"+selectOptions[j].value +"\" tstValue=\""+selectOptions[j].value +"\"";
            selected = j;
        } 
        
        if(selectOptions[j].selected){
            try{
                setTimeout("__$(" + (j-1) + ").click();", 0);
            } catch(e){}
        }
        
        optionsList += (j % 2 == 0 ? " class='odd' tag='odd' " : " class='even' tag='even'") + 
        ' onmousedown="'+ (tstFormElements[tstCurrentPage].getAttribute("tt_requirenextclick") != null ? 
            (tstFormElements[tstCurrentPage].getAttribute("tt_requirenextclick") == "false" ? "checkRequireNextClick();" : "") : "") +'"';

        optionsList += (j % 2 == 0 ? " class='odd' tag='odd' " : " class='even' tag='even'") + 
        ' onclick="' + mouseDownAction + '" ';
        
        // njih
        optionsList += ">" + (tstFormElements[tstCurrentPage].getAttribute("multiple") ? 
            "<div style='display: table; border-spacing: 0px;'><div style='display: table-row'>" + 
            "<div style='display: table-cell;'><img id='img" + (j-1) + "' src='lib/images/unticked.jpg' alt='[ ]' />" + 
            "</div><div style='display: table-cell; vertical-align: middle; " + 
            "text-align: left; padding-left: 15px;' id='optionValue"  + (j-1) + "'>" : "") + 
        selectOptions[j].text + "</div></div></div></li>\n";
    }
    optionsList += "</ul>";
    options.innerHTML = optionsList;

}

function addSummary(position){
    tstTimerHandle = setTimeout("hideKeyBoard()", 0);
    
    if(__$("viewport")) {
        __$("viewport").style.height = "250px";
    }

    var summaryContainer = document.createElement("div");
    summaryContainer.id = "summaryContainer";
    summaryContainer.style.overflow = "hidden";
    summaryContainer.style.border = "1px solid #000";
    summaryContainer.style.height = "255px";
    summaryContainer.style.margin = "25px";
    summaryContainer.style.width = "94.5%";
    summaryContainer.style.backgroundColor = "#ccf";
    summaryContainer.style.fontSize = "1.5em";
    summaryContainer.style.marginBottom = "15px";

    __$("page" + tstCurrentPage).appendChild(summaryContainer);

    var styl = document.getElementById("summaryContainer").getAttribute("style");

    document.getElementById("summaryContainer").setAttribute("style", styl + " -moz-border-radius: 10px;");

    var summaryCushion = document.createElement("div");
    summaryCushion.id = "summaryCushion";
    summaryCushion.style.width = "98%";
    summaryCushion.style.height = "240px";
    summaryCushion.style.overflow = "auto";
    summaryCushion.style.margin = "8px";

    summaryContainer.appendChild(summaryCushion);

    var summary = document.createElement("div");
    summary.id = "summary";
    summary.style.borderSpacing = "1px";
    summary.style.display = "table";
    summary.style.width = "100%";

    summaryCushion.appendChild(summary);

    var tmpInputFrame = __$("inputFrame" + tstCurrentPage);

    __$("page" + tstCurrentPage).removeChild(__$("inputFrame" + tstCurrentPage));
    
    __$("page" + tstCurrentPage).appendChild(tmpInputFrame);

//if(position > 0){
//    changeSummary(position - 1);
//}
}

function changeSummary(position){
    __$("summary").innerHTML = "";

    if(position < tstDualViewOptions.length){
        var pos = 0;

        for(var item in tstDualViewOptions[position]) {
            var row = document.createElement("div");
            row.style.display = "table-row";
            row.style.backgroundColor = (pos % 2 == 0 ? "#ccf" : "#eef");

            __$("summary").appendChild(row);

            var cell1 = document.createElement("div");
            cell1.style.display = "table-cell";
            cell1.style.padding = "10px";
            // cell1.innerHTML = "<b style='color: #333;'>" + (item == "ta" ? "T/A" :
            //    item.replace(/_/g, " ").toProperCase()) + "</b>";

            cell1.innerHTML = "<b style='color: #333;'>" + item + "</b>";

            row.appendChild(cell1);

            var cell2 = document.createElement("div");
            cell2.style.display = "table-cell";
            cell2.style.padding = "10px";
            cell2.innerHTML = tstDualViewOptions[position][item];

            row.appendChild(cell2);

            pos++;
        }
    }
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

//TODO make these into 1 function
function updateTouchscreenInputForSelect(element){ 
    var inputTarget = tstInputTarget;
    var multiple = inputTarget.getAttribute("multiple") == "multiple";

    if (multiple) {
        var val_arr = inputTarget.value.split(tstMultipleSplitChar);
        var val = "";
        
        if (element.innerHTML.length>1)
            val = unescape(element.innerHTML);        
        // njih
        else if (element.value.length>1)
            val = element.value;
        
        // Check if the item is already included
        // var idx = val_arr.toString().indexOf(val);
        if (!tstMultipleSelected[tstCurrentPage][val]){ //(idx == -1){
            val_arr.push(val);
            tstMultipleSelected[tstCurrentPage][val] = true;
        } else {
            // val_arr.splice(idx, 1);
            val_arr = removeFromArray(val_arr, val);
            delete(tstMultipleSelected[tstCurrentPage][val]);
        }
        inputTarget.value = val_arr.join(tstMultipleSplitChar);
        if (inputTarget.value.indexOf(tstMultipleSplitChar) == 0)
            inputTarget.value = inputTarget.value.substring(1, inputTarget.value.length);
    } else {
        if (element.value.length>1){
            inputTarget.value = element.value;
        }
        else if (element.innerHTML.length>0){
            inputTarget.value = element.innerHTML;
        }
    }

    highlightSelection(element.parentNode.childNodes, inputTarget)
            
    tt_update(inputTarget);
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
    // If lots of things are selected this could be bad... but indexOf is js
    // 1.6+
    for (var i = 0; i < val_arr.length; i++) {
        if (opt.trim().replace("\n", "") == val_arr[i].trim().replace("\n", "")) return true;
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
            // njih
            if(optionIncludedInValue(unescape(options[i].innerHTML), val_arr)){
                options[i].style.backgroundColor = "lightblue"
                
                if(tstFormElements[tstCurrentPage].getAttribute("multiple")){
                    var id = options[i].id.match(/optionValue(\d+)$/);
                    
                    if(id){
                        __$(id[1]).style.backgroundColor = "lightblue"
                        __$("img" + id[1]).src = "/touchscreentoolkit/lib/images/ticked.jpg";
                    }            
                }
        
                if (options[i].getAttribute("tstValue")) {
                    inputElement.setAttribute("tstValue", options[i].getAttribute("tstValue"));
                }
            }
            else{
                options[i].style.backgroundColor = ""   
                
                if(tstFormElements[tstCurrentPage].getAttribute("multiple")){
                    var id = options[i].id.match(/optionValue(\d+)$/);
                    
                    if(id){
                        __$(id[1]).style.backgroundColor = ""
                        __$("img" + id[1]).src = "/touchscreentoolkit/lib/images/unticked.jpg";
                    }            
                }
        
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
            var optionNodes = optionsList.getElementsByTagName("LI");
            var optionNodeCount = optionNodes.length;
            for(var i=0;i<optionNodeCount;i++){
                
                if(optionNodes[i].getAttribute("value") != null){
                    if(optionNodes[i].getAttribute("value").trim() != optionNodes[i].innerHTML.trim()) {
                        optionNodes[i].setAttribute("tstValue", optionNodes[i].getAttribute("value"));
                    }
                }

                var onmousedown = optionNodes[i].getAttribute("onmousedown");
                if (onmousedown == null || onmousedown.match(/updateTouchscreenInput/) == null)
                    optionNodes[i].setAttribute("onmousedown", onmousedown + 
                        ((tstFormElements[tstPages[tstCurrentPage]].tagName == "SELECT") ? "; updateTouchscreenInputForSelect(this);" :
                            "; updateTouchscreenInput(this);"));
                    
                if (optionNodes[i].getAttribute("tstValue") == tstInputTarget.value || optionNodes[i].getAttribute("value") == tstInputTarget.value) {
                    tstInputTarget.value = optionNodes[i].innerHTML;
                    optionNodes[i].style.backgroundColor = "lightblue";
                    if (optionNodes[i].hasAttribute("tstValue"))
                        tstInputTarget.setAttribute('tstValue', optionNodes[i].getAttribute("tstValue"));
                    else if (optionNodes[i].hasAttribute("value"))
                        tstInputTarget.setAttribute('value', optionNodes[i].getAttribute("value"));
                } else if (optionNodes[i].innerHTML == tstInputTarget.value) {
                    optionNodes[i].style.backgroundColor = "lightblue";
                }
                
            }
        }
        optionsList.innerHTML = "<ul>"+optionsList.innerHTML+"</ul>"
        var inputElement = tstFormElements[tstPages[tstCurrentPage]];
        assignSelectOptionsFromSuggestions(inputElement, document.getElementById('options'));

        var val = tstInputTarget.value;
        if (val == null) val = "";
        inputElement.value = val;
    }
}

function tt_update(sourceElement, navback){
    var sourceValue = null;
    if (!sourceElement) return;

    var condition = sourceElement.getAttribute("condition");
        
    if (sourceElement.getAttribute("tstValue")) {        
        // skip destination page when a condition is false
        if (condition && navback == true) {
            sourceValue = "";            
        } else {
            sourceValue = sourceElement.getAttribute("tstValue");
        }                
    }
    else {
        if (condition && navback == true) {
            sourceValue = "";            
        } else {
            sourceValue = sourceElement.value;
        }
    }

    var targetElement = returnElementWithAttributeValue("touchscreenInputID", sourceElement.getAttribute("refersToTouchscreenInputID"), tstFormElements);
    targetElement.focus();
    
    switch (sourceElement.tagName){
        // switch (targetElement.tagName){
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
                            }
                            else
                                targetElement.options[i].selected = false;

                        }
                    }
                }

            }
            break;
        case "SELECT":
            
            var val_arr = new Array();
            if (targetElement.multiple) {
                val_arr = sourceElement.value.split(tstMultipleSplitChar);
            }
            else {
                val_arr.push(sourceElement.value);
            }

            for(i=0;i<targetElement.options.length;i++){
                if(optionIncludedInValue(targetElement.options[i].value, val_arr)){
                    targetElement.options[i].selected = true;
                    if (!targetElement.multiple)
                        break;
                } else {
                    targetElement.options[i].selected = false;
                }
            }
			 
            break;
        case "TEXTAREA":
            targetElement.value = sourceValue;
            break;
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
    var strDate = "";  // sourceValue.split('/');

    var re = /([^\[]*)\[([^\(]*)\(([^\)]*)/ig; // detect patient[birthdate(1i)]
    // patient[birthdate(2i)]
    var str = re.exec(aDateElement.name);
    if (str == null) {
        str = re.exec(aDateElement.name); // i don't know why we need this!
    }
    if (str) {
        // handle format: patient[birthdate(1i)], patient[birthdate(2i)],
        // patient[birthdate(3i)]
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
        // var yearValue =
        // document.getElementsByName(str[1]+'['+str[2]+'(1i)]')[0].value;
        var yearValue = yearElement.value;
        if (!isNaN(dayValue) && !isNaN(monthValue && !isNaN(yearValue))) {
            strDate = dayValue+'/'+monthValue+'/'+yearValue;
        }

    } else {
        // handle date[year], date[month], date[day]
        var nameLength = aDateElement.name.length;
        var baseName = aDateElement.name.substr(0, nameLength-6);
        if (aDateElement.name.search(/\[year\]/) != -1) {
            strDate = document.getElementsByName(baseName+"[day]")[0].value + '-';
            strDate += document.getElementsByName(baseName+"[month]")[0].value + '-';
            strDate += document.getElementsByName(baseName+"[year]")[0].value;
        }
    }

    if (strDate.length != 10 && aDateElement.value) return aDateElement.value;
    if (strDate.length != 10) return "";
    else return strDate;
}

// This detour has been added to capture alert messages that need to be displayed
// before the next page is viewed
function gotoPage(destPage, validate, navback){
    var currentPage = tstCurrentPage;
    var currentInput = __$("touchscreenInput"+currentPage);

    var navback = (navback ? navback : false);       

    tstMultipleSelected[tstCurrentPage] = {}; 
    
    //	tt_BeforeUnload
    var unloadElementId = 'touchscreenInput';
    if (currentPage < destPage) {
        unloadElementId = 'touchscreenInput'+(destPage-1);
    }
    else if (currentPage > destPage) {
        unloadElementId = 'touchscreenInput'+(destPage+1);
    }

    var unloadElement = __$(unloadElementId);
    if (unloadElement) {
        var onUnloadCode = unloadElement.getAttribute('tt_BeforeUnload');
        if (onUnloadCode) {
            var result = eval(onUnloadCode);

            if(result == true){
                // Set a global handle for the timer function and the
                // corresponding function for earlier cancelling when required
                tstTimerHandle = setTimeout("navigateToPage(" + destPage + ", " + validate + ", " + navback + ");", 3000);
                tstTimerFunctionCall = "navigateToPage(" + destPage + ", " + validate + ", " + navback + ");";
            } else {
                navigateToPage(destPage, validate, navback);
            }
        } else {
            navigateToPage(destPage, validate, navback);
        }
    } else {
        navigateToPage(destPage, validate, navback);
    }
}

//args: page number to load, validate: true/false
function navigateToPage(destPage, validate, navback){    
    clearTimeout(tstTimerHandle);
    
    var currentPage = tstCurrentPage;
    var currentInput = __$("touchscreenInput"+currentPage);

    if (currentInput) {
        // if (__$('dateselector') != null && typeof ds != 'undefined')
        // ds.update(currentInput);
        if (validate) {
            if (!inputIsValid()) return;
            // if (!inputIsAcceptable()) return;

            if(dispatchFlag()) return;
        }
        
        tstPageValues[currentPage] = currentInput.value;        
        
        tt_update(currentInput, navback);
        
    // Progress Indicator -- disabled
    /*
		 * var currentPageIndex = __$("progressAreaPage"+currentPage); if
		 * (currentPageIndex) { // remove current index mark
		 * currentPageIndex.innerHTML = (currentPage+1)+". "+
		 * getHelpText(tstFormElements[tstPages[currentPage]],
		 * currentPage).innerHTML+ ": <div
		 * class='progressInputValue'>"+progressAreaFormat(currentInput)+"</div>";
		 * currentPageIndex.removeAttribute("class"); }
		 */
    }
    //	tt_OnUnload
    var unloadElementId = 'touchscreenInput';
    if (currentPage < destPage) {
        unloadElementId = 'touchscreenInput'+(destPage-1);
    }
    else if (currentPage > destPage) {
        unloadElementId = 'touchscreenInput'+(destPage+1);
    }

    var unloadElement = __$(unloadElementId);
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
        /*
		try {
			var thisPage = __$('page'+currentPage);
			var pageWrapper = thisPage.parentNode;
			pageWrapper.parentNode.removeChild(pageWrapper);
		} catch(e) {
			var pages = document.getElementsByClassName('inputPage');
			for(var i=0; i<pages.length; i++) {
				pages[i].parentNode.removeChild(pages[i]);
			}
		}
                */

        if(__$('page'+currentPage) != null){

            var thisPage = __$('page'+currentPage);
            var pageWrapper = thisPage.parentNode;
            pageWrapper.parentNode.removeChild(pageWrapper);

        } else {

            var pages = document.getElementsByClassName('inputPage');
            for(var i=0; i<pages.length; i++) {
                pages[i].parentNode.removeChild(pages[i]);
            }

        }

        inputTargetPageNumber = destPage;
        tstCurrentPage = destPage;
        populateInputPage(destPage);
        __$("progressAreaPage"+destPage).setAttribute("class", "currentIndex");

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

        if(tstFormElements[tstCurrentPage].tagName == "SELECT") {
            if(tstFormElements[tstCurrentPage].getAttribute("multiple")){
                for(var j=0;j<tstFormElements[tstCurrentPage].options.length;j++){
                    if(__$(j)){
                        __$(j).click();
                        __$(j).click();
                    } 
                }
            }
        }
            
    }
    else{

        /*
        var popupBox = __$("popupBox");
        if (popupBox) {
            popupBox.style.visibility = "visible";
        }
    */
   
        showStatus();

        document.forms[0].submit();
    }
}


function inputIsValid() {
    // don't leave current page if no value has been entered
    var ttInput = new TTInput(tstCurrentPage);
    var validateResult = ttInput.validate();
    var messageBar = __$("messageBar");
    messageBar.innerHTML = "";

    if (validateResult.length > 0 && !tstSearchPage) {
        var message = validateResult;

        if (ttInput.shouldConfirm) {

            messageBar.innerHTML += "<p>" + ((message.match(/^Value\s/))?(message.replace(/^Value\s/, "The value is ")):message) +
            ". Are you sure about this value?</p><div style='display: block;'>" +
            "<button class='button' style='float: none;' onclick='this.offsetParent.style.display=\"none\"; " +
            "gotoPage(tstCurrentPage+1, false);' onmousedown='this.offsetParent.style.display=\"none\"; " +
            "gotoPage(tstCurrentPage+1, false);'><span>Yes</span></button><button class='button' " +
            "style='float: none; right: 3px;' onmousedown='this.offsetParent.style.display=\"none\"; '>" +
            "<span>No</span></button>";

            messageBar.style.display = "block";

        } else {
            showMessage(message)
        }
        return false;
    }
    return true;
}

function confirmValue() {
    var confirmationBar = __$("confirmationBar");
    confirmationBar.innerHTML = "<span style='font-size: 2em;'>Username: </span>";
    var username = document.createElement("input");
    username.setAttribute("id", "confirmUsername");
    username.setAttribute("type", "text");
    username.setAttribute("textCase", "lower");
    username.style.fontSize = "2em";
    username.style.width = "252px";
    confirmationBar.appendChild(username);

    confirmationBar.innerHTML += "<div style='display: block; margin-top: 15px;'><input type='submit'" +
    " value='OK' class='btn' style='float: left;' onclick='validateConfirmUsername()'" + 
    " onmousedown='validateConfirmUsername()'/><input type='submit' value='Cancel' " + 
    " class='btn' style='float: right; right: 3px;' onmousedown='cancelConfirmValue()' />";

    confirmationBar.style.display = "block";
    tstInputTarget = __$("confirmUsername");
    if (typeof(barcodeFocusTimeoutId) != "undefined")
        window.clearTimeout(barcodeFocusTimeoutId);
    tstInputTarget.focus();
    tstKeyboard.innerHTML = "";

    if (!__$("popupKeyboard")) {
        var popupKeyboard = document.createElement("div");
        popupKeyboard.setAttribute("id", "popupKeyboard");
        popupKeyboard.setAttribute("class", "keyboard");
        popupKeyboard.innerHTML = getPreferredKeyboard();
        contentContainer.appendChild(popupKeyboard);
    }
    __$("backspace").style.display = "inline";
    hideMessage();
}

function validateConfirmUsername() {
    var username = __$('confirmUsername');
    if (username.value == tstUsername) {
        cancelConfirmValue();
        gotoPage(tstCurrentPage+1, false);
    } else {
        showMessage("Username entered is invalid");
    }
}

function cancelConfirmValue() {
    __$("confirmationBar").style.display = "none";
    tstInputTarget = __$("touchscreenInput"+tstCurrentPage);
    if (typeof(focusForBarcodeInput) != "undefined")
        focusForBarcodeInput();

    contentContainer.removeChild(__$("popupKeyboard"));
    showBestKeyboard(tstCurrentPage);
}

function clearInput(){
    __$('touchscreenInput'+tstCurrentPage).value = "";

    if(doListSuggestions){
        listSuggestions(tstCurrentPage);
    }
    
    if(tstFormElements[tstPages[tstCurrentPage]].tagName == "SELECT"){
        var options = __$("tt_currentUnorderedListOptions").getElementsByTagName("li");
            
        if(tstFormElements[tstPages[tstCurrentPage]].getAttribute("multiple")){
            for(var i = 0; i < options.length; i++){
                if(options[i].style.backgroundColor == "lightblue"){
                    options[i].click();
                }
            }
        } else {
            for(var i = 0; i < options.length; i++){
                if(options[i].style.backgroundColor == "lightblue"){
                    options[i].style.backgroundColor = "";
                    tstFormElements[tstPages[tstCurrentPage]].value = ""; 
                    __$('touchscreenInput'+tstCurrentPage).setAttribute("tstvalue", "");
                }
            }
        }
    }
}

function showMessage(aMessage, withCancel, timed) {
    if(typeof(tstMessageBar) == "undefined"){
        __$("content").innerHTML += "<div id='messageBar' class='messageBar'></div>";
        
        tstMessageBar = __$('messageBar');
    }
    
    var messageBar = tstMessageBar;
    messageBar.innerHTML = aMessage +
    "<br />" + (typeof(withCancel) != "undefined" ? (withCancel == true ?
        "<button onmousedown='tstMessageBar.style.display = \"none\"; " +
        "clearTimeout(tstTimerHandle);'><span>Cancel</span></button>" : "") : "") +
    "<button style='width: 200px;' onmousedown='tstMessageBar.style.display = \"none\"; " +
    "clearTimeout(tstTimerHandle); eval(tstTimerFunctionCall);'><span>OK</span></button>";
    if (aMessage.length > 0) {
        messageBar.style.display = 'block'
        if((typeof(timed) == "undefined" ? true : timed) == true){
            window.setTimeout("hideMessage()",3000)
        }
    }
}

function hideMessage(){
    tstMessageBar.style.display = 'none'
}

function disableTouchscreenInterface(){
    // delete touchscreen tstPages
    contentContainer.removeChild(__$('page'+tstCurrentPage));
    contentContainer.removeChild(__$('keyboard'));
    contentContainer.removeChild(__$('progressArea'));
    contentContainer.removeChild(__$('buttons'));
    document.forms[0].style.display = 'block';

    touchscreenInterfaceEnabled = 0;
    document.getElementById('launchButton').innerHTML = "Enable Touchscreen UI";
}

function confirmCancelEntry(save) {     // If you want to save state set save =
    // true
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

    window.location.href = window.tt_cancel_destination || "/people";       // "/patient/menu?no_auto_load_forms=true";/*
// specially
// for
// dmht
// */
}

//format the given element's value for display on the Progress Indicator
//TODO: Crop long values
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
            else __$("keyboard").innerHTML = getNumericKeyboard();
        }	else {
            getDatePicker();
        }
        return;
    }
    var optionCount = __$('options').getElementsByTagName("li").length;
    if ((optionCount > 0 && optionCount < 6 && inputElement.tagName == "SELECT") || (inputElement.getAttribute("multiple") == "multiple")) {
        __$("keyboard").innerHTML = "";
        return;
    }

    switch (inputElement.getAttribute("field_type")) {
        case "password":
        case "full_keyboard":
            showKeyboard(true, (typeof(tstUserKeyboardPref) != 'undefined' && 
                tstUserKeyboardPref.toLowerCase() == "qwerty" ? true : false));
            break;
        case "alpha":
            __$("keyboard").innerHTML = getPreferredKeyboard();
            break;
        case "number":
            __$("keyboard").innerHTML = getNumericKeyboard();
            break;
        case "date":
            getDatePicker();
            break;
        case "time":
            getTimePicker();
            break;
        case "advancedTime":
            getAdvancedTimePicker();
            break;
        case "boolean":
            __$("keyboard").innerHTML = "";
            break;
        case "calendar":
            __$("keyboard").innerHTML = "";
            __$("page" + aPageNum).innerHTML = "";
            
            var selected = {};
            var selecteddate = null;
            var start_date_week = null;
            var end_date_week = null;
            
            if(inputElement.getAttribute("selecteddays")){
                selected = eval(inputElement.getAttribute("selecteddays"));
            }
            
            if(inputElement.getAttribute("startweekdate")){
                start_date_week = inputElement.getAttribute("startweekdate");
            }
            
            if(inputElement.getAttribute("endweekdate")){
                end_date_week = inputElement.getAttribute("endweekdate");
            }
            
            selecteddate = inputElement.value;
            
            createCalendar("page" + aPageNum, inputElement.id, selecteddate, 
                selected, start_date_week, end_date_week);                  
            break;
        default:
            __$("keyboard").innerHTML = getPreferredKeyboard();
            break;
    }
}

//check if this element's name is for a Rails' datetime_select
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
	 * // for date[year] dates if (aElement.name.search(/\[year\]/gi) != -1) return
	 * true;
	 *
	 * if (aElement.id.search(/_day$/) != -1) return true;
	 *  // for person[date(1i)] dates var re = /([^\[]*)\[([^\(]*)\(([^\)]*)/ig; var
	 * str = re.exec(aElement.name); if (str == null) { str =
	 * re.exec(aElement.name); // i don't know why we need this! } if (str == null) {
	 * return false; } else { return true; } //return (str[2] != null);
	 */
}

//return whether this element represents a year, month or day of month
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
    if(__$("category")){
        document.body.removeChild(__$("category"));
    }
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
    var keyboard = __$("keyboard");
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
    // getButtonString('date','Date') +
    "</span><span style='padding-left:0px' class='buttonLine'>" +
    getButtons("ASDFGHJKL") +
    getButtonString('apostrophe',"'") +
    getButtonString('num','0-9');

    // if(tstFormElements[tstCurrentPage].tagName == "TEXTAREA") {
    //    keyboard = keyboard +
    //    getButtonString('return',"ENTER");
    // }

    keyboard = keyboard +
    "</span><span style='padding-left:0px' class='buttonLine'>" +
    getButtons("ZXCVBNM,.") + (tstFormElements[tstCurrentPage].tagName == "TEXTAREA" ? "" :
        getButtonString('whitespace','Space', 'width: 85px;')) +
    getButtonString('abc','A-Z') +
    getButtonString('SHIFT','aA') +
    "</span>";

    if(tstFormElements[tstCurrentPage].tagName == "TEXTAREA") {
        keyboard = keyboard +
        "</span><span style='padding-left:0px' class='buttonLine'>" +
        getButtonString('whitespace','Space', 'width: 520px;') +
        getButtonString('return',"ENTER", 'width: 120px;') +
        "</span>";
    }

    keyboard = keyboard +
    "</span>"
    return keyboard;
}

function getABCKeyboard(){
    // var keyboard = createKeyboardDiv();
    keyboard =
    "<span class='abcKeyboard'>" +
    "<span class='buttonLine'>" +
    getButtons("ABCDEFGH") +
    getButtonString('apostrophe',"'") +
    getButtonString('backspace','Delete') +
    getButtonString('num','0-9') +
    "</span><span class='buttonLine'>" +
    getButtons("IJKLMNOP") +
    getButtonString('qwerty','qwerty') +
    getButtonString('SHIFT','aA') ;

    // if(tstFormElements[tstCurrentPage].tagName == "TEXTAREA") {
    //    keyboard = keyboard +
    //    getButtonString('return',"ENTER");
    // }

    keyboard = keyboard +
    getButtonString('Unknown','Unknown') +
    getButtonString('na','N/A') +
    "</span><span class='buttonLine'>" +
    getButtons("QRSTUVWXYZ") + (tstFormElements[tstCurrentPage].tagName == "TEXTAREA" ? "" : 
        getButtonString('whitespace','Space', 'width: 85px;')) +
    "</span>";

    if(tstFormElements[tstCurrentPage].tagName == "TEXTAREA") {
        keyboard = keyboard +
        "</span><span style='padding-left:0px' class='buttonLine'>" +
        getButtonString('whitespace','Space', 'width: 520px;') +
        getButtonString('return',"ENTER", 'width: 120px;') +
        "</span>";
    }

    keyboard = keyboard +
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
    getButtonString('char','A-Z') +
    getButtonString('date','Date') +
    getButtonString('na','N/A') +
    "</span><span id='buttonLine2' class='buttonLine'>" +
    getButtons("456") +
    getCharButtonSetID("%","percent") +
    getCharButtonSetID("=","equals") +
    getCharButtonSetID("<","lessthan") +
    getCharButtonSetID(">","greaterthan") +
    getButtonString('qwerty','qwerty') +
    "</span><span id='buttonLine3' class='buttonLine'>" +
    getButtons("789") +
    // getCharButtonSetID("0","zero") +
    getCharButtonSetID(".","decimal") +
    getCharButtonSetID(",","comma") +
    getButtonString('backspace','Delete') +
    getButtonString('Unknown','Unknown') +
    getButtonString('SHIFT','aA') +
    "</span>" +
    "</span><span id='buttonLine3' class='buttonLine'>" +
    getCharButtonSetID("0","zero") +
    "</span>"

    return keyboard;
}

function getTimePicker() {
    if (typeof(TimeSelector) == "undefined")
        return;

    var inputElement = tstFormElements[tstPages[tstCurrentPage]];
    var keyboardDiv = __$('keyboard');
    keyboardDiv.innerHTML = "";

    var railsDate = new RailsDate(inputElement);
    if (railsDate.isDayOfMonthElement()) {
        getDayOfMonthPicker(railsDate.getYearElement().value, railsDate.getMonthElement().value);
        return;
    }

    var defaultDate = joinDateValues(inputElement);
    //defaultDate = defaultDate.replace("-", "/", "g");
    var arrDate = defaultDate.split(':');
    __$("touchscreenInput"+tstCurrentPage).value = defaultDate;

    if (arrDate.length == 3) {
        ds = new TimeSelector({
            element: keyboardDiv,
            target: tstInputTarget,
            hour: arrDate[0],
            minute: arrDate[1],
            second: arrDate[2],
            format: "H:M:S",
            maxNow: (tstInputTarget.getAttribute("maxNow") ? true : false)
        });
    } else {
        ds = new TimeSelector({
            element: keyboardDiv,
            target: tstInputTarget,
            format: "H:M:S",
            maxNow: (tstInputTarget.getAttribute("maxNow") ? true : false)
        });
    }

// __$("options" + tstCurrentPage).innerHTML = "";
}

function getDatePicker() {
    if (typeof(DateSelector) == "undefined")
        return;

    var inputElement = tstFormElements[tstPages[tstCurrentPage]];
    var keyboardDiv = __$('keyboard');
    keyboardDiv.innerHTML = "";

    var railsDate = new RailsDate(inputElement);
    if (railsDate.isDayOfMonthElement()) {
        getDayOfMonthPicker(railsDate.getYearElement().value, railsDate.getMonthElement().value);
        return;
    }

    var defaultDate = joinDateValues(inputElement);

    defaultDate = defaultDate.replace("/", "-", "g");
    var arrDate = defaultDate.split('-');
    __$("touchscreenInput"+tstCurrentPage).value = defaultDate;

    var maximumDate = (tstInputTarget.getAttribute("maxDate") != null ? tstInputTarget.getAttribute("maxDate") : "");
    var maxDate = null;

    if(maximumDate != ""){
        var tmpDate = maximumDate.split("-");

        if(tmpDate.length == 3){
            maxDate = new Date(tmpDate[0], tmpDate[1] - 1, tmpDate[2]);
        }
    }

    if (!isNaN(Date.parse(defaultDate))) {
        ds = new DateSelector({
            element: keyboardDiv,
            target: tstInputTarget,
            year: arrDate[0],
            month: arrDate[1],
            date: arrDate[2],
            format: "dd-MM-yyyy",
            max: (maxDate ? maxDate : new Date())
        });
    } else {
        ds = new DateSelector({
            element: keyboardDiv,
            target: tstInputTarget,
            format: "dd-MMM-yyyy",
            max: (maxDate ? maxDate : new Date())
        });
    }

    __$("options").innerHTML = "";
}

function getYearPicker() {
    ds = new DateSelector({
        element: __$("keyboard"),
        target: tstInputTarget,
        format: "yyyy"
    });
}

function getMonthPicker() {
    ds = new DateSelector({
        element: __$("keyboard"),
        target: tstInputTarget,
        format: "MM"
    });
}

function getDayOfMonthPicker(aYear, aMonth) {
    var keyboard =__$('keyboard')
    keyboard.innerHTML = "";
    numberOfDays = DateUtil.getLastDate(aYear,aMonth-1).getDate();

    for(var i=1;i <= numberOfDays;i++){
        keyboard.innerHTML += getButtonString(i,i);

        /* set minimum width for the button to 80 pixels */
        button = document.getElementById(i);
        button.setAttribute("style","min-width:80px;");

        /* break on the seventh button, implying the end of the week */
        if(i%7 == 0) keyboard.innerHTML +="<span><br/></span>";
    }
    keyboard.innerHTML += getButtonString("Unknown","Unknown")

    if (tstInputTarget.value > numberOfDays) {
        tstInputTarget.value = numberOfDays;
    }
    tstInputTarget.setAttribute("singleButtonMode", "true");
/*
	 * if (aYear && aMonth) ds = new DateSelector({element: __$("keyboard"), target:
	 * tstInputTarget, year: aYear, month: aMonth, format: "dd" }); else if (aMonth)
	 * ds = new DateSelector({element: __$("keyboard"), target: tstInputTarget, month:
	 * aMonth, format: "dd" }); else ds = new DateSelector({element: __$("keyboard"),
	 * target: tstInputTarget, format: "dd" });
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

function getButtonString(id, string, style){
    return "<button \
	onMouseDown='press(this.id);' \
	class='keyboardButton' \
	id='" + id + "' style='" + style + "'><span>" +
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
            case 'whitespace':
                inputTarget.value += ' ';
                break;
            case 'return':
                inputTarget.value += "\n";
                break;
            case 'apostrophe':
                inputTarget.value += "'";
                break;
            case 'na':
                inputTarget.value = "N/A";
                break;
            case 'abc':
                tstUserKeyboardPref = 'abc';
                __$('keyboard').innerHTML = getPreferredKeyboard();
                if (typeof(saveUserKeyboardPref) != 'undefined'){
                    saveUserKeyboardPref('abc');
                }
                break;
            case 'qwerty':
                tstUserKeyboardPref = 'qwerty';
                __$('keyboard').innerHTML = getPreferredKeyboard();
                if (typeof(saveUserKeyboardPref) != 'undefined'){
                    saveUserKeyboardPref('qwerty');
                }
                break;
            case 'num':
                __$('keyboard').innerHTML = getNumericKeyboard();
                break;
            case 'char':
                __$('keyboard').innerHTML = getPreferredKeyboard();
                if (typeof(saveUserKeyboardPref) != 'undefined'){
                    saveUserKeyboardPref('abc');
                }
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
//refresh options
function listSuggestions(inputTargetPageNumber) {
    if (inputTargetPageNumber == undefined) {
        return;
    }
    var inputElement = __$('touchscreenInput'+inputTargetPageNumber);

    if(inputElement.getAttribute("ajaxURL") != null){
        ajaxRequest(__$('options'),inputElement.getAttribute("ajaxURL")+inputElement.value);
    } else {
        var optionsList = document.getElementById('options');
        options = optionsList.getElementsByTagName("li");

        var searchTerm = "";

        if(inputElement.getAttribute("ttMatchFromBeginning") != null && inputElement.getAttribute("ttMatchFromBeginning") == "true"){
            searchTerm = new RegExp("^" + inputElement.value, "i");
        } else {
            searchTerm = new RegExp(inputElement.value,"i");
        }

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

    var inputElement = __$('touchscreenInput'+inputTargetPageNumber);
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
    var keyboardElement = __$("keyboard");
    // disable all keys
    for (var i=0;i<allKeys.length; i++) {
        if (keyButton = __$(allKeys.substring(i,i+1))) {
            keyButton.style.backgroundColor = "";
            keyButton.style.color = "gray";
            keyButton.disabled = true;
        }
    }
    // enable only valid keys
    for (var i=0;i<validKeys.length; i++) {
        if (keyButton = __$(validKeys.substring(i,i+1))) {
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


//Touchscreen Input element
var TTInput = function(aPageNum) {
    this.element = __$("touchscreenInput"+aPageNum);
    this.formElement = tstFormElements[tstPages[aPageNum]]
    this.value = this.element.value;

    if (isDateElement(this.formElement)) {
        this.formElement.value = this.element.value; // update date value before
        // validation so we can use
        // RailsDate
        var rDate = new RailsDate(this.formElement);
        this.value = rDate.getDayOfMonthElement().value+"/"+rDate.getMonthElement().value+"/"+rDate.getYearElement().value;
    }
    this.shouldConfirm = false;
};
TTInput.prototype = {
    // return error msg when input value is invalid, blank otherwise
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
            // this.value.match(/(\d+)\/(\d+)\/(\d+)/);
            
            this.value = this.value.replace(/\//g, '-');
            var thisDate = new Date(this.value);
            // var thisDate = new Date(RegExp.$3,parseFloat(RegExp.$2)-1, RegExp.$1);
            minValue = this.element.getAttribute("min");
            maxValue = this.element.getAttribute("max");
            absMinValue = this.element.getAttribute("absoluteMin");
            absMaxValue = this.element.getAttribute("absoluteMax");

            if (absMinValue) {
                absMinValue = absMinValue.replace(/\//g, '-');
                var minDate = new Date(absMinValue);
                if (minDate && (thisDate.valueOf() < minDate.valueOf())) {
                    tooSmall = true;
                    minValue = absMinValue;
                }
            }
            if (absMaxValue) {
                absMaxValue = absMaxValue.replace(/\//g, '-');
                var maxDate = new Date(absMaxValue);

                if (maxDate && (thisDate.valueOf() > maxDate.valueOf())) {
                    tooBig = true;
                    maxValue = absMaxValue;
                }
            }
            if (!tooSmall && !tooBig) {
                if (minValue) {
                    minValue = minValue.replace(/\//g, '-');
                    var minDate = new Date(minValue);
                    if (minDate && (thisDate.valueOf() < minDate.valueOf())) {
                        tooSmall = true;
                        this.shouldConfirm = true;
                    }
                }
                if (maxValue) {
                    maxValue = maxValue.replace(/\//g, '-');
                    var maxDate = new Date(maxValue);

                    if (maxDate && (thisDate.valueOf() > maxDate.valueOf())) {
                        tooBig = true;
                        this.shouldConfirm = true;
                    }
                }
            }

        } else if (this.element.getAttribute("field_type") == "number") {
            // this.value = this.getNumberFromString(this.value);
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
        var suggestURL = this.formElement.getAttribute("ajaxURL") || this.element.getAttribute("ajaxURL") || "";
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
                selectOptions = document.getElementById("options").getElementsByTagName("LI");
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
		 * The flag() function dispatches message flags from a TTInput object. To
		 * use it, add a 'JSON' flag in the options list of a given TTInput object.
		 * Syntax: 1. a string: :flag => '{"message":"This is a TTInput flag
		 * message", "condition":"expression"}' 2. Using Rails JSON Object :flag =>
		 * ({:message=>'This is a TTInput flag message', :condition =>
		 * 'expression'}).to_json
		 */
    flag: function(){
        var flag    = this.element.getAttribute("flag");
        if (flag){
            flag    = JSON.parse(flag);
            value   = (this.element.value || this.formElement.value);

            // return if the message, the condition and the value is missing
            if(!(flag['message'] && flag['condition'] && value)) return false;

            if (value.match(flag['condition'])){
                dispatchMessage(flag['message'], tstMessageBoxType.OKOnly);
                return true;
            }
        }
        return false;
    }

}



//Rails Date: object for parsing and manipulating Rails Dates
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
            dayElement = __$(elementId);

        } else if (!dayElement && this.element.id.search(/_month$/)) {
            var elementId = this.element.id.replace(/_month$/, "_day");
            dayElement = __$(elementId);
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

                }
                else if (this.isDayOfMonthElement() &&
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
            monthElement = __$(elementId);
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
                }
                else if (str[1].search(/date$/) != -1 ) {
                    elementName = str[1].replace(/date$/, "year")+'['+str[2]+'(1i)]';
                }
                yearElement = document.getElementsByName(elementName)[0];
            }

            if (!yearElement) {
                yearElement = document.getElementsByName(str[1]+'['+str[2]+'(1i)]')[0];
            }

        }
        else {
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
            yearElement = __$(elementId);
        }

        return yearElement;
    },

    update: function(aValue) {
        if (this.isDayOfMonthElement()) {
            if (aValue.toLowerCase() == "unknown") {
                // this.element.value = "Unknown"
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

        var dateArray = aValue.split('-');
        if (dayElement && !isNaN(dateArray[0])) {
            dayElement.value = stripLeadingZeroes(dateArray[0]);
        }

        if (monthElement && !isNaN(dateArray[1]))
            monthElement.value = stripLeadingZeroes(dateArray[1]);

        if (yearElement && !isNaN(dateArray[2]))
            yearElement.value = dateArray[2];

    }


};

//Add trim() method to String Class
String.prototype.trim = function()
{
    return this.replace(/^\s+|\s+__$/g, '');
};

function getPreferredKeyboard(){
    if (typeof(tstUserKeyboardPref) != 'undefined' && tstUserKeyboardPref == 'qwerty') {
        return getQwertyKeyboard()
    }
    else{
        return getABCKeyboard()
    }
}

//window.addEventListener("load", loadTouchscreenToolkit, false);

/*
 * The dispatchMessage(message, messageBoxType) displays a 'message' with a
 * custom message box The message box can be any of the types defined by
 * tstMessageBoxType i.e. tstMessageBoxType.OKOnly, tstMessageBoxType.OKCancel,
 * tstMessageBoxType.YesNo, tstMessageBoxType.YesNoCancel
 *
 * By default, dispatchMessage(msg, messageBoxType) displays an OKCancel message
 * box if: a. the messageBoxType is not specified b. the messageBoxType
 * parameter does not match any of the message box types defined by
 * tstMessageBoxType
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
 * The dispatchFlag() function returns 'true' or 'false' depending on whether a
 * TTInput flag is raised on the current page.
 */
function dispatchFlag() {
    var thisPage = new TTInput(tstCurrentPage);

    return thisPage.flag();
}

function confirmRecordDeletion(message, form) {
    if (!tstMessageBar) {

        var tstMessageBar = document.createElement("div");
        tstMessageBar.id = "messageBar";
        tstMessageBar.className = "messageBar";

        tstMessageBar.innerHTML = message + "<br/>" + "<button onmousedown=\"document.getElementById('content').removeChild(document.getElementById('messageBar')); if(document.getElementById('" + form + "')) document.getElementById('"
        + form + "').submit();\"><span>Yes</span></button><button onmousedown=\"document.getElementById('content').removeChild(document.getElementById('messageBar'));\"><span>No</span></button>";

        tstMessageBar.style.display = "block";
        document.getElementById("content").appendChild(tstMessageBar);
    }

    return false;

}

String.prototype.toProperCase = function()
{
    return this.toLowerCase().replace(/^(.)|\s(.)/g,
        function($1) {
            return $1.toUpperCase();
        });
}

function hideKeyBoard(){
    __$("keyboard").style.display = "none";
    
    tstTimerHandle = setTimeout("hideKeyBoard()", 200);
}


function updateKeyColor(element){
    for(node in element.parentNode.childnodes){
        element.style.backgroundColor = ""
    }
    element.style.backgroundColor = "lightblue"
}

var DateSelector = function() {
    this.date = new Date();
    if (! arguments[0])
        arguments[0] = {};

    this.options = {
        year: arguments[0].year || this.date.getFullYear(),
        month: arguments[0].month || this.date.getMonth() + 1,
        date: arguments[0].date || this.date.getDate(),
        format: "yyyy-MM-dd",
        element: arguments[0].element || document.body,
        target: arguments[0].target,
        maxDate: arguments[0].max || this.date
    };

    if (!isNaN(Date.parse(new Date(this.options.year, (stripZero(this.options.month) -1), stripZero(this.options.date))))){
        
        this.date = new Date(this.options.year, (stripZero(this.options.month) -1), stripZero(this.options.date));

    } else if (typeof(tstCurrentDate) != "undefined" && tstCurrentDate) {

        var splitDate = tstCurrentDate.split("-");

        if (splitDate.length == 3) {
            this.date = new Date(splitDate[0], splitDate[1]-1, splitDate[2]);
        } else {
            var splitDate2 = tstCurrentDate.split("/");

            if (splitDate2.length == 3) {
                this.date = new Date(splitDate2[0], splitDate2[1]-1, splitDate2[2]);
            }
        }
    }	else {
        this.date = new Date();
    }

    this.element = this.options.element;
    this.format = this.options.format;

    this.formatDate = this.format.length>0 ? DateUtil.simpleFormat(this.format) : DateUtil.toLocaleDateString;

    this.target = this.options.target;

    var dateElement = document.createElement('div');
    this.element.appendChild(this.build());

    this.currentYear = $('dateselector_year');
    this.currentMonth = $('dateselector_month');
    this.currentDay = $('dateselector_day');

    this.currentYear.value = this.date.getFullYear();
    this.currentMonth.value = this.getMonth();
    this.currentDay.value = this.date.getDate();

};

DateSelector.prototype = {
    build: function() {
        var node = document.createElement('div');
        // TODO: move style stuff to a css file
        node.innerHTML = ' \
			<div id="dateselector" class="dateselector"> \
			<table><tr> \
			<td> \
			<div style="display: inline;" > \
				<button id="dateselector_nextYear" onmousedown="ds.incrementYear();"><span>+</span></button> \
				<input id="dateselector_year" type="text" > \
				<button id="dateselector_preYear" onmousedown="ds.decrementYear();"><span>-</span></button> \
			</div> \
			</td><td> \
			<div style="display: inline;"> \
				<button id="dateselector_nextMonth" onmousedown="ds.incrementMonth();"><span>+</span></button> \
				<input id="dateselector_month" type="text"> \
				<button id="dateselector_preMonth" onmousedown="ds.decrementMonth();"><span>-</span></button> \
			</div> \
			</td><td> \
			<div style="display: inline;"> \
				<button id="dateselector_nextDay" onmousedown="ds.incrementDay();"><span>+</span></button> \
				<input id="dateselector_day" type="text"> \
				<button id="dateselector_preDay" onmousedown="ds.decrementDay();"><span>-</span></button> \
			</div> \
			</td><td> \
                        <button id="today" ' + (tstCurrentDate ? (tstCurrentDate == tstInternalCurrentDate ? 
            'class="blue" ' : 'class="red" ') : 'class="blue" ') + 
        ' onmousedown="setToday()" style="width: 150px;"><span>Today</span></button> \
			<!--button id="num" onmousedown="updateKeyColor(this);press(this.id);" style="width: 150px;"><span>Num</span></button--> \
			<button id="Unknown" onmousedown="updateKeyColor(this);press(this.id);" style="width: 150px;"><span>Unknown</span></button> \
			</tr></table> \
			</div> \
		';

        return node;
    },

    getMonth: function() {
        return  DateUtil.months[this.date.getMonth()];
    },

    init: function() {
        this.update(this.target);
    },


    incrementYear: function() {
        // Only increment if year is less than this year
        if(this.currentYear.value < (this.options.maxDate.getFullYear())) this.currentYear.value++;

        this.date.setFullYear(this.currentYear.value);
        this.update(this.target);
    },

    decrementYear: function() {
        if (this.currentYear.value > 1)	{	// > minimum Year
            this.currentYear.value--;
            this.date.setFullYear(this.currentYear.value);
            this.update(this.target);
        }
    },

    incrementMonth: function() {
        var currentDate = new Date(this.date.getFullYear(), this.date.getMonth() + 1,
            this.date.getDate());

        if(this.options.maxDate > currentDate){

            if (this.date.getMonth() >= 11) {
                ds.incrementYear();
                this.date.setMonth(0)
                this.currentMonth.value = this.getMonth();
                this.date.setDate(1);
                this.currentDay.value = 1;
            } else {
                var lastDate = DateUtil.getLastDate(this.date.getFullYear(), this.date.getMonth()+1).getDate();
                if (lastDate < this.date.getDate()) {
                    this.currentDay.value = lastDate;
                    this.date.setDate(lastDate);
                }

                this.date.setMonth(this.date.getMonth()+1);
                this.currentMonth.value = this.getMonth();
            }
        }
        this.update(this.target);
    },

    decrementMonth: function() {
        var thisMonth = this.date.getMonth();
        if (thisMonth <= 0) {
            ds.decrementYear();
            this.date.setMonth(11)
            this.currentMonth.value = this.getMonth();

            var lastDate = DateUtil.getLastDate(this.date.getFullYear(), this.date.getMonth()).getDate();

            this.currentDay.value = lastDate;
            this.date.setDate(lastDate);

        } else {
            var lastDate = DateUtil.getLastDate(this.date.getFullYear(), this.date.getMonth()-1).getDate();
            if (lastDate < this.date.getDate()) {
                this.currentDay.value = lastDate;
                this.date.setDate(lastDate);
            }

            this.date.setMonth(thisMonth-1)
            this.currentMonth.value = this.getMonth();
        }
        this.update(this.target);
    },

    incrementDay: function() {
        var currentDate = new Date(this.date.getFullYear(), this.date.getMonth(),
            this.date.getDate() + 1);

        if(this.options.maxDate >= currentDate){
            if (currentDate.getMonth() == this.date.getMonth())
                this.date.setDate(this.date.getDate()+1);
            else {
                this.date.setDate(1);
                ds.incrementMonth();
            }

            this.currentDay.value = this.date.getDate();
        }

        this.date.setDate(this.currentDay.value);
        this.update(this.target);
    },

    decrementDay: function() {
        if (this.currentDay.value > 1)
            this.currentDay.value--;
        else {
            // this.currentDay.value = this.currentDay.value; //
            ds.decrementMonth();
            this.currentDay.value = DateUtil.getLastDate(this.date.getFullYear(), this.date.getMonth()).getDate();
        }

        this.date.setDate(this.currentDay.value);
        this.update(this.target);
    },

    update: function(aDateElement) {
        var aTargetElement = aDateElement || this.target;

        if (!aTargetElement)
            return;

        aTargetElement.value = this.formatDate(this.date);
    }

};

/**
 * DateUtil
 */
var DateUtil = {

    dayOfWeek: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],

    months: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],

    daysOfMonth: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],

    isLeapYear: function(year) {
        if (((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0))
            return true;
        return false;
    },

    nextDate: function(date) {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1);
    },

    previousDate: function(date) {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate() - 1);
    },

    getLastDate: function(year, month) {
        var last = this.daysOfMonth[month];
        if ((month == 1) && this.isLeapYear(year)) {
            return new Date(year, month, last + 1);
        }
        return new Date(year, month, last);
    },

    getFirstDate: function(year, month) {
        if (year.constructor == Date) {
            return new Date(year.getFullYear(), year.getMonth(), 1);
        }
        return new Date(year, month, 1);
    },

    getWeekTurn: function(date, firstDWeek) {
        var limit = 6 - firstDWeek + 1;
        var turn = 0;
        while (limit < date) {
            date -= 7;
            turn++;
        }
        return turn;
    },

    toDateString: function(date) {
        return date.toDateString();
    },

    toLocaleDateString: function(date) {
        return date.toLocaleDateString();
    },

    simpleFormat: function(formatStr) {
        return function(date) {
            var formated = formatStr.replace(/M+/g, DateUtil.zerofill((date.getMonth() + 1).toString(), 2));
            formated = formated.replace(/d+/g, DateUtil.zerofill(date.getDate().toString(), 2));
            formated = formated.replace(/y{4}/g, date.getFullYear());
            formated = formated.replace(/y{1,3}/g, new String(date.getFullYear()).substr(2));
            formated = formated.replace(/E+/g, DateUtil.dayOfWeek[date.getDay()]);

            return formated;
        }
    },

    zerofill: function(date,digit){
        var result = date;
        if(date.length < digit){
            var tmp = digit - date.length;
            for(i=0; i < tmp; i++){
                result = "0" + result;
            }
        }
        return result;
    }
}

function setToday(){
    var d = new Date();
    if (tstCurrentDate) {
        if(tstCurrentDate.match(/\d{4}\-\d{2}\-\d{2}/)){
            d = new Date(tstCurrentDate);
        }
    }
    
    var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    document.getElementById("touchscreenInput" + tstCurrentPage).value =
    d.getFullYear() + "-" + ((d.getMonth() + 1) < 10 ? "0" : "") + (d.getMonth() + 1) +
    "-" + ((d.getDate()) < 10 ? "0" : "") + (d.getDate());

    document.getElementById("dateselector_year").value = d.getFullYear();
    document.getElementById("dateselector_month").value = months[d.getMonth()];
    document.getElementById("dateselector_day").value = d.getDate();

    ds.date.setFullYear(d.getFullYear());
    ds.date.setMonth(d.getMonth());
    ds.date.setDate(d.getDate());
}

var TimeSelector = function() {
    this.time = [new Date().getHours(), new Date().getMinutes(), new Date().getSeconds()];

    if (! arguments[0])
        arguments[0] = {};

    this.options = {
        hour: arguments[0].hour || this.time[0],
        minute: arguments[0].minute || this.time[1],
        second: arguments[0].second || this.time[2],
        format: "H:M:S",
        element: arguments[0].element || document.body,
        target: arguments[0].target,
        maxNow: arguments[0].maxNow
    };

    if (typeof(tstCurrentTime) != "undefined" && tstCurrentTime) {
        var splitTime = tstCurrentTime.split(":");
        if (splitTime.length == 3) {
            this.time = [splitTime[0], splitTime[1], splitTime[2]];
        }
    }	else {
        this.time = [this.options.hour, this.options.minute, this.options.second];
    }
    this.element = this.options.element;
    this.format = this.options.format;
    this.target = this.options.target;

    this.element.appendChild(this.build());

    this.currentHour = $('timeselector_hour');
    this.currentMinute = $('timeselector_minute');
    //this.currentSecond = $('timeselector_second');

    this.currentHour.value = this.time[0];
    this.currentMinute.value = this.time[1];
//this.currentSecond.value = this.time[2];
};

TimeSelector.prototype = {
    build: function() {
        var node = document.createElement('div');
        // TODO: move style stuff to a css file
        node.innerHTML = ' \
			<div id="timeselector" class="dateselector"> \
			<table><tr> \
			<td valign="top"> \
			<div style="display: inline;" > \
                                <div style="text-align:center; width:100%; font-size:1.8em;">Hr</div>\
				<button id="timeselector_nextHour" onmousedown="ds.incrementHour();" ' + 
        (this.options["maxNow"] == true ? 'class="blue" ' : 'class="red" ') + 
        ' ><span>+</span></button> \
				<input id="timeselector_hour" type="text" > \
				<button id="timeselector_preHour" onmousedown="ds.decrementHour();"><span>-</span></button> \
			</div> \
			</td><td> \
			<div style="display: inline;"> \
                                <div style="text-align:center; width:100%; font-size:1.8em;">Min</div>\
				<button id="timeselector_nextMinute" onmousedown="ds.incrementMinute();"' + 
        (this.options["maxNow"] == true ? 'class="blue" ' : 'class="red" ') + 
        ' ><span>+</span></button> \
				<input id="timeselector_minute" type="text"> \
				<button id="timeselector_preMinute" onmousedown="ds.decrementMinute();"><span>-</span></button> \
			</div> \
			</td><td> \
			<!--div style="display: inline;"> \
                                <div style="text-align:center; width:100%; font-size:1.8em;">Sec</div>\
				<button id="timeselector_nextSecond" onmousedown="ds.incrementSecond();"><span>+</span></button> \
				<input id="timeselector_second" type="text"> \
				<button id="timeselector_preSecond" onmousedown="ds.decrementSecond();"><span>-</span></button> \
			</div--> \
			</td><td> \
			<!--button id="Unknown" onmousedown="updateKeyColor(this);press(this.id);" style=""><span>Unknown</span></button--> \
			</tr></table> \
			</div> \
		';

        return node;
    },

    init: function() {
        this.update(this.target);
    },


    incrementHour: function() {
        if(this.options["maxNow"] == true){       
            if(this.currentHour.value >= (new Date().getHours())){

            } else if(this.currentHour.value == 23){
                this.currentHour.value = 0;
            } else {
                this.currentHour.value++;
            }
        } else if(this.currentHour.value == 23){
            this.currentHour.value = 0;
        } else {
            this.currentHour.value++;
        }
        
        this.time[0] = this.currentHour.value;
        this.update(this.target);
    },

    decrementHour: function() {
        if(this.currentHour.value == 0){
            this.currentHour.value = 0;
        } else {
            this.currentHour.value--;
        }

        this.time[0] = this.currentHour.value;
        this.update(this.target);
    },

    incrementMinute: function() {
        if(this.options["maxNow"] == true){        
            if(this.currentMinute.value == 59){
                this.currentMinute.value = 0;
                this.incrementHour();
            } else if(this.currentMinute.value >= (new Date().getMinutes())){
                this.currentMinute.value = 0;
            } else  {
                this.currentMinute.value++;
            }
        } else  {
            if(this.currentMinute.value == 59){
                this.currentMinute.value = 0;
                this.incrementHour();
            } else {
                this.currentMinute.value++;
            }
        }

        this.time[1] = this.currentMinute.value;
        this.update(this.target);
    },

    decrementMinute: function() {
        if(this.currentMinute.value == 0){
            this.currentMinute.value = 0;
        } else {
            this.currentMinute.value--;
        }

        this.time[1] = this.currentMinute.value;
        this.update(this.target);
    },

    incrementSecond: function() {
        if(this.options["maxNow"] == true){        
            if(this.currentSecond.value == 59){
                this.currentSecond.value = 0;
            } else {
                this.currentSecond.value++;
            }
        } else {
            this.currentSecond.value++;
        }

        this.time[2] = this.currentSecond.value;
        this.update(this.target);
    },

    decrementSecond: function() {
        if(this.currentSecond.value == 0){
            this.currentSecond.value = 0;
        } else {
            this.currentSecond.value--;
        }

        this.time[2] = this.currentSecond.value;
        this.update(this.target);
    },

    update: function(aDateElement) {
        var aTargetElement = aDateElement || this.target;

        if (!aTargetElement)
            return;

        aTargetElement.value = TimeUtil.zerofill((this.time[0]).toString(),2) + ":" +
        TimeUtil.zerofill((this.time[1]).toString(),2) + ":" +
        TimeUtil.zerofill((this.time[2]).toString(),2);
    }

};

/**
 * TimeUtil
 */
var TimeUtil = {
    zerofill: function(time,digit){
        var result = time;
        if(time.length < digit){
            var tmp = digit - time.length;
            for(i=0; i < tmp; i++){
                result = "0" + result;
            }
        }
        return result;
    }
}

function stripZero(value){
    try {
        if(value.match(/^0/)){
            return eval(value.substr(1));
        }
    }catch(e) {}
    return value;
}

function showKeyboard(full_keyboard, qwerty){   
    var div = document.createElement("div");
    div.id = "divMenu";
    // div.className = "keyboard";
    
    var row1 = (qwerty ? ["q","w","e","r","t","y","u","i","o","p"] : ["a","b","c","d","e","f","g","h","i","j"]);
    var row2 = (qwerty ? ["a","s","d","f","g","h","j","k","l",":"] : ["k","l","m","n","o","p","q","r","s",":"]);
    var row3 = (qwerty ? ["z","x","c","v","b","n","m",",",".","?"] : ["t","u","v","w","x","y","z",",",".","?"]);
    var row4 = ["CAP","space","delete"];
    var row5 = ["1","2","3","4","5","6","7","8","9","0"];
    var row6 = ["_","-","@","(",")","+",";","=","\\","/"];

    global_control = "touchscreenInput" + tstCurrentPage;

    var tbl = document.createElement("table");
    tbl.className = "keyBoardTable";
    tbl.cellSpacing = 0;
    tbl.cellPadding = 3;
    tbl.id = "tblKeyboard";
    tbl.style.width = "100%";

    var tr5 = document.createElement("tr");

    for(var i = 0; i < row5.length; i++){
        var td5 = document.createElement("td");
        td5.align = "center";
        td5.vAlign = "middle";
        td5.style.cursor = "pointer";
        td5.bgColor = "#ffffff";
        td5.width = "30px";

        tr5.appendChild(td5);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row5[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td5.appendChild(btn);

    }

    if(full_keyboard){
        tbl.appendChild(tr5);
    }

    var tr1 = document.createElement("tr");

    for(var i = 0; i < row1.length; i++){
        var td1 = document.createElement("td");
        td1.align = "center";
        td1.vAlign = "middle";
        td1.style.cursor = "pointer";
        td1.bgColor = "#ffffff";
        td1.width = "30px";

        tr1.appendChild(td1);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row1[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td1.appendChild(btn);

    }

    tbl.appendChild(tr1);

    var tr2 = document.createElement("tr");

    for(var i = 0; i < row2.length; i++){
        var td2 = document.createElement("td");
        td2.align = "center";
        td2.vAlign = "middle";
        td2.style.cursor = "pointer";
        td2.bgColor = "#ffffff";
        td2.width = "30px";

        tr2.appendChild(td2);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row2[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td2.appendChild(btn);

    }

    tbl.appendChild(tr2);

    var tr3 = document.createElement("tr");

    for(var i = 0; i < row3.length; i++){
        var td3 = document.createElement("td");
        td3.align = "center";
        td3.vAlign = "middle";
        td3.style.cursor = "pointer";
        td3.bgColor = "#ffffff";
        td3.width = "30px";

        tr3.appendChild(td3);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row3[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td3.appendChild(btn);

    }

    tbl.appendChild(tr3);

    var tr6 = document.createElement("tr");

    for(var i = 0; i < row6.length; i++){
        var td6 = document.createElement("td");
        td6.align = "center";
        td6.vAlign = "middle";
        td6.style.cursor = "pointer";
        td6.bgColor = "#ffffff";
        td6.width = "30px";

        tr6.appendChild(td6);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row6[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td6.appendChild(btn);

    }

    if(full_keyboard){
        tbl.appendChild(tr6);
    }

    var tr4 = document.createElement("tr");

    for(var i = 0; i < row4.length; i++){
        var td4 = document.createElement("td");
        td4.align = "center";
        td4.vAlign = "middle";
        td4.style.cursor = "pointer";
        td4.bgColor = "#ffffff";

        switch(row4[i]){
            case "cap":
                td4.colSpan = 2;
                break;
            case "space":
                td4.colSpan = 6;
                break;
            case "delete":
                td4.colSpan = 2;
                break;
            default:
                td4.colSpan = 2;
        }

        tr4.appendChild(td4);

        var btn = document.createElement("button");
        btn.innerHTML = (row4[i].trim().length > 0 ? "<span>" + row4[i] + "</span>" : "");
        
        if(row4[i] == "space"){
            btn.style.width = "80%";
        }
        
        btn.onclick = function(){
            if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "cap"){
                if(this.innerHTML.match(/<span>(.+)<\/span>/)[1] == "cap"){
                    this.innerHTML = "<span>" + this.innerHTML.match(/<span>(.+)<\/span>/)[1].toUpperCase() + "</span>";

                    var cells = $("tblKeyboard").getElementsByTagName("button");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "cap"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "clear"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "space"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "full"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "basic" ){

                            cells[c].innerHTML = "<span>" + cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() + "</span>";

                        }
                    }

                } else {
                    this.innerHTML = "<span>" + this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() + "</span>";

                    var cells = $("tblKeyboard").getElementsByTagName("button");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "cap"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "delete"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "space"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "full"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "basic" ){

                            cells[c].innerHTML = "<span>" + cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toUpperCase() + "</span>";

                        }
                    }

                }
            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1] == "enter"){
                if(!this.innerHTML.match(/^$/)){
                    $(global_control).value += "\n";
                }
            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "space"){

                $(global_control).value += " ";

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "delete"){

                $(global_control).value = $(global_control).value.substring(0,$(global_control).value.length - 1);

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "full"){

                full_keyboard = true;

                showKeyboard(global_control, qwerty);

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "basic"){

                full_keyboard = false;

                showKeyboard(global_control, qwerty);

            } else if(!this.innerHTML.match(/<span>(.+)<\/span>/)[1].match(/^$/)){

                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];

            }
        }

        if(row4[i].trim().length > 0) {
            td4.appendChild(btn);
        } else {
            td4.innerHTML = "&nbsp;";
        }
        
    }

    tbl.appendChild(tr4);

    div.appendChild(tbl);
    
    __$("keyboard").innerHTML = "";
    
    __$("keyboard").appendChild(div);
    
}

function padZeros(number, positions){
    var zeros = parseInt(positions) - String(number).length;
    var padded = "";
    
    for(var i = 0; i < zeros; i++){
        padded += "0";
    }
    
    padded += String(number);
    
    return padded;
}

function ajaxGeneralRequest(aUrl, method) {
    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function() {
        handleGeneralResult(httpRequest, method);
    };
    try {        
        showProgress();
        
        httpRequest.open('GET', aUrl, true);
        httpRequest.send(null);
    } catch(e){
    }
}

function handleGeneralResult(aXMLHttpRequest, method) {    
    if (!aXMLHttpRequest) return "error";

    if (aXMLHttpRequest.readyState == 4 && (aXMLHttpRequest.status == 200 || aXMLHttpRequest.status == 304)) {
        var result = aXMLHttpRequest.responseText;
        
        ajaxGeneralRequestResult = result;
        
        __$("progress_bar").style.display = "none";        
        
        eval(method);
        
        return ajaxGeneralRequestResult;
    }  
    return "";
}

function showProgress(){
    if(!__$("progress_bar")){
        var div = document.createElement("div");
        div.id = "progress_bar";
        div.className = "messageBar";
        div.innerHTML = "Fetching data. Please wait...";
        //div.style.top = "200px";
        //div.style.left = "280px";
        
        __$("page" + tstCurrentPage).appendChild(div);
    }
    
    __$("progress_bar").style.display = "block";
}

function hideProgress(){
    __$("progress_bar").style.display = "none";
}

function showStatus(){
    if(!__$("popupBox")){
        var  popupBox = document.createElement("div");
        popupBox.id = "popupBox";
        popupBox.style.display = "none";
       
        popupBox.innerHTML = "<p>Processing. Please Wait ...</p>"
       
        __$("content").appendChild(popupBox);
    }
    
    __$("popupBox").style.display = "block";
}

function checkCtrl(obj){
    var o = obj;
    var t = o.offsetTop;
    var l = o.offsetLeft + 1;
    var w = o.offsetWidth;
    var h = o.offsetHeight;

    while((o ? (o.offsetParent != document.body) : false)){
        o = o.offsetParent;
        t += (o ? o.offsetTop : 0);
        l += (o ? o.offsetLeft : 0);
    }
    return [w, h, t, l];
}
     
function showCategory(category){
    var pos = checkCtrl(__$("content"));
    
    if(__$("category")){
        document.body.removeChild(__$("category"));
    }
    
    var cat = document.createElement("div");
    cat.id = "category";
    cat.style.position = "absolute";
    cat.style.left = (pos[3] + (pos[0] - 378)) + "px";
    cat.style.top = (pos[2] + 5) + "px";
    cat.style.width = "350px";
    cat.style.height = "45px";
    cat.style.fontSize = "36px";
    cat.style.padding = "10px";
    cat.style.backgroundColor = "#9e9";
    cat.style.color = "#000";
    cat.style.opacity = "0.95";
    cat.style.zIndex = 100;
    cat.style.textAlign = "center";
    cat.innerHTML = category;
    
    document.body.appendChild(cat);
}  

function getAdvancedTimePicker() {
    if (typeof(AdvancedTimeSelector) == "undefined")
        return;

    var inputElement = tstFormElements[tstPages[tstCurrentPage]];
    var keyboardDiv = __$('keyboard');
    keyboardDiv.innerHTML = "";

    var railsDate = new RailsDate(inputElement);
    if (railsDate.isDayOfMonthElement()) {
        getDayOfMonthPicker(railsDate.getYearElement().value, railsDate.getMonthElement().value);
        return;
    }

    var defaultDate = joinDateValues(inputElement);
    //defaultDate = defaultDate.replace("-", "/", "g");
    var arrDate = defaultDate.split(':');
    __$("touchscreenInput"+tstCurrentPage).value = defaultDate;

    if (arrDate.length == 3) {
        ds = new AdvancedTimeSelector({
            element: keyboardDiv,
            target: tstInputTarget,
            hour: arrDate[0],
            minute: arrDate[1],
            second: arrDate[2],
            format: "H:M:S",
            maxNow: (tstInputTarget.getAttribute("maxNow") ? true : false)
        });
    } else {
        ds = new AdvancedTimeSelector({
            element: keyboardDiv,
            target: tstInputTarget,
            format: "H:M:S",
            maxNow: (tstInputTarget.getAttribute("maxNow") ? true : false)
        });
    }

// __$("options" + tstCurrentPage).innerHTML = "";
}

var AdvancedTimeSelector = function() {
    this.time = [new Date().getHours(), new Date().getMinutes(), new Date().getSeconds()];

    if (! arguments[0])
        arguments[0] = {};

    this.options = {
        hour: arguments[0].hour || this.time[0],
        minute: arguments[0].minute || this.time[1],
        second: arguments[0].second || this.time[2],
        format: "H:M:S",
        element: arguments[0].element || document.body,
        target: arguments[0].target,
        maxNow: arguments[0].maxNow
    };

    if (typeof(tstCurrentTime) != "undefined" && tstCurrentTime) {
        var splitTime = tstCurrentTime.split(":");
        if (splitTime.length == 3) {
            this.time = [splitTime[0], splitTime[1], splitTime[2]];
        }
    }	else {
        this.time = [this.options.hour, this.options.minute, this.options.second];
    }
    this.element = this.options.element;
    this.format = this.options.format;
    this.target = this.options.target;

    this.element.appendChild(this.build());

    this.currentHour = $('timeselector_hour');
    this.currentMinute = $('timeselector_minute');
    //this.currentSecond = $('timeselector_second');

    this.currentHour.value = this.time[0];
    this.currentMinute.value = this.time[1];
//this.currentSecond.value = this.time[2];
};

AdvancedTimeSelector.prototype = {
    build: function() {
        var hr = (new Date()).getHours();
        var node = document.createElement('div');
        // TODO: move style stuff to a css file
        node.innerHTML = ' \
			<div id="timeselector" class="dateselector" style="min-height: 477px;"> \
                            <div class="table" style="width: 100%;"><div class="row"><div class="cell" \
                                        style="text-align: center; font-size: 36px;">\
                                        Hour</div><div class="cell">&nbsp;</div><div class="cell" \
                                        style="text-align: center; font-size: 36px;">Minute</div></div>\
                                        <div class="row"><div class="cell" \
                                        style="text-align: center;"><object type="image/svg+xml" \
                                        data="/touchscreentoolkit/examples/lib/images/hour.svg" wmode="transparent" \
                                        style="padding:5px; overflow:hidden;" \
                                        id="hour" >\
                                    <param id="et1" name="t1" value="" />\
                                    <param id="et2" name="t2" value="" />\
                                    <param id="et3" name="t3" value="" />\
                                    <param id="et4" name="t4" value="" />\
                                    <param id="et5" name="t5" value="" />\
                                    <param id="et6" name="t6" value="" />\
                                    <param id="et7" name="t7" value="" />\
                                    <param id="et8" name="t8" value="" />\
                                    <param id="et9" name="t9" value="" />\
                                    <param id="et10" name="t10" value="" />\
                                    <param id="et11" name="t11" value="" />\
                                    <param id="et12" name="t12" value="" /></object></div><div class="cell"></div>\
                              <div class="cell" style="text-align: center;"><object type="image/svg+xml" \
                                data="/touchscreentoolkit/examples/lib/images/minute.svg" \
                                   wmode="transparent" \
                                style="padding:5px; overflow:hidden;" id="minute" >\
                                    <param id="etm5" name="tm5" value="" />\
                                    <param id="etm10" name="tm10" value="" />\
                                    <param id="etm15" name="tm15" value="" />\
                                    <param id="etm20" name="tm20" value="" />\
                                    <param id="etm25" name="tm25" value="" />\
                                    <param id="etm30" name="tm30" value="" />\
                                    <param id="etm35" name="tm35" value="" />\
                                    <param id="etm40" name="tm40" value="" />\
                                    <param id="etm45" name="tm45" value="" />\
                                    <param id="etm50" name="tm50" value="" />\
                                    <param id="etm55" name="tm55" value="" />\
                                    <param id="etm0" name="tm0" value="" /></object> \
                                </div></div><div class="row"><div class="cell"><div class="table" \
                                style="margin-left: 20px;"><div class="row"><div class="cell">\
                                <button id="timeselector_preHour" style="width: 100px;" onmousedown="ds.decrementHour();">\
                                <span>-</span></button></div><div class="cell" style="vertical-align: middle; text-align: center;">\
                                <input id="timeselector_hour" type="text" style="margin-left: 10px;" />\
                                </div><div class="cell"><button id="timeselector_nextHour" onmousedown="ds.incrementHour();" ' + 
        (this.options["maxNow"] == true ? 'class="blue" ' : 'class="red" ') + 
        ' style="width: 100px;" ><span>+</span></button></div></div></div> </div>\
                                <div class="cell"><button id="ampm" style="width: 150px;" \
                                onmousedown="ds.changeScope();"><span>' + (hr >= 12 ? 'PM' : 'AM') + 
        '</span></button></div><div class="cell"> \
                                <div class="table" \
                                style="margin-right: 25px; float: right;"><div class="row"><div class="cell"> \
                                <button id="timeselector_preMinute" onmousedown="ds.decrementMinute();" style="width: 100px;"> \
                                <span>-</span></button>\
                                </div><div class="cell" style="vertical-align: middle; text-align: center;">\
                                <input id="timeselector_minute" type="text" style="margin-left: 10px;"/>\
                                </div><div class="cell"><button id="timeselector_nextMinute" style="width: 100px;"\
                                 onmousedown="ds.incrementMinute();"' + 
        (this.options["maxNow"] == true ? 'class="blue" ' : 'class="red" ') + 
        ' ><span>+</span></button></div></div></div>\
                                </div></div></div></div></div>	';

        return node;
    },

    init: function() {
        this.update(this.target);
    },

    changeScope: function(){
        if(this.currentHour.value > 12){
            this.currentHour.value = parseInt(this.currentHour.value) - 12;
            __$("ampm").innerHTML = "<span>AM</span>";
        } else if(this.currentHour.value <= 12){
            this.currentHour.value = parseInt(this.currentHour.value) + 12;
            __$("ampm").innerHTML = "<span>PM</span>";
        }
        this.time[0] = this.currentHour.value;
        this.update(this.target);
    },

    incrementHour: function() {
        if(this.options["maxNow"] == true){       
            if(this.currentHour.value >= (new Date().getHours())){

            } else if(this.currentHour.value == 23){
                this.currentHour.value = 0;
            } else {
                this.currentHour.value++;
            }
        } else if(this.currentHour.value == 23){
            this.currentHour.value = 0;
        } else {
            this.currentHour.value++;
        }
        
        this.time[0] = this.currentHour.value;
        this.update(this.target);
    },

    decrementHour: function() {
        if(this.currentHour.value == 0){
            this.currentHour.value = 0;
        } else {
            this.currentHour.value--;
        }

        this.time[0] = this.currentHour.value;
        this.update(this.target);
    },

    incrementMinute: function() {
        if(this.options["maxNow"] == true){        
            if(this.currentMinute.value == 59){
                this.currentMinute.value = 0;
                this.incrementHour();
            } else if(this.currentMinute.value >= (new Date().getMinutes())){
                this.currentMinute.value = 0;
            } else  {
                this.currentMinute.value++;
            }
        } else  {
            if(this.currentMinute.value == 59){
                this.currentMinute.value = 0;
                this.incrementHour();
            } else {
                this.currentMinute.value++;
            }
        }

        this.time[1] = this.currentMinute.value;
        this.update(this.target);
    },

    decrementMinute: function() {
        if(this.currentMinute.value == 0){
            this.currentMinute.value = 0;
        } else {
            this.currentMinute.value--;
        }

        this.time[1] = this.currentMinute.value;
        this.update(this.target);
    },

    incrementSecond: function() {
        if(this.options["maxNow"] == true){        
            if(this.currentSecond.value == 59){
                this.currentSecond.value = 0;
            } else {
                this.currentSecond.value++;
            }
        } else {
            this.currentSecond.value++;
        }

        this.time[2] = this.currentSecond.value;
        this.update(this.target);
    },

    decrementSecond: function() {
        if(this.currentSecond.value == 0){
            this.currentSecond.value = 0;
        } else {
            this.currentSecond.value--;
        }

        this.time[2] = this.currentSecond.value;
        this.update(this.target);
    },

    invokeHourUpdate: function(pos){
        var hr = pos;
            
        if(hr != null){
            if(__$("ampm").innerHTML.toLowerCase() == "<span>pm</span>"){
                if(hr == 12){
                    this.currentHour.value = hr;
                } else {
                    this.currentHour.value = (hr == 12 ? 0 : (hr + 12));
                }
            } else {
                if(hr == 12){
                    this.currentHour.value = 0;
                } else {
                    this.currentHour.value = hr;
                }
            }
        }
        
        this.time[0] = this.currentHour.value;
        this.update(this.target);
    },
    
    updateHourDisk: function(){
        var params = __$("hour").getElementsByTagName("param");
        var hr = (parseInt(this.currentHour.value) == 0 ? 12 : (parseInt(this.currentHour.value) > 12 ? 
            (parseInt(this.currentHour.value) - 12) : this.currentHour.value));
       
        for(var i = 0; i < params.length; i++){
            if(params[i]){
                if(params[i].id == "et" + hr){
                    params[i].value = "selected";
                } else {
                    params[i].value = "";
                }
            }
        } 
       
        if(parseInt(this.currentHour.value) >= 12){
            __$("ampm").innerHTML = "<span>PM</span>";
        } else {
            __$("ampm").innerHTML = "<span>AM</span>";
        }
    },

    invokeMinuteUpdate: function(pos){
        var min = pos;
            
        if(min != null){
            this.currentMinute.value = min;
        }
        
        this.time[1] = this.currentMinute.value;
        this.update(this.target);
    },
    
    updateMinuteDisk: function(){
        var params = __$("minute").getElementsByTagName("param");
        var time = parseInt(this.currentMinute.value);
       
        var range = "";

        if(time >= 1 && time <= 5){
            range = 5;
        } else if(time >= 6 && time <= 10){
            range = 10;
        } else if(time >= 11 && time <= 15){
            range = 15;
        } else if(time >= 16 && time <= 20){
            range = 20;
        } else if(time >= 21 && time <= 25){
            range = 25;
        } else if(time >= 26 && time <= 30){
            range = 30;
        } else if(time >= 31 && time <= 35){
            range = 35;
        } else if(time >= 36 && time <= 40){
            range = 40;
        } else if(time >= 41 && time <= 45){
            range = 45;
        } else if(time >= 46 && time <= 50){
            range = 50;
        } else if(time >= 51 && time <= 55){
            range = 55;
        } else if(time >= 56 && time <= 59){
            range = 0;
        } 
       
        for(var i = 0; i < params.length; i++){
            if(params[i]){
                if(params[i].id == "etm" + range){
                    params[i].value = "selected";
                } else {
                    params[i].value = "";
                }
            }
        }        
    },
    
    update: function(aDateElement) {
        var aTargetElement = aDateElement || this.target;

        if (!aTargetElement)
            return;

        aTargetElement.value = TimeUtil.zerofill((this.time[0]).toString(),2) + ":" +
        TimeUtil.zerofill((this.time[1]).toString(),2) + ":" +
        TimeUtil.zerofill((this.time[2]).toString(),2);
    
        this.updateHourDisk();
        this.updateMinuteDisk();
    }

};

function addSelectAllButton(){
    var holder = document.createElement("div");
    holder.id = "holder";
    holder.style.margin = "5px";
    holder.style.display = "table";
    holder.style.cursor = "pointer";

    __$("keyboard").appendChild(holder);
    
    var row = document.createElement("div");
    row.style.display = "table-row";
    
    holder.appendChild(row);  
    
    var cell1 = document.createElement("div");
    cell1.style.display = "table-cell";
    cell1.style.verticalAlign = "middle";
    
    row.appendChild(cell1);  
    
    var cell2 = document.createElement("div");
    cell2.style.display = "table-cell";
    cell2.id = "lblSelectAll";
    cell2.innerHTML = "Select All";
    cell2.style.verticalAlign = "middle";
    cell2.style.fontSize = "36px";
    cell2.style.paddingLeft = "10px";
    cell2.onclick = function(){
        __$("chkSelectAll").click();
    }
    
    row.appendChild(cell2);  
    
    var checkbox = document.createElement("img");
    checkbox.src = "/touchscreentoolkit/lib/images/unticked.jpg";
    checkbox.id = "chkSelectAll";
    checkbox.setAttribute("checked", "false")
    
    checkbox.onclick = function(){
        if(this.getAttribute("checked") == "false"){
            toggleState("uncheck");
            this.setAttribute("checked", "true");
            this.src = "/touchscreentoolkit/lib/images/ticked.jpg";
            __$("lblSelectAll").innerHTML = "Deselect All";
        } else {
            toggleState("check");
            this.setAttribute("checked", "false");
            this.src = "/touchscreentoolkit/lib/images/unticked.jpg";
            __$("lblSelectAll").innerHTML = "Select All";
        }
    }
    
    cell1.appendChild(checkbox);  
    
}
     
function toggleState(state){
    switch(state.toLowerCase()){
        case "check":
            checkAll();
            break;
        case "uncheck":
            unCheckAll()
            break;
    }
}
    
function checkAll(){
    var elements = __$("tt_currentUnorderedListOptions").getElementsByTagName("li");
    
    for(var i = 0; i < elements.length; i++){
        if(__$("img" + elements[i].id).src.match(/\/touchscreentoolkit\/lib\/images\/ticked.jpg/)){
            elements[i].click();
        }
    }
}
    
function unCheckAll(){
    var elements = __$("tt_currentUnorderedListOptions").getElementsByTagName("li");
    
    for(var i = 0; i < elements.length; i++){
        if(__$("img" + elements[i].id).src.match(/\/touchscreentoolkit\/lib\/images\/unticked.jpg/)){
            elements[i].click();
        }
    }
}
   