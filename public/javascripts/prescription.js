var drugs = {};

function updateFromKeyboard(aText){
    if (aText == null){
        $('drug-inputbox').value = $('drug-inputbox').value.slice(0, -1);
    }else{
        $('drug-inputbox').value = $('drug-inputbox').value + aText;
    }
}

function createKeyboardRow(aDivPosition, aRowValues){

    for (var i = 0; i < aRowValues.length; i++){
        var simpleButtonSpan = document.createElement('span');
        simpleButtonSpan.innerHTML = aRowValues[i];
    
        var simpleButton = document.createElement('button');
        simpleButton.className = 'simple-button';
        simpleButton.setAttribute("onClick", "updateFromKeyboard('" + aRowValues[i]+ "');updateDrugList('drug-select','drug-inputbox');");
    
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
    backSpaceButton.setAttribute("onClick", "updateFromKeyboard(null);updateDrugList('drug-select','drug-inputbox');");
  
    keyboardDivBottom.appendChild(backSpaceButton);
  
    backSpaceButton.appendChild(backSpace);
}
       
function createDiagnosesInfo(){
  $('diagnosesInfoBar').innerHTML = "";
  $("prescriptionInfoBar").innerHTML = "";
  
  for (i in currentDiagnoses){
       $('diagnosesInfoBar').innerHTML += i == activeDiagnosis ? "<span class='diagnosisSpan' id='diagnosisSpan' onClick='activeDiagnosis=this.innerHTML;createDiagnosesInfo();updateDrugList();'>" + i + "</span><br />" : "<span class='diagnosisSpan' onClick='activeDiagnosis=this.innerHTML;createDiagnosesInfo();updateDrugList();'>" + i + "</span><br />";
  }

  if (typeof(drugs[currentDiagnoses[activeDiagnosis]]) != 'undefined'){
    var observation = currentDiagnoses[activeDiagnosis];
    for (presc in drugs[observation]){
      $("prescriptionInfoBar").innerHTML = "<span onclick='$(\"prescriptionInfoBar\").removeChild(this); delete drugs[" + observation + "];' class='selections'>"+ drugs[observation][presc] +"<br /></span>" + $("prescriptionInfoBar").innerHTML;
    }
  }

  //updateDrugList();

}

function createDrugsPrescribed(){
   // initialiseDrugsHash();

    var  mainContainer = document.createElement('div');
    /*Create the main container div*/
    mainContainer.id = "diagnosis-container";
    mainContainer.className = "main-container";
    $("content").appendChild(mainContainer);

    var drugInfoBar = document.createElement("div");
    drugInfoBar.id = "drugInfoBar";
    drugInfoBar.className = "drugBarClass";
    mainContainer.appendChild(drugInfoBar);

     var diagnosesInfoBar =  document.createElement("div");
    diagnosesInfoBar.id = "diagnosesInfoBar";
    diagnosesInfoBar.className = "diagnosesInfoBar";
    drugInfoBar.appendChild(diagnosesInfoBar);

    var prescriptionInfoBar =  document.createElement("div");
    prescriptionInfoBar.id = "prescriptionInfoBar";
    prescriptionInfoBar.className = "prescriptionInfoBar";
    drugInfoBar.appendChild(prescriptionInfoBar);

    createDiagnosesInfo();
    
    /*Added Text Input*/
    var mainDiagnosisInputBox = document.createElement('input');
    mainDiagnosisInputBox.className = "drug-inputbox";
    mainDiagnosisInputBox.id = "drug-inputbox";
    mainDiagnosisInputBox.setAttribute("onKeyUp", "updateDrugList('drug-select','drug-inputbox');");
    mainContainer.appendChild(mainDiagnosisInputBox);

    createSimpleKeyboard();
    /*+++++++++++++++++++++++++Create the main diagnosis column*/
    var mainDiagnosis = document.createElement('div');
    mainDiagnosis.className = "diagnosis-columns";
    mainDiagnosis.id = "main-diagnosis";
  
    mainContainer.appendChild(mainDiagnosis);

    /*Add header*/
    var mainDiagnosisHeader = document.createElement('div');
    mainDiagnosisHeader.className = "diagnosis-headers";
    mainDiagnosisHeader.innerHTML = "<span>DRUG</span><span id='showAllSpan'><button id='showButton'><span>Show</span></button>All</span>";
    mainDiagnosis.appendChild(mainDiagnosisHeader);
    /*Input box div*/
    var mainDiagnosisInputBoxDiv = document.createElement('div');
    mainDiagnosisInputBoxDiv.className = "drug-inputbox-div";
    //mainDiagnosis.appendChild(mainDiagnosisInputBoxDiv);

    /*Select div*/
    var mainDiagnosisSelectDiv = document.createElement('div');
    mainDiagnosisSelectDiv.className = "drug-select-div";
    mainDiagnosis.appendChild(mainDiagnosisSelectDiv);

    /*Added Select*/
    var mainDiagnosisSelect = document.createElement('select');
    mainDiagnosisSelect.className = "drug-select";
    mainDiagnosisSelect.id = "drug-select";
    mainDiagnosisSelect.size = 10;
    mainDiagnosisSelectDiv.appendChild(mainDiagnosisSelect);
    //=================================================================
     /*+++++++++++++++++++++Create the dosage column*/
    var dosage = document.createElement('div');
    dosage.className = "diagnosis-columns";
    dosage.id = "dosage";

    mainContainer.appendChild(dosage);
    /*add sub diagnosis header*/
    var dosageHeader = document.createElement('div');
    dosageHeader.className = "diagnosis-headers";
    dosageHeader.innerHTML = "DOSAGE";
    dosage.appendChild(dosageHeader);
    //sub diagnosis notification area
    var dosageNotifyDiv = document.createElement('div');
    dosageNotifyDiv.className = "notify-div";
    dosageNotifyDiv.id = "dosage-notify";
    //subDiagnosis.appendChild(subDiagnosisNotifyDiv);


    /*Select div*/
    var dosageSelectDiv = document.createElement('div');
    dosageSelectDiv.className = "drug-select-div";
    dosage.appendChild(dosageSelectDiv);

    /*Added Select*/
    var dosageSelect = document.createElement('div');
    //durationSelect.className = "drug-select";
    dosageSelect.id = "dosage-div";
    dosageSelectDiv.appendChild(dosageSelect);

    /*Added Select
    var dosageSelect = document.createElement('select');
    dosageSelect.className = "drug-select";
    dosageSelect.id = "dosage-select";
    dosageSelect.size = 10;
    dosageSelectDiv.appendChild(dosageSelect); */

///////////////////////////////////////////////////////////


    /*+++++++++++++++++++++Create the sub diagnosis column*/
    var subDiagnosis = document.createElement('div');
    subDiagnosis.className = "diagnosis-columns";
    subDiagnosis.id = "sub-diagnosis";

    mainContainer.appendChild(subDiagnosis);
    /*add sub diagnosis header*/
    var subDiagnosisHeader = document.createElement('div');
    subDiagnosisHeader.className = "diagnosis-headers";
    subDiagnosisHeader.innerHTML = "FREQUENCY";
    subDiagnosis.appendChild(subDiagnosisHeader);
    //sub diagnosis notification area
    var subDiagnosisNotifyDiv = document.createElement('div');
    subDiagnosisNotifyDiv.className = "notify-div";
    subDiagnosisNotifyDiv.id = "subdiagnosis-notify";
    //subDiagnosis.appendChild(subDiagnosisNotifyDiv);


    /*Select div*/
    var subDiagnosisSelectDiv = document.createElement('div');
    subDiagnosisSelectDiv.className = "drug-select-div";
    subDiagnosis.appendChild(subDiagnosisSelectDiv);

    /*Added Select*/
    var subDiagnosisSelect = document.createElement('select');
    subDiagnosisSelect.className = "drug-select";
    subDiagnosisSelect.id = "frequency-select";
    subDiagnosisSelect.size = 10;
    subDiagnosisSelectDiv.appendChild(subDiagnosisSelect);


    /*+++++++++++++++++++++Create the sub sub diagnosis column*/
    var duration = document.createElement('div');
    duration.className = "diagnosis-columns";
    duration.id = "duration";
  
    mainContainer.appendChild(duration);

    /*add sub sub diagnosis header*/
    var durationHeader = document.createElement('div');
    durationHeader.className = "diagnosis-headers";
    durationHeader.innerHTML = "DURATION";
    duration.appendChild(durationHeader);
    //sub diagnosis notification area
    var subSubDiagnosisNotifyDiv = document.createElement('div');
    subSubDiagnosisNotifyDiv.className = "notify-div";
    subSubDiagnosisNotifyDiv.id = "sub-subdiagnosis-notify";
    //duration.appendChild(subSubDiagnosisNotifyDiv);


    /*Select div*/
    var durationSelectDiv = document.createElement('div');
    durationSelectDiv.className = "drug-select-div";
    durationSelectDiv.id = "duration-parent";
    duration.appendChild(durationSelectDiv);

    /*Added Select*/
    var durationSelect = document.createElement('div');
    //durationSelect.className = "drug-select";
    durationSelect.id = "duration-div";
    durationSelectDiv.appendChild(durationSelect);

    var durationValues = document.createElement('div');
    //durationSelect.className = "drug-select";
    durationValues.id = "duration-values";
    durationSelectDiv.appendChild(durationValues);
}

/*+++++++++++++++++Some ajax for updating lists*/
function handleHttpResponse(aElement) {
    if (http.readyState == 4 && http.status == 200) {
        if (aElement == 'drug-select'){
            $('drug-select').innerHTML = "<option onClick=updateDosage()>" +
            http.responseText.replace(/\;/g, "</option><option onClick=updateDosage()>") + "</option>";
        } else if (aElement == 'frequency'){
            $('frequency-select').innerHTML = "<option onClick=showMainRange()>" +
            http.responseText.replace(/,/g, "</option><option onClick=showMainRange()>") + "</option>";
        } else if (aElement == 'dosage'){
          var updateText = "<br />";
          var dosagesArray = http.responseText.split(',');
          for (var i in dosagesArray){
            updateText += "<label onClick='updateFrequency()'><input name='dosage' type='radio' value='" + dosagesArray[i] + "'>" + dosagesArray[i]+ "</label><br/>"; 
          }
          $('dosage-div').innerHTML = updateText;
        }
    }
}

function updateList(aUrl, aElement) {
 
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

function updateDrugList(){
  if(activeDiagnosis in commonPrescriptions){
    $('drug-select').innerHTML = "";
    for (drug in commonPrescriptions[activeDiagnosis]){
      $('drug-select').innerHTML += "<option onClick=updateDosageAndFrequency(this.innerHTML)>" + drug + "</option>";
    }
    //$('showAllSpan').style.display = "block";
  }else{
    var aElement = 'drug-select'
    $('frequency-select').innerHTML = "<option></option>";
    $('dosage-div').innerHTML = ""
    $('duration-div').innerHTML = ""
    $('duration-values').innerHTML = ""
    var searchString =  $('drug-inputbox').value;
    var aUrl = "/search/location_drugs?search_string=" + searchString;
    updateList(aUrl, 'drug-select');
    //$('showAllSpan').style.display = "none";
  }
}

function updateFrequency(){
    var aUrl = "/search/location_frequencies";
    updateList(aUrl, 'frequency');
    $('duration-div').innerHTML = "";
    $('duration-values').innerHTML = "";
}

function showMainRange(){
    var updateText = "";
    for (var min = 1; min < 92; min +=10){
        updateText += "<label><input name='mainrange' type='radio' value="+ eval(min) + " onClick=updateSubRange(" + min + ")>" + min + "-"+ eval(min+9) +"</label><br/>";
    }
    $('duration-div').innerHTML = updateText;
    $('duration-values').innerHTML = "";
}

function updateSubRange(minimum){
    var updateText = "";
    var maximum = minimum + 10
    for (var i = minimum; i < maximum; i++){
        updateText += "<label><input name='subRange' type='radio' value='"+ i +"' onclick='appendDrug()'>" + i +"</label><br/>";
    }
    $('duration-values').innerHTML = updateText
  
}

function appendDrug(){
    //var drug = $("drug-select")[$("drug-select").selectedIndex].innerHTML;
    var drug = $("drug-select").value;
    //var freq = $("frequency-select")[$("frequency-select").selectedIndex].innerHTML;
    var freq = $("frequency-select").value;
    var duration ="";
    var dosage = "";
    var checkedDos = document.getElementsByName("dosage");
    var rdos = document.getElementsByName("subRange");

    for(var i = 0; i < rdos.length; i++){
        if(rdos[i].checked){
            duration = rdos[i].value;
            break;
        }
    }

    for(var i = 0; i < checkedDos.length; i++){
        if(checkedDos[i].checked){
            dosage = checkedDos[i].value;
            break;
        }
    }


  if (typeof(drugs[currentDiagnoses[activeDiagnosis]]) == 'undefined'){
    drugs[currentDiagnoses[activeDiagnosis]] = [];
  }

    drugs[currentDiagnoses[activeDiagnosis]].push(drug + ':' + dosage + ':' + freq + ':' + duration);
  
    createDiagnosesInfo();

    updateFrequency();
}

function removeDrugsPrescribed(){

    for (diagnosis in drugs){
      for (prescription in drugs[diagnosis]){
        var obsId = document.createElement('input');
        obsId.name = 'prescriptions[][obs_id]';
        obsId.type = 'hidden';
        obsId.value = diagnosis;
        $('inpatient_prescriptions').appendChild(obsId);
      
        var drugName = document.createElement('input');
        drugName.name = 'prescriptions[][drug_name]';
        drugName.type = 'hidden';
        drugName.value = drugs[diagnosis][prescription].split(':')[0];
        $('inpatient_prescriptions').appendChild(drugName);

        var dosagePrescribed = document.createElement('input');
        dosagePrescribed.name = 'prescriptions[][dosage]';
        dosagePrescribed.type = 'hidden';
        dosagePrescribed.value = drugs[diagnosis][prescription].split(':')[1];
        $('inpatient_prescriptions').appendChild(dosagePrescribed);

        var frequency = document.createElement('input');
        frequency.name = 'prescriptions[][frequency]';
        frequency.type = 'hidden';
        frequency.value = drugs[diagnosis][prescription].split(':')[2];
        $('inpatient_prescriptions').appendChild(frequency);

        var duration = document.createElement('input');
        duration.name = 'prescriptions[][duration]';
        duration.type = 'hidden';
        duration.value = drugs[diagnosis][prescription].split(':')[3];
        $('inpatient_prescriptions').appendChild(duration);

        var orderType = document.createElement('input');
        orderType.name = 'prescriptions[][order_type]';
        orderType.type = 'hidden';
        orderType.value = 'Drug prescribed';
        $('inpatient_prescriptions').appendChild(orderType);
      }
    }


    
    
    $("content").removeChild($("diagnosis-container"));
}

function createDrugsGiven(){
    //window.location = ""
}

function updateDosage(){
  var selectedDrug =  $("drug-select")[$("drug-select").selectedIndex].innerHTML
  var aUrl = "/search/drug_dosages?selected_drug_name=" + selectedDrug;
  updateList(aUrl, 'dosage');
}

function updateDosageAndFrequency(aValue){
var dosage = commonPrescriptions[activeDiagnosis][aValue][0];
var frequency = commonPrescriptions[activeDiagnosis][aValue][1];

$('dosage-div').innerHTML = "<label><input name='dosage' type='radio' value='" + dosage + "' checked>" + dosage + "</label>"; 
$('frequency-select').innerHTML = "<option>" + frequency + "</option>";
$('frequency-select').value = frequency;
showMainRange();
}
