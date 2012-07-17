// --------------------------------------------------------------------
// 
// Touchscreen Toolkit
//
// (c) 2010 Baobab Health Partnership www.baobabhealth.org
//
// --------------------------------------------------------------------
//
var milisec=0; 
var seconds=30; 
//var countDownValue = 30;
var continueCount = false;

function display(){ 
  if (seconds == 0){
    continueCount = false
    document.location.href = "/login?auto_logout=true";
  }

  if (continueCount == true){
    if (milisec<=0){ 
      milisec=9;
      seconds-=1;
    } 
    
    if (seconds<=-1){ 
      milisec=0;
      seconds+=1;
    } 
    
    else
      milisec-=1; 
    document.getElementById('countDown').innerHTML=seconds;
    setTimeout("display()",100);
  }
} 

function hideMessage(){ 
  document.getElementById('logoutMessage').style.display = 'none' 
}

function destinationUrl(){
  if (seconds == 0){
    continueCount = false;
    document.location.href = "/login?auto_logout=true";
  }
  else{
    continueCount = false;
    milisec=0; 
    seconds=30; 
    setTimeout("resetTimer()", 60000*3);
  }

}

function resetTimer(){
  document.getElementById('logoutMessage').innerHTML = "You will be logged out in<br/>" +
                              "<span id='countDown'> </span> seconds <br />" +
															"<button onmousedown='hideMessage(); destinationUrl();'><span>Cancel</span></button><br />";
  document.getElementById('logoutMessage').style.display = "block";
  continueCount = true;
  display(); 
}

setTimeout("resetTimer()", 60000*3);

