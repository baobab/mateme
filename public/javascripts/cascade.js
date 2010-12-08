// cascade_v2.js

var rdoset = 0;

var rdo_parentset = 1;
var rdo_childset = 2;
var rdo_grandchildset = 3;

var global_ignore = false;
var ctrls_collection = [];
var ctrl_value_assoc = {};
var title = "";

var global_control = null;
var full_keyboard = false;

var global_grouptable = [];             // Grouping Tables for horizontal grouped display
var global_grouptrs = [];             // Grouping Tables Rows for horizontal grouped display

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
    div.style.backgroundColor = "#EEEEEE";
    div.style.top = p[2] + p[1] - $("divScroller").scrollTop;
    div.style.left = p[3];
    div.style.position = "absolute";

    global_control = id;

    var row1 = ["Q","W","E","R","T","Y","U","I","O","P"];
    var row2 = ["A","S","D","F","G","H","J","K","L",":"];
    var row3 = ["Z","X","C","V","B","N","M",",",".","?"];
    var row4 = ["cap","space","clear",(full_keyboard?"basic":"full")];
    var row5 = ["1","2","3","4","5","6","7","8","9","0"];
    var row6 = ["_","-","@","(",")","+",";","=","\\","/"];

    var tbl = document.createElement("table");
    tbl.bgColor = "#999999";
    tbl.cellSpacing = 5;
    tbl.cellPadding = 10;
    tbl.id = "tblKeyboard";

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

        td5.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML;
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

        td1.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML;
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

        td2.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML;
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

        td3.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML;
            }
        }

        tr3.appendChild(td3);
    }

    tbl.appendChild(tr3);

    var tr6 = document.createElement("tr");

    for(var i = 0; i < row6.length; i++){
        var td6 = document.createElement("td");
        td6.innerHTML = row6[i];
        td6.align = "center";
        td6.vAlign = "middle";
        td6.style.cursor = "pointer";
        td6.style.fontSize = "1.5em";
        td6.bgColor = "#EEEEEE"
        td6.width = "30px";

        td6.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML;
            }
        }

        tr6.appendChild(td6);
    }

    if(full_keyboard){
        tbl.appendChild(tr6);
    }

    var tr4 = document.createElement("tr");

    for(var i = 0; i < row4.length; i++){
        var td4 = document.createElement("td");
        td4.innerHTML = row4[i];
        td4.align = "center";
        td4.vAlign = "middle";
        td4.style.cursor = "pointer";
        td4.style.fontSize = "1.5em";
        td4.bgColor = "#EEEEEE"

        switch(row4[i]){
            case "cap":
                td4.colSpan = 2;
                break;
            case "space":
                td4.colSpan = 4;
                break;
            case "clear":
                td4.colSpan = 2;
                break;
            default:
                td4.colSpan = 2;
        }

        td4.onclick = function(){
            if(this.innerHTML.toLowerCase() == "cap"){
                if(this.innerHTML == "cap"){
                    this.innerHTML = this.innerHTML.toUpperCase();

                    var cells = $("tblKeyboard").getElementsByTagName("td");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.toLowerCase() != "cap"
                            && cells[c].innerHTML.toLowerCase() != "clear"
                            && cells[c].innerHTML.toLowerCase() != "space"
                            && cells[c].innerHTML.toLowerCase() != "full"
                            && cells[c].innerHTML.toLowerCase() != "basic" ){

                            cells[c].innerHTML = cells[c].innerHTML.toLowerCase();

                        }
                    }

                } else {
                    this.innerHTML = this.innerHTML.toLowerCase();

                    var cells = $("tblKeyboard").getElementsByTagName("td");

                    for(var c = 0; c < cells.length; c++){
                        if(cells[c].innerHTML.toLowerCase() != "cap"
                            && cells[c].innerHTML.toLowerCase() != "clear"
                            && cells[c].innerHTML.toLowerCase() != "space"
                            && cells[c].innerHTML.toLowerCase() != "full"
                            && cells[c].innerHTML.toLowerCase() != "basic" ){

                            cells[c].innerHTML = cells[c].innerHTML.toUpperCase();

                        }
                    }

                }
            } else if(this.innerHTML.toLowerCase() == "space"){

                $(global_control).value += " ";

            } else if(this.innerHTML.toLowerCase() == "clear"){

                $(global_control).value = $(global_control).value.substring(0,$(global_control).value.length - 1);

            } else if(this.innerHTML.toLowerCase() == "full"){

                full_keyboard = true;

                showKeyboard(global_control);

            } else if(this.innerHTML.toLowerCase() == "basic"){

                full_keyboard = false;

                showKeyboard(global_control);

            } else if(!this.innerHTML.match(/^$/)){

                $(global_control).value += this.innerHTML;

            }
        }
        //
        tr4.appendChild(td4);
    }

    tbl.appendChild(tr4);

    div.appendChild(tbl);
    document.body.appendChild(div);

    var u = checkCtrl(div);
    p = checkCtrl($(id));

    //div.style.left = (parseInt(d[3]) + (parseInt(d[0])/2) - (parseInt(p[3])/2))+"px";

    if(u[3] > ((d[0]/2)+d[3])){
        div.style.left = (parseInt(p[3]) - parseInt(u[0]) + parseInt(p[0]))+"px";
    } else if((parseInt(u[3]) + parseInt(u[0])) > (parseInt(d[3])+parseInt(d[0]))){
        div.style.left = (parseInt(d[3]) - parseInt(u[0]) + parseInt(d[0]))+"px";
    }

//  (w, h, t, l)
/*if((parseInt(u[2]) + parseInt(u[1]) + parseInt($("divScroller").scrollTop)) > (parseInt(d[2]) + parseInt(d[1]))){
        alert(parseInt($("divScroller").scrollTop));
        div.style.top = parseInt(p[2]) + parseInt($("divScroller").scrollTop - parseInt(u[1] + parseInt(p[1])));
    }*/
}

function showCalendar(id){

    if($("divMenu")){
        document.body.removeChild($("divMenu"));
    }

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
    div.style.backgroundColor = "#EEEEEE";
    div.style.top = p[2] + p[1] - $("divScroller").scrollTop;
    div.style.left = p[3];
    div.style.position = "absolute";

    global_control = id;

    var row1 = ["1","2","3"];
    var row2 = ["4","5","6"];
    var row3 = ["7","8","9"];
    var row4 = [".","0","C"];

    var tbl = document.createElement("table");
    tbl.bgColor = "#999999";
    tbl.cellSpacing = 5;
    tbl.cellPadding = 10;
    tbl.id = "tblKeyboard";

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

        td1.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML;
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

        td2.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML;
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

        td3.onclick = function(){
            if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML;
            }
        }

        tr3.appendChild(td3);
    }

    tbl.appendChild(tr3);

    var tr4 = document.createElement("tr");

    for(var i = 0; i < row4.length; i++){
        var td4 = document.createElement("td");
        td4.innerHTML = row4[i];
        td4.align = "center";
        td4.vAlign = "middle";
        td4.style.cursor = "pointer";
        td4.style.fontSize = "1.5em";
        td4.bgColor = "#EEEEEE"
        td4.width = "30px";

        td4.onclick = function(){
            if(this.innerHTML == "C"){
                $(global_control).value = $(global_control).value.substring(0,$(global_control).value.length - 1);
            }else if(!this.innerHTML.match(/^$/)){
                $(global_control).value += this.innerHTML;
            }
        }

        tr4.appendChild(td4);
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

function createQuestionare(ctrl){

    if($(ctrl).id != ctrl){
        return;
    } else {
        ctrl = $(ctrl);
    }

    //  Sentence structure has to be "TITLE | the rest"
    // Get Title
    var vals = ctrl.value.match(/[^\|]+/g);

    if(vals){

        if(vals.length == 2){
            title = vals[0];
        } else {
            alert("Please pass the proper sentence structure.");
            return;
        }
    } else {
        alert("Error: Could not parse control value.");
        return;
    }

    var roots = vals[1].match(/[^\{\}]+\{[^\{\}]+\}/g);

    var mainTable = document.createElement("table");
    mainTable.width = "100%";
    mainTable.cellPadding = 10;

    var mainTBody = document.createElement("tbody");
    var trMain = document.createElement("tr");
    var tdMain = document.createElement("td");

    tdMain.innerHTML = "<br /><br />";

    mainTable.appendChild(mainTBody);
    mainTBody.appendChild(trMain);
    trMain.appendChild(tdMain);

    var tblBorder = document.createElement("table");
    var tbodyBorder = document.createElement("tbody");
    var trBorder = document.createElement("tr");
    var tdBorder = document.createElement("td");

    tblBorder.bgColor = "#000000";
    tblBorder.width = "100%";
    tblBorder.cellSpacing = 1;
    tblBorder.cellPadding = 0;

    trBorder.appendChild(tdBorder);
    tbodyBorder.appendChild(trBorder);
    tblBorder.appendChild(tbodyBorder);

    tdMain.appendChild(tblBorder);

    var divScroller = document.createElement("div");
    divScroller.style.width = "100%";
    divScroller.style.height = "600px";
    divScroller.style.overflow = "auto";
    divScroller.style.backgroundColor = "#ffffff";
    divScroller.id = "divScroller";

    tdBorder.appendChild(divScroller);

    var tbl = document.createElement("table");
    divScroller.appendChild(tbl);

    tbl.cellSpacing = 1;
    tbl.cellPadding = 5;
    tbl.align = "left";
    tbl.width = "100%";
    //tbl.border = 1;
    //tbl.bgColor = "#EEEEEE";

    var tbody = document.createElement("tbody");

    tbl.appendChild(tbody);

    var tr1 = document.createElement("tr");
    var td1 = document.createElement("th");
    td1.innerHTML = title;
    //td1.className = "helpText";
    td1.style.height = "2em";
    td1.style.width = "500px";
    td1.style.position = "absolute";
    td1.style.top = "5px";
    td1.style.left = "10px";
    td1.style.fontSize = "2em";
    td1.style.overFlow = "hidden";

    td1.style.fontSize = "2em";

    td1.colSpan = 2;
    td1.align = "left";

    tr1.appendChild(td1);

    tbody.appendChild(tr1);

    for(var i = 0; i < roots.length; i++){
        var val = roots[i];
        rdoset += 1;

        var ret = val.match(/(.+){/);

        if(ret){
            if(ret[1]){

                // Echo Label
                var tr = document.createElement("tr");
                var td = document.createElement("td");
                td.vAlign = "top";
                td.colSpan = 2;
                td.style.fontSize = "1.5em";

                //td.innerHTML = ret[1];
                //td.innerHTML = "&nbsp;";

                tr.appendChild(td);

                var tr_1 = document.createElement("tr");
                //tbody.appendChild(tr_1);

                tbody.appendChild(tr_1);

                // Echo Control
                var ctrl = val.match(/.+\{([^\}]+)?\}/);

                if(ctrl){
                    if(ctrl[1]){
                        var td_1 = document.createElement("td");
                        var td_1_blank = document.createElement("td");
                        td_1_blank.innerHTML = "&nbsp;"
                        td_1_blank.width = "0%";

                        tr_1.appendChild(td_1_blank);
                        tr_1.appendChild(td_1);

                        var tblin = document.createElement("table");
                        //tblin.border = 1;
                        tblin.width = "100%";

                        tblin.cellSpacing = 5;
                        tblin.cellPadding = 5;

                        var tboin = document.createElement("tbody");

                        tblin.appendChild(tboin);

                        var parents = [];
                        var parents_check = {};

                        var p = roots[i].match(/parent[a-z]+\d+/g);

                        if(p){
                            for(var z = 0; z < p.length; z++){
                                if(!parents_check[p[z]]){
                                    parents.push(p[z]);
                                    parents_check[p[z]] = true;
                                }
                            }
                        }

                        for(var j = 0; j < parents.length; j++){
                            var pc = parents[j].match(/parent([a-z]+)\d+/);
                            var pv = ctrl[1].match("[^<>]+<"+parents[j]+">(.+)?<\\/"+parents[j]+">", "g");

                            var c_tbody = null;

                            var group_id = null;

                            switch(pc[1]){
                                case "checkbox":
                                    c_tbody = createCheckBoxes(null, pv[0], tboin, "parent",
                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j, i, j);

                                    td_1.appendChild(tblin);

                                    break;
                                case "textbox":
                                    c_tbody = createTextBoxes(null, pv[0], tboin, "parent",
                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j, i, j);

                                    td_1.appendChild(tblin);

                                    break;
                                case "numberbox":
                                    c_tbody = createNumberBoxes(null, pv[0], tboin, "parent",
                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j, i, j);

                                    td_1.appendChild(tblin);

                                    break;
                                case "yearbox":
                                    c_tbody = createYearBoxes(null, pv[0], tboin, "parent",
                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j, i, j);

                                    td_1.appendChild(tblin);

                                    break;
                                case "calendarbox":
                                    c_tbody = createCalendarBoxes(null, pv[0], tboin, "parent",
                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j, i, j);

                                    td_1.appendChild(tblin);

                                    break;
                                case "radio":
                                    c_tbody = createRadios(null, pv[0], tboin, "parent",
                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j, i, j);

                                    td_1.appendChild(tblin);

                                    break;
                                case "group":
                                    var r = createGroup(pv[0], tboin, "parent",
                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j, i, j);

                                    if(r[0]){
                                        c_tbody = r[0];

                                        if(r[1]){
                                            group_id = r[1];
                                        }

                                    } else {

                                        c_tbody = r;

                                    }

                                    td_1.appendChild(tblin);

                                    break;
                            }

                            var children = [];
                            var children_check = {};

                            var v1 = ctrl[1].match("<"+parents[j]+">(.+)?<\\/"+parents[j]+">");

                            if(v1){

                                if(v1[1]){
                                    var c = v1[1].match(/<child[a-z]+\d+/g);

                                    if(c){
                                        for(var k = 0; k < c.length; k++){
                                            c[k] = c[k].substring(1, c[k].length);

                                            if(!children_check[c[k]]){
                                                children.push(c[k]);
                                                children_check[c[k]] = true;
                                            }
                                        }
                                    }
                                }

                                //alert(ctrl[1]);

                                for(var k = 0; k < children.length; k++){
                                    var cc = children[k].match(/child([a-z]+)\d+/);
                                    var cv = v1[1].match("[^<>]+<"+children[k]+">(.+)?<\\/"+children[k]+">", "g");

                                    var g_tbody = null;

                                    switch(cc[1]){
                                        case "checkbox":
                                            g_tbody = createCheckBoxes(group_id, cv[0], c_tbody, "child",
                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k, i, j, k);

                                            td_1.appendChild(tblin);

                                            break;
                                        case "textbox":
                                            g_tbody = createTextBoxes(group_id, cv[0], c_tbody, "child",
                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k, i, j, k);

                                            td_1.appendChild(tblin);

                                            break;
                                        case "numberbox":
                                            g_tbody = createNumberBoxes(group_id, cv[0], c_tbody, "child",
                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k, i, j, k);

                                            td_1.appendChild(tblin);

                                            break;
                                        case "yearbox":
                                            g_tbody = createYearBoxes(group_id, cv[0], c_tbody, "child",
                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k, i, j, k);

                                            td_1.appendChild(tblin);

                                            break;
                                        case "calendarbox":
                                            g_tbody = createCalendarBoxes(group_id, cv[0], c_tbody, "child",
                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k, i, j, k);

                                            td_1.appendChild(tblin);

                                            break;
                                        case "radio":
                                            g_tbody = createRadios(group_id, cv[0], c_tbody, "child",
                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k, i, j, k);

                                            td_1.appendChild(tblin);

                                            break;
                                    }

                                    var grandchildren = [];
                                    var grandchildren_check = {};

                                    var v2 = v1[1].match("<"+children[k]+">(.+)?<\\/"+children[k]+">");

                                    if(v2){

                                        if(v2[1]){
                                            var g = v2[1].match(/<grandchild[a-z]+\d+/g);

                                            if(g){
                                                for(var n = 0; n < g.length; n++){
                                                    if(!grandchildren_check[g[n]]){
                                                        g[n] = g[n].substring(1, g[n].length);

                                                        grandchildren.push(g[n]);
                                                        grandchildren_check[g[n]] = true;
                                                    }
                                                }

                                            }
                                        }

                                        for(var b = 0; b < grandchildren.length; b++){

                                            var gc = grandchildren[b].match(/grandchild([a-z]+)\d+/);
                                            var gv = v2[1].match("[^<>]+<"+grandchildren[b]+">(.+)?<\\/"+grandchildren[b]+">", "g");

                                            var t_tbody = null;

                                            switch(gc[1]){
                                                case "checkbox":
                                                    t_tbody = createCheckBoxes(group_id, gv[0], g_tbody, "grandchild",
                                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b, i, j, k, b);

                                                    td_1.appendChild(tblin);

                                                    break;
                                                case "textbox":
                                                    t_tbody = createTextBoxes(group_id, gv[0], g_tbody, "grandchild",
                                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b, i, j, k, b);

                                                    td_1.appendChild(tblin);

                                                    break;
                                                case "numberbox":
                                                    t_tbody = createNumberBoxes(group_id, gv[0], g_tbody, "grandchild",
                                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b, i, j, k, b);

                                                    td_1.appendChild(tblin);

                                                    break;
                                                case "yearbox":
                                                    t_tbody = createYearBoxes(group_id, gv[0], g_tbody, "grandchild",
                                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b, i, j, k, b);

                                                    td_1.appendChild(tblin);

                                                    break;
                                                case "calendarbox":
                                                    t_tbody = createCalendarBoxes(group_id, gv[0], g_tbody, "grandchild",
                                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b, i, j, k, b);

                                                    td_1.appendChild(tblin);

                                                    break;
                                                case "radio":
                                                    t_tbody = createRadios(group_id, gv[0], g_tbody, "grandchild",
                                                        ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b, i, j, k, b);

                                                    td_1.appendChild(tblin);

                                                    break;
                                            }

                                            var greatgrandchildren = [];
                                            var greatgrandchildren_check = {};

                                            var v3 = v2[1].match("<"+grandchildren[b]+">(.+)?<\\/"+grandchildren[b]+">");

                                            if(v3){

                                                if(v3[1]){
                                                    var gg = v3[1].match(/<greatgrandchild[a-z]+\d+/g);

                                                    if(gg){
                                                        for(var n = 0; n < gg.length; n++){
                                                            if(!greatgrandchildren_check[gg[n]]){
                                                                gg[n] = gg[n].substring(1, gg[n].length);

                                                                greatgrandchildren.push(gg[n]);
                                                                greatgrandchildren_check[gg[n]] = true;
                                                            }
                                                        }

                                                    }
                                                }

                                                for(var f = 0; f < greatgrandchildren.length; f++){

                                                    var ggc = greatgrandchildren[f].match(/greatgrandchild([a-z]+)\d+/);
                                                    var ggv = v3[1].match("[^<>]+<"+greatgrandchildren[f]+">(.+)?<\\/"+greatgrandchildren[f]+">", "g");

                                                    var f_tbody = null;

                                                    switch(ggc[1]){
                                                        case "checkbox":
                                                            f_tbody = createCheckBoxes(group_id, ggv[0], t_tbody, "greatgrandchild",
                                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b+"_greatgrandchild_"+f, i, j, k, b, f);

                                                            td_1.appendChild(tblin);

                                                            break;
                                                        case "textbox":
                                                            f_tbody = createTextBoxes(group_id, ggv[0], t_tbody, "greatgrandchild",
                                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b+"_greatgrandchild_"+f, i, j, k, b, f);

                                                            td_1.appendChild(tblin);

                                                            break;
                                                        case "numberbox":
                                                            f_tbody = createNumberBoxes(group_id, ggv[0], t_tbody, "greatgrandchild",
                                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b+"_greatgrandchild_"+f, i, j, k, b, f);

                                                            td_1.appendChild(tblin);

                                                            break;
                                                        case "yearbox":
                                                            f_tbody = createYearBoxes(group_id, ggv[0], t_tbody, "greatgrandchild",
                                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b+"_greatgrandchild_"+f, i, j, k, b, f);

                                                            td_1.appendChild(tblin);

                                                            break;
                                                        case "calendarbox":
                                                            f_tbody = createCalendarBoxes(group_id, ggv[0], t_tbody, "greatgrandchild",
                                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b+"_greatgrandchild_"+f, i, j, k, b, f);

                                                            td_1.appendChild(tblin);

                                                            break;
                                                        case "radio":
                                                            f_tbody = createRadios(group_id, ggv[0], t_tbody, "greatgrandchild",
                                                                ret[1].replace(/\s/g, "_") + "_root_"+i+"_parent_"+j+"_child_"+k+"_grandchild_"+b+"_greatgrandchild_"+f, i, j, k, b, f);

                                                            td_1.appendChild(tblin);

                                                            break;
                                                    }

                                                }
                                            }

                                        }
                                    }

                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if($("clearButton")) $("clearButton").style.display = "none";
    if($("backButton")) $("backButton").style.display = "none";

    setNextButtonText('Finish');
    
    var trFiller = document.createElement("tr");
    var tdFiller = document.createElement("td");
    tdFiller.height = "300px";
    tdFiller.innerHTML = "&nbsp;";

    trFiller.appendChild(tdFiller);
    //tbody.appendChild(trFiller);

    var div = document.createElement("div");
    div.style.position = "absolute";
    div.style.marginLeft = "-500px";
    div.style.marginTop = "-380px";
    div.style.top = "50%";
    div.style.left = "50%";
    div.style.height = "675px";
    div.style.width = "1000px";
    div.style.overflow = "auto";
    div.style.zIndex = "20";
    div.style.backgroundColor = "#FFFFFF";
    div.id = "divQuestionare";

    //document.body.appendChild(div);

    $("content").appendChild(div);

    div.appendChild(mainTable);

    for(var y = 0; y < global_grouptable.length; y++){
        var g_id = global_grouptable[y].id.match(/\d+$/);
        var ctrls = div.getElementsByTagName("input");

        var valid_ctrls = [];
        var valid_ctrls_check = {};

        for(var x = 0; x < ctrls.length; x++){
            if(ctrls[x].type == "checkbox" || ctrls[x].type == "radio"){
                var gi = ctrls[x].getAttribute("group_id");

                if(gi){
                    //console.log(ctrls[x].id + " : " + gi);

                    var index = gi.match("^(" + g_id + "_\\d+)_\\d+_(\\d+)");

                    if(index){
                        index = index[1] + "_0_" + index[2];

                        if(!valid_ctrls_check[index]){
                            valid_ctrls.push(ctrls[x].id);
                            valid_ctrls_check[index] = true;

                        }
                    }
                }
            }
        }

        var etbody = createGroup("Both<parentgroup1000><"+g_id+"></"+g_id+"></parentgroup1000>", null, "parent");

        for(var e = 0; e < valid_ctrls.length; e++){
            var etr = document.createElement("tr");
            var etd = document.createElement("td");
            var eid = $(valid_ctrls[e]).getAttribute("group_id");

            var construction_text = $(valid_ctrls[e]).getAttribute("construction_text");

            switch($(valid_ctrls[e]).type){
                case "checkbox":
                    var child_tbody = createCheckBoxes(g_id, construction_text, etbody[0], "child",
                        eid);
                    var gr = construction_text.match(/<grandchild[a-z]+\d+/g);
                    grandchildren_check = {};
                    grandchildren = [];
                    
                    if(gr){
                        for(var nn = 0; nn < gr.length; nn++){
                            if(!grandchildren_check[gr[nn]]){
                                gr[nn] = gr[nn].substring(1, gr[nn].length);

                                grandchildren.push(gr[nn]);
                                grandchildren_check[gr[nn]] = true;
                            }
                        }

                    }

                    for(var bb = 0; bb < grandchildren.length; bb++){

                        var grc = grandchildren[bb].match(/grandchild([a-z]+)\d+/);
                        var grv = construction_text.match("[^<>]+<"+grandchildren[bb]+">(.+)?<\\/"+grandchildren[bb]+">", "g");
                        
                        var ggct_tbody = null;

                        switch(grc[1]){
                            case "checkbox":
                                ggct_tbody = createCheckBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "radio":
                                ggct_tbody = createRadios(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "numberbox":
                                ggct_tbody = createNumberBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "yearbox":
                                ggct_tbody = createNumberBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "calendarbox":
                                ggct_tbody = createCalendarBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "textbox":
                                ggct_tbody = createTextBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                        }

                        var ggr = grv[0].match(/<greatgrandchild[a-z]+\d+/g); // get greatgrandchildren
                        greatgrandchildren_check = {};
                        greatgrandchildren = [];

                        // if there are any greatgrandchildren, collect them into greatgrandchildren_check
                        // and confirm in greatgrandchildren
                        if(ggr){
                            for(var nnn = 0; nn < ggr.length; nnn++){
                                if(!greatgrandchildren_check[ggr[nnn]]){
                                    ggr[nnn] = ggr[nnn].substring(1, ggr[nnn].length);

                                    greatgrandchildren.push(ggr[nnn]);
                                    greatgrandchildren_check[ggr[nnn]] = true;
                                }
                            }

                        }

                        // then loop through the found greatgrandchildren and create corresponding controls
                        for(var bbb = 0; bbb < greatgrandchildren.length; bbb++){

                            var ggrc = greatgrandchildren[bbb].match(/greatgrandchild([a-z]+)\d+/);
                            var ggrv = grv[0].match("[^<>]+<"+greatgrandchildren[bbb]+">(.+)?<\\/"+greatgrandchildren[bbb]+">", "g");

                            var gggct_tbody = null;

                            switch(ggrc[1]){
                                case "checkbox":
                                    gggct_tbody = createCheckBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "radio":
                                    gggct_tbody = createRadios(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "numberbox":
                                    gggct_tbody = createNumberBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "yearbox":
                                    gggct_tbody = createNumberBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "calendarbox":
                                    gggct_tbody = createCalendarBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "textbox":
                                    gggct_tbody = createTextBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                            }

                        }

                    }

                    break;
                case "radio":
                    var child_tbody = createRadios(g_id, construction_text, etbody[0], "child",
                        eid);
                    var gr = construction_text.match(/<grandchild[a-z]+\d+/g);
                    grandchildren_check = {};
                    grandchildren = [];

                    if(gr){
                        for(var nn = 0; nn < gr.length; nn++){
                            if(!grandchildren_check[gr[nn]]){
                                gr[nn] = gr[nn].substring(1, gr[nn].length);

                                grandchildren.push(gr[nn]);
                                grandchildren_check[gr[nn]] = true;
                            }
                        }

                    }

                    for(var bb = 0; bb < grandchildren.length; bb++){

                        var grc = grandchildren[bb].match(/grandchild([a-z]+)\d+/);
                        var grv = construction_text.match("[^<>]+<"+grandchildren[bb]+">(.+)?<\\/"+grandchildren[bb]+">", "g");

                        var ggct_tbody = null;

                        switch(grc[1]){
                            case "checkbox":
                                ggct_tbody = createCheckBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "radio":
                                ggct_tbody = createRadios(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "numberbox":
                                ggct_tbody = createNumberBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "yearbox":
                                ggct_tbody = createNumberBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "calendarbox":
                                ggct_tbody = createCalendarBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                            case "textbox":
                                ggct_tbody = createTextBoxes(g_id, grv[0], child_tbody, "grandchild", eid + "_"+bb);
                                break;
                        }

                        var ggr = grv[0].match(/<greatgrandchild[a-z]+\d+/g); // get greatgrandchildren
                        greatgrandchildren_check = {};
                        greatgrandchildren = [];

                        // if there are any greatgrandchildren, collect them into greatgrandchildren_check
                        // and confirm in greatgrandchildren
                        if(ggr){
                            for(var nnn = 0; nnn < ggr.length; nnn++){
                                if(!greatgrandchildren_check[ggr[nnn]]){
                                    ggr[nnn] = ggr[nnn].substring(1, ggr[nnn].length);

                                    greatgrandchildren.push(ggr[nnn]);
                                    greatgrandchildren_check[ggr[nnn]] = true;
                                }
                            }

                        }

                        // then loop through the found greatgrandchildren and create corresponding controls
                        for(var bbb = 0; bbb < greatgrandchildren.length; bbb++){

                            var ggrc = greatgrandchildren[bbb].match(/greatgrandchild([a-z]+)\d+/);
                            var ggrv = grv[0].match("[^<>]+<"+greatgrandchildren[bbb]+">(.+)?<\\/"+greatgrandchildren[bbb]+">", "g");

                            var gggct_tbody = null;

                            switch(ggrc[1]){
                                case "checkbox":
                                    gggct_tbody = createCheckBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "radio":
                                    gggct_tbody = createRadios(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "numberbox":
                                    gggct_tbody = createNumberBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "yearbox":
                                    gggct_tbody = createNumberBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "calendarbox":
                                    gggct_tbody = createCalendarBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                                case "textbox":
                                    gggct_tbody = createTextBoxes(g_id, ggrv[0], ggct_tbody, "greatgrandchild", eid + "_"+bb+"_"+bbb);
                                    break;
                            }

                        }

                    }
                    break;
            }

        }
    }

    // Assign the collected values to their respective sources
    for(var k = 0; k < ctrls_collection.length; k++){
        if($(ctrls_collection[k]) && $(ctrl_value_assoc[ctrls_collection[k]])){
            if($(ctrls_collection[k]).type == "textbox"){
                $(ctrls_collection[k]).value = $(ctrl_value_assoc[ctrls_collection[k]]).value;
            } else {
                //if($(ctrl_value_assoc[ctrls_collection[k]]).value=="true"){
                if($(ctrl_value_assoc[ctrls_collection[k]]).disabled==false){
                    $(ctrls_collection[k]).click();
                }
            }

        }
    }
}

function removeQuestionaire(){
    // Assign the collected values to their respective sources
    for(var i = 0; i < ctrls_collection.length; i++){

        if($(ctrls_collection[i]) && $(ctrl_value_assoc[ctrls_collection[i]])){
            if($(ctrls_collection[i]).type == "textbox"){
                $(ctrl_value_assoc[ctrls_collection[i]]).value = $(ctrls_collection[i]).value;
            } else {
                //$(ctrl_value_assoc[ctrls_collection[i]]).value = $(ctrls_collection[i]).checked;
                if($(ctrls_collection[i]).checked){
                    $(ctrl_value_assoc[ctrls_collection[i]]).disabled = false;

                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_concept_name")) $(ctrl_value_assoc[ctrls_collection[i]]+"_concept_name").disabled = false;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_parent_concept_name")) $(ctrl_value_assoc[ctrls_collection[i]]+"_parent_concept_name").disabled = false;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_patient_id")) $(ctrl_value_assoc[ctrls_collection[i]]+"_patient_id").disabled = false;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_obs_datetime")) $(ctrl_value_assoc[ctrls_collection[i]]+"_obs_datetime").disabled = false;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_encounter_datetime")) $(ctrl_value_assoc[ctrls_collection[i]]+"_encounter_datetime").disabled = false;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_provider_id")) $(ctrl_value_assoc[ctrls_collection[i]]).disabled = false;
                } else {
                    $(ctrl_value_assoc[ctrls_collection[i]]).disabled = true;

                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_concept_name")) $(ctrl_value_assoc[ctrls_collection[i]]+"_concept_name").disabled = true;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_parent_concept_name")) $(ctrl_value_assoc[ctrls_collection[i]]+"_parent_concept_name").disabled = true;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_patient_id")) $(ctrl_value_assoc[ctrls_collection[i]]+"_patient_id").disabled = true;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_obs_datetime")) $(ctrl_value_assoc[ctrls_collection[i]]+"_obs_datetime").disabled = true;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_encounter_datetime")) $(ctrl_value_assoc[ctrls_collection[i]]+"_encounter_datetime").disabled = true;
                    if($(ctrl_value_assoc[ctrls_collection[i]]+"_provider_id")) $(ctrl_value_assoc[ctrls_collection[i]]+"_provider_id").disabled = true;
                }
            //$(ctrl_value_assoc[ctrls_collection[i]]).value = $(ctrls_collection[i]).checked;
            }
        }

    }

    //reset all global variables to avoid confusion next time
    rdoset = 0;
    rdo_parentset = 1;
    rdo_childset = 2;
    rdo_grandchildset = 3;
    global_ignore = false;
    ctrls_collection = [];
    ctrl_value_assoc = {};
    global_grouptable = [];
    global_grouptrs = [];

    if($('divQuestionare')) $("content").removeChild($('divQuestionare'));
}

function createCheckBoxes(group_id, text, tbody, level, prefix, root, parent, child, grandchild, greatgrandchild){
    
    var r = text.match("[^<>]+<" + level + "checkbox\\d+>(.*?)<\\/" + level + "checkbox\\d+>", "gi");

    var id = root + (String(parent).match(/\d+/)?(("_"+parent) + (String(child).match(/\d+/)?(("_"+child) +
        (String(grandchild).match(/\d+/)?(("_"+grandchild)+(String(greatgrandchild).match(/\d+/)?("_"+greatgrandchild):"")):"")):"")):"");

    var int_id = id.match(/(.+)_\d+$/);
    var name;

    if(int_id){
        if(int_id[1]){
            name = int_id[1];
        }
    }

    var trin = document.createElement("tr");

    var tdin = document.createElement("td");
    tdin.colSpan = 2;
    tdin.style.width = "100%";
    tdin.style.cursor = 'pointer';

    var chk = document.createElement("input");
    chk.type = "checkbox";

    if(id.match(/^\d+/)){
        chk.name = "chk_" + (name?name:id);
        chk.id = "chk_" + id;

        trin.id = "tr_" + id;
        tdin.id = "tdi_" + id;

        if(group_id){
            chk.setAttribute("group_id", group_id+"_"+id);
            chk.setAttribute("construction_text", text);
        }
    } else{
        var pre = prefix.match(/(.+)_\d+$/);

        if(pre){
            pre = pre[1];

            chk.name = "chk_" + pre + "_group";
        } else {
            chk.name = "chk_" + prefix + "_group";
        }

        chk.id = "chk_" + prefix + "_group" + ((level.match(/grand/))?"_A":"");

        trin.id = "tr_" + prefix + "_group" + ((level.match(/grand/))?"_A":"");
        tdin.id = "tdi_" + prefix + "_group" + ((level.match(/grand/))?"_A":"");
    }

    var fld_value = r[0].match(/[^<>]+/);

    if(fld_value){
        if(fld_value[0]){
            fld_value = fld_value[0]
        }
    }

    chk.value = fld_value;

    if(id){
        ctrls_collection.push("chk_" + id);
        ctrl_value_assoc["chk_" + id] = prefix;
    }

    chk.onclick = function(){
        if($("divMenu")){
            document.body.removeChild($("divMenu"));
        }

        var c = this.id.match(/chk_(.+)$/);

        if(c){
            if(c[1]){
                var c2 = c[1].match(/(.+)_group$/);

                if(c2){
                    var check = c2[1].match(/^\d+_\d+_\d+_\d+/);

                    var dctrls = $("divQuestionare").getElementsByTagName("input");

                    for(var t = 0; t < dctrls.length; t++){
                        var g = dctrls[t].getAttribute("group_id");
                        if(g){
                            if(g.match("^"+String(check).match(/^\d+_\d+/)) && 
                                g.match(/^\d+_\d+_\d+_\d+$/) && g.match(String(check).match(/_\d+$/)+"$") &&
                                dctrls[t].type == "checkbox"){
                                
                                dctrls[t].click();
                                if(dctrls[t].checked != this.checked){
                                    dctrls[t].click();
                                }
                            }
                        }
                    }

                } else {

                    c = this.id.match(/chk_(.+)$/);
                    var c3 = c[1].match(/(.+)_group_A$/);

                    if(c3){
                        
                        var checks = c3[1].match(/^\d+_\d+_\d+_\d+_\d+/);

                        var dctrlscol = $("divQuestionare").getElementsByTagName("input");

                        for(var tt = 0; tt < dctrlscol.length; tt++){
                            var gg = dctrlscol[tt].getAttribute("group_id");
                            if(gg){
                                if(gg.match("^"+String(checks).match(/\d+_\d+/)) &&
                                    gg.match(/^\d+_\d+_\d+_\d+_\d+$/) && gg.match(String(checks).match(/\d+_\d+$/)+"$")){
                                    dctrlscol[tt].click();
                                    if(dctrlscol[tt].checked != this.checked){
                                        dctrlscol[tt].click();
                                    }
                                }
                            }
                        }

                    }
                }

            }

            unCheckAll(c[1], this);
        }

        global_ignore = true;
        if($("val_" + this.id)){
            $("val_" + this.id).value = this.checked;
        }

        var collapse = this.id.match(/chk_(.+)$/);

        if(collapse){
            if(collapse[1]){
                if($("table_"+collapse[1])){
                    if($(this.id).checked){
                        $("table_"+collapse[1]).style.display = "block";
                        $("td_"+collapse[1]).innerHTML = "-";
                    } else {
                        $("table_"+collapse[1]).style.display = "none";
                        $("td_"+collapse[1]).innerHTML = "+";
                    }
                }
            }

        }

        if($("divScroller")){

            var p = checkCtrl(this);

            var d = checkCtrl($("divScroller"));

            $("divScroller").scrollTop = p[2] - d[2] - 10;
        }

    }

    tdin.onclick = function(){
        try{
            var v = this.id.match(/tdi_(.+)/)[1];

            v = "chk_" + v;

            if(global_ignore == false){
                //$(v).checked = !$(v).checked;
                $(v).click();
            } else {
                global_ignore = false;
            }

            if($(v).checked){
                this.bgColor = "#add8e6";
                this.style.color = "#000000";
            } else {
                this.bgColor = "";
                this.style.color = "#000000";
            }
        }catch(e){
        }
    }

    tdin.appendChild(chk);

    var lbl = document.createElement("label");
    lbl.style.fontSize = "1.5em";
    lbl.style.cursor = "pointer";

    lbl.innerHTML = r[0].match(/[^<>]+/);

    tdin.appendChild(lbl);

    trin.appendChild(tdin);
    tbody.appendChild(trin);

    var ot = r[0].match("<" + level + "\\w+\\d+>(.*)<\\/" + level + "\\w+\\d+>");

    var tdcollapse = document.createElement("th");
    tdcollapse.setAttribute("width", "20px");
    tdcollapse.id = "td_" + (!id.match(/^\d+/)?(prefix+"_group" + ((level.match(/grand/))?"_A":"")):id);

    if((ot[1]?ot[1].length:0)>0){
        tdcollapse.innerHTML = "+";
        tdcollapse.style.cursor = 'pointer';

        tdcollapse.onclick = function(){
            var id = this.id.match(/^td_(.+)$/);

            if(id){
                id = id[1];

                if(this.innerHTML == "+"){
                    this.innerHTML = "-";
                    $("table_" + id).style.display = "block";
                } else {
                    global_ignore = true;
                    this.innerHTML = "+";
                    $("table_" + id).style.display = "none";
                }
            }
        }
    } else {
        tdcollapse.innerHTML = "&nbsp;";
    }

    trin.appendChild(tdcollapse);
    trin.appendChild(tdin);
    tbody.appendChild(trin);

    if((ot[1]?ot[1].length:0)>0){
        var tblot = document.createElement("table");
        tblot.cellPadding = 5;
        tblot.id = "table_" + (!id.match(/^\d+/)?(prefix+"_group" + ((level.match(/grand/))?"_A":"")):id)
        tblot.width = "100%";

        var tbodyot = document.createElement("tbody");

        tblot.appendChild(tbodyot);

        var trinc1 = document.createElement("tr");
        trinc1.id = 'row_collapsible_' + (!id.match(/^\d+/)?(prefix+"_group" + ((level.match(/grand/))?"_A":"")):id)

        var tdinc1 = document.createElement("td");

        tdinc1.appendChild(tblot);

        var tdblank = document.createElement("td");
        var tdblank2 = document.createElement("td");
        tdblank2.style.width = "40px";

        tdblank.innerHTML = "";
        tdblank2.innerHTML = "";

        trinc1.appendChild(tdblank);
        trinc1.appendChild(tdblank2);
        trinc1.appendChild(tdinc1);

        tbody.appendChild(trinc1);

        tblot.style.display = "none";

        return tbodyot;
    } else {
        return tbody;
    }

}


function createRadios(group_id, text, tbody, level, prefix, root, parent, child, grandchild, greatgrandchild){

    var r = text.match("[^<>]+<" + level + "radio\\d+>(.*?)<\\/" + level + "radio\\d+>", "gi");

    var id = root + (String(parent).match(/\d+/)?(("_"+parent) + (String(child).match(/\d+/)?(("_"+child) +
        (String(grandchild).match(/\d+/)?(("_"+grandchild)+(String(greatgrandchild).match(/\d+/)?("_"+greatgrandchild):"")):"")):"")):"");

    var int_id = id.match(/(.+)_\d+$/);
    var name;

    if(int_id){
        if(int_id[1]){
            name = int_id[1];
        }
    }

    var trin = document.createElement("tr");
    var tdin = document.createElement("td");
    tdin.colSpan = 2;
    tdin.style.width = "100%";
    tdin.style.cursor = 'pointer';

    var rdo = document.createElement("input");
    rdo.type = "radio";
    
    if(id.match(/^\d+/)){
        rdo.name = "rdo_" + (name?name:id);
        rdo.id = "rdo_" + id;

        trin.id = "tr_" + id;
        tdin.id = "tdi_" + id;

        if(group_id){
            rdo.setAttribute("group_id", group_id+"_"+id);
            rdo.setAttribute("construction_text", text);
        }
    } else{
        var pre = prefix.match(/(.+)_\d+$/);
        
        if(pre){
            pre = pre[1];

            rdo.name = "rdo_" + pre + "_group_A";
        } else {
            rdo.name = "rdo_" + prefix + "_group";
        }
                
        rdo.id = "rdo_" + prefix + "_group" + ((level.match(/grand/))?"_A":"");

        trin.id = "tr_" + prefix + "_group" + ((level.match(/grand/))?"_A":"");
        tdin.id = "tdi_" + prefix + "_group" + ((level.match(/grand/))?"_A":"");
    }

    var fld_value = r[0].match(/[^<>]+/);

    if(fld_value){
        if(fld_value[0]){
            fld_value = fld_value[0]
        }
    }

    rdo.value = fld_value;

    ctrls_collection.push("rdo_" + id);
    ctrl_value_assoc["rdo_" + id] = prefix;

    rdo.onclick = function(){
        if($("divMenu")){
            document.body.removeChild($("divMenu"));
        }

        var c = this.id.match(/rdo_(.+)$/);

        if(c){
            var c2 = c[1].match(/(.+)_group$/);

            if(c2){

                var check = c2[1].match(/^\d+_\d+_\d+_\d+/);

                var dctrls = $("divQuestionare").getElementsByTagName("input");

                for(var t = 0; t < dctrls.length; t++){
                    var g = dctrls[t].getAttribute("group_id");
                    if(g){
                        if(g.match("^"+String(check).match(/\d+_\d+/)) &&
                            g.match(/^\d+_\d+_\d+_\d+$/) && g.match(String(check).match(/\d+$/)+"$")){
                            dctrls[t].click();
                            if(dctrls[t].checked != this.checked){
                                dctrls[t].click();
                            }
                        }
                    }
                }

            } else {
                
                c = this.id.match(/rdo_(.+)$/);
                var c3 = c[1].match(/(.+)_group_A$/);

                if(c3){
                    
                    var checks = c3[1].match(/^\d+_\d+_\d+_\d+_\d+_\d+|^\d+_\d+_\d+_\d+_\d+/);

                    var dctrlscol = $("divQuestionare").getElementsByTagName("input");

                    for(var tt = 0; tt < dctrlscol.length; tt++){
                        var gg = dctrlscol[tt].getAttribute("group_id");
                        if(gg){
                            if(gg.match("^"+String(checks).match(/\d+_\d+/)) && dctrlscol[tt].type == this.type &&
                                ((gg.match(/^\d+_\d+_\d+_\d+_\d+$/) && gg.match(String(checks).match(/\d+_\d+$/)+"$")) ||
                                    (gg.match(/^\d+_\d+_\d+_\d+_\d+_\d+$/) && gg.match(String(checks).match(/\d+_\d+_\d+$/)+"$")))){
                                
                                dctrlscol[tt].click();
                                if(dctrlscol[tt].checked != this.checked){
                                    dctrlscol[tt].click();
                                }
                            }
                        }
                    }

                }
            }

            unCheckAll(c[1], this, this.id);
        }
        global_ignore = true;

        var collapse = this.id.match(/^rdo_(.+)$/);

        if(collapse){
            if(collapse[1]){
                if($("table_"+collapse[1])){
                    if($(this.id).checked){
                        $("table_"+collapse[1]).style.display = "block";
                        $("td_"+collapse[1]).innerHTML = "-";
                    } else {
                        $("table_"+collapse[1]).style.display = "none";
                        $("td_"+collapse[1]).innerHTML = "+";
                    }
                }
            }

        }

        if($("divScroller")){

            var p = checkCtrl(this);

            var d = checkCtrl($("divScroller"));

            $("divScroller").scrollTop = p[2] - d[2] - 10;
        }

    }

    tdin.onclick = function(){
        try{
            var v = this.id.match(/tdi_(.+)/)[1];

            v = "rdo_" + v;

            if(global_ignore == false){
                $(v).click();
            } else {
                global_ignore = false;
            }

        }catch(e){
        }
    }

    tdin.appendChild(rdo);

    var lbl = document.createElement("label");
    lbl.style.fontSize = "1.5em";
    lbl.style.cursor = "pointer";

    lbl.innerHTML = r[0].match(/[^<>]+/);

    tdin.appendChild(lbl);

    var ot = r[0].match("<" + level + "\\w+\\d+>(.*)<\\/" + level + "\\w+\\d+>");

    var tdcollapse = document.createElement("th");
    tdcollapse.setAttribute("width", "20px");
    tdcollapse.id = "td_" + (!id.match(/^\d+/)?(prefix+"_group" + ((level.match(/grand/))?"_A":"")):id);

    if((ot[1]?ot[1].length:0)>0){
        tdcollapse.innerHTML = "+";
        tdcollapse.style.cursor = 'pointer';

        tdcollapse.onclick = function(){
            var id = this.id.match(/^td_(.+)$/);

            if(id){
                id = id[1];

                if(this.innerHTML == "+"){
                    this.innerHTML = "-";
                    $("table_" + id).style.display = "block";
                } else {
                    global_ignore = true;
                    this.innerHTML = "+";
                    $("table_" + id).style.display = "none";
                }
            }
        }
    } else {
        tdcollapse.innerHTML = "&nbsp;";
    }

    trin.appendChild(tdcollapse);
    trin.appendChild(tdin);
    tbody.appendChild(trin);

    if((ot[1]?ot[1].length:0)>0){
        var tblot = document.createElement("table");
        tblot.cellPadding = 5;
        tblot.id = "table_" + (!id.match(/^\d+/)?(prefix+"_group" + ((level.match(/grand/))?"_A":"")):id);
        tblot.width = "100%";

        var tbodyot = document.createElement("tbody");

        tblot.appendChild(tbodyot);

        var trinc1 = document.createElement("tr");
        trinc1.id = 'row_collapsible_' + (!id.match(/^\d+/)?(prefix+"_group" + ((level.match(/grand/))?"_A":"")):id);

        var tdinc1 = document.createElement("td");

        tdinc1.appendChild(tblot);

        var tdblank = document.createElement("td");
        var tdblank2 = document.createElement("td");
        tdblank2.style.width = "40px";

        tdblank.innerHTML = "";
        tdblank2.innerHTML = "";

        trinc1.appendChild(tdblank);
        trinc1.appendChild(tdblank2);
        trinc1.appendChild(tdinc1);

        tbody.appendChild(trinc1);

        tblot.style.display = "none";

        return tbodyot;
    } else {
        return tbody;
    }

}

function createTextBoxes(group_id, text, tbody, level, prefix, root, parent, child, grandchild, greatgrandchild){

    var r = text.match("[^<>]+<" + level + "textbox\\d+>(.*?)<\\/" + level + "textbox\\d+>", "gi");

    var id = root + (String(parent).match(/\d+/)?(("_"+parent) + (String(child).match(/\d+/)?(("_"+child) +
        (String(grandchild).match(/\d+/)?(("_"+grandchild)+(String(greatgrandchild).match(/\d+/)?("_"+greatgrandchild):"")):"")):"")):"");

    var int_id = id.match(/(.+)_\d+$/);
    var name;

    if(int_id){
        if(int_id[1]){
            name = int_id[1];
        }
    }

    var trin = document.createElement("tr");
    var tdin1 = document.createElement("td");
    var tdin2 = document.createElement("td");
    tdin2.colSpan = 2;

    tdin1.id = "tdi_" + id;

    var txt = document.createElement("input");
    txt.type = "text";
    txt.name = "txt_" + (name?name:id);
    txt.id = "txt_" + id;
    txt.style.width = "100%";
    txt.style.fontSize = "1.5em";

    txt.onclick = function(){
        if($('divMenu')){
            document.body.removeChild($('divMenu'));
        } else {
            showKeyboard(this.id);
        }
    }

    var fld_value = r[0].match(/[^<>]+/);

    if(fld_value){
        if(fld_value[0]){
            fld_value = fld_value[0]
        }
    }

    txt.value = "";

    ctrls_collection.push("txt_" + id);
    ctrl_value_assoc["txt_" + id] = prefix;


    var lbl = document.createElement("label");
    lbl.style.fontSize = "1.5em";
    lbl.style.cursor = "pointer";

    lbl.innerHTML = r[0].match(/[^<>]+/);

    tdin1.appendChild(lbl);

    tdin2.appendChild(txt);

    trin.appendChild(tdin1);
    trin.appendChild(tdin2);
    tbody.appendChild(trin);

    return tbody;

}

function createNumberBoxes(group_id, text, tbody, level, prefix, root, parent, child, grandchild, greatgrandchild){

    var r = text.match("[^<>]+<" + level + "numberbox\\d+>(.*?)<\\/" + level + "numberbox\\d+>", "gi");

    var id = root + (String(parent).match(/\d+/)?(("_"+parent) + (String(child).match(/\d+/)?(("_"+child) +
        (String(grandchild).match(/\d+/)?(("_"+grandchild)+(String(greatgrandchild).match(/\d+/)?("_"+greatgrandchild):"")):"")):"")):"");

    var int_id = id.match(/(.+)_\d+$/);
    var name;

    if(int_id){
        if(int_id[1]){
            name = int_id[1];
        }
    }

    var trin = document.createElement("tr");
    var tdin1 = document.createElement("td");
    var tdin2 = document.createElement("td");

    tdin1.id = "tdi_" + id;

    var txt = document.createElement("input");
    txt.type = "text";
    txt.name = "nmb_" + (name?name:id);
    txt.id = "nmb_" + id;
    txt.style.width = "100%";
    txt.style.fontSize = "1.5em";

    txt.onclick = function(){
        if($('divMenu')){
            document.body.removeChild($('divMenu'));
        } else {
            showNumber(this.id);
        }
    }

    var fld_value = r[0].match(/[^<>]+/);

    if(fld_value){
        if(fld_value[0]){
            fld_value = fld_value[0]
        }
    }

    txt.value = "";

    ctrls_collection.push("nmb_" + id);
    ctrl_value_assoc["nmb_" + id] = prefix;


    var lbl = document.createElement("label");
    lbl.style.fontSize = "1.5em";
    lbl.style.cursor = "pointer";

    lbl.innerHTML = r[0].match(/[^<>]+/);

    tdin1.appendChild(lbl);

    tdin2.appendChild(txt);

    trin.appendChild(tdin1);
    trin.appendChild(tdin2);
    tbody.appendChild(trin);

    return tbody;
}

function createYearBoxes(group_id, text, tbody, level, prefix, root, parent, child, grandchild, greatgrandchild){

    var r = text.match("[^<>]+<" + level + "yearbox\\d+>(.*?)<\\/" + level + "yearbox\\d+>", "gi");

    var id = root + (String(parent).match(/\d+/)?(("_"+parent) + (String(child).match(/\d+/)?(("_"+child) +
        (String(grandchild).match(/\d+/)?(("_"+grandchild)+(String(greatgrandchild).match(/\d+/)?("_"+greatgrandchild):"")):"")):"")):"");

    var int_id = id.match(/(.+)_\d+$/);
    var name;

    if(int_id){
        if(int_id[1]){
            name = int_id[1];
        }
    }

    var trin = document.createElement("tr");
    var tdin1 = document.createElement("td");
    var tdin2 = document.createElement("td");

    tdin1.id = "tdi_" + id;

    var txt = document.createElement("input");
    txt.type = "text";
    txt.name = "yr_" + (name?name:id);
    txt.id = "yr_" + id;
    txt.style.width = "100%";
    txt.style.fontSize = "1.5em";

    txt.onclick = function(){
        if($('divMenu')){
            document.body.removeChild($('divMenu'));
        } else {
            showYear(this.id);
        }
    }

    var fld_value = r[0].match(/[^<>]+/);

    if(fld_value){
        if(fld_value[0]){
            fld_value = fld_value[0]
        }
    }

    txt.value = "";

    ctrls_collection.push("yr_" + id);
    ctrl_value_assoc["yr_" + id] = prefix;


    var lbl = document.createElement("label");
    lbl.style.fontSize = "1.5em";
    lbl.style.cursor = "pointer";

    lbl.innerHTML = r[0].match(/[^<>]+/);

    tdin1.appendChild(lbl);

    tdin2.appendChild(txt);

    trin.appendChild(tdin1);
    trin.appendChild(tdin2);
    tbody.appendChild(trin);

    return tbody;
}

function createCalendarBoxes(group_id, text, tbody, level, prefix, root, parent, child, grandchild, greatgrandchild){

    var r = text.match("[^<>]+<" + level + "calendarbox\\d+>(.*?)<\\/" + level + "calendarbox\\d+>", "gi");

    var id = root + (String(parent).match(/\d+/)?(("_"+parent) + (String(child).match(/\d+/)?(("_"+child) +
        (String(grandchild).match(/\d+/)?(("_"+grandchild)+(String(greatgrandchild).match(/\d+/)?("_"+greatgrandchild):"")):"")):"")):"");

    var int_id = id.match(/(.+)_\d+$/);
    var name;

    if(int_id){
        if(int_id[1]){
            name = int_id[1];
        }
    }

    var trin = document.createElement("tr");
    var tdin1 = document.createElement("td");
    var tdin2 = document.createElement("td");

    tdin1.id = "tdi_" + id;

    var txt = document.createElement("input");
    txt.type = "text";
    txt.name = "cld_" + (name?name:id);
    txt.id = "cld_" + id;
    txt.style.width = "100%";
    txt.style.fontSize = "1.5em";

    txt.onclick = function(){
        if($('divMenu')){
            document.body.removeChild($('divMenu'));
        } else {
            showCalendar(this.id);
        }
    }

    var fld_value = r[0].match(/[^<>]+/);

    if(fld_value){
        if(fld_value[0]){
            fld_value = fld_value[0]
        }
    }

    txt.value = "";

    ctrls_collection.push("cld_" + id);
    ctrl_value_assoc["cld_" + id] = prefix;


    var lbl = document.createElement("label");
    lbl.style.fontSize = "1.5em";
    lbl.style.cursor = "pointer";

    lbl.innerHTML = r[0].match(/[^<>]+/);

    tdin1.appendChild(lbl);

    tdin2.appendChild(txt);

    trin.appendChild(tdin1);
    trin.appendChild(tdin2);
    tbody.appendChild(trin);

    return tbody;

}


function createGroup(text, tbody, level, prefix, root, parent, child, grandchild, greatgrandchild){

    var r = text.match("[^<>]+<" + level + "group\\d+>(.*?)<\\/" + level + "group\\d+>", "gi");

    var s = r[0].match("[^<>]+<" + level + "group\\d+><(\\d+)>(.*?)</\\d+><\\/" + level + "group\\d+>");

    var title = r[0].match(/[^<>]+/);

    if(!title){
        title = "";
    }

    if(s){

        if(s[1]){

            if(!global_grouptable[s[1]-1]){
                var grouptable = document.createElement("table");
                grouptable.id = "group_table_"+s[1];
                grouptable.border = 0;
                grouptable.width = "100%";
                grouptable.cellSpacing = 1;

                var grouptbody = document.createElement("tbody");
                grouptbody.id = "group_tbody_"+s[1];

                var grouptr = document.createElement("tr");
                grouptr.id = "group_tr_"+s[1];

                var itr = document.createElement("tr");
                var itd = document.createElement("td");
                itd.colSpan = 3;
                itd.setAttribute("valign", "top");

                tbody.appendChild(itr);

                itr.appendChild(itd);

                itd.appendChild(grouptable);

                grouptable.appendChild(grouptbody);

                grouptbody.appendChild(grouptr);

                global_grouptable.push(grouptable);

                global_grouptrs.push(grouptr);

            }

            var grouptd = document.createElement("td");
            grouptd.width = "33%";
            grouptd.setAttribute("valign", "top");

            //alert(global_grouptable[s[1]-1]);

            global_grouptrs[s[1]-1].appendChild(grouptd);

            //$("group_tr_"+eval(s[1]-1)).appendChild(grouptd);

            var tbl = document.createElement("table");
            tbl.cellPadding = 2;
            tbl.cellSpacing = 1;

            var tbdy = document.createElement("tbody");

            var tr = document.createElement("tr");
            var th = document.createElement("td");
            th.bgColor = "#CCCCCC";
            th.innerHTML = String(title).toUpperCase();
            th.style.fontSize = "1.2em";
            th.colSpan = 3;
            th.align = "left";


            grouptd.appendChild(tbl);

            tbl.appendChild(tbdy);

            tbdy.appendChild(tr);

            tr.appendChild(th);

            return [tbdy, s[1]];
        } else {
            return tbody;
        }
    } else {
        return tbody;
    }

}

function collapseAll(id){
    var trs = document.getElementsByTagName("tr");

    try{
        var vid = id.match(/rdo_\w+_(\d+_\d+)/)[1];

        for(var i = 0; i < trs.length; i++){
            if(trs[i].id){
                if(trs[i].id.match(/^row_collapsible/)){
                    if(trs[i].id == "row_collapsible_" + vid){
                        trs[i].style.display = "block";
                    } else {
                        trs[i].style.display = "none";
                    }
                }
            }
        }
    }catch(e){}
}

function unCheckAll(id, control, owner){
    try{
        var chks = document.getElementsByTagName("input");

        for(var i = 0; i < chks.length; i++){
            var c;

            if(control.type == "radio"){
                c = chks[i].name.match("^\\w+_(" + id + ")");
            } else {
                c = chks[i].name.match("^\\w+_(" + id + ")$");
            }


            if(c){
                switch(chks[i].type){
                    case "checkbox":
                        if(chks[i].checked == true){
                            chks[i].click();
                        }
                        break;
                    case "radio":
                        if(chks[i].checked == true){
                            chks[i].click();
                            if(chks[i].id != owner){
                                chks[i].checked = false;
                            } else {
                                var sc = chks[i].id.match("^\\w+_(" + id + ")$");

                                if(sc){
                                    if(sc[1]){
                                        if($("td_"+sc[1])){
                                            if($("td_"+sc[1]).innerHTML == "-") {
                                                $("td_"+sc[1]).click();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    case "text":
                        chks[i].value = "";
                        break;
                }
            }
        }

    }catch(e){}
}

function removeSelect(){
    if($("parent_container")){
        document.body.removeChild($("parent_container"));
    }
}

function viewSelect(){
    if($("parent_container")){
        document.body.removeChild($("parent_container"));
    }

    var parent_container = document.createElement("div");
    parent_container.id = "parent_container";
    parent_container.style.position = "absolute";
    parent_container.style.marginLeft = "-400px";
    parent_container.style.marginTop = "-300px";
    parent_container.style.top = "50%";
    parent_container.style.left = "50%";
    parent_container.style.height = "520px";
    parent_container.style.width = "795px";
    parent_container.style.overflow = "auto";
    parent_container.style.zIndex = "1000";
    parent_container.style.backgroundColor = "#FFFFFF";

    document.body.appendChild(parent_container);

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
    title.innerHTML = "Select Test Type";
    title.style.fontSize = "2em";
    title.style.position = "absolute";
    title.style.top = "5px";
    title.style.left = "25px";

    parent_container.appendChild(title);

    var divMid = document.createElement("div");
    divMid.style.width = "100%";
    divMid.style.height = "422px";
    divMid.style.overflow = "hidden";
    divMid.id = "divMid";
    divMid.style.backgroundColor = "#EEEEEE";
    divMid.style.overflow = "auto";

    tdBorder1.appendChild(divMid);

    var sel = document.createElement("select");
    sel.id = "test_type";
    sel.name = "test_type";
    sel.size = 10;
    sel.style.width = "100%";
    sel.style.height = "100%";
    sel.style.fontSize = "2em";

    sel.onclick = function(){
        //alert(this.value);
        $('diabetes_test_type').value = this.value;
    }

    divMid.appendChild(sel);

    var ops = ["URINE PROTEIN", "VISUAL ACUITY", "FUNDOSCOPY", "FOOT CHECK"];

    for(var i = 0; i < ops.length; i++){
        var opt = document.createElement("option");
        opt.value = ops[i].toLowerCase();
        opt.innerHTML = ops[i];

        sel.appendChild(opt);
    }

}
