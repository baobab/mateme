var patnum = ""
var setFocusTimeout = 5000;
var checkForBarcodeTimeout = 1500;
var barcodeFocusTimeoutId = null;


function loadBarcodePage() {
  focusForBarcodeInput()
  checkForBarcode()
}

function focusForBarcodeInput(barcodeId){
	if (!barcodeId) {
		barcodeId = "barcode";
	}
  var barcode = document.getElementById("barcode");
	if (barcode) {
		barcode.focus();
		barcodeFocusTimeoutId = window.setTimeout("focusForBarcodeInput()", setFocusTimeout);
	}
}

function checkForBarcode(barcodeId, validAction){
	if (!barcodeId) {
		barcodeId = "barcode";
	}
  barcode_element = document.getElementById(barcodeId)
	if (!barcode_element)
		return

  // Look for anything with a dollar sign at the end
  if (barcode_element.value.match(/.+\$$/i) != null){
    barcode_element.value = barcode_element.value.substring(0,barcode_element.value.length-1)

		if (typeof validAction == "string" && barcodeId != "barcode")
			eval(validAction);
		else if (typeof barcodeScanAction != "undefined")
			barcodeScanAction();
		else
    	document.getElementById('barcodeForm').submit();
    return
  }
  window.setTimeout("checkForBarcode('"+barcodeId+"', '" + validAction + "')", checkForBarcodeTimeout);
}


window.addEventListener("load", loadBarcodePage, false)
