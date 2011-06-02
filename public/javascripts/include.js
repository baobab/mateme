//include.js :
// this is the only file necessary to call in pages using the ToolKit in the
// current version

/*******************************************************************************
 *
 * Baobab Touchscreen Toolkit
 *
 * A library for transforming HTML pages into touch-friendly user interfaces.
 *
 * (c) 2011 Baobab Health Trust (http://www.baobabhealth.org)
 *
 * For lincense details, see the README.md file
 *
 ******************************************************************************/

function __$(id){
    return document.getElementById(id);
}

function include(file){
    // Three links for the same file are also created to allow for usage of the calls in
    // pure HTML prototypes as well as RAILS application with 2 scenarios for pure
    // HTML prototypes in cases where sub-folders are used; a kind of overloading
    // due to javascript limitations as it can't check file existence
	var script1 = document.createElement("script");
    script1.setAttribute("language", "javascript");
    script1.setAttribute("src", "../javascripts/" + file + (!file.match(/\.js$/) ? ".js" : ""));
    script1.setAttribute("type", "text/javascript");

    document.getElementsByTagName("head")[0].appendChild(script1);

    var script2 = document.createElement("script");
    script2.setAttribute("language", "javascript");
    script2.setAttribute("src", "/javascripts/" + file + (!file.match(/\.js$/) ? ".js" : ""));
    script2.setAttribute("type", "text/javascript");

    document.getElementsByTagName("head")[0].appendChild(script2);

    var script3 = document.createElement("script");
    script3.setAttribute("language", "javascript");
    script3.setAttribute("src", "javascripts/" + file + (!file.match(/\.js$/) ? ".js" : ""));
    script3.setAttribute("type", "text/javascript");

    document.getElementsByTagName("head")[0].appendChild(script3);

    var fileType = file.match(/transform|dashboard|touchscreen/i);

    if(fileType){
        fileType = fileType[0];

        switch(fileType){
            case "transform":
                includeCss("transform");
                includeCss("dashboard");
                break;
            case "dashboard":
                includeCss("graytabs");
                includeCss("dashboard");
                includeCss("touch-fancy");
                break;
            default:
                includeCss("form");
                includeCss("graytabs");
                includeCss("touch-fancy");
                break;
        }
    }
}

// Three links for the same file are created to allow for usage of the method in
// pure HTML prototypes as well as RAILS application with 2 scenarios for pure
// HTML prototypes in cases where sub-folders are used; a kind of overloading
// due to javascript limitations as it can't check file existence
function includeCss(file){
    if(file != undefined){
        var link1 = document.createElement("link");
        link1.setAttribute("rel", "stylesheet");
        link1.setAttribute("href", "stylesheets/" + file + (!file.match(/\.css$/) ? ".css" : ""));
        link1.setAttribute("type", "text/css");

        document.getElementsByTagName("head")[0].appendChild(link1);

        var link2 = document.createElement("link");
        link2.setAttribute("rel", "stylesheet");
        link2.setAttribute("href", "/stylesheets/" + file + (!file.match(/\.css$/) ? ".css" : ""));
        link2.setAttribute("type", "text/css");

        document.getElementsByTagName("head")[0].appendChild(link2);

        var link3 = document.createElement("link");
        link3.setAttribute("rel", "stylesheet");
        link3.setAttribute("href", "../stylesheets/" + file + (!file.match(/\.css$/) ? ".css" : ""));
        link3.setAttribute("type", "text/css");

        document.getElementsByTagName("head")[0].appendChild(link3);
    }
}

function createLoadingMessage(){
    var msg = document.createElement("div");
    msg.id = "loadingProgressMessage";
    msg.style.zIndex = 1000;
    msg.style.color = "#00f";
    msg.style.backgroundColor = "#fff";
    msg.style.fontSize = "2em";
    msg.innerHTML = "<div id='progressAnimation' style='margin-top:35%; " +
    "font-style: italic; padding-left: 350px; border: 1px solid #fff; text-align: left;'>Loading. Please Wait...</div>";
    msg.style.position = "absolute";
    msg.style.left = "50%";
    msg.style.top = "50%";
    msg.style.width = "1000px";
    msg.style.height = "750px";
    msg.style.marginLeft = "-500px";
    msg.style.marginTop = "-380px";
    msg.style.textAlign = "center";
    msg.style.verticalAlign = "middle";

    document.body.appendChild(msg);

    setTimeout("changeProgressMessage('progressAnimation')", 300);
}

function changeProgressMessage(id){
    var obj = __$(id);

    if(obj){
        if(obj.innerHTML.trim() == "Loading. Please Wait..."){
            obj.innerHTML = "Loading. Please Wait";
        } else if(obj.innerHTML.trim() == "Loading. Please Wait"){
            obj.innerHTML = "Loading. Please Wait.";
        } else if(obj.innerHTML.trim() == "Loading. Please Wait."){
            obj.innerHTML = "Loading. Please Wait..";
        } else if(obj.innerHTML.trim() == "Loading. Please Wait.."){
            obj.innerHTML = "Loading. Please Wait...";
        }

        setTimeout("changeProgressMessage('" + id + "')", 300);
    }
}

// Load progress message
createLoadingMessage();

// Check the kind of page we have and render accordingly
// Added half a minute sleep to allow the page to finish loading.
if((document.forms[0] != undefined ? (document.forms[0].getAttribute("extended") != null ?
    (document.forms[0].getAttribute("extended") == "true" ? true : false) : false) : false)){

    include("transform");
    setTimeout("initMultipleQuestions()", 200);


} else if(__$('home') != null || __$('dashboard') != null){

    include("dashboard");
    //setTimeout("createPage()", 200);

} else {

    include("touchscreen");
    //setTimeout("loadTouchscreenToolkit()", 200);

}
