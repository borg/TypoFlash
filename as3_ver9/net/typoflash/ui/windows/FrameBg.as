/*******************************************
* Class: FrameBg
*
* Copyright A. net.typoflash, net.typoflash@elevated.to
*
********************************************
* Example usage:
*
*
*
********************************************/
import net.typoflash.ui.Controls;

class net.typoflash.ui.windows.FrameBg extends MovieClip{
	var _targetFrame:String;
	var leftMargin,rightMargin,topMargin,bottomMargin:Number=0;

	function FrameBg() {
		
		
	}
	function onLoad(){
		if(_targetFrame!=null){
			if(typeof(_parent[_targetFrame])=="movieclip"){
				targetFrame= _parent[_targetFrame];
			}else if(typeof(eval(_targetFrame))=="movieclip"){
				targetFrame = eval(_targetFrame);
			}else{
				Controls.debugMsg(_name + " couldn't find its target frame " + _targetFrame)
			}
		
		}else{
			Controls.debugMsg(_name + "hasn't got a target frame set: " + _targetFrame)
		}

		
	}
	function set targetFrame(f){
		f.addEventListener("onResize",this);
		f.addEventListener("onSetWidth",this);
		f.addEventListener("onSetHeight",this);
		f.addEventListener("onSetX",this);
		f.addEventListener("onSetY",this);
		
		/*_y = f._y-topMargin;
		_x = f._x-leftMargin;
		_width = f._width+leftMargin+rightMargin;
		_height = f._height+topMargin+bottomMargin;*/
		Controls.debugMsg("Adding " + _name + " as listener to " + f._name)



	}

	function onResize(o){
		_width = o.width+leftMargin+rightMargin;
		_height = o.height+topMargin+bottomMargin;
		_x = o.x-leftMargin;
		_y = o.y-topMargin;
	}
	
	function onSetWidth(o){
		_width = o.width+leftMargin+rightMargin;
	}

	function onSetHeight(o){
		_height = o.height+topMargin+bottomMargin;
	}

	function onSetX(o){
		_x = o.x-leftMargin;
	}

	function onSetY(o){
		_y = o.y-topMargin;
	}


};

