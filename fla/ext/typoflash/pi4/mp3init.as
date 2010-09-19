//import net.typoflash.utils.Debug;
import net.typoflash.Glue;
import com.jeroenwijering.players.MP3Player;

import net.typoflash.components.StandAloneInit;


var i = new StandAloneInit();




stop();
/*

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

*/
var configArray = {};
//configArray.media = MEDIA;

//configArray.width=WIDTH
//configArray.height=HEIGHT
configArray.autostart= Boolean(AUTOSTART == '1');
configArray.shuffle =  Boolean(SHUFFLE == '1');
configArray.repeat =  Boolean(REPEAT == '1');
configArray.backcolor = BACKCOLOR
configArray.frontcolor= FRONTCOLOR
configArray.lightcolor = LIGHTCOLOR
configArray.displayheight = 0
configArray.showicons =   Boolean(SHOWICONS== '1');
configArray.showeq = Boolean(SHOWEQ== '1');
configArray.linkfromdisplay = LINKFROMDISPLAY
configArray.linktarget = LINKTARGET
configArray.showdigits =  Boolean(SHOWDIGITS== '1');
configArray.showfsbutton =   Boolean(SHOWFSBUTTON== '1');
configArray.fullscreenmode =  FULLSCREENMODE;
configArray.fullscreenpage = FULLSCREENPAGE
configArray.fsreturnpage = FSRETURNPAGE
configArray.bufferlength = BUFFERLENGTH
configArray.volume = VOLUME
configArray.autoscroll =  Boolean(AUTOSCROLL== '1');
configArray.thumbsinplaylist =  Boolean(THUMBSINPLAYLIST== '1');
configArray.rotatetime = ROTATETIME
configArray.shownavigation =  SHOWNAVIGATION;
configArray.callback = CALLBACK
configArray.streamscript = STREAMSCRIPT
configArray.enablejs =  ENABLEJS;


if(WIDTH>0){
	configArray.width =WIDTH
}else{
	configArray.width = 200
}

if(HEIGHT>0){
	configArray.height = HEIGHT
}else{
	configArray.height =88
}


bg._width = configArray.height
bg._height = configArray.height
var c = new Color(_root.bg);
c.setRGB(configArray.backcolor);



///////



///////


menuId = "mp3player";


if(_level0.MEDIA != null){
	var o = {};
	o.media = _level0.MEDIA;
	o.callback = 'onGetMedia';
	o.menuId = menuId;
	//o.orderBy='title';
	_global['TF']['CONTENT_RENDERING'].getMedia(o);
	_global['TF']['CONTENT_RENDERING'].addEventListener("onGetMedia",this);

}

if(_level0.MEDIA_CATEGORY != null){
	var o = {};
	o.media_category = _level0.MEDIA_CATEGORY;
	o.returnTree = true;
	o.menuId =  menuId;
	o.callback = 'onGetMediaFromCategory';
	_global['TF']['CONTENT_RENDERING'].getMediaFromCategory(o);
	_global['TF']['CONTENT_RENDERING'].addEventListener("onGetMediaFromCategory",this);
}





// Center activity icon
activity._x = configArray["width"]/2;
activity._y = configArray["height"]/2;




// Start the player
mpl = new MP3Player(player,null,configArray,this);
mpl._visible = false











fileArray = [];

function onGetMedia(o){

	if(!(o.data.media.length>0)){
		return;
	}
	//Debug.trace("MP3 player onGetMedia" )
	//Debug.trace(o.data.mediaRecords)
	
	for(var i=0;i<o.data.media.length;i++){
		if(o.data.media[i]['lang'][0]['file_name'].length>0){
			fileArray.push(parseItem(o.data.media[i]));
		}

	}
	mpl.unload();
	
	mpl.loadFile(fileArray);
	mpl._visible = true;
	
	
}




function onGetMediaFromCategory(o){
	if(!(o.data.flatlist.length>0)){
		return;
	}
	//Debug.trace("MP3 player onGetMediaFromCategory" )
	//Debug.trace(o.data.mediaCategoryFlatlist)

	for(var i=0;i<o.data.flatlist.length;i++){
		if(o.data.flatlist[i]['lang'][0]['file_name'].length>0){
			fileArray.push(parseItem(o.data.flatlist[i]));
		}
	}
	
	mpl.unload();
	mpl.loadFile(fileArray);
	mpl._visible = true;
	
}

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
	i['file'] = _global['TF']['HOST_URL'] +  x['lang'][0]['file_path'] + x['lang'][0]['file_name'];
	if(x['lang'][0]['file_dl_name'].length > 0){ 
		i['link'] = i['file'];
	}else{
		i['link'] = null;
	}
	return i;

}


