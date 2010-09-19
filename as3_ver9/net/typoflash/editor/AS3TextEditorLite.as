to/*

AS3TextEditorLite: Free version of AS3 Text Editor Component for Flash CS3
Developed by MobileWish (www.mobilewish.com)
(c) November 2007
Author: Samir K. Dash <samir@mobilewish.com>

*/
package net.typoflash.editor{

	import fl.core.UIComponent;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.text.*;
	import flash.system.System;
	import fl.events.ScrollEvent;

	import fl.controls.UIScrollBar;


	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.controls.*;
	import fl.data.DataProvider;
	import fl.controls.ColorPicker;

	import fl.events.ColorPickerEvent;


	public class AS3TextEditorLite extends UIComponent {

		private var  selectedFontColor:uint;
		private var  selectedLinkColor:uint;

		private var  HTMLtext:TextField = new TextField();
		private var  isActive:Boolean = true;
		private var  beginIndex:int = 0;
		private var  endIndex:int = 0;
		private var  lastIndexTillSearched:uint;

		private var  isLinkShow:Boolean = true;


		private var  findTxt:TextInput = new TextInput();
		private var  searchString:String = new String();
		private var  initialPoint:Number = new Number();
		private var  finalpoint:Number = new Number();
		private var  clipBoard:String = new String();
		private var  clipboardFmt:TextFormat = new TextFormat();


		private var  rightIndentBut:Button = new Button();
		private var  leftIndentBut:Button = new Button();




		private var  l_button:Button = new Button();



		private var  charBackBut:Button = new Button();
		private var  findNextBut:Button = new Button();
		private var  replaceBut:Button = new Button();
		private var  hyperlink_button:Button = new Button();
		private var  Char1:Button = new Button();
		private var  Char2:Button = new Button();
		private var  Char3:Button = new Button();
		private var  Char4:Button = new Button();
		private var  Char5:Button = new Button();
		private var  Char6:Button = new Button();
		private var  Char7:Button = new Button();
		private var  Char8:Button = new Button();
		private var  Char9:Button = new Button();
		private var  Char10:Button = new Button();
		private var  Char11:Button = new Button();
		private var  Char12:Button = new Button();
		private var  Char13:Button = new Button();
		private var  Char14:Button = new Button();
		private var  Char15:Button = new Button();
		private var  Char16:Button = new Button();
		private var  Char17:Button = new Button();
		private var  Char18:Button = new Button();
		private var  Char19:Button = new Button();
		private var  Char20:Button = new Button();
		private var  bold_button:Button = new Button();
		private var  italic_button:Button = new Button();
		private var  underline_button:Button = new Button();
		private var  sizeUp_button:Button = new Button();
		private var  sizeDown_button:Button = new Button();


		private var  leftAlign_button:Button = new Button();
		private var  centerAlign_button:Button = new Button();
		private var  rightAlign_button:Button = new Button();
		private var  justifiedAlign_button:Button = new Button();
		private var  letterspacing_button:Button = new Button();
		private var  imgAdd_button:Button = new Button();
		private var  formatParagraphBut:Button = new Button();
		private var  paraBackBut:Button = new Button();
		private var  copy_button:Button = new Button();
		private var  cut_button:Button = new Button();
		private var  paste_button:Button = new Button();
		private var  selectall_button:Button = new Button();
		private var  removeformatting_button:Button = new Button();


		private var  linkColorPicker:ColorPicker = new ColorPicker();
		private var  addunderlineTick:CheckBox = new CheckBox();
		private var  changecolorTick:CheckBox = new CheckBox();
		private var  replaceString:String =  new String();
		private var  replaceTxt:TextInput =  new TextInput();
		private var  indStepper:NumericStepper = new NumericStepper();
		private var  lineStepper:NumericStepper = new NumericStepper();
		private var  lMarginStepper:NumericStepper = new NumericStepper();
		private var  rMarginStepper:NumericStepper = new NumericStepper();
		private var  FindBackground:Button = new Button();
		private var  font_cb:ComboBox = new ComboBox();
		private var  size_cb:ComboBox = new ComboBox();

		private var  window_cb:ComboBox = new ComboBox();
		private var  viewHTML:Button = new Button();
		private var  findLabel:TextField = new TextField();
		private var  replaceLabel:TextField = new TextField();
		private var  linkTxt:TextInput = new TextInput();
		private var  hyperlinkActive:Button = new Button();
		private var  findActive:Button = new Button();

		private var  fontColorPicker:ColorPicker = new ColorPicker();

		private var  linkLabel:TextField = new TextField();
		private var  indentLabel:TextField = new TextField();
		private var  lineLabel:TextField = new TextField();
		private var  leftindLabel:TextField = new TextField();
		private var  rightindLabel:TextField = new TextField();
		private var  specialCharBut:Button = new Button();
		private var  scrollTarget:ScrollEvent;
		private var  my_fmt:TextFormat = new TextFormat();


		private  static  var charSpaceBackBut:Button = new Button();
		private  static  var charSpacemaxStepper:NumericStepper = new NumericStepper();
		private  static  var charSpacemaxLabel:TextField = new TextField();
		private  static  var charSpaceminStepper:NumericStepper = new NumericStepper();
		private  static  var charSpaceminLabel:TextField = new TextField();

		private var icon1:MovieClip = new MovieClip();

		private var icon2:MovieClip = new MovieClip();
		private var icon3:MovieClip = new MovieClip();
		private var icon4:MovieClip = new MovieClip();
		private var icon5:MovieClip = new MovieClip();
		private var icon6:MovieClip = new MovieClip();
		private var icon7:MovieClip = new MovieClip();
		private var icon8:MovieClip = new MovieClip();
		private var icon9:MovieClip = new MovieClip();
		private var icon10:MovieClip = new MovieClip();
		private var icon11:MovieClip = new MovieClip();
		private var icon12:MovieClip = new MovieClip();
		private var icon13:MovieClip = new MovieClip();
		private var icon14:MovieClip = new MovieClip();
		private var icon15:MovieClip = new MovieClip();
		private var icon16:MovieClip = new MovieClip();
		private var icon17:MovieClip = new MovieClip();
		private var icon18:MovieClip = new MovieClip();
		private var icon19:MovieClip = new MovieClip();
		private var icon20:MovieClip = new MovieClip();
		private var icon21:MovieClip = new MovieClip();
		private var icon22:MovieClip = new MovieClip();
		private var labeltextformat:TextFormat = new TextFormat();
		
		
			
					private var imgPathTxt:TextInput =  new TextInput();
					private var imgAlignCb:ComboBox = new ComboBox();
					private var imgWidthTxt:TextInput =  new TextInput();
					private var imgHeightTxt:TextInput =  new TextInput();
					private var imgHSNs:NumericStepper = new NumericStepper();
					private var imgVSNs:NumericStepper = new NumericStepper();
					private var imgURLTxt:TextInput =  new TextInput();
					private var imgTargetCb:ComboBox = new ComboBox();
					private var imgBackBt:Button = new Button();
					private var imgBackBG:Button = new Button();
private var imgLabel:TextField = new TextField();
private var imgAlignLabel:TextField = new TextField();
private var imgWidthLabel:TextField = new TextField();
private var imgHeightLabel:TextField = new TextField();
private var imgHSpLabel:TextField = new TextField();
private var imgVSpLabel:TextField = new TextField();
private var imgURLLabel:TextField = new TextField();
private var imgTargetLabel:TextField = new TextField();

		private var imgIDTxt:TextInput = new TextInput();
		private var imgIDLabel:TextField = new TextField();
		private var incId:Number = 0;

		public var input_txt:TextField = new TextField();
		public var scroller:UIScrollBar = new UIScrollBar();








		public function AS3TextEditorLite() {
			super();





            //AddDemo();

			AddingChildren();
			SetElements();
			ShowAllRow();
			//input_txt.addEventListener(MouseEvent.MOUSE_UP, input_txtListener);
			input_txt.addEventListener(MouseEvent.MOUSE_UP, handleClick);







		}




		protected override function configUI():void {

			super.configUI();
		}
		protected override function draw():void {

			//Lastline
			super.draw();
		}
		public override function setSize(w:Number,h:Number):void {

		}
		//All the other methods and properties are component specific







		public function handleClick(e:Event):void {

			var initialPoint:uint = input_txt.selectionBeginIndex;

			////trace(input_txt.selectionEndIndex)
			////trace(input_txt.selectionBeginIndex)
			////trace("initialPoint: "+initialPoint)
			if ((input_txt.selectionEndIndex - input_txt.selectionBeginIndex) > 0 ) {
				////trace("selected");
				rightIndentBut.enabled = true;
				l_button.enabled = true;
				leftIndentBut.enabled = true;


			} else {
				rightIndentBut.enabled = false;
				l_button.enabled = false;
				leftIndentBut.enabled = false;

			}
		}



     protected function AddDemo():void {
		 
		 var DemoText:TextField = new TextField();
		 addChild(DemoText);
		 var dtextformat:TextFormat = new TextFormat();
		 	dtextformat.font = "Tahoma";
			dtextformat.color = 0xff0000;
			dtextformat.size = 10;
		 
		 
		 
		 	DemoText.x = 5;
			DemoText.y =  22;
			
			DemoText.width = 500;
			DemoText.height = 22;
			DemoText.text = " TypoFlash demo ";
			DemoText.setTextFormat(dtextformat);
			
		 
	 }


		private function AddingChildren():void {



			/*
			input_txt.x=4;
			input_txt.y = 95 ;
			input_txt.width = 502;
			input_txt.height = 285;
			
			addChild(input_txt);*/




			/*
			addChild(scroller);
			scroller.x = 506;
			scroller.y = 95 ;
			scroller.scrollTarget = input_txt;
			scroller.height = input_txt.height;
			*/










			addChild(icon1);
			addChild(icon2);
			addChild(icon3);
			addChild(icon4);
			addChild(icon5);
			addChild(icon6);
			addChild(icon7);
			addChild(icon8);
			addChild(icon9);
			addChild(icon10);
			addChild(icon11);
			addChild(icon12);
			addChild(icon13);
			addChild(icon14);
			addChild(icon15);
			addChild(icon16);
			addChild(icon17);
			addChild(icon18);
			addChild(icon19);
			addChild(icon20);
			addChild(icon21);
			addChild(icon22);





			labeltextformat.font = "Tahoma";
			labeltextformat.color = 0x000000;
			labeltextformat.size = 10;

			
			


			addChild(font_cb);
			font_cb.x = 0;
			font_cb.y = 2 ;
			font_cb.width = 272;
			font_cb.height = 22;


			addChild(size_cb);
			size_cb.x = 275;
			size_cb.y = 2 ;
			size_cb.width = 60;
			size_cb.height = 22;




			addChild(bold_button);
			bold_button.x = 339;
			bold_button.y = 2 ;
			bold_button.width = 29;
			bold_button.height = 22;
			bold_button.label = "";
			bold_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			bold_button.setStyle("icon", Icon14);



			addChild(italic_button);
			italic_button.x = 371;
			italic_button.y = 2 ;
			italic_button.width = 29;
			italic_button.height = 22;
			italic_button.label = "";
			italic_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			italic_button.setStyle("icon", Icon13);





			addChild(underline_button);
			underline_button.x = 402;
			underline_button.y = 2 ;
			underline_button.width = 29;
			underline_button.height = 22;
			underline_button.label = "";
			underline_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			underline_button.setStyle("icon", Icon12);




			addChild(fontColorPicker);
			fontColorPicker.x = 434;
			fontColorPicker.y = 2 ;
			fontColorPicker.width = 24;
			fontColorPicker.height = 24;




			/*
			var sizeUp_button = new Button();
			addChild(sizeUp_button);
			sizeUp_button.x = 402;
			sizeUp_button.y = 2 ;
			sizeUp_button.width = 29;
			sizeUp_button.height = 22;
			*/





			addChild(sizeUp_button);
			sizeUp_button.x = 461;
			sizeUp_button.y = 2 ;
			sizeUp_button.width = 29;
			sizeUp_button.height = 22;
			sizeUp_button.label="";
			sizeUp_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			sizeUp_button.setStyle("icon", Icon17);









			addChild(sizeDown_button);
			sizeDown_button.x = 492;
			sizeDown_button.y = 2 ;
			sizeDown_button.width = 29;
			sizeDown_button.height = 22;
			sizeDown_button.label="";
			sizeDown_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			sizeDown_button.setStyle("icon", Icon18);





			addChild(viewHTML);
			viewHTML.x = 0;
			viewHTML.y = 27 ;
			viewHTML.width = 266.3;
			viewHTML.height = 22;
			viewHTML.label = "< HTML Code >"
			
			
			
			
			
			;
			addChild(hyperlinkActive);
			hyperlinkActive.x = 269;
			hyperlinkActive.y = 27 ;
			hyperlinkActive.width = 125;
			hyperlinkActive.height = 22;
			hyperlinkActive.label = "Open Link Tab";
			hyperlinkActive.labelPlacement = ButtonLabelPlacement.RIGHT;
			hyperlinkActive.setStyle("icon", Icon22);




			addChild(findActive);
			findActive.x = 395;
			findActive.y = 27 ;
			findActive.width = 125;
			findActive.height = 22;
			findActive.label = "Open Find Tab";
			findActive.labelPlacement = ButtonLabelPlacement.RIGHT;
			findActive.setStyle("icon", Icon15);





			addChild(leftIndentBut);
			leftIndentBut.x = 0;
			leftIndentBut.y = 52 ;
			leftIndentBut.width = 29;
			leftIndentBut.height = 22;
			leftIndentBut.label = "";
			leftIndentBut.enabled = false;
			leftIndentBut.labelPlacement = ButtonLabelPlacement.RIGHT;
			leftIndentBut.setStyle("icon", Icon9);






			addChild(rightIndentBut);
			rightIndentBut.x = 32;
			rightIndentBut.y = 52 ;
			rightIndentBut.width = 29;
			rightIndentBut.height = 22;
			rightIndentBut.label = "";
			rightIndentBut.enabled = false;
			rightIndentBut.labelPlacement = ButtonLabelPlacement.RIGHT;
			rightIndentBut.setStyle("icon", Icon8);


			addChild(l_button);
			l_button.x = 62;
			l_button.y = 52 ;
			l_button.width = 29;
			l_button.height = 22;
			l_button.label = "";
			l_button.enabled = false;
			l_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			l_button.setStyle("icon", Icon6);







			addChild(leftAlign_button);
			leftAlign_button.x = 100;
			leftAlign_button.y = 52 ;
			leftAlign_button.width = 29;
			leftAlign_button.height = 22;
			leftAlign_button.label = "";

			leftAlign_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			leftAlign_button.setStyle("icon", Icon1);








			addChild(centerAlign_button);
			centerAlign_button.x = 130;
			centerAlign_button.y = 52 ;
			centerAlign_button.width = 29;
			centerAlign_button.height = 22;
			centerAlign_button.label = "";

			centerAlign_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			centerAlign_button.setStyle("icon", Icon2);




			addChild(rightAlign_button);
			rightAlign_button.x = 160;
			rightAlign_button.y = 52 ;
			rightAlign_button.width = 29;
			rightAlign_button.height = 22;
			rightAlign_button.label = "";

			rightAlign_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			rightAlign_button.setStyle("icon", Icon3);






			addChild(justifiedAlign_button);
			justifiedAlign_button.x = 190;
			justifiedAlign_button.y = 52 ;
			justifiedAlign_button.width = 29;
			justifiedAlign_button.height = 22;
			justifiedAlign_button.label = ""
			;
			justifiedAlign_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			justifiedAlign_button.setStyle("icon", Icon4);








			addChild(cut_button);
			cut_button.x = 236.9;
			cut_button.y = 52 ;
			cut_button.width = 29;
			cut_button.height = 22;
			cut_button.label = "";
			cut_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			cut_button.setStyle("icon", Icon7);



			addChild(copy_button);
			copy_button.x = 267.9;
			copy_button.y = 52 ;
			copy_button.width = 29;
			copy_button.height = 22;
			copy_button.label = "";
			copy_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			copy_button.setStyle("icon", Icon10);



			addChild(paste_button);
			paste_button.x = 297.9;
			paste_button.y = 52 ;
			paste_button.width = 29;
			paste_button.height = 22;
			paste_button.label = "";
			paste_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			paste_button.setStyle("icon", Icon16);







			addChild(selectall_button);
			selectall_button.x = 329.9;
			selectall_button.y = 52 ;
			selectall_button.width = 29;
			selectall_button.height = 22;
			selectall_button.label = "";
			selectall_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			selectall_button.setStyle("icon", Icon11);





			addChild(removeformatting_button);
			removeformatting_button.x = 360.9;
			removeformatting_button.y = 52 ;
			removeformatting_button.width = 29;
			removeformatting_button.height = 22;
			removeformatting_button.label = "";
			removeformatting_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			removeformatting_button.setStyle("icon", Icon21);






			addChild(letterspacing_button);
			letterspacing_button.x = 430.9;
			letterspacing_button.y = 52 ;
			letterspacing_button.width = 29;
			letterspacing_button.height = 22;
			letterspacing_button.label = "";
			letterspacing_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			letterspacing_button.setStyle("icon", Icon19);







			addChild(imgAdd_button);
			imgAdd_button.x = 460.9;
			imgAdd_button.y = 52 ;
			imgAdd_button.width = 29;
			imgAdd_button.height = 22;
			imgAdd_button.label = "";
			imgAdd_button.labelPlacement = ButtonLabelPlacement.RIGHT;
			imgAdd_button.setStyle("icon", Icon20);







			addChild(specialCharBut);
			specialCharBut.x = 491.9;
			specialCharBut.y = 52 ;
			specialCharBut.width = 29;
			specialCharBut.height = 22;
			specialCharBut.label = "§"
			
			
			
			 
			    
			 
			;
			addChild(formatParagraphBut);
			formatParagraphBut.x = 392.9;
			formatParagraphBut.y = 52 ;
			formatParagraphBut.width = 29;
			formatParagraphBut.height = 22;
			formatParagraphBut.label = "¶"
			
			
			
			 ;
			//end of layer 1




			addChild(FindBackground);
			FindBackground.x = 0;
			FindBackground.y = 52 ;
			FindBackground.width = 522;
			FindBackground.height = 30;
			FindBackground.visible = true;
			FindBackground.label = "";
			FindBackground.enabled = false;


			//end of layer 2




			addChild(findLabel);
			findLabel.x = 6;
			findLabel.y = 56 ;
			findLabel.width = 30;
			findLabel.height = 22;
			findLabel.text = "Find";
			findLabel.setTextFormat(labeltextformat);



			addChild(findTxt);
			findTxt.x = 37.5;
			findTxt.y = 56 ;
			findTxt.width = 140;
			findTxt.height = 22;



			addChild(replaceLabel);
			replaceLabel.x = 184;
			replaceLabel.y = 56 ;
			replaceLabel.width = 44;
			replaceLabel.height = 22;
			replaceLabel.text = "Replace";
			replaceLabel.setTextFormat(labeltextformat);



			addChild(replaceTxt);
			replaceTxt.x = 228.5;
			replaceTxt.y = 56 ;
			replaceTxt.width = 140;
			replaceTxt.height = 22;







			addChild(findNextBut);
			findNextBut.x = 378;
			findNextBut.y = 56 ;
			findNextBut.width = 59;
			findNextBut.height = 22;
			findNextBut.label = "Find Next";






			addChild(replaceBut);
			replaceBut.x = 445;
			replaceBut.y = 56 ;
			replaceBut.width = 59;
			replaceBut.height = 22;
			replaceBut.label = "Replace";



			//end of layer 3








			addChild(linkLabel);
			linkLabel.x = 5;
			linkLabel.y = 56 ;
			linkLabel.width = 26;
			linkLabel.height = 22;
			linkLabel.text = "Link";
			linkLabel.setTextFormat(labeltextformat);





			addChild(linkTxt);
			linkTxt.x = 30.5;
			linkTxt.y = 56 ;
			linkTxt.width = 131;
			linkTxt.height = 22;







			addChild(window_cb);
			window_cb.x = 165;
			window_cb.y = 56 ;
			window_cb.width = 77;
			window_cb.height = 22;




			addChild(changecolorTick);
			changecolorTick.x = 240;
			changecolorTick.y = 56 ;
			changecolorTick.width = 100;
			changecolorTick.height = 22;
			changecolorTick.label="Change Color";
			changecolorTick.enabled = true;






			addChild(linkColorPicker);
			linkColorPicker.x = 341;
			linkColorPicker.y = 56 ;
			linkColorPicker.width = 24;
			linkColorPicker.height = 22;
			//linkColorPicker.enabled = false;



			addChild(addunderlineTick);
			addunderlineTick.x = 366.6;
			addunderlineTick.y = 56 ;
			addunderlineTick.width = 100;
			addunderlineTick.height = 22;
			addunderlineTick.label="Add Underline";
			addunderlineTick.enabled = true;






			addChild(hyperlink_button);
			hyperlink_button.x = 485;
			hyperlink_button.y = 56 ;
			hyperlink_button.width = 30;
			hyperlink_button.height = 22;
			hyperlink_button.label = "<>"
			
			
			 
			
			
			
			 
			 
			 ;
			//end of layer 4




			addChild(Char1);
			Char1.x = 7;
			Char1.y = 56 ;
			Char1.width = 22;
			Char1.height = 22;
			Char1.label = "€"
			
			  
			   
			
			;
			addChild(Char2);
			Char2.x = 30;
			Char2.y = 56 ;
			Char2.width = 22;
			Char2.height = 22;
			Char2.label = "©"
			
			
			;
			addChild(Char3);
			Char3.x = 53;
			Char3.y = 56 ;
			Char3.width = 22;
			Char3.height = 22;
			Char3.label = "®"
			
			  
			 
			 
			;
			addChild(Char4);
			Char4.x = 76;
			Char4.y = 56 ;
			Char4.width = 22;
			Char4.height = 22;
			Char4.label = "£"
			
			  
			 
			  ;
			addChild(Char5);
			Char5.x = 99;
			Char5.y = 56 ;
			Char5.width = 22;
			Char5.height = 22;
			Char5.label = "¢"
			
			  
			 
			  ;
			addChild(Char6);
			Char6.x = 122;
			Char6.y = 56 ;
			Char6.width = 22;
			Char6.height = 22;
			Char6.label = "«"
			
			   
			 ;
			addChild(Char7);
			Char7.x = 146;
			Char7.y = 56 ;
			Char7.width = 22;
			Char7.height = 22;
			Char7.label = "»"
			;
			addChild(Char8);
			Char8.x = 170 ;
			Char8.y = 56 ;
			Char8.width = 22;
			Char8.height = 22;
			Char8.label = "¦"
			
			    
			 ;
			addChild(Char9);
			Char9.x =  193;
			Char9.y = 56 ;
			Char9.width = 22;
			Char9.height = 22;
			Char9.label = "¤"
			
			    
			;
			addChild(Char10);
			Char10.x = 216;
			Char10.y = 56 ;
			Char10.width = 22;
			Char10.height = 22;
			Char10.label = "¶"
			
			    
			 
			    
			;
			addChild(Char11);
			Char11.x = 239 ;
			Char11.y = 56 ;
			Char11.width = 22;
			Char11.height = 22;
			Char11.label = "¯"
			
			    
			 
			 
			 ;
			addChild(Char12);
			Char12.x = 262 ;
			Char12.y = 56 ;
			Char12.width = 22;
			Char12.height = 22;
			Char12.label = "°"
			
			    
			;
			addChild(Char13);
			Char13.x = 285 ;
			Char13.y = 56 ;
			Char13.width = 22;
			Char13.height = 22;
			Char13.label = "±"
			
			    
			   ;
			addChild(Char14);
			Char14.x = 308 ;
			Char14.y = 56 ;
			Char14.width = 22;
			Char14.height = 22;
			Char14.label = "²"
			
			    
			;
			addChild(Char15);
			Char15.x =  332;
			Char15.y = 56 ;
			Char15.width = 22;
			Char15.height = 22;
			Char15.label = "³"
			
			    
			   ;
			addChild(Char16);
			Char16.x = 355 ;
			Char16.y = 56 ;
			Char16.width = 22;
			Char16.height = 22;
			Char16.label = "Þ"
			
			    
			  ;
			addChild(Char17);
			Char17.x =  379;
			Char17.y = 56 ;
			Char17.width = 22;
			Char17.height = 22;
			Char17.label = "µ"
			
			    
			  ;
			addChild(Char18);
			Char18.x = 402 ;
			Char18.y = 56 ;
			Char18.width = 22;
			Char18.height = 22;
			Char18.label = "ß"
			
			    
			 
			  ;
			addChild(Char19);
			Char19.x = 425 ;
			Char19.y = 56 ;
			Char19.width = 22;
			Char19.height = 22;
			Char19.label = "Ø"
			
			    
			 
			  ;
			addChild(Char20);
			Char20.x = 448 ;
			Char20.y = 56 ;
			Char20.width = 22;
			Char20.height = 22;
			Char20.label = "§"
			
			    
			  ;
			addChild(charBackBut);
			charBackBut.x = 475 ;
			charBackBut.y = 56 ;
			charBackBut.width = 39;
			charBackBut.height = 22;
			charBackBut.label = "Back"
			
			    
			 ;
			//end of layer 5










			addChild(indentLabel);
			indentLabel.x = 5;
			indentLabel.y = 56 ;
			indentLabel.width = 41;
			indentLabel.height = 22;
			indentLabel.text = "Indent";
			//indentLabel.embedFonts = true;
			//indentLabel.defaultTextFormat = labeltextformat;
			indentLabel.setTextFormat(labeltextformat);






			indStepper.x = 41;
			indStepper.y = 56 ;
			indStepper.width = 50;
			indStepper.height = 22;
			indStepper.stepSize = 1;
			indStepper.minimum = 0;
			indStepper.maximum = 1200;
			indStepper.value = 0;
			addChild(indStepper);




			addChild(lineLabel);
			lineLabel.x = 101;
			lineLabel.y = 56 ;
			lineLabel.width = 70;
			lineLabel.height = 22;
			lineLabel.text = "Line Spacing";
			lineLabel.setTextFormat(labeltextformat);




			lineStepper.x = 166;
			lineStepper.y = 56 ;
			lineStepper.width = 50;
			lineStepper.height = 22;
			lineStepper.stepSize = 1;
			lineStepper.minimum = 0;
			lineStepper.maximum = 1200;
			lineStepper.value = 2;
			addChild(lineStepper);







			addChild(leftindLabel);
			leftindLabel.x = 225;
			leftindLabel.y = 56 ;
			leftindLabel.width = 65;
			leftindLabel.height = 22;
			leftindLabel.text = "Left Margin";
			leftindLabel.setTextFormat(labeltextformat);



			lMarginStepper.x = 287;
			lMarginStepper.y = 56 ;
			lMarginStepper.width = 50;
			lMarginStepper.height = 22;
			lMarginStepper.stepSize = 1;
			lMarginStepper.minimum = 0;
			lMarginStepper.maximum = 1200;
			lMarginStepper.value = 0;
			addChild(lMarginStepper);









			addChild(rightindLabel);
			rightindLabel.x = 343;
			rightindLabel.y = 56 ;
			rightindLabel.width = 72;
			rightindLabel.height = 22;
			rightindLabel.text = "Right Margin";
			rightindLabel.setTextFormat(labeltextformat);



			rMarginStepper.x = 414;
			rMarginStepper.y = 56 ;
			rMarginStepper.width = 50;
			rMarginStepper.height = 22;

			rMarginStepper.stepSize = 1;
			rMarginStepper.minimum = 0;
			rMarginStepper.maximum = 1200;
			rMarginStepper.value = 0;
			addChild(rMarginStepper);







			addChild(paraBackBut);
			paraBackBut.x = 475 ;
			paraBackBut.y = 56 ;
			paraBackBut.width = 39;
			paraBackBut.height = 22;
			paraBackBut.label = "Back"
			
			
			  
			 ;
			//end of layer 6




			addChild(charSpaceminLabel);
			charSpaceminLabel.x = 5;
			charSpaceminLabel.y = 56 ;
			charSpaceminLabel.width = 150;
			
			charSpaceminLabel.height = 22;
			charSpaceminLabel.text = "Change Character Spacing";
			//charSpaceminLabel.embedFonts = true;
			//charSpaceminLabel.defaultTextFormat = labeltextformat;
			charSpaceminLabel.setTextFormat(labeltextformat);





			addChild(charSpaceminStepper);
			charSpaceminStepper.x = 150;
			charSpaceminStepper.y = 56 ;
			charSpaceminStepper.width = 50;
			charSpaceminStepper.height = 22;
			charSpaceminStepper.stepSize = 1;
			charSpaceminStepper.minimum = 0;
			charSpaceminStepper.maximum = 100;
			charSpaceminStepper.value = 0;





///*addChild(charSpacemaxLabel);
//			charSpacemaxLabel.x = 160;
//			charSpacemaxLabel.y = 56 ;
//			charSpacemaxLabel.width = 85;
//			charSpacemaxLabel.height = 22;
//			charSpacemaxLabel.text = "Decrease Line Spacing";
//			charSpacemaxLabel.setTextFormat(labeltextformat);
//
//
//
//
//			charSpacemaxStepper.x = 250;
//			charSpacemaxStepper.y = 56 ;
//			charSpacemaxStepper.width = 50;
//			charSpacemaxStepper.height = 22;
//			charSpacemaxStepper.stepSize = 1;
//			charSpacemaxStepper.minimum = 0;
//			charSpacemaxStepper.maximum = 1200;
//			charSpacemaxStepper.value = 1;
//			addChild(charSpacemaxStepper);
//*/



			addChild(charSpaceBackBut);
			charSpaceBackBut.x = 475 ;
			charSpaceBackBut.y = 56 ;
			charSpaceBackBut.width = 39;
			charSpaceBackBut.height = 22;
			charSpaceBackBut.label = "Back"
			
			
			;

			//end of layer 7







addChild(imgBackBG);
imgBackBG.x = 0;
imgBackBG.y = 0 ;
imgBackBG.width = 522;
imgBackBG.height = 80;
imgBackBG.visible = true;
imgBackBG.label = "";
imgBackBG.enabled = false;








//end of layer 8




addChild(imgLabel);
imgLabel.x = 5;
imgLabel.y = 2 ;
imgLabel.width = 104;
imgLabel.height = 22;
imgLabel.text = "Image";
//imgLabel.embedFonts = true;
//imgLabel.defaultTextFormat = labeltextformat;
imgLabel.setTextFormat(labeltextformat);



addChild(imgIDLabel);
imgIDLabel.x = 240;
imgIDLabel.y = 2 ;
imgIDLabel.width = 80;
imgIDLabel.height = 22;
imgIDLabel.text = "ID";
//imgIDLabel.embedFonts = true;
//imgIDLabel.defaultTextFormat = labeltextformat;
imgIDLabel.setTextFormat(labeltextformat);


addChild(imgAlignLabel);
imgAlignLabel.x = 344;
imgAlignLabel.y = 2 ;
imgAlignLabel.width = 104;
imgAlignLabel.height = 22;
imgAlignLabel.text = "Align";
//imgAlignLabel.embedFonts = true;
//imgAlignLabel.defaultTextFormat = labeltextformat;
imgAlignLabel.setTextFormat(labeltextformat);


addChild(imgWidthLabel);
imgWidthLabel.x = 5;
imgWidthLabel.y = 28 ;
imgWidthLabel.width = 104;
imgWidthLabel.height = 22;
imgWidthLabel.text = "Width";
//imgWidthLabel.embedFonts = true;
//imgWidthLabel.defaultTextFormat = labeltextformat;
imgWidthLabel.setTextFormat(labeltextformat);


addChild(imgHeightLabel);
imgHeightLabel.x = 138;
imgHeightLabel.y = 28 ;
imgHeightLabel.width = 104;
imgHeightLabel.height = 22;
imgHeightLabel.text = "Height";
//imgHeightLabel.embedFonts = true;
//imgHeightLabel.defaultTextFormat = labeltextformat;
imgHeightLabel.setTextFormat(labeltextformat);


addChild(imgHSpLabel);
imgHSpLabel.x = 260;
imgHSpLabel.y = 28 ;
imgHSpLabel.width = 104;
imgHSpLabel.height = 22;
imgHSpLabel.text = "H-Space";
//imgHSpLabel.embedFonts = true;
//imgHSpLabel.defaultTextFormat = labeltextformat;
imgHSpLabel.setTextFormat(labeltextformat);


addChild(imgVSpLabel);
imgVSpLabel.x = 378;
imgVSpLabel.y = 28 ;
imgVSpLabel.width = 104;
imgVSpLabel.height = 22;
imgVSpLabel.text = "V-Space";
//imgVSpLabel.embedFonts = true;
//imgVSpLabel.defaultTextFormat = labeltextformat;
imgVSpLabel.setTextFormat(labeltextformat);


addChild(imgURLLabel);
imgURLLabel.x = 5;
imgURLLabel.y = 54 ;
imgURLLabel.width = 104;
imgURLLabel.height = 22;
imgURLLabel.text = "URL";
//imgURLLabel.embedFonts = true;
//imgURLLabel.defaultTextFormat = labeltextformat;
imgURLLabel.setTextFormat(labeltextformat);


addChild(imgTargetLabel);
imgTargetLabel.x = 260;
imgTargetLabel.y = 54 ;
imgTargetLabel.width = 104;
imgTargetLabel.height = 22;
imgTargetLabel.text = "Target";
//imgTargetLabel.embedFonts = true;
//imgTargetLabel.defaultTextFormat = labeltextformat;
imgTargetLabel.setTextFormat(labeltextformat);





addChild(imgPathTxt);
imgPathTxt.x = 60;
imgPathTxt.y = 2 ;
imgPathTxt.width = 170;
imgPathTxt.height = 22;

			
	
addChild(imgIDTxt);
imgIDTxt.x = 260;
imgIDTxt.y = 2 ;
imgIDTxt.width = 80;
imgIDTxt.height = 22;




addChild(imgAlignCb);
imgAlignCb.x = 379;
imgAlignCb.y = 2 ;
imgAlignCb.width = 113;
imgAlignCb.height = 22;

			
			
			
addChild(imgWidthTxt);
imgWidthTxt.x = 58;
imgWidthTxt.y = 28 ;
imgWidthTxt.width = 67;
imgWidthTxt.height = 22;

			
			
addChild(imgHeightTxt);
imgHeightTxt.x = 183;
imgHeightTxt.y = 28 ;
imgHeightTxt.width = 67;
imgHeightTxt.height = 22;

			
			
addChild(imgHSNs);
imgHSNs.x = 308;
imgHSNs.y = 28 ;
imgHSNs.width = 67;
imgHSNs.height = 22;
imgHSNs.stepSize = 1;
imgHSNs.minimum = 0;
imgHSNs.maximum = 1200;
imgHSNs.value = 0;
			

			
			
addChild(imgVSNs);
imgVSNs.x = 428;
imgVSNs.y = 28 ;
imgVSNs.width = 67;
imgVSNs.height = 22;
imgVSNs.stepSize = 1;
imgVSNs.minimum = 0;
imgVSNs.maximum = 1200;
imgVSNs.value = 0;


			
			
addChild(imgURLTxt);
imgURLTxt.x = 60;
imgURLTxt.y = 53 ;
imgURLTxt.width = 190;
imgURLTxt.height = 22;


			
addChild(imgTargetCb);
imgTargetCb.x = 301;
imgTargetCb.y = 53 ;
imgTargetCb.width = 110;
imgTargetCb.height = 22;


			addChild(imgBackBt);
			imgBackBt.x = 420 ;
			imgBackBt.y = 53 ;
			imgBackBt.width = 75;
			imgBackBt.height = 22;
			imgBackBt.label = "Insert Image";



//end of layer 9



		}





private function HideAllRow():void {
	Hide1stRow();
	Hide2ndRow();
	Hide3rdRow();
	imgBackBG.visible = true;
}


private function ShowAllRow():void {
	Show1stRow();
	Show2ndRow();
	Show3rdRow();
	imgBackBG.visible = false;
	HideimgTab();
	
}

private function Hide1stRow():void {
	
font_cb.visible = false;
size_cb.visible = false;
bold_button.visible = false;
italic_button.visible = false;
underline_button.visible = false;
fontColorPicker.visible = false;
sizeUp_button.visible = false;
sizeDown_button.visible = false;
}
private function Show1stRow():void {
font_cb.visible = true;
size_cb.visible = true;
bold_button.visible = true;
italic_button.visible = true;
underline_button.visible = true;
fontColorPicker.visible = true;
sizeUp_button.visible = true;
sizeDown_button.visible = true;
	
}

private function Hide2ndRow():void {
//style_cb.visible = false;
viewHTML.visible = false;
hyperlinkActive.visible = false;
findActive.visible = false;
	
}
private function Show2ndRow():void {
//style_cb.visible = true;
viewHTML.visible = true;
hyperlinkActive.visible = true;
findActive.visible = true;
	
}

private function ShowimgTab():void {
imgPathTxt.visible = true;
imgIDTxt.visible = true;
imgAlignCb.visible = true;
imgWidthTxt.visible = true;
imgHeightTxt.visible = true;
imgHSNs.visible = true;
imgVSNs.visible = true;
imgURLTxt.visible = true;
imgTargetCb.visible = true;
imgBackBt.visible = true;
imgLabel.visible = true;
imgIDLabel.visible = true;
imgAlignLabel.visible = true;
imgWidthLabel.visible = true;
imgHeightLabel.visible = true;
imgHSpLabel.visible = true;
imgVSpLabel.visible = true;
imgURLLabel.visible = true;
imgTargetLabel.visible = true;
imgBackBG.visible = true;

}


private function HideimgTab():void {
imgPathTxt.visible = false;
imgIDTxt.visible = false;
imgAlignCb.visible = false;
imgWidthTxt.visible = false;
imgHeightTxt.visible = false;
imgHSNs.visible = false;
imgVSNs.visible = false;
imgURLTxt.visible = false;
imgTargetCb.visible = false;
imgBackBt.visible = false;
imgLabel.visible = false;
imgIDLabel.visible = false;
imgAlignLabel.visible = false;
imgWidthLabel.visible = false;
imgHeightLabel.visible = false;
imgHSpLabel.visible = false;
imgVSpLabel.visible = false;
imgURLLabel.visible = false;
imgTargetLabel.visible = false;
imgBackBG.visible = false;

}



		private function Hide3rdRow():void {

			leftIndentBut.visible = false;
			rightIndentBut.visible= false;
			l_button.visible= false;
			leftAlign_button.visible= false;
			centerAlign_button.visible= false;
			rightAlign_button.visible= false;
			justifiedAlign_button.visible= false;
			cut_button.visible= false;
			copy_button.visible= false;
			paste_button.visible= false;
			removeformatting_button.visible= false;
			selectall_button.visible= false;
			letterspacing_button.visible= false;
			imgAdd_button.visible= false;
			specialCharBut.visible= false;
			formatParagraphBut.visible= false;


		}

		private function Show3rdRow():void {

			leftIndentBut.visible = true;
			rightIndentBut.visible= true;
			l_button.visible= true;
			leftAlign_button.visible= true;
			centerAlign_button.visible= true;
			rightAlign_button.visible= true;
			justifiedAlign_button.visible= true;
			cut_button.visible= true;
			copy_button.visible= true;
			paste_button.visible= true;
			removeformatting_button.visible= true;
			selectall_button.visible= true;
			letterspacing_button.visible= true;
			imgAdd_button.visible= true;
			specialCharBut.visible= true;
			formatParagraphBut.visible= true;


		}

		private function SetElements():void {

			searchString = findTxt.text;
			replaceString = replaceTxt.text;

			hideChartab();
			hideCharSpacetab();
			SetTextField();
			PopulateDropdown();
			openFindTab();
			hideLinkElements();
			hideParagraphtab();
			EnableListeners();


		}
		private function showCharSpacetab():void {


			charSpaceBackBut.visible = true;
			charSpacemaxStepper.visible =  true;
			charSpacemaxLabel.visible =  true;
			charSpaceminStepper.visible =  true;
			charSpaceminLabel.visible =  true;
			Hide3rdRow();
			FindBackground.visible = true;


		}
		private function hideCharSpacetab():void {


			charSpaceBackBut.visible = false;
			charSpacemaxStepper.visible = false;
			charSpacemaxLabel.visible = false;
			charSpaceminStepper.visible = false;
			charSpaceminLabel.visible = false;
			Show3rdRow();
			FindBackground.visible = false;


		}




		private function hideChartab():void {
			Char1.visible = false;
			Char2.visible = false;
			Char3.visible = false;
			Char4.visible = false;
			Char5.visible = false;
			Char6.visible = false;
			Char7.visible = false;
			Char8.visible = false;
			Char9.visible = false;
			Char10.visible = false;
			Char11.visible = false;
			Char12.visible = false;
			Char13.visible = false;
			Char14.visible = false;
			Char15.visible = false;
			Char16.visible = false;
			Char17.visible = false;
			Char18.visible = false;
			Char19.visible = false;
			Char20.visible = false;
			charBackBut.visible = false;
			FindBackground.visible = false;

		}
		private function showChartab():void {
			Hide3rdRow();
			Char1.visible = true;
			Char2.visible = true;
			Char3.visible = true;
			Char4.visible = true;
			Char5.visible = true;
			Char6.visible = true;
			Char7.visible = true;
			Char8.visible = true;
			Char9.visible = true;
			Char10.visible = true;
			Char11.visible = true;
			Char12.visible = true;
			Char13.visible = true;
			Char14.visible = true;
			Char15.visible = true;
			Char16.visible = true;
			Char17.visible = true;
			Char18.visible = true;
			Char19.visible = true;
			Char20.visible = true;
			charBackBut.visible = true;
			FindBackground.visible = true;
		}
		private function SetTextField():void {

			/* set the text field parameters so that the text field has a border, 
			   word wrap and multiline enabled, and set it to an input text field so users can modify the text. */
			/*input_txt.border = true;
			input_txt.wordWrap = true;
			input_txt.useRichTextClipboard = true;
			input_txt.multiline = true;
			input_txt.type = TextFieldType.INPUT;
			input_txt.background = true;
			input_txt.alwaysShowSelection = true;
			input_txt.backgroundColor = 0xFFFFFF;
			input_txt.doubleClickEnabled = true;*/
			// enter some fake text into the input_txt text field on the Stage.
			//input_txt.htmlText='Enter your text here.';

		}
		private function PopulateDropdown():void {

			// populate the instances on the Stage.
			font_cb.labelField = "fontName";
			font_cb.dropdown.iconField = null;
			font_cb.dataProvider = new DataProvider(Font.enumerateFonts(true).sortOn("fontName"));

			// add a few standard font sizes to the size_cb ComboBox instance.
			size_cb.dataProvider = new DataProvider([8, 10, 12, 14, 16, 20, 24, 32, 36, 48, 64, 96]);


			window_cb.dropdown.iconField = null;
			window_cb.dataProvider = new DataProvider(["_blank", "_self","_parent"]);
			
			
			
			imgAlignCb.dropdown.iconField = null;
			imgAlignCb.dataProvider = new DataProvider(["left", "right"]);
			
			
			imgTargetCb.dropdown.iconField = null;
			imgTargetCb.dataProvider = new DataProvider(["_blank", "_self","_parent"]);


		}
		private function changeFindButtonToggle():void {
			if (isActive == true) {

				isActive = false;
				findActive.label = "Close Find Tab";
				findActive.labelPlacement = ButtonLabelPlacement.RIGHT;
				findActive.setStyle("icon", Icon15);
				hyperlinkActive.enabled = false;
				viewHTML.enabled = false;

			} else {
				isActive = true;
				findActive.label = "Open Find Tab";
				hyperlinkActive.enabled = true;
				viewHTML.enabled = true;
				findActive.labelPlacement = ButtonLabelPlacement.RIGHT;
				findActive.setStyle("icon", Icon15);

			}
		}

		private function displayFindtab():void {

			if (isActive == true) {

				openFindTab();
				Show3rdRow();

			} else {

				closeFindTab();

				Hide3rdRow();
			}
		}

		private function openFindTab():void {

			findNextBut.visible = false;
			replaceBut.visible = false;
			findTxt.visible = false;
			replaceTxt.visible = false;
			FindBackground.visible = false;
			findLabel.visible = false;
			replaceLabel.visible = false;


		}

		private function closeFindTab():void {

			lastIndexTillSearched = 0;
			replaceBut.enabled = false;

			findNextBut.visible = true;
			replaceBut.visible = true;
			findTxt.visible = true;
			replaceTxt.visible = true;
			FindBackground.visible = true;
			//trace(FindBackground.x)
			findLabel.visible = true;
			replaceLabel.visible = true;


		}

		private function displayLinkElements():void {
			Hide3rdRow();
			FindBackground.visible = true;
			linkTxt.visible = true;
			linkLabel.visible = true;
			window_cb.visible = true;
			hyperlink_button.visible = true;
			changecolorTick.visible = true;
			addunderlineTick.visible = true;
			linkColorPicker.visible = true;


		}


		private function hideLinkElements():void {
			Show3rdRow();
			FindBackground.visible = false;
			linkTxt.visible = false;
			linkLabel.visible = false;
			window_cb.visible = false;
			hyperlink_button.visible = false;
			changecolorTick.visible = false;
			addunderlineTick.visible = false;
			linkColorPicker.visible = false;


		}


		private function toggleLinkButton():void {

			if (hyperlinkActive.label == "Open Link Tab") {


				hyperlinkActive.label = "Close Link Tab";


			} else if (hyperlinkActive.label == "Close Link Tab") {
				hyperlinkActive.label = "Open Link Tab";


			}
		}




		private function colorHTML():void {
			var searchString1:String;
			var searchString2:String;
			var lastIndexTillSearched:int = 0;
			initialPoint = 0;
			finalpoint = 0;
			var textLength:uint = input_txt.text.length;

			var i:int = 0;
			searchString1 = "<";
			searchString2 = ">";
			//trace(input_txt.text);


			var colorformat:TextFormat = new TextFormat();
			colorformat.font = "Verdana";
			colorformat.color = 0xff0000;
			colorformat.size = 10;
			colorformat.underline = false;


			do {

				initialPoint = input_txt.text.indexOf(searchString1, lastIndexTillSearched);
				finalpoint = input_txt.text.indexOf(searchString2, lastIndexTillSearched)+1;


				lastIndexTillSearched = finalpoint;
				//trace(initialPoint +"  "+finalpoint+" /"+textLength);

				i = initialPoint;
				//trace("i= "+i);
				if (initialPoint > -1) {
					input_txt.setTextFormat(colorformat, initialPoint, finalpoint);
				}
			} while (i >= 0 && i < textLength );
			initialPoint = input_txt.text.indexOf(searchString1, lastIndexTillSearched);
			finalpoint = input_txt.text.indexOf(searchString2, lastIndexTillSearched);
			lastIndexTillSearched = finalpoint;
			//trace(finalpoint);


		}





		private function hideParagraphtab():void {
			indStepper.visible = false;
			lineStepper.visible = false;
			lMarginStepper.visible = false;
			rMarginStepper.visible = false;
			paraBackBut.visible = false;
			indentLabel.visible = false;
			lineLabel.visible = false;
			leftindLabel.visible = false;
			rightindLabel.visible = false;
			if (FindBackground.visible == true) {
				FindBackground.visible = false;
				Show3rdRow();
			}
		}
		private function showParagraphtab():void {

			indStepper.value = 0;
			lineStepper.value = 2;
			lMarginStepper.value = 0;
			rMarginStepper.value = 0;


			indStepper.visible = true;
			lineStepper.visible = true;
			lMarginStepper.visible = true;
			rMarginStepper.visible = true;
			paraBackBut.visible = true;
			indentLabel.visible = true;
			lineLabel.visible = true;
			leftindLabel.visible = true;
			rightindLabel.visible = true;
			FindBackground.visible = true;
			Hide3rdRow();


		}







		public function EnableListeners():void {




			findActive.addEventListener(MouseEvent.CLICK, findWindowActivatorListener);
			hyperlinkActive.addEventListener(MouseEvent.CLICK, hyperlinkListener);


			addunderlineTick.addEventListener(MouseEvent.CLICK, addunderlineTickHandler);
			changecolorTick.addEventListener(MouseEvent.CLICK, changecolorTickHandler);
			linkColorPicker.addEventListener(ColorPickerEvent.CHANGE, linkColorPickerChangeHandler);


			font_cb.addEventListener(Event.CHANGE, comboBoxChangeListener);
			size_cb.addEventListener(Event.CHANGE, comboBoxChangeListener);
			//window_cb.addEventListener(Event.CHANGE, comboBoxChangeListener);
			bold_button.addEventListener(MouseEvent.CLICK, buttonClickListener);
			underline_button.addEventListener(MouseEvent.CLICK, buttonClickListener);
			hyperlink_button.addEventListener(MouseEvent.CLICK, hyperbuttonClickListener);

			italic_button.addEventListener(MouseEvent.CLICK, buttonClickListener);
			sizeUp_button.addEventListener(MouseEvent.CLICK, buttonClickListener);
			sizeDown_button.addEventListener(MouseEvent.CLICK, buttonClickListener);
			l_button.addEventListener(MouseEvent.CLICK,  buttonClickListener);
			leftIndentBut.addEventListener(MouseEvent.CLICK,  buttonClickListener);
			rightIndentBut.addEventListener(MouseEvent.CLICK,  buttonClickListener);
			leftAlign_button.addEventListener(MouseEvent.CLICK,  buttonClickListener);
			centerAlign_button.addEventListener(MouseEvent.CLICK,  buttonClickListener);
			rightAlign_button.addEventListener(MouseEvent.CLICK,  buttonClickListener);
			justifiedAlign_button.addEventListener(MouseEvent.CLICK,  buttonClickListener);

			imgAdd_button.addEventListener(MouseEvent.CLICK,  imgAdd_buttonListener);
			//color_cb.addEventListener(Event.CHANGE, comboBoxChangeListener);
			fontColorPicker.addEventListener(ColorPickerEvent.CHANGE, colorPickerChangeHandler);
			replaceTxt.addEventListener(Event.CHANGE, updateReplaceTxt);
			replaceBut.addEventListener(MouseEvent.CLICK, replaceListener);
			specialCharBut.addEventListener(MouseEvent.CLICK,  specialCharButListener);
			charBackBut.addEventListener(MouseEvent.CLICK,  charBackButListener);
			viewHTML.addEventListener(MouseEvent.CLICK, viewHTMLListener);
			findTxt.addEventListener(Event.CHANGE, updateFindTxt);
			findNextBut.addEventListener(MouseEvent.CLICK, findNextListener);



			Char1.addEventListener(MouseEvent.CLICK, insertChar);
			Char2.addEventListener(MouseEvent.CLICK, insertChar);
			Char3.addEventListener(MouseEvent.CLICK, insertChar);
			Char4.addEventListener(MouseEvent.CLICK, insertChar);
			Char5.addEventListener(MouseEvent.CLICK, insertChar);
			Char6.addEventListener(MouseEvent.CLICK, insertChar);
			Char7.addEventListener(MouseEvent.CLICK, insertChar);
			Char8.addEventListener(MouseEvent.CLICK, insertChar);
			Char9.addEventListener(MouseEvent.CLICK, insertChar);
			Char10.addEventListener(MouseEvent.CLICK, insertChar);
			Char11.addEventListener(MouseEvent.CLICK, insertChar);
			Char12.addEventListener(MouseEvent.CLICK, insertChar);
			Char13.addEventListener(MouseEvent.CLICK, insertChar);
			Char14.addEventListener(MouseEvent.CLICK, insertChar);
			Char15.addEventListener(MouseEvent.CLICK, insertChar);
			Char16.addEventListener(MouseEvent.CLICK, insertChar);
			Char17.addEventListener(MouseEvent.CLICK, insertChar);
			Char18.addEventListener(MouseEvent.CLICK, insertChar);
			Char19.addEventListener(MouseEvent.CLICK, insertChar);
			Char20.addEventListener(MouseEvent.CLICK, insertChar);

			indStepper.addEventListener(Event.CHANGE, changeOccurredIN);
			lineStepper.addEventListener(Event.CHANGE, changeOccurredLE);
			lMarginStepper.addEventListener(Event.CHANGE, changeOccurredLM);
			rMarginStepper.addEventListener(Event.CHANGE, changeOccurredRM);

			formatParagraphBut.addEventListener(MouseEvent.CLICK, formatParagraphListener);
			paraBackBut.addEventListener(MouseEvent.CLICK, paraBackButListener );


			copy_button.addEventListener(MouseEvent.CLICK, copytoClipboard);
			cut_button.addEventListener(MouseEvent.CLICK, cuttoClipboard);
			paste_button.addEventListener(MouseEvent.CLICK, pastefromClipboard);
			selectall_button.addEventListener(MouseEvent.CLICK, selectAllListener);
			removeformatting_button.addEventListener(MouseEvent.CLICK, removeFormatListener);

			charSpaceminStepper.addEventListener(MouseEvent.CLICK, charSpaceminStepperListener);
			//charSpacemaxStepper.addEventListener(MouseEvent.CLICK, charSpacemaxStepperListener);
			charSpaceBackBut.addEventListener(MouseEvent.CLICK, charSpaceBackButListener);
			letterspacing_button.addEventListener(MouseEvent.CLICK,  letterspacing_buttonListener);
			imgBackBt.addEventListener(MouseEvent.CLICK,  imgBackBtListener);
		}





		//Listener Functions


		private function imgBackBtListener(e:Event):void {
			ShowAllRow();
			
			
			
			//var imageCode:String = "<img src = 'abc.jpg' id='abcd' >";
			if(imgIDTxt.text == ""){
				incId = incId+1;
				imgIDTxt.text = "default_id"+incId;
				
			}
			if(imgPathTxt.text != ""){
			
			input_txt.replaceText (input_txt.selectionBeginIndex, input_txt.selectionEndIndex, '!##'); 
			
			HTMLtext.text = input_txt.htmlText;
			initialPoint = HTMLtext.text.indexOf("!##", 0);
			finalpoint = initialPoint+3;
			if(imgURLTxt == null){
			HTMLtext.replaceText (initialPoint, finalpoint,  "<img src = '"+imgPathTxt.text+"' id='"+imgIDTxt.text+"' align='"+imgAlignCb.value+"' hspace = '"+imgHSNs.value+"' vspace='"+imgVSNs.value+"' width='"+imgWidthTxt.text+"' height='"+imgHeightTxt.text+"'  >");
			}else {
				
			HTMLtext.replaceText (initialPoint, finalpoint,  "<a href='"+imgURLTxt.text+"' target='"+imgTargetCb.value+"' ><img src = '"+imgPathTxt.text+"' id='"+imgIDTxt.text+"' align='"+imgAlignCb.value+"' hspace = '"+imgHSNs.value+"' vspace='"+imgVSNs.value+"' width='"+imgWidthTxt.text+"' height='"+imgHeightTxt.text+"'  ></a>");
	
			}
			//trace("<img src = '"+imgPathTxt.text+"' id='' align='"+imgAlignCb.value+"' hspace = '"+imgHSNs.value+"' vspace='"+imgVSNs.value+"' width='"+imgWidthTxt.text+"' height='"+imgHeightTxt.text+"'  >")
			input_txt.htmlText =  HTMLtext.text;
			} else {
				
				
				
			}
			
			
			
			
			

			
		}
		
		private function imgAdd_buttonListener(e:Event):void {
			imgIDTxt.text = "";
			HideAllRow();
			ShowimgTab();
			
		}
		

		private function letterspacing_buttonListener(e:Event):void {

			showCharSpacetab();
		}
		private function charSpaceBackButListener(e:Event):void {
			hideCharSpacetab();

		}
		/*private function charSpacemaxStepperListener(e:Event):void {

   				trace(charSpaceminStepper.value+"_____________________________")
			
				var my_fmt:TextFormat = input_txt.getTextFormat(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);

				my_fmt.letterSpacing =  e.target.value;
				input_txt.setTextFormat(my_fmt, input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
				scroller.scrollTarget = input_txt;

			
		}*/
		private function charSpaceminStepperListener(e:Event):void {

			
			
				var my_fmt:TextFormat = input_txt.getTextFormat(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);

				my_fmt.letterSpacing =  charSpaceminStepper.value;
				
				input_txt.setTextFormat(my_fmt, input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
				scroller.scrollTarget = input_txt;

			
		}
		private function removeFormatListener(e:Event):void {
			//trace("clear");
			var clear_fmt:TextFormat = new TextFormat ();
			clear_fmt.font = "Tahoma";
			clear_fmt.color = 0x000000;
			clear_fmt.size = 11;
			clear_fmt.underline = false;
			clear_fmt.align = "left";
			clear_fmt.blockIndent=0;
			clear_fmt.bold = false;
			clear_fmt.italic = false;
			clear_fmt.bullet = false;
			clear_fmt.indent = 0;
			clear_fmt.kerning = 0;
			clear_fmt.leading = 2;
			clear_fmt.leftMargin=0;
			clear_fmt.rightMargin=0;



			//var selectedText:String = input_txt.text.substring(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			//input_txt.replaceText (input_txt.selectionBeginIndex,input_txt.selectionEndIndex,selectedText);
			input_txt.setTextFormat(clear_fmt, input_txt.selectionBeginIndex, input_txt.selectionEndIndex);

		}

		private function selectAllListener(e:Event):void {

			initialPoint = 0;
			finalpoint = input_txt.text.length;
			input_txt.setSelection(initialPoint,finalpoint);

		}

		private function pastefromClipboard(e:Event):void {
			input_txt.replaceText(input_txt.selectionBeginIndex,input_txt.selectionEndIndex,clipBoard);
			finalpoint = initialPoint+clipBoard.length;
			//trace(initialPoint+"---"+finalpoint);
			input_txt.setSelection(initialPoint,finalpoint);
			input_txt.setTextFormat(clipboardFmt, initialPoint,finalpoint);
			scroller.scrollTarget = input_txt;

		}
		private function cuttoClipboard(e:Event):void {
			input_txt.useRichTextClipboard = true;
			clipboardFmt = input_txt.getTextFormat(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			clipBoard = input_txt.text.substring(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			System.setClipboard(clipBoard);
			//trace(":::::   "+clipBoard);
			input_txt.replaceText(input_txt.selectionBeginIndex,input_txt.selectionEndIndex,"");
		}

		private function copytoClipboard(e:Event):void {
			input_txt.useRichTextClipboard = true;
			clipboardFmt = input_txt.getTextFormat(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			clipBoard = input_txt.text.substring(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			System.setClipboard(clipBoard);
			//trace(":::::   "+clipBoard);
		}
		
		private function changeOccurredIN(e:Event):void {

			var my_fmt:TextFormat = input_txt.getTextFormat(input_txt.selectionBeginIndex, input_txt.selectionEndIndex );


			my_fmt.indent = indStepper.value;


			input_txt.setTextFormat(my_fmt, input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			scroller.scrollTarget = input_txt;
		}
		private function changeOccurredLE(e:Event):void {

			var my_fmt:TextFormat =  input_txt.getTextFormat(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			my_fmt.leading = lineStepper.value;

			input_txt.setTextFormat(my_fmt, input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			scroller.scrollTarget = input_txt;
		}
		private function changeOccurredLM(e:Event):void {

			var my_fmt:TextFormat =  input_txt.getTextFormat(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);

			my_fmt.leftMargin = lMarginStepper.value;

			input_txt.setTextFormat(my_fmt, input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			scroller.scrollTarget = input_txt;
		}
		private function changeOccurredRM(e:Event):void {

			var my_fmt:TextFormat =  input_txt.getTextFormat(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);

			my_fmt.rightMargin = rMarginStepper.value;

			input_txt.setTextFormat(my_fmt, input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			scroller.scrollTarget = input_txt;
		}
		///////////////
		private function formatParagraphListener(e:Event):void {

			showParagraphtab();

			viewHTML.enabled= false;
			findActive.enabled= false;
			hyperlinkActive.enabled= false;

		}
		private function paraBackButListener(e:Event):void {

			hideParagraphtab();
			viewHTML.enabled= true;
			findActive.enabled= true;
			hyperlinkActive.enabled= true;
		}

		private function insertChar(e:Event):void {

			var charTxt:String = e.target.label;
			input_txt.replaceText(input_txt.selectionBeginIndex,input_txt.selectionEndIndex,charTxt);


		}

		private function input_txtListener(e:Event):void {
			//trace("mouse up");

			//var p:DisplayObject = input_txt.getImageReference ("abc");
			//var q:DisplayObject;

			//q = p;
			////trace(p.width);
			////trace(p.x+" / mouse X "+ input_txt.mouseX );
			////trace(p.y);
			////trace(p.name);
			////trace(p.loaderInfo);
			////trace( hitTestObject(p));




			//imgLoader.source = q;

			////trace("caretIndex ="+input_txt.caretIndex);
			/* 
			
			to update colored areas of input text field in HTML code view on any changes made 
			 if (viewHTML.label == "Rich Text"){
			  
			  colorHTML();
			  
			  }*/
			var initialPoint:uint = input_txt.selectionBeginIndex;

			////trace(input_txt.selectionEndIndex)
			////trace(input_txt.selectionBeginIndex)
			//trace("initialPoint: "+initialPoint)
			if ((input_txt.selectionEndIndex - input_txt.selectionBeginIndex) > 0 ) {
				////trace("selected");
				rightIndentBut.enabled = true;
				l_button.enabled = true;
				leftIndentBut.enabled = true;


			} else {
				rightIndentBut.enabled = false;
				l_button.enabled = false;
				leftIndentBut.enabled = false;

			}
		}


		private function findNextListener(e:Event):void {
			//trace(searchString);
			var selectLength:Number = searchString.length;
			initialPoint = input_txt.text.indexOf(searchString, lastIndexTillSearched);
			//trace(initialPoint);
			finalpoint= initialPoint+ selectLength;

			if (initialPoint > -1) {
				replaceBut.enabled  = true;
				input_txt.setSelection(initialPoint,finalpoint);
				lastIndexTillSearched = finalpoint;
			}
		}

		private function updateFindTxt(e:Event):void {
			searchString = findTxt.text;

		}


		private function updateReplaceTxt(e:Event):void {
			replaceString = replaceTxt.text;

		}
		private function replaceListener(e:Event):void {

			if (initialPoint > -1) {
				input_txt.replaceText(initialPoint,finalpoint, replaceString);
				var selectLength:Number = replaceString.length;
				finalpoint = initialPoint+selectLength;
				input_txt.setSelection(initialPoint,finalpoint);
				lastIndexTillSearched = finalpoint;

			}
			replaceBut.enabled = false;
		}





		private function findWindowActivatorListener(e:Event):void {

			changeFindButtonToggle();

			displayFindtab();

		}
		private function changecolorTickHandler(event:MouseEvent):void {
			if ( changecolorTick.selected == true ) {
				linkColorPicker.enabled = true;
			} else {
				linkColorPicker.enabled = false;
			}
		}


		private function addunderlineTickHandler(event:MouseEvent):void {
			//
		}


		private function linkColorPickerChangeHandler(event:ColorPickerEvent):void {

			selectedLinkColor = event.color;//event.target.hexValue;
			////trace("color changed:", event.color, "(#" + event.target.hexValue + ")");

		}
		private function hyperlinkListener(e:Event):void {

			if (isLinkShow == true) {

				displayLinkElements();
				isLinkShow = false;

				findActive.enabled = false;
				viewHTML.enabled = false;

			} else if (isLinkShow == false) {

				isLinkShow = true;
				findActive.enabled = true;
				viewHTML.enabled = true;
				hideLinkElements();

			}
			toggleLinkButton();

		}


		private function comboBoxChangeListener(event:Event):void {
			if (viewHTML.enabled == true) {
				applyStyle(event.currentTarget);
			}
		}

		private function buttonClickListener(event:MouseEvent):void {

			if (viewHTML.enabled == true) {
				applyStyle(event.currentTarget);


			}
		}
		private function hyperbuttonClickListener(event:MouseEvent):void {


			applyStyle(event.currentTarget);



		}


		private function colorPickerChangeHandler(event:ColorPickerEvent):void {

			selectedFontColor = event.color;//event.target.hexValue;
			//trace("color changed:", event.color, "(#" + event.target.hexValue + ")");

			// //trace(selectedFontColor);
			if (viewHTML.enabled == true) {
				applyStyle(event.currentTarget);
			}
		}


		private function specialCharButListener(e:Event):void {

			showChartab();
			hyperlinkActive.enabled = false ;
			findActive.enabled = false ;
			viewHTML.enabled = false ;

		}

		private function charBackButListener(e:Event):void {

			hideChartab();
			Show3rdRow();

			hyperlinkActive.enabled = true ;
			findActive.enabled = true ;
			viewHTML.enabled = true ;

		}

		public function applyStyle(theObject:*):void {
			if ((input_txt.selectionBeginIndex == 0) && (input_txt.selectionEndIndex == 0)) {
				return;
			}
			var my_fmt:TextFormat = input_txt.getTextFormat(input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			// because the majority of the code in this function is the same, 
			// rather than rewrite the code for each instance, we'll perform a "switch" 
			// on the name of the target component and simply change the one paramter in the format.
			switch (theObject) {
				case font_cb :
					// if the font_cb ComboBox instance is changed, set the font to the currently selected item in the ComboBox.
					my_fmt.font = ComboBox(theObject).selectedItem.fontName;
					break;
				case size_cb :
					my_fmt.size = ComboBox(theObject).selectedLabel;
					break;
				case bold_button :
					// if the bold_btn Button instance is clicked, toggle the bold property.
					my_fmt.bold = !my_fmt.bold;
					break;
				case underline_button :
					// if the underline_button Button instance is clicked, toggle the underline property.
					my_fmt.underline = !my_fmt.underline;
					break;
				case hyperlink_button :



					my_fmt.url = linkTxt.text;
					my_fmt.target = window_cb.selectedLabel;
					////trace(window_cb.selectedLabel);

					if (changecolorTick.selected == true) {
						my_fmt.color = selectedLinkColor;


					}
					if (addunderlineTick.selected == true) {
						my_fmt.underline =  true;
					}
					//applyStyle(input_txt);
					break;

				case italic_button :
					my_fmt.italic = !my_fmt.italic;
					break;
				case sizeUp_button :
					// if the sizeUp_btn Button instance is clicked, increment the font size by one pixel.
					my_fmt.size += 1;
					break;
				case sizeDown_button :
					my_fmt.size = Number(my_fmt.size)-1;
					break;


				case l_button :



					my_fmt.bullet = !my_fmt.bullet;


					break;


				case leftIndentBut :

					my_fmt.blockIndent += 5;

					break;


				case rightIndentBut :
					//trace( my_fmt.blockIndent);
					my_fmt.blockIndent = Number(my_fmt.blockIndent)-5;
					//trace( my_fmt.blockIndent);
					break;


				case leftAlign_button :
					my_fmt.align = "left";
					break;

				case centerAlign_button :
					my_fmt.align = "center";
					break;

				case rightAlign_button :
					my_fmt.align = "right";
					break;

				case justifiedAlign_button :
					my_fmt.align = "justify";
					break;

					/*case color_cb :
					// if the color_cb ComboBox instance changes, set the color to the currently selected item's data property
					my_fmt.color = ComboBox(theObject).selectedItem.data;
					//trace(ComboBox(theObject).selectedItem.data+"dddddddd")
					break;
					*/
				case fontColorPicker :
					////trace(selectedFontColor+"kkkkk")
					my_fmt.color = selectedFontColor;
					break;



				
			}
			// reapply the text format.
			input_txt.setTextFormat(my_fmt, input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
			scroller.scrollTarget = input_txt;

		}

		private function viewHTMLListener(e:Event):void {

			if (viewHTML.label == "< HTML Code >") {

				openFindTab();
				isActive = false;
				findActive.enabled = false;
				hyperlinkActive.enabled = false;
				findActive.enabled = false;


				var format:TextFormat = new TextFormat();
				format.font = "Verdana";
				format.color = 0x000000;
				format.size = 10;
				format.underline = false;



				//input_txt.setTextFormat(my_fmt, input_txt.selectionBeginIndex, input_txt.selectionEndIndex);
				input_txt.defaultTextFormat = format;
				input_txt.alwaysShowSelection = false;
				input_txt.text = input_txt.htmlText;
				viewHTML.label = "Rich Text";
				//viewRichText.enabled = true;

				colorHTML();

			} else {


				findActive.enabled = true;
				hyperlinkActive.enabled = true;
				input_txt.alwaysShowSelection = false;
				//applyStyle(input_txt.text);
				input_txt.htmlText = input_txt.text;
				viewHTML.label = "< HTML Code >";
				//viewRichText.enabled = false;

			}
		}























	}
}