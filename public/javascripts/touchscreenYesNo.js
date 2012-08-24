var confirmation = null;
var confirmationTimeout = null;

function confirmYesNo(message, yes, no) {
  hideConfirmation();
  if (confirmation == null) {
    confirmation = document.createElement("div");
    confirmation.setAttribute('id', 'confirmation');
    confirmation.setAttribute('style', 'display:none');
    confirmation.style.left = "50%";
    confirmation.style.marginLeft = "-225px";
    confirmation.style.width = "450px";
    confirmation.style.position = "absolute";
    confirmation.style.top = "30%";
    confirmation.style.fontSize = "2em";
    confirmation.style.textAlign = "center";
    confirmation.style.backgroundColor = "tomato";
    confirmation.style.zIndex = "999";
    
    document.body.appendChild(confirmation);
  }
  confirmation.innerHTML = ''+
  '<div class="confirmation" style="left:50%; margin-left: -225px; width: 450px; ' +
    'position: absolute; top: 30%; font-size: 2em; text-align: center; ' +
    'background-color: tomato; z-index: 999;">'+ message+ '<div>'+
  '<button id="yes"><span>Yes</span></button>'+
  '<button id="no"><span>No</span></button></div>'+
  '</div>';
  $("#yes").mousedown(yes);
  $("#no").mousedown(no);
  confirmation.setAttribute('style', 'display:block');
  confirmationTimeout = window.setTimeout("hideConfirmation()", 5000);
}

function hideConfirmation(){ 
  if (confirmation != null) confirmation.setAttribute('style', 'display:none');
  if (confirmationTimeout != null) window.clearTimeout(confirmationTimeout);
}
