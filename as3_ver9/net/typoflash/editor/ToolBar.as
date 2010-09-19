package net.typoflash.editor 
{
	import flash.display.Sprite;
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.typoflash.events.EditingEvent;
	import net.typoflash.utils.Cookie;
	import net.typoflash.events.AuthEvent;
	import net.typoflash.datastructures.TFConfig;
	
	/**
	 * ...
	 * @author Borg
	 */
	public class ToolBar extends Sprite	{
		
		public var TF_CONF:TFConfig  = TFConfig.global;
		
		public function ToolBar() {
			parent.addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		private function init(e:Event) {
			txtBtn.addEventListener(MouseEvent.CLICK, setTextMode);
			Button(txtBtn).toggle = true;
			moveBtn.addEventListener(MouseEvent.CLICK, setMoveMode);
			Button(moveBtn).toggle = true;
			snap_chk.addEventListener(MouseEvent.CLICK, setSnapMode);
			if (Cookie.global.getData('snap')) {
				snap_chk.selected = true;
			}
			
			txt_y.restrict = txt_x.restrict = txt_w.restrict = txt_h.restrict = "0-9";
			
			TypoFlash(TF_CONF.EDITOR).addEventListener(EditingEvent.ON_SET_EDIT_MODE, onSetEditMode); 
			TypoFlash(TF_CONF.EDITOR).editMode = EditingEvent.EDIT_MODE_MOVE;	
			
			TypoFlash(TF_CONF.EDITOR).transformTool.addEventListener(TransformTool.NEW_TARGET, transformSelect, false, 0, true);
			//TypoFlash(TF_CONF.EDITOR).transformTool.addEventListener(TransformTool., transformDeselect);
			TypoFlash(TF_CONF.EDITOR).transformTool.addEventListener(TransformTool.CONTROL_MOVE, transformChange, false, 0, true);
			
			TypoFlash(TF_CONF.EDITOR).transformTool.addEventListener(TransformTool.CONTROL_UP, transformDone, false, 0, true);
			txtBg = 0x666666;
		}
		
		private function transformSelect(e:Event) {
			if(TypoFlash(TF_CONF.EDITOR).transformTool.target){
				txtBg = 0xCCCCCC;
			}else {
				txtBg = 0x666666;
			}
		}
		
		private function set txtBg(v:uint) {
			txt_x.backgroundColor = txt_y.backgroundColor = txt_w.backgroundColor = txt_h.backgroundColor = v;
				

		}
		private function transformChange(e:Event) {
			if(TypoFlash(TF_CONF.EDITOR).transformTool.target){
				txt_x.text = String(TypoFlash(TF_CONF.EDITOR).transformTool.target.x);
				txt_y.text = String(TypoFlash(TF_CONF.EDITOR).transformTool.target.y);
				txt_w.text = String(TypoFlash(TF_CONF.EDITOR).transformTool.target.width);
				txt_h.text = String(TypoFlash(TF_CONF.EDITOR).transformTool.target.height);
			}
		}
		
		
		private function transformDone(e:Event) {
			if (TypoFlash(TF_CONF.EDITOR).transformTool.target) {
				trace("Transform done")
			}
		}
		
		private function onSetEditMode(e:EditingEvent) {
			if (e.data == EditingEvent.EDIT_MODE_MOVE) {
				txtBtn.selected = false;
			}else if(e.data == EditingEvent.EDIT_MODE_TEXT) {
				moveBtn.selected = false;
			}
		}
		private function setMoveMode(e:MouseEvent) {
			TypoFlash(TF_CONF.EDITOR).editMode = EditingEvent.EDIT_MODE_MOVE;
			
			
		}
		private function setTextMode(e:MouseEvent) {
			TypoFlash(TF_CONF.EDITOR).editMode = EditingEvent.EDIT_MODE_TEXT;
		}	
		
		private	function setSnapMode(e:MouseEvent):void {
			var cb:CheckBox = CheckBox(e.target);
			Cookie.global.setData('snap',cb.selected);
			
		}
	}
	
}