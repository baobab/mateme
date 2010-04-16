function updateFromKeyboard(aText){
  $('diagnosis-inputbox').value = $('diagnosis-inputbox').value + aText;
}
function updateFromKeyboardAgain(){
  $('diagnosis-inputbox').value = $('diagnosis-inputbox').value.slice(0, -1);
}

function createKeyboardRow(aDivPosition, aRowValues){

  for (var i = 0; i < aRowValues.length; i++){
    var simpleButtonSpan = document.createElement('span');
    simpleButtonSpan.className = 'simple-button'; 
    simpleButtonSpan.innerHTML = aRowValues[i];
    simpleButtonSpan.setAttribute("onClick", "updateFromKeyboard('" + aRowValues[i]+ "');updateSelectionList('diagnosis-select','diagnosis-inputbox');");

    $(aDivPosition).appendChild(simpleButtonSpan);
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
  backSpace.className = 'simple-button';
  backSpace.id = 'simple-backspace';
  backSpace.innerHTML = 'DELETE';
  backSpace.setAttribute("onClick", " updateFromKeyboardAgain();updateSelectionList('diagnosis-select','diagnosis-inputbox')")
  keyboardDivBottom.appendChild(backSpace);
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
 mainDiagnosisInputBox.setAttribute("onKeyUp", "updateSelectionList('diagnosis-select','diagnosis-inputbox')");
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


 /*+++++++++++++++++++++++++++++++Create confirmatory evidence column column*/
  var confirmatoryEvidence = document.createElement('div');
  confirmatoryEvidence.className = "diagnosis-columns";
  confirmatoryEvidence.id = "confirmatory-evidence";

  mainContainer.appendChild(confirmatoryEvidence);

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
    } else if (updateElement == 'sub-diagnosis-select'){

      updateText = "<option onClick=updateSubSubDiagnosis();updateInfoBar('"+ updateElement +"');checkObjectLength('sub-diagnosis-select')>" + http.responseText.replace(/,/g, "</option><option onClick=updateSubSubDiagnosis();updateInfoBar('"+ updateElement +"');checkObjectLength('sub-diagnosis-select');>") + "</option>";
    } else if (updateElement == 'sub-sub-diagnosis-select'){
      updateText = "<option onClick=updateInfoBar('"+ updateElement +"');checkObjectLength('sub-sub-diagnosis-select');>" + http.responseText.replace(/,/g, "</option><option onClick=updateInfoBar('"+ updateElement +"');checkObjectLength('sub-sub-diagnosis-select');>") + "</option>";
    } else if (updateElement == 'confirmatory-evidence-select'){
      updateText = "<option onClick=resetSelections();>FINISHED</option><option onClick=updateInfoBar('" + updateElement + "')>" + http.responseText.replace(/,/g, "</option><option onClick=updateInfoBar('"+updateElement+"')>") + "</option>"
    }

    $(updateElement).innerHTML = updateText;
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
  $('diagnosis-inputbox').value = ""
  $('diagnosis-select').innerHTML = "<option></option>"
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
    };
  
    $('infoBar'+tstCurrentPage).innerHTML = "<span onClick='removeMainValue(this)'>"+(mainDataArray.toSource().replace(/\[/g, "").replace(/\]/g, "").replace(/"/g, "").replace(/>,/g, ">").replace(/, </g, "<")).replace(/<br>/g,"</span><br><span onclick='removeMainValue(this)'>") + "</span>" + "<span onClick='removeTempValue(this)'>"+(tempDataArray.toSource().replace(/\[/g, "").replace(/\]/g, "").replace(/"/g, "").replace(/>,/g, ">").replace(/, </g, "<")).replace(/<br>/g,"</span><br><span onClick='removeTempValue(this)'>") + "</span>";
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
  var diagnosis = tempDataArray.toSource().replace(/"/g,"").replace(/\[/g,"").replace(/\]/g, "").replace(/,/,"")
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
    $('confirmatory-evidence-select').innerHTML = "<option></option>";
    updateMainDiagnosis();
}

function checkObjectLength(selectedValue){
  if (selectedValue == 'diagnosis-select'){
    if(getObjectLength(finalAnswers[0][$(selectedValue).value]) == 0){
      /*resetSelections();*/
      updateConfirmatoryEvidence();
    }
  } else if (selectedValue == 'sub-diagnosis-select'){
    if(getObjectLength(finalAnswers[0][$('diagnosis-select').value][$(selectedValue).value]) == 0){
     /* resetSelections();*/
      updateConfirmatoryEvidence();
    }
  } else if (selectedValue == 'sub-sub-diagnosis-select'){
    if(getObjectLength(finalAnswers[0][$('diagnosis-select').value][$('sub-diagnosis-select').value][$(selectedValue).value]) == 0){
      /*resetSelections();*/
      updateConfirmatoryEvidence();
    }
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
        updateInfoBar();
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
  updateInfoBar();
  resetSelections();
}


