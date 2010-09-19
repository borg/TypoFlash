package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.typoflash.base.TemplateBase;
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.datastructures.TFPageRequest;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.ContentRendering;
	import net.typoflash.templates.menus.HorisontalDropDownMenu;
	/**
	 * This is a demonstration of a few basic menu options 
	 * 
	 * ...
	 * @author A. Borg
	 */
	
	
	
	public class Menus extends TemplateBase {
		public var horisontalMenu:HorisontalDropDownMenu;
		
		public function Menus() {
		}
		override public function init() {
	
			TF_CONF.HOST_URL = "http://localhost:801/";
			
			


			ContentRendering.addEventListener(RenderingEvent.ON_SET_PAGE, settingPage);
			ContentRendering.addEventListener(RenderingEvent.ON_MENU_ITEM_ACTIVATED, onMenuItemActivated);
			
			//little button in the corner simulating a call from a non menu, such as a link
			setPageControl.btn.buttonMode = true;
			setPageControl.btn.addEventListener(MouseEvent.CLICK, onClick);
			
			horisontalMenu = new HorisontalDropDownMenu();
			
			horisontalMenu.name = "horisontalMenu";
			horisontalMenu.mainSymbol = HorisontalMainSymbol;
			horisontalMenu.subSymbol = HorisontalSubSymbol;
			horisontalMenu.x = 50;
			horisontalMenu.y = 50;
			horisontalMenu.width = 700;
			horisontalMenu.height = 30;
			horisontalMenu.rootPid = 3;
			addChild(horisontalMenu);
			
			

		}	
			
		function onClick(e:MouseEvent){
			var pObj = new TFPageRequest(setPageControl.pageNum.text);
			ContentRendering.dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_PAGE,pObj));
		};
	
		
		
		private function settingPage(o:RenderingEvent){
			setPageControl.pageNum.text = TFPageRequest(o.data).id;
		};

		private function onMenuItemActivated (o:RenderingEvent){
			setPageControl.pageNum.text = o.data.@uid;
		};
	}
	
}