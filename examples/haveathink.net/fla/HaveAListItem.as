package  
{
	import flash.events.MouseEvent;
	import net.typoflash.components.news.NewsListItem;
	import net.typoflash.datastructures.TFNewsItem;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import gs.TweenLite;
	import gs.easing.*;
	import net.typoflash.events.ReaderEvent;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.fonts.FontManager;
	import net.typoflash.components.reader.AbstractReader;	
	import flash.text.TextFormat;
	import flash.text.Font;
	
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	/**
	 * ...
	 * @author A. Borg
	 */
	import net.typoflash.utils.Debug;
	public class HaveAListItem extends NewsListItem{
		protected var _finHeight;
		public function HaveAListItem(_reader:AbstractReader,o:TFNewsItem) {
			super(_reader,o);
		}

		override public function render() {
			try {
			
				
				skin.titleTxt.text = TFNewsItem(data).title.toLocaleUpperCase();
				//TextField(skin.titleTxt).setTextFormat(tf1)
				skin.titleTxt.mouseEnabled = false;
				//TextField(skin.bodyTxt).autoSize = TextFieldAutoSize.LEFT;
				skin.titleTxt.antiAliasType = AntiAliasType.ADVANCED;  
				skin.bodyTxt.text = TFNewsItem(data).short;
				//TextField(skin.bodyTxt).setTextFormat(tf2)
				skin.bodyTxt.antiAliasType = AntiAliasType.ADVANCED;  
				
				
				skin.titleTxt.mouseEnabled = skin.bodyTxt.mouseEnabled = false
				//skin.bodyTxt.visible = false;
				//_finHeight = skin.bodyTxt.y + skin.bodyTxt.height + padding;
				height = 50;
				var imageWidth = 60
				var imageHeight = 60;
				var imgs = TFNewsItem(data).image.split(",");
				if(imgs[0] !=''){
					
					var thumb:Loader = new Loader();
					var url = new URLRequest(TF_CONF.HOST_URL  +'typo3/thumbs.php?size=' + imageWidth + 'x' + imageHeight + '&file=../uploads/pics/' + imgs[0]);
					thumb.load(url);
					thumb.x = -5;//centre
					thumb.y = -5;
					skin.image.addChild(thumb);
				}
				
				
			
				
				
				//TweenLite.to(this, .5, { height:_finHeight, easClickRollIt, false, 0, true);
				skin.bg.addEventListener(MouseEvent.CLICK, onClickIt, false, 0, true);/**/
				skin.bg.addEventListener(MouseEvent.ROLL_OVER, onRollIt, false, 0, true);/**/
				skin.bg.addEventListener(MouseEvent.ROLL_OUT, onRollItOut, false, 0, true);/**/
				skin.bg.buttonMode = true
			}
			catch (e:Error){
				throw new Error("HaveAListItem render error");
				
			}
		}
		private function onClickIt(e:MouseEvent) {
			reader.stopTimer();
			reader.activeItem = data;	
		}
		private function onRollIt(e:MouseEvent) {
				
			skin.highlite.gotoAndPlay("over");
			skin.imageFrame.gotoAndPlay("over");		
		}
		private function onRollItOut(e:MouseEvent) {
			//reader.dispatchEvent(new ReaderEvent(ReaderEvent.ON_SET_ACTIVE,data))
			skin.highlite.gotoAndPlay("out");
			skin.imageFrame.gotoAndPlay("out");		
		}
		
		override public function activate() {
			if (_isActive) {
				//TweenLite.to(this, .5, { height:_finHeight, ease:Quad.easeInOut, onComplete:onFinishTween } );	
				skin.states.gotoAndStop("active");
			}else {
				//skin.bodyTxt.visible = false;
				//TweenLite.to(this, .5, { height:38, ease:Quad.easeInOut} );	
				skin.states.gotoAndStop("passive");
			}
			
		}
		protected function onFinishTween() {
			skin.bodyTxt.visible = true;
		}
		
		override public function set height(v:Number):void {
			skin.holder.y = v + margin;
			skin.bg.height = v;
		}
		override public function get height():Number {
			return skin.bg.height;
		}	
		
		override public function setDefaultTextFormat() {
				try{
					var tf1:TextFormat = new TextFormat(TF_CONF.FONT_MANAGER.getFontById(0).fontName, 14, 0);
					var tf2:TextFormat = new TextFormat(TF_CONF.FONT_MANAGER.getFontById(1).fontName, 10, 0x555555);
					skin.titleTxt.defaultTextFormat = new TextFormat(reader.textFormats[0].font,14,reader.colours[0]);
					skin.titleTxt.embedFonts = true
					skin.bodyTxt.defaultTextFormat = new TextFormat(reader.textFormats[1].font,10,reader.colours[3]);
					skin.bodyTxt.embedFonts = true
					Debug.output("HaveAListItem render tf1.font "+tf1.font)
				}catch (e:Error)	{
					tf1 = tf2 =  new TextFormat("Verdana", 10, 0x333333);
				}	

		}
	}
	
}