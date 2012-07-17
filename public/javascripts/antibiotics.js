/* antibiotics.js
 *
 *  This is a supporting file for the Outpatient System which contains methods for
 *  updating Antibiotic Lab Results.
 *
 *  It generates a dynamic interface for multiple selection of antibiotics and
 *  corresponding results (Sensitive, Intermediate, Resistant or Not Done).
 *
 *  To use the interface, a user selects an Antibiotic and then for each selected
 *  Antibiotic, an hash containing the sets of selected Antibiotics and their
 *  results is created.
 *
 *  A given Antibiotic will be known to have corresponding values if it is highlighted
 *  in orange when it is not the focus selection and will be highlight normal color
 *  when selected. Only results for the selected entry are selected at a given
 *  selection instance
 *  
 */

// Global variables
var current_antibiotic = null;
var selectedAntibiotics = {};

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
function generateAntibiotics(){
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
    mainDiv.style.margin = "20px";

    parent_container.appendChild(mainDiv);

    var topLeftDiv = document.createElement("div");
    topLeftDiv.style.width = "48.6%";
    topLeftDiv.style.height = "8%";
    topLeftDiv.style.backgroundColor = "#fff";
    topLeftDiv.style.cssFloat = "left";
    topLeftDiv.style.border = "1px solid #ccc";
    topLeftDiv.style.paddingTop = "10px";
    topLeftDiv.style.paddingLeft = "10px";
    topLeftDiv.innerHTML = "Antibiotic";
    topLeftDiv.style.fontSize = "1.8em";

    mainDiv.appendChild(topLeftDiv);

    var topRightDiv = document.createElement("div");
    topRightDiv.style.width = "48.6%";
    topRightDiv.style.height = "8%";
    topRightDiv.style.backgroundColor = "#fff";
    topRightDiv.style.cssFloat = "right";
    topRightDiv.style.border = "1px solid #ccc";
    topRightDiv.style.paddingTop = "10px";
    topRightDiv.style.paddingLeft = "10px";
    topRightDiv.innerHTML = "Result";
    topRightDiv.style.fontSize = "1.8em";

    mainDiv.appendChild(topRightDiv);

    var bottomLeftDiv = document.createElement("div");
    bottomLeftDiv.style.width = "49.6%";
    bottomLeftDiv.style.height = "89%";
    bottomLeftDiv.style.backgroundColor = "#fff";
    bottomLeftDiv.style.cssFloat = "left";
    bottomLeftDiv.style.border = "1px solid #ccc";
    bottomLeftDiv.style.overflow = "auto";

    mainDiv.appendChild(bottomLeftDiv);

    var bottomRightDiv = document.createElement("div");
    bottomRightDiv.style.width = "49.6%";
    bottomRightDiv.style.height = "89%";
    bottomRightDiv.style.backgroundColor = "#fff";
    bottomRightDiv.style.cssFloat = "right";
    bottomRightDiv.style.border = "1px solid #ccc";
    bottomRightDiv.style.overflow = "auto";

    mainDiv.appendChild(bottomRightDiv);

    var ulLeft = document.createElement("ul");
    ulLeft.id = "ulLeft";
    ulLeft.style.fontSize = "1.7em";
    ulLeft.style.listStyle = "none";
    ulLeft.style.padding = "0px";

    bottomLeftDiv.appendChild(ulLeft);

    var ulRight = document.createElement("ul");
    ulRight.id = "ulRight";
    ulRight.style.fontSize = "1.7em";
    ulRight.style.listStyle = "none";
    ulRight.style.padding = "0px";

    bottomRightDiv.appendChild(ulRight);

    for(var i = 0; i < antibiotics.length; i++){
        var li = document.createElement("li");
        li.id = "option" + antibiotics[i];
        li.innerHTML = antibiotics[i];
        li.style.padding = "15px";
        li.onclick = function(){
            for(var j = 0; j < $('ulRight').childNodes.length; j++){
                $('ulRight').childNodes[j].style.backgroundColor = "";
            }
            current_antibiotic = this.innerHTML;
            for(var el = 0; el < $('ulLeft').childNodes.length; el++){
                if(selectedAntibiotics[$('ulLeft').childNodes[el].innerHTML]){
                    $('ulLeft').childNodes[el].style.backgroundColor = "yellowgreen";
                    $('ulLeft').childNodes[el].style.color = "white";
                } else {
                    $('ulLeft').childNodes[el].style.backgroundColor = "";
                    $('ulLeft').childNodes[el].style.color = "black";
                }
            }
            this.style.backgroundColor = "lightblue";
            this.style.color = "black";

            if(selectedAntibiotics[this.innerHTML]){                
                $("option" + selectedAntibiotics[this.innerHTML]).style.backgroundColor = "lightblue";
            }
        }

        ulLeft.appendChild(li);
    }

    var results = ["Sensitive", "Intermediate", "Resistant", "Not Done"];

    for(var i = 0; i < results.length; i++){
        var li = document.createElement("li");
        li.id = "option" + results[i];
        li.innerHTML = results[i];
        li.style.padding = "15px";
        li.onclick = function(){
            if(current_antibiotic){
                selectedAntibiotics[current_antibiotic] = this.innerHTML;
            }
            
            for(var el = 0; el < $('ulRight').childNodes.length; el++){
                $('ulRight').childNodes[el].style.backgroundColor = "";
            }
            this.style.backgroundColor = "lightblue";
        }

        ulRight.appendChild(li);
    }

}

// Remove the created interface and create corresponding controls ready for storage
function removeAntibiotics(){
    
    for(var item in selectedAntibiotics){

        var value_coded = document.createElement("input");
        value_coded.type = "hidden";
        value_coded.name = "observations[][value_coded_or_text]";
        value_coded.value = selectedAntibiotics[item];

        document.forms[0].appendChild(value_coded);

        var parent = document.createElement("input");
        parent.type = "hidden";
        parent.name = "observations[][parent_concept_name]";
        parent.value = "LAB TEST RESULT";

        document.forms[0].appendChild(parent);

        var concept = document.createElement("input");
        concept.type = "hidden";
        concept.name = "observations[][concept_name]";
        concept.value = item;

        document.forms[0].appendChild(concept);

        var patientid = document.createElement("input");
        patientid.type = "hidden";
        patientid.name = "observations[][patient_id]";
        patientid.value = patient_id;

        document.forms[0].appendChild(patientid);

        var obsdate = document.createElement("input");
        obsdate.type = "hidden";
        obsdate.name = "observations[][obs_datetime]";
        obsdate.value = datetime;

        document.forms[0].appendChild(obsdate);
    }

    if($("parent_container")){
        $("content").removeChild($("parent_container"));
    }

}