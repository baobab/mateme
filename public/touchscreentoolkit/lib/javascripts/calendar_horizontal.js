
var selecteddays = {};            
            
var active_cell = null;
var selected_color = "#9e9";
var default_color = "#fff";
var selected_date = null;
var targetControl = null;
            
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
        "-" + padZeros(selected_date.getDate(), 2), selecteddays);
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
        "-" + padZeros(selected_date.getDate(), 2), selecteddays);
}
            
function addYear(){
    current_year++;
    createMonth(current_year + "-" + padZeros((selected_date.getMonth() + 1), 2) + 
        "-" + padZeros(selected_date.getDate(), 2), selecteddays);                
}
            
function subtractYear(){
    current_year--;
    createMonth(current_year + "-" + padZeros((selected_date.getMonth() + 1), 2) + 
        "-" + padZeros(selected_date.getDate(), 2), selecteddays);
}
            
function createMonth(date, selected){
    __$("chart").innerHTML = "";
                
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
                
    var names = ["S", "M", "T", "W", "T", "F", "S"];
    var days = {
        0:[0,7,14,21,28,35], 
        1:[1,8,15,22,29,36], 
        2:[2,9,16,23,30,37], 
        3:[3,10,17,24,31,38], 
        4:[4,11,18,25,32,39], 
        5:[5,12,19,26,33,40], 
        6:[6,13,20,27,34,41]
    };
                
    var carry_over_day = new Date(first_day.getFullYear(), first_day.getMonth(), first_day.getDate());    
                
    if(carry_over_day.getDay() > 0){
        carry_over_day.setDate(carry_over_day.getDate() - first_day.getDay());
    }
                
    for(var day in days){
        var row = document.createElement("div");
        row.className = "cRow";
                    
        __$("chart").appendChild(row);
                    
        var dayCell = document.createElement("div");
        dayCell.className = "cCell" + (day == 0 || day == 6 ? " weekEnd" : " weekDay");
        dayCell.innerHTML = names[day];
                    
        row.appendChild(dayCell);
                    
        var current_day = new Date(carry_over_day.getFullYear(), carry_over_day.getMonth(), carry_over_day.getDate());
                    
        for(var d = 0; d < days[day].length; d++){
            var dayCell = document.createElement("div");
            dayCell.id = days[day][d];
            0
            var found = false;
            if(selected_date != null){
                if((current_day.getFullYear() == selected_date.getFullYear() && 
                    current_day.getMonth() == selected_date.getMonth() && 
                    current_day.getDate() == selected_date.getDate())) {
                                
                    active_cell = days[day][d]; 
                    found = true;
                }
            }
                        
            var checkDay = current_day.getDay();
                        
            switch(checkDay){
                case 0:
                    if(days[day][d] == 0 || days[day][d] == 7 || days[day][d] == 14 || 
                        days[day][d] == 21 || days[day][d] == 28 || days[day][d] == 35){
                                    
                        if(current_day.getMonth() == first_day.getMonth()){
                            dayCell.innerHTML = current_day.getDate();
                                        
                            dayCell.setAttribute("value", current_day.getDate());
                                        
                            dayCell.className = "cCell day weekEndDay" + 
                            ((current_day.getFullYear() == today.getFullYear() && 
                                current_day.getMonth() == today.getMonth() && 
                                current_day.getDate() == today.getDate()) ? " today" : "");
                        } else {
                            dayCell.innerHTML = "&nbsp;";
                            dayCell.className = "cCell day cellInactive";
                        }
                                    
                        if(checkDay == 0){
                            current_day.setDate(current_day.getDate() + 7);
                        }                                    
                    } else {
                        dayCell.innerHTML = "&nbsp;";
                    }                                
                    break;
                case 1:
                    if(days[day][d] == 1 || days[day][d] == 8 || days[day][d] == 15 || 
                        days[day][d] == 22 || days[day][d] == 29 || days[day][d] == 36){
                                    
                        if(current_day.getMonth() == first_day.getMonth()){
                            dayCell.innerHTML = current_day.getDate();
                                        
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
                                        
                            dayCell.className = "cCell day cellActive" + 
                            ((current_day.getFullYear() == today.getFullYear() && 
                                current_day.getMonth() == today.getMonth() && 
                                current_day.getDate() == today.getDate()) ? " today" : "");
                                        
                            dayCell.onclick = function(){
                                if(active_cell != null){
                                    __$(active_cell).style.backgroundColor = default_color;
                                    __$(active_cell).style.color = "#000";
                                }
                                            
                                active_cell = this.id;
                                __$(active_cell).style.backgroundColor = selected_color;
                                __$(active_cell).style.color = "#fff";
                                            
                                targetControl.value = current_year + "-" + 
                                    padZeros((months[current_month][0] + 1), 2) + "-" + 
                                    padZeros(this.getAttribute("value"), 2);
                                
                                selected_date = new Date(current_year, months[current_month][0], this.getAttribute("value"));
                            }
                        } else {
                            dayCell.innerHTML = "&nbsp;";
                            dayCell.className = "cCell day cellInactive";
                        }
                                    
                        if(checkDay == 1){
                            current_day.setDate(current_day.getDate() + 7);
                        }                                    
                    } else {
                        dayCell.innerHTML = "&nbsp;";
                    }
                                
                    break;
                case 2:
                    if(days[day][d] == 2 || days[day][d] == 9 || days[day][d] == 16 || 
                        days[day][d] == 23 || days[day][d] == 30 || days[day][d] == 37){
                                    
                        if(current_day.getMonth() == first_day.getMonth()){
                            dayCell.innerHTML = current_day.getDate();
                                        
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
                                        
                            dayCell.className = "cCell day cellActive" + 
                            ((current_day.getFullYear() == today.getFullYear() && 
                                current_day.getMonth() == today.getMonth() && 
                                current_day.getDate() == today.getDate()) ? " today" : "");
                                        
                            dayCell.onclick = function(){
                                if(active_cell != null){
                                    __$(active_cell).style.backgroundColor = default_color;
                                    __$(active_cell).style.color = "#000";
                                }
                                            
                                active_cell = this.id;
                                __$(active_cell).style.backgroundColor = selected_color;
                                __$(active_cell).style.color = "#fff";
                                            
                                targetControl.value = current_year + "-" + 
                                    padZeros((months[current_month][0] + 1), 2) + "-" + 
                                    padZeros(this.getAttribute("value"), 2);                                
                                            
                                selected_date = new Date(current_year, months[current_month][0], this.getAttribute("value"));
                            }
                        } else {
                            dayCell.innerHTML = "&nbsp;";
                            dayCell.className = "cCell day cellInactive";
                        }
                                    
                        if(checkDay == 2){
                            current_day.setDate(current_day.getDate() + 7);
                        }                                    
                    } else {
                        dayCell.innerHTML = "&nbsp;";
                    }
                    break;
                case 3:
                    if(days[day][d] == 3 || days[day][d] == 10 || days[day][d] == 17 || 
                        days[day][d] == 24 || days[day][d] == 31 || days[day][d] == 38){
                                    
                        if(current_day.getMonth() == first_day.getMonth()){
                            dayCell.innerHTML = current_day.getDate();
                                        
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
                                        
                            dayCell.className = "cCell day cellActive" + 
                            ((current_day.getFullYear() == today.getFullYear() && 
                                current_day.getMonth() == today.getMonth() && 
                                current_day.getDate() == today.getDate()) ? " today" : "");
                                        
                            dayCell.onclick = function(){
                                if(active_cell != null){
                                    __$(active_cell).style.backgroundColor = default_color;
                                    __$(active_cell).style.color = "#000";
                                }
                                            
                                active_cell = this.id;
                                __$(active_cell).style.backgroundColor = selected_color;
                                __$(active_cell).style.color = "#fff";
                                            
                                targetControl.value = current_year + "-" + 
                                    padZeros((months[current_month][0] + 1), 2) + "-" + 
                                    padZeros(this.getAttribute("value"), 2);  
                                            
                                selected_date = new Date(current_year, months[current_month][0], this.getAttribute("value"));
                            }
                        } else {
                            dayCell.innerHTML = "&nbsp;";
                            dayCell.className = "cCell day cellInactive";
                        }
                                    
                        if(checkDay == 3){
                            current_day.setDate(current_day.getDate() + 7);
                        }                                    
                    } else {
                        dayCell.innerHTML = "&nbsp;";
                    }
                    break;
                case 4:
                    if(days[day][d] == 4 || days[day][d] == 11 || days[day][d] == 18 || 
                        days[day][d] == 25 || days[day][d] == 32 || days[day][d] == 39){
                                    
                        if(current_day.getMonth() == first_day.getMonth()){
                            dayCell.innerHTML = current_day.getDate();
                                        
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
                                        
                            dayCell.className = "cCell day cellActive" + 
                            ((current_day.getFullYear() == today.getFullYear() && 
                                current_day.getMonth() == today.getMonth() && 
                                current_day.getDate() == today.getDate()) ? " today" : "");
                                        
                            dayCell.onclick = function(){
                                if(active_cell != null){
                                    __$(active_cell).style.backgroundColor = default_color;
                                    __$(active_cell).style.color = "#000";
                                }
                                            
                                active_cell = this.id;
                                __$(active_cell).style.backgroundColor = selected_color;
                                __$(active_cell).style.color = "#fff";
                                            
                                targetControl.value = current_year + "-" + 
                                    padZeros((months[current_month][0] + 1), 2) + "-" + 
                                    padZeros(this.getAttribute("value"), 2);  
                                            
                                selected_date = new Date(current_year, months[current_month][0], this.getAttribute("value"));
                            }
                        } else {
                            dayCell.innerHTML = "&nbsp;";
                            dayCell.className = "cCell day cellInactive";
                        }
                                                                        
                        if(checkDay == 4){
                            current_day.setDate(current_day.getDate() + 7);
                        }
                                    
                    } else {
                        dayCell.innerHTML = "&nbsp;";
                    }
                    break;
                case 5:
                    if(days[day][d] == 5 || days[day][d] == 12 || days[day][d] == 19 || 
                        days[day][d] == 26 || days[day][d] == 33 || days[day][d] == 40){
                                    
                        if(current_day.getMonth() == first_day.getMonth()){
                            dayCell.innerHTML = current_day.getDate();
                                        
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
                                        
                            dayCell.className = "cCell day cellActive" + 
                            ((current_day.getFullYear() == today.getFullYear() && 
                                current_day.getMonth() == today.getMonth() && 
                                current_day.getDate() == today.getDate()) ? " today" : "");
                                        
                            dayCell.onclick = function(){
                                if(active_cell != null){
                                    __$(active_cell).style.backgroundColor = default_color;
                                    __$(active_cell).style.color = "#000";
                                }
                                            
                                active_cell = this.id;
                                __$(active_cell).style.backgroundColor = selected_color;
                                __$(active_cell).style.color = "#fff";
                                            
                                targetControl.value = current_year + "-" + 
                                    padZeros((months[current_month][0] + 1), 2) + "-" + 
                                    padZeros(this.getAttribute("value"), 2);  
                                            
                                selected_date = new Date(current_year, months[current_month][0], this.getAttribute("value"));
                            }
                        } else {
                            dayCell.innerHTML = "&nbsp;";
                            dayCell.className = "cCell day cellInactive";
                        }
                                                                
                        if(checkDay == 5){
                            current_day.setDate(current_day.getDate() + 7);
                        }                            
                    } else {
                        dayCell.innerHTML = "&nbsp;";
                    }
                    break;
                case 6:
                    if(days[day][d] == 6 || days[day][d] == 13 || days[day][d] == 20 || 
                        days[day][d] == 27 || days[day][d] == 34 || days[day][d] == 41){
                                    
                        if(current_day.getMonth() == first_day.getMonth()){
                            dayCell.innerHTML = current_day.getDate();
                                        
                            dayCell.setAttribute("value", current_day.getDate());
                                        
                            dayCell.className = "cCell day weekEndDay" + 
                            ((current_day.getFullYear() == today.getFullYear() && 
                                current_day.getMonth() == today.getMonth() && 
                                current_day.getDate() == today.getDate()) ? " today" : "");
                        } else {
                            dayCell.innerHTML = "&nbsp;";
                            dayCell.className = "cCell day cellInactive";
                        }
                                    
                        if(checkDay == 6){
                            current_day.setDate(current_day.getDate() + 7);
                        }
                                    
                    } else {
                        dayCell.innerHTML = "&nbsp;";
                    }
                    break;
            }
                    
            row.appendChild(dayCell);
            if(found){
                __$(active_cell).click();
            }
        }
                    
        carry_over_day.setDate(carry_over_day.getDate() + 1);
                
    }
}
                        
function createCalendar(control, target, date, selected){
    if(__$(control) && __$(target)){
        
        targetControl = __$(target);
        
        var main = document.createElement("div");
        main.className = "cTable";
        main.id = "calendar";
    
        __$(control).appendChild(main);
        
        var mainrow1 = document.createElement("div");
        mainrow1.className = "cRow";
        
        main.appendChild(mainrow1);
        
        var mainrow2 = document.createElement("div");
        mainrow2.className = "cRow";
        
        main.appendChild(mainrow2);
        
        var mainrow1cell = document.createElement("div");
        mainrow1cell.className = "cCell";
        
        mainrow1.appendChild(mainrow1cell);
        
        var bannerTable = document.createElement("div");
        bannerTable.className = "cTable";
        bannerTable.style.width = "100%";
        
        mainrow1cell.appendChild(bannerTable);
        
        var bannerrow = document.createElement("div");
        bannerrow.className = "cRow";
        
        bannerTable.appendChild(bannerrow);
        
        var bannerrowcell1 = document.createElement("div");
        bannerrowcell1.className = "cCell";
        
        bannerrowcell1.innerHTML = "<button onclick='subtractMonth()' class='btn'>-</button>" + 
        "<span id='month'></span><button onclick='addMonth()' class='btn'>+</button>";
    
        bannerrow.appendChild(bannerrowcell1);
                
        var bannerrowcell2 = document.createElement("div");
        bannerrowcell2.className = "cCell";
        bannerrowcell2.style.textAlign = "right";
        
        bannerrowcell2.innerHTML = "<button onclick='subtractYear()' class='btn'>" +
        "-</button><span id='year'></span><button onclick='addYear()' class='btn'>+</button>";

        bannerrow.appendChild(bannerrowcell2);
        
        var mainrow2cell = document.createElement("div");
        mainrow2cell.className = "cCell";
        
        mainrow2cell.innerHTML = "<div class='cTable' id='chart'></div>";
        
        mainrow2.appendChild(mainrow2cell);
        
        createMonth(date, selected);
    }
}