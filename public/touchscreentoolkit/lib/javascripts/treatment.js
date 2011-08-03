/* 
 * treatment.js
 * This file contains the code for generation of a prescription interface. The
 * interface is generated dynamically. Initially, a list of Generic drugs is given
 * as well as a list of the possible periods for a prescription.
 *
 * When a user selects a generic drug, the list of possible dosages and frequencies
 * is pulled from the database and populated on the interface.
 *
 * When the period is selected, the combination of the various fields is saved in
 * a temporary hash. Clicking an already selected item deletes a saved entry if
 * there is one.
 * 
 */

// Global variables
var current_generic = null;
var selectedGenerics = {};
var current_diagnosis = null;

var search_path = (typeof(search_path) != "undefined" ? search_path : "/search/load_frequencies_and_dosages");

// This function exists in the TouchScreenToolkit but repeated here in case it's
// not referenced
function $(id){
    return document.getElementById(id);
}

// Supporting function to allow a humanized Concept Name display
String.prototype.toProperCase = function()
{
    return this.toLowerCase().replace(/^(.)|\s(.)/g,
        function($1) {
            return $1.toUpperCase();
        });
}

// Create the interface
function generateGenerics(){
    if($("parent_container")){
        $("content").removeChild($("parent_container"));
    }

    $("clearButton").style.display = "none";

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

    $("content").appendChild(parent_container);

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

    for(var g = 0; g < diagnosisList.length; g++){
        var optio = document.createElement("option");
        optio.innerHTML = diagnosisList[g].toProperCase();
        optio.onclick = function(){
            current_diagnosis = this.innerHTML.toUpperCase();
            selectedGenerics[current_diagnosis] = {};
            $('inputTxt').value = '';
            searchDrug();
        }

        diagnoses.appendChild(optio);

        if(g == 0){
            current_diagnosis = diagnosisList[g].toUpperCase();
        }
    }
    
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

    var drugsDiv = document.createElement("div");
    drugsDiv.style.width = "25%";
    drugsDiv.style.height = "99%";
    drugsDiv.style.marginLeft = "2px";
    drugsDiv.style.marginTop = "2px";
    drugsDiv.style.backgroundColor = "#fff";
    drugsDiv.style.border = "1px solid #ccc";
    drugsDiv.style.padding = "0px";
    drugsDiv.style.cssFloat = "left";

    detailsDiv.appendChild(drugsDiv);

    var freqsDosePeriodDiv = document.createElement("div");
    freqsDosePeriodDiv.style.width = "72.5%";
    freqsDosePeriodDiv.style.height = "99%";
    freqsDosePeriodDiv.style.marginLeft = "2px";
    freqsDosePeriodDiv.style.marginTop = "2px";
    freqsDosePeriodDiv.style.backgroundColor = "#fff";
    freqsDosePeriodDiv.style.border = "1px solid #ccc";
    freqsDosePeriodDiv.style.padding = "0px";
    freqsDosePeriodDiv.style.cssFloat = "right";

    detailsDiv.appendChild(freqsDosePeriodDiv);

    var drugsTopicDiv = document.createElement("div");
    drugsTopicDiv.style.fontSize = "1.5em";
    drugsTopicDiv.style.height = "32px";
    drugsTopicDiv.style.padding = "5px";
    drugsTopicDiv.innerHTML = "Drug";
    drugsTopicDiv.style.backgroundColor = "#999";
    drugsTopicDiv.style.textAlign = "center";
    drugsTopicDiv.style.color = "#eee";

    drugsDiv.appendChild(drugsTopicDiv);

    var drugsListDiv = document.createElement("div");
    drugsListDiv.style.fontSize = "1.5em";
    drugsListDiv.style.height = "89.5%";
    drugsListDiv.style.padding = "5px";
    drugsListDiv.style.overflow = "auto";
    drugsListDiv.style.backgroundColor = "#fff";

    drugsDiv.appendChild(drugsListDiv);

    var doseDiv = document.createElement("div");
    doseDiv.style.width = "33%";
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
    doseTopicDiv.innerHTML = "Dosage";
    doseTopicDiv.style.backgroundColor = "#999";
    doseTopicDiv.style.textAlign = "center";
    doseTopicDiv.style.color = "#eee";

    doseDiv.appendChild(doseTopicDiv);

    var doseListDiv = document.createElement("div");
    doseListDiv.style.fontSize = "1.5em";
    doseListDiv.style.height = "79%";
    doseListDiv.style.padding = "5px";
    doseListDiv.style.overflow = "auto";
    doseListDiv.style.backgroundColor = "#fff";

    doseDiv.appendChild(doseListDiv);

    var freqDiv = document.createElement("div");
    freqDiv.style.width = "33%";
    freqDiv.style.height = "49%";
    freqDiv.style.backgroundColor = "#ff0";
    freqDiv.style.borderRight = "1px solid #ccc";
    freqDiv.style.padding = "0px";
    freqDiv.style.cssFloat = "left";

    freqsDosePeriodDiv.appendChild(freqDiv);

    var freqTopicDiv = document.createElement("div");
    freqTopicDiv.style.fontSize = "1.5em";
    freqTopicDiv.style.height = "32px";
    freqTopicDiv.style.padding = "5px";
    freqTopicDiv.innerHTML = "Frequency";
    freqTopicDiv.style.backgroundColor = "#999";
    freqTopicDiv.style.textAlign = "center";
    freqTopicDiv.style.color = "#eee";

    freqDiv.appendChild(freqTopicDiv);

    var freqListDiv = document.createElement("div");
    freqListDiv.style.fontSize = "1.5em";
    freqListDiv.style.height = "79%";
    freqListDiv.style.padding = "5px";
    freqListDiv.style.overflow = "auto";
    freqListDiv.style.backgroundColor = "#fff";

    freqDiv.appendChild(freqListDiv);

    var periodDiv = document.createElement("div");
    periodDiv.style.width = "33.5%";
    periodDiv.style.height = "49%";
    periodDiv.style.backgroundColor = "#fff";
    //periodDiv.style.borderRight = "1px solid #ccc";
    periodDiv.style.padding = "0px";
    periodDiv.style.cssFloat = "left";

    freqsDosePeriodDiv.appendChild(periodDiv);

    var periodTopicDiv = document.createElement("div");
    periodTopicDiv.style.fontSize = "1.5em";
    periodTopicDiv.style.height = "32px";
    periodTopicDiv.style.padding = "5px";
    periodTopicDiv.innerHTML = "Duration";
    periodTopicDiv.style.backgroundColor = "#999";
    periodTopicDiv.style.textAlign = "center";
    periodTopicDiv.style.color = "#eee";

    periodDiv.appendChild(periodTopicDiv);

    var periodListDiv = document.createElement("div");
    periodListDiv.style.fontSize = "1.5em";
    periodListDiv.style.height = "79%";
    periodListDiv.style.padding = "5px";
    periodListDiv.style.overflow = "auto";
    periodListDiv.style.backgroundColor = "#fff";

    periodDiv.appendChild(periodListDiv);

    var keyboardDiv = document.createElement("div");
    keyboardDiv.style.width = "99.7%";
    keyboardDiv.style.height = "50.5%";
    keyboardDiv.style.backgroundColor = "#fff";
    keyboardDiv.style.borderTop = "1px solid #ccc";
    keyboardDiv.style.padding = "0px";
    keyboardDiv.style.cssFloat = "left";
    keyboardDiv.id = "keyboardDiv";

    freqsDosePeriodDiv.appendChild(keyboardDiv);

    showFixedKeyboard($("keyboardDiv"), "inputTxt");

    var ulDrugs = document.createElement("ul");
    ulDrugs.id = "ulDrugs";
    ulDrugs.style.fontSize = "1.0em";
    ulDrugs.style.listStyle = "none";
    ulDrugs.style.padding = "0px";

    drugsListDiv.appendChild(ulDrugs);

    var ulFreqs = document.createElement("ul");
    ulFreqs.id = "ulFreqs";
    ulFreqs.style.fontSize = "1.0em";
    ulFreqs.style.listStyle = "none";
    ulFreqs.style.padding = "0px";

    freqListDiv.appendChild(ulFreqs);

    var ulDoses = document.createElement("ul");
    ulDoses.id = "ulDoses";
    ulDoses.style.fontSize = "1.0em";
    ulDoses.style.listStyle = "none";
    ulDoses.style.padding = "0px";

    doseListDiv.appendChild(ulDoses);

    var ulPeriod = document.createElement("ul");
    ulPeriod.id = "ulPeriod";
    ulPeriod.style.fontSize = "1.0em";
    ulPeriod.style.listStyle = "none";
    ulPeriod.style.padding = "0px";

    // periodListDiv.appendChild(ulPeriod);

    var tblContent = document.createElement("table");
    tblContent.cellSpacing = 1;
    tblContent.cellPadding = 2;
    tblContent.width = "100%";
    tblContent.border = 0;
    tblContent.style.fontSize = "0.7em";

    periodListDiv.appendChild(tblContent);
    
    for(var i = 0; i < 10; i++){
        var tr = document.createElement("tr");
        tblContent.appendChild(tr);
        
        // SET 1:
        var td1 = document.createElement("td");
        td1.vAlign = "middle";
        td1.id = "group1_" + (((i*10)+1) + "-" + ((i+1)*10));
        td1.height = "40px";
        td1.width = "19%";
        td1.bgColor = "#DDDDDD";

        td1.onclick = function(){
            var rdo = this.getElementsByTagName("input");

            if(rdo[0]){
                if(rdo[0].type=="radio") rdo[0].click();
            }
        }

        var rdo1 = document.createElement("input");
        rdo1.type = "radio";
        rdo1.value = (((i*10)+1) + "-" + ((i+1)*10));
        rdo1.name = "group1";

        rdo1.onclick = function(){
            var tds = document.getElementsByName("group1");

            for(var k = 0; k < tds.length; k++){
                $("group1_" + tds[k].value).bgColor = "#DDDDDD";
            }

            this.offsetParent.bgColor = "#add8e6";

            var targets = document.getElementsByName("group1");
            var v = this.value.split("-");
            var start = v[0];
            var end = v[1];

            var val = start;

            for(var k = 0; k < targets.length; k++){
                var td = $("group2_" + (k+1));

                var irdo = td.getElementsByTagName("input");

                if(irdo){
                    irdo[0].value = val;
                }

                var ilbl = td.getElementsByTagName("label");

                if(ilbl){
                    ilbl[0].innerHTML = val;
                }

                val++;
            }

        }

        td1.appendChild(rdo1);

        var lbl1 = document.createElement("label");
        lbl1.style.width = "100%";
        lbl1.innerHTML = (((i*10)+1) + "-" + ((i+1)*10));

        td1.appendChild(lbl1);

        tblContent.appendChild(tr);
        tr.appendChild(td1);


        var td2 = document.createElement("td");
        td2.vAlign = "middle";
        td2.id = "group2_" + (i+1);
        td2.width = "14%";

        td2.onclick = function(){
            var rdo = this.getElementsByTagName("input");

            if(rdo[0]){
                if(rdo[0].type=="radio") rdo[0].click();
            }
        }

        var rdo2 = document.createElement("input");
        rdo2.type = "radio";
        rdo2.name = "group2";

        rdo2.onclick = function(){
            var tds = document.getElementsByName("group2");

            for(var k = 0; k < tds.length; k++){
                var p = String(tds[k].value).match(/\d$/);

                if(p){
                    $("group2_" + (p==0?10:p)).bgColor = "";
                }

            }

            if(selectedGenerics[current_diagnosis]){
                if(selectedGenerics[current_diagnosis][current_generic]) {
                    selectedGenerics[current_diagnosis][current_generic]["duration"] = this.value;
                } else {
                    selectedGenerics[current_diagnosis][current_generic] = {
                        "dosage":[],
                        "frequency":null,
                        "duration":this.value
                    };
                }
            }else {
                selectedGenerics[current_diagnosis] = {};
                selectedGenerics[current_diagnosis][current_generic] = {
                    "dosage":[],
                    "frequency":null,
                    "duration":this.value
                };
            }            
            
            this.offsetParent.bgColor = "#add8e6";
        }

        td2.appendChild(rdo2);

        var lbl2 = document.createElement("label");
        lbl2.style.width = "100%";
        lbl2.innerHTML = "&nbsp;";

        td2.appendChild(lbl2);

        tr.appendChild(td2);
    }

    // Create Generic Drugs list
    for(var d = 0; d < generics.length; d++){
        var li = document.createElement("li");
        li.id = "option" + generics[d][0];
        li.innerHTML = generics[d][0].toProperCase();
        li.style.padding = "15px";

        if(d%2>0){
            li.style.backgroundColor = "#eee";
        }

        li.setAttribute("concept_id", generics[d][1])
        li.onclick = function(){
            loadDosageFrequency(this.getAttribute("concept_id"));

            current_generic = this.innerHTML.toUpperCase();
            
            if(this.style.backgroundColor == "lightblue"){
                if(selectedGenerics[current_diagnosis]){
                    delete selectedGenerics[current_diagnosis][current_generic];
                }
            } 

            var tds = document.getElementsByName("group2");

            for(var k = 0; k < tds.length; k++){
                var p = String(tds[k].value).match(/\d$/);

                if(p){
                    $("group2_" + (p==0?10:p)).bgColor = "";
                    var rdos = $("group2_" + (p==0?10:p)).getElementsByTagName("input");
                    if(rdos[0])
                        rdos[0].checked = false;

                    if($("group1_" + (((((p==0?10:p)-1)*10)+1) + "-" + ((((p==0?10:p)-1)+1)*10)))){
                        $("group1_" + (((((p==0?10:p)-1)*10)+1) + "-" + ((((p==0?10:p)-1)+1)*10))).bgColor = "#DDDDDD";

                        var rdos2 = $("group1_" + (((((p==0?10:p)-1)*10)+1) + "-" +
                            ((((p==0?10:p)-1)+1)*10))).getElementsByTagName("input");
                        
                        if(rdos2[0])
                            rdos2[0].checked = false;
                    }                     
                }

            }
            
            // Clear Frequencies
            for(var j = 0; j < $('ulFreqs').childNodes.length; j++){
                $('ulFreqs').childNodes[j].style.backgroundColor = "";
                if(j%2>0){
                    $('ulFreqs').childNodes[j].style.backgroundColor = "#eee";
                }
                $('ulFreqs').childNodes[j].style.color = "#000";

                if(selectedGenerics[current_diagnosis]){
                    if(selectedGenerics[current_diagnosis][current_generic]){
                        if(selectedGenerics[current_diagnosis][current_generic]["frequency"] ==
                            $('ulFreqs').childNodes[j].innerHTML.toUpperCase()){

                            $('ulFreqs').childNodes[j].style.backgroundColor = "yellowgreen";
                            $('ulFreqs').childNodes[j].style.color = "#fff";
                        }
                    }
                }
            }
            
            for(var j = 0; j < $('ulDrugs').childNodes.length; j++){
                if(selectedGenerics[current_diagnosis]){
                    if(selectedGenerics[current_diagnosis][$('ulDrugs').childNodes[j].innerHTML.toUpperCase()]){
                        $('ulDrugs').childNodes[j].style.backgroundColor = "yellowgreen";
                        $('ulDrugs').childNodes[j].style.color = "white";
                    } else {
                        if(j%2>0){
                            $('ulDrugs').childNodes[j].style.backgroundColor = "#eee";
                        } else {
                            $('ulDrugs').childNodes[j].style.backgroundColor = "";
                        }
                        $('ulDrugs').childNodes[j].style.color = "black";
                    }
                } else {
                    if(j%2>0){
                        $('ulDrugs').childNodes[j].style.backgroundColor = "#eee";
                    } else {
                        $('ulDrugs').childNodes[j].style.backgroundColor = "";
                    }
                    $('ulDrugs').childNodes[j].style.color = "black";
                }
            }
            this.style.backgroundColor = "lightblue";
            this.style.color = "black";

        }

        ulDrugs.appendChild(li);
    }

    // Create frequencies list
    for(var d = 0; d < frequencies.length; d++){
        var li = document.createElement("li");
        li.id = "option" + frequencies[d];
        li.innerHTML = frequencies[d];
        li.style.padding = "15px";

        if(d%2>0){
            li.style.backgroundColor = "#eee";
        }
        li.style.color = "#000";

        if(selectedGenerics[current_diagnosis]){
            if(selectedGenerics[current_diagnosis][current_generic]){
                if(selectedGenerics[current_diagnosis][current_generic]["frequency"] == frequencies[i].toUpperCase()){
                    li.style.backgroundColor = "yellowgreen";
                    li.style.color = "#fff";
                }
            }
        }

        li.onclick = function(){            
            for(var j = 0; j < $('ulFreqs').childNodes.length; j++){
                $('ulFreqs').childNodes[j].style.backgroundColor = "";
                if(j%2>0){
                    $('ulFreqs').childNodes[j].style.backgroundColor = "#eee";
                }
                $('ulFreqs').childNodes[j].style.color = "black";

                if(selectedGenerics[current_diagnosis]){
                    if(selectedGenerics[current_diagnosis][current_generic]) {
                        selectedGenerics[current_diagnosis][current_generic]["frequency"] = this.innerHTML.toUpperCase();
                    } else {
                        selectedGenerics[current_diagnosis][current_generic] = {
                            "dosage":[],
                            "frequency":this.innerHTML.toUpperCase(),
                            "duration":null
                        };
                    }
                } else {
                    selectedGenerics[current_diagnosis] = {};
                    selectedGenerics[current_diagnosis][current_generic] = {
                        "dosage":[],
                        "frequency":this.innerHTML.toUpperCase(),
                        "duration":null
                    };
                }
            }
            this.style.backgroundColor = "lightblue";
        }

        ulFreqs.appendChild(li);
    }

}

/*
 * This method filters the search list to accomodate only those that are similar
 * to the typed text
 * 
 */
function searchDrug(){
    $('ulDrugs').innerHTML = "";
    current_generic = null;

    var k = 0;
    
    for(var d = 0; d < generics.length; d++){
        if(generics[d][0].toLowerCase().match($("inputTxt").value.toLowerCase())){
            var li = document.createElement("li");
            li.id = "option" + generics[d][0];
            li.innerHTML = generics[d][0].toProperCase();
            li.style.padding = "15px";

            if(k%2>0){
                li.style.backgroundColor = "#eee";
            }
            li.style.color = "#000";

            if(selectedGenerics[current_diagnosis]){
                if(selectedGenerics[current_diagnosis][generics[d][0].toUpperCase()]){
                    li.style.backgroundColor = "yellowgreen";
                    li.style.color = "#fff";
                }
            }

            li.setAttribute("concept_id", generics[d][1])
            li.onclick = function(){
                loadDosageFrequency(this.getAttribute("concept_id"));

                current_generic = this.innerHTML.toUpperCase();

                if(this.style.backgroundColor == "lightblue"){
                    if(selectedGenerics[current_diagnosis]){
                        delete selectedGenerics[current_diagnosis][current_generic];
                    }
                }


                var tds = document.getElementsByName("group2");

                for(var k = 0; k < tds.length; k++){
                    var p = String(tds[k].value).match(/\d$/);

                    if(p){
                        $("group2_" + (p==0?10:p)).bgColor = "";
                        var rdos = $("group2_" + (p==0?10:p)).getElementsByTagName("input");
                        if(rdos[0])
                            rdos[0].checked = false;

                        if($("group1_" + (((((p==0?10:p)-1)*10)+1) + "-" + ((((p==0?10:p)-1)+1)*10)))){
                            $("group1_" + (((((p==0?10:p)-1)*10)+1) + "-" + ((((p==0?10:p)-1)+1)*10))).bgColor = "#DDDDDD";

                            var rdos2 = $("group1_" + (((((p==0?10:p)-1)*10)+1) + "-" +
                                ((((p==0?10:p)-1)+1)*10))).getElementsByTagName("input");

                            if(rdos2[0])
                                rdos2[0].checked = false;
                        }
                    }

                }

                // Clear Frequencies
                for(var j = 0; j < $('ulFreqs').childNodes.length; j++){
                    $('ulFreqs').childNodes[j].style.backgroundColor = "";
                    if(j%2>0){
                        $('ulFreqs').childNodes[j].style.backgroundColor = "#eee";
                    }
                    $('ulFreqs').childNodes[j].style.color = "#000";

                    if(selectedGenerics[current_diagnosis]){
                        if(selectedGenerics[current_diagnosis][current_generic]){
                            if(selectedGenerics[current_diagnosis][current_generic]["frequency"] ==
                                $('ulFreqs').childNodes[j].innerHTML.toUpperCase()){

                                $('ulFreqs').childNodes[j].style.backgroundColor = "yellowgreen";
                                $('ulFreqs').childNodes[j].style.color = "#fff";
                            }
                        }
                    }
                }

                for(var j = 0; j < $('ulDrugs').childNodes.length; j++){
                    if(selectedGenerics[current_diagnosis]){
                        if(selectedGenerics[current_diagnosis][$('ulDrugs').childNodes[j].innerHTML.toUpperCase()]){
                            $('ulDrugs').childNodes[j].style.backgroundColor = "yellowgreen";
                            $('ulDrugs').childNodes[j].style.color = "white";
                        } else {
                            if(j%2>0){
                                $('ulDrugs').childNodes[j].style.backgroundColor = "#eee";
                            } else {
                                $('ulDrugs').childNodes[j].style.backgroundColor = "";
                            }
                            $('ulDrugs').childNodes[j].style.color = "black";
                        }
                    } else {
                        if(j%2>0){
                            $('ulDrugs').childNodes[j].style.backgroundColor = "#eee";
                        } else {
                            $('ulDrugs').childNodes[j].style.backgroundColor = "";
                        }
                        $('ulDrugs').childNodes[j].style.color = "black";
                    }
                }
                this.style.backgroundColor = "lightblue";
                this.style.color = "black";

            }

            $('ulDrugs').appendChild(li);

            k++;
        }
    }

}

/*
 *This method calls the ajax method for loading dosages and frequencies
 */
function loadDosageFrequency(concept_id){
    $('ulDoses').innerHTML = "";
    ajaxDFRequest(search_path + "?concept_id=" + concept_id);
}

/*
 * This function exists in the TouchScreen toolkit. Reproduced here to customise
 * it for the specifics of the interface. It is used here to load Dosages and
 * Frequencies which are filled on demand
 * 
 */
function ajaxDFRequest(aUrl) {
    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function() {
        handleDFResult(httpRequest);
    };
    try {
        httpRequest.open('GET', aUrl, true);
        httpRequest.send(null);
    } catch(e){
    }
}

function handleDFResult(aXMLHttpRequest) {
    if (!aXMLHttpRequest) return;

    if (aXMLHttpRequest.readyState == 4 && aXMLHttpRequest.status == 200) {
        var dosesFreqs = JSON.parse(aXMLHttpRequest.responseText);

        var existingDoses = {};

        for(var i = 0; i < dosesFreqs.length; i++){
            var li = document.createElement("li");
            li.id = "option" + dosesFreqs[i][0];
            li.innerHTML = dosesFreqs[i][0];
            li.setAttribute("strength", dosesFreqs[i][1]);
            li.setAttribute("units", dosesFreqs[i][2]);
            li.style.padding = "15px";

            if(i%2>0){
                li.style.backgroundColor = "#eee";
            }
            li.style.color = "#000";

            if(selectedGenerics[current_diagnosis]){
                if(selectedGenerics[current_diagnosis][current_generic]){
                    if(selectedGenerics[current_diagnosis][current_generic]["dosage"] == [dosesFreqs[i][0].toUpperCase(),
                        dosesFreqs[i][1].toUpperCase(),
                        dosesFreqs[i][2].toUpperCase()]){
                        li.style.backgroundColor = "yellowgreen";
                        li.style.color = "#fff";
                    }
                }
            }
            
            li.onclick = function(){
                for(var j = 0; j < $('ulDoses').childNodes.length; j++){
                    $('ulDoses').childNodes[j].style.backgroundColor = "";
                    if(j%2>0){
                        $('ulDoses').childNodes[j].style.backgroundColor = "#eee";
                    }
                    $('ulDoses').childNodes[j].style.color = "#000";
                }
                if(selectedGenerics[current_diagnosis]){
                    if(selectedGenerics[current_diagnosis][current_generic]) {
                        selectedGenerics[current_diagnosis][current_generic]["dosage"] = [this.innerHTML.toUpperCase(),
                        this.getAttribute("strength"),
                        this.getAttribute("units")];
                    } else {
                        selectedGenerics[current_diagnosis][current_generic] = {
                            "dosage":[this.innerHTML.toUpperCase(), this.getAttribute("strength"),
                            this.getAttribute("units")],
                            "frequency":null,
                            "duration":null
                        };
                    }
                } else {
                    selectedGenerics[current_diagnosis] = {};
                    selectedGenerics[current_diagnosis][current_generic] = {
                        "dosage":[this.innerHTML.toUpperCase(), this.getAttribute("strength"),
                        this.getAttribute("units")],
                        "frequency":null,
                        "duration":null
                    };
                }
                this.style.backgroundColor = "lightblue";
            }

            if(!existingDoses[dosesFreqs[i][0].toUpperCase()]){
                $('ulDoses').appendChild(li);
                existingDoses[dosesFreqs[i][0].toUpperCase()] = true;
            }
        }
    }
}

// Remove the created interface and create corresponding controls ready for storage
function removeGenerics(){

    for(var diagnosis in selectedGenerics){
        for(var generic in selectedGenerics[diagnosis]){

            var parent_diagnosis = document.createElement("input");
            parent_diagnosis.type = "hidden";
            parent_diagnosis.name = "prescriptions[][concept_name]";
            parent_diagnosis.value = "DIAGNOSIS";

            document.forms[0].appendChild(parent_diagnosis);

            var valueCodedText = document.createElement("input");
            valueCodedText.type = "hidden";
            valueCodedText.name = "prescriptions[][value_coded_or_text]";
            valueCodedText.value = diagnosis;

            document.forms[0].appendChild(valueCodedText);

            var concept = document.createElement("input");
            concept.type = "hidden";
            concept.name = "prescriptions[][drug]";
            concept.value = generic;

            document.forms[0].appendChild(concept);

            var patientid = document.createElement("input");
            patientid.type = "hidden";
            patientid.name = "prescriptions[][patient_id]";
            patientid.value = patient_id;

            document.forms[0].appendChild(patientid);

            if(selectedGenerics[diagnosis][generic]["dosage"]){
                var dosage = document.createElement("input");
                dosage.type = "hidden";
                dosage.name = "prescriptions[][dosage]";
                dosage.value = selectedGenerics[diagnosis][generic]["dosage"][0];

                document.forms[0].appendChild(dosage);

                var strength = document.createElement("input");
                strength.type = "hidden";
                strength.name = "prescriptions[][strength]";
                strength.value = selectedGenerics[diagnosis][generic]["dosage"][1];

                document.forms[0].appendChild(strength);
                
                var units = document.createElement("input");
                units.type = "hidden";
                units.name = "prescriptions[][units]";
                units.value = selectedGenerics[diagnosis][generic]["dosage"][2];

                document.forms[0].appendChild(units);
            }

            if(selectedGenerics[diagnosis][generic]["frequency"]){
                var frequency = document.createElement("input");
                frequency.type = "hidden";
                frequency.name = "prescriptions[][frequency]";
                frequency.value = selectedGenerics[diagnosis][generic]["frequency"];

                document.forms[0].appendChild(frequency);
            }

            if(selectedGenerics[diagnosis][generic]["duration"]){
                var duration = document.createElement("input");
                duration.type = "hidden";
                duration.name = "prescriptions[][duration]";
                duration.value = selectedGenerics[diagnosis][generic]["duration"];

                document.forms[0].appendChild(duration);
            }
        }
    }

    if($("parent_container")){
        $("content").removeChild($("parent_container"));
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
    var row3 = ["clear", "Z","X","C","V","B","N","M",""];
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

        if(row3[i] == "clear"){
            td3.colSpan = 2;

            td3.onclick = function(){
                $(global_control).value = $(global_control).value.substring(0,$(global_control).value.length - 1);
                searchDrug();
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

/*
 * Sometimes it may be necessary only to view the drugs that have been selected 
 * so far. This is where this function comes into play
 */
function showSelectedDrugsOnly(){
    $('ulDrugs').innerHTML = "";
    current_generic = null;

    var k = 0;

    for(var d = 0; d < generics.length; d++){
        for(var drug in selectedGenerics[current_diagnosis]){
            if(generics[d][0].toLowerCase().match("^" + drug.toLowerCase() + "$")){
                var li = document.createElement("li");
                li.id = "option" + generics[d][0];
                li.innerHTML = generics[d][0].toProperCase();
                li.style.padding = "15px";

                if(k%2>0){
                    li.style.backgroundColor = "#eee";
                }
                li.style.color = "#000";

                if(selectedGenerics[current_diagnosis]){
                    if(selectedGenerics[current_diagnosis][generics[d][0].toUpperCase()]){
                        li.style.backgroundColor = "yellowgreen";
                        li.style.color = "#fff";
                    }
                }

                li.setAttribute("concept_id", generics[d][1])
                li.onclick = function(){
                    loadDosageFrequency(this.getAttribute("concept_id"));

                    current_generic = this.innerHTML.toUpperCase();

                    if(this.style.backgroundColor == "lightblue"){
                        if(selectedGenerics[current_diagnosis]){
                            delete selectedGenerics[current_diagnosis][current_generic];
                        }
                    }

                    
                    var tds = document.getElementsByName("group2");

                    for(var k = 0; k < tds.length; k++){
                        var p = String(tds[k].value).match(/\d$/);

                        if(p){
                            $("group2_" + (p==0?10:p)).bgColor = "";
                            var rdos = $("group2_" + (p==0?10:p)).getElementsByTagName("input");
                            if(rdos[0])
                                rdos[0].checked = false;

                            if($("group1_" + (((((p==0?10:p)-1)*10)+1) + "-" + ((((p==0?10:p)-1)+1)*10)))){
                                $("group1_" + (((((p==0?10:p)-1)*10)+1) + "-" + ((((p==0?10:p)-1)+1)*10))).bgColor = "#DDDDDD";

                                var rdos2 = $("group1_" + (((((p==0?10:p)-1)*10)+1) + "-" +
                                    ((((p==0?10:p)-1)+1)*10))).getElementsByTagName("input");

                                if(rdos2[0])
                                    rdos2[0].checked = false;
                            }
                        }

                    }

                    // Clear Frequencies
                    for(var j = 0; j < $('ulFreqs').childNodes.length; j++){
                        $('ulFreqs').childNodes[j].style.backgroundColor = "";
                        if(j%2>0){
                            $('ulFreqs').childNodes[j].style.backgroundColor = "#eee";
                        }
                        $('ulFreqs').childNodes[j].style.color = "#000";

                        if(selectedGenerics[current_diagnosis]){
                            if(selectedGenerics[current_diagnosis][current_generic]){
                                if(selectedGenerics[current_diagnosis][current_generic]["frequency"] ==
                                    $('ulFreqs').childNodes[j].innerHTML.toUpperCase()){

                                    $('ulFreqs').childNodes[j].style.backgroundColor = "yellowgreen";
                                    $('ulFreqs').childNodes[j].style.color = "#fff";
                                }
                            }
                        }
                    }

                    for(var j = 0; j < $('ulDrugs').childNodes.length; j++){
                        if(selectedGenerics[current_diagnosis]){
                            if(selectedGenerics[current_diagnosis][$('ulDrugs').childNodes[j].innerHTML.toUpperCase()]){
                                $('ulDrugs').childNodes[j].style.backgroundColor = "yellowgreen";
                                $('ulDrugs').childNodes[j].style.color = "white";
                            } else {
                                if(j%2>0){
                                    $('ulDrugs').childNodes[j].style.backgroundColor = "#eee";
                                } else {
                                    $('ulDrugs').childNodes[j].style.backgroundColor = "";
                                }
                                $('ulDrugs').childNodes[j].style.color = "black";
                            }
                        } else {
                            if(j%2>0){
                                $('ulDrugs').childNodes[j].style.backgroundColor = "#eee";
                            } else {
                                $('ulDrugs').childNodes[j].style.backgroundColor = "";
                            }
                            $('ulDrugs').childNodes[j].style.color = "black";
                        }
                    }
                    this.style.backgroundColor = "lightblue";
                    this.style.color = "black";

                }

                $('ulDrugs').appendChild(li);

                k++;
            }
        }
    }

}