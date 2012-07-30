var selecteddays = {};            
            
var active_cell = null;
var selected_color = "#9e9";
var default_color = "#fff";
var default_weekend_color = "#fff";
var initial_selected_color = "#ccc";
var selected_date = null;
var targetControl = null;
var initial_date = null;
var start_week_date = null;
var end_week_date = null;
            
var monthNames = ["January", "February", "March", "April", "May", "June", 
"July", "August", "September", "October", "November", "December"];
            
var current_month = monthNames[(new Date()).getMonth()];
var current_year = 2012;
var months = {
    "January":[0, 31],
    "February":[1, 28],
    "March":[2, 31],
    "April":[3, 30],
    "May":[4,31],
    "June":[5,30],
    "July":[6, 31],
    "August":[7, 31],
    "September":[8, 30],
    "October":[9, 31],
    "November":[10, 30],
    "December":[11, 31]
};
            
var calendar = {
    0:[0,0,0,0,0],
    1:[0,0,0,0,0],
    2:[0,0,0,0,0],
    3:[0,0,0,0,0],
    4:[0,0,0,0,0],
    5:[0,0,0,0,0],
    6:[0,0,0,0,0]
}
                
function __$(id){
    return document.getElementById(id);
}

function padZeros(number, positions){
    var zeros = parseInt(positions) - String(number).length;
    var padded = "";
    
    for(var i = 0; i < zeros; i++){
        padded += "0";
    }
    
    padded += String(number);
    
    return padded;
}

function addMonth(){
    var pos = months[current_month][0];
                
    pos++;
                
    if(pos > 11){
        pos = 0;
        current_year++;
    }
                
    current_month = monthNames[pos];
                
    createMonth(current_year + "-" + padZeros((pos + 1), 2) + 
        "-" + padZeros(selected_date.getDate(), 2), selecteddays, initial_date, start_week_date, end_week_date);
}
            
function subtractMonth(){                
    var pos = months[current_month][0];
                
    pos--;
                
    if(pos < 0){
        pos = 11;
        current_year--;
    }
                
    current_month = monthNames[pos];
                
    createMonth(current_year + "-" + padZeros((pos + 1), 2) + 
        "-" + padZeros(selected_date.getDate(), 2), selecteddays, initial_date, start_week_date, end_week_date);
}
            
function addYear(){
    current_year++;
    createMonth(current_year + "-" + padZeros((selected_date.getMonth() + 1), 2) + 
        "-" + padZeros(selected_date.getDate(), 2), selecteddays, initial_date, start_week_date, end_week_date);                
}
            
function subtractYear(){
    current_year--;
    createMonth(current_year + "-" + padZeros((selected_date.getMonth() + 1), 2) + 
        "-" + padZeros(selected_date.getDate(), 2), selecteddays, initial_date, start_week_date, end_week_date);
}
            
function createMonth(date, selected, initialdate, startweekdate, endweekdate){
    __$("chart").innerHTML = "";
                
    if(typeof(initialdate) != "undefined"){                    
        initial_date = initialdate;
    }
                   
    if(typeof(startweekdate) != "undefined"){                    
        start_week_date = startweekdate;
    }
                   
    if(typeof(endweekdate) != "undefined"){                    
        end_week_date = endweekdate;
    }
                
    if(typeof(date) != "undefined" && date != null){
        selected_date = new Date(date);
        current_year = selected_date.getFullYear();
        current_month = monthNames[selected_date.getMonth()];        
    } else {
        current_year = (new Date()).getFullYear();
        current_month = monthNames[(new Date()).getMonth()];
    }            
      
    if(typeof(selected) == "undefined"){
        selected = {};
    } else {
        selecteddays = selected;
    }
      
    __$("year").innerHTML = current_year;
    __$("month").innerHTML = current_month;
                
    var first_day = new Date(current_year, months[current_month][0], 1);
    var today = new Date();
                
    var names = ["Week", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];    
     
    var carry_over_day = new Date(first_day.getFullYear(), first_day.getMonth(), first_day.getDate());    
                
    if(carry_over_day.getDay() > 0){
        carry_over_day.setDate(carry_over_day.getDate() - first_day.getDay());
    }
      
    var row = document.createElement("div");
    row.className = "cRow";
    
    for(var day = 0; day < 8; day++){                    
        __$("chart").appendChild(row);
                    
        var dayCell = document.createElement("div");
        dayCell.className = "cCell" + (day == 1 || day == 7 ? " weekEnd" : " weekDay");
        dayCell.innerHTML = names[day];
        
        if(day == 0){
            dayCell.style.textAlign = "center";
        }
                    
        row.appendChild(dayCell);
    }
         
    var rowcoll = [];
    for(var i = 0; i < 7; i++){
        rowcoll[i] = document.createElement("div");        
        rowcoll[i].className = "cRow";
        
        __$("chart").appendChild(rowcoll[i]);               
    }
              
    for(var week = 0; week < 7; week++){
        var current_day = new Date(carry_over_day.getFullYear(), carry_over_day.getMonth(), carry_over_day.getDate());
               
        for(var day = 0; day < 7; day++){
            
            if(day == 0){
                var dayCell = document.createElement("div");
                dayCell.id = "week" + week;
                dayCell.className = "cCell day";
                dayCell.style.backgroundColor = "#ddd";
                dayCell.style.textAlign = "center";
                dayCell.style.verticalAlign = "middle";
                dayCell.style.fontSize = "30px";
                dayCell.style.padding = "0px";
            
                rowcoll[week].appendChild(dayCell);
                
                var startdate;
                var enddate;
                
                if(typeof(start_week_date) != "undefined" && start_week_date != null){
                    if((start_week_date + "").match(/\d{4}\-\d{2}\-\d{2}/)){                    
                        startdate = new Date(start_week_date);
                    }                     
                } else {
                    startdate = new Date(current_day.getFullYear(), 0, 1);
                }
                
                if(typeof(end_week_date) != "undefined" && end_week_date != null){
                    if(end_week_date.match(/\d{4}\-\d{2}\-\d{2}/)){                    
                        enddate = new Date(end_week_date);
                    }                    
                } else {
                    enddate = new Date(current_day.getFullYear(), 11, 31);
                }
                
                var millisecondsPerWeek = 1000 * 60 * 60 * 24 * 7;
                
                var period = Math.floor(((current_day.getTime() - startdate.getTime()) / millisecondsPerWeek)) + 1;
                
                var durationend = Math.abs(((enddate.getTime() - startdate.getTime()) / millisecondsPerWeek)) + 1;
                    
                dayCell.innerHTML = (period < durationend && period > 0 ? period : "&nbsp;");
            }            
            
            var dayCell = document.createElement("div");
            dayCell.id = week + "-" + day;
            
            rowcoll[week].appendChild(dayCell);
            
            var found = false;
            if(selected_date != null){
                if((current_day.getFullYear() == selected_date.getFullYear() && 
                    current_day.getMonth() == selected_date.getMonth() && 
                    current_day.getDate() == selected_date.getDate())) {
                                
                    active_cell = week + "-" + day; 
                    found = true;
                }
            }
                        
            var checkDay = current_day.getDay();
                
            if(checkDay == day){                
                dayCell.innerHTML = current_day.getDate();
                
                if(current_day.getMonth() == first_day.getMonth()){
                               
                    if(selected[current_day.getFullYear() + "-" + 
                        padZeros((current_day.getMonth() + 1),2) + "-" + 
                        padZeros(current_day.getDate(),2)]){
                                      
                        var count = document.createElement("div");
                        count.className = "dayCount";
                        count.innerHTML = selected[current_day.getFullYear() + "-" + 
                        padZeros((current_day.getMonth() + 1),2) + "-" + 
                        padZeros(current_day.getDate(),2)];
                        
                        dayCell.appendChild(count);
                    }
                             
                    dayCell.setAttribute("value", current_day.getDate());
                            
                    dayCell.setAttribute("daytype", "weekday");
                              
                    dayCell.setAttribute("date", current_day.getFullYear() + "-" + padZeros((current_day.getMonth()+1),2) + 
                        "-" + padZeros(current_day.getDate(), 2));          
                              
                    dayCell.className = "cCell day cellActive" + 
                    ((current_day.getFullYear() == today.getFullYear() && 
                        current_day.getMonth() == today.getMonth() && 
                        current_day.getDate() == today.getDate()) ? " today" : "");
                    
                    dayCell.onclick = function(){
                        var celldate = current_day.getFullYear() + "-" + padZeros((current_day.getMonth()),2) + 
                        "-" + padZeros(__$(active_cell).getAttribute("value"), 2);
                        
                        if(celldate == date){
                            __$(active_cell).style.backgroundColor = initial_selected_color;
                        } else if(active_cell != null){
                            if(__$(active_cell).getAttribute("daytype") == "weekend"){
                                __$(active_cell).style.backgroundColor = default_weekend_color;
                            } else {
                                __$(active_cell).style.backgroundColor = default_color;
                            }
                        }
                        __$(active_cell).style.color = "#000";
                        __$(active_cell).style.fontWeight = "normal";
                                            
                        active_cell = this.id;
                        __$(active_cell).style.backgroundColor = selected_color;
                        __$(active_cell).style.color = "#000";
                        __$(active_cell).style.fontWeight = "bold";
                                            
                        targetControl.value = current_year + "-" + 
                        padZeros((months[current_month][0] + 1), 2) + "-" + 
                        padZeros(this.getAttribute("value"), 2);
                                
                        selected_date = new Date(current_year, months[current_month][0], this.getAttribute("value"));
                        
                        if(targetControl.getAttribute("ajaxCalendarUrl")){
                            ajaxCalendarRequest(__$(this.id), targetControl.getAttribute("ajaxCalendarUrl"), 
                                __$(this.id).getAttribute("date"));
                        }
                    }
                } else {                                        
                    dayCell.className = "cCell day cellInactive";
                    dayCell.style.color = "#999";
                }
                
                current_day.setDate(current_day.getDate() + 1); 
                
            }
            if(found){
                __$(active_cell).click();
            }                
        }
        
        carry_over_day = new Date(current_day.getFullYear(), current_day.getMonth(), current_day.getDate());
    }
     
}
                        
function createCalendar(control, target, date, selected, startweekdate, endweekdate){
    if(__$(control) && __$(target)){
        
        targetControl = __$(target);
        
        var main = document.createElement("div");
        main.className = "cTable";
        main.id = "calendar";
    
        __$(control).appendChild(main);
        
        var mainrow2 = document.createElement("div");
        mainrow2.className = "cRow";
        
        main.appendChild(mainrow2);
        
        var bannerTable = document.createElement("div");
        bannerTable.className = "cTable";
        bannerTable.style.width = "95%";
        bannerTable.style.border = "1px solid #fff";
                
        __$("keyboard").appendChild(bannerTable);
        
        var bannerrow = document.createElement("div");
        bannerrow.className = "cRow";
        
        bannerTable.appendChild(bannerrow);
        
        var bannerrowcell1 = document.createElement("div");
        bannerrowcell1.className = "cCell";
        bannerrowcell1.style.border = "1px solid #fff";
        
        bannerrowcell1.innerHTML = "<button onclick='subtractMonth()' class='btn'>-</button>" + 
        "<span id='month'></span><button onclick='addMonth()' class='btn'>+</button>";
    
        bannerrow.appendChild(bannerrowcell1);
                
        var bannerrowcell2 = document.createElement("div");
        bannerrowcell2.className = "cCell";
        bannerrowcell2.style.textAlign = "none";
        bannerrowcell2.style.padding = "0px";
        bannerrowcell2.style.fontSize = "2.5em";
        bannerrowcell2.style.verticalAlign = "middle";
        
        bannerrowcell2.innerHTML = (targetControl.getAttribute("helpText") ? 
            (targetControl.getAttribute("helpText").trim().length > 15 ? 
            targetControl.getAttribute("helpText").substring(0,14) + "..." : 
            targetControl.getAttribute("helpText")) : "");

        bannerrow.appendChild(bannerrowcell2);
        
        var bannerrowcell3 = document.createElement("div");
        bannerrowcell3.className = "cCell";
        bannerrowcell3.style.textAlign = "right";
        bannerrowcell3.style.padding = "0px";
        
        bannerrowcell3.innerHTML = "<button onclick='subtractYear()' class='btn'>" +
        "-</button><span id='year'></span><button onclick='addYear()' class='btn'>+</button>";

        bannerrow.appendChild(bannerrowcell3);
        
        var mainrow2cell = document.createElement("div");
        mainrow2cell.className = "cCell";
        
        mainrow2cell.innerHTML = "<div class='cTable' id='chart'></div>";
        
        mainrow2.appendChild(mainrow2cell);
        
        createMonth(date, selected, date, startweekdate, endweekdate);
    }
}

function ajaxCalendarRequest(aElement, aUrl, date) {
    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function() {
        handleCalendarResult(aElement, httpRequest, date);
    };
    try {
        httpRequest.open('GET', aUrl + date, true);
        httpRequest.send(null);
    } catch(e){
    }
}

function handleCalendarResult(element, aXMLHttpRequest, date) {
    if (!aXMLHttpRequest) return;

    if (!element) return;

    if (aXMLHttpRequest.readyState == 4 && (aXMLHttpRequest.status == 200 || aXMLHttpRequest.status == 304)) {
        var result = JSON.parse(aXMLHttpRequest.responseText);                
        
        if(result[date]){
        
            if(element.getElementsByTagName("div").length <= 0){                    
                var count = document.createElement("div");
                count.className = "dayCount";
                        
                element.appendChild(count);
            }
        
            element.getElementsByTagName("div")[0].innerHTML = result[date];
        }
    }
}