package net.typoflash.templates.menus 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import net.typoflash.base.MenuBase;
	import net.typoflash.components.Skinnable;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.events.MenuItemEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * Note: There is a bug in Flash AS3 which makes it ignore stop action in the first frame in dynamically 
	 * added & nested movieclips. My default buttons have nested states and unless put first stop action in second frame
	 * it will be ignored.
	 * ...
	 * @author A. Borg
	 */
	public dynamic class MenuItem extends Skinnable {

		protected var _node:XML;
		protected var _isActive:Boolean = false;
		protected var _isInActiveRootline:Boolean = false;
		protected var _isOpen:Boolean = false;
		protected var _label:String;
		protected var _menu:MenuBase;
		public var level:int=0;//depth in nested menu
		protected var _hitArea:Sprite;//must be set in subclasses. Indicates active Sprtie to recieve mouse events. Typically bg.
		
		protected var _padding:int=0;//Passed on from Menu.itemPadding
		protected var _margin:int=0;//Passed on from Menu.margin
		
		public function MenuItem(_level:int=0){
			level = _level;
		}
		
		
		/*
		 * Overrides
		 */
		
		 /*
		 * Check if isOpen and isActive to get right state
		 */ 
		public function render() {
			
		}

		/*
		 * Override this to set textfield and bg dimensions if not fixedDimensions
		 */ 
		public function set label(value:String):void {
			_label = value;
		}
		/*
		 * Always run before setting any text to use dynamic fonts
		 */ 
		public function setDefaultTextFormat(tf:TextField, size:int = 12, colour:int = 0, fontId:int = -1, autoSize:String = TextFieldAutoSize.LEFT) {
			try{
				if (fontId == -1 && menu.dynamicFonts) {
					fontId = menu.dynamicFonts[level];
				}	
				if(TF_CONF.FONT_MANAGER.fontList.length>0){
					tf.embedFonts = true;
					tf.antiAliasType = AntiAliasType.ADVANCED;  
					tf.autoSize = autoSize;
					tf.defaultTextFormat = new TextFormat( TF_CONF.FONT_MANAGER.getFontById(fontId).fontName, size, colour);
				}
			}
			catch (e:Error)	{
				
			}
		}
			
		
		/*
		 * Mouse over and out action
		 */
		
		public function over(e:MenuItemEvent) { }
		public function out(e:MenuItemEvent) { }
		
		
		
		/*******************************/
		
		
		
		
		
		/*
		 * Utilities
		 */ 
		public function get isOpen():Boolean { return _isOpen; }
		
		
		public function set isOpen(value:Boolean):void{
			_isOpen = value;
		}
		
		
		public function get isActive():Boolean { return _isActive; }
		
		public function set isActive(value:Boolean):void 
		{
			_isActive = value;
		}
		
		
		
		public function get label():String { return _label; }
		

		
		public function get node():XML { return _node; }
		
		public function set node(value:XML):void{
			_node = value;
			label = _node.@label;
		}
		
		

		
		
		protected function onSetActive(e:RenderingEvent) {
			if (e.data == _node) {
				_isActive = true;
			}else {
				_isActive = false;
				if (_menu.isInActiveRootline(_node)) {
					_isInActiveRootline = true;
				}else {
					_isInActiveRootline = false;
				}
			}
			render();
		}
		
		/*
		 * When adding MenuItem to a menu this function ensures communication between Menu and Item is maintained
		 */ 
		public function set menu(m:MenuBase) {
			_menu = m;
			_menu.addEventListener(RenderingEvent.ON_SET_ACTIVE, onSetActive,false,0,true);
			_menu.addEventListener(MenuItemEvent.ON_ROLL_OUT, out,false,0,true);
			_menu.addEventListener(MenuItemEvent.ON_ROLL_OVER, over,false,0,true);
			_hitArea.addEventListener(MouseEvent.ROLL_OVER, rollOver,false,0,true);
			_hitArea.addEventListener(MouseEvent.ROLL_OUT, rollOut,false,0,true);
			_hitArea.addEventListener(MouseEvent.CLICK, click,false,0,true);
			_hitArea.buttonMode = true;
			_hitArea.useHandCursor = true;
			
		}
		public function get menu():MenuBase { return _menu; }	
		
		public function get padding():int { return _padding; }
		
		public function set padding(value:int):void 
		{
			_padding = value;
		}
		
		public function get margin():int { return _margin; }
		
		public function set margin(value:int):void 
		{
			_margin = value;
		}
		
		public function get isInActiveRootline():Boolean { 
			if (_menu.isInActiveRootline(_node)) {
				_isInActiveRootline = true;
			}else {
				_isInActiveRootline = false;
			}			
			return _isInActiveRootline; 
		}
		
		public function set isInActiveRootline(value:Boolean):void 
		{
			_isInActiveRootline = value;
		}
		

		
		protected function rollOver(e:MouseEvent) {
			
			_menu.dispatchEvent(new MenuItemEvent(MenuItemEvent.ON_ROLL_OVER, this));
		}
		protected function rollOut(e:MouseEvent) {
			_menu.dispatchEvent(new MenuItemEvent(MenuItemEvent.ON_ROLL_OUT, this));
		}
		
		protected function click(e:MouseEvent) {
			_menu.onClick(node);
		}


		
	}
	
}