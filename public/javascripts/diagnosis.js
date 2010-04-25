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
  $('main-container').appendChild(simpleKeyBoard);
  
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
 mainContainer.id = "main-container";
 document.body.appendChild(mainContainer);

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
function removeElements(){
  $('final_diagnosis').value = mainDataArray.toSource();
  document.body.removeChild($('main-container'));
}

/*+++++++++++++++++Some ajax for updating lists*/
function handleHttpResponse(updateElement) {
  var updateText = '';
  
  if (http.readyState == 4 && http.status == 200) {
    if (updateElement == 'diagnosis-select'){
      updateText = "<option onClick=updateTextBox('diagnosis-inputbox','diagnosis-select');updateSubDiagnosis();updateInfoBar('"+ updateElement +"');checkObjectLength('diagnosis-select');>" + http.responseText.replace(/,/g, "</option><option onClick=updateTextBox('diagnosis-inputbox','diagnosis-select');updateSubDiagnosis();updateInfoBar('" + updateElement + "');checkObjectLength('diagnosis-select');>") + "</option>";
    $(updateElement).innerHTML = updateText;
    updateSubDiagnosisNotification();  
    checkIfOptionsAvailable();
    } else if (updateElement == 'sub-diagnosis-select'){

      updateText = "<option onClick=updateSubSubDiagnosis();updateInfoBar('"+ updateElement +"');checkObjectLength('sub-diagnosis-select')>" + http.responseText.replace(/,/g, "</option><option onClick=updateSubSubDiagnosis();updateInfoBar('"+ updateElement +"');checkObjectLength('sub-diagnosis-select');>") + "</option>";
    $(updateElement).innerHTML = updateText;
  
    checkIfOptionsAvailable();
    } else if (updateElement == 'sub-sub-diagnosis-select'){
      updateText = "<option onClick=updateInfoBar('"+ updateElement +"');checkObjectLength('sub-sub-diagnosis-select');>" + http.responseText.replace(/,/g, "</option><option onClick=updateInfoBar('"+ updateElement +"');checkObjectLength('sub-sub-diagnosis-select');>") + "</option>";
    $(updateElement).innerHTML = updateText;
  
    checkIfOptionsAvailable();
    } else if (updateElement == 'confirmatory-evidence-select'){
        confirmatoryEvidenceString += http.responseText + ",";
        resetSelections();
    }else if (updateElement == 'subDiagnosisPopUp'){
      if (http.responseText != ""){
        $('subDiagnosisPopUpDiv').style.display = "block";
        updateText = "<label onClick=updateInfoBar(this);checkObjectLength('pop-up-object')>" + http.responseText.replace(/\;/g,"</label><br /><label onClick=updateInfoBar(this);checkObjectLength('pop-up-object')>") + "</label>";
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
        updateText = "<label  onClick=updateInfoBar(this);checkObjectLength('pop-up-object')>" + http.responseText.replace(/\;/g,"</label><br /><label onClick=updateInfoBar(this);checkObjectLength('pop-up-object')>") + "</label>";
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


function updateTextBox(aElement, parentElement){
  $(aElement).value = $(parentElement).value;

}

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
    } else if (updateElement == 'confirmatory-evidence-select'){
      tempDataArray.push($('confirmatory-evidence-select').value);
    } else{
      tempDataArray = [];//updateElement.innerHTML.replace(/, /g,",").split(",");
    };
  if (tempDataArray.toSource() != "[]"){
    alert(tempDataArray.toSource());
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


/*Look for confirmatory evidence*/

function updateConfirmatoryEvidence(){
  var diagnosis = tempDataArray.toSource().replace(/"/g,"").replace(/\[/g,"").replace(/\]/g, "").replace(/,/g,"")
  var aUrl = "/search/confirmatory_evidence?diagnosis=" + diagnosis;
  var aElement = 'confirmatory-evidence-select';
  updateList(aElement, aUrl);
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
      updateConfirmatoryEvidence();
    }
  } else if (selectedValue == 'sub-diagnosis-select'){
    if(getObjectLength(finalAnswers[0][$('diagnosis-select').value][$(selectedValue).value]) == 0){
      updateConfirmatoryEvidence();
    }
  } else if (selectedValue == 'sub-sub-diagnosis-select'){
    if(getObjectLength(finalAnswers[0][$('diagnosis-select').value][$('sub-diagnosis-select').value][$(selectedValue).value]) == 0){
      updateConfirmatoryEvidence();
    }
  } else if (selectedValue == 'pop-up-object'){
     $('subDiagnosisPopUpDiv').style.display = "none";
     $('subSubDiagnosisPopUpDiv').style.display = "none";
     $('diagnosis-inputbox').value = "";
     updateConfirmatoryEvidence();
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
  if ($('diagnosis-select').innerHTML.length == 176){
    var searchString = $('diagnosis-inputbox').value;
    var aUrl = "/search/unqualified_sub_diagnosis?level=second&search_string=" + searchString;
    var aElement = 'subDiagnosisPopUp';
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
 mainContainer.id = "main-container";
 document.body.appendChild(mainContainer);


 /*+++++++++++++++++++++++++++++++Create confirmatory evidence column column*/
  var confirmatoryEvidence = document.createElement('div');
  confirmatoryEvidence.id = "confirmatory-evidence";

  mainContainer.appendChild(confirmatoryEvidence);

  /*add confirmatory evidennce header*/
  var confirmatoryEvidenceHeader = document.createElement('div');
  confirmatoryEvidenceHeader.className = "diagnosis-headers";
  confirmatoryEvidenceHeader.innerHTML = "TEST RESULT AVAILABLE?";
  confirmatoryEvidence.appendChild(confirmatoryEvidenceHeader);


   /*Select div*/
 var confirmatoryEvidenceSelectDiv = document.createElement('div');
 confirmatoryEvidenceSelectDiv.className = "diagnosis-select-div";
 confirmatoryEvidence.appendChild(confirmatoryEvidenceSelectDiv);

 /*Added Select*/
 var confirmatoryEvidenceSelect = document.createElement('select');
 confirmatoryEvidenceSelect.className = "diagnosis-select";
 confirmatoryEvidenceSelect.id = "confirmatory-evidence-select";
 confirmatoryEvidenceSelect.size = 10;
 confirmatoryEvidenceSelectDiv.appendChild(confirmatoryEvidenceSelect);

 $('confirmatory-evidence-select').innerHTML = "<option>" + confirmatoryEvidenceString.replace(/,/g,"</option><option>") + "</option>";

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

