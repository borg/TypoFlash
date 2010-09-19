/*
*****************************
Form
******************************
Andreas net.typoflash
(C) Elevated Ltd
2005
******************************

Each form element has properties:
-label
-name
-value
-type (you can pass any class in as form element type as long as it implements the iFormElement interface)
-initObj (optional properties to send to class init function




import net.typoflash.ui.forms.*;
import net.typoflash.managers.DepthManager;
import fl.containers.ScrollPane
DepthManager.init(this);

var formElement = [];
formElement.push({label:"Root page",name:"rootPid",value:1,type:FormInput,initObj:{obligatory:"*"}});
formElement.push({label:"Target",name:"target",value:"target",type:FormTextArea,initObj:{obligatory:"*"}});
//formElement.push({label:"Name",value:1,name:"name",type:FormComboBox ,initObj:{ dataProvider : [{label:"Pending", data : 0},{label:"Open", data : 1},{label: "Done", data : 2},{label: "Cancelled", data : 3}]}});
formElement.push({label:"Priority",name:"priority",value:0,type:FormComboBox , initObj:{dataProvider : [{label:"Low", data : 0},{label:"Normal", data : 1},{label: "High", data : 2}]}});
formElement.push({label:"FormLinkTable",name:"dbllist",value:"2,1",type:FormDoubleList , initObj:{dataProvider : [{label:"Pending", data : 0},{label:"Open", data : 1},{label: "Done", data : 2},{label: "Cancelled", data : 3},{label: "Cancelled", data : 6},{label: "Cancelled", data : 7},{label: "Cancelled", data : 8},{label: "Cancelled", data : 9}]}});
formElement.push({label:"Status",name:"sgl_list",value:"2",type:FormList , initObj:{dataProvider : [{label:"Pending", data : 0},{label:"Open", data : 1},{label: "Done", data : 2},{label: "Cancelled", data : 3}]}});

formElement.push({label:"Gender",name:"gender",value:1,type:FormRadioButton , initObj:{dataProvider : [{label:"Male", data : 0},{label:"Female", data : 1}]}});
formElement.push({label:"Is private?",name:"isprivate",value:true,type:FormCheckBox});
formElement.push({name:"pid",value:23,type:"hidden"});
formElement.push({name:"uid",value:11,type:"hidden"});

var form = new Form()

form.dataProvider=formElement;
sp.source = form

import fl.controls.Button;
import fl.events.ComponentEvent;
btn.addEventListener(ComponentEvent.BUTTON_DOWN, buttonDownHandler);

function buttonDownHandler(e){
	form.traceForm()
}

form.addEventListener(FormEvent.CHANGED, changeHandler);
function changeHandler(e){
			trace("Form changed. " +e.data.name + " " + e.data.value)
		}

Todo: 
-Tooltip integration
-Global styles
-Enable / hide all fields via broadcaster
-add colour selector, date selector, file upload
-support for wizards
-validation
-resizing and individual textfield size
-get/set individual form values/states/options from outside
-make form catch check and radio button changes before broadcasted to outside change handlers
so as to update internal formvars if external listener wants to modify form ->redraw whole form
-catch textfield chagnes and update formvars

******************************/

package net.typoflash.ui.forms{
	import net.typoflash.ui.forms.FormEvent;
	import net.typoflash.ui.Controls;
	import flash.display.Sprite;
	import fl.data.DataProvider;
	import flash.utils.*;

	public class Form extends Sprite{
		var formElements:Array=[],formVars:Array;//formVars are the variables, and elements are the same with appended mc reference
		var formObjects:Object;//An associative array to access elements by name
		var rowSpacing:int,currY:int,h:int;
		var submitUrl:String;
		var callback:Function;
		var submitObj:Object;
		var submitFunc:String;
		var method:String = "POST";
		var holder:Sprite;
		var focusBackgroundColour, focusBorderColour,focusTextColour,blurBackgroundColour, blurBorderColour,blurTextColour,backgroundColour,borderColour,textColour:Number;
		var _editable:Boolean=true;
		var _enabled:Boolean = true;
		var leftMargin:int;


		public function Form(){
			
			rowSpacing = 0;
			h=0;
			leftMargin = 0;
			if(focusBackgroundColour ==null){
				focusBackgroundColour = 0xFFFFFF;
			}
			if(focusBorderColour ==null){
				focusBorderColour = 0x33CC00;//green
			}
			if(focusTextColour ==null){
				focusTextColour = 0x000000;//
			}
			if(blurBackgroundColour ==null){
				blurBackgroundColour = 0xFFFFFF;
			}
			if(blurBorderColour ==null){
				blurBorderColour = 0x999999;//gray
			}
			if(blurTextColour ==null){
				blurTextColour = 0x333333;//gray
			}
			
			x = Math.round(x)
			y = Math.round(y)
		
			//date embed fonts
			

			/*setStyle("styleName", "newStyle");
			global.style.setStyle("fontFamily" , "fontbody");
			global.style.setStyle("embedFonts" , "true");
			global.style.setStyle("selectionColour" , "0xCADADF");//light blue



			global.styles.HeaderDateText.setStyle("Colour", 0x660000);
			global.styles.HeaderDateText.setStyle("fontFamily" , "fontheader");
			global.styles.WeekDayStyle.setStyle("Colour", 0x33CC00);
			global.styles.WeekDayStyle.setStyle("fontFamily", "fontbody");
			//global.styles.TodayStyle.setStyle("Colour", 0x660000);
			global.styles.WeekDayStyle.setStyle("fontFamily", "fontbody");
			*/






			
			

		}	
		/*
		Public methods
		*/
		
		public function set dataProvider(d){
			if(d is DataProvider){
				d = d.toArray();
			}

			if(d == null){
				Controls.debugMsg("Form got empty dataprovider")
			}else{
				setFormElements(d) ;
			}
			

		}
		public function get dataProvider(){
			return new DataProvider(getValues());
			

		}
		 public function setFormElements(f){
			h++;
			try{
				removeChild(holder)
			}
			catch(err){}

			holder = new Sprite();
			addChild(holder);

			formObjects = {};
			formVars = f;//Store originals
			
			currY = 0;
			var el ,oldEl;
			//Loop through all the elements in the array
			for (var i=0;i<f.length;i++) {

				if(f[i]["type"] ==null){
					//default textfield
					f[i]["type"] = FormInput;
				}

				if(f[i]["type"] is Class){
					

					
					f[i]["element"] = el = new f[i]["type"]()
					
					el.label = f[i]["label"];
					el.y = currY;
					currY += Math.round(el.bg.height+rowSpacing);
					el.x = leftMargin;
					el.addEventListener(FormEvent.CHANGED, changeHandler);
					
					el.backgroundColour =el.blurBackgroundColour = blurBackgroundColour;
					el.borderColour = el.blurBorderColour = blurBorderColour;
					el.textColour = el.blurTextColour = blurTextColour;
					

					el.focusBackgroundColour = focusBackgroundColour;
					el.focusBorderColour = focusBorderColour;
					el.focusTextColour = focusTextColour;	
					
				

				}else if(f[i]["type"] == "hidden"){
					//is hidden, lets not overwrite previous member
					f[i]["element"] = el = new FormElement();
					
				}else{
					Controls.debugMsg("Form error: Variable neither Class nor hidden.")
				}


				
				if(f[i]["initObj"] is Object){
					el.init(f[i]["initObj"])
				}


				el.name = f[i]["name"];
				el.value = f[i]["value"];
				
				
				
				//add to associative array
				formObjects[f[i]["name"]] = f[i];
				formObjects[f[i]["name"]]["id"] = i;
				holder.addChild(el);
			}
			
			
			//submitBtn.y = Math.round(currY+rowSpacing + 40);
			/*bg.height = Math.round(submitBtn.y+submitBtn.height + 40);
			bg.width = width + 10;
			submitBtn.x= Math.round(bg.width - submitBtn.width-10);*/
			setSize(width+10, Math.round(currY+rowSpacing ));
			//parent.setSize(width+10, Math.round(currY+rowSpacing + 40));
			

			/*
			Store all elements in internal array with their mc references
			*/

			formElements = f;

		
		}

		public function setSize(w,h){
			
			try{
			var f = formElements;
				
				for (var i=0;i<f.length;i++) {
					f[i]["element"].setSize(w,h);
		
				}
			}
			catch(err){}

			//width = w;
			//height =h;
		}
		public function setWidth(w){
			width = w;
		}
		function onResize(e){
			//trace("Form is resized")
		}

		
		function changeHandler(e:FormEvent){

			//trace(e.data.name + " : " + e.data.value)
			//this is not good...cause some element events bubble up...need to filter them out else two events coming
			//dispatchEvent(e);
		}
		
		/*
		This has been updated so that getValue and setValue can be used across all elements. Only it hasn't been tested yet.
		14 March 2006
		*/

		public function setValue(name,value){
			var f = formObjects;
			if(f[name]!=null){
				f[name]["element"].value = value;	
			
			}else{
				//Controls.debugMsg(this + " got a value "+value + " for a variable (" + name + ") that doesn't exist");
			}
		}
		
		public function getField(name){
			return formObjects[name]["element"];	
			
		}

		public function set data(d){
			
			for(var n in d){
				setValue(n,d[n])
			}
		}
		public function getValue(name){
		
			return getValues()[name];
		}

		public function move(nx,ny){
			x = nx
			y = ny
		}
			

		public function getValues() {
			var l = {};
			var f = formElements;
			
			// extract name values out of formElements, note that a mc reference was created before
			for (var i=0;i<f.length;i++) {
				l[f[i]["name"]] = f[i]["element"].value;
	
			}
			
	
			return l;
		};

		public function traceForm(){
			Controls.debugMsg("________________________________________")
			Controls.debugMsg("Form values")
			Controls.debugMsg("________________________________________")
			Controls.debugMsg(getValues())
			Controls.debugMsg("________________________________________")
		}

	




		public function addFormVars(f){
			for(var i=0;i<f.length;i++){
				if(formObjects[f[i]["name"]] == null ){
					//new one
					formVars.push(f[i]);
				}else{
					//update old one
					formVars[formObjects[f[i]["name"]]["id"]]= f[i];
				}
			}
			//var f2 = formElements.concat(f);
			setFormElements(formVars);
		}
		
		/*
		Accepts both an array with variable names or array with object with name as property
		*/

		public function removeFormVars(f){
			var fn;
			for(var i=0;i<f.length;i++){
				if(f[i]["name"]==null){
					fn = f[i];
				}else{
					fn = f[i]["name"];
				}
				if(formObjects[fn] !=null ){
					//formElements.splice(formObjects[f[i]["name"]]["id"], 1);//splice should work but breaks the iteration for some reason?!
					formObjects[fn] = null;
				}
			}
			var temp = [];
			for(var n in formObjects){
				temp[formObjects[n]["id"]] = formObjects[n];
				
			
			}
			var temp2 = [];
			for (var ii=0;ii<temp.length;ii++ ){
				temp[ii]["element"] = null;
				if(temp[ii] != null){
					temp2.push(temp[ii]);
				}
			}

		
			setFormElements(temp2);

		}


		//not implemented yet

		public function set editable(s:Boolean){
			_editable = s

			var f = formElements;
			
			// extract name values out of formElements, note that a mc reference was created before
			for (var i=0;i<f.length;i++) {
				try{
					f[i]["element"].editable = s;
				}
				catch(err){
				//trace(f[i]["element"] +" has no editble")
				}
	
			}

		}
		public function get editable():Boolean{
			return _editable;
		}
		public function set enabled(s){
			var f = formElements;
			
			// extract name values out of formElements, note that a mc reference was created before
			for (var i=0;i<f.length;i++) {
				try{
					f[i]["element"].enabled = s;
				}
				catch(err){
				//trace(f[i]["element"] +" has no editble")
				}
	
			}
			
			_enabled = s;
		}


		public function get enabled(){
			return _enabled;
		}		
	}

}


