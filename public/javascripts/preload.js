// Pre load images if we are fancy
var left_buttons = [
  'btn_left_blue.png',		
  'btn_left_dark.png',		
  'btn_left_gray.png',		
  'btn_left_green.png',	
  'btn_left_hover_blue.png',		
  'btn_left_hover_dark.png',		
  'btn_left_hover_gray.png',		
  'btn_left_hover_green.png',	
  'btn_left_hover_red.png',		
  'btn_left_red.png'
];
	
var right_buttons = [    	
  'btn_right_blue.png',		
  'btn_right_dark.png',		
  'btn_right_gray.png',		
  'btn_right_green.png',		
  'btn_right_hover_blue.png',	
  'btn_right_hover_dark.png',
  'btn_right_hover_gray.png',
  'btn_right_hover_green.png',
  'btn_right_hover_red.png',
  'btn_right_red.png'
]

var images = [];

preload(left_buttons, 500, 56);
preload(right_buttons, 32, 56);

function preload(arr, width, height) { 
  for (var i=0; i < arr.length; i++) {
    images[images.length] = new Image(width, height);
    images[images.length-1].src = '/images/buttons/' + arr[i];
  }  
}
