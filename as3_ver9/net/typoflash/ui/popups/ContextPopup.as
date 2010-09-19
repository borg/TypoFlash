/*
ContextPopup
net.typoflash, 2005


*/


import mx.data.binding.ObjectDumper;
import mx.controls.TextArea;
import mx.controls.ComboBox;
import net.typoflash.ui.Controls;
import net.typoflash.managers.DepthManager;
import mx.events.EventDispatcher;

class net.typoflash.ui.popups.ContextPopup extends MovieClip{
	var killMouseLayer,bg,shadow:MovieClip;
	
	function ContextPopup(){
		
		
		//Put an invisible btn to cover all bg to capture mouse action
		var k = this.killMouseLayer = DepthManager.mouse_capture_mc.createEmptyMovieClip("killMouseLayer",DepthManager.getNextDepth())
		k.beginFill (0xFFFFFF,0);
		k.lineStyle (0, 0xFF00FF, 0);
		k.moveTo (0, 0);
		k.lineTo (Stage.width, 0);
		k.lineTo (Stage.width, Stage.height);
		k.lineTo (0, Stage.height);
		k.endFill();
		k.parent = this;
	
		k.onPress =function(){
			this.parent.close();
			
		}
		bg.onPress = function(){
			//Steal from kill mouse
		}
		bg.useHandCursor  = k.useHandCursor = false;
		delete k;

	}
	
	function close() {
		this.killMouseLayer.removeMovieClip();
		this.removeMovieClip();
	};

	function setSize(w,h){
		bg._height = h;
		shadow._height =  h + 5;
		bg._width = w;
		shadow._width =  w + 10;
	}
	
}