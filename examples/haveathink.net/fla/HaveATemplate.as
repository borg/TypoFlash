package {
	
	/**
	 * ...
	 * @author Borg
	 */
	
	import fl.containers.ScrollPane;
	import net.typoflash.base.TemplateBase;
	import net.typoflash.datastructures.TFMenuRequest;
	import net.typoflash.datastructures.TFPageRequest;
	
	import net.typoflash.templates.frames.TFBasicFrame;
	import net.typoflash.remoting.RemotingService;
	import net.typoflash.events.RemotingEvent;
	import flash.net.Responder;
	import flash.events.Event;
	
	import flash.display.Shape;	
	import flash.system.Capabilities;	
	import flash.text.TextField;	
	
	import net.typoflash.queueloader.QueueLoaderEvent;	
	import net.typoflash.queueloader.QueueLoader;	

	import flash.system.ApplicationDomain;	
	import flash.system.LoaderContext;	
	import flash.display.Sprite;	
	
	
	import net.typoflash.ContentRendering;
	import net.typoflash.events.RenderingEvent;
	
	import flash.net.*;
	
	import net.typoflash.utils.Debug
	import fl.controls.ScrollPolicy;
	
	public class HaveATemplate extends TemplateBase{

		public var logo:HaveALogo;
		public var beta:BetaAnim;
		public var mainMenu:HaveAMenu;
		
		public var header:Sprite;
		public var headerBg:Sprite;
		public var footer:HaveAFooter;
		public var BG:TFBasicFrame;
		public var FG:TFBasicFrame;
		
		public var holder:Sprite;//to contain all content
		public var scrollpane:TFScrollPaneSkin;//to contain holder
		public var frameHeight:uint = 520;
		public var margin:int = 10;
		public var scrW:int = 8;
		
		public var headerColour:int
		public var bodyColour:int
		
		public function HaveATemplate() {
			if(!TF_CONF.IS_LIVE){
				TF_CONF.HOST_URL = "http://localhost:801/";
				TF_CONF.REMOTING_GATEWAY = TF_CONF.HOST_URL + 'typo3conf/ext/flashremoting/amf.php';
				TF_CONF.INIT_PAGE_REQUEST = new TFPageRequest(8, 0);
				TF_CONF.LOAD_QUEUE = new QueueLoader();
			}
			TF_CONF.API_KEY["YOUTUBE_DEV_KEY"] = "AI39si6GqJJgx9fzWHXTTQjnwJQi2HYFM07j0YLmViQdmMSC9ESE0zDURQ1Pf5itewY6bXaX_6ZH_zu1GLGuHmhAIJavepqGAw";
		}
		
		override public function init() {
			colours = [0x333333, 0x76CBCF,0x00000,0x999999];
			scrollpane = new TFScrollPaneSkin();
			ScrollPane(scrollpane).horizontalScrollPolicy = ScrollPolicy.OFF;
			header = new Sprite();
			header.y = margin;
			
			headerBg = new Sprite();
			headerBg.graphics.beginFill (0xFFFFFF,1);
			headerBg.graphics.lineStyle (0, 0xFFFFFF, 1);
			headerBg.graphics.moveTo (0, 0);
			headerBg.graphics.lineTo (965, 0);
			headerBg.graphics.lineTo (965, 110);
			headerBg.graphics.lineTo (0, 110);
			headerBg.graphics.endFill();
			headerBg.x= 0
			headerBg.y = 0
			headerBg.useHandCursor = false;			
			
			
			

			
			
			FG = new TFBasicFrame();
			FG.name = "FG";
			FG.isDefaultFrame = true
			FG.masked = true;
			FG.x = 0;
			FG.y = 130;
			FG.setSize(stage.stageWidth-2*margin, frameHeight);
			
			BG = new TFBasicFrame();
			BG.name = "BG"
			BG.isDefaultFrame = false
			BG.masked = true;
			BG.x = 0;
			BG.y = 0;
			BG.setSize(stage.stageWidth, frameHeight+FG.y+margin);		
			
			
			
			logo = new HaveALogo();
			logo.x = margin;
			logo.y = -5;
			logo.scaleX = logo.scaleY = .2
			
			
			mainMenu = new HaveAMenu();
			//mainMenu.name = "horisontalMenu";
			mainMenu.ItemClasses = [HorisontalMainSymbol,HorisontalSubSymbol];
			mainMenu.ItemSkins = [HorisontalMainSkin,HorisontalSubSkin];

			mainMenu.x = margin;
			mainMenu.y = 75;
			mainMenu.width = 945;//was 880
			mainMenu.itemMargin = 20
			mainMenu.fixedDimensions = true
			mainMenu.height = 30;
			mainMenu.rootAlias = "root";		
			
			
			footer = new HaveAFooter();
			footer.y = BG.height;
			
			holder = new Sprite();
			holder.addChild(BG);
			holder.addChild(FG);
			header.addChild(headerBg);
			header.addChild(logo);
			logo.logoAnimFinished = logoAnimFinished;
			header.addChild(mainMenu);
			holder.addChild(header);
			holder.addChild(footer);
			
			scrollpane.source = holder;
			addChild(scrollpane);
			positionChildren();
		}
		public function logoAnimFinished() {
			showBetaAnim()
		}
		public function showBetaAnim() {
			beta = new BetaAnim();
			beta.x = 730;
			beta.y = 0;
			header.addChild(beta);
		}
		
		override public function positionChildren() {
			FG.setSize(stage.stageWidth - 2 * margin, frameHeight);
			FG.x = header.x = (stage.stageWidth / 2 -  headerBg.width / 2) - scrW;
			BG.setSize(stage.stageWidth-2*margin, frameHeight+FG.y+margin);
			footer.bg.width = stage.stageWidth;
			scrollpane.setSize(stage.stageWidth,stage.stageHeight)
		}
		
	}
	
}