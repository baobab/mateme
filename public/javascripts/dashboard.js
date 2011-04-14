var title = "";
var tt_cancel_show = null;
var tt_cancel_destination = null;
var heading = [];
var controls = [];

function $(id){
    return document.getElementById(id);
}

function checkCtrl(obj){
    var o = obj;
    var t = o.offsetTop;
    var l = o.offsetLeft + 1;
    var w = o.offsetWidth;
    var h = o.offsetHeight;

    while((o ? (o.offsetParent != document.body) : false)){
        o = o.offsetParent;
        t += (o ? o.offsetTop : 0);
        l += (o ? o.offsetLeft : 0);
    }
    return [w, h, t, l];
}

function generateHomepage(){
    // Requires a container DIV with id "home"
    if(!$('home')) return;

    $('home').style.display = "none";
    
    // Get the application name
    title = fetchTitle();

    var content = document.createElement("div");
    content.id = "content";

    document.body.appendChild(content);

    var banner = document.createElement("div");
    banner.id = "banner";

    content.appendChild(banner);

    var bannerrow = document.createElement("div");
    bannerrow.id = "bannerrow";

    banner.appendChild(bannerrow);

    var scanlabel = document.createElement("div");
    scanlabel.id = "scanlabel";
    scanlabel.innerHTML = "Scan Patient Barcode :";

    bannerrow.appendChild(scanlabel);

    var scaninput = document.createElement("div");
    scaninput.id = "scaninput";

    bannerrow.appendChild(scaninput);

    var barcodeinput = document.createElement("input");
    barcodeinput.type = "text";
    barcodeinput.id = "barcodeinput";
    barcodeinput.className = "touchscreenTextInput";
    barcodeinput.onkeydown = function(event){
        if(event.keyCode == 52){
            if(tt_cancel_show){
                window.location = tt_cancel_show;
            } else {
                window.location = 'dashboard.html?id=' + this.value;
            }
        }
    }

    scaninput.appendChild(barcodeinput);

    var application = document.createElement("div");
    application.id = "application";

    bannerrow.appendChild(application);

    var applicationname = document.createElement("div");
    applicationname.id = "applicationname";
    applicationname.innerHTML = title;

    application.appendChild(applicationname);

    var main = document.createElement("div");
    main.id = "main";

    content.appendChild(main);

    var nav = document.createElement("div");
    nav.id = "nav";

    content.appendChild(nav);

    var finish = document.createElement("button");
    finish.id = "btnNext";
    finish.innerHTML = "<span>Find or Register Patient</span>";
    finish.className = "green";
    finish.style.cssFloat = "right";
    finish.style.margin = "10px";
    finish.onclick = function(){
        if(tt_cancel_show){
            window.location = tt_cancel_show;
        }
    }

    nav.appendChild(finish);

    var logout = document.createElement("button");
    logout.id = "btnCancel";
    logout.innerHTML = "<span>Logout</span>";
    logout.className = "red";
    logout.style.cssFloat = "left";
    logout.style.margin = "10px";
    logout.onclick = function(){
        if(tt_cancel_destination){
            window.location = tt_cancel_destination;
        }
    }

    nav.appendChild(logout);

    if($("tabs")){
        var children = $("tabs").options;
        
        for(var i = 0; i < children.length; i++){
            var page = (children[i].value.trim() != children[i].innerHTML.trim() ? children[i].value :
                "tabpages/" + children[i].innerHTML.trim().toLowerCase().replace(/\s/gi, "_") + ".html")
            
            heading.push([children[i].innerHTML.trim(), page]);
        }

        generateTab(heading, $("main"))
    }
}

function generateDashboard(){
    // Requires a container DIV with id "home"
    if(!$('dashboard')) return;

    $('dashboard').style.display = "none";

    // Get the application name
    title = fetchTitle();

    var content = document.createElement("div");
    content.id = "content";

    document.body.appendChild(content);

    var details = document.createElement("div");
    details.id = "details";
    
    content.appendChild(details);

    var detailsRow1 = document.createElement("div");
    detailsRow1.id = "detailsRow1";

    details.appendChild(detailsRow1);

    var detailsRow2 = document.createElement("div");
    detailsRow2.id = "detailsRow2";

    details.appendChild(detailsRow2);

    var mainTopicContent = document.createElement("div");
    mainTopicContent.id = "mainTopicContent";

    detailsRow1.appendChild(mainTopicContent);

    var topicRow = document.createElement("div");
    topicRow.id = "topicRow";

    mainTopicContent.appendChild(topicRow);

    var detailsTopic = document.createElement("div");
    detailsTopic.id = "detailsTopic";
    detailsTopic.innerHTML = ($('patient_name') ? $('patient_name').innerHTML : "&nbsp;");

    topicRow.appendChild(detailsTopic);

    var gender = document.createElement("div");
    gender.id = "gendercell";
    if($('patient_gender')){
        gender.innerHTML = "<div id='gender'><img src='/images/" +
        ($('patient_gender').innerHTML.toLowerCase().trim() == "female" ? "female" : "male") +
        ".gif' height='25px' width='25px' style='padding-left: 3px; padding-top: 2px;' /></div>";
    }

    topicRow.appendChild(gender);

    var mainDetailsContent = document.createElement("div");
    mainDetailsContent.id = "mainTopicContent";

    detailsRow2.appendChild(mainDetailsContent);

    var nameRow = document.createElement("div");
    nameRow.id = "nameRow";

    mainDetailsContent.appendChild(nameRow);

    var patientid = document.createElement("div");
    patientid.id = "id";
    patientid.innerHTML = "Patient ID:"

    nameRow.appendChild(patientid);

    var patientidvalue = document.createElement("div");
    patientidvalue.id = "idvalue";
    patientidvalue.innerHTML = ":" + ($('patient_id') ? $('patient_id').innerHTML : "");

    nameRow.appendChild(patientidvalue);

    var residenceRow = document.createElement("div");
    residenceRow.id = "residenceRow";

    mainDetailsContent.appendChild(residenceRow);

    var residence = document.createElement("div");
    residence.id = "residence";
    residence.innerHTML = "Residence"

    residenceRow.appendChild(residence);

    var residencevalue = document.createElement("div");
    residencevalue.id = "residencevalue";
    residencevalue.innerHTML = ":" + ($('patient_residence') ? $('patient_residence').innerHTML : "");

    residenceRow.appendChild(residencevalue);

    var ageRow = document.createElement("div");
    ageRow.id = "ageRow";

    mainDetailsContent.appendChild(ageRow);

    var age = document.createElement("div");
    age.id = "age";
    age.innerHTML = "Age"

    ageRow.appendChild(age);

    var agevalue = document.createElement("div");
    agevalue.id = "agevalue";
    agevalue.innerHTML = ":" + ($('patient_age') ? $('patient_age').innerHTML : "");

    ageRow.appendChild(agevalue);

    var application = document.createElement("div");
    application.id = "patient-dashboard-application";

    content.appendChild(application);

    var applicationname = document.createElement("div");
    applicationname.id = "patient-dashboard-applicationname";
    applicationname.innerHTML = title;

    application.appendChild(applicationname);

    var links = document.createElement("div");
    links.id = "links";

    content.appendChild(links);

    var main = document.createElement("div");
    main.id = "patient-dashboard-main";

    content.appendChild(main);

    var nav = document.createElement("div");
    nav.id = "nav";

    content.appendChild(nav);

    var finish = document.createElement("button");
    finish.id = "btnNext";
    finish.innerHTML = "<span>Finish</span>";
    finish.className = "green";
    finish.style.cssFloat = "right";
    finish.style.margin = "10px";
    finish.onclick = function(){
        if(tt_cancel_destination){
            window.location = tt_cancel_destination;
        }
    }

    nav.appendChild(finish);

    var logout = document.createElement("button");
    logout.id = "btnCancel";
    logout.innerHTML = "<span>Cancel</span>";
    logout.className = "red";
    logout.style.cssFloat = "left";
    logout.style.margin = "10px";
    logout.onclick = function(){
        if(tt_cancel_show){
            window.location = tt_cancel_show;
        }
    }

    nav.appendChild(logout);

    if($("tabs")){
        var children = $("tabs").options;

        for(var i = 0; i < children.length; i++){
            var page = (children[i].value.trim() != children[i].innerHTML.trim() ? children[i].value :
                "tabpages/" + children[i].innerHTML.trim().toLowerCase().replace(/\s/gi, "_") + ".html")

            heading.push([children[i].innerHTML.trim(), page]);
        }

        generateTab(heading, $("patient-dashboard-main"))
    }

    if($("links")){
        var childlinks = $("links").options;

        for(var j = 0; j < childlinks.length; j++){
            var button = document.createElement("button");
            button.className = "blue";
            button.style.minWidth = "255px";
            button.style.margin = "0px";
            button.style.marginTop = "5px";
            button.innerHTML = "<span>" + childlinks[j].innerHTML.trim() + "</span>";
            button.setAttribute("link", childlinks[j].value);
            button.onclick = function(){
                window.location = this.getAttribute("link");
            }

            links.appendChild(button);
        }

    }
}

function createPage(){
    if($('home')){
        generateHomepage();
    } else if($('dashboard')){
        generateDashboard();
    }
}

// Get the application name
function fetchTitle(){
    if($("project_name")){
        return $("project_name").innerHTML;
    } else {
        return "";
    }
}

function activate(id){
    for(var i = 0; i < controls.length; i++){
        if(controls[i] == id){
            var page = $(id).getAttribute("link");
            var page_id = $(id).innerHTML.trim().toLowerCase().replace(/\s/gi, "_");
            
            $(page_id).src = page;

            $(controls[i]).className = "active-tab";
            $("view_" + controls[i]).style.display = "block";
        } else {
            $(controls[i]).className = "inactive-tab";
            $("view_" + controls[i]).style.display = "none";
        }
    }
}

function repositionLayer(layer){
    var pos = [];

    if($("mainContainer")){
        pos = checkCtrl($("mainContainer"));
    } else {
        return;
    }

    if($("tabContainer") != null){
        if($("tabContainer").id == layer){
            $("tabContainer").style.top = (pos[2] + $("tabContainer").offsetHeight) + "px";
        } else {
            if($("tabContainer2").innerHTML.trim().length > 0){
                $("tabContainer").style.top = (pos[2]) + "px";
            }
        }
    }

    if($("tabContainer2") != null){
        if($("tabContainer2").id == layer){
            if($("tabContainer2").innerHTML.trim().length > 0){
                $("tabContainer2").style.top = (pos[2] + $("tabContainer").offsetHeight) + "px";
            }
        } else {
            $("tabContainer2").style.top = (pos[2]) + "px";
        }
    }

}
                
/* Before calling the function to generate tabs, the following variables should ve
 * supplied with values as follows:
 *      generateTab(
 *             headings = [heading1, heading2, ..., heading(n)],
 *             content = {
 *                         "heading1":"",
 *                         "heading2":"",
 *                             .
 *                             .
 *                             .
 *                         "heading(n)":""
 *                       },
 *             [target = control to attach tab to defaulted to document.body]);
*/
function generateTab(headings, target, content){
    var tabMainContainer = document.createElement("div");
    tabMainContainer.id = "tabMainContainer";

    if(target){
        target.innerHTML = "";
        target.appendChild(tabMainContainer);
    } else {
        document.body.appendChild(tabMainContainer);
    }

    var mainContainer = document.createElement("div");
    mainContainer.id = "mainContainer";

    tabMainContainer.appendChild(mainContainer);

    var tabContainer = document.createElement("div");
    tabContainer.id = "tabContainer";
    tabContainer.onclick = function(){
        repositionLayer(this.id);
    }

    mainContainer.appendChild(tabContainer);

    var tabContainer2 = document.createElement("div");
    tabContainer2.id = "tabContainer2";
    tabContainer2.onclick = function(){
        repositionLayer(this.id);
    }

    mainContainer.appendChild(tabContainer2);

    var tabPageContainer = document.createElement("div");
    tabPageContainer.id = "tabPageContainer";

    tabMainContainer.appendChild(tabPageContainer);

    var cumulative_width = 0;
    var average_tab_width = tabPageContainer.offsetWidth / 4;

    for(var i = 0; i < headings.length; i++){
        var tab = document.createElement("div");
        tab.id = "tab" + (i + 1);
        if(i == 0){
            tab.className = "active-tab";
            tab.style.marginLeft = "7px";
        } else {
            tab.className = "inactive-tab";
            tab.style.marginLeft = "1px";
        }
        tab.innerHTML = headings[i][0];
        tab.setAttribute("link", headings[i][1]);
        tab.onclick = function(){
            activate(this.id);
        }

        if((average_tab_width + cumulative_width) > tabPageContainer.offsetWidth){
            tabContainer2.appendChild(tab);
        } else {
            tabContainer.appendChild(tab);
        }        

        cumulative_width += tab.offsetWidth;

        controls.push(tab.id);

        var tabPage = document.createElement("div");
        tabPage.id = "view_tab" + (i + 1);
        tabPage.className = "view";

        if(i == 0){
            tabPage.style.display = "block";
        } else {
            tabPage.style.display = "none";
        }

        if(content){
            if(content[headings[i]]){
                tabPage.innerHTML = content[headings[i][0]];
            } else {
                tabPage.innerHTML = "<iframe src='' id='" + headings[i][0].toLowerCase().replace(/\s/gi, "_") + "'></iframe>";
            }
        } else {
            tabPage.innerHTML = "<iframe src='' id='" + headings[i][0].toLowerCase().replace(/\s/gi, "_") + "'></iframe>";
        }

        tabPageContainer.appendChild(tabPage);
    }

    $(headings[0][0].toLowerCase().replace(/\s/gi, "_")).src = headings[0][1];

    $("tabContainer").style.position = "absolute";
    $("tabContainer2").style.position = "absolute";

    $("tabContainer").style.width = $("mainContainer").offsetWidth;
    $("tabContainer2").style.width = $("mainContainer").offsetWidth;
    
    repositionLayer("tabContainer");
}

window.addEventListener("load", createPage, false);