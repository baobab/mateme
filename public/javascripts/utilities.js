// utilities.js
var global_control = null;
var full_keyboard = false;

function $(id){
    return document.getElementById(id);
}

function checkCtrl(obj){
    if(!obj) return [];
    
    var o = obj;
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
    div.style.zIndex = 1001;
    div.style.top = (p[2] + p[1] - $("divScroller").scrollTop) + "px";
    div.style.left = p[3] + "px";
    div.style.position = "absolute";

    global_control = id;

    var row1 = ["Q","W","E","R","T","Y","U","I","O","P"];
    var row2 = ["A","S","D","F","G","H","J","K","L",":"];
    var row3 = ["Z","X","C","V","B","N","M",",",".","?"];
    var row4 = ["cap","space","clear",(full_keyboard?"basic":"full")];
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
                td4.colSpan = 4;
                break;
            case "clear":
                td4.colSpan = 2;
                break;
            default:
                td4.colSpan = 2;
        }

        tr4.appendChild(td4);

        var btn = document.createElement("button");
        btn.innerHTML = "<span>" + row4[i] + "</span>";
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

        td4.appendChild(btn);

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
    div.style.zIndex = 1001;
    div.style.top = (p[2] + p[1] - $("divScroller").scrollTop) + "px";
    div.style.left = p[3] + "px";
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
        td2.className = "blue";

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
        td3.className = "blue";

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
        td4.className = "blue";

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
    div.style.zIndex = 1001;
    div.style.backgroundColor = "#EEEEEE";
    div.style.top = (p[2] + p[1] - $("divScroller").scrollTop) + "px";
    div.style.width = p[0] + "px";
    div.style.left = p[3] + "px";
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

function showMenu(id, original_id){

    if($("divMenu")){
        document.body.removeChild($("divMenu"));
    }

    var p = checkCtrl($(id));

    var d = checkCtrl($("divScroller"));

    $("divScroller").scrollTop = p[2] - d[2] - 10;

    p = checkCtrl($(id));

    var div = document.createElement("div");
    div.id = "divMenu";
    div.style.zIndex = 1001;
    div.style.backgroundColor = "#EEEEEE";
    div.style.top = (p[2] + p[1] - $("divScroller").scrollTop) + "px";
    div.style.width = p[0] + "px";
    div.style.left = p[3] + "px";
    div.style.position = "absolute";

    var sel = document.createElement("select");
    sel.style.height = "200px";
    sel.style.width = "100%";
    sel.size = 10;
    sel.style.fontSize = "1.8em";

    sel.onclick = function(){
        $(id).value = unescape(this[this.selectedIndex].innerHTML);
        document.body.removeChild($("divMenu"));
    }

    div.appendChild(sel);


    document.body.appendChild(div);

    for(var i = 0; i < $(original_id).options.length; i++){
        var opt = document.createElement("option");
        opt.style.padding = "10px";

        opt.value = $(original_id).options[i].value;
        opt.innerHTML = unescape($(original_id).options[i].innerHTML);

        sel.appendChild(opt);
    }
    
}

<!-- Calender Script  -->

function makeCalendar(){
    var table = document.createElement("table");
    table.id = "calenderTable";
    
    document.body.appendChild(table);
    
    var tbody1 = document.createElement("tbody");
    tbody1.id = "calenderTableHead";

    table.appendChild(tbody1);

    var tr1 = document.createElement("tr");

    tbody1.appendChild(tr1);

    var td1_1 = document.createElement("td");
    td1_1.colSpan = "4";
    td1_1.align = "center";

    tr1.appendChild(td1_1);

    var selectMonth = document.createElement("select");
    selectMonth.id = "selectMonth";
    selectMonth.style.fontSize = "1.2em";
    selectMonth.onchange = function(){
        showCalenderBody(createCalender(document.getElementById('selectYear').value,
            this.selectedIndex, false));
    }

    td1_1.appendChild(selectMonth);

    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    for(var i = 0; i < months.length; i++){
        var opt = document.createElement("option");
        opt.value = i;
        opt.innerHTML = months[i];

        selectMonth.appendChild(opt);
    }

    var td1_2 = document.createElement("td");
    td1_2.colSpan = "2";
    td1_2.align = "center";

    tr1.appendChild(td1_2);

    var selectYear = document.createElement("select");
    selectYear.id = "selectYear";
    selectYear.style.fontSize = "1.2em";
    selectYear.onchange = function(){
        showCalenderBody(createCalender(this.value, document.getElementById('selectMonth').selectedIndex, false));
    }

    td1_2.appendChild(selectYear);

    var td1_3 = document.createElement("td");
    td1_3.align = "center";

    tr1.appendChild(td1_3);

    var a = document.createElement("td");
    a.href = "#";
    a.style.color = "#033";
    a.style.fontSize = "+1";
    a.onclick = function(){
        closeCalender();
    }
    a.innerHTML = "X";

    td1_3.appendChild(a);

    var tbody2 = document.createElement("tbody");
    tbody2.id = "calenderTableDays";

    table.appendChild(tbody2);

    var tr2 = document.createElement("tr");

    tbody2.appendChild(tr2);

    var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    for(var i = 0; i < days.length; i++){
        var td2_1 = document.createElement("td");
        td2_1.className = "header-cell";
        td2_1.innerHTML = days[i];

        tr2.appendChild(td2_1);
    }

    var tbody3 = document.createElement("tbody");
    tbody3.id = "calender";

    table.appendChild(tbody3);

}

<!-- End Calender Script  -->

makeCalendar();