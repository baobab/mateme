var generics = [];
var dosages = {};
var frequencies = [];
var drugslist = {};
var previous_clicked = null;

var current_concept_id = null;

var removal_target = null;

var timerTime = 300;

// var current_patient_id = null;

// This function exists in the TouchScreenToolkit but repeated here in case it's
// not referenced
function __$(id){
    return document.getElementById(id);
}
    
function init(){
    generics = generic_drugs;
    dosages = drug_dosages;
    drugslist = drugs;
   
    frequencies = {
        "OD":"Once a day (OD)",
        "BD":"Twice a day (BD)",
        "TDS":"Three a day (TDS)",  
        "QID":"Four times a day (QID)", 
        "5X/D":"Five times a day (5X/D)",
        "5XD":"Five times a day (5XD)",  
        "Q4HRS":"Six times a day (Q4HRS)", 
        "NOCTE":"Once a day at night (NOCTE)",
        "QAM":"In the morning (QAM)", 
        "QHS":"Once a day at night (QHS)",
        "QNOON":"Once a day at noon (QNOON)", 
        "QOD":"Every other day (QOD)", 
        "QPM":"In the evening (QPM)", 
        "QWK":"Once a week (QWK)"
    }
    
    generateGenerics();
}

// Create the interface
function generateGenerics(patient_id){
    current_patient_id = patient_id;
    
    generics = generic_drugs;
    dosages = drug_dosages;
    drugslist = drugs;
   
    frequencies = {
        "OD":"Once a day (OD)",
        "BD":"Twice a day (BD)",
        "TDS":"Three a day (TDS)",  
        "QID":"Four times a day (QID)", 
        "5X/D":"Five times a day (5X/D)",
        "5XD":"Five times a day (5XD)",  
        "Q4HRS":"Six times a day (Q4HRS)", 
        "NOCTE":"Once a day at night (NOCTE)",
        "QAM":"In the morning (QAM)", 
        "QHS":"Once a day at night (QHS)",
        "QNOON":"Once a day at noon (QNOON)", 
        "QOD":"Every other day (QOD)", 
        "QPM":"In the evening (QPM)", 
        "QWK":"Once a week (QWK)"
    }
    
    if(__$("parent_container")){
        __$("content").removeChild(__$("parent_container"));
    }

    if(__$("clearButton")){
        __$("clearButton").style.display = "none";
    }

    var parent_container = document.createElement("div");
    parent_container.id = "parent_container";
    parent_container.style.position = "absolute";
    parent_container.style.marginLeft = "-500px";
    parent_container.style.marginTop = "-358px";
    parent_container.style.top = "50%";
    parent_container.style.left = "50%";
    parent_container.style.height = "630px";
    parent_container.style.width = "1000px";
    parent_container.style.overflow = "hidden";
    parent_container.style.zIndex = "20";
    parent_container.style.backgroundColor = "#FFFFFF";

    __$("content").appendChild(parent_container);

    var mainDiv = document.createElement("div");
    mainDiv.id = "mainDiv";
    mainDiv.style.width = "960px";
    mainDiv.style.height = "590px";
    mainDiv.style.margin = "10px";

    parent_container.appendChild(mainDiv);

    var topBannerDiv = document.createElement("div");
    topBannerDiv.style.width = "101%";
    topBannerDiv.style.height = "8%";
    topBannerDiv.style.backgroundColor = "#fff";
    topBannerDiv.style.cssFloat = "left";
    //topBannerDiv.style.border = "1px solid #ccc";
    topBannerDiv.style.paddingTop = "10px";
    topBannerDiv.style.paddingLeft = "10px";
    topBannerDiv.innerHTML = "Select Treatment Details";
    topBannerDiv.style.fontSize = "1.8em";

    mainDiv.appendChild(topBannerDiv);

    // Selection area for Diagnoses    
    var diagnoses = document.createElement("select");
    diagnoses.id = "diagnoses";
    diagnoses.style.fontSize = "1em";
    diagnoses.style.width = "580px";
    diagnoses.style.cssFloat = "right";
    diagnoses.style.border = "1px solid #ccc";
    diagnoses.style.backgroundColor = "lightyellow";
    diagnoses.style.padding = "5px";
    diagnoses.style.top = "12px";
    diagnoses.style.right = "12px";
    diagnoses.style.position = "absolute";
    diagnoses.style.display = "none";

    topBannerDiv.appendChild(diagnoses);

    var inputTxt = document.createElement("input");
    inputTxt.type = "text";
    inputTxt.id = "inputTxt";
    inputTxt.style.width = "100%";
    inputTxt.style.fontSize = "1.8em";
    inputTxt.style.padding = "5px";
    inputTxt.style.backgroundColor = "#eee";
    inputTxt.style.marginLeft = "5px";

    mainDiv.appendChild(inputTxt);

    var detailsDiv = document.createElement("div");
    detailsDiv.style.width = "100%";
    detailsDiv.style.height = "84%";
    detailsDiv.style.marginLeft = "4px";
    detailsDiv.style.marginTop = "4px";
    detailsDiv.style.backgroundColor = "#fff";
    detailsDiv.style.border = "1px solid #ccc";
    detailsDiv.style.padding = "5px";

    mainDiv.appendChild(detailsDiv);

    var freqsDosePeriodDiv = document.createElement("div");
    freqsDosePeriodDiv.style.width = "72.5%";
    freqsDosePeriodDiv.style.height = "99%";
    freqsDosePeriodDiv.style.marginLeft = "2px";
    freqsDosePeriodDiv.style.marginTop = "2px";
    freqsDosePeriodDiv.style.backgroundColor = "#fff";
    freqsDosePeriodDiv.style.border = "1px solid #ccc";
    freqsDosePeriodDiv.style.padding = "0px";
    freqsDosePeriodDiv.style.cssFloat = "left";

    detailsDiv.appendChild(freqsDosePeriodDiv);

    var drugsDiv = document.createElement("div");
    drugsDiv.style.width = "25%";
    drugsDiv.style.height = "99%";
    drugsDiv.style.marginLeft = "2px";
    drugsDiv.style.marginTop = "2px";
    drugsDiv.style.backgroundColor = "#fff";
    drugsDiv.style.border = "1px solid #ccc";
    drugsDiv.style.padding = "0px";
    drugsDiv.style.cssFloat = "right";

    detailsDiv.appendChild(drugsDiv);

    var drugsTopicDiv = document.createElement("div");
    drugsTopicDiv.style.fontSize = "1.5em";
    drugsTopicDiv.style.height = "32px";
    drugsTopicDiv.style.padding = "5px";
    drugsTopicDiv.innerHTML = "Drug";
    drugsTopicDiv.style.backgroundColor = "#999";
    drugsTopicDiv.style.textAlign = "left";
    drugsTopicDiv.style.color = "#eee";

    drugsDiv.appendChild(drugsTopicDiv);

    var doseDiv = document.createElement("div");
    doseDiv.style.width = "100%";
    doseDiv.style.height = "49%";
    doseDiv.style.backgroundColor = "#fff";
    doseDiv.style.borderRight = "1px solid #ccc";
    doseDiv.style.padding = "0px";
    doseDiv.style.cssFloat = "left";

    freqsDosePeriodDiv.appendChild(doseDiv);

    var doseTopicDiv = document.createElement("div");
    doseTopicDiv.style.fontSize = "1.5em";
    doseTopicDiv.style.height = "32px";
    doseTopicDiv.style.padding = "5px";
    doseTopicDiv.innerHTML = "Selected Drugs";
    doseTopicDiv.style.backgroundColor = "#999";
    doseTopicDiv.style.textAlign = "left";
    doseTopicDiv.style.color = "#eee";

    doseDiv.appendChild(doseTopicDiv);

    var doseListDiv = document.createElement("div");
    doseListDiv.style.fontSize = "1.5em";
    doseListDiv.style.height = "79%";
    doseListDiv.style.padding = "5px";
    doseListDiv.style.overflow = "auto";
    doseListDiv.style.backgroundColor = "#fff";

    doseDiv.appendChild(doseListDiv);

    var keyboardDiv = document.createElement("div");
    keyboardDiv.style.width = "99.7%";
    keyboardDiv.style.height = "50.5%";
    keyboardDiv.style.backgroundColor = "#fff";
    keyboardDiv.style.borderTop = "1px solid #ccc";
    keyboardDiv.style.padding = "0px";
    keyboardDiv.style.cssFloat = "left";
    keyboardDiv.id = "keyboardDiv";

    freqsDosePeriodDiv.appendChild(keyboardDiv);

    var drugsListDiv = document.createElement("div");
    drugsListDiv.style.fontSize = "1.5em";
    drugsListDiv.style.height = "89.5%";
    drugsListDiv.style.padding = "5px";
    drugsListDiv.style.overflow = "auto";
    drugsListDiv.style.backgroundColor = "#fff";

    drugsDiv.appendChild(drugsListDiv);

    var ulDrugs = document.createElement("ul");
    ulDrugs.id = "ulDrugs";
    ulDrugs.style.fontSize = "1.0em";
    ulDrugs.style.listStyle = "none";
    ulDrugs.style.padding = "0px";

    drugsListDiv.appendChild(ulDrugs);

    var ulDoses = document.createElement("ul");
    ulDoses.id = "ulDoses";
    ulDoses.style.fontSize = "1.0em";
    ulDoses.style.listStyle = "none";
    ulDoses.style.padding = "0px";

    doseListDiv.appendChild(ulDoses);

    showFixedKeyboard(__$("keyboardDiv"), "inputTxt");

    searchDrug();   
    
    if(__$("clearButton")){
        __$("clearButton").style.display = "block";
    
        __$("clearButton").onmousedown = function(){
            clearTextInput();
        }
    }
}

/*
 * This method filters the search list to accomodate only those that are similar
 * to the typed text
 * 
 */
function searchDrug(){
    var search_term = "";
    __$("ulDrugs").innerHTML = "";
    
    if(__$("inputTxt").value.trim().length > 0){
        search_term = __$("inputTxt").value.trim()
    }
        
    // Create Generic Drugs list
    for(var d = 0; d < generics.length; d++){
        if(search_term != ""){
            if(!generics[d][0].toLowerCase().match(search_term.toLowerCase())){
                continue;
            }
        }
        
        var li = document.createElement("li");
        li.id = "option" + generics[d][0];
        li.innerHTML = generics[d][0];
        li.style.padding = "15px";

        if(d%2>0){
            li.style.backgroundColor = "#eee";
            li.setAttribute("tag", "#eee");
        } else {            
            li.setAttribute("tag", "#fff");
        }

        li.setAttribute("concept_id", generics[d][1])

        li.onclick = function(){    
            highlightSelected(__$("ulDrugs"), this);
            
            current_concept_id = __$(this.id).getAttribute("concept_id");
            
            __$("inputTxt").value = this.innerHTML;
            askFormulation();
        }

        __$("ulDrugs").appendChild(li);
    }
}

function highlightSelected(parent, control){
    for(var i = 0; i < parent.children.length; i++){
        if(i % 2 > 0){
            parent.children[i].style.backgroundColor = "#eee";
        } else {
            parent.children[i].style.backgroundColor = "#fff";
        }
    }
    if(control){
        control.style.backgroundColor = "lightblue";
    }
}

function checkState(button, control){
    if(control){
        if(control.value.trim().length > 0){
            button.className = "button blue";
        } else {
            button.className = "button gray";
        }
        setTimeout("checkState(__$(\"" + button.id + "\"), __$(\"" + control.id + "\"))", timerTime);
    }
}

function askFormulation(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.4;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        divShield.className = "no-selection";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 101; 
    __$("divShield").style.display = "block";
    
    var question = document.createElement("div");
    question.id = "dosageQuestion";
    question.style.position = "absolute";
    question.style.left = "80px";
    question.style.top = "80px";
    question.style.width = "600px";
    question.style.height = "400px";
    question.style.backgroundColor = "#fff";
    //question.style.border = "1px solid #000";
    question.style.zIndex = 101;
    question.className = "dialog  no-selection";
    
    __$("content").appendChild(question);
    
    var cancelImg = document.createElement("img");
    cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
    cancelImg.setAttribute("alt", "X");
    cancelImg.style.cssFloat = "right";
    cancelImg.style.margin = "-65px";
    cancelImg.style.marginTop = "-65px";
    cancelImg.style.cursor = "pointer";
    cancelImg.onclick = function(){
        closePopUps();
    }
    
    question.appendChild(cancelImg);
    
    var qtbl = document.createElement("div");
    qtbl.className = "table";
    
    question.appendChild(qtbl);
    
    var qtblrow1 = document.createElement("div");
    qtblrow1.className = "row";
    
    qtbl.appendChild(qtblrow1);
    
    var qtblcell1_1 = document.createElement("div");
    qtblcell1_1.className = "cell";
    qtblcell1_1.innerHTML = "Select Drug Formulation";
    
    qtblrow1.appendChild(qtblcell1_1);
    
    var qtblrow2 = document.createElement("div");
    qtblrow2.className = "row";
    
    qtbl.appendChild(qtblrow2);
    
    var qtblcell2_1 = document.createElement("div");
    qtblcell2_1.className = "cell";
    qtblcell2_1.innerHTML = "<input type='text' id='editDosage' value='' class='inputBox' />";
    
    qtblrow2.appendChild(qtblcell2_1);
    
    var qtblrow3 = document.createElement("div");
    qtblrow3.className = "row";
    
    qtbl.appendChild(qtblrow3);
    
    var qtblcell3_1 = document.createElement("div");
    qtblcell3_1.className = "cell";
    qtblcell3_1.innerHTML = "<ul id='ulDosages' class='popup'></ul>";
    
    qtblrow3.appendChild(qtblcell3_1);

    var f = 0;
    for(var dose in drugslist[current_concept_id]){
        var li = document.createElement("li");
        li.innerHTML = dose; //drugslist[current_concept_id][dose];
        li.setAttribute("strength", drugslist[current_concept_id][dose][0]);
        li.setAttribute("units", drugslist[current_concept_id][dose][1]);
        
        if(f % 2 > 0){
            li.className = "oddf";
        }
        
        li.onclick = function(){
            highlightSelected(__$("ulDosages"), this);
            
            __$("editDosage").value = this.innerHTML;
            __$("editDosage").setAttribute("strength", this.getAttribute("strength"));
            __$("editDosage").setAttribute("units", this.getAttribute("units"));
        }
        
        __$("ulDosages").appendChild(li);
        
        f++;
    }
    
    var qtblrow4 = document.createElement("div");
    qtblrow4.className = "row";
    
    qtbl.appendChild(qtblrow4);
    
    var qtblcell4_1 = document.createElement("div");
    qtblcell4_1.className = "cell";
    
    qtblrow4.appendChild(qtblcell4_1);
    
    var btnBack = document.createElement("button");
    btnBack.className = "button red";
    btnBack.innerHTML = "<span>Cancel</span>";
    btnBack.style.cssFloat = "left";
    btnBack.onclick = function(){
        closePopUps();
    }
    
    qtblcell4_1.appendChild(btnBack);
    
    var btnForward = document.createElement("button");
    btnForward.className = "button gray";
    btnForward.innerHTML = "<span>Forward</span>";
    btnForward.style.cssFloat = "right";
    btnForward.id = "btnForwardDosage";
    btnForward.onclick = function(){
        if(this.className == "button gray"){
            showMessage("Please select a value first", false, false)
        } else {
            askPrescriptionType();            
        }
    }
    
    qtblcell4_1.appendChild(btnForward);
    
    setTimeout("checkState(__$(\"btnForwardDosage\"), __$(\"editDosage\"))", timerTime);
}

function askPrescriptionType(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.6;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 102; 
    __$("divShield").style.display = "block";
    
    if(!__$("prescriptionQuestion")){
        var question = document.createElement("div");
        question.id = "prescriptionQuestion";
        question.style.position = "absolute";
        question.style.left = "110px";
        question.style.top = "110px";
        question.style.width = "600px";
        question.style.height = "400px";
        question.style.backgroundColor = "#fff";
        //question.style.border = "1px solid #000";
        question.style.zIndex = 102;
        question.className = "dialog  no-selection";
    
        __$("content").appendChild(question);
    
        var cancelImg = document.createElement("img");
        cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
        cancelImg.setAttribute("alt", "X");
        cancelImg.style.cssFloat = "right";
        cancelImg.style.margin = "-65px";
        cancelImg.style.marginTop = "-65px";
        cancelImg.style.cursor = "pointer";
        cancelImg.onclick = function(){
            closePopUps();
        }
    
        question.appendChild(cancelImg);
    
        var qtbl = document.createElement("div");
        qtbl.className = "table";
    
        question.appendChild(qtbl);
    
        var qtblrow1 = document.createElement("div");
        qtblrow1.className = "row";
    
        qtbl.appendChild(qtblrow1);
    
        var qtblcell1_1 = document.createElement("div");
        qtblcell1_1.className = "cell";
        qtblcell1_1.innerHTML = "Type of Prescription";
    
        qtblrow1.appendChild(qtblcell1_1);
    
        var qtblrow2 = document.createElement("div");
        qtblrow2.className = "row";
    
        qtbl.appendChild(qtblrow2);
    
        var qtblcell2_1 = document.createElement("div");
        qtblcell2_1.className = "cell";
        qtblcell2_1.innerHTML = "<input type='text' id='editPrescriptionType' value='' class='inputBox' />";
    
        qtblrow2.appendChild(qtblcell2_1);
    
        var qtblrow3 = document.createElement("div");
        qtblrow3.className = "row";
    
        qtbl.appendChild(qtblrow3);
    
        var qtblcell3_1 = document.createElement("div");
        qtblcell3_1.className = "cell";
        qtblcell3_1.innerHTML = "<ul id='ulPrescriptionType' class='popup'><li>" + 
        "Standard</li><li class='oddf'>Variable</li><li>Stat Dose</li></ul>";
    
        qtblrow3.appendChild(qtblcell3_1);
            
        for(var li in __$("ulPrescriptionType").children){            
            __$("ulPrescriptionType").children[li].onclick = function(){
                highlightSelected(__$("ulPrescriptionType"), this);
            
                __$("editPrescriptionType").value = this.innerHTML;
                
                if(this.innerHTML == "Stat Dose"){
                    __$("btnForwardPrescriptionType").innerHTML = "<span>Done</span>";
                } else {
                    __$("btnForwardPrescriptionType").innerHTML = "<span>Forward</span>";
                }
            }       
        }
            
        var qtblrow4 = document.createElement("div");
        qtblrow4.className = "row";
    
        qtbl.appendChild(qtblrow4);
    
        var qtblcell4_1 = document.createElement("div");
        qtblcell4_1.className = "cell";
    
        qtblrow4.appendChild(qtblcell4_1);
    
        var btnForward = document.createElement("button");
        btnForward.className = "button gray";
        btnForward.innerHTML = "<span>Forward</span>";
        btnForward.style.cssFloat = "right";
        btnForward.id = "btnForwardPrescriptionType";
        btnForward.onclick = function(){
            if(this.className == "button gray"){
                showMessage("Please select a value first", false, false)
            } else {
                if(__$("btnForwardPrescriptionType").innerHTML == "<span>Done</span>"){
                    processDrug(current_concept_id, "true");
                } else if(__$("editPrescriptionType").value == "Variable"){
                    askMorningDose();
                } else {
                    askDoseStrength();
                }   
            }
        }
    
        qtblcell4_1.appendChild(btnForward);
        var btnBack = document.createElement("button");
        btnBack.className = "button";
        btnBack.innerHTML = "<span>Back</span>";
        btnBack.style.cssFloat = "right";
        btnBack.onclick = function(){
            __$("prescriptionQuestion").style.display = "none";
            __$("divShield").style.zIndex = 101;
        }
    
        qtblcell4_1.appendChild(btnBack);
    
        var btnCancel = document.createElement("button");
        btnCancel.className = "button red";
        btnCancel.innerHTML = "<span>Cancel</span>";
        btnCancel.style.cssFloat = "left";
        btnCancel.onclick = function(){
            closePopUps();
        }
    
        qtblcell4_1.appendChild(btnCancel);
    
    } else {
        highlightSelected(__$("ulPrescriptionType"));
        __$("prescriptionQuestion").style.display = "block";
        __$("editPrescriptionType").value = "";
    }
    
    setTimeout("checkState(__$(\"btnForwardPrescriptionType\"), __$(\"editPrescriptionType\"))", timerTime);
}

function askMorningDose(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.6;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 104; 
    __$("divShield").style.display = "block";
    
    if(!__$("morningQuestion")){
        var question = document.createElement("div");
        question.id = "morningQuestion";
        question.style.position = "absolute";
        question.style.left = "140px";
        question.style.top = "140px";
        question.style.width = "390px";
        question.style.height = "420px";
        question.style.backgroundColor = "#fff";
        question.style.zIndex = 104;
        question.className = "dialog  no-selection";
    
        __$("content").appendChild(question);
    
        var cancelImg = document.createElement("img");
        cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
        cancelImg.setAttribute("alt", "X");
        cancelImg.style.cssFloat = "right";
        cancelImg.style.margin = "-65px";
        cancelImg.style.marginTop = "-65px";
        cancelImg.style.cursor = "pointer";
        cancelImg.onclick = function(){
            closePopUps();
        }
    
        question.appendChild(cancelImg);
    
        var qtbl = document.createElement("div");
        qtbl.className = "table";
    
        question.appendChild(qtbl);
    
        var qtblrow1 = document.createElement("div");
        qtblrow1.className = "row";
    
        qtbl.appendChild(qtblrow1);
    
        var qtblcell1_1 = document.createElement("div");
        qtblcell1_1.className = "cell";
        qtblcell1_1.innerHTML = "Morning Dose Strength";
    
        qtblrow1.appendChild(qtblcell1_1);
    
        var qtblrow2 = document.createElement("div");
        qtblrow2.className = "row";
    
        qtbl.appendChild(qtblrow2);
    
        var qtblcell2_1 = document.createElement("div");
        qtblcell2_1.className = "cell";
        qtblcell2_1.innerHTML = "<input type='text' id='editMorningDose' value='' class='inputBox' />";
    
        qtblrow2.appendChild(qtblcell2_1);
    
        var qtblrow3 = document.createElement("div");
        qtblrow3.className = "row";
    
        qtbl.appendChild(qtblrow3);
    
        var qtblcell3_1 = document.createElement("div");
        qtblcell3_1.className = "cell";
        qtblcell3_1.id = "ulMorningDose";
        // qtblcell3_1.style.paddingLeft = "60px";
    
        qtblrow3.appendChild(qtblcell3_1);
    
        showNumber("ulMorningDose", "editMorningDose", true);
    
        var qtblrow4 = document.createElement("div");
        qtblrow4.className = "row";
    
        qtbl.appendChild(qtblrow4);
    
        var qtblcell4_1 = document.createElement("div");
        qtblcell4_1.className = "cell";
    
        qtblrow4.appendChild(qtblcell4_1);
    
        var btnForward = document.createElement("button");
        btnForward.className = "button gray";
        btnForward.innerHTML = "<span>Forward</span>";
        btnForward.style.cssFloat = "right";
        btnForward.id = "btnForwardMorningDose";
        btnForward.onclick = function(){
            if(this.className == "button gray"){
                showMessage("Please enter a value first", false, false)
            } else {            
                askAfternoonDose();
            }
        }
    
        qtblcell4_1.appendChild(btnForward);
        var btnBack = document.createElement("button");
        btnBack.className = "button";
        btnBack.innerHTML = "<span>Back</span>";
        btnBack.style.cssFloat = "right";
        btnBack.onclick = function(){
            __$("morningQuestion").style.display = "none";
            __$("divShield").style.zIndex = 102;
        }
    
        qtblcell4_1.appendChild(btnBack);
    
        var btnCancel = document.createElement("button");
        btnCancel.className = "button red";
        btnCancel.innerHTML = "<span>Cancel</span>";
        btnCancel.style.cssFloat = "left";
        btnCancel.onclick = function(){
            closePopUps();
        }
    
        qtblcell4_1.appendChild(btnCancel);
    
    } else {
        __$("morningQuestion").style.display = "block";
        __$("editMorningDose").value = "";
    }
    
    updateDosage("ulMorningDose");
    
    setTimeout("checkState(__$(\"btnForwardMorningDose\"), __$(\"editMorningDose\"))", timerTime);
}

function askAfternoonDose(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.6;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 105; 
    __$("divShield").style.display = "block";
    
    if(!__$("afternoonQuestion")){
        var question = document.createElement("div");
        question.id = "afternoonQuestion";
        question.style.position = "absolute";
        question.style.left = "170px";
        question.style.top = "170px";
        question.style.width = "390px";
        question.style.height = "420px";
        question.style.backgroundColor = "#fff";
        question.style.zIndex = 105;
        question.className = "dialog  no-selection";
    
        __$("content").appendChild(question);
    
        var cancelImg = document.createElement("img");
        cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
        cancelImg.setAttribute("alt", "X");
        cancelImg.style.cssFloat = "right";
        cancelImg.style.margin = "-65px";
        cancelImg.style.marginTop = "-65px";
        cancelImg.style.cursor = "pointer";
        cancelImg.onclick = function(){
            closePopUps();
        }
    
        question.appendChild(cancelImg);
    
        var qtbl = document.createElement("div");
        qtbl.className = "table";
    
        question.appendChild(qtbl);
    
        var qtblrow1 = document.createElement("div");
        qtblrow1.className = "row";
    
        qtbl.appendChild(qtblrow1);
    
        var qtblcell1_1 = document.createElement("div");
        qtblcell1_1.className = "cell";
        qtblcell1_1.innerHTML = "Afternoon Dose Strength";
    
        qtblrow1.appendChild(qtblcell1_1);
    
        var qtblrow2 = document.createElement("div");
        qtblrow2.className = "row";
    
        qtbl.appendChild(qtblrow2);
    
        var qtblcell2_1 = document.createElement("div");
        qtblcell2_1.className = "cell";
        qtblcell2_1.innerHTML = "<input type='text' id='editAfternoonDose' value='' class='inputBox' />";
    
        qtblrow2.appendChild(qtblcell2_1);
    
        var qtblrow3 = document.createElement("div");
        qtblrow3.className = "row";
    
        qtbl.appendChild(qtblrow3);
    
        var qtblcell3_1 = document.createElement("div");
        qtblcell3_1.className = "cell";
        qtblcell3_1.id = "ulAfternoonDose";
        // qtblcell3_1.style.paddingLeft = "60px";
    
        qtblrow3.appendChild(qtblcell3_1);
    
        showNumber("ulAfternoonDose", "editAfternoonDose", true);
    
        var qtblrow4 = document.createElement("div");
        qtblrow4.className = "row";
    
        qtbl.appendChild(qtblrow4);
    
        var qtblcell4_1 = document.createElement("div");
        qtblcell4_1.className = "cell";
    
        qtblrow4.appendChild(qtblcell4_1);
    
        var btnForward = document.createElement("button");
        btnForward.className = "button gray";
        btnForward.innerHTML = "<span>Forward</span>";
        btnForward.style.cssFloat = "right";
        btnForward.id = "btnForwardAfternoonDose";
        btnForward.onclick = function(){
            if(this.className == "button gray"){
                showMessage("Please enter a value first", false, false)
            } else {            
                askEveningDose();
            }
        }
    
        qtblcell4_1.appendChild(btnForward);
        var btnBack = document.createElement("button");
        btnBack.className = "button";
        btnBack.innerHTML = "<span>Back</span>";
        btnBack.style.cssFloat = "right";
        btnBack.onclick = function(){
            __$("afternoonQuestion").style.display = "none";
            __$("divShield").style.zIndex = 104;
        }
    
        qtblcell4_1.appendChild(btnBack);
    
        var btnCancel = document.createElement("button");
        btnCancel.className = "button red";
        btnCancel.innerHTML = "<span>Cancel</span>";
        btnCancel.style.cssFloat = "left";
        btnCancel.onclick = function(){
            closePopUps();
        }
    
        qtblcell4_1.appendChild(btnCancel);
    
    } else {
        __$("afternoonQuestion").style.display = "block";
        __$("editAfternoonDose").value = "";
    }
    
    updateDosage("ulAfternoonDose");
    
    setTimeout("checkState(__$(\"btnForwardAfternoonDose\"), __$(\"editAfternoonDose\"))", timerTime);
}

function askEveningDose(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.6;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 106; 
    __$("divShield").style.display = "block";
    
    if(!__$("eveningQuestion")){
        var question = document.createElement("div");
        question.id = "eveningQuestion";
        question.style.position = "absolute";
        question.style.left = "200px";
        question.style.top = "200px";
        question.style.width = "390px";
        question.style.height = "420px";
        question.style.backgroundColor = "#fff";
        question.style.zIndex = 106;
        question.className = "dialog  no-selection";
    
        __$("content").appendChild(question);
    
        var cancelImg = document.createElement("img");
        cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
        cancelImg.setAttribute("alt", "X");
        cancelImg.style.cssFloat = "right";
        cancelImg.style.margin = "-65px";
        cancelImg.style.marginTop = "-65px";
        cancelImg.style.cursor = "pointer";
        cancelImg.onclick = function(){
            closePopUps();
        }
    
        question.appendChild(cancelImg);
    
        var qtbl = document.createElement("div");
        qtbl.className = "table";
    
        question.appendChild(qtbl);
    
        var qtblrow1 = document.createElement("div");
        qtblrow1.className = "row";
    
        qtbl.appendChild(qtblrow1);
    
        var qtblcell1_1 = document.createElement("div");
        qtblcell1_1.className = "cell";
        qtblcell1_1.innerHTML = "Evening Dose Strength";
    
        qtblrow1.appendChild(qtblcell1_1);
    
        var qtblrow2 = document.createElement("div");
        qtblrow2.className = "row";
    
        qtbl.appendChild(qtblrow2);
    
        var qtblcell2_1 = document.createElement("div");
        qtblcell2_1.className = "cell";
        qtblcell2_1.innerHTML = "<input type='text' id='editEveningDose' value='' class='inputBox' />";
    
        qtblrow2.appendChild(qtblcell2_1);
    
        var qtblrow3 = document.createElement("div");
        qtblrow3.className = "row";
    
        qtbl.appendChild(qtblrow3);
    
        var qtblcell3_1 = document.createElement("div");
        qtblcell3_1.className = "cell";
        qtblcell3_1.id = "ulEveningDose";
        // qtblcell3_1.style.paddingLeft = "60px";
    
        qtblrow3.appendChild(qtblcell3_1);
    
        showNumber("ulEveningDose", "editEveningDose", true);
    
        var qtblrow4 = document.createElement("div");
        qtblrow4.className = "row";
    
        qtbl.appendChild(qtblrow4);
    
        var qtblcell4_1 = document.createElement("div");
        qtblcell4_1.className = "cell";
    
        qtblrow4.appendChild(qtblcell4_1);
    
        var btnForward = document.createElement("button");
        btnForward.className = "button gray";
        btnForward.innerHTML = "<span>Forward</span>";
        btnForward.style.cssFloat = "right";
        btnForward.id = "btnForwardEveningDose";
        btnForward.onclick = function(){
            if(this.className == "button gray"){
                showMessage("Please enter a value first", false, false)
            } else {            
                askNightDose();
            }
        }
    
        qtblcell4_1.appendChild(btnForward);
        var btnBack = document.createElement("button");
        btnBack.className = "button";
        btnBack.innerHTML = "<span>Back</span>";
        btnBack.style.cssFloat = "right";
        btnBack.onclick = function(){
            __$("eveningQuestion").style.display = "none";
            __$("divShield").style.zIndex = 105;
        }
    
        qtblcell4_1.appendChild(btnBack);
    
        var btnCancel = document.createElement("button");
        btnCancel.className = "button red";
        btnCancel.innerHTML = "<span>Cancel</span>";
        btnCancel.style.cssFloat = "left";
        btnCancel.onclick = function(){
            closePopUps();
        }
    
        qtblcell4_1.appendChild(btnCancel);
    
    } else {
        __$("eveningQuestion").style.display = "block";
        __$("editEveningDose").value = "";
    }
    
    updateDosage("ulEveningDose");
    
    setTimeout("checkState(__$(\"btnForwardEveningDose\"), __$(\"editEveningDose\"))", timerTime);
}

function askNightDose(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.6;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 107; 
    __$("divShield").style.display = "block";
    
    if(!__$("nightQuestion")){
        var question = document.createElement("div");
        question.id = "nightQuestion";
        question.style.position = "absolute";
        question.style.left = "230px";
        question.style.top = "230px";
        question.style.width = "390px";
        question.style.height = "420px";
        question.style.backgroundColor = "#fff";
        question.style.zIndex = 107;
        question.className = "dialog  no-selection";
    
        __$("content").appendChild(question);
    
        var cancelImg = document.createElement("img");
        cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
        cancelImg.setAttribute("alt", "X");
        cancelImg.style.cssFloat = "right";
        cancelImg.style.margin = "-65px";
        cancelImg.style.marginTop = "-65px";
        cancelImg.style.cursor = "pointer";
        cancelImg.onclick = function(){
            closePopUps();
        }
    
        question.appendChild(cancelImg);
    
        var qtbl = document.createElement("div");
        qtbl.className = "table";
    
        question.appendChild(qtbl);
    
        var qtblrow1 = document.createElement("div");
        qtblrow1.className = "row";
    
        qtbl.appendChild(qtblrow1);
    
        var qtblcell1_1 = document.createElement("div");
        qtblcell1_1.className = "cell";
        qtblcell1_1.innerHTML = "Night Dose Strength";
    
        qtblrow1.appendChild(qtblcell1_1);
    
        var qtblrow2 = document.createElement("div");
        qtblrow2.className = "row";
    
        qtbl.appendChild(qtblrow2);
    
        var qtblcell2_1 = document.createElement("div");
        qtblcell2_1.className = "cell";
        qtblcell2_1.innerHTML = "<input type='text' id='editNightDose' value='' class='inputBox' />";
    
        qtblrow2.appendChild(qtblcell2_1);
    
        var qtblrow3 = document.createElement("div");
        qtblrow3.className = "row";
    
        qtbl.appendChild(qtblrow3);
    
        var qtblcell3_1 = document.createElement("div");
        qtblcell3_1.className = "cell";
        qtblcell3_1.id = "ulNightDose";
        // qtblcell3_1.style.paddingLeft = "60px";
    
        qtblrow3.appendChild(qtblcell3_1);
    
        showNumber("ulNightDose", "editNightDose", true);
    
        var qtblrow4 = document.createElement("div");
        qtblrow4.className = "row";
    
        qtbl.appendChild(qtblrow4);
    
        var qtblcell4_1 = document.createElement("div");
        qtblcell4_1.className = "cell";
    
        qtblrow4.appendChild(qtblcell4_1);
    
        var btnForward = document.createElement("button");
        btnForward.className = "button gray";
        btnForward.innerHTML = "<span>Forward</span>";
        btnForward.style.cssFloat = "right";
        btnForward.id = "btnForwardNightDose";
        btnForward.onclick = function(){
            if(this.className == "button gray"){
                showMessage("Please enter a value first", false, false)
            } else {            
                askDuration();
            }
        }
    
        qtblcell4_1.appendChild(btnForward);
        var btnBack = document.createElement("button");
        btnBack.className = "button";
        btnBack.innerHTML = "<span>Back</span>";
        btnBack.style.cssFloat = "right";
        btnBack.onclick = function(){
            __$("nightQuestion").style.display = "none";
            __$("divShield").style.zIndex = 106;
        }
    
        qtblcell4_1.appendChild(btnBack);
    
        var btnCancel = document.createElement("button");
        btnCancel.className = "button red";
        btnCancel.innerHTML = "<span>Cancel</span>";
        btnCancel.style.cssFloat = "left";
        btnCancel.onclick = function(){
            closePopUps();
        }
    
        qtblcell4_1.appendChild(btnCancel);
    
    } else {
        __$("nightQuestion").style.display = "block";
        __$("editNightDose").value = "";
    }
    
    updateDosage("ulNightDose");
    
    setTimeout("checkState(__$(\"btnForwardNightDose\"), __$(\"editNightDose\"))", timerTime);
}

function askDoseStrength(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.6;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 103; 
    __$("divShield").style.display = "block";
    
    if(!__$("doseStrengthQuestion")){
        var question = document.createElement("div");
        question.id = "doseStrengthQuestion";
        question.style.position = "absolute";
        question.style.left = "140px";
        question.style.top = "140px";
        question.style.width = "390px";
        question.style.height = "420px";
        question.style.backgroundColor = "#fff";
        question.style.zIndex = 103;
        question.className = "dialog  no-selection";
    
        __$("content").appendChild(question);
    
        var cancelImg = document.createElement("img");
        cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
        cancelImg.setAttribute("alt", "X");
        cancelImg.style.cssFloat = "right";
        cancelImg.style.margin = "-65px";
        cancelImg.style.marginTop = "-65px";
        cancelImg.style.cursor = "pointer";
        cancelImg.onclick = function(){
            closePopUps();
        }
    
        question.appendChild(cancelImg);
    
        var qtbl = document.createElement("div");
        qtbl.className = "table";
    
        question.appendChild(qtbl);
    
        var qtblrow1 = document.createElement("div");
        qtblrow1.className = "row";
    
        qtbl.appendChild(qtblrow1);
    
        var qtblcell1_1 = document.createElement("div");
        qtblcell1_1.className = "cell";
        qtblcell1_1.innerHTML = "Dose Strength" + (__$("editDosage").getAttribute("units").trim() != "" ? 
            " in " + __$("editDosage").getAttribute("units") : "");
        qtblcell1_1.id = "labelDose";
    
        qtblrow1.appendChild(qtblcell1_1);
    
        var qtblrow2 = document.createElement("div");
        qtblrow2.className = "row";
    
        qtbl.appendChild(qtblrow2);
    
        var qtblcell2_1 = document.createElement("div");
        qtblcell2_1.className = "cell";
        qtblcell2_1.innerHTML = "<input type='text' id='editDoseStrength' value='' class='inputBox' />";
    
        qtblrow2.appendChild(qtblcell2_1);
    
        var qtblrow3 = document.createElement("div");
        qtblrow3.className = "row";
    
        qtbl.appendChild(qtblrow3);
    
        var qtblcell3_1 = document.createElement("div");
        qtblcell3_1.className = "cell";
        qtblcell3_1.id = "ulDoseStrength";
    
        qtblrow3.appendChild(qtblcell3_1);
    
        showNumber("ulDoseStrength", "editDoseStrength", true);
    
        var qtblrow4 = document.createElement("div");
        qtblrow4.className = "row";
    
        qtbl.appendChild(qtblrow4);
    
        var qtblcell4_1 = document.createElement("div");
        qtblcell4_1.className = "cell";
    
        qtblrow4.appendChild(qtblcell4_1);
    
        var btnForward = document.createElement("button");
        btnForward.className = "button gray";
        btnForward.innerHTML = "<span>Forward</span>";
        btnForward.style.cssFloat = "right";
        btnForward.id = "btnForwardDoseStrength";
        btnForward.onclick = function(){
            if(this.className == "button gray"){
                showMessage("Please enter a value first", false, false)
            } else {            
                askFrequency();
            }
        }
    
        qtblcell4_1.appendChild(btnForward);
        var btnBack = document.createElement("button");
        btnBack.className = "button";
        btnBack.innerHTML = "<span>Back</span>";
        btnBack.style.cssFloat = "right";
        btnBack.onclick = function(){
            __$("doseStrengthQuestion").style.display = "none";
            __$("divShield").style.zIndex = 102;
        }
    
        qtblcell4_1.appendChild(btnBack);
    
        var btnCancel = document.createElement("button");
        btnCancel.className = "button red";
        btnCancel.innerHTML = "<span>Cancel</span>";
        btnCancel.style.cssFloat = "left";
        btnCancel.onclick = function(){
            closePopUps();
        }
    
        qtblcell4_1.appendChild(btnCancel);
    
    } else {
        __$("doseStrengthQuestion").style.display = "block";
        __$("editDoseStrength").value = "";
        __$("labelDose").innerHTML = "Dose Strength" + (__$("editDosage").getAttribute("units").trim() != "" ? 
            " in " + __$("editDosage").getAttribute("units") : "");
    }
    
    updateDosage("ulDoseStrength");
    
    setTimeout("checkState(__$(\"btnForwardDoseStrength\"), __$(\"editDoseStrength\"))", timerTime);
}

function askFrequency(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.6;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 108; 
    __$("divShield").style.display = "block";
    
    if(!__$("frequencyQuestion")){
        var question = document.createElement("div");
        question.id = "frequencyQuestion";
        question.style.position = "absolute";
        question.style.left = "170px";
        question.style.top = "170px";
        question.style.width = "600px";
        question.style.height = "400px";
        question.style.backgroundColor = "#fff";
        question.style.zIndex = 108;
        question.style.display = "block";
        question.className = "dialog  no-selection";
    
        __$("content").appendChild(question);
    
        var cancelImg = document.createElement("img");
        cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
        cancelImg.setAttribute("alt", "X");
        cancelImg.style.cssFloat = "right";
        cancelImg.style.margin = "-65px";
        cancelImg.style.marginTop = "-65px";
        cancelImg.style.cursor = "pointer";
        cancelImg.onclick = function(){
            closePopUps();
        }
    
        question.appendChild(cancelImg);
    
        var qtbl = document.createElement("div");
        qtbl.className = "table";
    
        question.appendChild(qtbl);
    
        var qtblrow1 = document.createElement("div");
        qtblrow1.className = "row";
    
        qtbl.appendChild(qtblrow1);
    
        var qtblcell1_1 = document.createElement("div");
        qtblcell1_1.className = "cell";
        qtblcell1_1.innerHTML = "Select Frequency";
    
        qtblrow1.appendChild(qtblcell1_1);
    
        var qtblrow2 = document.createElement("div");
        qtblrow2.className = "row";
    
        qtbl.appendChild(qtblrow2);
    
        var qtblcell2_1 = document.createElement("div");
        qtblcell2_1.className = "cell";
        qtblcell2_1.innerHTML = "<input type='text' id='editFrequency' value='' class='inputBox' />";
    
        qtblrow2.appendChild(qtblcell2_1);
    
        var qtblrow3 = document.createElement("div");
        qtblrow3.className = "row";
    
        qtbl.appendChild(qtblrow3);
    
        var qtblcell3_1 = document.createElement("div");
        qtblcell3_1.className = "cell";
        qtblcell3_1.innerHTML = "<ul id='ulFrequencies' class='popup'></ul>";
    
        qtblrow3.appendChild(qtblcell3_1);
    
        var f = 0;
        for(var freq in frequencies){
            var li = document.createElement("li");
            li.innerHTML = frequencies[freq];
            li.setAttribute("frequency", freq);
        
            if(f % 2 > 0){
                li.className = "oddf";
            }
        
            li.onclick = function(){
                highlightSelected(__$("ulFrequencies"), this);
            
                __$("editFrequency").value = this.getAttribute("frequency");
                
                if(this.innerHTML == "Stat Dose"){
                    __$("btnForwardFreq").innerHTML = "<span>Done</span>";
                } else {
                    __$("btnForwardFreq").innerHTML = "<span>Forward</span>";
                }
            }
        
            __$("ulFrequencies").appendChild(li);
            
            f++;
        }
    
        var qtblrow4 = document.createElement("div");
        qtblrow4.className = "row";
    
        qtbl.appendChild(qtblrow4);
    
        var qtblcell4_1 = document.createElement("div");
        qtblcell4_1.className = "cell";
    
        qtblrow4.appendChild(qtblcell4_1);
    
        var btnForward = document.createElement("button");
        btnForward.className = "button gray";
        btnForward.innerHTML = "<span>Forward</span>";
        btnForward.style.cssFloat = "right";
        btnForward.id = "btnForwardFreq";
        btnForward.onclick = function(){            
            if(this.className == "button gray"){
                showMessage("Please select a value first", false, false)
            } else {
                askDuration();                             
            }
        }
    
        qtblcell4_1.appendChild(btnForward);
        var btnBack = document.createElement("button");
        btnBack.className = "button";
        btnBack.innerHTML = "<span>Back</span>";
        btnBack.style.cssFloat = "right";
        btnBack.onclick = function(){
            __$("frequencyQuestion").style.display = "none";
            __$("divShield").style.zIndex = 103;
        }
    
        qtblcell4_1.appendChild(btnBack);
    
        var btnCancel = document.createElement("button");
        btnCancel.className = "button red";
        btnCancel.innerHTML = "<span>Cancel</span>";
        btnCancel.style.cssFloat = "left";
        btnCancel.onclick = function(){
            closePopUps();
        }
    
        qtblcell4_1.appendChild(btnCancel);
    
    } else {
        highlightSelected(__$("ulFrequencies"));
        __$("frequencyQuestion").style.display = "block";
        __$("editFrequency").value = "";
    }
    
    setTimeout("checkState(__$(\"btnForwardFreq\"), __$(\"editFrequency\"))", timerTime);
}

function askDuration(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.6;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 109; 
    __$("divShield").style.display = "block";
    
    if(!__$("durationQuestion")){
        var question = document.createElement("div");
        question.id = "durationQuestion";
        question.style.position = "absolute";
        question.style.left = "200px";
        question.style.top = "200px";
        question.style.width = "390px";
        question.style.height = "420px";
        question.style.backgroundColor = "#fff";
        //question.style.border = "1px solid #000";
        question.style.zIndex = 109;
        question.className = "dialog  no-selection";
    
        __$("content").appendChild(question);
    
        var cancelImg = document.createElement("img");
        cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
        cancelImg.setAttribute("alt", "X");
        cancelImg.style.cssFloat = "right";
        cancelImg.style.margin = "-65px";
        cancelImg.style.marginTop = "-65px";
        cancelImg.style.cursor = "pointer";
        cancelImg.onclick = function(){
            closePopUps();
        }
    
        question.appendChild(cancelImg);
    
        var qtbl = document.createElement("div");
        qtbl.className = "table";
    
        question.appendChild(qtbl);
    
        var qtblrow1 = document.createElement("div");
        qtblrow1.className = "row";
    
        qtbl.appendChild(qtblrow1);
    
        var qtblcell1_1 = document.createElement("div");
        qtblcell1_1.className = "cell";
        qtblcell1_1.innerHTML = "Set Duration (Days)";
    
        qtblrow1.appendChild(qtblcell1_1);
    
        var qtblrow2 = document.createElement("div");
        qtblrow2.className = "row";
    
        qtbl.appendChild(qtblrow2);
    
        var qtblcell2_1 = document.createElement("div");
        qtblcell2_1.className = "cell";
        qtblcell2_1.innerHTML = "<input type='text' id='editDuration' value='' class='inputBox' />";
    
        qtblrow2.appendChild(qtblcell2_1);
    
        var qtblrow3 = document.createElement("div");
        qtblrow3.className = "row";
    
        qtbl.appendChild(qtblrow3);
    
        var qtblcell3_1 = document.createElement("div");
        qtblcell3_1.className = "cell";
        qtblcell3_1.id = "ulDuration";
        // qtblcell3_1.style.paddingLeft = "60px";
    
        qtblrow3.appendChild(qtblcell3_1);
    
        showNumber("ulDuration", "editDuration");
    
        var qtblrow4 = document.createElement("div");
        qtblrow4.className = "row";
    
        qtbl.appendChild(qtblrow4);
    
        var qtblcell4_1 = document.createElement("div");
        qtblcell4_1.className = "cell";
    
        qtblrow4.appendChild(qtblcell4_1);
    
        var btnForward = document.createElement("button");
        btnForward.className = "button gray";
        btnForward.innerHTML = "<span>Forward</span>";
        btnForward.style.cssFloat = "right";
        btnForward.id = "btnForwardDuration";
        btnForward.onclick = function(){
            if(this.className == "button gray"){
                showMessage("Please enter a value first", false, false)
            } else {            
                askPRN();
            }
        }
    
        qtblcell4_1.appendChild(btnForward);
        var btnBack = document.createElement("button");
        btnBack.className = "button";
        btnBack.innerHTML = "<span>Back</span>";
        btnBack.style.cssFloat = "right";
        btnBack.onclick = function(){
            __$("durationQuestion").style.display = "none";
            __$("divShield").style.zIndex = 107;
        }
    
        qtblcell4_1.appendChild(btnBack);
    
        var btnCancel = document.createElement("button");
        btnCancel.className = "button red";
        btnCancel.innerHTML = "<span>Cancel</span>";
        btnCancel.style.cssFloat = "left";
        btnCancel.onclick = function(){
            closePopUps();
        }
    
        qtblcell4_1.appendChild(btnCancel);
    
    } else {
        __$("durationQuestion").style.display = "block";
        __$("editDuration").value = "";
    }
    
    if(__$("frequencyQuestion")){
        if(__$("frequencyQuestion").style.display == "block"){
            __$("durationQuestion").style.left = "200px";
            __$("durationQuestion").style.top = "200px";
        } else {
            __$("durationQuestion").style.left = "260px";
            __$("durationQuestion").style.top = "200px";        
        }
    } else {
        __$("durationQuestion").style.left = "260px";
        __$("durationQuestion").style.top = "200px";        
    }
    
    setTimeout("checkState(__$(\"btnForwardDuration\"), __$(\"editDuration\"))", timerTime);
}

function askPRN(){
    if(!__$("divShield")){
        var divShield = document.createElement("div");
        divShield.id = "divShield";
        divShield.style.position = "absolute";
        divShield.style.left = "0px";
        divShield.style.top = "0px";
        divShield.style.opacity = 0.6;
        divShield.style.backgroundColor = "#ccf";
        divShield.style.width = __$("content").offsetWidth + "px";
        divShield.style.height = __$("content").offsetHeight + "px"; 
        divShield.style.display = "none";
        
        __$("content").appendChild(divShield);
    }
    
    __$("divShield").style.zIndex = 110; 
    __$("divShield").style.display = "block";
    
    if(!__$("prnQuestion")){
        var question = document.createElement("div");
        question.id = "prnQuestion";
        question.style.position = "absolute";
        question.style.left = "230px";
        question.style.top = "230px";
        question.style.width = "600px";
        question.style.height = "400px";
        question.style.backgroundColor = "#fff";
        //question.style.border = "1px solid #000";
        question.style.zIndex = 110;
        question.className = "dialog  no-selection";
    
        __$("content").appendChild(question);
    
        var cancelImg = document.createElement("img");
        cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_red.png");
        cancelImg.setAttribute("alt", "X");
        cancelImg.style.cssFloat = "right";
        cancelImg.style.margin = "-65px";
        cancelImg.style.marginTop = "-65px";
        cancelImg.style.cursor = "pointer";
        cancelImg.onclick = function(){
            closePopUps();
        }
    
        question.appendChild(cancelImg);
    
        var qtbl = document.createElement("div");
        qtbl.className = "table";
    
        question.appendChild(qtbl);
    
        var qtblrow1 = document.createElement("div");
        qtblrow1.className = "row";
    
        qtbl.appendChild(qtblrow1);
    
        var qtblcell1_1 = document.createElement("div");
        qtblcell1_1.className = "cell";
        qtblcell1_1.innerHTML = "Take as required (PRN)";
    
        qtblrow1.appendChild(qtblcell1_1);
    
        var qtblrow2 = document.createElement("div");
        qtblrow2.className = "row";
    
        qtbl.appendChild(qtblrow2);
    
        var qtblcell2_1 = document.createElement("div");
        qtblcell2_1.className = "cell";
        qtblcell2_1.innerHTML = "<input type='text' id='editPRN' value='' class='inputBox' />";
    
        qtblrow2.appendChild(qtblcell2_1);
    
        var qtblrow3 = document.createElement("div");
        qtblrow3.className = "row";
    
        qtbl.appendChild(qtblrow3);
    
        var qtblcell3_1 = document.createElement("div");
        qtblcell3_1.className = "cell";
        qtblcell3_1.innerHTML = "<ul id='ulPRN' class='popup'><li>No</li><li class='oddf'>Yes</li></ul>";
    
        qtblrow3.appendChild(qtblcell3_1);
            
        for(var li in __$("ulPRN").children){            
            __$("ulPRN").children[li].onclick = function(){
                highlightSelected(__$("ulPRN"), this);
            
                __$("editPRN").value = this.innerHTML;
            }       
        }
            
        var qtblrow4 = document.createElement("div");
        qtblrow4.className = "row";
    
        qtbl.appendChild(qtblrow4);
    
        var qtblcell4_1 = document.createElement("div");
        qtblcell4_1.className = "cell";
    
        qtblrow4.appendChild(qtblcell4_1);
    
        var btnForward = document.createElement("button");
        btnForward.className = "button gray";
        btnForward.innerHTML = "<span>Done</span>";
        btnForward.style.cssFloat = "right";
        btnForward.id = "btnForwardPRN";
        btnForward.onclick = function(){
            if(this.className == "button gray"){
                showMessage("Please select a value first", false, false)
            } else {            
                processDrug(current_concept_id);
            }
        }
    
        qtblcell4_1.appendChild(btnForward);
        var btnBack = document.createElement("button");
        btnBack.className = "button";
        btnBack.innerHTML = "<span>Back</span>";
        btnBack.style.cssFloat = "right";
        btnBack.onclick = function(){
            __$("prnQuestion").style.display = "none";
            __$("divShield").style.zIndex = 109;
        }
    
        qtblcell4_1.appendChild(btnBack);
    
        var btnCancel = document.createElement("button");
        btnCancel.className = "button red";
        btnCancel.innerHTML = "<span>Cancel</span>";
        btnCancel.style.cssFloat = "left";
        btnCancel.onclick = function(){
            closePopUps();
        }
    
        qtblcell4_1.appendChild(btnCancel);
    
    } else {
        highlightSelected(__$("ulPRN"));
        __$("prnQuestion").style.display = "block";
        __$("editPRN").value = "";
    }
    
    if(__$("frequencyQuestion")){
        if(__$("frequencyQuestion").style.display == "block"){
            __$("prnQuestion").style.left = "230px";
            __$("prnQuestion").style.top = "230px";
        } else {
            __$("prnQuestion").style.left = "290px";
            __$("prnQuestion").style.top = "170px";        
        }
    } else {
        __$("prnQuestion").style.left = "290px";
        __$("prnQuestion").style.top = "170px";        
    }
    
    setTimeout("checkState(__$(\"btnForwardPRN\"), __$(\"editPRN\"))", timerTime);
}

function closePopUps(){
    if(__$("dosageQuestion")){
        __$("content").removeChild(__$("dosageQuestion"));
    }
    
    if(__$("frequencyQuestion")){
        __$("frequencyQuestion").style.display = "none";
    }
    
    if(__$("durationQuestion")){
        __$("durationQuestion").style.display = "none";
    }
    
    if(__$("prnQuestion")){
        __$("prnQuestion").style.display = "none";
    }
    
    if(__$("prescriptionQuestion")){
        __$("prescriptionQuestion").style.display = "none";
    }
    
    if(__$("doseStrengthQuestion")){
        __$("doseStrengthQuestion").style.display = "none";
    }
    
    if(__$("morningQuestion")){
        __$("morningQuestion").style.display = "none";
    }
    
    if(__$("afternoonQuestion")){
        __$("afternoonQuestion").style.display = "none";
    }
    
    if(__$("eveningQuestion")){
        __$("eveningQuestion").style.display = "none";
    }
    
    if(__$("nightQuestion")){
        __$("nightQuestion").style.display = "none";
    }
    
    if(__$("divShield")){
        __$("divShield").style.display = "none";
    }
    
    clearTextInput();
}

function processDrug(concept_id, statdose){
    var li = document.createElement("li");
    
    var pos = __$("ulDoses").getElementsByTagName("li").length % 2;
    
    if(pos > 0){
        li.style.backgroundColor = "#eee";
    }
    
    var drug = "";
    
    var duration = (__$("editDuration") ? (typeof(statdose) != "undefined" ? "1" : __$("editDuration").value) : "1");
    var prn = (__$("editPRN") ? __$("editPRN").value : "No");
    var type = (__$("editPrescriptionType") ? (__$("editPrescriptionType").value == 
        "Stat Dose" ? "Standard" : __$("editPrescriptionType").value) : "Standard");
    var dose_strength = (__$("editDoseStrength") ? __$("editDoseStrength").value : 
        __$("editDosage").getAttribute("strength"));
    var frequency = (__$("editFrequency") ? __$("editFrequency").value : "1");
    var morning = (__$("editMorningDose") ? __$("editMorningDose").value : (typeof(statdose) != "undefined" ? dose_strength : null));
    var afternoon = (__$("editAfternoonDose") ? __$("editAfternoonDose").value : null);
    var evening = (__$("editEveningDose") ? __$("editEveningDose").value : null);
    var night = (__$("editNightDose") ? __$("editNightDose").value : null);
    
    drug += "Drug: <i>" + __$("editDosage").value + "</i>; Type: <i>" + type + 
    "</i>; Dur.: <i>" + duration + "</i>; PRN: <i>" + prn + "</i>";

    if(type == "Standard"){

        switch(frequency.toUpperCase()){
            case "OD":
                morning = dose_strength;
                break;
            case "BD":
                morning = dose_strength;
                evening = dose_strength;
                break;
            case "TDS":
                morning = dose_strength;
                afternoon = dose_strength;
                evening = dose_strength;
                break;
            case "Q4HRS":
                morning = dose_strength;
                afternoon = dose_strength;
                evening = dose_strength;
                night = dose_strength;
                break;
            case "NOCTE":
                night = dose_strength;
                break;
            case "QOD":
                night = dose_strength;
                break;
            case "QPM":
                evening = dose_strength;
                break;
            case "QAM":
                morning = dose_strength;
                break;
            case "QWK":
                morning = dose_strength / 7;
                break;
            case "QID":
                morning = dose_strength;
                afternoon = dose_strength;
                evening = dose_strength;
                night = dose_strength;
                break;
            case "5XD":
                morning = dose_strength * 2;
                afternoon = dose_strength;
                evening = dose_strength;
                night = dose_strength;
                break;
            case "5X/D":
                morning = dose_strength * 2;
                afternoon = dose_strength;
                evening = dose_strength;
                night = dose_strength;
                break;
            case "QHS":
                night = dose_strength;
                break;
            case "QNOON":
                afternoon = dose_strength;
                break;
        }
    }

    li.id = "li" + concept_id;
    
    li.setAttribute("generic", __$("inputTxt").value.trim());
    li.setAttribute("formulation", __$("editDosage").value.trim());
    li.setAttribute("type_of_prescription", type.toLowerCase());
    li.setAttribute("dose_strength", dose_strength);
    li.setAttribute("frequency", frequency);
    li.setAttribute("morning_dose", morning);
    li.setAttribute("afternoon_dose", afternoon);
    li.setAttribute("evening_dose", evening);
    li.setAttribute("night_dose", night);
    li.setAttribute("duration", duration);
    li.setAttribute("prn", prn);
        
    li.setAttribute("concept_id", concept_id);
    
    __$("ulDoses").appendChild(li);
    
    var tbl = document.createElement("div");
    tbl.className = "table";
    
    li.appendChild(tbl);
    
    var row = document.createElement("div");
    row.className = "row";
    
    tbl.appendChild(row);
    
    var cell1 = document.createElement("div");
    cell1.className = "cell";
    cell1.innerHTML = drug;
    
    row.appendChild(cell1);
    
    var cell2 = document.createElement("div");
    cell2.className = "cell";
    cell2.style.verticalAlign = "middle";
    
    row.appendChild(cell2);
    
    var cancelImg = document.createElement("img");
    cancelImg.setAttribute("src", "/touchscreentoolkit/lib/images/cancel_flat_small_red.png");
    cancelImg.setAttribute("alt", "X");
    cancelImg.style.cssFloat = "right";
    cancelImg.style.cursor = "pointer";
    cancelImg.style.margin = "5px";
    cancelImg.setAttribute("target", "li" + concept_id);
    cancelImg.onclick = function(){
        removal_target = this.getAttribute("target");
        
        tstTimerFunctionCall = "removeDrug()";
        
        showMessage("Are you sure you want to delete this entry?", true, false);
    }
        
    cell2.appendChild(cancelImg);
        
    closePopUps();
}

function updateDosage(global_control){
    
    if(__$("defaultButton" + global_control) && __$("editDosage")){
        __$("defaultButton" + global_control).innerHTML = "<span>" + 
        __$("editDosage").getAttribute("strength") + "</span>";
    }
    
}

function clearTextInput(){
    __$("inputTxt").value = "";
    searchDrug();
}

function removeDrug(){    
    if(__$(removal_target)){
        __$("ulDoses").removeChild(__$(removal_target));
    }
}

// Remove the created interface and create corresponding controls ready for storage
function removeGenerics(){    
    
    var fields = ["generic", "formulation", "type_of_prescription", "dose_strength", 
    "frequency", "morning_dose", "afternoon_dose", "evening_dose", "night_dose",
    "duration", "prn"];
    
    for(var i = 0; i <  __$("ulDoses").children.length; i++){        
        for(var j = 0; j < fields.length; j++){            
            var field = document.createElement("input");
            field.type = "hidden";
            field.name = "prescription[][" + fields[j] + "]";
            field.value = __$("ulDoses").children[i].getAttribute(fields[j]);

            document.forms[0].appendChild(field);
        }
    }
    
}

/*
     * We create a custom keyboard for the interface to fit on the available space
     */
function showFixedKeyboard(ctrl, global_control){
    var full_keyboard = "full";
    
    var div = document.createElement("div");
    div.id = "divMenu";
    div.style.backgroundColor = "#EEEEEE";
    div.style.top = "0px";
    div.style.left = "0px";
    div.style.margin = "5px";

    var row1 = ["Q","W","E","R","T","Y","U","I","O","P"];
    var row2 = ["", "A","S","D","F","G","H","J","K","L"];
    var row3 = ["delete", "Z","X","C","V","B","N","M",""];
    var row5 = ["1","2","3","4","5","6","7","8","9","0"];

    var tbl = document.createElement("table");
    tbl.bgColor = "#fff";
    tbl.cellSpacing = 2;
    tbl.cellPadding = 10;
    tbl.id = "tblKeyboard";
    tbl.width = "100%";

    var tr5 = document.createElement("tr");

    for(var i = 0; i < row5.length; i++){
        var td5 = document.createElement("td");
        td5.innerHTML = row5[i];
        td5.align = "center";
        td5.vAlign = "middle";
        td5.style.cursor = "pointer";
        td5.style.fontSize = "1.5em";
        td5.bgColor = "#EEEEEE"
        td5.width = "30px";
        td5.className = "btn";

        td5.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.toProperCase();
                $(global_control).value = $(global_control).value.toProperCase();
                searchDrug();
            }
        }

        tr5.appendChild(td5);
    }

    if(full_keyboard){
        tbl.appendChild(tr5);
    }

    var tr1 = document.createElement("tr");

    for(var i = 0; i < row1.length; i++){
        var td1 = document.createElement("td");
        td1.innerHTML = row1[i];
        td1.align = "center";
        td1.vAlign = "middle";
        td1.style.cursor = "pointer";
        td1.style.fontSize = "1.5em";
        td1.bgColor = "#EEEEEE"
        td1.width = "30px";
        td1.className = "btn";

        td1.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.toProperCase();
                $(global_control).value = $(global_control).value.toProperCase();
                searchDrug();
            }
        }

        tr1.appendChild(td1);
    }

    tbl.appendChild(tr1);

    var tr2 = document.createElement("tr");

    for(var i = 0; i < row2.length; i++){
        var td2 = document.createElement("td");
        td2.innerHTML = row2[i];
        td2.align = "center";
        td2.vAlign = "middle";
        td2.style.cursor = "pointer";
        td2.style.fontSize = "1.5em";
        td2.bgColor = "#EEEEEE"
        td2.width = "30px";

        if(!row2[i].trim().match(/^$/)){
            td2.className = "btn";
        }

        td2.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.toProperCase();
                $(global_control).value = $(global_control).value.toProperCase();
                searchDrug();
            }
        }

        tr2.appendChild(td2);
    }

    tbl.appendChild(tr2);

    var tr3 = document.createElement("tr");

    for(var i = 0; i < row3.length; i++){
        var td3 = document.createElement("td");
        td3.innerHTML = row3[i];
        td3.align = "center";
        td3.vAlign = "middle";
        td3.style.cursor = "pointer";
        td3.style.fontSize = "1.5em";
        td3.bgColor = "#EEEEEE"
        td3.width = "30px";

        if(!row3[i].trim().match(/^$/)){
            td3.className = "btn";
        }

        if(row3[i] == "delete"){
            td3.colSpan = 2;

            td3.onclick = function(){
                $(global_control).value = $(global_control).value.substring(0,$(global_control).value.length - 1);
                searchDrug();
            }
            
        } else if(row3[i].trim() == "stat<br />dose"){            
            td3.style.fontSize = "0.9em";            
            td3.style.padding = "0px";           
            td3.style.fontWeight = "bold";
            
            td3.onclick = function(){
                if ($("optionOD"))
                    $("optionOD").click();
                if ($("group1_1-10"))
                    $("group1_1-10").click();
                if ($("group2_1"))
                    $("group2_1").click();
            }
        } else {            

            td3.onclick = function(){
                if(!this.innerHTML.match(/^$/)){
                    $(global_control).value += this.innerHTML.toProperCase();
                    $(global_control).value = $(global_control).value.toProperCase();
                    searchDrug();
                }
            }

        }

        tr3.appendChild(td3);
    }

    tbl.appendChild(tr3);

    div.appendChild(tbl);
    ctrl.appendChild(div);

}

function showNumber(id, global_control, showDefault){
    
    var row1 = ["1","2","3"];
    var row2 = ["4","5","6"];
    var row3 = ["7","8","9"];
    var row4 = [".","0","C"];

    var tbl = document.createElement("table");
    tbl.className = "keyBoardTable";
    tbl.cellSpacing = 0;
    tbl.cellPadding = 3;
    tbl.id = "tblKeyboard";

    var tr1 = document.createElement("tr");

    var td = document.createElement("td");
    td.rowSpan = "4";
    td.style.minWidth = "60px";
    td.style.textAlign = "center";
    td.style.verticalAlign = "top";
    
    tr1.appendChild(td);

    if(typeof(showDefault) != "undefined"){
        if(showDefault == true){
            td.innerHTML = "<span style='font-size: 1.1em; font-style: italic;'>Default</span>";
            
            var defaultButton = document.createElement("button");
            defaultButton.id = "defaultButton" + id;
            defaultButton.className = "blue";
            defaultButton.innerHTML = "<span>0</span>";
            defaultButton.style.fontWeight = "normal";
            defaultButton.onclick = function(){
                var value = this.innerHTML.replace(/\<span\>/i, "").replace(/\<\/span\>/i, "");
        
                if(value != "Default"){
                    __$(global_control).value = value;
                } else {
                    __$(global_control).value = 0; 
                }
            }
        
            td.appendChild(defaultButton);
        }
    } 
    
    for(var i = 0; i < row1.length; i++){
        var td1 = document.createElement("td");
        td1.align = "center";
        td1.vAlign = "middle";
        td1.style.cursor = "pointer";
        td1.bgColor = "#ffffff"
        td1.width = "30px";

        tr1.appendChild(td1);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row1[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^__$/)){
                __$(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
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
                __$(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
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
            if(!this.innerHTML.match(/^__$/)){
                __$(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td3.appendChild(btn);

    }

    tbl.appendChild(tr3);

    var tr4 = document.createElement("tr");

    for(var i = 0; i < row4.length; i++){
        var td4 = document.createElement("td");
        td4.align = "center";
        td4.vAlign = "middle";
        td4.style.cursor = "pointer";
        td4.bgColor = "#ffffff";
        td4.width = "30px";

        tr4.appendChild(td4);

        var btn = document.createElement("button");
        btn.innerHTML = "<span>" + row4[i] + "</span>";
        btn.className = "blue";
        btn.onclick = function(){
            if(this.innerHTML.match(/<span>(.+)<\/span>/)[1] == "C"){
                __$(global_control).value = __$(global_control).value.substring(0,__$(global_control).value.length - 1);
            }else if(!this.innerHTML.match(/^$/)){
                __$(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td4.appendChild(btn);

    }

    tbl.appendChild(tr4);

    __$(id).appendChild(tbl);

}

// Supporting function to allow a humanized Concept Name display
String.prototype.toProperCase = function()
{
    return this.toLowerCase().replace(/^(.)|\s(.)/g,
        function($1) {
            return $1.toUpperCase();
        });
}

// init();