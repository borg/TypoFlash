/*
Class: selectUserBox Box

Author: A. net.typoflash
Email: net.typoflash@elevated.to


Example usage:

var c = info("");
c.accept = function() {
	//to do if accept
	registerUser()
	this.close();
};

delete c;

*/
#initclip 2
InfoBox = function () {
	// need to run super, ie initialise alertBox class for inheritance to work
	//super()
	
};
Object.registerClass("infoBox", InfoBox);
//extend alert box class
var r = InfoBox.prototype = new MovieClip();

r.close = function() {
	this.removeMovieClip();
};

MovieClip.prototype.info = function(msg, accFunc, decFunc){
	var c = _root.main.attachMovie("infoBox", "infoBox" + i, DEPTH["subcontent"]);
	c._x =100;
	c._y = 10;

	c.setMsg(msg);
	if(accFunc!=null){
		c.accept = function(){
			accFunc();
			this.close();
		}
	}
	if(decFunc!=null){
		c.decline = function(){
			decFunc();
			this.close();
		}
	}
	//return reference to this box
	return c;
	delete c,i;
}

delete r;

#endinitclip

//Runtime init
//txt.setTextFormat(globalTextFormat);
stop();

//Should not be draggable but should catch all mouse activity
this.bg.onPress = function() {};
this.bg.useHandCursor = 0;
//confirm button
this.registerBtn.label="New game";
this.registerBtn.onRelease = function(){
	//to do if accept
	this.registerUser()
	this._parent.close();
};	
	
if (cookie.data.agent!= null) {
	//been here before
	this.selectBtn.label="Load game";
	this.selectBtn.onRelease = function(){
		//to do if accept
		this.selectUser();
		this._parent.close();
	};
}else{
		this.selectBtn._visible=0;
}
	


