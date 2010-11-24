function updateFromKeyboard(aText){
  if (activeInputBox == 'diagnosis-inputbox'){
    if (aText == null){
      $('diagnosis-inputbox').value = $('diagnosis-inputbox').value.slice(0, -1);
    }else{
      $('diagnosis-inputbox').value = $('diagnosis-inputbox').value + aText;
    }
  }else{
     if (aText == null){
      $('other-diagnosis-inputbox').value = $('other-diagnosis-inputbox').value.slice(0, -1);
    }else{
      $('other-diagnosis-inputbox').value = $('other-diagnosis-inputbox').value + aText;
    }
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
  
  var keyboardRowTop = ["Q","W","E","R","T","Y","U","I","O","P","?"];
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

   /*Create Space*/
  var space = document.createElement('span');
  space.innerHTML = 'SPACE';
  
  var spaceButton = document.createElement('button');
  spaceButton.className = 'simple-button'; 
  spaceButton.setAttribute("onClick", "updateFromKeyboard(' ');updateSelectionList('diagnosis-select','diagnosis-inputbox');");
  
  keyboardDivMiddle.appendChild(spaceButton);
  
  spaceButton.appendChild(space);

}

function createElements(){

 var  mainContainer = document.createElement('div');
 /*Create the main container div*/
 mainContainer.id = "diagnosis-container";
 mainContainer.className = "main-container";
 //document.body.appendChild(mainContainer);
 $('content').appendChild(mainContainer);

  /*Added Info bar */
 var diagnosesInfobarMain = document.createElement('div');
 diagnosesInfobarMain.className = "diagnosesInfobarMain";
 $('diagnosis-container').appendChild(diagnosesInfobarMain);
 
 var priSecAddDiv = document.createElement('div');
 priSecAddDiv.id = "priSecAddDiv";
 diagnosesInfobarMain.appendChild(priSecAddDiv);

 var diagnosesInfobar = document.createElement('div');
 diagnosesInfobar.id = "diagnoses-infobar";
 diagnosesInfobarMain.appendChild(diagnosesInfobar);
 
 /*Added Text Input */
 var mainDiagnosisInputBox = document.createElement('input');
 mainDiagnosisInputBox.className = "diagnosis-inputbox";
 mainDiagnosisInputBox.id = "diagnosis-inputbox";
 mainDiagnosisInputBox.setAttribute("onKeyUp", "updateSelectionList('diagnosis-select','diagnosis-inputbox');");
 $('diagnosis-container').appendChild(mainDiagnosisInputBox);


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
  subDiagnosisHeader.innerHTML = "SUB DIAGNOSIS &nbsp;&nbsp; <span id='subdiagnosis-notify'> </span>";
  subDiagnosis.appendChild(subDiagnosisHeader);

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
  subSubDiagnosisHeader.innerHTML = "SUB SUB DIAGNOSIS &nbsp;&nbsp; <span id='sub-subdiagnosis-notify'></span>";
  subSubDiagnosis.appendChild(subSubDiagnosisHeader);

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
   //check for iris conditions
  for (i in mainDataArray){
    if (mainDataArray[i] in objectConverter(irisConditions)){
    irisConditionAvailable = true;
  }
  }

}

function hideConfirmatoryContainer(){
  //document.body.removeChild($('confirmatory-container'));
  $('content').removeChild($('confirmatory-container'));
}

/*+++++++++++++++++Some ajax for updating lists*/
function handleHttpResponse(updateElement) {
  var updateText = '';
  
  if (http.readyState == 4 && http.status == 200) {
    if (updateElement == 'sub-diagnosis-notify'){
        subDiagnosisPopupData =  http.responseText;
        var diagnosesMatches = 0;
        var matchesArray = subDiagnosisPopupData.split(';');
        if (matchesArray[0] != "" && matchesArray.length > 0 && $('diagnosis-inputbox').value != ""){
          $('subdiagnosis-notify').innerHTML = "<span class='notify-span' onClick=activatePopup('subDiagnosisPopUp')>(" + matchesArray.length + ")<blink> Matches</blink></span>";
        }else {
          $('subdiagnosis-notify').innerHTML = "";
        }
        setTimeout("updateSubSubDiagnosisNotification()", 500);
    } else if (updateElement == 'sub-sub-diagnosis-notify'){
        subSubDiagnosisPopupData =  http.responseText;
        var diagnosesMatches = 0;
        var matchesArray = subSubDiagnosisPopupData.split(';');
        if (matchesArray[0] != "" && matchesArray.length > 0 && $('diagnosis-inputbox').value != ""){
          $('sub-subdiagnosis-notify').innerHTML = "<span class='notify-span' onClick=activatePopup('subSubDiagnosisPopUp')>(" + matchesArray.length + ")<blink> Matches</blink></span>";
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

  //Check if entered word is synonym 
  if (typeof(synonyms[$('diagnosis-inputbox').value]) == 'object'){
    synonymString = stringfyArray(synonyms[$('diagnosis-inputbox').value], true);
    //stringfyArray(synonyms[$('diagnosis-inputbox').value], true);
    //activatePopup('synonymsPopUp');
  } 
 
  if (updateSelectionList == 'diagnosis-select'){
    updateMainDiagnosis();
  }
}

function updateMainDiagnosis(){
  var fullString = '';
  var searchString = $('diagnosis-inputbox').value;
  var tmpArray = [];
  var patt = "^" + $('diagnosis-inputbox').value;
  $('subdiagnosis-notify').innerHTML = "";
  $('diagnosis-select').innerHTML = "<option></option>";

  for (i in diagnosesHash){
    if (i.match(patt)){
      tmpArray.push(i)
    }
  }
  if (synonymString != ''){
    fullString = synonymString + ';' + stringfyArray(tmpArray, true);
  }else{
    fullString = stringfyArray(tmpArray, true);
  }

    $('diagnosis-select').innerHTML = "<option onClick=validateEntry('diagnosis-select');>" + fullString.replace(/\;/g, "</option><option onClick=validateEntry('diagnosis-select');>") + "</option>";
    synonymString = '';
    setTimeout("updateSubDiagnosisNotification()", 500);  
    checkIfOptionsAvailable();
}

function updateSubDiagnosis(){
  var mainDiagnosis =   $('diagnosis-inputbox').value;

  var tmpArray = [];

  for (i in diagnosesHash[mainDiagnosis]){
      tmpArray.push(i)
  }

    $('sub-diagnosis-select').innerHTML = "<option onClick=validateEntry('sub-diagnosis-select')>" + stringfyArray(tmpArray,true).replace(/\;/g, "</option><option onClick=validateEntry('sub-diagnosis-select')>") + "</option>";
    checkIfOptionsAvailable();

}

function updateSubSubDiagnosis(){
  var mainDiagnosis =  $('diagnosis-inputbox').value;
  var subDiagnosis =  $('sub-diagnosis-select').value;
  var tmpArray = [];

  for (i in diagnosesHash[mainDiagnosis][subDiagnosis]){
      tmpArray.push(i);
  }

   $('sub-sub-diagnosis-select').innerHTML   = "<option onClick=validateEntry('sub-sub-diagnosis-select');>" + stringfyArray(tmpArray,true).replace(/\;/g, "</option><option onClick=validateEntry('sub-sub-diagnosis-select');>") + "</option>";
  
    checkIfOptionsAvailable();
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

    //check if elements of tempDataArray constitute multiselect
    if (stringfyArray(tempDataArray,false).replace(/\;/," ") in  multiSelectDiagnoses){
      activatePopup('multiSelectPopUp');
    }
   showHeaders(); 
}

function getObjectLength(valueLength){
  var b = 0;
  for( i in valueLength ){
    b++;
  }
  return b;
}

function resetSelections(){
    if (tempDataArray.toSource() != "[]"){ //avoid inserting empty objects
      if (stringfyArray(tempDataArray,false).replace(/\;/g," ") in objectConverter(mainDataArray)){
        $('duplicateWarning').style.display='block';
      }else{
        mainDataArray.push(stringfyArray(tempDataArray,false).replace(/\;/g," "));
      }
      tempDataArray = [];
    }
    
    $('sub-diagnosis-select').innerHTML = "<option></option>";
    $('sub-sub-diagnosis-select').innerHTML = "<option></option>";
    $('diagnosis-inputbox').value = "";
    updateMainDiagnosis();
    showHeaders();
}

function checkObjectLength(selectedValue){
  if (selectedValue == 'diagnosis-select'){
    if(getObjectLength(finalAnswers[0][$(selectedValue).value]) == 0){
      resetSelections();
    } else{
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
     $('synonymsPopUpDiv').style.display = "none";
     $('diagnosis-inputbox').value = "";
     resetSelections();
  } 
}

function removeMainValue(aValue){
    mainDataArray.splice(mainDataArray.indexOf(aValue),1);
    updateInfoBar();
    if (!multiSelectSession){
      resetSelections();
    }
}

function removeTempValue(aElement){
  tempDataArray = [];
  multiSelectSession = false;
  $('multiSelectPopUpDiv').style.display = "none";
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

function hidePopUp(popUpType){
  $('subDiagnosisPopUpDiv').style.display = "none";
  $('subSubDiagnosisPopUpDiv').style.display = "none";
  $('synonymsPopUpDiv').style.display = "none";
  $('multiSelectPopUpDiv').style.display = "none";
  $('otherDiagnosisPopUpDiv').style.display = "none";
  $('testResultPopUpDiv').style.display = "none";
  if (popUpType == "diagnosis"){
    updateMainDiagnosis();
  }else if (popUpType == 'multiSelect'){
    multiSelectSession = false;
    tempDataArray = [];
    resetSelections();
  }else if (popUpType == "otherDiagnosis"){
    processOther();
    tempDataArray = [];
    resetSelections();
  }
  $("diagnosis-inputbox").focus();
}

function createConfirmatoryEvidence(){
  $('nextButton').click();
  
 var  mainContainer = document.createElement('div');
 /*Create the main container div*/
 mainContainer.id = "confirmatory-container";
 mainContainer.className = "main-container";
 //document.body.appendChild(mainContainer);
 $('content').appendChild(mainContainer);
 
 var testsRequestedHeader = document.createElement('div');
 testsRequestedHeader.id = 'tests-header';
 testsRequestedHeader.innerHTML = "<span>TESTS DONE</span>";
 $('confirmatory-container').appendChild(testsRequestedHeader);

 var diagnosesInfobarMain = document.createElement('div');
 diagnosesInfobarMain.className = "diagnosesInfobarMain";
 diagnosesInfobarMain.id = 'confirm-info-bar';
 diagnosesInfobarMain.innerHTML = "";
 $('confirmatory-container').appendChild(diagnosesInfobarMain);

 /*+++++++++++++++++++++++++++++++Create confirmatory evidence column column*/
  var confirmatoryEvidence = document.createElement('div');
  confirmatoryEvidence.id = "confirmatory-evidence";

  mainContainer.appendChild(confirmatoryEvidence);

   /*Select div*/
 var confirmatoryEvidenceSelectDiv = document.createElement('div');
 confirmatoryEvidenceSelectDiv.id = "confirmatory-evidence-select-div"
 confirmatoryEvidenceSelectDiv.className = "confirmatory-evidence-select-div";
 confirmatoryEvidence.appendChild(confirmatoryEvidenceSelectDiv);

 setTimeout("showConfirmatoryEvidence()", 200);
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
  if (popUpType == 'subDiagnosisPopUp'){
     $('subDiagnosisPopUpDiv').style.display = "block";
        $('subDiagnosisPopUp').innerHTML = "<label onClick=changeParam();updateInfoBar(this);checkObjectLength('pop-up-object')>" + subDiagnosisPopupData.replace(/\;/g,"</label><br /><label onClick=changeParam();updateInfoBar(this);checkObjectLength('pop-up-object')>") + "</label>";
  
  }else if (popUpType == 'subSubDiagnosisPopUp'){
     $('subSubDiagnosisPopUpDiv').style.display = "block";
        $('subSubDiagnosisPopUp').innerHTML = "<label  onClick=changeParam();updateInfoBar(this);checkObjectLength('pop-up-object')>" + subSubDiagnosisPopupData.replace(/\;/g,"</label><br /><label onClick=changeParam();updateInfoBar(this);checkObjectLength('pop-up-object')>") + "</label>";
  
  } else if (popUpType == 'synonymsPopUp'){
     $('synonymsPopUpDiv').style.display = "block";
        $('synonymsPopUp').innerHTML = "<label onClick=changeParam();updateInfoBar(this);checkObjectLength('pop-up-object')>" + stringfiedArray.replace(/\;/g,"</label><br /><label onClick=changeParam();updateInfoBar(this);checkObjectLength('pop-up-object')>") + "</label>";
  } else if (popUpType == 'multiSelectPopUp'){
     $('multiSelectPopUpDiv').style.display = "block";
       multiSelectSession = true;
        $('multiSelectPopUp').innerHTML = "<label onClick=processMultiSelect(this)>" + stringfyArray(multiSelectDiagnoses[stringfyArray(tempDataArray,false).replace(/\;/," ")]).replace(/\;/g,"</label><br /><label onClick=processMultiSelect(this)>") + "</label>";
  } else if (popUpType == 'otherDiagnosisPopUp'){
    $('otherDiagnosisPopUpDiv').style.display = "block";
    activeInputBox = 'other-diagnosis-inputbox';
  }
}

var updateInfoBarParameter = "";

function changeParam(){
  updateInfoBarParameter = "update"
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
  var tmpHash = {};
  confirmatoryEvidenceData = {};
  var processArray = function(x,idx){ //Assign relevent tests to elements in mainDataArray 
        for (i in finalTests[0]){
          if(x in objectConverter(finalTests[0][i])){
            if (typeof(confirmatoryEvidenceData[x]) == 'undefined'){
              confirmatoryEvidenceData[x] = [];
            }
            //This section avoids double showing the same test even if it applies to different diagnosis
            if (!(i in tmpHash)){
              confirmatoryEvidenceData[x].push(i);
              tmpHash[i] = 0;
            }
          }
        }
  }
  mainDataArray.forEach(processArray); 
}

function showConfirmatoryEvidence(){
   if (confirmatoryEvidenceData.toSource() == "({})"){
     if (back == true){
       back = false;
       gotoPage(0);
     }else{
      back = true;
      if (irisConditionAvailable == false){
        $('savingPopUpBox').style.display='block';
      }
      gotoNextPage();
     }
  }else{
   for (i in confirmatoryEvidenceData){
     if (confirmatoryEvidenceData[i].length != 0){
       /*add confirmatory evidennce header */
       var confirmatoryEvidenceHeader = document.createElement('div');
       confirmatoryEvidenceHeader.className = "confirmatory-evidence-headers";
       confirmatoryEvidenceHeader.innerHTML = i;
       $('confirmatory-evidence-select-div').appendChild(confirmatoryEvidenceHeader);
       
       /*Added Select */
       var confirmatoryEvidenceSelect = document.createElement('select');
       confirmatoryEvidenceSelect.className = "confirmatory-evidence-select";
       confirmatoryEvidenceSelect.size = 10;
       $('confirmatory-evidence-select-div').appendChild(confirmatoryEvidenceSelect);
       
       confirmatoryEvidenceSelect.innerHTML = "<option onClick= updateTests(this.value)>" + confirmatoryEvidenceData[i].toSource().replace(/"/g,"").replace(/\[/g,"").replace(/\]/g,"").replace(/,/g,"</option><option onClick= updateTests(this.value)>") + "</option>";
     } 
   }
  }

}

function setNextAttribute(){
 $('nextButton').setAttribute("onClick", "populateConfirmatoryEvidence()");
}

function validateEntry(updateElement){

  if ($(updateElement).value.search(/OTHER/) != -1 || $(updateElement).value.search(/SPECIFY/) != -1){
    activatePopup('otherDiagnosisPopUp');
  }else{
    if (updateElement == 'diagnosis-select'){
      if (tempDataArray.length > 0){
        $('diagnosis-select').value = tempDataArray[0];
        $('invalidDiagnosis').style.display='block';
      } else{
        $('diagnosis-inputbox').value = $('diagnosis-select').value;
        updateInfoBar('diagnosis-select');
        checkObjectLength('diagnosis-select');
      }
    } else if (updateElement == 'sub-diagnosis-select'){
      if (tempDataArray.length == 2){
        $('sub-diagnosis-select').value = tempDataArray[1];
        $('invalidDiagnosis').style.display='block';
      } else {
        updateInfoBar('sub-diagnosis-select');
        checkObjectLength('sub-diagnosis-select');
      }
    }else if  (updateElement == 'sub-sub-diagnosis-select'){
      updateInfoBar('sub-sub-diagnosis-select');
      checkObjectLength('sub-sub-diagnosis-select');
    }
  }
}

function showHeaders(){

  var mainDataArrayHash = processDiagnoses();
  var header_str = "";
  var diagnoses_str = "";

  for (x in mainDataArrayHash){
    header_str += x == 'PRIMARY DIAGNOSIS'? "PRIMARY:":(x == "SECONDARY DIAGNOSIS"? "SECONDARY:" : "ADDITIONAL:");           ;
    for (i in mainDataArrayHash[x]){
      header_str += "<br />";
      diagnoses_str += "<span onClick=\"removeMainValue('" + mainDataArrayHash[x][i] + "')\">" + mainDataArrayHash[x][i] + "<span style='display:inline-block;width:20px;'></span><span><img src='/images/cancel_flat_small.png'></span></span><br />"
    }
  }
  $('priSecAddDiv').innerHTML = header_str;
  $('diagnoses-infobar').innerHTML = diagnoses_str + "<span onClick='removeTempValue(this)'>" + stringfyArray(tempDataArray,false).replace(/\;/g," ") + "</span>";
}

function processDiagnoses(){
  var current_key = "";
  var tmpHash = {};
  var tmpPointer = {};
  var diagnosisType = '';

   for (i in mainDataArray){
    current_key = mainDataArray[i].split(" ")[0]
    
    if(typeof(tmpPointer[current_key]) == 'undefined'){
      //assign an unassigned diagnosis type or default to ADDITIONAL DIAGNOSIS
      var assignedDiagnosisTypes = {}
      for (n in tmpPointer){
        assignedDiagnosisTypes[tmpPointer[n]] = 0
      }
      diagnosisType = !('PRIMARY DIAGNOSIS' in assignedDiagnosisTypes)? "PRIMARY DIAGNOSIS":(!('SECONDARY DIAGNOSIS' in assignedDiagnosisTypes)? "SECONDARY DIAGNOSIS": "ADDITIONAL DIAGNOSIS");
      tmpPointer[current_key] = diagnosisType;
    }

    if (typeof(tmpHash[diagnosisType]) == 'undefined'){
      tmpHash[diagnosisType] = [];
    }
    diagnosisType = tmpPointer[current_key];
    tmpHash[diagnosisType].push(mainDataArray[i])
  }
   return tmpHash;
}


function createHiddenDiagnosis(){  
  var mainDataArrayHash = processDiagnoses();
  var tmpArr = [];

  for (x in mainDataArrayHash){
    tmpArr = mainDataArrayHash[x]
      for (i in tmpArr){
        var valueCodedOrText = document.createElement('input');
        valueCodedOrText.name = 'observations[][value_coded_or_text]';
        valueCodedOrText.type = 'hidden';
        valueCodedOrText.value = tmpArr[i];
        valueCodedOrText.className = 'hiddenDiagnosis';
        $('inpatient_diagnosis').appendChild(valueCodedOrText);
        
        var conceptName = document.createElement('input');
        conceptName.name = 'observations[][concept_name]';
        conceptName.type = 'hidden';
        conceptName.value = x;
        conceptName.className = 'hiddenDiagnosis' ;
        $('inpatient_diagnosis').appendChild(conceptName);
        
        var patientId = document.createElement('input');
        patientId.name = 'observations[][patient_id]';
        patientId.type = 'hidden';
        patientId.value = patientIdValue;
        patientId.className = 'hiddenDiagnosis';
        $('inpatient_diagnosis').appendChild(patientId);
        
        var obsDatetime = document.createElement('input');
        obsDatetime.name = 'observations[][obs_datetime]';
        obsDatetime.type = 'hidden';
        obsDatetime.value = obsDatetimeValue;
        obsDatetime.className = 'hiddenDiagnosis';
        $('inpatient_diagnosis').appendChild(obsDatetime);
      } 
  }
}

function createHiddenConfirmatoryEvidence(){
   if (irisConditionAvailable == false){
     $('savingPopUpBox').style.display='block';
   }

  for (i in allTests){
    var valueCodedOrText = document.createElement('input');
    valueCodedOrText.name = 'observations[][value_coded_or_text]';
    valueCodedOrText.type = 'hidden';
    valueCodedOrText.value = i;
    valueCodedOrText.className = "hiddenTests";
    $('inpatient_diagnosis').appendChild(valueCodedOrText);

    var conceptName = document.createElement('input');
    conceptName.name = 'observations[][concept_name]';
    conceptName.type = 'hidden';
    conceptName.value = "TEST REQUESTED";
    conceptName.className = "hiddenTests";
    $('inpatient_diagnosis').appendChild(conceptName);
    
    var patientId = document.createElement('input');
    patientId.name = 'observations[][patient_id]';
    patientId.type = 'hidden';
    patientId.value = patientIdValue;
    patientId.className = "hiddenTests";
    $('inpatient_diagnosis').appendChild(patientId);

    var obsDatetime = document.createElement('input');
    obsDatetime.name = 'observations[][obs_datetime]';
    obsDatetime.type = 'hidden';
    obsDatetime.value = obsDatetimeValue;
    obsDatetime.className = "hiddenTests";
    $('inpatient_diagnosis').appendChild(obsDatetime);

    if (allTests[i] != 0){//If a test result has been entered
      var valueCodedOrText = document.createElement('input');
      valueCodedOrText.name = 'observations[][value_coded_or_text]';
      valueCodedOrText.type = 'hidden';
      valueCodedOrText.value = allTests[i];
      valueCodedOrText.className = "hiddenTests";
      $('inpatient_diagnosis').appendChild(valueCodedOrText);

      var conceptName = document.createElement('input');
      conceptName.name = 'observations[][concept_name]';
      conceptName.type = 'hidden';
      conceptName.value = i + ' RESULT';
      conceptName.className = "hiddenTests";
      $('inpatient_diagnosis').appendChild(conceptName);
    
      var patientId = document.createElement('input');
      patientId.name = 'observations[][patient_id]';
      patientId.type = 'hidden';
      patientId.value = patientIdValue;
      patientId.className = "hiddenTests";
      $('inpatient_diagnosis').appendChild(patientId);

      var obsDatetime = document.createElement('input');
      obsDatetime.name = 'observations[][obs_datetime]';
      obsDatetime.type = 'hidden';
      obsDatetime.value = obsDatetimeValue;
      obsDatetime.className = "hiddenTests";
      $('inpatient_diagnosis').appendChild(obsDatetime);
    }
  }
}

function removeTest(aValue){
  delete allTests[aValue];
  updateConfirmatoryInforBar();
}

function updateConfirmatoryInforBar(){
  $('confirm-info-bar').innerHTML = '';
    for (i in allTests){
      if (allTests[i] == 0){
        $('confirm-info-bar').innerHTML += "<span onClick=\"removeTest('"+ i + "')\">" + i + "<span style='display:inline-block;width:20px;'></span><span><img src='/images/cancel_flat_small.png'></span></span><br />"; 
      }else{
        $('confirm-info-bar').innerHTML += "<span onClick=\"removeTest('"+ i + "')\">" + i + " : " + allTests[i] +"<span style='display:inline-block;width:20px;'></span><span><img src='/images/cancel_flat_small.png'></span></span><br />"; 
      }
    }

}

function updateTests(aValue){
  //avoid entry of duplicate values
  if (aValue in allTests){
    $('duplicateWarning').style.display='block';
  }else{
    if (aValue in finalTestResults){
      stringfiedArray = stringfyArray(finalTestResults[aValue],true);
      $('testResultPopUpDiv').style.display = "block";
      $('testResultPopUp').innerHTML = "<label onClick=\"processTestResult('"+ aValue + "',this)\">" + stringfiedArray.replace(/\;/g,"</label><br /><label onClick=\"processTestResult('"+aValue+"',this)\">") + "</label>";

    }else{
      allTests[aValue] = 0;
      updateConfirmatoryInforBar();
    }
      
  }
}

function stringfyArray(arrayToStringfy, sort){
  stringfiedArray = "";
  if (sort == true){
    arrayToStringfy = arrayToStringfy.sort()
  }
  for (var i in arrayToStringfy){
    stringfiedArray += arrayToStringfy[i] + ";";
  }
  return stringfiedArray.replace(/\;$/,"");
}

function processMultiSelect(aElement){
  var finalString = "";
  if (aElement.innerHTML.search(/OTHER/) != -1 || aElement.innerHTML.search(/SPECIFY/) != -1){
    activatePopup('otherDiagnosisPopUp');
  }else{
    finalString = stringfyArray(tempDataArray,false) + " " + aElement.innerHTML;
    if (finalString.replace(/\;/g, " ") in objectConverter(mainDataArray)){
      $('duplicateWarning').style.display='block';
    }else{
      mainDataArray.push(finalString.replace(/\;/g, " ")); //remove colon from middle of stringfied tempDataArray
    }

    $('multiSelectPopUp').removeChild(aElement);
    showHeaders();
  }
}

function processOther(){
   if (stringfyArray(tempDataArray,false) + " " + $('other-diagnosis-inputbox').value in objectConverter(mainDataArray)){
      $('duplicateWarning').style.display='block';
    }else{
      mainDataArray.push(stringfyArray(tempDataArray,false) + " " + $('other-diagnosis-inputbox').value);
    }
  showHeaders();
}

function processTestResult(test,aElement){
  allTests[test] = aElement.innerHTML;
  updateConfirmatoryInforBar();
  hidePopUp('testResultPopUp');
}

function removeHiddenFormElements(elementsToRemove){
  if (elementsToRemove == 'diagnoses'){
    var hiddenElements = $('inpatient_diagnosis').getElementsByClassName('hiddenDiagnosis');
  }else{
    var hiddenElements = $('inpatient_diagnosis').getElementsByClassName('hiddenTests');
  }
  try{
    for (i in hiddenElements){
      $('inpatient_diagnosis').removeChild(hiddenElements[i]);
    }
  }catch(e){
    //do nothing
  }
}
