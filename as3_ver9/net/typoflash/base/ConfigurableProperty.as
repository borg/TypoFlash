package net.typoflash.base 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public class ConfigurableProperty 	{
		public var name:String;
		public var label:String;//How the property is labeled in editor
		public var value:*;
		public var description:String;//Optional explanatory note for editor panel
		public var editor:String;//Class reference to be retrieved dynamically
		public var editorPath:String;//Path from where to load exernal editor
		public var max:*;//optional limits on value
		public var min:*;
		public var enabled:Boolean = true;
		
		public function ConfigurableProperty(_name:String, _label:String,_value:*=null,_min:*=null,_max:*=null,_editor:String=null, _desc:String=''){
			name = _name;
			value = _value;
			label = _label;
			description = _desc;
			min = _min;
			max = _max;
			editor = _editor;
		}
		
	}
	
}