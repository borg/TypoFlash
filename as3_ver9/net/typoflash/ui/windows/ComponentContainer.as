/*
Class: ComponentContainer
Author: A. net.typoflash
Email: net.typoflash@elevated.to


Public events


*/

import net.typoflash.managers.DepthManager;
import mx.events.EventDispatcher;
import net.typoflash.ui.Controls;
import mx.data.binding.ObjectDumper;
//import net.typoflash.managers.FrameManager;
import net.typoflash.typo3.pagecontrol.ContentRendering;
import net.typoflash.typo3.pagecontrol.ContentEditing;
//import mx.containers.ScrollPane;
import net.typoflash.managers.QueueLoader;
import flash.filters.BlurFilter;
import mx.transitions.Tween; 
import mx.transitions.easing.*;
import net.typoflash.managers.CoreEvents;

class net.typoflash.ui.windows.ComponentContainer  extends net.typoflash.typo3.typoflash.ComponentBase implements net.typoflash.typo3.typoflash.IComponentInterface{

	
	var bg:MovieClip;


	var depth:Number = 1000000;
	var components:Array;
	var hidden:Boolean;
	var bId:String="TemplateObject";
	var cId:String="ComponentContainer";

	function ComponentContainer (){
		
		components = [];


	}
	
	function init(){
		orgW = width = Math.round(bg._width);
		orgH = height = Math.round(bg._height);
		setSize(orgW,orgH);
	}




	function refresh(){
		sequentialXYresize(_x,_y,this.bg._width,this.bg._height)

	}


	function setSize(w,h){
		h = Math.round(h);
		w = Math.round(w);
		this.bg._height = h;
		this.bg._y = 0;			
		
		this.bg._width = w;
		width= w;
		height = h;

		var o = {};
		o.type = "onResize";
		o.target = this;
		o.width = w;
		o.height = h;
		dispatchEvent(o);

	}	


	/*
	Returns an array of all configuration variables for this component that should be editable
	*/
	
	function getConfVars():Array{
		var l = net.typoflash.typo3.pagecontrol.LocalLang.global;
		var formElement = [];
		formElement.push({label:l.getLang("Frame_x","x position"),name:"x",value:x,type:"input",width:40,restrict:"0-9\\-",tooltip:l.getLang("Frame_x_tooltip","x position of frame")});
		formElement.push({label:l.getLang("Frame_y","y position"),name:"y",value:y,type:"input",width:40,restrict:"0-9\\-",tooltip:l.getLang("Frame_y_tooltip","y position of frame")});
		formElement.push({label:l.getLang("Frame_w","width"),name:"width",value:width,type:"input",width:40,restrict:"0-9\\-",tooltip:l.getLang("Frame_w_tooltip","Width of frame")});
		formElement.push({label:l.getLang("Frame_h","height"),name:"height",value:height,type:"input",width:40,restrict:"0-9\\-",tooltip:l.getLang("Frame_h_tooltip","Height of frame")});
		return formElement;
	}

	function registerComponent(mc){
		//Controls.debugMsg("registerComponent for " + this + " " + mc)
		components.push(mc);
	}

	function onSequentialXYresizeChange(){
		if(introDependent && !introComplete && components.length>0 && !hidden){
			for (var i=0;i<components.length ; i++){
				components[i]._visible=false;
				
			}
			hidden = true;

		}
		//Controls.debugMsg("onSequentialXYresizeChange for " +this + " introDependent " + introDependent)
	}

	function onSequentialXYresizeComplete(){
		if(!introComplete){
			introComplete = true;
			for (var i=0;i<components.length ; i++){
				components[i]._visible=true;
				
			}
			hidden = false;
		}
	}

}