// drugs.js

var controlCount = 0;
var current_drug = "";

function $(id){
    return document.getElementById(id);
}

String.prototype.toProperCase = function()
{
    return this.toLowerCase().replace(/^(.)|\s(.)/g,
        function($1) {
            return $1.toUpperCase();
        });
}

function valueExists(number_array, number){
    for(var i = 0; i < number_array.length; i++){
        if(number_array[i] == number){
            return true;
        }
    }
    return false;
}

function generateDrugs(){
    if($("parent_container")){
        $("content").removeChild($("parent_container"));
    }

    var parent_container = document.createElement("div");
    parent_container.id = "parent_container";
    parent_container.style.position = "absolute";
    parent_container.style.marginLeft = "-500px";
    parent_container.style.marginTop = "-380px";
    parent_container.style.top = "50%";
    parent_container.style.left = "50%";
    parent_container.style.height = "675px";
    parent_container.style.width = "1000px";
    parent_container.style.overflow = "hidden";
    parent_container.style.zIndex = "20";
    parent_container.style.backgroundColor = "#FFFFFF";

    $("content").appendChild(parent_container);
    
    var mainTable = document.createElement("table");
    mainTable.width = "100%";
    mainTable.cellPadding = 30;

    parent_container.appendChild(mainTable);

    var mainTBody = document.createElement("tbody");
    var trMain = document.createElement("tr");
    var tdMain = document.createElement("td");

    tdMain.innerHTML = "<br />";

    mainTable.appendChild(mainTBody);
    mainTBody.appendChild(trMain);
    trMain.appendChild(tdMain);

    var tblBorder = document.createElement("table");
    var tbodyBorder = document.createElement("tbody");

    var trBorder1 = document.createElement("tr");
    
    var tdBorder1 = document.createElement("td");
    tdBorder1.width = "28%";

    var tdBorder2 = document.createElement("td");
    tdBorder2.width = "54%";

    var tdBorder4 = document.createElement("td");
    tdBorder4.width = "18%";

    tblBorder.bgColor = "#000000";
    tblBorder.width = "100%";
    tblBorder.cellSpacing = 1;
    tblBorder.cellPadding = 0;

    trBorder1.appendChild(tdBorder1);
    tbodyBorder.appendChild(trBorder1);

    trBorder1.appendChild(tdBorder2);
    tbodyBorder.appendChild(trBorder1);

    trBorder1.appendChild(tdBorder4);
    tbodyBorder.appendChild(trBorder1);

    tblBorder.appendChild(tbodyBorder);

    tdMain.appendChild(tblBorder);

    var title = document.createElement("label");
    title.innerHTML = "Treatments";
    title.style.fontSize = "2em";
    title.style.position = "absolute";
    title.style.top = "5px";
    title.style.left = "25px";

    parent_container.appendChild(title);

    // GROUP 1
    var tbl1 = document.createElement("table");
    tbl1.style.width = "100%";
    tbl1.style.height = "570px";
    tbl1.style.backgroundColor = "#EEEEEE";
    tbl1.border = 0;
    tbl1.cellPadding = 3;
    tbl1.cellSpacing = 0;

    var tbody1 = document.createElement("tbody");
    var tr1 = document.createElement("tr");
    var td1 = document.createElement("th");
    td1.innerHTML = "DRUG";
    td1.align = "left";
    td1.bgColor = "#CCCCCC";
    
    var tr1b = document.createElement("tr");
    var td1b = document.createElement("td");

    tr1.appendChild(td1);
    tbl1.appendChild(tr1);

    tr1b.appendChild(td1b);
    tbl1.appendChild(tr1b);

    tbl1.appendChild(tbody1);
    
    var div1 = document.createElement("div");
    div1.style.width = "100%";
    div1.style.height = "570px";
    div1.style.overflow = "auto";
    div1.id = "div1";

    td1b.appendChild(div1);
    tdBorder1.appendChild(tbl1);

    // MIDDLE CONTAINER
    var divMid = document.createElement("div");
    divMid.style.width = "100%";
    divMid.style.height = "602px";
    divMid.style.overflow = "hidden";
    divMid.id = "divMid";
    divMid.style.backgroundColor = "#EEEEEE";

    tdBorder2.appendChild(divMid);

    // GROUP 4
    var tbl4 = document.createElement("table");
    tbl4.style.width = "100%";
    tbl4.style.height = "570px";
    tbl4.style.backgroundColor = "#EEEEEE";
    tbl4.border = 0;
    tbl4.cellPadding = 3;
    tbl4.cellSpacing = 0;

    var tbody4 = document.createElement("tbody");
    var tr4 = document.createElement("tr");
    var td4 = document.createElement("th");
    td4.innerHTML = "DURATION";
    td4.align = "left";
    td4.bgColor = "#CCCCCC";

    var tr4b = document.createElement("tr");
    var td4b = document.createElement("td");
    td4b.id = "idDuration";

    tr4.appendChild(td4);
    tbl4.appendChild(tr4);

    tr4b.appendChild(td4b);
    tbl4.appendChild(tr4b);

    tbl4.appendChild(tbody4);

    var div4 = document.createElement("div");
    div4.style.width = "100%";
    div4.style.height = "570px";
    div4.style.overflow = "auto";
    div4.id = "div4";

    td4b.appendChild(div4);
    tdBorder4.appendChild(tbl4);

    var optTable1 = document.createElement("table");
    var optTBody1 = document.createElement("tbody");
    optTable1.width = "100%";
    optTable1.border = 0;
    optTable1.style.fontSize = "1.1em";
    optTable1.cellPadding = 5;

    optTable1.appendChild(optTBody1);

    generic.sort();

    for(var i = 0; i < generic.length; i++){
        var optTr1 = document.createElement("tr");
        var optTd1 = document.createElement("td");
        optTd1.id = "generic_cell_"+i;
        optTd1.setAttribute("generic", generic[i]);
        optTd1.bgColor = ((selected_drugs)?((selected_drugs[generic[i]])?"#F0F000":""):"");
        
        var optRadio1 = document.createElement("input");
        optRadio1.type = "radio";
        optRadio1.name = "generics";
        optRadio1.value = generic[i];
        optRadio1.id = "rdo_generic_cell_"+i;

        optTd1.onclick = function(){
            var id = "rdo_" + this.id;
            $(id).click();
        }

        optRadio1.onclick = function(){
            var id = this.id.match(/(generic_cell_\d+)/);

            if(id){
                if(this.checked){
                    var c = document.getElementsByName("generics");

                    for(var k = 0; k < c.length; k++){
                        var d = c[k].id.match(/(generic_cell_\d+)/);

                        if(d){
                            if($(d[1]).getAttribute("generic")){
                                var drug = $(d[1]).getAttribute("generic");

                                $(d[1]).bgColor = ((selected_drugs)?((selected_drugs[drug])?"#F0F000":""):"");
                            } else {
                                $(d[1]).bgColor = "";
                            }
                        }
                    }

                    $(id[1]).bgColor = "#add8e6";

                    if($(id[1]).getAttribute("generic")){
                        $("divMid").innerHTML = "";
                        loadDrugs($(id[1]).getAttribute("generic"), $("divMid"));
                    }

                    current_drug = this.value;
                    
                } else {
                    $(id[1]).bgColor = "";
                }
            }
        }

        optTd1.appendChild(optRadio1);
        optTr1.appendChild(optTd1);
        optTBody1.appendChild(optTr1);

        var lbl1 = document.createElement("label");
        lbl1.innerHTML = ((generic[i].toUpperCase()=="NIFEDIPINE SR")?"Nifedipine SR":generic[i].toProperCase());

        optTd1.appendChild(lbl1);
    }

    div1.appendChild(optTable1);

    var optTable4 = document.createElement("table");
    var optTBody4 = document.createElement("tbody");
    optTable4.width = "100%";
    optTable4.border = 0;
    optTable4.style.fontSize = "1.1em";
    optTable4.cellPadding = 5;

    optTable4.appendChild(optTBody4);

    div4.appendChild(optTable4);

    var duration = ["1 WEEK", "2 WEEKS", "1 MONTH", "2 MONTHS", "3 MONTHS", "4 MONTHS", "5 MONTHS", "6 MONTHS"];
    var duration_values = ["7", "14", "30", "60", "90", "120", "150", "180"];

    for(var i = 0; i < duration.length; i++){
        var optTr4 = document.createElement("tr");
        var optTd4 = document.createElement("td");
        optTd4.id = "duration_cell_"+i;
        optTd4.bgColor = ((durations)?((durations[duration_values[i]])?"#F0F000":""):"");

        var optRadio4 = document.createElement("input");
        optRadio4.type = "radio";
        optRadio4.name = "duration";
        optRadio4.value = duration_values[i];
        optRadio4.id = "rdo_duration_cell_"+i;

        optTd4.onclick = function(){
            var id = "rdo_" + this.id;
            $(id).click();
        }

        optRadio4.onclick = function(){
            var id = this.id.match(/(duration_cell_\d+)/);

            if(id){
                if(this.checked){
                    controlCount++;

                    var c = document.getElementsByName("duration");

                    for(var k = 0; k < c.length; k++){
                        var d = c[k].id.match(/(duration_cell_\d+)/);
                        
                        $(d[1]).bgColor = ((durations)?((durations[c[k].value])?"#F0F000":""):"");
                        
                    }

                    $(id[1]).bgColor = "#add8e6";

                    var generics = document.getElementsByName("generics");
                    var generics_value = "";

                    for(var g = 0; g < generics.length; g++){
                        if(generics[g].checked){
                            generics_value = generics[g].value;
                            break;
                        }
                    }
                    
                    var dose = document.getElementsByName("dose");
                    var dose_value = "";

                    for(var d = 0; d < dose.length; d++){
                        if(dose[d].checked){
                            dose_value = dose[d].value;
                            break;
                        }
                    }

                    var frequency = document.getElementsByName("frequency");
                    var frequency_value = "";

                    for(var f = 0; f < frequency.length; f++){
                        if(frequency[f].checked){
                            frequency_value = frequency[f].value;
                            break;
                        }
                    }

                    var group2 = document.getElementsByName("group2");
                    var group2_value = "";

                    var group4 = document.getElementsByName("group4");
                    var group4_value = "";

                    var group6 = document.getElementsByName("group6");
                    var group6_value = "";

                    if(!generics_value.match(/^$/)){
                        
                        if((dose_value.match(/^$/) && frequency_value.match(/^$/)) ||
                            (dose_value.match(/^$/) && current_drug.toLowerCase() == "glibenclamide")){

                            for(var g2 = 0; g2 < group2.length; g2++){
                                if(group2[g2].checked){
                                    group2_value = group2[g2].value;
                                    break;
                                }
                            }

                            for(var g4 = 0; g4 < group4.length; g4++){
                                if(group4[g4].checked){
                                    group4_value = group4[g4].value;
                                    break;
                                }
                            }

                            for(var g6 = 0; g6 < group6.length; g6++){
                                if(group6[g6].checked){
                                    group6_value = group6[g6].value;
                                    break;
                                }
                            }

                            /*
                             *
                             *  SUFFIX CODE LEGEND
                             *
                             *          0.  generic
                             *          1.  drug_strength
                             *          2.  frequency
                             *          3.  duration
                             *          4.  morning_dose
                             *          5.  afternoon_dose
                             *          6.  evening_dose
                             *          7.  diagnosis
                             *          8.  patient_id
                             *          9.  suggestion
                             *          10. concept_name
                             *          11. value_coded_text
                             *          12. type_of_prescription
                             *          
                             */

                            if((!group2_value.match(/^$/) || !group4_value.match(/^$/) || !group6_value.match(/^$/)) && generics_value == "SOLUBLE INSULIN"){

                                var txtConceptName = document.createElement("input");
                                txtConceptName.type = "hidden";
                                txtConceptName.name = "prescriptions[][concept_name]";
                                txtConceptName.value = "DIAGNOSIS";
                                txtConceptName.id = "group_"+controlCount+"_10";

                                document.forms[0].appendChild(txtConceptName);

                                var txtValueCodedText = document.createElement("input");
                                txtValueCodedText.type = "hidden";
                                txtValueCodedText.name = "prescriptions[][value_coded_or_text]";
                                txtValueCodedText.value = "DIABETES MEDICATION";
                                txtValueCodedText.id = "group_"+controlCount+"_11";

                                document.forms[0].appendChild(txtValueCodedText);

                                var txtSuggestion = document.createElement("input");
                                txtSuggestion.type = "hidden";
                                txtSuggestion.name = "prescriptions[][suggestion]";
                                txtSuggestion.value = 0;
                                txtSuggestion.id = "group_"+controlCount+"_9";

                                document.forms[0].appendChild(txtSuggestion);

                                var txtTypeOfPrescription = document.createElement("input");
                                txtTypeOfPrescription.type = "hidden";
                                txtTypeOfPrescription.name = "prescriptions[][type_of_prescription]";
                                txtTypeOfPrescription.value = "variable";
                                txtTypeOfPrescription.id = "group_"+controlCount+"_12";

                                document.forms[0].appendChild(txtTypeOfPrescription);

                                var txtPatientID = document.createElement("input");
                                txtPatientID.type = "hidden";
                                txtPatientID.name = "prescriptions[][patient_id]";
                                txtPatientID.value = $('patient_id').value;
                                txtPatientID.id = "group_"+controlCount+"_8";

                                document.forms[0].appendChild(txtPatientID);

                                var txtDiagnosis = document.createElement("input");
                                txtDiagnosis.type = "hidden";
                                txtDiagnosis.name = "prescriptions[][diagnosis]";
                                txtDiagnosis.value = "DIABETES MEDICATION";
                                txtDiagnosis.id = "group_"+controlCount+"_7";

                                document.forms[0].appendChild(txtDiagnosis);

                                var txtGenerics = document.createElement("input");
                                txtGenerics.type = "hidden";
                                txtGenerics.name = "prescriptions[][generic]";
                                txtGenerics.value = generics_value;
                                txtGenerics.id = "group_"+controlCount+"_0";

                                document.forms[0].appendChild(txtGenerics);

                                var txtGroup2 = document.createElement("input");
                                txtGroup2.type = "hidden";
                                txtGroup2.name = "prescriptions[][morning_dose]";
                                txtGroup2.value = group2_value;
                                txtGroup2.id = "group_"+controlCount+"_4";

                                document.forms[0].appendChild(txtGroup2);

                                var txtGroup4 = document.createElement("input");
                                txtGroup4.type = "hidden";
                                txtGroup4.name = "prescriptions[][afternoon_dose]";
                                txtGroup4.value = group4_value;
                                txtGroup4.id = "group_"+controlCount+"_5";

                                document.forms[0].appendChild(txtGroup4);

                                var txtGroup6 = document.createElement("input");
                                txtGroup6.type = "hidden";
                                txtGroup6.name = "prescriptions[][evening_dose]";
                                txtGroup6.value = group6_value;
                                txtGroup6.id = "group_"+controlCount+"_6";

                                document.forms[0].appendChild(txtGroup6);

                                var txtDuration = document.createElement("input");
                                txtDuration.type = "hidden";
                                txtDuration.name = "prescriptions[][duration]";
                                txtDuration.value = this.value;
                                txtDuration.id = "group_"+controlCount+"_3";

                                document.forms[0].appendChild(txtDuration);

                                generateDrugs();

                            } else if((!group2_value.match(/^$/) || !group6_value.match(/^$/)) && generics_value == "LENTE INSULIN"){

                                var txtConceptName = document.createElement("input");
                                txtConceptName.type = "hidden";
                                txtConceptName.name = "prescriptions[][concept_name]";
                                txtConceptName.value = "DIAGNOSIS";
                                txtConceptName.id = "group_"+controlCount+"_10";

                                document.forms[0].appendChild(txtConceptName);

                                var txtValueCodedText = document.createElement("input");
                                txtValueCodedText.type = "hidden";
                                txtValueCodedText.name = "prescriptions[][value_coded_or_text]";
                                txtValueCodedText.value = "DIABETES MEDICATION";
                                txtValueCodedText.id = "group_"+controlCount+"_11";

                                document.forms[0].appendChild(txtValueCodedText);

                                var txtSuggestion = document.createElement("input");
                                txtSuggestion.type = "hidden";
                                txtSuggestion.name = "prescriptions[][suggestion]";
                                txtSuggestion.value = 0;
                                txtSuggestion.id = "group_"+controlCount+"_9";

                                document.forms[0].appendChild(txtSuggestion);

                                var txtTypeOfPrescription = document.createElement("input");
                                txtTypeOfPrescription.type = "hidden";
                                txtTypeOfPrescription.name = "prescriptions[][type_of_prescription]";
                                txtTypeOfPrescription.value = "variable";
                                txtTypeOfPrescription.id = "group_"+controlCount+"_12";

                                document.forms[0].appendChild(txtTypeOfPrescription);

                                var txtPatientID = document.createElement("input");
                                txtPatientID.type = "hidden";
                                txtPatientID.name = "prescriptions[][patient_id]";
                                txtPatientID.value = $('patient_id').value;
                                txtPatientID.id = "group_"+controlCount+"_8";

                                document.forms[0].appendChild(txtPatientID);

                                var txtDiagnosis = document.createElement("input");
                                txtDiagnosis.type = "hidden";
                                txtDiagnosis.name = "prescriptions[][diagnosis]";
                                txtDiagnosis.value = "DIABETES MEDICATION";
                                txtDiagnosis.id = "group_"+controlCount+"_7";

                                document.forms[0].appendChild(txtDiagnosis);

                                var txtGenerics = document.createElement("input");
                                txtGenerics.type = "hidden";
                                txtGenerics.name = "prescriptions[][generic]";
                                txtGenerics.value = generics_value;
                                txtGenerics.id = "group_"+controlCount+"_0";

                                document.forms[0].appendChild(txtGenerics);

                                var txtGroup2 = document.createElement("input");
                                txtGroup2.type = "hidden";
                                txtGroup2.name = "prescriptions[][morning_dose]";
                                txtGroup2.value = group2_value;
                                txtGroup2.id = "group_"+controlCount+"_4";

                                document.forms[0].appendChild(txtGroup2);

                                var txtGroup6 = document.createElement("input");
                                txtGroup6.type = "hidden";
                                txtGroup6.name = "prescriptions[][evening_dose]";
                                txtGroup6.value = group6_value;
                                txtGroup6.id = "group_"+controlCount+"_6";

                                document.forms[0].appendChild(txtGroup6);

                                var txtDuration = document.createElement("input");
                                txtDuration.type = "hidden";
                                txtDuration.name = "prescriptions[][duration]";
                                txtDuration.value = this.value;
                                txtDuration.id = "group_"+controlCount+"_3";

                                document.forms[0].appendChild(txtDuration);

                                generateDrugs();
                                    
                            }
                            
                        } else if(!dose_value.match(/^$/) && !frequency_value.match(/^$/)){

                            var txtConceptName = document.createElement("input");
                            txtConceptName.type = "hidden";
                            txtConceptName.name = "prescriptions[][concept_name]";
                            txtConceptName.value = "DIAGNOSIS";
                            txtConceptName.id = "group_"+controlCount+"_10";

                            document.forms[0].appendChild(txtConceptName);

                            var txtValueCodedText = document.createElement("input");
                            txtValueCodedText.type = "hidden";
                            txtValueCodedText.name = "prescriptions[][value_coded_or_text]";
                            txtValueCodedText.value = "DIABETES MEDICATION";
                            txtValueCodedText.id = "group_"+controlCount+"_11";

                            document.forms[0].appendChild(txtValueCodedText);

                            var txtSuggestion = document.createElement("input");
                            txtSuggestion.type = "hidden";
                            txtSuggestion.name = "prescriptions[][suggestion]";
                            txtSuggestion.value = 0;
                            txtSuggestion.id = "group_"+controlCount+"_9";

                            document.forms[0].appendChild(txtSuggestion);

                            var txtTypeOfPrescription = document.createElement("input");
                            txtTypeOfPrescription.type = "hidden";
                            txtTypeOfPrescription.name = "prescriptions[][type_of_prescription]";
                            txtTypeOfPrescription.value = "standard";
                            txtTypeOfPrescription.id = "group_"+controlCount+"_12";

                            document.forms[0].appendChild(txtTypeOfPrescription);

                            var txtPatientID = document.createElement("input");
                            txtPatientID.type = "hidden";
                            txtPatientID.name = "prescriptions[][patient_id]";
                            txtPatientID.value = $('patient_id').value;
                            txtPatientID.id = "group_"+controlCount+"_8";

                            document.forms[0].appendChild(txtPatientID);

                            var txtDiagnosis = document.createElement("input");
                            txtDiagnosis.type = "hidden";
                            txtDiagnosis.name = "prescriptions[][diagnosis]";
                            txtDiagnosis.value = "DIABETES MEDICATION";
                            txtDiagnosis.id = "group_"+controlCount+"_7";

                            document.forms[0].appendChild(txtDiagnosis);

                            var txtGenerics = document.createElement("input");
                            txtGenerics.type = "hidden";
                            txtGenerics.name = "prescriptions[][generic]";
                            txtGenerics.value = generics_value;
                            txtGenerics.id = "group_"+controlCount+"_0";

                            document.forms[0].appendChild(txtGenerics);

                            var txtDose = document.createElement("input");
                            txtDose.type = "hidden";
                            txtDose.name = "prescriptions[][drug_strength]";
                            txtDose.value = dose_value;
                            txtDose.id = "group_"+controlCount+"_1";

                            document.forms[0].appendChild(txtDose);

                            var txtFrequency = document.createElement("input");
                            txtFrequency.type = "hidden";
                            txtFrequency.name = "prescriptions[][frequency]";
                            txtFrequency.value = frequency_value;
                            txtFrequency.id = "group_"+controlCount+"_2";

                            document.forms[0].appendChild(txtFrequency);

                            var txtDuration = document.createElement("input");
                            txtDuration.type = "hidden";
                            txtDuration.name = "prescriptions[][duration]";
                            txtDuration.value = this.value;
                            txtDuration.id = "group_"+controlCount+"_3";

                            document.forms[0].appendChild(txtDuration);

                            generateDrugs();

                        } else if(!dose_value.match(/^$/) && current_drug.toLowerCase() == "glibenclamide"){
                            var r = dose_value.match(/\[[^\]]+\]/g);
                            var morning_dose = "";
                            var evening_dose = "";
                            
                            if(r){
                                for(var j=0; j < r.length; j++){
                                    var vals = r[j].match(/\[(.+):(.+)\]/);

                                    if(vals){
                                        switch(vals[2].toUpperCase()){
                                            case "AM":
                                                morning_dose = vals[1].match(/\d+/g)[0];
                                                break;
                                            case "PM":
                                                evening_dose = vals[1].match(/\d+/g)[0];
                                                break;
                                        }

                                    }
                                }

                                var txtConceptName = document.createElement("input");
                                txtConceptName.type = "hidden";
                                txtConceptName.name = "prescriptions[][concept_name]";
                                txtConceptName.value = "DIAGNOSIS";
                                txtConceptName.id = "group_"+controlCount+"_10";

                                document.forms[0].appendChild(txtConceptName);

                                var txtValueCodedText = document.createElement("input");
                                txtValueCodedText.type = "hidden";
                                txtValueCodedText.name = "prescriptions[][value_coded_or_text]";
                                txtValueCodedText.value = "DIABETES MEDICATION";
                                txtValueCodedText.id = "group_"+controlCount+"_11";

                                document.forms[0].appendChild(txtValueCodedText);

                                var txtSuggestion = document.createElement("input");
                                txtSuggestion.type = "hidden";
                                txtSuggestion.name = "prescriptions[][suggestion]";
                                txtSuggestion.value = 0;
                                txtSuggestion.id = "group_"+controlCount+"_9";

                                document.forms[0].appendChild(txtSuggestion);

                                var txtTypeOfPrescription = document.createElement("input");
                                txtTypeOfPrescription.type = "hidden";
                                txtTypeOfPrescription.name = "prescriptions[][type_of_prescription]";
                                txtTypeOfPrescription.value = "variable";
                                txtTypeOfPrescription.id = "group_"+controlCount+"_12";

                                document.forms[0].appendChild(txtTypeOfPrescription);

                                var txtPatientID = document.createElement("input");
                                txtPatientID.type = "hidden";
                                txtPatientID.name = "prescriptions[][patient_id]";
                                txtPatientID.value = $('patient_id').value;
                                txtPatientID.id = "group_"+controlCount+"_8";

                                document.forms[0].appendChild(txtPatientID);

                                var txtDiagnosis = document.createElement("input");
                                txtDiagnosis.type = "hidden";
                                txtDiagnosis.name = "prescriptions[][diagnosis]";
                                txtDiagnosis.value = "DIABETES MEDICATION";
                                txtDiagnosis.id = "group_"+controlCount+"_7";

                                document.forms[0].appendChild(txtDiagnosis);

                                var txtGenerics = document.createElement("input");
                                txtGenerics.type = "hidden";
                                txtGenerics.name = "prescriptions[][generic]";
                                txtGenerics.value = generics_value;
                                txtGenerics.id = "group_"+controlCount+"_0";

                                document.forms[0].appendChild(txtGenerics);

                                var txtGroup2 = document.createElement("input");
                                txtGroup2.type = "hidden";
                                txtGroup2.name = "prescriptions[][morning_dose]";
                                txtGroup2.value = morning_dose;
                                txtGroup2.id = "group_"+controlCount+"_4";

                                document.forms[0].appendChild(txtGroup2);

                                var txtGroup6 = document.createElement("input");
                                txtGroup6.type = "hidden";
                                txtGroup6.name = "prescriptions[][evening_dose]";
                                txtGroup6.value = evening_dose;
                                txtGroup6.id = "group_"+controlCount+"_6";

                                document.forms[0].appendChild(txtGroup6);

                                var txtDuration = document.createElement("input");
                                txtDuration.type = "hidden";
                                txtDuration.name = "prescriptions[][duration]";
                                txtDuration.value = this.value;
                                txtDuration.id = "group_"+controlCount+"_3";

                                document.forms[0].appendChild(txtDuration);

                                generateDrugs();
                                    
                            } else {
                                return;
                            }
                            
                        }
                    }
                    
                } else {
                    $(id[1]).bgColor = "";
                }
            }
        }

        optTd4.appendChild(optRadio4);
        optTr4.appendChild(optTd4);
        optTBody4.appendChild(optTr4);

        var lbl4 = document.createElement("label");
        lbl4.innerHTML = duration[i].toProperCase();

        optTd4.appendChild(lbl4);
    }

    var btnView = document.createElement("input");
    btnView.type = "button";
    btnView.value = "View Selection";
    btnView.style.width = "150px";
    btnView.style.height = "40px";
    btnView.style.fontSize = "1em";
    
    btnView.onclick = function(){
        viewSelectedDrugs();
    }

    var trBtn = document.createElement("tr");
    var tdBtn = document.createElement("td");

    trBtn.appendChild(tdBtn);
    tdBtn.appendChild(btnView);

    optTBody4.appendChild(trBtn);

}

function viewSelectedDrugs(){
    if($("parent_container")){
        $("content").removeChild($("parent_container"));
    }

    var parent_container = document.createElement("div");
    parent_container.id = "parent_container";
    parent_container.style.position = "absolute";
    parent_container.style.marginLeft = "-500px";
    parent_container.style.marginTop = "-380px";
    parent_container.style.top = "50%";
    parent_container.style.left = "50%";
    parent_container.style.height = "675px";
    parent_container.style.width = "1000px";
    parent_container.style.overflow = "hidden";
    parent_container.style.zIndex = "20";
    parent_container.style.backgroundColor = "#FFFFFF";

    $("content").appendChild(parent_container);

    var mainTable = document.createElement("table");
    mainTable.width = "100%";
    mainTable.cellPadding = 30;

    parent_container.appendChild(mainTable);

    var mainTBody = document.createElement("tbody");
    var trMain = document.createElement("tr");
    var tdMain = document.createElement("td");

    tdMain.innerHTML = "<br />";

    mainTable.appendChild(mainTBody);
    mainTBody.appendChild(trMain);
    trMain.appendChild(tdMain);

    var tblBorder = document.createElement("table");
    var tbodyBorder = document.createElement("tbody");

    var trBorder1 = document.createElement("tr");

    var tdBorder1 = document.createElement("td");
    tdBorder1.width = "28%";

    var tdBorder2 = document.createElement("td");
    tdBorder2.width = "54%";

    var tdBorder4 = document.createElement("td");
    tdBorder4.width = "18%";

    tblBorder.bgColor = "#000000";
    tblBorder.width = "100%";
    tblBorder.cellSpacing = 1;
    tblBorder.cellPadding = 0;

    trBorder1.appendChild(tdBorder1);
    tbodyBorder.appendChild(trBorder1);

    tblBorder.appendChild(tbodyBorder);

    tdMain.appendChild(tblBorder);

    var title = document.createElement("label");
    title.innerHTML = "Selected Treatments";
    title.style.fontSize = "2em";
    title.style.position = "absolute";
    title.style.top = "5px";
    title.style.left = "25px";

    parent_container.appendChild(title);

    var divMid = document.createElement("div");
    divMid.style.width = "100%";
    divMid.style.height = "602px";
    divMid.style.overflow = "hidden";
    divMid.id = "divMid";
    divMid.style.backgroundColor = "#EEEEEE";
    divMid.style.overflow = "auto";

    tdBorder1.appendChild(divMid);

    var tbl = document.createElement("table");
    tbl.cellSpacing = 1;
    tbl.cellPadding = 5;
    tbl.width = "100%";
    tbl.id = "tblFirst";
    
    var tbody = document.createElement("tbody");
    tbody.id = "tbody1";

    divMid.appendChild(tbl);
    tbl.appendChild(tbody);

    var tbl2 = document.createElement("table");
    tbl2.cellSpacing = 1;
    tbl2.cellPadding = 5;
    tbl2.width = "100%";
    tbl2.id = "tblSecond";

    var tbody2 = document.createElement("tbody");
    tbody2.id = "tbody2";

    var br = document.createElement("br");

    divMid.appendChild(br);
    
    divMid.appendChild(tbl2);
    tbl2.appendChild(tbody2);

    var trH1 = document.createElement("tr");
    var trH2 = document.createElement("tr");

    var s1 = ["DRUG", "DOSAGE", "FREQUENCY", "DURATION", "&nbsp;"];
    var s2 = ["DRUG", "morning dose", "lunchtime dose", "evening dose", "DURATION", "&nbsp;"];

    tbody.appendChild(trH1);
    tbody2.appendChild(trH2);

    for(var i = 0; i < s1.length; i++){
        var tdH = document.createElement("th");
        tdH.align = "left";
        tdH.bgColor = "#CCCCCC";

        tdH.innerHTML = s1[i];

        trH1.appendChild(tdH);
    }

    for(var i = 0; i < s2.length; i++){
        var tdH = document.createElement("th");
        tdH.align = "left";
        tdH.bgColor = "#CCCCCC";

        tdH.innerHTML = s2[i];

        trH2.appendChild(tdH);
    }

    var ctrls = document.getElementsByTagName("input");

    for(var i = 0; i < ctrls.length; i++){
        if(ctrls[i].name.match(/^prescriptions\[\]\[generic\]$/)){
            var tr = document.createElement("tr");

            var id = ctrls[i].id.match(/^group_(\d+)_\d+$/);
            
            if(id){
                tr.id = "row_"+id[1];
            }

            var td = document.createElement("td");

            if(ctrls[i+1].name.match(/^prescriptions\[\]\[drug_strength\]$/)){
                tbody.appendChild(tr);
                tr.appendChild(td);

                td.innerHTML = ctrls[i].value.toProperCase();
                td.bgColor = "#EAEAEA";

                var td2 = document.createElement("td");
                td2.align = "center";

                tr.appendChild(td2);

                td2.innerHTML = ctrls[i+1].value;

                if(ctrls[i+2].name.match(/^prescriptions\[\]\[frequency\]$/)){
                    var td3 = document.createElement("td");

                    tr.appendChild(td3);

                    td3.innerHTML = ctrls[i+2].value;
                    td3.bgColor = "#EAEAEA";
                    td3.align = "center";

                    if(ctrls[i+3].name.match(/^prescriptions\[\]\[duration\]$/)){
                        var td4 = document.createElement("td");
                        td4.align = "center";

                        tr.appendChild(td4);

                        td4.innerHTML = ctrls[i+3].value + " days";

                    }

                    var td5 = document.createElement("th");
                    td5.style.color = "#FF0000";
                    td5.id = "cell_"+id[1];

                    tr.appendChild(td5);

                    td5.innerHTML = "X";

                    td5.onclick = function(){
                        var idi = this.id.match(/^cell_(\d+)$/);

                        if(idi){
                            var ctrs = document.getElementsByTagName("input");

                            var lim = ctrs.length;
                                
                            for(var c = lim-1; c >= 0; c--){
                                if(ctrs[c].id.match("^group_"+idi[1]+"_\\d+$")){
                                    document.forms[0].removeChild(ctrs[c]);
                                }
                            }
                            $("tbody1").removeChild($("row_"+idi[1]));
                        }
                    }
                        
                }
            } else if(ctrls[i+1].name.match(/^prescriptions\[\]\[morning_dose\]$/)){
                tbody2.appendChild(tr);
                
                tr.appendChild(td);

                td.innerHTML = ctrls[i].value.toProperCase();

                var td2 = document.createElement("td");
                td2.bgColor = "#EAEAEA";
                td2.align = "center";

                tr.appendChild(td2);

                td2.innerHTML = ctrls[i+1].value;

                if(ctrls[i+2].name.match(/^prescriptions\[\]\[afternoon_dose\]$/)){
                    var td3 = document.createElement("td");
                    td3.align = "center";

                    tr.appendChild(td3);

                    td3.innerHTML = ctrls[i+2].value;

                    if(ctrls[i+3].name.match(/^prescriptions\[\]\[evening_dose\]$/)){
                        var td4 = document.createElement("td");
                        td4.align = "center";

                        tr.appendChild(td4);

                        td4.innerHTML = ctrls[i+3].value;

                        if(ctrls[i+4].name.match(/^prescriptions\[\]\[duration\]$/)){
                            var td5 = document.createElement("td");
                            td5.align = "center";

                            tr.appendChild(td5);

                            td5.innerHTML = ctrls[i+4].value + " days";

                        }

                        var td6 = document.createElement("th");
                        td6.style.color = "#FF0000";
                        td6.id = "cell_"+id[1];

                        tr.appendChild(td6);

                        td6.innerHTML = "X";

                        td6.onclick = function(){
                            var idi = this.id.match(/^cell_(\d+)$/);

                            if(idi){
                                var ctrs = document.getElementsByTagName("input");

                                var lim = ctrs.length;

                                for(var c = lim-1; c >= 0; c--){
                                    if(ctrs[c].id.match("^group_"+idi[1]+"_\\d+$")){
                                        document.forms[0].removeChild(ctrs[c]);
                                    }
                                }
                                $("tbody2").removeChild($("row_"+idi[1]));
                            }
                        }
                        
                    }
                } else {
                    var td3 = document.createElement("td");
                    td3.align = "center";

                    tr.appendChild(td3);

                    td3.innerHTML = "&nbsp;";

                    if(ctrls[i+2].name.match(/^prescriptions\[\]\[evening_dose\]$/)){
                        var td4 = document.createElement("td");
                        td4.align = "center";

                        tr.appendChild(td4);

                        td4.innerHTML = ctrls[i+2].value;

                        if(ctrls[i+3].name.match(/^prescriptions\[\]\[duration\]$/)){
                            var td5 = document.createElement("td");
                            td5.align = "center";

                            tr.appendChild(td5);

                            td5.innerHTML = ctrls[i+3].value + " days";

                        }

                        var td6 = document.createElement("th");
                        td6.style.color = "#FF0000";
                        td6.id = "cell_"+id[1];

                        tr.appendChild(td6);

                        td6.innerHTML = "X";

                        td6.onclick = function(){
                            var idi = this.id.match(/^cell_(\d+)$/);

                            var ctrs = document.getElementsByTagName("input");

                            var lim = ctrs.length;

                            for(var c = lim-1; c >= 0; c--){
                                if(ctrs[c].id.match("^group_"+idi[1]+"_\\d+$")){
                                    document.forms[0].removeChild(ctrs[c]);
                                }
                            }
                            $("tbody2").removeChild($("row_"+idi[1]));
                        }

                    }
                }
            }
        }

    }

    if(tbl.rows.length <= 1){
        var trD = document.createElement("tr");
        var tdD = document.createElement("td");
        tdD.colSpan = 4;
        tdD.align = "center";
        tdD.style.fontStyle = "italic";

        tdD.innerHTML = "No Drugs Selected in this Category";

        trD.appendChild(tdD);
        tbody.appendChild(trD);
    }

    if(tbl2.rows.length <= 1){
        var trD2 = document.createElement("tr");
        var tdD2 = document.createElement("td");
        tdD2.colSpan = 5;
        tdD2.align = "center";
        tdD2.style.fontStyle = "italic";

        tdD2.innerHTML = "No Drugs Selected in this Category";

        trD2.appendChild(tdD2);
        tbody2.appendChild(trD2);
    }

    var br2 = document.createElement("br");
    
    divMid.appendChild(br2);
    
    var btnContinue = document.createElement("input");
    btnContinue.type = "button";
    btnContinue.style.height = "60px";
    btnContinue.style.width = "100%";
    btnContinue.value = "Continue...";
    btnContinue.style.fontSize = "1.5em";
    btnContinue.align = "center";

    btnContinue.onclick = function(){
        generateDrugs();
    }

    divMid.appendChild(btnContinue);
}

function loadDrugs(drug, dosefreqdiv){
    
    switch(drug){
        case "SOLUBLE INSULIN":
            createSolubleInsulinDosageFrequencyTable(drug, dosefreqdiv);
            break;
        case "LENTE INSULIN":
            createLenteInsulinDosageFrequencyTable(drug, dosefreqdiv);
            break;
        default:
            createNormalDoseFrequencyTable(drug, dosefreqdiv);
            break;
    }

}

function createSolubleInsulinDosageFrequencyTable(drug, dosefreqdiv){
    var tbl = document.createElement("table");
    tbl.width = "100%";
    tbl.cellSpacing = 0;
    tbl.cellPadding = 3;

    var tbody = document.createElement("tbody");

    dosefreqdiv.appendChild(tbl);
    tbl.appendChild(tbody);

    var trTop = document.createElement("tr");
    var tdTop = document.createElement("th");
    tdTop.bgColor = "#CCCCCC";
    tdTop.align = "left";
    tdTop.innerHTML = "DOSAGE";

    tbl.appendChild(trTop);
    trTop.appendChild(tdTop);

    var trBody = document.createElement("tr");
    var tdBody = document.createElement("td");

    tbl.appendChild(trBody);
    trBody.appendChild(tdBody);

    var div = document.createElement("div");
    div.style.overflow = "auto";
    div.style.width = "100%";
    div.style.height = "602px";
    div.style.backgroundColor = "#EEEEEE";

    tdBody.appendChild(div);

    var tblContent = document.createElement("table");
    tblContent.cellSpacing = 1;
    tblContent.cellPadding = 2;
    tblContent.width = "100%";
    tblContent.border = 0;
    tblContent.style.fontSize = "0.7em";
    
    var trHead = document.createElement("tr");
    
    var tdHead1 = document.createElement("th");
    tdHead1.innerHTML = "morning";
    tdHead1.bgColor = "#999999";
    tdHead1.style.color = "#EEEEEE";
    tdHead1.colSpan = 2;

    var tdHead2 = document.createElement("th");
    tdHead2.innerHTML = "lunchtime";
    tdHead2.bgColor = "#999999";
    tdHead2.style.color = "#EEEEEE";
    tdHead2.colSpan = 2;
    
    var tdHead3 = document.createElement("th");
    tdHead3.innerHTML = "evening";
    tdHead3.bgColor = "#999999";
    tdHead3.style.color = "#EEEEEE";
    tdHead3.colSpan = 2;

    div.appendChild(tblContent);
    tblContent.appendChild(trHead);

    trHead.appendChild(tdHead1);
    trHead.appendChild(tdHead2);
    trHead.appendChild(tdHead3);

    var durat = document.getElementsByName("duration");

    for(var k = 0; k < durat.length; k++){
        var d = durat[k].id.match(/(duration_cell_\d+)/);

        if(d){
            $(d[1]).bgColor = ((durations)?((durations[durat[k].value])?"#F0F000":""):"");
            $("rdo_" + d[1]).checked = false;
        }
    }

    for(var i = 0; i < 10; i++){
        var tr = document.createElement("tr");
        
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

            this.offsetParent.bgColor = "#add8e6";
        }

        td2.appendChild(rdo2);

        var lbl2 = document.createElement("label");
        lbl2.style.width = "100%";
        lbl2.innerHTML = "&nbsp;";

        td2.appendChild(lbl2);

        tr.appendChild(td2);

        // SET 2:
        var td3 = document.createElement("td");
        td3.vAlign = "middle";
        td3.id = "group3_" + (((i*10)+1) + "-" + ((i+1)*10));
        td3.width = "19%";
        td3.bgColor = "#DDDDDD";

        td3.onclick = function(){
            var rdo = this.getElementsByTagName("input");

            if(rdo[0]){
                if(rdo[0].type=="radio") rdo[0].click();
            }
        }

        var rdo3 = document.createElement("input");
        rdo3.type = "radio";
        rdo3.value = (((i*10)+1) + "-" + ((i+1)*10));
        rdo3.name = "group3";

        rdo3.onclick = function(){
            var tds = document.getElementsByName("group3");

            for(var k = 0; k < tds.length; k++){
                $("group3_" + tds[k].value).bgColor = "#DDDDDD";
            }

            this.offsetParent.bgColor = "#add8e6";

            var targets = document.getElementsByName("group3");
            var v = this.value.split("-");
            var start = v[0];
            var end = v[1];

            var val = start;

            for(var k = 0; k < targets.length; k++){
                var td = $("group4_" + (k+1));

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

        td3.appendChild(rdo3);

        var lbl3 = document.createElement("label");
        lbl3.style.width = "100%";
        lbl3.innerHTML = (((i*10)+1) + "-" + ((i+1)*10));

        td3.appendChild(lbl3);

        tblContent.appendChild(tr);
        tr.appendChild(td3);


        var td4 = document.createElement("td");
        td4.vAlign = "middle";
        td4.id = "group4_" + (i+1);
        td4.width = "14%";

        td4.onclick = function(){
            var rdo = this.getElementsByTagName("input");

            if(rdo[0]){
                if(rdo[0].type=="radio") rdo[0].click();
            }
        }

        var rdo4 = document.createElement("input");
        rdo4.type = "radio";
        rdo4.name = "group4";

        rdo4.onclick = function(){
            var tds = document.getElementsByName("group4");

            for(var k = 0; k < tds.length; k++){
                var p = String(tds[k].value).match(/\d$/);

                if(p){
                    $("group4_" + (p==0?10:p)).bgColor = "";
                }

            }

            this.offsetParent.bgColor = "#add8e6";
        }

        td4.appendChild(rdo4);

        var lbl4 = document.createElement("label");
        lbl4.style.width = "100%";
        lbl4.innerHTML = "&nbsp;";

        td4.appendChild(lbl4);

        tr.appendChild(td4);

        // SET 3:
        var td5 = document.createElement("td");
        td5.vAlign = "middle";
        td5.id = "group5_" + (((i*10)+1) + "-" + ((i+1)*10));
        td5.width = "19%";
        td5.bgColor = "#DDDDDD";

        td5.onclick = function(){
            var rdo = this.getElementsByTagName("input");

            if(rdo[0]){
                if(rdo[0].type=="radio") rdo[0].click();
            }
        }

        var rdo5 = document.createElement("input");
        rdo5.type = "radio";
        rdo5.value = (((i*10)+1) + "-" + ((i+1)*10));
        rdo5.name = "group5";

        rdo5.onclick = function(){
            var tds = document.getElementsByName("group5");

            for(var k = 0; k < tds.length; k++){
                $("group5_" + tds[k].value).bgColor = "#DDDDDD";
            }

            this.offsetParent.bgColor = "#add8e6";

            var targets = document.getElementsByName("group5");
            var v = this.value.split("-");
            var start = v[0];
            var end = v[1];

            var val = start;

            for(var k = 0; k < targets.length; k++){
                var td = $("group6_" + (k+1));

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

        td5.appendChild(rdo5);

        var lbl5 = document.createElement("label");
        lbl5.style.width = "100%";
        lbl5.innerHTML = (((i*10)+1) + "-" + ((i+1)*10));

        td5.appendChild(lbl5);

        tblContent.appendChild(tr);
        tr.appendChild(td5);


        var td6 = document.createElement("td");
        td6.vAlign = "middle";
        td6.id = "group6_" + (i+1);
        td6.width = "14%";

        td6.onclick = function(){
            var rdo = this.getElementsByTagName("input");

            if(rdo[0]){
                if(rdo[0].type=="radio") rdo[0].click();
            }
        }

        var rdo6 = document.createElement("input");
        rdo6.type = "radio";
        rdo6.name = "group6";

        rdo6.onclick = function(){
            var tds = document.getElementsByName("group6");

            for(var k = 0; k < tds.length; k++){
                var p = String(tds[k].value).match(/\d$/);

                if(p){
                    $("group6_" + (p==0?10:p)).bgColor = "";
                }

            }

            this.offsetParent.bgColor = "#add8e6";
        }

        td6.appendChild(rdo6);

        var lbl6 = document.createElement("label");
        lbl6.style.width = "100%";
        lbl6.innerHTML = "&nbsp;";

        td6.appendChild(lbl6);

        tr.appendChild(td6);
    }

}

function createLenteInsulinDosageFrequencyTable(drug, dosefreqdiv){
    var tbl = document.createElement("table");
    tbl.width = "100%";
    tbl.cellSpacing = 0;
    tbl.cellPadding = 3;

    var tbody = document.createElement("tbody");

    dosefreqdiv.appendChild(tbl);
    tbl.appendChild(tbody);

    var trTop = document.createElement("tr");
    var tdTop = document.createElement("th");
    tdTop.bgColor = "#CCCCCC";
    tdTop.align = "left";
    tdTop.innerHTML = "DOSAGE";

    tbl.appendChild(trTop);
    trTop.appendChild(tdTop);

    var trBody = document.createElement("tr");
    var tdBody = document.createElement("td");

    tbl.appendChild(trBody);
    trBody.appendChild(tdBody);

    var div = document.createElement("div");
    div.style.overflow = "auto";
    div.style.width = "100%";
    div.style.height = "602px";
    div.style.backgroundColor = "#EEEEEE";

    tdBody.appendChild(div);

    var tblContent = document.createElement("table");
    tblContent.cellSpacing = 1;
    tblContent.cellPadding = 2;
    tblContent.width = "100%";
    tblContent.border = 0;
    tblContent.style.fontSize = "0.7em";

    var trHead = document.createElement("tr");

    var tdHead1 = document.createElement("th");
    tdHead1.innerHTML = "morning";
    tdHead1.bgColor = "#999999";
    tdHead1.style.color = "#EEEEEE";
    tdHead1.colSpan = 2;

    var tdHead2 = document.createElement("th");
    tdHead2.innerHTML = "lunchtime";
    tdHead2.bgColor = "#DDDDDD";
    tdHead2.style.color = "#EEEEEE";
    tdHead2.colSpan = 2;

    var tdHead3 = document.createElement("th");
    tdHead3.innerHTML = "evening";
    tdHead3.bgColor = "#999999";
    tdHead3.style.color = "#EEEEEE";
    tdHead3.colSpan = 2;

    div.appendChild(tblContent);
    tblContent.appendChild(trHead);

    trHead.appendChild(tdHead1);
    trHead.appendChild(tdHead2);
    trHead.appendChild(tdHead3);

    var durat = document.getElementsByName("duration");

    for(var k = 0; k < durat.length; k++){
        var d = durat[k].id.match(/(duration_cell_\d+)/);

        if(d){
            $(d[1]).bgColor = ((durations)?((durations[durat[k].value])?"#F0F000":""):"");
            $("rdo_" + d[1]).checked = false;
        }
    }

    for(var i = 0; i < 10; i++){
        var tr = document.createElement("tr");

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

            this.offsetParent.bgColor = "#add8e6";
        }

        td2.appendChild(rdo2);

        var lbl2 = document.createElement("label");
        lbl2.style.width = "100%";
        lbl2.innerHTML = "&nbsp;";

        td2.appendChild(lbl2);

        tr.appendChild(td2);

        // SET 2:
        var td3 = document.createElement("td");
        td3.vAlign = "middle";
        td3.id = "group3_" + (((i*10)+1) + "-" + ((i+1)*10));
        td3.width = "19%";
        td3.bgColor = "#EAEAEA";

        tblContent.appendChild(tr);
        tr.appendChild(td3);


        var td4 = document.createElement("td");
        td4.vAlign = "middle";
        td4.id = "group4_" + (i+1);
        td4.width = "14%";
        td4.bgColor = "#EEEEEE";

        tr.appendChild(td4);

        // SET 3:
        var td5 = document.createElement("td");
        td5.vAlign = "middle";
        td5.id = "group5_" + (((i*10)+1) + "-" + ((i+1)*10));
        td5.width = "19%";
        td5.bgColor = "#DDDDDD";

        td5.onclick = function(){
            var rdo = this.getElementsByTagName("input");

            if(rdo[0]){
                if(rdo[0].type=="radio") rdo[0].click();
            }
        }

        var rdo5 = document.createElement("input");
        rdo5.type = "radio";
        rdo5.value = (((i*10)+1) + "-" + ((i+1)*10));
        rdo5.name = "group5";

        rdo5.onclick = function(){
            var tds = document.getElementsByName("group5");

            for(var k = 0; k < tds.length; k++){
                $("group5_" + tds[k].value).bgColor = "#DDDDDD";
            }

            this.offsetParent.bgColor = "#add8e6";

            var targets = document.getElementsByName("group5");
            var v = this.value.split("-");
            var start = v[0];
            var end = v[1];

            var val = start;

            for(var k = 0; k < targets.length; k++){
                var td = $("group6_" + (k+1));

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

        td5.appendChild(rdo5);

        var lbl5 = document.createElement("label");
        lbl5.style.width = "100%";
        lbl5.innerHTML = (((i*10)+1) + "-" + ((i+1)*10));

        td5.appendChild(lbl5);

        tblContent.appendChild(tr);
        tr.appendChild(td5);


        var td6 = document.createElement("td");
        td6.vAlign = "middle";
        td6.id = "group6_" + (i+1);
        td6.width = "14%";

        td6.onclick = function(){
            var rdo = this.getElementsByTagName("input");

            if(rdo[0]){
                if(rdo[0].type=="radio") rdo[0].click();
            }
        }

        var rdo6 = document.createElement("input");
        rdo6.type = "radio";
        rdo6.name = "group6";

        rdo6.onclick = function(){
            var tds = document.getElementsByName("group6");

            for(var k = 0; k < tds.length; k++){
                var p = String(tds[k].value).match(/\d$/);

                if(p){
                    $("group6_" + (p==0?10:p)).bgColor = "";
                }

            }

            this.offsetParent.bgColor = "#add8e6";
        }

        td6.appendChild(rdo6);

        var lbl6 = document.createElement("label");
        lbl6.style.width = "100%";
        lbl6.innerHTML = "&nbsp;";

        td6.appendChild(lbl6);

        tr.appendChild(td6);
    }

}

function createNormalDoseFrequencyTable(drug, dosefreqdiv){
    var c = drugs[drug];
    var freqcount = {};
    var frequency = [];
    var dose = [];
    var dosecount = {};

    var tbl = document.createElement("table");
    tbl.cellSpacing = 1;
    tbl.cellPadding = 0;
    tbl.border = 0;
    tbl.width = "100%";
    tbl.bgColor = "#000000";

    var trmain1 = document.createElement("tr");
    var tdmain1 = document.createElement("th");
    tdmain1.width = "60%";
    tdmain1.bgColor = "#CCCCCC";
    
    var tdmain2 = document.createElement("th");
    tdmain2.width = "40%";
    tdmain2.bgColor = "#CCCCCC";

    trmain1.appendChild(tdmain1);
    trmain1.appendChild(tdmain2);
    tbl.appendChild(trmain1);
    dosefreqdiv.appendChild(tbl);

    var div1 = document.createElement("div");
    div1.style.width = "100%";
    div1.style.height = "570px";
    div1.style.overflow = "auto";
    div1.id = "divDose";

    var div2 = document.createElement("div");
    div2.style.width = "100%";
    div2.style.height = "570px";
    div2.style.overflow = "auto";
    div2.id = "divFreq";

    // GROUP 1
    var tbl1 = document.createElement("table");
    tbl1.style.width = "100%";
    tbl1.style.height = "400px";
    tbl1.style.backgroundColor = "#EEEEEE";
    tbl1.border = 0;
    tbl1.cellPadding = 3;
    tbl1.cellSpacing = 0;

    var tbody1 = document.createElement("tbody");
    var tr1 = document.createElement("tr");
    var td1 = document.createElement("th");
    td1.innerHTML = "DOSAGE";
    td1.align = "left";
    td1.bgColor = "#CCCCCC";

    var tr1b = document.createElement("tr");
    var td1b = document.createElement("td");
    td1b.id = "idDosage";

    tr1.appendChild(td1);
    tbl1.appendChild(tr1);

    tr1b.appendChild(td1b);
    tbl1.appendChild(tr1b);

    tbl1.appendChild(tbody1);

    td1b.appendChild(div1);
    tdmain1.appendChild(tbl1);

    // GROUP 2
    var tbl2 = document.createElement("table");
    tbl2.style.width = "100%";
    tbl2.style.height = "390px";
    tbl2.style.backgroundColor = "#EEEEEE";
    tbl2.border = 0;
    tbl2.cellPadding = 3;
    tbl2.cellSpacing = 0;

    var tbody2 = document.createElement("tbody");
    var tr2 = document.createElement("tr");
    var td2 = document.createElement("th");
    td2.innerHTML = "FREQUENCY";
    td2.align = "left";
    td2.bgColor = "#CCCCCC";

    var tr2b = document.createElement("tr");
    var td2b = document.createElement("td");
    td2b.id = "idFrequency";

    tr2.appendChild(td2);
    tbl2.appendChild(tr2);

    tr2b.appendChild(td2b);
    tbl2.appendChild(tr2b);

    tbl2.appendChild(tbody2);

    td2b.appendChild(div2);
    tdmain2.appendChild(tbl2);


    for(var i = 0; i < c.length; i++){
        if(c[i]){
            if(c[i][0]){
                if(!dosecount[c[i][0]]){
                    dose.push(c[i][0]);
                    dosecount[c[i][0]] = true;
                }
            }
            if(c[i][1]){
                if(!freqcount[ c[i][1]] ){
                    frequency.push( c[i][1] );
                    freqcount[ c[i][1] ] = true;
                }
            }
        }
    }


    var durat = document.getElementsByName("duration");

    for(var k = 0; k < durat.length; k++){
        var d = durat[k].id.match(/(duration_cell_\d+)/);

        if(d){
            $(d[1]).bgColor = ((durations)?((durations[durat[k].value])?"#F0F000":""):"");
            $("rdo_" + d[1]).checked = false;
        }
    }

    var optTable1 = document.createElement("table");
    var optTBody1 = document.createElement("tbody");
    optTable1.width = "100%";
    optTable1.border = 0;
    optTable1.style.fontSize = "1.1em";
    optTable1.cellPadding = 5;

    optTable1.appendChild(optTBody1);

    div1.appendChild(optTable1);
    
    for(var i = 0; i < dose.length; i++){
        var optTr1 = document.createElement("tr");
        var optTd1 = document.createElement("td");
        optTd1.id = "dose_cell_"+i;
        optTd1.align = "left";
        optTd1.style.fontStyle = "normal";
        optTd1.bgColor = ((doses[drug+"_"+dose[i].match(/\d+(\.?\d+)?/g)[0]])?((doses[drug+"_"+dose[i].match(/\d+(\.?\d+)?/g)[0]])?"#F0F000":""):"");
       
        var optRadio1 = document.createElement("input");
        optRadio1.type = "radio";
        optRadio1.name = "dose";
        optRadio1.value = dose[i];
        optRadio1.id = "rdo_dose_cell_"+i;

        optTd1.onclick = function(){
            var id = "rdo_" + this.id;
            $(id).click();
        }

        optRadio1.onclick = function(){
            var id = this.id.match(/(dose_cell_\d+)/);

            if(id){
                if(this.checked){
                    var c = document.getElementsByName("dose");

                    if(current_drug.toLowerCase()=="glibenclamide"){

                        var f = document.getElementsByName("frequency");

                        for(var g = 0; g < f.length; g++){
                            var o = f[g].id.match(/(frequency_cell_\d+)/);

                            f[g].disabled = false;

                            if(o){
                                $(o[1]).bgColor = ((freqs[drug+"_"+f[g].value])?((freqs[drug+"_"+f[g].value])?"#F0F000":""):"");
                            }
                        }

                    }
            
                    for(var k = 0; k < c.length; k++){
                        var d = c[k].id.match(/(dose_cell_\d+)/);

                        if(d){
                            if(c[k].value == "[10MG:AM],[5MG:PM]"){
                                $(d[1]).bgColor = ((doses[drug+"_10MG_AM_5MG_PM"])?((doses[drug+"_10MG_AM_5MG_PM"])?"#F0F000":""):"");
                            } else {
                                $(d[1]).bgColor = ((doses[drug+"_"+c[k].value.match(/\d+(\.?\d+)?/g)[0]])?((doses[drug+"_"+c[k].value.match(/\d+(\.?\d+)?/g)[0]])?"#F0F000":""):"");
                            }
                        }
                    }

                    $(id[1]).bgColor = "#add8e6";

                } else {
                    $(id[1]).bgColor = "";
                }
            }
        }

        optTd1.appendChild(optRadio1);
        optTr1.appendChild(optTd1);
        optTBody1.appendChild(optTr1);

        var lbl1 = document.createElement("label");
        lbl1.innerHTML = dose[i].toProperCase();

        optTd1.appendChild(lbl1);
    }

    if(drug.toLowerCase() == "glibenclamide"){
        var optTr = document.createElement("tr");
        var optTd = document.createElement("td");
        optTd.id = "dose_cell_1000";
        optTd.align = "left";
        optTd.style.fontStyle = "normal";
        optTd.bgColor = ((doses[drug+"_10MG_AM_5MG_PM"])?((doses[drug+"_10MG_AM_5MG_PM"])?"#F0F000":""):"");

        var optRadio = document.createElement("input");
        optRadio.type = "radio";
        optRadio.name = "dose";
        optRadio.value = "[10MG:AM],[5MG:PM]";
        optRadio.id = "rdo_dose_cell_1000";

        optTd.onclick = function(){
            var id = "rdo_" + this.id;
            $(id).click();
        }

        optRadio.onclick = function(){
            var id = this.id.match(/(dose_cell_\d+)/);

            if(id){
                if(this.checked){
                    var c = document.getElementsByName("dose");

                    for(var k = 0; k < c.length; k++){
                        var d = c[k].id.match(/(dose_cell_\d+)/);

                        if(d){
                            if(c[k].value == "[10MG:AM],[5MG:PM]"){
                                $(d[1]).bgColor = ((doses[drug+"_10MG_AM_5MG_PM"])?((doses[drug+"_10MG_AM_5MG_PM"])?"#F0F000":""):"");
                            } else {
                                $(d[1]).bgColor = ((doses[drug+"_"+c[k].value.match(/\d+(\.?\d+)?/g)[0]])?((doses[drug+"_"+c[k].value.match(/\d+(\.?\d+)?/g)[0]])?"#F0F000":""):"");
                            }
                        }
                    }

                    var f = document.getElementsByName("frequency");

                    for(var g = 0; g < f.length; g++){
                        var o = f[g].id.match(/(frequency_cell_\d+)/);

                        f[g].checked = false;
                        f[g].disabled = true;
                        
                        if(o){
                            $(o[1]).bgColor = ((freqs[drug+"_"+f[g].value])?((freqs[drug+"_"+f[g].value])?"#F0F000":"#DDDDDD"):"#DDDDDD"); //"#DDDDDD";
                        }
                    }

                    $(id[1]).bgColor = "#add8e6";

                } else {
                    $(id[1]).bgColor = "";
                }
            }
        }

        optTd.appendChild(optRadio);
        optTr.appendChild(optTd);
        optTBody1.appendChild(optTr);

        var lbl = document.createElement("label");
        lbl.innerHTML = "10mg AM : 5mg PM";

        optTd.appendChild(lbl);
    }

    var optTable2 = document.createElement("table");
    var optTBody2 = document.createElement("tbody");
    optTable2.width = "100%";
    optTable2.border = 0;
    optTable2.style.fontSize = "1.1em";
    optTable2.cellPadding = 5;

    optTable2.appendChild(optTBody2);

    div2.appendChild(optTable2);

    for(var i = 0; i < frequency.length; i++){
        var optTr2 = document.createElement("tr");
        var optTd2 = document.createElement("td");
        optTd2.id = "frequency_cell_"+i;
        optTd2.align = "left";
        optTd2.style.fontStyle = "normal";
        optTd2.bgColor = ((freqs[drug+"_"+frequency[i]])?((freqs[drug+"_"+frequency[i]])?"#F0F000":""):"");

        var optRadio2 = document.createElement("input");
        optRadio2.type = "radio";
        optRadio2.name = "frequency";
        optRadio2.value = frequency[i];
        optRadio2.id = "rdo_frequency_cell_"+i;

        optTd2.onclick = function(){
            var id = "rdo_" + this.id;
            $(id).click();
        }

        optRadio2.onclick = function(){
            var id = this.id.match(/(frequency_cell_\d+)/);

            if(id){
                if(this.checked){
                    var c = document.getElementsByName("frequency");

                    for(var k = 0; k < c.length; k++){
                        var d = c[k].id.match(/(frequency_cell_\d+)/);

                        if(d){
                            $(d[1]).bgColor = ((freqs[drug+"_"+c[k].value])?((freqs[drug+"_"+c[k].value])?"#F0F000":""):"");
                        }
                    }

                    $(id[1]).bgColor = "#add8e6";

                } else {
                    $(id[1]).bgColor = "";
                }
            }
        }

        optTd2.appendChild(optRadio2);
        optTr2.appendChild(optTd2);
        optTBody2.appendChild(optTr2);

        var lbl2 = document.createElement("label");
        lbl2.innerHTML = frequency[i];//.toProperCase();

        optTd2.appendChild(lbl2);
    }
}

function removeDrugs(){
    $("content").removeChild($('parent_container'));
}

//window.addEventListener("load", generateDrugs, false);
