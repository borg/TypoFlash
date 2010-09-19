package net.typoflash.templates.menus{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import net.typoflash.base.MenuBase;
	import net.typoflash.templates.menus.MenuItem;
	import net.typoflash.events.MenuItemEvent;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.ContentRendering;
	//import fl.transitions.Tween;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class HorisontalDropDownMenu extends MenuBase{
		

		public var killMouseLayer:Sprite;
		public var dropdown:HorisontalDropShadow;//HorisontalDropShadow
		
		protected var _totalWidth:Number=500;
		protected var _height:Number=30;
		
		
		
		public function HorisontalDropDownMenu() {
			//since we are not using any other components no need to nest further
			view = this;
			fixedDimensions = true;
			//Generic killer
			ContentRendering.addEventListener(RenderingEvent.ON_SET_PAGE, killSub);
			//addEventListener(MenuItemEvent.ON_ROLL_OVER, openDropdownMenu);
		}

		
		override public function render() {
			renderMenuBar();
		}
		
		public function renderMenuBar() {
			var mc:MenuItem;
			var oldX:int = 0;
			if(fixedDimensions){
				var orgW = (_totalWidth-_itemMargin*(menuXML.children().length()-1))/ menuXML.children().length();
			}
			for(var i=0;i<menuXML.children().length();i++){
				mc = new ItemClasses[0](0);
				mc.skin = new ItemSkins[0]();
				//order is important sometimes since node sets label and thus width need to be set for textfield to be centered
				mc.menu = this;
				mc.x = oldX;
				
				mc.height = height;
				
				
				mc.padding = _itemPadding;
				mc.margin = _itemMargin;			
				
				//this sets label, and thus text dimensions
				mc.node = menuXML.children()[i];
				
				if (fixedDimensions) {
					mc.width = orgW;
				}
				if (fixedItemDimensions) {
					mc.width = itemWidth;
				}
				
				
				addChild(mc);
				mc.render();
				oldX += mc.width + _itemMargin;
				
			}	
		}
		
		public function openDropdownMenu(item:MenuItem) {

			var node:XML = item.node;
			if(!(item.node.children().length()>0) || dropdown){
				killSub()
				return;
			}
			//Put an invisible btn to cover all bg to capture mouse action
			killMouseLayer = new Sprite();
			killMouseLayer.graphics.beginFill (0xFFFF00,0);
			killMouseLayer.graphics.lineStyle (0, 0xFF00FF, 0);
			killMouseLayer.graphics.moveTo (0, 0);
			killMouseLayer.graphics.lineTo (stage.stageWidth, 0);
			killMouseLayer.graphics.lineTo (stage.stageWidth, stage.stageHeight);
			killMouseLayer.graphics.lineTo (0, stage.stageHeight);
			killMouseLayer.graphics.endFill();
			killMouseLayer.x=-x;//center it
			killMouseLayer.y = -y;
			killMouseLayer.addEventListener(MouseEvent.CLICK, killSub);
			killMouseLayer.useHandCursor = false;			
			addChildAt(killMouseLayer,0);

			
			dropdown = new HorisontalDropShadow();
			dropdown.x = item.x;
			dropdown.y = item.y + item.height;
			addChild(dropdown)
			//trace(node.attributes.mc +" "+node.attributes.mc._height)
			


			
			var s:MenuItem;
			var bgh:Number;//sum height
			var w = 50;
			for(var i=0;i<node.children().length();i++){
				s = new ItemClasses[Math.min(ItemClasses.length,1)](1);
				s.skin = new ItemSkins[Math.min(ItemSkins.length,1)]();
		
				s.height = height;
				s.node = node.children()[i];
				s.menu = this;
						
				s.y = s.height*i;
				bgh = s.y + s.height + 1;
				w = Math.max(w, (s.width + 10 ));
				if (node.children()[i].children().length()>0) {
					s.arrow = new HorisontalArrow();
					s.skin.addChild(s.arrow);
				}
				dropdown.holder.addChildAt(s,0);
			}
			/*
			 * Set width when all elements are rendered
			 */
			for(i=0;i<node.children().length();i++){
				s = MenuItem(dropdown.holder.getChildAt(i));
				try{
					s.arrow.x = w-15;
					s.arrow.y = s.height / 2 - s.arrow.height / 2;
				}
				catch (e:Error)	{
					//only applicable to items with kids
				}
				s.skin.subholder.x = w+1;
				s.width = w;
				s.render();
				
			}
			
			dropdown.bg.width = w+2;
			dropdown.bg.height = bgh;
		}
		/*
		 * Dropdowns can be killed by clicking on the kill layer or by a setpage event
		 */ 
		public function killSub(e:*=null) {
			if (killMouseLayer) {
				removeChild(killMouseLayer);
				killMouseLayer = null;
			}
			
			if(dropdown) {
				removeChild(dropdown);
				dropdown = null;
			}
			
		}
		
		/*
		 * Called by subitem onRollOver
		 */
		
		public function attachSub(item:MenuItem) {
			
			if (Sprite(item.skin.subholder).numChildren > 0) {
				for (var c = 0; c < item.skin.subholder.numChildren; c++) {
					item.skin.subholder.removeChildAt(c);
				}
			}
			var subdrop = new HorisontalDropShadow();
			//subdrop.x = item.x;
			//subdrop.y = item.y + item.height;
			item.skin.subholder.addChild(subdrop)
			
			
			
			
			
			var node:XML = item.node;
			
			var s:MenuItem;
			var bgh:Number;//sum height
			var w = 50;
			for(var i=0;i<node.children().length();i++){
				s = new ItemClasses[Math.min(ItemClasses.length,2)](2);
				s.skin = new ItemSkins[Math.min(ItemSkins.length,2)]();
		
				s.height = height;
				s.node = node.children()[i];
				s.menu = this;
						
				s.y = s.height*i;
				bgh = s.y + s.height + 1;
				w = Math.max(w, (s.width + 10 ));
				if (node.children()[i].children().length()>0) {
					s.arrow = new HorisontalArrow();
					s.skin.addChild(s.arrow);
				}
				subdrop.holder.addChildAt(s,0);
			}
			/*
			 * Set width when all elements are rendered
			 */
			for(i=0;i<node.children().length();i++){
				s = subdrop.holder.getChildAt(i);
				
				try{
					s.arrow.x = w-15;
					s.arrow.y = s.height / 2 - s.arrow.height / 2;
				}
				catch (e:Error)	{
					//only applicable to items with kids
				}
				s.subholder.x = w+1;
				s.bg.width = w;
				s.render();
				
			}
			
			subdrop.bg.width = w+2;
			subdrop.bg.height = bgh;
			
			
			
			
			
			
			
			
			
			
			
			
			
		}
			/*	clearInterval(subInt);
			var s,bgh;
			var w = 50;
			var mc =mc.subholder.attachMovie("ddDropdown","ddDropdown" ,0);

			//mc._x = node.attributes.mc._x;
			
			mc._y = node.attributes.mc._y + node.attributes.mc._height;
			for(var i=0;i<node.childNodes.length;i++){
				s= mc.holder.attachMovie(subSymbol,"sub"+i,1000-i);

				s._y = s._height*i;
				bgh = s._y + s._height+1;
				s.titleTxt.autoSize = "LEFT";
				s.titleTxt.text = node.childNodes[i].attributes[titleField];
				w = Math.max(w,(s.titleTxt._width+30))
				s.bg.mRoot = this;
				s.bg.k = mc.k;
				s.bg.node =node.childNodes[i];
				s.bg.onRelease = function(){
					clearInterval(this.mRoot.subInt);
					this.mRoot.onClick(this.node)
					this.k.onPress();
				}
				s.bg.onRollOver = function (){
					this.hilite.gotoAndStop("over");
					if(this.node.hasChildNodes()){
						//this.mRoot.subInt = setInterval(this.mRoot,"attachSub",50,this.node,this._parent);
						this.mRoot.attachSub(this.node,this._parent);
					}
					var m = {};
					m.type = "onOpened";
					m.node =this.node;
					this.mRoot.dispatchEvent(m);
					
				}
				s.bg.onRollOut = function (){
					this.hilite.gotoAndPlay("out");
				}
				
				if(s.bg.node.hasChildNodes()){
					var ar = s.attachMovie("ddArrow","arrow",10);
					
		
				}
				
				
				this.addEventListener("onSetActive",s.bg);
				s.bg.onSetActive = function(o){
					if(o.node === this.node){
						this.bg.hilite.gotoAndStop("over");
					}else{
						this.bg.states.gotoAndStop("passive");
					}
				}

				this.addEventListener("onOpened",s.bg);
				s.bg.onOpened = function(o){
					if((o.node != this.node.parentNode)&&(!this._parent._parent._parent.hitTest(_root._xmouse,_root._ymouse))){
					
						this._parent._parent._parent.removeMovieClip();
					}
				}
				
			}
			mc.bg._height = bgh;
			/*
			Set width when all elements are rendered
			
			for(var i=0;i<node.childNodes.length;i++){
				s = mc.holder["sub"+i];
				s.arrow._x = w-15;
				s.arrow._y = s._height/2;
				s.bg._width = w;
				s.subholder._x = w+1;
				
				
			}
			mc.bg._width = w+2;
			var w = new Tween(mc, "_x", Regular.easeOut, 20, 1, .2, true);

		}*/
		override public function set width(v:Number):void {
			_totalWidth = v;
		}
		override public function get width():Number {
			return _totalWidth;
		}
		
		override public function get height():Number { return _height; }
		
		override public function set height(value:Number):void{
			_height = value;
		}
	}
	
}