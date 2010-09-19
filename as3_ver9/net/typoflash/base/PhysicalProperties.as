package net.typoflash.base {

	
	/**
	 * Physical properties are all properties of a display object that are built into the Flash Player.
	 * They can be modified on the fly without any errors. A Configurable object, such as a Menu can have 
	 * meta data as well which contain the optional configurable data for the object.
	 * 
	 * The x,y and alpha properties can be edited by hand inside typo3 as well, and in that case they are
	 * applied immediately as the default values for the component, where as the physical properties
	 * stored from the use of the TypoFlash editor CAN be applied directly, but also be the the final
	 * values for a Tween. This way it is possible to set start and end values for a Tween. In later
	 * version we might find an explicit way of doing that in the editor alone.
	 * ...
	 * @author A. Borg
	 */
	public class PhysicalProperties extends ConfigurableProperties{
		public const x:ConfigurableProperty = new ConfigurableProperty("x", "X");
		public const y:ConfigurableProperty = new ConfigurableProperty("y", "Y");
		public const width:ConfigurableProperty = new ConfigurableProperty("width", "W");
		public const height:ConfigurableProperty = new ConfigurableProperty("height", "H");
		public const scaleX:ConfigurableProperty = new ConfigurableProperty("scaleX", "X Scale");
		public const scaleY:ConfigurableProperty = new ConfigurableProperty("scaleY", "Y Scale");
		public const alpha:ConfigurableProperty = new ConfigurableProperty("alpha", "Alpha");
		public const rotation:ConfigurableProperty = new ConfigurableProperty("rotation", "Rotation");
		
		private var _enumerable:Array = ['x', 'y','width', 'height', 'rotation', 'alpha'];//
			

		public function PhysicalProperties() {
			super();
			var v = _enumerable.length;
			while(v--){
				addProperty(this[_enumerable[v]]);
			}
			updateList();
			//{'x': 'x', 'y': 'y', 'width': 'width', 'height': 'height', 'rotation': 'rotation', 'alpha': 'alpha', 'scaleY': 'scaleY', 'scaleX': 'scaleX'};
			
		}
		

		
	}
	
}