package net.typoflash.base{
	
	/**
	 * ...
	 * @author Borg
	 */
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.Glue;
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.ContentRendering;
	import net.typoflash.datastructures.TFPageRequest;
	import net.typoflash.datastructures.TFMotherload;
	import flash.system.Security;
	
	import net.typoflash.utils.Debug;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import net.typoflash.events.CoreEvent;
	import flash.text.TextFormat;
	
	public class TemplateBase extends Configurable implements ITemplate{
		
		public var firstPageContentFullyLoaded:Boolean = false;
		public var motherloadLoaded:Boolean = false;
		public var textFormats:Array;
		public var colours:Array;//define pallette and use as you wish
		
		public function TemplateBase() {
			TF_GLUE.disablePhysicalConfig = true;
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			textFormats = [];
			colours = [];
			
			ContentRendering.addEventListener(RenderingEvent.ON_FRAME_LOAD_COMPLETE, onPageLoadComlete);
			/* This event listens to all types of load processes so that the template can inform the user 
			 * about what is going on. Override in extensions.
			 */ 
			if(TF_CONF.CORE){
				TF_CONF.CORE.addEventListener(CoreEvent.ON_LOAD_PROGRESS, onAnyLoadProgress,false,0,true);
				TF_CONF.CORE.addEventListener(CoreEvent.ON_LOAD_COMPLETE, onAnyLoadComplete,false,0,true);
			}
			
			try{
				for (var i = 0;i < TF_CONF.FONT_MANAGER.fontList.length; i++) {
					textFormats.push(new TextFormat( TF_CONF.FONT_MANAGER.getFontById(i).fontName, 12, 0));
				}
			}
			catch (e:Error) {}			
		}
		
		/*
		 * Template objects, such as frames and menus, should listen to the RenderingEvent.ON_TEMPLATE_ADDED_TO_STAGE 
		 * event instead of using their own addedToStage events to make sure TF_CONF settings for the specific
		 * template are set
		 */
		private function _onAddedToStage(e:Event) {
			if(TF_CONF.INIT_PAGE_REQUEST){
				ContentRendering.getPage(TF_CONF.INIT_PAGE_REQUEST);
				/*
				 * Important note. Init page request is passed in by html, but another page might be called via
				 * SWFaddress and then updateFlashHistory is called in core. If INIT_PAGE_REQUEST is set and
				 * the props different it will assume it is the first call, even before this template call. Thus
				 * we need to clean it out here so no double calls.
				 */ 
				TF_CONF.INIT_PAGE_CALLED = true;
			}
			//For dev purposes...when local file loads http component
			Security.allowDomain(TF_CONF.HOST_DOMAIN );	
			
			if (!(TF_CONF.IS_LIVE)) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			init();
			ContentRendering.dispatchEvent(new RenderingEvent(RenderingEvent.ON_TEMPLATE_ADDED_TO_STAGE));
			
		}
		/*
		 * This can be used in subclasses to init things before all the children gets into the classroom
		 */ 
		
		public function init() {}
		 
		/*
		 * The template level onGetPage listener is checking if it is still the same template.swf for the new page
		 * then it applies the template comnfig.
		 * 
		 * Note: The function is called by Configurable after preparsedGetPage is called.
		 */ 
		override protected function onGetPage(e:RenderingEvent) {
			Debug.output("Templatebase onGetpage returned")
			return;
			var v3 = {};
			v3.conf = ContentRendering.page.TEMPLATE.conf;
			v3.template_conf = ContentRendering.page.TEMPLATE.template_conf;
			v3.page_conf = ContentRendering.page.TEMPLATE.page_conf;
			v3.onComplete = function (obj) {
				//var v2 = {'type': 'onQueueItemProgress', 'obj': obj};
				//TF_CONF.CORE.dispatchEvent(v2);
			 };

			v3.onProgress = function (obj) {
				//var v2 = {'type': 'onQueueItemComplete', 'obj': obj};
				//TF_CONF.CORE.dispatchEvent(v2);
			};

			var v10 = escape(ContentRendering.page.TEMPLATE.conf + ContentRendering.page.TEMPLATE.template_conf + ContentRendering.page.TEMPLATE.page_conf + ContentRendering.page.TEMPLATE.uid);
		  
			var templFile = TF_CONF.HOST_URL + ContentRendering.page.TEMPLATE.base + ContentRendering.page.TEMPLATE.file;
		  
			if (ContentRendering.OLD_TEMPLATE_ID != ContentRendering.TEMPLATE_ID && ContentRendering.page.TEMPLATE.file.length > 0) {
            if (ContentRendering.page.TEMPLATE.language_file.length > 0) {
				var v11 = TF_CONF.HOST_URL + ContentRendering.page.TEMPLATE.base + ContentRendering.page.TEMPLATE.language_file;
            }else{
              //(net.typoflash.LocalLang.__get__global()).parseXML('');
            }
            
			v3.mc = TF_CONF.TEMPLATE;
            
			ContentRendering.currTplState = {};
            if (TF_CONF.TEMPLATE != ContentRendering.page.TEMPLATE.file && TF_CONF.IS_LIVE) {
				Debug.output('Loading file ' + templFile + ' into ' + TF_CONF.LAYER.template);
				/*var q = TF_CONF.LOAD_QUEUE;
				q.clear();
				q.addItem(templFile, TF_CONF.LAYER.template);
				q.execute();*/
            } else {
				Debug.output('The template file ' + ContentRendering.page.TEMPLATE.file + ' is already loaded. Only need to apply new config');
            }
            if (ContentRendering.page.TEMPLATE.bgcolour.length > 0) {
              var v4 = (ContentRendering.page.TEMPLATE.bgcolour.split('#'))[1];
              v4 = parseInt('0x' + v4);
			  // TODO: BGcolour
              /*var v8 = new Color(_level0.bg);
              v8.setRGB(v4);*/
            }
          } 
		}
		
		protected function onRequestMenu(e:RenderingEvent) {
			if (TF_CONF.MENU.debug) {
				//Debug.output('onRequestMenu');
				//Debug.output(e.data.pObj);
			}
        };

        override protected function onGetMotherload(e:RenderingEvent) {
          firstPageContentFullyLoaded = true;
          motherloadLoaded = firstPageContentFullyLoaded;
        };

		override protected function onClearCache(e:RenderingEvent) {
			Debug.output('TemplateBase: onClearCache');
			firstPageContentFullyLoaded = false;
			motherloadLoaded = firstPageContentFullyLoaded;
			if (TF_CONF.MOTHERLOAD.mode == TFMotherload.MODE_ON_PAGE_LOAD_COMPLETE) {
				if (TF_CONF.MOTHERLOAD.pageRequest is TFPageRequest) {
					ContentRendering.getMotherload(TF_CONF.MOTHERLOAD.pageRequest);
				} else {
					Debug.output('TemplateBase: Template trying to get motherload pos cache but no menu requested to set TF_CONF.MOTHERLOAD.pageRequest');
				}
			  }
        };
        private function onPageLoadComlete(e:RenderingEvent) {
			if (!firstPageContentFullyLoaded) {
				if (TF_CONF.MOTHERLOAD.mode == TFMotherload.MODE_ON_PAGE_LOAD_COMPLETE) {
					if (TF_CONF.MOTHERLOAD.pageRequest is TFPageRequest) {
						ContentRendering.getMotherload(TF_CONF.MOTHERLOAD.pageRequest);
					} else {
						Debug.output('Template trying to get motherload but no menu requested to set TF_CONF.MOTHERLOAD.pageRequest');
					}
				}
				Debug.output('TemplateBase: First page completely loaded');
			}
			firstPageContentFullyLoaded = true;
        };

        private function onPreSetPage(e:RenderingEvent) {
			if (firstPageContentFullyLoaded) {
				//TF_CONF.LOAD_QUEUE.clear();
			}
        };
		
		/*
		 * Override these functions to display preloaders in template for frame loads as well as component asset
		 * loads.
		 */ 
		protected function onAnyLoadProgress(e:CoreEvent) {
			//Debug.output("TemplateBase.onAnyLoadProgress " + e.info);
		}
		protected function onAnyLoadComplete(e:CoreEvent) {
			//Debug.output("TemplateBase.onAnyLoadComplete " + e.info);
		}
	}
	
}