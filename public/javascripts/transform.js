/*******************************************************************************
 *
 * Baobab Touchscreen Toolkit
 *
 * A library for transforming HTML pages into touch-friendly user interfaces.
 *
 * (c) 2011 Baobab Health Trust (http://www.baobabhealth.org)
 *
 * For lincense details, see the README.md file
 *
 * This file is part the Baobab Touchscreen Toolkit API
 *
 ******************************************************************************/

/* transform.js
 * Script to transform a normal form page to a multiquestion wizard page
*/

var actualElements = {};
var elements = {};
var elementIDs = [];
var sections = null;
var tstCurrentPage = 0;
var remoteNavigation = false;

var global_control = null;
var full_keyboard = false;
var selectValue = "";

// Array of max days in month in a year and in a leap year
monthMaxDays	= [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
monthMaxDaysLeap= [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
hideSelectTags = [];

function $(id){
    return document.getElementById(id);
}

function getRealYear(dateObj)
{
    return (dateObj.getYear() % 100) + (((dateObj.getYear() % 100) < 39) ? 2000 : 1900);
}

function getDaysPerMonth(month, year)
{
    /*
	Check for leap year. These are some conditions to check year is leap year or not...
	1.Years evenly divisible by four are normally leap years, except for...
	2.Years also evenly divisible by 100 are not leap years, except for...
	3.Years also evenly divisible by 400 are leap years.
	*/
    if ((year % 4) == 0)
    {
        if ((year % 100) == 0 && (year % 400) != 0)
            return monthMaxDays[month];

        return monthMaxDaysLeap[month];
    }
    else
        return monthMaxDays[month];
}

function createCalender(year, month, day)
{
    // current Date
    var curDate = new Date();
    var curDay = curDate.getDate();
    var curMonth = curDate.getMonth();
    var curYear = getRealYear(curDate)

    // if a date already exists, we calculate some values here
    if (!year)
    {
        var year = curYear;
        var month = curMonth;
    }

    var yearFound = 0;
    for (var i=0; i<document.getElementById('selectYear').options.length; i++)
    {
        if (document.getElementById('selectYear').options[i].value == year)
        {
            document.getElementById('selectYear').selectedIndex = i;
            yearFound = true;
            break;
        }
    }
    if (!yearFound)
    {
        document.getElementById('selectYear').selectedIndex = 0;
        year = document.getElementById('selectYear').options[0].value;
    }
    document.getElementById('selectMonth').selectedIndex = month;

    // first day of the month.
    var fristDayOfMonthObj = new Date(year, month, 1);
    var firstDayOfMonth = fristDayOfMonthObj.getDay();

    continu		= true;
    firstRow	= true;
    var x	= 0;
    var d	= 0;
    var trs = []
    var ti = 0;
    while (d <= getDaysPerMonth(month, year))
    {
        if (firstRow)
        {
            trs[ti] = document.createElement("TR");
            if (firstDayOfMonth > 0)
            {
                while (x < firstDayOfMonth)
                {
                    trs[ti].appendChild(document.createElement("TD"));
                    x++;
                }
            }
            firstRow = false;
            var d = 1;
        }
        if (x % 7 == 0)
        {
            ti++;
            trs[ti] = document.createElement("TR");
        }
        if (day && d == day)
        {
            var setID = 'calenderChoosenDay';
            var styleClass = 'choosenDay';
            var setTitle = 'this day is currently selected';
        }
        else if (d == curDay && month == curMonth && year == curYear)
        {
            var setID = 'calenderToDay';
            var styleClass = 'toDay';
            var setTitle = 'this day today';
        }
        else
        {
            var setID = false;
            var styleClass = 'normalDay';
            var setTitle = false;
        }
        var td = document.createElement("TD");
        td.className = styleClass;
        if (setID)
        {
            td.id = setID;
        }
        if (setTitle)
        {
            td.title = setTitle;
        }
        td.onmouseover = new Function('highLiteDay(this)');
        td.onmouseout = new Function('deHighLiteDay(this)');
        if (targetEl)
            td.onclick = new Function('pickDate('+year+', '+month+', '+d+')');
        else
            td.style.cursor = 'default';
        td.appendChild(document.createTextNode(d));
        trs[ti].appendChild(td);
        x++;
        d++;
    }
    return trs;
}

function showCalender(elPos, tgtEl)
{
    if(document.getElementById("calenderTable").style.display == "block"){
        closeCalender();
        return;
    }

    targetEl = false;

    if (document.getElementById(tgtEl))
    {
        targetEl = document.getElementById(tgtEl);
    }
    else
    {
        if (document.forms[0].elements[tgtEl])
        {
            targetEl = document.forms[0].elements[tgtEl];
        }
    }
    var calTable = document.getElementById('calenderTable');

    //var positions = [0,0];
    //var positions = getParentOffset(elPos, positions);

    var positions = checkCtrl($(tgtEl));

    calTable.style.left = positions[3]+'px';
    calTable.style.top = ( positions[2] - $("divScroller").scrollTop + elPos.offsetHeight)+'px';

    calTable.style.display='block';

    var matchDate = new RegExp('^([0-9]{2})-([0-9]{2})-([0-9]{4})$');
    var m = matchDate.exec(targetEl.value);
    if (m == null)
    {
        trs = createCalender(false, false, false);
        showCalenderBody(trs);
    }
    else
    {
        if (m[1].substr(0, 1) == 0)
            m[1] = m[1].substr(1, 1);
        if (m[2].substr(0, 1) == 0)
            m[2] = m[2].substr(1, 1);
        m[2] = m[2] - 1;
        trs = createCalender(m[3], m[2], m[1]);
        showCalenderBody(trs);
    }

    //calTable.style.left = (positions[0] + elPos.offsetWidth - calTable.offsetWidth)+'px';
    //calTable.style.top = (positions[1]-calTable.offsetHeight)+'px';

    hideSelect(document.body, 1);
}
function showCalenderBody(trs)
{
    var calTBody = document.getElementById('calender');
    while (calTBody.childNodes[0])
    {
        calTBody.removeChild(calTBody.childNodes[0]);
    }
    for (var i in trs)
    {
        calTBody.appendChild(trs[i]);
    }
}
function setYears(sy, ey)
{
    // current Date
    var curDate = new Date();
    var curYear = getRealYear(curDate);
    if (sy)
        startYear = curYear;
    if (ey)
        endYear = curYear;
    document.getElementById('selectYear').options.length = 0;
    var j = 0;
    for (y=ey; y>=sy; y--)
    {
        document.getElementById('selectYear')[j++] = new Option(y, y);
    }
}
function hideSelect(el, superTotal)
{
    if (superTotal >= 100)
    {
        return;
    }

    var totalChilds = el.childNodes.length;
    for (var c=0; c<totalChilds; c++)
    {
        var thisTag = el.childNodes[c];
        if (thisTag.tagName == 'SELECT')
        {
            if (thisTag.id != 'selectMonth' && thisTag.id != 'selectYear')
            {
                var calenderEl = document.getElementById('calenderTable');
                var positions = [0,0];
                var positions = getParentOffset(thisTag, positions);	// nieuw
                var thisLeft	= positions[0];
                var thisRight	= positions[0] + thisTag.offsetWidth;
                var thisTop	= positions[1];
                var thisBottom	= positions[1] + thisTag.offsetHeight;
                var calLeft	= calenderEl.offsetLeft;
                var calRight	= calenderEl.offsetLeft + calenderEl.offsetWidth;
                var calTop	= calenderEl.offsetTop;
                var calBottom	= calenderEl.offsetTop + calenderEl.offsetHeight;

                if (
                    (
                        /* check if it overlaps horizontally */
                        (thisLeft >= calLeft && thisLeft <= calRight)
                        ||
                        (thisRight <= calRight && thisRight >= calLeft)
                        ||
                        (thisLeft <= calLeft && thisRight >= calRight)
                        )
                    &&
                    (
                        /* check if it overlaps vertically */
                        (thisTop >= calTop && thisTop <= calBottom)
                        ||
                        (thisBottom <= calBottom && thisBottom >= calTop)
                        ||
                        (thisTop <= calTop && thisBottom >= calBottom)
                        )
                    )
                    {
                    hideSelectTags[hideSelectTags.length] = thisTag;
                    thisTag.style.display = 'none';
                }
            }

        }
        else if(thisTag.childNodes.length > 0)
        {
            hideSelect(thisTag, (superTotal+1));
        }
    }
}
function closeCalender()
{
    for (var i=0; i<hideSelectTags.length; i++)
    {
        hideSelectTags[i].style.display = 'block';
    }
    hideSelectTags.length = 0;
    document.getElementById('calenderTable').style.display='none';
}
function highLiteDay(el)
{
    el.className = 'hlDay';
}
function deHighLiteDay(el)
{
    if (el.id == 'calenderToDay')
        el.className = 'toDay';
    else if (el.id == 'calenderChoosenDay')
        el.className = 'choosenDay';
    else
        el.className = 'normalDay';
}
function pickDate(year, month, day)
{
    month++;
    day	= day < 10 ? '0'+day : day;
    month	= month < 10 ? '0'+month : month;
    if (!targetEl)
    {
        alert('target for date is not set yet');
    }
    else
    {
        targetEl.value= year+'-'+month+'-'+day;
        closeCalender();
    }
}
function getParentOffset(el, positions)
{
    positions[0] += el.offsetLeft;
    positions[1] += el.offsetTop;
    if (el.offsetParent)
        positions = getParentOffset(el.offsetParent, positions);
    return positions;
}

function ajaxRequest(aElement1, search, aUrl) {
    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function() {
        handleResult(aElement1, search, httpRequest);
    };
    try {
        httpRequest.open('GET', aUrl, true);
        httpRequest.send(null);
    } catch(e){
    }
}

function handleResult(optionsList, search, aXMLHttpRequest) {
    if (!aXMLHttpRequest) return;

    if (!optionsList) return;

    if (aXMLHttpRequest.readyState == 4 && aXMLHttpRequest.status == 200) {
        optionsList.innerHTML = "";

        var initialControl = null;
        
        if($(global_control).getAttribute("initial_id") != null){
            initialControl = $($(global_control).getAttribute("initial_id"));
        }

        if(initialControl != null){
            initialControl.innerHTML = "";
        }

        if(optionsList.type.toUpperCase() == "SELECT-MULTIPLE" ||
            optionsList.type.toUpperCase() == "SELECT-ONE"){

            var result = aXMLHttpRequest.responseText.split("\n");

            for(var i = 0; i < result.length; i++){
                if(result[i].toUpperCase().match(search.toUpperCase())){
                    var opt = document.createElement("option");
                    opt.innerHTML = result[i];

                    optionsList.appendChild(opt);
                    
                    if(initialControl != null){
                        var optio = document.createElement("option");
                        optio.innerHTML = result[i];
                        
                        initialControl.appendChild(optio);
                    }
                }
            }

        }
    }
}

function checkCtrl(obj){
    var o = obj;

    if(obj == null)
        return null;

    var t = o.offsetTop;
    var l = o.offsetLeft + 1;
    var w = o.offsetWidth;
    var h = o.offsetHeight;

    while(o.offsetParent != document.body){
        o = o.offsetParent;
        t += o.offsetTop;
        l += o.offsetLeft;
    }
    return Array(w, h, t, l);
}

function showKeyboard(id){

    if($("divMenu")){
        document.body.removeChild($("divMenu"));
    }

    var p = checkCtrl($(id));

    var d = checkCtrl($("divScroller"));

    $("divScroller").scrollTop = p[2] - d[2] - 10;

    p = checkCtrl($(id));

    var iWidth = p[0];

    var div = document.createElement("div");
    div.id = "divMenu";
    div.style.top = "px";
    div.style.zIndex = 1001;
    div.style.top = p[2] + p[1] - $("divScroller").scrollTop;
    div.style.left = p[3];
    div.style.position = "absolute";

    global_control = id;

    var row1 = ["Q","W","E","R","T","Y","U","I","O","P"];
    var row2 = ["A","S","D","F","G","H","J","K","L",":"];
    var row3 = ["Z","X","C","V","B","N","M",",",".","?"];
    var row4 = ["cap","space","clear",(full_keyboard?"enter":""),(full_keyboard?"basic":"full")];
    var row5 = ["1","2","3","4","5","6","7","8","9","0"];
    var row6 = ["_","-","@","(",")","+",";","=","\\","/"];

    var tbl = document.createElement("table");
    tbl.className = "keyBoardTable";
    tbl.cellSpacing = 0;
    tbl.cellPadding = 3;
    tbl.id = "tblKeyboard";

    var tr5 = document.createElement("tr");

    for(var i = 0; i < row5.length; i++){
        var td5 = document.createElement("td");
        td5.align = "center";
        td5.vAlign = "middle";
        td5.style.cursor = "pointer";
        td5.bgColor = "#ffffff";
        td5.width = "30px";

        tr5.appendChild(td5);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row5[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td5.appendChild(btn);

    }

    if(full_keyboard){
        tbl.appendChild(tr5);
    }

    var tr1 = document.createElement("tr");

    for(var i = 0; i < row1.length; i++){
        var td1 = document.createElement("td");
        td1.align = "center";
        td1.vAlign = "middle";
        td1.style.cursor = "pointer";
        td1.bgColor = "#ffffff";
        td1.width = "30px";

        tr1.appendChild(td1);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row1[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
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
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
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
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td3.appendChild(btn);

    }

    tbl.appendChild(tr3);

    var tr6 = document.createElement("tr");

    for(var i = 0; i < row6.length; i++){
        var td6 = document.createElement("td");
        td6.align = "center";
        td6.vAlign = "middle";
        td6.style.cursor = "pointer";
        td6.bgColor = "#ffffff";
        td6.width = "30px";

        tr6.appendChild(td6);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row6[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td6.appendChild(btn);

    }

    if(full_keyboard){
        tbl.appendChild(tr6);
    }

    var tr4 = document.createElement("tr");

    for(var i = 0; i < row4.length; i++){
        var td4 = document.createElement("td");
        td4.align = "center";
        td4.vAlign = "middle";
        td4.style.cursor = "pointer";
        td4.bgColor = "#ffffff";

        switch(row4[i]){
            case "cap":
                td4.colSpan = 2;
                break;
            case "space":
                td4.colSpan = 2;
                break;
            case "clear":
                td4.colSpan = 2;
                break;
            default:
                td4.colSpan = 2;
        }

        tr4.appendChild(td4);

        var btn = document.createElement("button");
        btn.innerHTML = (row4[i].trim().length > 0 ? "<span>" + row4[i] + "</span>" : "");
        btn.onclick = function(){
            if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "cap"){
                if(this.innerHTML.match(/<span>(.+)<\/span>/)[1] == "cap"){
                    this.innerHTML = "<span>" + this.innerHTML.match(/<span>(.+)<\/span>/)[1].toUpperCase() + "</span>";

                    var cells = $("tblKeyboard").getElementsByTagName("button");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "cap"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "clear"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "space"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "full"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "basic" ){

                            cells[c].innerHTML = "<span>" + cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() + "</span>";

                        }
                    }

                } else {
                    this.innerHTML = "<span>" + this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() + "</span>";

                    var cells = $("tblKeyboard").getElementsByTagName("button");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "cap"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "clear"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "space"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "full"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "basic" ){

                            cells[c].innerHTML = "<span>" + cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toUpperCase() + "</span>";

                        }
                    }

                }
            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1] == "enter"){
                if(!this.innerHTML.match(/^$/)){
                    $(global_control).value += "\n";
                }
            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "space"){

                $(global_control).value += " ";

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "clear"){

                $(global_control).value = $(global_control).value.substring(0,$(global_control).value.length - 1);

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "full"){

                full_keyboard = true;

                showKeyboard(global_control);

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "basic"){

                full_keyboard = false;

                showKeyboard(global_control);

            } else if(!this.innerHTML.match(/<span>(.+)<\/span>/)[1].match(/^$/)){

                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];

            }
        }

        if(row4[i].trim().length > 0) {
            td4.appendChild(btn);
        } else {
            td4.innerHTML = "&nbsp;";
        }
        
    }

    tbl.appendChild(tr4);

    div.appendChild(tbl);
    document.body.appendChild(div);

    var u = checkCtrl(div);
    p = checkCtrl($(id));

    if(u[3] > ((d[0]/2)+d[3])){
        div.style.left = (parseInt(p[3]) - parseInt(u[0]) + parseInt(p[0]))+"px";
    } else if((parseInt(u[3]) + parseInt(u[0])) > (parseInt(d[3])+parseInt(d[0]))){
        div.style.left = (parseInt(d[3]) - parseInt(u[0]) + parseInt(d[0]))+"px";
    }

}

function showCalendar(id){

    if($("divMenu")){
        document.body.removeChild($("divMenu"));
    }

    var p = checkCtrl($(id));

    var d = checkCtrl($("divScroller"));

    $("divScroller").scrollTop = p[2] - d[2] - 10;

    p = checkCtrl($(id));

    var yr = new Date();
    setYears(yr.getFullYear() - 30, yr.getFullYear() + 10);
    showCalender($(id), id);
}

function showNumber(id){

    if($("divMenu")){
        document.body.removeChild($("divMenu"));
    }

    var p = checkCtrl($(id));

    var d = checkCtrl($("divScroller"));

    $("divScroller").scrollTop = p[2] - d[2] - 10;

    p = checkCtrl($(id));

    var div = document.createElement("div");
    div.id = "divMenu";
    div.style.top = "px";
    div.style.zIndex = 1001;
    div.style.top = p[2] + p[1] - $("divScroller").scrollTop;
    div.style.left = p[3];
    div.style.position = "absolute";

    global_control = id;

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
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
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
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
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
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
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
                $(global_control).value = $(global_control).value.substring(0,$(global_control).value.length - 1);
            }else if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
            }
        }

        td4.appendChild(btn);

    }

    tbl.appendChild(tr4);

    div.appendChild(tbl);
    document.body.appendChild(div);

}

function showYear(id){

    if($("divMenu")){
        document.body.removeChild($("divMenu"));
    }

    var p = checkCtrl($(id));

    var d = checkCtrl($("divScroller"));

    $("divScroller").scrollTop = p[2] - d[2] - 10;

    p = checkCtrl($(id));

    var div = document.createElement("div");
    div.id = "divMenu";
    div.style.top = "px";
    div.style.zIndex = 1001;
    div.style.backgroundColor = "#EEEEEE";
    div.style.top = p[2] + p[1] - $("divScroller").scrollTop;
    div.style.width = p[0];
    div.style.left = p[3];
    div.style.position = "absolute";

    var sel = document.createElement("select");
    sel.style.height = "200px";
    sel.style.width = "100%";
    sel.size = 10;
    sel.style.fontSize = "1.5em";

    div.appendChild(sel);

    sel.onclick = function(){
        $(id).value = this[this.selectedIndex].innerHTML;
        document.body.removeChild($("divMenu"));
    }

    var d = new Date();

    for(var i = 1970; i < d.getFullYear()+10; i++){
        var opt = document.createElement("option");

        opt.innerHTML = i;

        if(i == d.getFullYear()){
            opt.selected = "true";
        }

        sel.appendChild(opt);
    }

    document.body.appendChild(div);

}
/*
function showMenu(id, original_id){
    if($("divMenu")){
        document.body.removeChild($("divMenu"));
        return;
    }

    var p = checkCtrl($(id));

    var d = checkCtrl($("divScroller"));

    $("divScroller").scrollTop = p[2] - d[2] - 10;

    p = checkCtrl($(id));

    var div = document.createElement("div");
    div.id = "divMenu";
    div.style.top = "px";
    div.style.zIndex = 1001;
    div.style.backgroundColor = "#EEEEEE";
    div.style.top = p[2] + p[1] - $("divScroller").scrollTop;
    div.style.width = p[0];
    div.style.left = p[3];
    div.style.position = "absolute";

    var sel = document.createElement("select");
    sel.style.height = "200px";
    sel.style.width = "100%";
    sel.size = 10;
    sel.style.fontSize = "1.5em";
    sel.id = "sel";

    div.appendChild(sel);

    sel.onclick = function(){
        if(this.selectedIndex >= 0){
            $(id).value = this[this.selectedIndex].innerHTML;

            $(id).className = "availableValue labelText textInput";
        }

        document.body.removeChild($("divMenu"));
    }


    document.body.appendChild(div);

    if($(original_id).getAttribute("ajaxURL") != null){
        $(id).setAttribute("ajaxURL", $(original_id).getAttribute("ajaxURL"));
    }

    if($(id).getAttribute("ajaxURL") == null){
        for(var i = 0; i < $(original_id).options.length; i++){
            var opt = document.createElement("option");

            opt.value = $(original_id).options[i].value;
            opt.innerHTML = $(original_id).options[i].innerHTML;

            sel.appendChild(opt);
        }
    } else {
        showSelectKeyboard(id, "sel");
    }
}

function showSelectKeyboard(id, target){

    if($("divKeyboardMenu")){
        $("divMenu").removeChild($("divKeyboardMenu"));
    }

    var p = checkCtrl($(target));

    var d = checkCtrl($("divScroller"));

    $("divScroller").scrollTop = p[2] - d[2] - 10;

    p = checkCtrl($(target));

    var divMenu = $("divMenu");

    var div = document.createElement("div");
    div.id = "divKeyboardMenu";
    div.style.position = "absolute";
    div.style.left = (-295) + "px";

    global_control = id;

    assignValue($(global_control).value.trim());

    var row1 = ["Q","W","E","R","T","Y","U","I","O","P"];
    var row2 = ["A","S","D","F","G","H","J","K","L",":"];
    var row3 = ["Z","X","C","V","B","N","M",",",".","?"];
    var row4 = ["cap","space","clear",(full_keyboard?"enter":""),""];
    var row5 = ["1","2","3","4","5","6","7","8","9","0"];
    var row6 = ["_","-","@","(",")","+",";","=","\\","/"];

    var tbl = document.createElement("table");
    tbl.className = "keyBoardTable";
    tbl.cellSpacing = 0;
    tbl.cellPadding = 3;
    tbl.id = "tblKeyboard";

    var tr5 = document.createElement("tr");

    for(var i = 0; i < row5.length; i++){
        var td5 = document.createElement("td");
        td5.align = "center";
        td5.vAlign = "middle";
        td5.style.cursor = "pointer";
        td5.bgColor = "#ffffff";
        td5.width = "30px";

        tr5.appendChild(td5);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row5[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
            }
        }

        td5.appendChild(btn);

    }

    if(full_keyboard){
        tbl.appendChild(tr5);
    }

    var tr1 = document.createElement("tr");

    for(var i = 0; i < row1.length; i++){
        var td1 = document.createElement("td");
        td1.align = "center";
        td1.vAlign = "middle";
        td1.style.cursor = "pointer";
        td1.bgColor = "#ffffff";
        td1.width = "30px";

        tr1.appendChild(td1);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row1[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
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
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
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
            if(!this.innerHTML.match(/^$/)){
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
            }
        }

        td3.appendChild(btn);

    }

    tbl.appendChild(tr3);

    var tr6 = document.createElement("tr");

    for(var i = 0; i < row6.length; i++){
        var td6 = document.createElement("td");
        td6.align = "center";
        td6.vAlign = "middle";
        td6.style.cursor = "pointer";
        td6.bgColor = "#ffffff";
        td6.width = "30px";

        tr6.appendChild(td6);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row6[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
            }
        }

        td6.appendChild(btn);

    }

    if(full_keyboard){
        tbl.appendChild(tr6);
    }

    var tr4 = document.createElement("tr");

    for(var i = 0; i < row4.length; i++){
        var td4 = document.createElement("td");
        td4.align = "center";
        td4.vAlign = "middle";
        td4.style.cursor = "pointer";
        td4.bgColor = "#ffffff";

        switch(row4[i]){
            case "cap":
                td4.colSpan = 2;
                break;
            case "space":
                td4.colSpan = 2;
                break;
            case "clear":
                td4.colSpan = 2;
                break;
            default:
                td4.colSpan = 2;
        }

        tr4.appendChild(td4);

        var btn = document.createElement("button");
        btn.innerHTML = (row4[i].trim().length > 0 ? "<span>" + row4[i] + "</span>" : "");
        btn.onclick = function(){
            if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "cap"){
                if(this.innerHTML.match(/<span>(.+)<\/span>/)[1] == "cap"){
                    this.innerHTML = "<span>" + this.innerHTML.match(/<span>(.+)<\/span>/)[1].toUpperCase() + "</span>";

                    var cells = $("tblKeyboard").getElementsByTagName("button");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "cap"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "clear"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "space"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "full"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "basic" ){

                            cells[c].innerHTML = "<span>" + cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() + "</span>";

                        }
                    }

                } else {
                    this.innerHTML = "<span>" + this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() + "</span>";

                    var cells = $("tblKeyboard").getElementsByTagName("button");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "cap"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "clear"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "space"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "full"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "basic" ){

                            cells[c].innerHTML = "<span>" + cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toUpperCase() + "</span>";

                        }
                    }

                }
            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1] == "enter"){
                if(!this.innerHTML.match(/^$/)){
                    assignValue($(global_control).value +  "\n");
                }
            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "space"){

                assignValue($(global_control).value +  " ");

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "clear"){

                assignValue($(global_control).value.substring(0,$(global_control).value.length - 1));

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "full"){

                full_keyboard = true;

                showSelectKeyboard(global_control);

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "basic"){

                full_keyboard = false;

                showSelectKeyboard(global_control);

            } else if(!this.innerHTML.match(/<span>(.+)<\/span>/)[1].match(/^$/)){

                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);

            }
        }

        if(row4[i].trim().length > 0) {
            td4.appendChild(btn);
        } else {
            td4.innerHTML = "&nbsp;";
        }

    }

    tbl.appendChild(tr4);

    div.appendChild(tbl);
    divMenu.appendChild(div);

    var u = checkCtrl(div);
    p = checkCtrl($(target));

    if(u[3] > ((d[0]/2)+d[3])){
        div.style.left = (parseInt(p[3]) - parseInt(u[0]) + parseInt(p[0]))+"px";
    } else if((parseInt(u[3]) + parseInt(u[0])) > (parseInt(d[3])+parseInt(d[0]))){
        div.style.left = (parseInt(d[3]) - parseInt(u[0]) + parseInt(d[0]))+"px";
    }

}

function assignValue(value){
    $(global_control).value = value;

    if($(global_control).getAttribute("ajaxURL") != null){
        ajaxRequest($('sel'), $(global_control).value.trim(), $(global_control).getAttribute('ajaxURL'));
    }
}
*/

function showMenu(id, original_id){

    if($("divMenu")){
        document.body.removeChild($("divMenu"));
        selectValue = "";
        return;
    }

    var p = checkCtrl($(id));

    var d = checkCtrl($("divScroller"));

    $("divScroller").scrollTop = p[2] - d[2] - 10;

    p = checkCtrl($(id));

    var div = document.createElement("div");
    div.id = "divMenu";
    div.style.top = "px";
    div.style.zIndex = 1001;
    div.style.backgroundColor = "#EEEEEE";
    div.style.top = p[2] + p[1] - $("divScroller").scrollTop;
    div.style.width = p[0];
    div.style.left = p[3];
    div.style.position = "absolute";

    var sel = document.createElement("select");
    sel.style.height = "200px";
    sel.style.width = "100%";
    sel.size = 10;
    sel.style.fontSize = "1.5em";
    sel.id = "sel";

    div.appendChild(sel);

    sel.onclick = function(){
        if(this.selectedIndex >= 0){
            $(id).value = this[this.selectedIndex].innerHTML;

            $(id).className = "availableValue labelText textInput";
        }

        document.body.removeChild($("divMenu"));
    }


    document.body.appendChild(div);

    if($(original_id).getAttribute("ajaxURL") != null){
        $(id).setAttribute("ajaxURL", $(original_id).getAttribute("ajaxURL"));
    }

    if($(id).getAttribute("ajaxURL") == null){
        for(var i = 0; i < $(original_id).options.length; i++){
            var opt = document.createElement("option");

            opt.value = $(original_id).options[i].value;
            opt.innerHTML = $(original_id).options[i].innerHTML;

            sel.appendChild(opt);
        }
        showSelectKeyboard(id, "sel");
    } else {
        showSelectKeyboard(id, "sel");
    }
}

function showSelectKeyboard(id, target){

    if($("divKeyboardMenu")){
        $("divMenu").removeChild($("divKeyboardMenu"));
    }

    var p = checkCtrl($(id));

    var d = checkCtrl($("divScroller"));

    $("divScroller").scrollTop = p[2] - d[2] - 10;

    p = checkCtrl($(id));

    var divMenu = $("divMenu");

    var div = document.createElement("div");
    div.id = "divKeyboardMenu";
    div.style.position = "absolute";
    div.style.left = (-295) + "px";

    global_control = id;

    assignValue($(global_control).value.trim());

    var row1 = ["Q","W","E","R","T","Y","U","I","O","P"];
    var row2 = ["A","S","D","F","G","H","J","K","L",":"];
    var row3 = ["Z","X","C","V","B","N","M",",",".","?"];
    var row4 = ["cap","space","clear",(full_keyboard?"enter":""),""];
    var row5 = ["1","2","3","4","5","6","7","8","9","0"];
    var row6 = ["_","-","@","(",")","+",";","=","\\","/"];

    var tbl = document.createElement("table");
    tbl.className = "keyBoardTable";
    tbl.cellSpacing = 0;
    tbl.cellPadding = 3;
    tbl.id = "tblKeyboard";

    var tr5 = document.createElement("tr");

    for(var i = 0; i < row5.length; i++){
        var td5 = document.createElement("td");
        td5.align = "center";
        td5.vAlign = "middle";
        td5.style.cursor = "pointer";
        td5.bgColor = "#ffffff";
        td5.width = "30px";

        tr5.appendChild(td5);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row5[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                selectValue += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
            }
        }

        td5.appendChild(btn);

    }

    if(full_keyboard){
        tbl.appendChild(tr5);
    }

    var tr1 = document.createElement("tr");

    for(var i = 0; i < row1.length; i++){
        var td1 = document.createElement("td");
        td1.align = "center";
        td1.vAlign = "middle";
        td1.style.cursor = "pointer";
        td1.bgColor = "#ffffff";
        td1.width = "30px";

        tr1.appendChild(td1);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row1[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                selectValue += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
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
                selectValue += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
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
            if(!this.innerHTML.match(/^$/)){
                selectValue += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
            }
        }

        td3.appendChild(btn);

    }

    tbl.appendChild(tr3);

    var tr6 = document.createElement("tr");

    for(var i = 0; i < row6.length; i++){
        var td6 = document.createElement("td");
        td6.align = "center";
        td6.vAlign = "middle";
        td6.style.cursor = "pointer";
        td6.bgColor = "#ffffff";
        td6.width = "30px";

        tr6.appendChild(td6);

        var btn = document.createElement("button");
        btn.className = "blue";
        btn.innerHTML = "<span>" + row6[i] + "</span>";
        btn.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                selectValue += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);
            }
        }

        td6.appendChild(btn);

    }

    if(full_keyboard){
        tbl.appendChild(tr6);
    }

    var tr4 = document.createElement("tr");

    for(var i = 0; i < row4.length; i++){
        var td4 = document.createElement("td");
        td4.align = "center";
        td4.vAlign = "middle";
        td4.style.cursor = "pointer";
        td4.bgColor = "#ffffff";

        switch(row4[i]){
            case "cap":
                td4.colSpan = 2;
                break;
            case "space":
                td4.colSpan = 2;
                break;
            case "clear":
                td4.colSpan = 2;
                break;
            default:
                td4.colSpan = 2;
        }

        tr4.appendChild(td4);

        var btn = document.createElement("button");
        btn.innerHTML = (row4[i].trim().length > 0 ? "<span>" + row4[i] + "</span>" : "");
        btn.onclick = function(){
            if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "cap"){
                if(this.innerHTML.match(/<span>(.+)<\/span>/)[1] == "cap"){
                    this.innerHTML = "<span>" + this.innerHTML.match(/<span>(.+)<\/span>/)[1].toUpperCase() + "</span>";

                    var cells = $("tblKeyboard").getElementsByTagName("button");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "cap"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "clear"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "space"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "full"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "basic" ){

                            cells[c].innerHTML = "<span>" + cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() + "</span>";

                        }
                    }

                } else {
                    this.innerHTML = "<span>" + this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() + "</span>";

                    var cells = $("tblKeyboard").getElementsByTagName("button");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "cap"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "clear"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "space"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "full"
                            && cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() != "basic" ){

                            cells[c].innerHTML = "<span>" + cells[c].innerHTML.match(/<span>(.+)<\/span>/)[1].toUpperCase() + "</span>";

                        }
                    }

                }
            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1] == "enter"){
                if(!this.innerHTML.match(/^$/)){
                    selectValue += "\n";
                    assignValue($(global_control).value +  "\n");
                }
            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "space"){

                selectValue += " ";
                assignValue($(global_control).value +  " ");

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "clear"){

                selectValue = selectValue.substring(0, selectValue.length - 1);
                assignValue($(global_control).value.substring(0,$(global_control).value.length - 1));

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "full"){

                full_keyboard = true;

                showSelectKeyboard(global_control);

            } else if(this.innerHTML.match(/<span>(.+)<\/span>/)[1].toLowerCase() == "basic"){

                full_keyboard = false;

                showSelectKeyboard(global_control);

            } else if(!this.innerHTML.match(/<span>(.+)<\/span>/)[1].match(/^$/)){

                selectValue += this.innerHTML.match(/<span>(.+)<\/span>/)[1];
                assignValue($(global_control).value +  this.innerHTML.match(/<span>(.+)<\/span>/)[1]);

            }
        }

        if(row4[i].trim().length > 0) {
            td4.appendChild(btn);
        } else {
            td4.innerHTML = "&nbsp;";
        }

    }

    tbl.appendChild(tr4);

    div.appendChild(tbl);
    divMenu.appendChild(div);

    var u = checkCtrl(div);
    p = checkCtrl($(target));

/*
    if(u[3] > ((d[0]/2)+d[3])){
        div.style.left = (parseInt(p[3]) - parseInt(u[0]) + parseInt(p[0]))+"px";
    } else if((parseInt(u[3]) + parseInt(u[0])) > (parseInt(d[3])+parseInt(d[0]))){
        div.style.left = (parseInt(d[3]) - parseInt(u[0]) + parseInt(d[0]))+"px";
    }
*/
}

function assignValue(value){
    $(global_control).value = value;

    if($(global_control).getAttribute("ajaxURL") != null){
        ajaxRequest($('sel'), $(global_control).value.trim(), $(global_control).getAttribute('ajaxURL'));
    } else {
        filterSelection(global_control);
    }
}

function filterSelection(id){
    var old_id = $(id).getAttribute("initial_id");

    if(old_id == null)
        return;
    
    if($(old_id).type.toUpperCase() == "SELECT-MULTIPLE" ||
        $(old_id).type.toUpperCase() == "SELECT-ONE"){

        var result = $(old_id).options;
        $('sel').innerHTML = "";

        for(var i = 0; i < result.length; i++){
            if(result[i].innerHTML.toUpperCase().match(selectValue.toUpperCase())){
                var opt = document.createElement("option");
                opt.innerHTML = result[i].innerHTML;

                $('sel').appendChild(opt);
            }
        }

    }
}


function getSections(){
    return document.forms[0].getElementsByTagName("table");
}

function navigateTo(section){
    if($("frmAnswers") && section <= sections.length && remoteNavigation == false){
        var element = $("frmAnswers").elements;

        for(var i = 0; i < element.length; i++){
            if(String(element[i].id).match(/secondary_(.+)/)){
                var id = String(element[i].id).match(/secondary_(.+)/)[1];

                if($(id).tagName.toLowerCase() == "select"){
                    for(var j = 0; j < $(id).options.length; j++){
                        if(element[i].value.toLowerCase() == $(id).options[j].innerHTML.toLowerCase()){
                            $(id).selectedIndex = j;
                            break;
                        }
                    }
                } else {
                    $(id).value = element[i].value;
                }
            }
        }

        $("content").removeChild($("cntr"));
    } else if(remoteNavigation == true) {
        $("content").removeChild($("cntr"));
    }

    remoteNavigation = false;
    
    if(tstCurrentPage == sections.length){
        showSummary();
    } else if(section > (sections.length)){
        document.forms[0].submit();
    } else {
        transformPage(section);
    }
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
    var textareas = sections[section].getElementsByTagName("textarea");

    var formElements = [];

    //Push:      i. Question position
    //          ii. Pass control object
    //         iii. Check if question optional
    //into formElements
    for(var i = 0; i < selects.length; i++){
        selects[i].setAttribute("field_type", "select");
        selects[i].setAttribute("section", section);

        if(!elements[selects[i].id]){
            elements[selects[i].id] = true;
            elementIDs.push([selects[i].getAttribute("position"), selects[i].id]);
        }
        
        formElements.push([selects[i].getAttribute("position"), selects[i],
            (selects[i].getAttribute("optional") != null ? true : false)]);
    }

    for(var i = 0; i < textareas.length; i++){
        textareas[i].setAttribute("field_type", "textarea");
        textareas[i].setAttribute("section", section);

        if(!elements[textareas[i].id]){
            elements[textareas[i].id] = true;
            elementIDs.push([textareas[i].getAttribute("position"), textareas[i].id]);
        }

        formElements.push([textareas[i].getAttribute("position"), textareas[i],
            (textareas[i].getAttribute("optional") != null ? true : false)]);
    }

    for(var i = 0; i < inputs.length; i++){
        if(inputs[i].type != "hidden"){

            inputs[i].setAttribute("section", section);
            
            if(!elements[inputs[i].id]){
                elements[inputs[i].id] = true;
                elementIDs.push([inputs[i].getAttribute("position"), inputs[i].id]);
            }
        
            formElements.push([inputs[i].getAttribute("position"), inputs[i],
                (inputs[i].getAttribute("optional") != null ? true : false)]);
        }
    }

    formElements.sort();

    for(var i = 0; i < formElements.length; i++){
        if(formElements[i][1].tagName != "BUTTON"){
            if(formElements[i][1].tagName == "INPUT"){
                if(formElements[i][1].type != "button" && formElements[i][1].type != "submit" &&
                    formElements[i][1].type != "reset"){
                    actualElements[formElements[i][1].id] = [formElements[i],
                    getLabel(formElements[i][1].id), formElements[i][1].getAttribute("field_type"), formElements[i][2]];
                }
            } else if(formElements[i][1].tagName == "TEXTAREA"){
                actualElements[formElements[i][1].id] = [formElements[i],
                getLabel(formElements[i][1].id), formElements[i][1].getAttribute("field_type"), formElements[i][2]];
            } else {
                actualElements[formElements[i][1].id] = [formElements[i][1],
                getLabel(formElements[i][1].id), formElements[i][1].getAttribute("field_type"), formElements[i][2]];
            }
        }
    }

    generatePage(document.forms[0].action, document.forms[0].method, section);
}

function getLabel(id){
    var labels = document.getElementsByTagName("label");

    if($(id)){
        var helpText = $(id).getAttribute("helpText");

        if(helpText)
            return helpText;
    }

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

    var cntr = document.createElement("div");
    var headerText = (document.forms[0].getAttribute("headerLabel") ? document.forms[0].getAttribute("headerLabel") : "&nbsp;") +
    " - (" + (tstCurrentPage + 1) + " of " + sections.length + ")";
    cntr.id = "cntr";

    $("content").appendChild(cntr);

    var divmain = document.createElement("div");
    divmain.id = "divmain";

    cntr.appendChild(divmain);

    var divheader = document.createElement("div");
    divheader.id = "divheader";
    divheader.innerHTML = headerText;

    divmain.appendChild(divheader);

    var divcontent = document.createElement("div");
    divcontent.id = "divcontent";

    divmain.appendChild(divcontent);

    var divInside = document.createElement("div");
    divInside.id = "divScroller";

    divcontent.appendChild(divInside);

    var divnav = document.createElement("div");
    divnav.id = "footer";

    divmain.appendChild(divnav);

    var btnNext = document.createElement("button");
    btnNext.id = "btnNext";
    btnNext.innerHTML = (tstCurrentPage >= sections.length ? "<span>Finish</span>" : "<span>Next</span>");
    btnNext.style.cssFloat = "right";
    btnNext.className = "green navButton";
    btnNext.onclick = function(){
        if(checkFields()){
            tstCurrentPage += 1;
            navigateTo(tstCurrentPage);
            $("btnNext").innerHTML = (tstCurrentPage >= sections.length ? "<span>Finish</span>" : "<span>Next</span>");
        }
    }

    divnav.appendChild(btnNext);

    var btnClear = document.createElement("button");
    btnClear.id = "btnClear";
    btnClear.innerHTML = "<span>Clear</span>";
    btnClear.style.cssFloat = "right";
    btnClear.className = "blue navButton";
    btnClear.onclick = function(){
        $("frmAnswers").reset();
        var formButtons = $("frmAnswers").getElementsByTagName("button");
        var relevantButtons = {};

        for(var b = 0; b < formButtons.length; b++){
            if(!relevantButtons[formButtons[b].getAttribute("initial_id")]){
                relevantButtons[formButtons[b].getAttribute("initial_id")] = true;
            }
        }

        for(var btn in relevantButtons){
            $(btn).selectedIndex = -1;
            var buttons = document.getElementsByName(btn + "_buttons");

            for(var e = 0; e < buttons.length; e++){
                buttons[e].className = "blue";
            }
        }
    }

    divnav.appendChild(btnClear);

    var btnBack = document.createElement("button");
    btnBack.id = "btnBack";
    btnBack.innerHTML = "<span>Back</span>";
    btnBack.style.cssFloat = "right";
    btnBack.className = "blue navButton";
    btnBack.style.display = (tstCurrentPage > 0 ? "block" : "none");
    btnBack.onclick = function(){
        tstCurrentPage -= 1;
        navigateTo(tstCurrentPage);
    }

    divnav.appendChild(btnBack);

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

    divnav.appendChild(btnCancel);

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
        td2.style.width = "50%";
        
        var found_long = false;
        
        tbody.appendChild(tr);
        tr.appendChild(td1);
        tr.appendChild(td2);

        td1.className = "labelText";
        td1.innerHTML = actualElements[el][1];

        var controlType = actualElements[el][2];
        
        var input = document.createElement((controlType == "textarea" ? "textarea" : "input"));
        if(controlType != "textarea"){
            input.type = "text";
            input.className = "labelText textInput";
            input.style.width = "100%";
            input.onchange = function(){
                if(!this.value.trim().match(/^$/)){
                    this.className = "availableValue labelText textInput";
                }
            }
        } else {
            input.className = "labelText textInput";
            input.style.height = "250px";
            input.style.width = "600px";
            input.style.cssFloat = "right";
            input.onchange = function(){
                if(!this.value.trim().match(/^$/)){
                    this.className = "availableValue labelText textInput";
                }
            }
        }

        if(actualElements[el][3] == true){
            input.setAttribute("optional", "true");
        }
        
        input.id = "secondary_" + el;
        input.name = "secondary_" + el;
        input.setAttribute("initial_id", el)

        if($(el).getAttribute("validationRule") != null){
            input.setAttribute("validationRule", $(el).getAttribute("validationRule"))
        }

        if($(el).getAttribute("validationMessage") != null){
            input.setAttribute("validationMessage", $(el).getAttribute("validationMessage"))
        }

        switch(actualElements[el][2]){
            case "number":
                input.onclick = function(){
                    if($('divMenu')){
                        document.body.removeChild($('divMenu'));
                        if(!this.value.trim().match(/^$/)){
                            this.className = "availableValue labelText textInput";
                        }
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
                        if(!this.value.trim().match(/^$/)){
                            this.className = "availableValue labelText textInput";
                        }
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
                        if(!this.value.trim().match(/^$/)){
                            this.className = "availableValue labelText textInput";
                        }
                    } else {
                        showCalendar(this.id);
                    }
                }
                textThere = true;
                break;
            case "select":
                //Check if select control options have long values
                found_long = false;

                for(var o = 0; o < $(el).options.length; o++){
                    if($(el).options[o].innerHTML.length > 7) {
                        found_long = true;
                        break;
                    }
                }

                // Check if select control options are greater than 3
                if($(el).options.length > 4 || found_long == true) {
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
                        if(!this.value.trim().match(/^$/)){
                            this.className = "availableValue labelText textInput";
                        }
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
        if($(el).tagName == "SELECT" && $(el).getAttribute("ajaxURL") == null){

            //Check if select control options have long values
            found_long = false;

            for(var o = 0; o < $(el).options.length; o++){
                if($(el).options[o].innerHTML.length > 7) {
                    found_long = true;
                    break;
                }
            }

            if($(el).options.length <= 7 && found_long == false){

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
                        button.className = (unescape($(el).value) == unescape($(el).options[i].innerHTML) ? "green" : "blue");
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

                                    for(var w = 0; w < $(this.getAttribute("initial_id")).options.length; w++){
                                        if($(this.getAttribute("initial_id")).options[w].innerHTML == this.value &&
                                            !$(this.getAttribute("initial_id")).options[w].innerHTML.match(/^$/)){

                                            $(this.getAttribute("initial_id")).selectedIndex = w;
                                            break;
                                            
                                        }
                                    }
                                    
                                } else {
                                    btns[b].className = "blue";
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

function checkFields(){
    if(!$("frmAnswers")){
        alert("No form to check! Returning!");
        return false;
    }

    var formInputs = $("frmAnswers").getElementsByTagName("input");
    var formTextAreas = $("frmAnswers").getElementsByTagName("textarea");
    var formButtons = $("frmAnswers").getElementsByTagName("button");
    var relevantButtons = {};

    for(var b = 0; b < formButtons.length; b++){
        if(!relevantButtons[formButtons[b].getAttribute("initial_id")]){
            relevantButtons[formButtons[b].getAttribute("initial_id")] = true;
        }        
    }


    for(var btn in relevantButtons){
        var buttons = document.getElementsByName(btn + "_buttons");
        var notSet = true;

        for(var e = 0; e < buttons.length; e++){
            if(buttons[e].className == "green"){
                notSet = false;
            }
        }

        if(notSet){
            for(var e = 0; e < buttons.length; e++){
                buttons[e].className = "red"
            }
            alert("Missing selection in non-optional question!");
                
            return false;
        }
    }

    for(var i = 0; i < formInputs.length; i++){
        if(formInputs[i].getAttribute("optional") == null){
            var validation = validateRule(formInputs[i]);

            if(validation.trim().length > 0){
                alert(validation);
                formInputs[i].className = "missingValue labelText textInput";
                return false;
            } else if(formInputs[i].value.trim().length <= 0){
                alert("Missing value in non-optional question!");
                formInputs[i].className = "missingValue labelText textInput";
                return false;
            } else {
                formInputs[i].className = "availableValue labelText textInput";
            }
        }
    }

    for(var i = 0; i < formTextAreas.length; i++){
        if(formTextAreas[i].getAttribute("optional") == null){
            var validationText = validateRule(formTextAreas[i]);

            if(validationText.trim().length > 0){
                alert(validationText);
                formInputs[i].className = "missingValue labelText textInput";
                return false;
            } else if(formTextAreas[i].value.trim().length <= 0){
                alert("Missing value in non-optional question!");
                formTextAreas[i].className = "missingValue labelText textInput";
                return false;
            } else {
                formTextAreas[i].className = "availableValue labelText textInput";
            }
        }
    }

    return true;
}

function validateRule(aNumber) {
    var aRule = aNumber.getAttribute("validationRule")
    if (aRule==null) return ""

    var re = new RegExp(aRule)
    if (aNumber.value.search(re) ==-1){
        var aMsg= aNumber.getAttribute("validationMessage")
        if (aMsg ==null || aMsg=="")
            return "Please enter a valid value"
        else
            return aMsg
    }
    return ""
}

function createCalendarHTML(){

    var table = document.createElement("table");
    table.id = "calenderTable";

    document.body.appendChild(table);

    var tbody1 = document.createElement("tbody");
    tbody1.id = "calenderTableHead";

    table.appendChild(tbody1);

    var tr1 = document.createElement("tr");

    tbody1.appendChild(tr1);

    var td1_1 = document.createElement("td");
    td1_1.setAttribute("colspan", 4);
    td1_1.align = "center";

    tr1.appendChild(td1_1);

    var selectMonth = document.createElement("select");
    selectMonth.id = "selectMonth";
    selectMonth.style.fontSize = "1.2em";
    
    selectMonth.onchange = function(){
        showCalenderBody(createCalender(document.getElementById('selectYear').value,
            this.selectedIndex, false));
    }

    var months = [[0, "Jan"],
    [1, "Feb"],
    [2, "Mar"],
    [3, "Apr"],
    [4, "May"],
    [5, "Jun"],
    [6, "Jul"],
    [7, "Aug"],
    [8, "Sep"],
    [9, "Oct"],
    [10, "Nov"],
    [11, "Dec"]
    ]

    for(var month = 0; month < months.length; month++){
        var opt = document.createElement("option");
        opt.value = months[month][0];
        opt.innerHTML = months[month][1];

        selectMonth.appendChild(opt);
    }

    td1_1.appendChild(selectMonth);

    var td1_2 = document.createElement("td");
    td1_2.setAttribute("colspan", 2);
    td1_2.align = "center";
    
    td1_2.innerHTML = "<select onChange=\"showCalenderBody(createCalender(this.value," +
    " document.getElementById('selectMonth').selectedIndex, false));\"" +
    " id=\"selectYear\" style=\"font-size:1.2em\"> " +
    "</select>";

    tr1.appendChild(td1_2);

    var td1_3 = document.createElement("td");
    td1_3.align = "center";

    td1_3.innerHTML = "<a href=\"#\" onClick=\"closeCalender();\">" +
    "<font color=\"#003333\" size=\"+1\">X</font>" +
    "</a>";

    tr1.appendChild(td1_3);

    var tbody2 = document.createElement("tbody");
    tbody2.id = "calenderTableDays";

    table.appendChild(tbody2);

    var tr2 = document.createElement("tr");

    tbody2.appendChild(tr2);

    tr2.innerHTML = '<td class="header-cell">Sun</td><td class="header-cell">Mon</td>' +
    '<td class="header-cell">Tue</td><td class="header-cell">Wed</td>' +
    '<td class="header-cell">Thu</td><td class="header-cell">Fri</td>' +
    '<td class="header-cell">Sat</td>';

    var tbody3 = document.createElement("tbody");
    tbody3.id = "calender";

    table.appendChild(tbody3);

}

function showSummary(){
    remoteNavigation = true;
    
    document.forms[0].style.display = "none";

    var cntr = document.createElement("div");
    var headerText = (document.forms[0].getAttribute("headerLabel") ? document.forms[0].getAttribute("headerLabel") : "&nbsp;") +
    " Summary";
    cntr.id = "cntr";

    $("content").appendChild(cntr);

    var divmain = document.createElement("div");
    divmain.id = "divmain";

    cntr.appendChild(divmain);

    var divheader = document.createElement("div");
    divheader.id = "divheader";
    divheader.innerHTML = headerText;

    divmain.appendChild(divheader);

    var divcontent = document.createElement("div");
    divcontent.id = "divcontent";

    divmain.appendChild(divcontent);

    var divInside = document.createElement("div");
    divInside.id = "divScroller";

    divcontent.appendChild(divInside);

    var divnav = document.createElement("div");
    divnav.id = "footer";

    divmain.appendChild(divnav);

    var btnNext = document.createElement("button");
    btnNext.id = "btnNext";
    btnNext.innerHTML = (tstCurrentPage >= sections.length - 1 ? "<span>Finish</span>" : "<span>Next</span>");
    btnNext.style.cssFloat = "right";
    btnNext.className = "green navButton";
    btnNext.onclick = function(){
        if(checkFields()){
            tstCurrentPage += 1;
            navigateTo(tstCurrentPage);
            $("btnNext").innerHTML = (tstCurrentPage >= sections.length - 1? "<span>Finish</span>" : "<span>Next</span>");
        }
    }

    divnav.appendChild(btnNext);

    var btnClear = document.createElement("button");
    btnClear.id = "btnClear";
    btnClear.innerHTML = "<span>Clear</span>";
    btnClear.style.cssFloat = "right";
    btnClear.className = "blue navButton";
    btnClear.onclick = function(){
        $("frmAnswers").reset();
        var formButtons = $("frmAnswers").getElementsByTagName("button");
        var relevantButtons = {};

        for(var b = 0; b < formButtons.length; b++){
            if(!relevantButtons[formButtons[b].getAttribute("initial_id")]){
                relevantButtons[formButtons[b].getAttribute("initial_id")] = true;
            }
        }

        for(var btn in relevantButtons){
            $(btn).selectedIndex = -1;
            var buttons = document.getElementsByName(btn + "_buttons");

            for(var e = 0; e < buttons.length; e++){
                buttons[e].className = "blue";
            }
        }
    }

    //divnav.appendChild(btnClear);

    var btnBack = document.createElement("button");
    btnBack.id = "btnBack";
    btnBack.innerHTML = "<span>Back</span>";
    btnBack.style.cssFloat = "right";
    btnBack.className = "blue navButton";
    btnBack.style.display = (tstCurrentPage > 0 ? "block" : "none");
    btnBack.onclick = function(){
        tstCurrentPage -= 1;
        navigateTo(tstCurrentPage);
    }

    divnav.appendChild(btnBack);

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

    divnav.appendChild(btnCancel);

    var frm = document.createElement("form");
    frm.id = "frmAnswers";
    frm.setAttribute("autocomplete", "off");

    divInside.appendChild(frm);

    var tbl = document.createElement("table");
    tbl.width = "95%";
    tbl.cellSpacing = 1;
    tbl.cellPadding = 2;

    frm.appendChild(tbl);

    var tbody = document.createElement("tbody");

    tbl.appendChild(tbody);

    elementIDs.sort();

    var pages = {};

    for(var el = 0; el < elementIDs.length; el++){
        var tr = document.createElement("tr");
        var td1 = document.createElement("td");
        var td2 = document.createElement("td");

        tbody.appendChild(tr);
        tr.appendChild(td1);
        tr.appendChild(td2);

        td1.className = "labelText";

        if($(elementIDs[el][1])){
            if(!pages[$(elementIDs[el][1]).getAttribute("section")]){
                pages[$(elementIDs[el][1]).getAttribute("section")] = [el];
            } else {
                pages[$(elementIDs[el][1]).getAttribute("section")].push(el);
            }
            
            td1.innerHTML = "<div style='padding: 10px; color: #333;'><div class='question'>(" +
            (parseInt($(elementIDs[el][1]).getAttribute("section")) + 1) + "." +
            pages[$(elementIDs[el][1]).getAttribute("section")].length +
            "). <a href='#' onclick='tstCurrentPage = " +
            $(elementIDs[el][1]).getAttribute("section") + "; navigateTo(" +
            $(elementIDs[el][1]).getAttribute("section") + ");'>" +
            ($(elementIDs[el][1]).getAttribute("helpText") != null ?
                $(elementIDs[el][1]).getAttribute("helpText") : "") + "</a> :</div> <div class='summary'><i>" +
            ($(elementIDs[el][1]).value.trim().length > 0 ? $(elementIDs[el][1]).value : "&nbsp;") +
            "</i></div></div>";
        }
    }

}

function initMultipleQuestions(){
    if(document.getElementById("loadingProgressMessage")){
        document.body.removeChild(document.getElementById("loadingProgressMessage"));
    }
    
    sections = getSections();

    navigateTo(0);

    createCalendarHTML();
}

window.addEventListener("load", initMultipleQuestions, false);
