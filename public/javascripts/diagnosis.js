function updateFromKeyboard(aText){
  if (aText == null){
    $('diagnosis-inputbox').value = $('diagnosis-inputbox').value.slice(0, -1);
  }else{
    $('diagnosis-inputbox').value = $('diagnosis-inputbox').value + aText;
  }
}

function createKeyboardRow(aDivPosition, aRowValues){

  for (var i = 0; i < aRowValues.length; i++){
    var simpleButtonSpan = document.createElement('span');
    simpleButtonSpan.innerHTML = aRowValues[i];
    
    var simpleButton = document.createElement('button');
    simpleButton.className = 'simple-button'; 
    simpleButton.setAttribute("onClick", "updateFromKeyboard('" + aRowValues[i]+ "');updateSelectionList('diagnosis-select','diagnosis-inputbox');");
    
    $(aDivPosition).appendChild(simpleButton);
    
    simpleButton.appendChild(simpleButtonSpan);
  }
}

function createSimpleKeyboard(){
  var simpleKeyBoard = document.createElement('div');
  simpleKeyBoard.className = 'simple-keyboard'
  simpleKeyBoard.id = "simple-keyboard";
  simpleKeyBoard.zIndex = 1001;
  $('diagnosis-container').appendChild(simpleKeyBoard);
  
  var keyboardRowTop = ["Q","W","E","R","T","Y","U","I","O","P"];
  var keyboardRowMiddle = ["A","S","D","F","G","H","J","K","L"];
  var keyboardRowBottom = ["Z","X","C","V","B","N","M"];

  var keyboardDivTop = document.createElement('div');
  keyboardDivTop.id = 'keyboard-div-top';
  simpleKeyBoard.appendChild(keyboardDivTop);
  createKeyboardRow('keyboard-div-top', keyboardRowTop);

  var keyboardDivMiddle = document.createElement('div');
  keyboardDivMiddle.id = 'keyboard-div-middle';
  simpleKeyBoard.appendChild(keyboardDivMiddle);
  createKeyboardRow('keyboard-div-middle', keyboardRowMiddle);
  
  var keyboardDivBottom = document.createElement('div');
  keyboardDivBottom.id = 'keyboard-div-bottom';
  simpleKeyBoard.appendChild(keyboardDivBottom);
  createKeyboardRow('keyboard-div-bottom', keyboardRowBottom);

  /*Create Back space*/
  var backSpace = document.createElement('span');
  backSpace.innerHTML = 'DELETE';
  
  var backSpaceButton = document.createElement('button');
  backSpaceButton.className = 'simple-button'; 
  backSpaceButton.setAttribute("onClick", "updateFromKeyboard(null);updateSelectionList('diagnosis-select','diagnosis-inputbox');");
  
  keyboardDivBottom.appendChild(backSpaceButton);
  
  backSpaceButton.appendChild(backSpace);
}

function createElements(){
  
 var  mainContainer = document.createElement('div');
 /*Create the main container div*/
 mainContainer.id = "diagnosis-container";
 mainContainer.className = "main-container";
 //document.body.appendChild(mainContainer);
 $('content').appendChild(mainContainer);

  createSimpleKeyboard();
 /*+++++++++++++++++++++++++Create the main diagnosis column*/ 
 var mainDiagnosis = document.createElement('div');
 mainDiagnosis.className = "diagnosis-columns";
 mainDiagnosis.id = "main-diagnosis";
  
 mainContainer.appendChild(mainDiagnosis);
/*Add header*/
 var mainDiagnosisHeader = document.createElement('div');
 mainDiagnosisHeader.className = "diagnosis-headers";
 mainDiagnosisHeader.innerHTML = "MAIN DIAGNOSIS";
 mainDiagnosis.appendChild(mainDiagnosisHeader);
 /*Input box div*/
 var mainDiagnosisInputBoxDiv = document.createElement('div');
 mainDiagnosisInputBoxDiv.className = "diagnosis-inputbox-div";
 mainDiagnosis.appendChild(mainDiagnosisInputBoxDiv);

 /*Added Text Input*/
 var mainDiagnosisInputBox = document.createElement('input');
 mainDiagnosisInputBox.className = "diagnosis-inputbox";
 mainDiagnosisInputBox.id = "diagnosis-inputbox";
 mainDiagnosisInputBox.setAttribute("onKeyUp", "updateSelectionList('diagnosis-select','diagnosis-inputbox');");
 mainDiagnosisInputBoxDiv.appendChild(mainDiagnosisInputBox);

  /*Select div*/
 var mainDiagnosisSelectDiv = document.createElement('div');
 mainDiagnosisSelectDiv.className = "diagnosis-select-div";
 mainDiagnosis.appendChild(mainDiagnosisSelectDiv);

 /*Added Select*/
 var mainDiagnosisSelect = document.createElement('select');
 mainDiagnosisSelect.className = "diagnosis-select";
 mainDiagnosisSelect.id = "diagnosis-select";
 mainDiagnosisSelect.size = 10;
 mainDiagnosisSelectDiv.appendChild(mainDiagnosisSelect);


 /*+++++++++++++++++++++Create the sub diagnosis column*/
  var subDiagnosis = document.createElement('div');
  subDiagnosis.className = "diagnosis-columns";
  subDiagnosis.id = "sub-diagnosis";

  mainContainer.appendChild(subDiagnosis);
/*add sub diagnosis header*/
  var subDiagnosisHeader = document.createElement('div');
  subDiagnosisHeader.className = "diagnosis-headers";
  subDiagnosisHeader.innerHTML = "SUB DIAGNOSIS";
  subDiagnosis.appendChild(subDiagnosisHeader);
  //sub diagnosis notification area
  var subDiagnosisNotifyDiv = document.createElement('div');
  subDiagnosisNotifyDiv.className = "notify-div";
  subDiagnosisNotifyDiv.id = "subdiagnosis-notify";
  subDiagnosis.appendChild(subDiagnosisNotifyDiv);


  /*Select div*/
 var subDiagnosisSelectDiv = document.createElement('div');
 subDiagnosisSelectDiv.className = "diagnosis-select-div";
 subDiagnosis.appendChild(subDiagnosisSelectDiv);

 /*Added Select*/
 var subDiagnosisSelect = document.createElement('select');
 subDiagnosisSelect.className = "diagnosis-select";
 subDiagnosisSelect.id = "sub-diagnosis-select";
 subDiagnosisSelect.size = 10;
 subDiagnosisSelectDiv.appendChild(subDiagnosisSelect);


  /*+++++++++++++++++++++Create the sub sub diagnosis column*/
  var subSubDiagnosis = document.createElement('div');
  subSubDiagnosis.className = "diagnosis-columns";
  subSubDiagnosis.id = "sub-sub-diagnosis";
  
  mainContainer.appendChild(subSubDiagnosis);

  /*add sub sub diagnosis header*/
  var subSubDiagnosisHeader = document.createElement('div');
  subSubDiagnosisHeader.className = "diagnosis-headers";
  subSubDiagnosisHeader.innerHTML = "SUB SUB DIAGNOSIS";
  subSubDiagnosis.appendChild(subSubDiagnosisHeader);
  //sub diagnosis notification area
  var subSubDiagnosisNotifyDiv = document.createElement('div');
  subSubDiagnosisNotifyDiv.className = "notify-div";
  subSubDiagnosisNotifyDiv.id = "sub-subdiagnosis-notify";
  subSubDiagnosis.appendChild(subSubDiagnosisNotifyDiv);


   /*Select div*/
 var subSubDiagnosisSelectDiv = document.createElement('div');
 subSubDiagnosisSelectDiv.className = "diagnosis-select-div";
 subSubDiagnosis.appendChild(subSubDiagnosisSelectDiv);

 /*Added Select*/
 var subSubDiagnosisSelect = document.createElement('select');
 subSubDiagnosisSelect.className = "diagnosis-select";
 subSubDiagnosisSelect.id = "sub-sub-diagnosis-select";
 subSubDiagnosisSelect.size = 10;
 subSubDiagnosisSelectDiv.appendChild(subSubDiagnosisSelect);

}
/*Remove the dynamic elements from subsequent pages on Un load*/
function hideDiagnosisContainer(){
  //document.body.removeChild($('diagnosis-container'));
  $('content').removeChild($('diagnosis-container'));
}

function hideConfirmatoryContainer(){
  $('final_diagnosis').value = mainDataArray.toSource();
  //document.body.removeChild($('confirmatory-container'));
  $('content').removeChild($('confirmatory-container'));
}

/*+++++++++++++++++Some ajax for updating lists*/
function handleHttpResponse(updateElement) {
  var updateText = '';
  
  if (http.readyState == 4 && http.status == 200) {
    if (updateElement == 'diagnosis-select'){
      updateText = "<option onClick=validateEntry('diagnosis-select');>" + http.responseText.replace(/,/g, "</option><option onClick=validateEntry('diagnosis-select');>") + "</option>";
    $(updateElement).innerHTML = updateText;
    updateSubDiagnosisNotification();  
    checkIfOptionsAvailable();
    } else if (updateElement == 'sub-diagnosis-select'){

      updateText = "<option onClick=validateEntry('sub-diagnosis-select')>" + http.responseText.replace(/,/g, "</option><option onClick=validateEntry('sub-diagnosis-select')>") + "</option>";
    $(updateElement).innerHTML = updateText;
  
    checkIfOptionsAvailable();
    } else if (updateElement == 'sub-sub-diagnosis-select'){
      updateText = "<option onClick=updateInfoBar('sub-sub-diagnosis-select');checkObjectLength('sub-sub-diagnosis-select');>" + http.responseText.replace(/,/g, "</option><option onClick=updateInfoBar('sub-sub-diagnosis-select');checkObjectLength('sub-sub-diagnosis-select');>") + "</option>";
    $(updateElement).innerHTML = updateText;
  
    checkIfOptionsAvailable();
    }else if (updateElement == 'subDiagnosisPopUp'){
      if (http.responseText != ""){
        $('subDiagnosisPopUpDiv').style.display = "block";
        updateText = "<label onClick=changeParam();updateInfoBar(this);checkObjectLength('pop-up-object')>" + http.responseText.replace(/\;/g,"</label><br /><label onClick=updateInfoBar(this);checkObjectLength('pop-up-object')>") + "</label>";
        $(updateElement).innerHTML = updateText;
      }else{ /*Check in the final column*/
        $('subDiagnosisPopUpDiv').style.display = "none";
        var searchString = $('diagnosis-inputbox').value;
        var aUrl = "/search/unqualified_sub_diagnosis?level=third&search_string=" + searchString;
        var aElement = 'subSubDiagnosisPopUp';
        updateList(aElement, aUrl);
      }
    }else if (updateElement == 'subSubDiagnosisPopUp'){
      if (http.responseText != ""){
        $('subSubDiagnosisPopUpDiv').style.display = "block";
        updateText = "<label  onClick=changeParam();updateInfoBar(this);checkObjectLength('pop-up-object')>" + http.responseText.replace(/\;/g,"</label><br /><label onClick=updateInfoBar(this);checkObjectLength('pop-up-object')>") + "</label>";
        $(updateElement).innerHTML = updateText;
      } else {
        $('subSubDiagnosisPopUpDiv').style.display = "block";
        updateText = "No matches were found!<br />";
        $(updateElement).innerHTML = updateText;
      }
    } else if (updateElement == 'sub-diagnosis-notify'){
        var diagnosesMatches = 0;
        var matchesArray = http.responseText.split(';');
        if (matchesArray[0] != "" && matchesArray.length > 0 && $('diagnosis-inputbox').value != ""){
          $('subdiagnosis-notify').innerHTML = "<span class='notify-span' onClick=activatePopup('subDiagnosisPopUp')>(" + matchesArray.length + ")<blink> Possible matches</blink></span>";
        }else {
          $('subdiagnosis-notify').innerHTML = "";
        }
        updateSubSubDiagnosisNotification();
    } else if (updateElement == 'sub-sub-diagnosis-notify'){
        var diagnosesMatches = 0;
        var matchesArray = http.responseText.split(';');
        if (matchesArray[0] != "" && matchesArray.length > 0 && $('diagnosis-inputbox').value != ""){
          $('sub-subdiagnosis-notify').innerHTML = "<span class='notify-span' onClick=activatePopup('subSubDiagnosisPopUp')>(" + matchesArray.length + ")<blink> Possible matches</blink></span>";
        } else{
          $('sub-subdiagnosis-notify').innerHTML = "";
        }
    }
  }
}

function updateList(aElement, aUrl) {
 
  http.onreadystatechange = function(){
    handleHttpResponse(aElement);
  };
  try{
    http.open("GET", aUrl, true);
    http.send(null);
  }catch(e){
  }
}

function getHTTPObject() {
  var xmlhttp;
  if (!xmlhttp && typeof XMLHttpRequest != 'undefined') {
    try {
      xmlhttp = new XMLHttpRequest();
    } catch (e) {
      xmlhttp = false;
    }
  }
  return xmlhttp;
}
var http = getHTTPObject(); // We create the HTTP Object

function updateSelectionList(updateSelectionList, aElement){
  if (updateSelectionList == 'diagnosis-select'){
    aUrl = "/search/main_diagnosis?search_string=" + $(aElement).value;
  }

  updateList(updateSelectionList, aUrl);

}

function updateMainDiagnosis(){
  $('subdiagnosis-notify').innerHTML = "";
  $('diagnosis-inputbox').value = "";
  $('diagnosis-select').innerHTML = "<option></option>";
  var searchString =  $('diagnosis-inputbox').value;
  var aUrl = "/search/main_diagnosis?search_string=" + searchString;
  var aElement = 'diagnosis-select';
  updateList(aElement, aUrl);
}

function updateSubDiagnosis(){
  var mainDiagnosis =   $('diagnosis-inputbox').value;
  var aUrl = "/search/sub_diagnosis?main_diagnosis=" + mainDiagnosis;
  var aElement = 'sub-diagnosis-select';
  updateList(aElement, aUrl);
}

function updateSubSubDiagnosis(){
  var mainDiagnosis =  $('diagnosis-inputbox').value;
  var subDiagnosis =  $('sub-diagnosis-select').value;
  var aUrl = "/search/sub_sub_diagnosis?main_diagnosis="+ mainDiagnosis +"&sub_diagnosis=" + subDiagnosis;
  var aElement = 'sub-sub-diagnosis-select';
  updateList(aElement, aUrl);
}

function updateInfoBar(updateElement){
  if (updateElement == 'diagnosis-select'){
      tempDataArray.push($('diagnosis-select').value);
  } else if (updateElement == 'sub-diagnosis-select'){

    tempDataArray.push($('sub-diagnosis-select').value);
    } else if (updateElement == 'sub-sub-diagnosis-select'){
    tempDataArray.push($('sub-sub-diagnosis-select').value);
    } else if (updateInfoBarParameter == "update"){
      tempDataArray = updateElement.innerHTML.replace(/, /g,",").split(",");
      updateInfoBarParameter = "";
    };
  removeEmptyObjects();
  if (tempDataArray.toSource() != "[]"){
    $('infoBar'+tstCurrentPage).innerHTML = "<span onClick='removeMainValue(this)'>"+(mainDataArray.toSource().replace(/\[/g, "").replace(/\]/g, "").replace(/"/g, "").replace(/>,/g, ">").replace(/, </g, "<")).replace(/<br>/g,"</span><br><span onclick='removeMainValue(this)'>") + "</span>" + "<span onClick='removeTempValue(this)'>"+(tempDataArray.toSource().replace(/\[/g, "").replace(/\]/g, "").replace(/"/g, "").replace(/>,/g, ">").replace(/, </g, "<")).replace(/<br>/g,"</span><br><span onClick='removeTempValue(this)'>") + "</span>";
  }else {
    $('infoBar'+tstCurrentPage).innerHTML = "<span onClick='removeMainValue(this)'>"+(mainDataArray.toSource().replace(/\[/g, "").replace(/\]/g, "").replace(/"/g, "").replace(/>,/g, ">").replace(/, </g, "<")).replace(/<br>/g,"</span><br><span onclick='removeMainValue(this)'>") + "</span>";
  }

}

function getObjectLength(valueLength){
  var b = 0;
  for( i in valueLength ){
    b++;
  }
  return b;
}

function resetSelections(){
    mainDataArray.push(tempDataArray);
    mainDataArray.push("<br>")
    tempDataArray = [];
    $('infoBar'+tstCurrentPage).innerHTML = "<span onclick='removeMainValue(this)'>"+(mainDataArray.toSource().replace(/\[/g, "").replace(/\]/g, "").replace(/"/g, "").replace(/>,/g, ">").replace(/, </g, "<")).replace(/<br>/g,"</span><br><span onClick='removeMainValue(this)'>")+"</span>";
    
    $('sub-diagnosis-select').innerHTML = "<option></option>";
    $('sub-sub-diagnosis-select').innerHTML = "<option></option>";
    updateMainDiagnosis();
}

function checkObjectLength(selectedValue){
  if (selectedValue == 'diagnosis-select'){
    if(getObjectLength(finalAnswers[0][$(selectedValue).value]) == 0){
      resetSelections();
    } else{
      //alert('bingo');
      updateSubDiagnosis();
    }
  } else if (selectedValue == 'sub-diagnosis-select'){
    if(getObjectLength(finalAnswers[0][$('diagnosis-select').value][$(selectedValue).value]) == 0){
      resetSelections();
    }else{
      updateSubSubDiagnosis();
    }
  } else if (selectedValue == 'sub-sub-diagnosis-select'){
    if(getObjectLength(finalAnswers[0][$('diagnosis-select').value][$('sub-diagnosis-select').value][$(selectedValue).value]) == 0){
      resetSelections();
    }
  } else if (selectedValue == 'pop-up-object'){
     $('subDiagnosisPopUpDiv').style.display = "none";
     $('subSubDiagnosisPopUpDiv').style.display = "none";
     $('diagnosis-inputbox').value = "";
     resetSelections();
  } 
}

function removeMainValue(aElement){
  var originalStringArray = aElement.innerHTML.split(",");
  var myTempArray = [];
  var testString = ""

  var removeSpace = function(x){
    myTempArray.push(x.replace(/^ /,""))
  };

  var processArray = function(x,idx){
        testString = myTempArray.toSource();

    if (typeof(x) == 'object'){

      if (x.toSource() == testString){
        mainDataArray.splice(idx,2);   
        updateInfoBar(aElement);
        resetSelections();
        return;   
      }
    }
  }
  originalStringArray.forEach(removeSpace);
  mainDataArray.forEach(processArray);
}

function removeTempValue(aElement){
  tempDataArray = [];
  updateInfoBar(aElement);
  resetSelections();
}

function checkIfOptionsAvailable(){
  if ($('diagnosis-select').innerHTML.length == 62){
    var searchString = $('diagnosis-inputbox').value;
    var aUrl = "/search/unqualified_sub_diagnosis?level=second&search_string=" + searchString;
    var aElement = 'subDiagnosisPopUp';
    //setTimeout("", 500);
    updateList(aElement, aUrl);
  } else {
    $('subDiagnosisPopUpDiv').style.display = "none";
  }
}

function hidePopUp(){
  $('subDiagnosisPopUpDiv').style.display = "none";
  $('subSubDiagnosisPopUpDiv').style.display = "none";
  updateMainDiagnosis();
  $("diagnosis-inputbox").focus();
}

function createConfirmatoryEvidence(){
  
 var  mainContainer = document.createElement('div');
 /*Create the main container div*/
 mainContainer.id = "confirmatory-container";
 mainContainer.className = "main-container";
 //document.body.appendChild(mainContainer);
 $('content').appendChild(mainContainer);


 /*+++++++++++++++++++++++++++++++Create confirmatory evidence column column*/
  var confirmatoryEvidence = document.createElement('div');
  confirmatoryEvidence.id = "confirmatory-evidence";

  mainContainer.appendChild(confirmatoryEvidence);

   /*Select div*/
 var confirmatoryEvidenceSelectDiv = document.createElement('div');
 confirmatoryEvidenceSelectDiv.id = "confirmatory-evidence-select-div"
 confirmatoryEvidenceSelectDiv.className = "confirmatory-evidence-select-div";
 confirmatoryEvidence.appendChild(confirmatoryEvidenceSelectDiv);

 setTimeout("showConfirmatoryEvidence()", 500);

 $('infoBar'+tstCurrentPage).innerHTML = "<span onClick='removeMainValue(this)'>"+(mainDataArray.toSource().replace(/\[/g, "").replace(/\]/g, "").replace(/"/g, "").replace(/>,/g, ">").replace(/, </g, "<")).replace(/<br>/g,"</span><br><span onclick='removeMainValue(this)'>") + "</span>" ;

}

function updateSubDiagnosisNotification(){  
  var searchString = $('diagnosis-inputbox').value;
  updateList('sub-diagnosis-notify',"/search/unqualified_sub_diagnosis?level=second&search_string=" + searchString);
}

function updateSubSubDiagnosisNotification(){  
  var searchString = $('diagnosis-inputbox').value;
  updateList('sub-sub-diagnosis-notify',"/search/unqualified_sub_diagnosis?level=third&search_string=" + searchString);
}


function activatePopup(popUpType){
  var searchString = $('diagnosis-inputbox').value;
  if (popUpType == 'subDiagnosisPopUp'){
    var aUrl = "/search/unqualified_sub_diagnosis?level=second&search_string=" + searchString;
    updateList(popUpType, aUrl);
  }else if (popUpType == 'subSubDiagnosisPopUp'){
    var aUrl = "/search/unqualified_sub_diagnosis?level=third&search_string=" + searchString;
    updateList(popUpType, aUrl);
  }

}

var updateInfoBarParameter = "";

function changeParam(){
  updateInfoBarParameter = "update"
}

function removeEmptyObjects(){
   var processArray = function(x,idx){

    if (typeof(x) == 'object'){
      if (x.toSource() == "[]"){
        mainDataArray.splice(idx,2);   
        return;   
      }
    }
  }
  mainDataArray.forEach(processArray);
}

function objectConverter(a){
  var myObject = {};
  for(var i=0;i<a.length;i++)
  {
    myObject[a[i]]='';
  }
  return myObject;
}

function populateConfirmatoryEvidence(){
  confirmatoryEvidenceData = {};
  var processArray = function(x,idx){
    var diagnosis = "";
    if (typeof(x) == 'object'){
      if (x.toSource() != "[]"){
        diagnosis = x.toSource().replace(/\[/g,"").replace(/\]/g,"").replace(/,/g,"").replace(/"/g,"");
        confirmatoryEvidenceData[diagnosis] = [];
        for (i in finalTests[0]){
          if(diagnosis in objectConverter(finalTests[0][i])){
            confirmatoryEvidenceData[diagnosis].push(i);
          }
        }
      }
    }
  }
  mainDataArray.forEach(processArray); 
}

function showConfirmatoryEvidence(){
   for (i in confirmatoryEvidenceData){
   /*add confirmatory evidennce header */
  var confirmatoryEvidenceHeader = document.createElement('div');
  confirmatoryEvidenceHeader.className = "confirmatory-evidence-headers";
  confirmatoryEvidenceHeader.innerHTML = i;
  $('confirmatory-evidence-select-div').appendChild(confirmatoryEvidenceHeader);

 /*Added Select */
 var confirmatoryEvidenceSelect = document.createElement('select');
 confirmatoryEvidenceSelect.className = "confirmatory-evidence-select";
// confirmatoryEvidenceSelect.id = "confirmatory-evidence-select";
 confirmatoryEvidenceSelect.size = 10;
 $('confirmatory-evidence-select-div').appendChild(confirmatoryEvidenceSelect);

 confirmatoryEvidenceSelect.innerHTML = "<option>" + confirmatoryEvidenceData[i].toSource().replace(/"/g,"").replace(/\[/g,"").replace(/\]/g,"").replace(/,/g,"</option><option>") + "</option>";
 }

}

function setNextAttribute(){
 $('nextButton').setAttribute("onClick", "populateConfirmatoryEvidence()");
}

function validateEntry(updateElement){
  if (updateElement == 'diagnosis-select'){
    if (tempDataArray.length > 0){
      $('diagnosis-select').value = tempDataArray[0];
      alert('Invalid entry');
    }else{
      $('diagnosis-inputbox').value = $('diagnosis-select').value;
      updateInfoBar('diagnosis-select');
      checkObjectLength('diagnosis-select');
    }
  } else if (updateElement == 'sub-diagnosis-select'){
    if (tempDataArray.length == 2){
      $('sub-diagnosis-select').value = tempDataArray[1];
      alert('Invalid Sub');
    } else {
      updateInfoBar('sub-diagnosis-select');
      checkObjectLength('sub-diagnosis-select');
    }
    } 
}
