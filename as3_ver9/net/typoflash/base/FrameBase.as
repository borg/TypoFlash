package net.typoflash.base{
	
	/**
	 * ...
	 * @author Borg
	 */
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import net.typoflash.datastructures.TFContent;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.events.EditingEvent;
	import net.typoflash.events.CoreEvent;
	import net.typoflash.ContentRendering;
	import net.typoflash.datastructures.TFPage;
	import net.typoflash.utils.Debug;
	import net.typoflash.queueloader.QueueLoaderEvent;
	import net.typoflash.queueloader.QueueLoader;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import net.typoflash.transitions.ITransition;

	public class FrameBase extends Configurable	implements IFrame{
		public var components:Array
		public var allContentLoaded:Boolean = true;
		public var isDefaultFrame:Boolean = true;
		public var content:Sprite;//load assets into this
		public var Q:QueueLoader;//Local queue per frame load. Seems global queue either times out if left passive too long and then runs two copies at once on execute. Bug?
		private var oldQ:QueueLoader;
		
		
		public var horisontalAutoScale:Boolean = true;//rescale to fit browser width
		public var verticalAutoScale:Boolean = false;//rescale to fit browser height
		public var marginLeft:int = 0;
		public var marginRight:int = 0;
		public var marginTop:int = 0;
		public var marginBottom:int = 0;
		
		
		
		protected var transition:ITransition;
		public var Transition:Class;
		public var transitionInProperties:Object;
		public var transitionOutProperties:Object;
		public var transitionDuration:Number;
		public var oldSprite:Sprite;
		public var newSprite:Sprite;		
		
		public function FrameBase() {
			//TF_CONF.CORE.addEventListener('onComponentLoaded', this);
			//TF_CONF.LOAD_QUEUE.addEventListener(' onQueueCleared', this);

			components = [];
			
			//__set__transitionType('fade');
          
			//_disablePhysicalConfig = true;

			//TFeditorClass = EditingEvent.MODE_FRAME;
			TF_GLUE.disablePhysicalConfig = true;
			ContentRendering.addEventListener(RenderingEvent.ON_TEMPLATE_ADDED_TO_STAGE, _addedToStage);
			
        };
		/*
		 * Important to wait for template to have time to set configuration
		 */
		
		private function _addedToStage(e:Event) {

			//__set__vScrollPolicy(_vScrollPolicy);
			//__set__hScrollPolicy(_hScrollPolicy);
			ContentRendering.registerFrame(this);
			stage.addEventListener(Event.RESIZE, _stageResize);
			_stageResize(new Event(Event.RESIZE))

        };
		private function _stageResize(e:Event) {
			if (horisontalAutoScale && verticalAutoScale) {
				setSize(stage.stageWidth - marginLeft - marginRight, stage.stageHeight - marginTop - marginBottom);	
			}else if (horisontalAutoScale) {
				setSize(stage.stageWidth - marginLeft - marginRight, height);
			}else if (verticalAutoScale) {
				setSize(width, stage.stageHeight - marginTop - marginBottom);
			}
			
		}
		
			
		/*
        public function __set__vScrollPolicy = function (v) {
          _vScrollPolicy = v;
          holder.vScrollPolicy = v;
          return __get__vScrollPolicy();
        };

        public function __get__vScrollPolicy() { 
          return holder.vScrollPolicy;
        };

        public function __set__hScrollPolicy(v) {
          _hScrollPolicy = v;
          holder.hScrollPolicy = v;
          return __get__hScrollPolicy();
        };

        public function __get__hScrollPolicy() {
          return holder.hScrollPolicy;
        };

        public function __set__transitionType(v) {
          holder.transitionType = v;
          return __get__transitionType();
        };

        public function __get__transitionType() {
          return holder.transitionType;
        };

        public function refresh() {};

        v2.__set__x(s) {
          s = Math.round(s);
          if (holder._x < 0) {
            _x = s + holder._x;
            Debug.output('holder._x ' + holder._x);
          } else {
            _x = s;
          }
          return __get__x();
        };

        v2.__get__y() {
          if (holder._y < 0) {
            var v2 = _y - holder._y;
            return v2;
          } else {
            return _y;
          }
        };

        v2.__set__y(s) {
          s = Math.round(s);
          if (holder._y < 0) {
            _y = s + holder._y;
          } else {
            _y = s;
          }
          return __get__y();
        };


*/
		

        override protected function onGetPage(e:RenderingEvent) {
			Debug.output("Framebase get page from configurable")
			components = [];
			var v = 0;
			var content:TFPage = ContentRendering.page;
			var contentItem:TFContent;
			try {
				content.CONTENT.length
			}
			catch (e:Error)
			{
				Debug.output("Page not set yet, how come?")
				return;
			}
			while (v < content.CONTENT.length) {
				if (!content.CONTENT[v] is TFContent) {
					continue;
				}
				contentItem = content.CONTENT[v];
		
				try{
					if (contentItem.target == name) {
					  components.push(contentItem);
					  
					} else if (contentItem.component.path == name && contentItem.target == '') {
						components.push(contentItem);
					} else if (contentItem.target == '' && contentItem.component.path == '' && isDefaultFrame) {
						  components.push(contentItem);
					}
				}
				catch (e:Error) 	{
					Debug.output("FrameBase error: "+e)
				}
				++v;
			}
			if (components.length == 0) {
				unload();
				allContentLoaded = true;
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_FRAME_LOAD_COMPLETE));
			}else {
				load(components);
				allContentLoaded = false;
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_FRAME_LOAD_BEGIN));
			}
        };

        private function load(c:Array) {
			Debug.output("FrameBase about to load")
			Debug.output(c)
			//create local load queue
			content = new Sprite();
			var frameDataHolder:FrameDataHolder;
			var addedDefinitions : LoaderContext = new LoaderContext();
			addedDefinitions.applicationDomain = ApplicationDomain.currentDomain;
			if (Q) {
				oldQ = Q;
			}
			Q = new QueueLoader(false, addedDefinitions, true, "LoadQueue:"+name);
			
			Q.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onProgress,false,0,true);
			Q.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onComplete, false, 0, true);
			//Q.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemComplete,false,0,true);

			// TODO: Add filesize to component load info
			var v = 0;
			while (v < c.length) {
				frameDataHolder = new FrameDataHolder(c[v]);
				
				content.addChild(frameDataHolder);
				//_TFdata is passed on to loaded swf and picked up by glue
				Q.addItem(TF_CONF.HOST_URL + TFContent(c[v]).path + TFContent(c[v]).component.file,frameDataHolder.content,{name:TFContent(c[v]).name, frame:name});
				Debug.output("Adding queue item " +c[v].name)
				++v;

			}
			Q.execute();
			
        };
		
		/*
		 * Once components are loaded intoi holder sprite, use specific frame implementation to display them
		 */ 
		public function render(c:Sprite) {
			throw new Error("Override Framebase render function in extension class")
		}
		
        public function unload() {
			throw new Error("Override Framebase unload function in extension class")
			/*holder.contentPath = '';
			holder.unload(d);
			holder.holder._x = 0;
			holder.holder._y = 0;
			holder.hScroll.scrollPosition = holder.totW;
			holder.vScroll.scrollPosition = 0;
			holder.refresh();*/
        };
		/*
		 * Let TF_CONF.CORE/ContentRendering (which???) broadcast all frame loading events so as to keep the centrally accessible
		 */
		
		private function onProgress(e:QueueLoaderEvent) {
			if (e.info.frame == name) {
				ContentRendering.dispatchEvent(new RenderingEvent(RenderingEvent.ON_FRAME_LOAD_PROGRESS, this));
				if (TF_CONF.CORE) {
					TF_CONF.CORE.dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_PROGRESS, e, CoreEvent.LOAD_TYPE_COMPONENT));
				}
			}
		}

		private function onComplete(e:QueueLoaderEvent) {
			if (e.info.frame == name) {
				Debug.output("Frambase onComplete")
				//Debug.output(e.info)
				ContentRendering.dispatchEvent(new RenderingEvent(RenderingEvent.ON_FRAME_LOAD_COMPLETE,this));
				render(content);
				Q.removeEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onProgress);
				Q.removeEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onComplete);
				if (TF_CONF.CORE) {
					TF_CONF.CORE.dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_COMPLETE, e, CoreEvent.LOAD_TYPE_COMPONENT));
				}
				try{
					oldQ.dispose();
					oldQ = null;
				}
				catch (e:Error){}
			}
		}

		private function onItemComplete(e:QueueLoaderEvent) {
			if (e.info.frame == name) {
				Debug.output("onItemComplete.transferring TFdata")
				

				try{
					MovieClip(e.content)._TFdata = e.info._TFdata;
				}
				catch (e:Error) {
						Debug.output(e);
				}
			}
		}
		
        public function onDeleteContent(o) {
          var arr = [];
          var v = 0;
          while (v < components.length) {
            if (components.uid != o.data.uid) {
              arr.push(components[v]);
            }
            ++v;
          }
          components = arr;
          Debug.output('Frame to delete content uid: ' + o.data.uid);
          Debug.output(components);
        };

        public function onComponentLoaded(o) {
          var v = 0;
          while (v < components.length) {
            if (components[v].uid == o.key.uid) {
              components[v].key = o.key;
            }
            ++v;
          }
        };



        public function parseXMLdata(o, x) {
          return true;
        };

        public function onSequentialXYresizeComplete() {
			visible = true;
        };

        public function onQueueCleared(o) {
          allContentLoaded = true;
        };



      
		
	}
	
}