//window.onload = initialize;
function initialize_typoflashHistory() {

	
/** Initialize all of our objects now. 
06/04/2007
http://expisoft.blogspot.com/2007/03/history-restored.html
Changed for IE7
*/
	historyStorage.init();
	dhtmlHistory.create();

  dhtmlHistory.initialize();	
  
  dhtmlHistory.addListener(handleHistoryChange);
  
  // determine our current location so we can
  // initialize ourselves at startup
  var initialLocation = dhtmlHistory.getCurrentLocation();
  //alert("historyData empty " + initialLocation)
  // set the default
  if (initialLocation == ""){
    initialLocation = "<i></i>";
	}
	

  
  // now initialize our starting UI
//when visiting a deeplink we don't know the corresponding title message as that is not stored in the hash
//IE likes to change the title bar to the hash value..which doesn't look good..can either pass all titles in
//in a lookup table from T3 or lets flash update when page is set
  updateUI(initialLocation, {message:document.title});
	
	//swapScrollColor(0);
}

/** A simple method that updates our user
    interface using the new location. */
function updateUI(newLocation, historyData) {
  //var output = document.getElementById("output");
//save for Moz etc
 window.oldTitle = document.title;
  // simply display the location and the
  // data
  var historyMessage;
  if (historyData != undefined ){
	  if(historyData.message != undefined){
			historyMessage = historyData.message;
			document.title = historyData.message;
	  }
	} else {
		
		//document.title = "__";
	}    

}

/*
function debugMsg(msg) {
	var debugMsg = document.getElementById("debugMsg");
	debugMsg.innerHTML = msg;
}
*/

function handleHistoryChange(newLocation, historyData) {
	
	// this is updating the temp html debug message
	//debugMsg("handleHistoryChange() called");
	// this is updating the temp html UI changes
  updateUI(newLocation, historyData);
	//JS function to call back to flash
	
	//alert('history change');
	callExternalInterface();
	
	
}

function callExternalInterface() {
	//target the swf by id
	//updateFlashHistory is the ExternalInterface addCallback methodName
	//Followed by the JS method to be called

	//alert(dhtmlHistory.getCurrentLocation());
  if(thisMovie("main").updateFlashHistory){
		thisMovie("main").updateFlashHistory(dhtmlHistory.getCurrentLocation());
		//alert('method exists - call Flash');
	} else {
		//alert('method doesn\'t exist yet, don\'t call Flash');
		return true;
	}
}




function thisMovie(movieName) {
    if (navigator.appName.indexOf("Microsoft") != -1) {
        return window[movieName]
    }
    else {
        return document[movieName]
    }
}


function setDeepLink(newLocation, historyMessage){	
	var historyData = {message:historyMessage};
	
	// use the history data to update our UI
  updateUI(newLocation, historyData);
	//Add to the dhtml history
	dhtmlHistory.add(newLocation, historyData);

}

function getDeepLink(){
	//debugMsg("getDeepLink() called - " + dhtmlHistory.getCurrentLocation());
	return dhtmlHistory.getCurrentLocation();
}

function getPageTitle(){
	//debugMsg("getPageTitle() called - " + document.title);
	return document.title;
}

function setPageTitle(windowTitle){
	//debugMsg("setPageTitle() called - " + windowTitle);
	document.title = windowTitle;
}

/*
var discoIndex=0; 
function discoScroll(){
	swapScrollColor(discoIndex);
	discoIndex++;
	if(discoIndex>5){
		discoIndex=0;
	}
}
function initDiscoScroll(){
	setInterval("discoScroll()",200) ;
}
*/

//Swap scrollbar color function
function swapScrollColor(sectionNumber){
	switch (sectionNumber) {
		case 0 :
		with(document.body.style)
		{
			scrollbarBaseColor="000000";
			scrollbarDarkShadowColor="080b12";
			scrollbar3dLightColor="080b12";
			scrollbarTrackColor="080b12";
			scrollbarArrowColor="bfd8f1";			
			scrollbarFaceColor="0d1932";
			scrollbarHighlightColor="34466c";
			scrollbarShadowColor="01030a";			
		}
		break;		
		case 1 :
		//company
		with(document.body.style)
		{
			scrollbarBaseColor="000000";
			scrollbarDarkShadowColor="081209";
			scrollbar3dLightColor="081209";
			scrollbarTrackColor="081209";
			scrollbarArrowColor="bff2c4";			
			scrollbarFaceColor="0d3311";
			scrollbarHighlightColor="336b39";
			scrollbarShadowColor="010a02";			
		}
		break;		
		case 2 :
		//portfolio
		with(document.body.style)
		{
			scrollbarBaseColor="000000";
			scrollbarDarkShadowColor="120f08";
			scrollbar3dLightColor="120f08";
			scrollbarTrackColor="120f08";
			scrollbarArrowColor="f2e3bf";			
			scrollbarFaceColor="33280d";
			scrollbarHighlightColor="6b5a33";
			scrollbarShadowColor="0a0701";			
		}
		break;		
		case 3 :
		//services
		with(document.body.style)
		{
			scrollbarBaseColor="000000";
			scrollbarDarkShadowColor="120808";
			scrollbar3dLightColor="120808";
			scrollbarTrackColor="120808";
			scrollbarArrowColor="f2bfbf";			
			scrollbarFaceColor="330d0d";
			scrollbarHighlightColor="6b3333";
			scrollbarShadowColor="0a0101";			
		}
		break;
		case 4 :
		//case studies
		with(document.body.style)
		{
			scrollbarBaseColor="000000";
			scrollbarDarkShadowColor="12080e";
			scrollbar3dLightColor="12080e";
			scrollbarTrackColor="12080e";
			scrollbarArrowColor="f2bfdf";			
			scrollbarFaceColor="330d24";
			scrollbarHighlightColor="6b3356";
			scrollbarShadowColor="0a0107";			
		}
		break;
		case 5 :
		//recognition
		with(document.body.style)
		{
			scrollbarBaseColor="000000";
			scrollbarDarkShadowColor="0d1012";
			scrollbar3dLightColor="0d1012";
			scrollbarTrackColor="0d1012";
			scrollbarArrowColor="ffffff";			
			scrollbarFaceColor="212b31";
			scrollbarHighlightColor="4a5d68";
			scrollbarShadowColor="080a0b";			
		}
		break;
	}
}


function popup(url, w, h,features) {

	var wid = 600;
	var hi = 476;
	
	if (w != null) wid = w; 
	if (h != null) hi  = h; 
	

	
	var winl = (screen.width-w)/2;
	var wint = (screen.height-h)/2;
	
	new_spec = wid + "_" + hi + scroll;

	if(features == null){
		features = "directories=no,menubar=no,status=no,titlebar=no,toolbar=no,resizable=no,scrollBars=yes";
	}
	
	if(features.indexOf("scrollBars=yes")>-1){
		var scroll = true;
	}

	if (scroll && document.all && (navigator.userAgent.indexOf("Mac") > -1)) wid = wid+17;

	
	newwin=window.open(url,new_spec,"WIDTH=" + wid + ",HEIGHT=" + hi + ",screenX="+winl+",screenY="+wint+",left="+winl+",top="+wint+","+features);
	newwin.focus();
}

function doNothing() { return true; }



function allSwfsMustDIE(){
	var objects = document.getElementsByTagName("OBJECT");
	
  for (var i=0; i < objects.length; i++) {
    for (var x in objects[i]) {
      if (typeof objects[i][x] == 'function') {
				//alert('destroying ' + objects[i][x]);
        objects[i][x] = null;
      }
    }
  }
	
	
	var divHolder = document.getElementById("flash");
	var divToKILL = document.getElementById("flashcontent_");
	divHolder.removeChild(divToKILL);
	

}

if (typeof window.onunload == 'function') {
  var oldunload = window.onunload;
  window.onunload = function() {
    allSwfsMustDIE();
    oldunload();
  }
} else {
  window.onunload = allSwfsMustDIE;
}


function scrollWindow(xScroll, yScroll){
	scroll(xScroll,yScroll);
	return true;
}