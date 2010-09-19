// Stage variables
Stage.scaleMode = "noScale";
Stage.align = "TL";

// Center activity icon
activity._x = Stage.width/2;
activity._y = Stage.height/2;

if(IS_LIVE != 1){
	_global.HOST_URL = "http://localhost:805/";
	//borg.managers.DepthManager.initialize();
	media = "tx_dam_31,tx_dam_32,tx_dam_31,tx_dam_32";
	_global['LANGUAGE'] = 0;


	width=200
	height=88
	autostart=true;
	shuffle = false
	repeat = true
	backcolor = "0xD2DA63"
	frontcolor= "0x353500";
	lightcolor = "0x4B5300"
	displayheight = 0
	showicons = true
	logo = false;
	showeq = false;
	linkfromdisplay = false;
	linktarget = "_blank";
	overstretch = true
	showdigits = true
	showfsbutton = false
	fullscreenmode = false
	fullscreenpage
	fsreturnpage
	bufferlength
	volume = 80
	autoscroll = false;
	thumbsinplaylist = false;
	rotatetime
	shownavigation = true
	transition = false
	callback
	streamscript
	enablejs = false


}else{

	_global['LANGUAGE'] = L;
	_global.HOST_URL = HOST_URL;
	media = MEDIA;

	width=WIDTH
	height=HEIGHT
	autostart= Boolean(AUTOSTART == '1');
	shuffle =  Boolean(SHUFFLE == '1');
	repeat =  Boolean(REPEAT == '1');
	backcolor = BACKCOLOR
	frontcolor= FRONTCOLOR
	lightcolor = LIGHTCOLOR
	displayheight = DISPLAYHEIGHT
	showicons =   Boolean(SHOWICONS== '1');
	showeq = Boolean(SHOWEQ== '1');
	linkfromdisplay = LINKFROMDISPLAY
	linktarget = LINKTARGET
	showdigits =  Boolean(SHOWDIGITS== '1');
	showfsbutton =   Boolean(SHOWFSBUTTON== '1');
	fullscreenmode =  FULLSCREENMODE;
	fullscreenpage = FULLSCREENPAGE
	fsreturnpage = FSRETURNPAGE
	bufferlength = BUFFERLENGTH
	volume = VOLUME
	autoscroll =  Boolean(AUTOSCROLL== '1');
	thumbsinplaylist =  Boolean(THUMBSINPLAYLIST== '1');
	rotatetime = ROTATETIME
	shownavigation =  SHOWNAVIGATION;
	callback = CALLBACK
	streamscript = STREAMSCRIPT
	enablejs =  ENABLEJS;


}

_global.REMOTING_GATEWAY = _global.HOST_URL + "typo3conf/ext/borg_flashremoting/gateway.php";

_root.bg._width = width
_root.bg._height = height
var c = new Color(_root.bg);
c.setRGB(backcolor);

import borg.typo3.pagecontrol.ContentRendering;

borg.typo3.pagecontrol.ContentRendering.addEventListener("onGetMedia",this);
borg.typo3.pagecontrol.ContentRendering.addEventListener("onGetMediaFromCategory",this);
menuId = "mp3player";


///////



///////


stop();

if(this.media != null){
	var o = {};
	o.media = this.media;
	o.callback = 'onGetMedia';
	o.menuId = this.menuId;
	//o.orderBy='title';
	borg.typo3.pagecontrol.ContentRendering.getMedia(o);

}

if(this.media_category != null){
	var o = {};
	o.media_category = this.media_category;
	o.returnTree = true;
	o.menuId = this.menuId;
	o.callback = 'onGetMediaFromCategory';
	borg.typo3.pagecontrol.ContentRendering.getMediaFromCategory(o);
}

function onGetMedia(o){
	//mediaObject = o;
	if(o.data.menuId == menuId){
		_root.fileArray = [];
		for(var i=0;i<o.data.length;i++){
			_root.fileArray[i] = parseItem(o.data[i]);
		
		}
		gotoAndStop("player");
		trace(_root.fileArray)
	}
}




function onGetMediaFromCategory(o){

	if(o.data.menuId == menuId){
		fileArray = o.data;
		gotoAndStop("player");		
	}
}


//This function returns the field given in _global[LANGUAGE] if not null, else the 0 one, or else empty string
//You can pass either the attibutes xml object, else any object with lang sub array
function getLanguage(x, field){

	if(x.lang[_global['LANGUAGE']][field]!=null){
		return x.lang[_global['LANGUAGE']][field];
	}else if(x.lang[0][field]!=null){
		return x.lang[0][field];
	
	}else{
	
		return '';
	}
}


function parseItem(x){
	var i = x;
	i['title'] = getLanguage(x, 'title');
	i['description'] = getLanguage(x, 'description');
	i['author'] = x['creator'];
	i['guid'] = i['id'] = x['uid'];
	i['file'] = _global['HOST_URL'] +  x['lang'][0]['file_path'] + x['lang'][0]['file_name'];
	if(x['lang'][0]['file_dl_name'].length > 0){ 
		i['link'] = i['file'];
	}else{
		i['link'] = null;
	}
	return i;

}