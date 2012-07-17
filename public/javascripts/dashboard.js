var patnum = ""
var setFocusTimeout = 5000;
var checkForBarcodeTimeout = 1500;
var barcodeFocusTimeoutId = null;
var barcodeFocusOnce = false;
var barcodeId = null;
var focusOnce = false;

var title = "";
var tt_cancel_show = null;
var tt_cancel_destination = null;
var tt_register_destination = null;
var heading = [];
var controls = [];

function __$(id){
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
    if(!__$('home')) return;

    __$('home').style.display = "none";
    
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
    barcodeinput.id = "barcode";
    barcodeinput.className = "touchscreenTextInput";
    barcodeinput.onkeydown = function(event){
        return;
        if(event.keyCode == 52){
            if(tt_cancel_show){
                window.location = tt_cancel_show + '?identifier=' + this.value;
            } else {
                window.location = '/people/search?identifier=' + this.value;
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
        alert(tt_cancel_destination);
        if(tt_cancel_destination){
            window.location = tt_cancel_destination;
        }
    }

    nav.appendChild(logout);

    if(__$("tabs")){
        var children = __$("tabs").options;
        
        for(var i = 0; i < children.length; i++){
            var page = (children[i].value.trim() != children[i].innerHTML.trim() ? children[i].value :
                "tabpages/" + children[i].innerHTML.trim().toLowerCase().replace(/\s/gi, "_") + ".html")
            
            heading.push([children[i].innerHTML.trim(), page]);
        }

        generateTab(heading, __$("main"))
    }

    loadBarcodePage();
}

function generateDashboard(){
    // Requires a container DIV with id "home"
    if(!__$('dashboard')) return;

    __$('dashboard').style.display = "none";

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

    var gender = document.createElement("div");
    gender.id = "gendercell";
    if(__$('patient_gender')){
        gender.innerHTML = "<div id='gender'><img src='/images/" +
        (__$('patient_gender').innerHTML.toLowerCase().trim() == "female" ? "female" : "male") +
        ".gif' height='25px' width='25px' style='padding-left: 3px; padding-top: 2px;' /></div>";
    }

    topicRow.appendChild(gender);

    var detailsTopic = document.createElement("div");
    detailsTopic.id = "detailsTopic";
    detailsTopic.innerHTML = (__$('patient_name') ? __$('patient_name').innerHTML : "&nbsp;");

    topicRow.appendChild(detailsTopic);

    var mainDetailsContent = document.createElement("div");
    mainDetailsContent.id = "mainTopicContent";

    detailsRow2.appendChild(mainDetailsContent);

    var nameRow = document.createElement("div");
    nameRow.id = "nameRow";

    mainDetailsContent.appendChild(nameRow);

    var patientid = document.createElement("div");
    patientid.id = "id";
    patientid.innerHTML = "Patient ID"

    nameRow.appendChild(patientid);

    var patientidvalue = document.createElement("div");
    patientidvalue.id = "idvalue";
    patientidvalue.innerHTML = ":&nbsp;&nbsp;" + (__$('patient_id') ? __$('patient_id').innerHTML : "");

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
    residencevalue.innerHTML = ":&nbsp;&nbsp;" + (__$('patient_residence') ? __$('patient_residence').innerHTML : "");

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
    agevalue.innerHTML = ":&nbsp;&nbsp;" + (__$('patient_age') ? __$('patient_age').innerHTML : "");

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

    if(__$("tabs")){
        var children = __$("tabs").options;

        for(var i = 0; i < children.length; i++){
            var page = (children[i].value.trim() != children[i].innerHTML.trim() ? children[i].value :
                "tabpages/" + children[i].innerHTML.trim().toLowerCase().replace(/\s/gi, "_") + ".html")

            heading.push([children[i].innerHTML.trim(), page]);
        }

        generateTab(heading, __$("patient-dashboard-main"))
    }

    if(__$("links")){
        var childlinks = __$("links").options;

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

function generateGeneralDashboard(){
    var page = document.body.innerHTML;

    document.body.innerHTML = "";

    var content = document.createElement("div");
    content.id = "content";

    document.body.appendChild(content);

    var main = document.createElement("div");
    main.id = "patient-dashboard-main";
    main.style.height = "90%";
    main.style.width = "100%";
    main.style.overflow = "hidden";

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

    main.innerHTML = page;
    
}

function createPage(){
    if(__$('home')){
        generateHomepage();
    } else if(__$('dashboard')){
        generateDashboard();
    } else {
        generateGeneralDashboard();
    }
}

// Get the application name
function fetchTitle(){
    if(__$("project_name")){
        return __$("project_name").innerHTML;
    } else {
        return "";
    }
}

function activate(id){
    for(var i = 0; i < controls.length; i++){
        if(controls[i] == id){
            var page = __$(id).getAttribute("link");
            var page_id = __$(id).innerHTML.trim().toLowerCase().replace(/\s/gi, "_");
            
            __$(page_id).src = page;

            __$(controls[i]).className = "active-tab";
            __$("view_" + controls[i]).style.display = "block";
        } else {
            __$(controls[i]).className = "inactive-tab";
            __$("view_" + controls[i]).style.display = "none";
        }
    }
}

function repositionLayer(layer){
    var pos = [];

    if(__$("mainContainer")){
        pos = checkCtrl(__$("mainContainer"));
    } else {
        return;
    }

    if(__$("tabContainer") != null){
        if(__$("tabContainer").id == layer){
            __$("tabContainer").style.top = (pos[2] + __$("tabContainer").offsetHeight) + "px";
        } else {
            if(__$("tabContainer2").innerHTML.trim().length > 0){
                __$("tabContainer").style.top = (pos[2]) + "px";
            }
        }
    }

    if(__$("tabContainer2") != null){
        if(__$("tabContainer2").id == layer){
            if(__$("tabContainer2").innerHTML.trim().length > 0){
                __$("tabContainer2").style.top = (pos[2] + __$("tabContainer").offsetHeight) + "px";
            }
        } else {
            __$("tabContainer2").style.top = (pos[2]) + "px";
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

    __$(headings[0][0].toLowerCase().replace(/\s/gi, "_")).src = headings[0][1];

    __$("tabContainer").style.position = "absolute";
    __$("tabContainer2").style.position = "absolute";

    __$("tabContainer").style.width = __$("mainContainer").offsetWidth;
    __$("tabContainer2").style.width = __$("mainContainer").offsetWidth;
    
    repositionLayer("tabContainer");
}

function loadBarcodePage() {
    focusForBarcodeInput();
    checkForBarcode();
}

function focusForBarcodeInput(){
    if (!barcodeId) {
        barcodeId = "barcode";
    }
    var barcode = document.getElementById("barcode");
    if (barcode) {
        barcode.focus();
        if (!focusOnce) barcodeFocusTimeoutId = window.setTimeout("focusForBarcodeInput()", setFocusTimeout);
    }
}

function checkForBarcode(validAction){
    if (!barcodeId) {
        barcodeId = "barcode";
    }
    
    barcode_element = document.getElementById(barcodeId)

    if (!barcode_element)
        return
    
    // Look for anything with a dollar sign at the end
    if (barcode_element.value.match(/.+\$$/i) != null || barcode_element.value.match(/.+\$$/i) != null){
        barcode_element.value = barcode_element.value.substring(0,barcode_element.value.length-1)
        if (typeof barcodeScanAction != "undefined"){
            barcodeScanAction();
        } else {
            if(tt_cancel_show){
                window.location = tt_cancel_show + '?identifier=' + barcode_element.value;
            } else {
                window.location = '/people/search?identifier=' + barcode_element.value;
            }
        }
        //document.getElementById('barcodeForm').submit();
    }
    window.setTimeout("checkForBarcode('" + validAction + "')", checkForBarcodeTimeout);
}

window.addEventListener("load", createPage, false);