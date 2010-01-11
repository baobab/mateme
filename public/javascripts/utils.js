
/* set 'str' as the new text for 'Next' Button*/
function setNextButtonText(str){
    $('nextButton').innerHTML = "<span>" + str + "</span>";
  }

/* add 'setNextButtonText(Finish)' to onmousedown attribute where innerHTML is 'optionText' */
function addOnMouseDownAction(optionText){
  var choices = $('options').getElementsByTagName('li');

  for(var i = 0; i < choices.length; i++){
    var onMouseDown = choices[i].getAttribute('onmousedown');

    if(choices[i].innerHTML == optionText){
      choices[i].setAttribute('onmousedown', onMouseDown + " setNextButtonText('Finish')");
    }
    else{
      choices[i].setAttribute('onmousedown', onMouseDown + " setNextButtonText('Next')");
    }
  }
}