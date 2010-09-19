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

	public  interface iFormElement{
		
		function init(o:Object):void;
		function set value(s):void;
		function get value():*;


		function setSize(w,h):void;

		function set enabled(s:Boolean):void;
		function get enabled():Boolean;

		function set label(s:String):void;
		function get label():String;
	}
}