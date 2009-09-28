var patnum = ""
var setFocusTimeout = 5000;
var checkForBarcodeTimeout = 1500;
var barcodeFocusTimeoutId = null;
var barcodeFocusOnce = false;
var barcodeId = '';
var focusOnce = false;

function loadBarcodePage() {
  focusForBarcodeInput()
  checkForBarcode()
}

function focusForBarcodeInput(){
	if (!barcodeId) {
		barcodeId = "barcode";
	}
  var barcode = document.getElementById("barcode");
	if (barcode) {
		barcode.focus();
		if (!focusOnce) barcodeFocusTimeoutId = window.setTimeout("focusForBarcodeInput()", setFocusTimeout);
	}
}

function checkForBarcode(validAction){
	if (!barcodeId) {
		barcodeId = "barcode";
	}
  barcode_element = document.getElementById(barcodeId)
	if (!barcode_element)
		return

  // Look for anything with a dollar sign at the end
  if (barcode_element.value.match(/.+\$$/i) != null){
    barcode_element.value = barcode_element.value.substring(0,barcode_element.value.length-1)
		if (typeof barcodeScanAction != "undefined")
			barcodeScanAction();
		else
    	document.getElementById('barcodeForm').submit();
  }
  window.setTimeout("checkForBarcode('" + validAction + "')", checkForBarcodeTimeout);
}


window.addEventListener("load", loadBarcodePage, false)
