/* transform.js
 * Script to transform a normal form page to a multiquestion wizard page
*/

var actualElements = {};
var sections = null;
tstCurrentPage = 0;

function getSections(){
    return document.forms[0].getElementsByTagName("table");
}

function navigateTo(section){
    if($("frmAnswers")){
        var elements = $("frmAnswers").elements;

        for(var i = 0; i < elements.length; i++){
            if(String(elements[i].id).match(/secondary_(.+)/)){
                var id = String(elements[i].id).match(/secondary_(.+)/)[1];
                
                if($(id).tagName.toLowerCase() == "select"){
                    for(var j = 0; j < $(id).options.length; j++){
                        if(elements[i].value.toLowerCase() == $(id).options[j].innerHTML.toLowerCase()){
                            $(id).selectedIndex = j;
                            break;
                        }                        
                    }
                } else {
                    $(id).value = elements[i].value;
                }
            }
        }
        
        if(section == (sections.length)){
            $("content").removeChild($("cntr"));
            $("footer").innerHTML = "";
            document.forms[0].submit();
        } else {
            $("content").removeChild($("cntr"));
            $("footer").innerHTML = "";
        }
    }

    transformPage(section);
}

function transformPage(section){
    if(!sections) return;

    if(sections.length <= 0) return;
    
    if(section < 0){
        section = 0;
    } else if(section >= sections.length){
        section = sections.length - 1;
    }
    
    actualElements = {};
    var inputs = sections[section].getElementsByTagName("input");
    var selects = sections[section].getElementsByTagName("select");

    var formElements = [];

    for(var i = 0; i < selects.length; i++){
        selects[i].setAttribute("field_type", "select");
        
        formElements.push([selects[i].getAttribute("position"), selects[i]]);
    }

    for(var i = 0; i < inputs.length; i++){
        if(inputs[i].type != "hidden"){
            formElements.push([inputs[i].getAttribute("position"), inputs[i]]);
        }
    }

    formElements.sort();
    
    for(var i = 0; i < formElements.length; i++){
        if(formElements[i][1].tagName != "BUTTON"){
            if(formElements[i][1].tagName == "INPUT"){
                if(formElements[i][1].type != "button" && formElements[i][1].type != "submit"){
                    actualElements[formElements[i][1].id] = [formElements[i],
                    getLabel(formElements[i][1].id), formElements[i][1].getAttribute("field_type")];
                }
            } else {
                actualElements[formElements[i][1].id] = [formElements[i][1],
                getLabel(formElements[i][1].id), formElements[i][1].getAttribute("field_type")];
            }
        }
    }

    generatePage(document.forms[0].action, document.forms[0].method, section);
}

function getLabel(id){
    var labels = document.getElementsByTagName("label");

    // Get the value of the label text
    for(var l = 0; l < labels.length; l++){
        if(labels[l].getAttribute("for") == id){
            // if found, return the value else keep searching
            return labels[l].innerHTML;
        }
    }
    return "";
}

function generatePage(action, method, section){

    document.forms[0].style.display = "none";

    var cntr = document.createElement("center");
    cntr.id = "cntr";

    $("content").appendChild(cntr);

    var divmain = document.createElement("div");
    divmain.id = "divmain";

    cntr.appendChild(divmain);

    var divcontent = document.createElement("div");
    divcontent.id = "divcontent";
    divcontent.style.padding = "10px";
    divcontent.style.overflow = "hidden";
    divcontent.style.height = "575px";
    divcontent.style.width = "900px";

    divmain.appendChild(divcontent);

    var divInside = document.createElement("div");
    divInside.id = "divScroller";
    divInside.style.overflow = "auto";
    divInside.style.width = "100%"
    divInside.style.height = "100%"

    divcontent.appendChild(divInside);

    //var divnav = document.createElement("div");
    //divnav.id = "divnav";

    //divmain.appendChild(divnav);

    var btnNext = document.createElement("button");
    btnNext.id = "btnNext";
    btnNext.innerHTML = (tstCurrentPage >= sections.length - 1 ? "<span>Finish</span>" : "<span>Next</span>");
    btnNext.style.cssFloat = "right";
    btnNext.className = "green navButton";
    btnNext.onclick = function(){
        tstCurrentPage += 1;
        navigateTo(tstCurrentPage);
    }

    $("footer").appendChild(btnNext);

    var btnClear = document.createElement("button");
    btnClear.id = "btnClear";
    btnClear.innerHTML = "<span>Clear</span>";
    btnClear.style.cssFloat = "right";
    btnClear.className = "gray navButton";
    btnClear.onclick = function(){
        $("frmAnswers").reset();
    }

    $("footer").appendChild(btnClear);

    var btnBack = document.createElement("button");
    btnBack.id = "btnBack";
    btnBack.innerHTML = "<span>Back</span>";
    btnBack.style.cssFloat = "right";
    btnBack.className = "gray navButton";
    btnBack.style.display = (tstCurrentPage > 0 ? "block" : "none");
    btnBack.onclick = function(){
        tstCurrentPage -= 1;
        navigateTo(tstCurrentPage);
    }

    $("footer").appendChild(btnBack);

    var btnCancel = document.createElement("button");
    btnCancel.id = "btnCancel";
    btnCancel.innerHTML = "<span>Cancel</span>";
    btnCancel.style.cssFloat = "left";
    btnCancel.className = "red navButton";
    btnCancel.onclick = function(){
        if(tt_cancel_destination){
            window.location = tt_cancel_destination;
        } else {
            $("content").removeChild($("cntr"));
            document.forms[0].style.display = "block";
        }
    }

    $("footer").appendChild(btnCancel);

    var frm = document.createElement("form");
    frm.id = "frmAnswers";
    frm.action = action;
    frm.method = method;
    frm.setAttribute("autocomplete", "off");

    divInside.appendChild(frm);

    var tbl = document.createElement("table");
    tbl.width = "95%";
    tbl.cellSpacing = 1;
    tbl.cellPadding = 2;

    frm.appendChild(tbl);

    var tbody = document.createElement("tbody");

    tbl.appendChild(tbody);

    var textThere = false;

    for(var el in actualElements){
        var tr = document.createElement("tr");
        var td1 = document.createElement("td");
        var td2 = document.createElement("td");

        tbody.appendChild(tr);
        tr.appendChild(td1);
        tr.appendChild(td2);

        td1.className = "labelText";
        td1.innerHTML = actualElements[el][1];

        var input = document.createElement("input");
        input.type = "text";
        input.style.width = "100%";
        input.className = "labelText textInput";
        input.id = "secondary_" + el;
        input.name = "secondary_" + el;
        input.setAttribute("initial_id", el)

        switch(actualElements[el][2]){
            case "number":
                input.onclick = function(){
                    if($('divMenu')){
                        document.body.removeChild($('divMenu'));
                    } else {
                        showNumber(this.id);
                    }
                }
                textThere = true;
                break;
            case "year":
                input.onclick = function(){
                    if($('divMenu')){
                        document.body.removeChild($('divMenu'));
                    } else {
                        showYear(this.id);
                    }
                }
                textThere = true;
                break;
            case "date":
                //input.className = "input-date";
                input.onclick = function(){
                    if($('divMenu')){
                        document.body.removeChild($('divMenu'));
                    } else {
                        showCalendar(this.id);
                    }
                }
                textThere = true;
                break;
            case "select":
                // Check if select control options are greater than 3
                if($(el).options.length > 4) {
                    input.onclick = function(){
                        if($('divMenu')){
                            document.body.removeChild($('divMenu'));
                        } else {
                            showMenu(this.id, this.getAttribute("initial_id"));
                        }
                    }
                }

                break;
            default:
                input.onclick = function(){
                    if($('divMenu')){
                        document.body.removeChild($('divMenu'));
                    } else {
                        showKeyboard(this.id);
                    }
                }
                textThere = true;
                break;
        }

        if(!el.match(/^(\s+)?$/)){
            input.value = $(el).value;
        }

        // Add buttons if options are less than 3
        if($(el).tagName == "SELECT"){

            if($(el).options.length <= 4){

                var button_table = document.createElement("table");
                button_table.style.cssFloat = "right";
                button_table.style.minWidth = "150px";

                var button_tr = document.createElement("tr");
                button_table.appendChild(button_tr);

                for(var i = 0; i < $(el).options.length; i++){
                    if($(el).options[i].innerHTML.length > 0){
                        var button_td = document.createElement("td");
                        button_tr.appendChild(button_td);

                        var button = document.createElement("button");
                        button.className = ($(el).value == unescape($(el).options[i].innerHTML) ? "green" : "gray");
                        button.innerHTML = "<span>" + unescape($(el).options[i].innerHTML) + "</span>";
                        button.value = $(el).options[i].value;
                        button.id = el + "_" + $(el).options[i].value;
                        button.name = el + "_buttons";
                        button.setAttribute("initial_id", el)

                        button.onclick = function(){
                            var btns = document.getElementsByName(this.name);

                            for(var b = 0; b < btns.length; b++){
                                if(btns[b].id == this.id){
                                    btns[b].className = "green";
                                    $(this.getAttribute("initial_id")).value = this.value;
                                } else {
                                    btns[b].className = "gray";
                                }
                            }
                            return false;
                        }

                        button_td.appendChild(button);
                    }
                }

                td2.appendChild(button_table);

            } else {

                td2.appendChild(input);

            }
            
        } else {
            td2.appendChild(input);
        }
        
    }

    var spacer = document.createElement("div");

    if(textThere == true){
        spacer.style.height = "400px";
    }

    $("divScroller").appendChild(spacer);
    
}

function initMultipleQuestions(){
    sections = getSections();

    navigateTo(0);
}

if(document.forms[0]){
    if(document.forms[0].getAttribute("extended")){
        window.addEventListener("load", initMultipleQuestions, false);
    } else {
        window.addEventListener("load", loadTouchscreenToolkit, false);
    }
}



