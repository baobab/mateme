
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
