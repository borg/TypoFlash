/*
bFileMenu Class

Copyright Andreas net.typoflash 2007
net.typoflash@elevated.to


*/

package net.typoflash.ui.forms{

	import net.typoflash.ui.Controls;
	import net.typoflash.ui.components.bButton;
	import net.typoflash.ui.components.bListItem;
	import net.typoflash.managers.DepthManager;
	import fl.data.DataProvider;
	
	import flash.display.*;

	import net.typoflash.ui.forms.FormEvent;
	
	import fl.controls.Label;
	import fl.events.ComponentEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;


	import fl.controls.TextInput;
	import flash.text.*;

	public class FormElement extends Sprite implements iFormElement{
		//var w:int;//temp
		//var h:int;//temp_
		
		//var _dataProvider:DataProvider;
		

		var _value:*;
		var _backgroundColour 
		var _blurBackgroundColour;
		var _borderColour;
		var _textColour;
				
		var _blurBorderColour;
		var _focusBackgroundColour;
		var _focusBorderColour;
		var _focusTextColour;
		var _blurTextColour;
		var _enabled:Boolean=true;
		var _editable:Boolean=true;//if not editable cannot be enabled
		
		var hint:String;
		

		public var handCursor:Boolean=true;
		
		
		public function FormElement(){
	

		}
		public function init(o:Object):void{
	
			for(var n in o){
				this[n] = o[n]
			}
			this["_label"].autoSize = TextFieldAutoSize.LEFT;
		}

		public function set value(s):void{
			_value = s;
		}
		public function get value(){
			return _value;
		}

		public function set backgroundColour (s){
			_backgroundColour  = s;
		}
		public function get backgroundColour (){
			return _backgroundColour ;
		}

		public function set blurBackgroundColour (s){
			_blurBackgroundColour  = s;
		}
		public function get blurBackgroundColour (){
			return _blurBackgroundColour ;
		}

		public function set blurBorderColour (s){
			_blurBorderColour  = s;
		}
		public function get blurBorderColour (){
			return _blurBorderColour;
		}

		public function set borderColour (s){
			_borderColour  = s;
		}
		public function get borderColour (){
			return _borderColour ;
		}
		public function set textColour (s){
			_textColour  = s;
		}
		public function get textColour (){
			return _textColour ;
		}


		public function set focusBackgroundColour (s){
			_focusBackgroundColour  = s;
		}
		public function get focusBackgroundColour (){
			return _focusBackgroundColour ;
		}

				
		public function set focusBorderColour (s){
			_focusBorderColour  = s;
		}
		public function get focusBorderColour (){
			return _focusBorderColour ;
		}

		public function set focusTextColour (s){
			_focusTextColour  = s;
		}
		public function get focusTextColour (){
			return _focusTextColour ;
		}

		public function set blurTextColour (s){
			_blurTextColour  = s;
		}
		public function get blurTextColour (){
			return _blurTextColour ;
		}


		public function setSize(w,h):void{
			this["labelBg"].width = w;
			this["bg"].width = w
		}
		
		
		function changeHandler(event:Event):void {
			
			dispatchEvent(new FormEvent(FormEvent.CHANGED,{name:name,value:value}));
		}
		

		public function set editable(s:Boolean):void{
			_editable = this["field"].enabled = s;
		}
		public function get editable():Boolean{
			return _editable;
		}

		public function set enabled(s:Boolean):void{
			if(_editable){
				_enabled = this["field"].enabled = s;
			}else{
				_enabled = this["field"].enabled = false
			}
			
		}

		public function get enabled():Boolean{
			if(_editable){
				return this["field"].enabled;
			}
			return false;
			
		}



		public function set label(s:String):void{
			this["_label"].text = s;
			
		}
		public function get label():String{
			return this["_label"].text;
		}

		public function set obligatory(s:String){
			this["_obligatory"].text = s
		}
	}
}