
/* set 'str' as the new text for 'Next' Button*/
function setNextButtonText(str){
    $('nextButton').innerHTML = "<span>" + str + "</span>";
}

/* add 'setNextButtonText(Finish)' to onmousedown attribute where innerHTML is 'optionText' */
function addOnMouseDownAction(optionText){
    var choices = $('options').getElementsByTagName('li');

    for(var i = 0; i < choices.length; i++){
        var onMouseDown = choices[i].getAttribute('onmousedown');

        if((optionText.join(';')+';').match(choices[i].innerHTML +';')){
            choices[i].setAttribute('onmousedown', onMouseDown + " setNextButtonText('Finish');");
        }
        else{
            choices[i].setAttribute('onmousedown', onMouseDown + " setNextButtonText('Next');");
        }
    }
}

/* format date by either estimating it or giving it a valid format*/
function formatDate(main_date, sub_str, pos){

    var formatted_date = [];

    formatted_date['value_modifier'] = ''; /*assume the date is not estimated*/

    if(pos == 0) /*year*/
    {
        if (sub_str.toLowerCase() != 'unknown') {
            formatted_date['value_datetime'] = sub_str;
        }
        else{
            formatted_date['value_datetime'] = null; /* since year is unknown, leave the date 'null'*/
        }
    }

    else if(pos == 1) /*month*/
    {

        if (sub_str.toLowerCase() != 'unknown') {
            formatted_date['value_datetime'] = main_date +'-'+ sub_str;
        }
        else{
            formatted_date['value_datetime'] = main_date +'-07-01'; /* since month is unknown, estimate date*/
            formatted_date['value_modifier'] = 'ES';
        }
    }

    else if(pos == 2) /*day*/
    {
        if (sub_str.toLowerCase() != 'unknown') {
            formatted_date['value_datetime'] = main_date +'-'+ sub_str;
        }
        else{
            formatted_date['value_datetime'] = main_date +'-15'; /* since day is unknown, estimate date*/
            formatted_date['value_modifier'] = 'ES';
        }
    }

    return formatted_date;
}

/* checks for the presence of a substring in a given string of
  * semi-colon separated substrings.
  * it returns 'true' if found, otherwise it returns 'false'
  *
  * for example :
  *  1. ["programming;in;javascript;is;cool"].contains("javascript") => true
  *  2. ["programming;in;javascript;is;cool"].contains("java") => false
  *
  * TO DO: ADD HANDLING OF 'SPACE' SEPARATED SUBSTRINGS
  */
String.prototype.contains = function (substring) {

    var array_of_strings = this.split(';');

    if (jQuery.inArray(substring, array_of_strings)>= 0)  {
        return true;
    }
    else {
        return false;
    }
}

function onYearUpdateDateTime(main_field_str, year_str, modifier_str){

    var time      = new Date();
    var this_year = time.getYear();
    var estimated_date = [];

    if (this_year < 2000){
        this_year=(time.getYear() + 1900);
    }

    estimated_date = formatDate($(main_field_str).value, $(year_str).value,0);


    if((this_year - $(year_str).value > 2))  {

        estimated_date = formatDate($(year_str).value, 'unknown', 1);
    }
    $(main_field_str).value = estimated_date['value_datetime'];
    $(modifier_str).value   = estimated_date['value_modifier'];
}

function onMonthUpdateDateTime(main_field_str, month_str, modifier_str){

    var estimated_date = formatDate($(main_field_str).value, $(month_str).value, 1);

    $(main_field_str).value = estimated_date['value_datetime'];
    $(modifier_str).value   = estimated_date['value_modifier'];

    if(($(month_str).value.toLowerCase() != 'unknown'))  {
        estimated_date = formatDate($(main_field_str).value, 'unknown', 2);

        $(main_field_str).value = estimated_date['value_datetime'];
        $(modifier_str).value   = estimated_date['value_modifier'];
    }
}

function displayTab(tabMenu, tabMenuId, tabBody, tabMenuContainer){

    /* inactivate all tab menus */
    function inactivateAlltabs(menu) {
        menu      = document.getElementById(menu);
        tabLinks  = menu.getElementsByTagName('LI');

        for (i = 0; i < tabLinks.length; i++) {
            tabLinks[i].className = '';
        }
    }

    /* hide all tab menus */
    function hideAllTabs(tab) {
        tabData = document.getElementById(tab);
        tabDivs = tabData.getElementsByTagName('DIV');

        for (i = 0; i < tabDivs.length; i++) {
            tabDivs[i].style.display = 'none';
        }
    }

    /* activate a tab*/
    function doShow(menu, menuId) {
        hideAllTabs(tabMenuContainer);
        inactivateAlltabs(tabBody);
        menu.className = 'activated';
        tabData = document.getElementById(menuId);
        tabData.style.display = 'block';
        return false;
    }

    doShow(tabMenu, tabMenuId);
}

function confirmRecordDeletion(message, form) {    
    if(!tstMessageBar){
        var tstMessageBar = document.createElement("div");
        tstMessageBar.id = "messageBar";
        tstMessageBar.className = "messageBar";

        tstMessageBar.innerHTML = message + "<br/>" +
        "<button onmousedown=\"document.getElementById('content').removeChild(document.getElementById('messageBar')); if(document.getElementById('" + form +
        "')) document.getElementById('" + form +
        "').submit();\"><span>Yes</span></button><button onmousedown=\"document.getElementById('content').removeChild(document.getElementById('messageBar'));\"><span>No</span></button>";

        tstMessageBar.style.display = "block";
        document.getElementById("content").appendChild(tstMessageBar);
        
        return false; 
    }
    return false;
}

String.prototype.capitalize = function(){
  var titleized_string = new Array();

  if( (this.length > 0)){
    titleized_string.push(this[0].toUpperCase());
    titleized_string.push(this.substring(1,this.length).toLowerCase());
    return titleized_string.join("");
   }

  else{
    return this;
 }
}

String.prototype.titleize = function(){
	var titleized_string = new Array();
	var sub_strings = this.split(" ");

  for(i = 0; i < sub_strings.length; i++)
		titleized_string.push(sub_strings[i].capitalize());

	return titleized_string.join(" ");
}

function showProgressBar(id){
  var info, element;

    if(typeof(custom_message) == "undefined"){
    custom_message="The system is processing your request.";
    }

    info = "<div id='popupBox'  align='center'>";
    info += "<p id='p1'>"+custom_message+"</p>";
    info += "<p id='p2'>Please wait......</p>";
    info += "</div>";

    element = document.getElementById(id);
    element.innerHTML += info;

    alert(element.innerHTML);

}
