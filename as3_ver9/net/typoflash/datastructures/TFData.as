package net.typoflash.datastructures 
{
	
	/**
	 * CONTENT is all that which comes from the database record. It contains information about swf location
	 * title, any text written in the Typo3 record, media_category etc. In a way it is the swf configuration
	 * set in Typo3. It is not retrieve using the unique configuration key but from the frame loader as 
	 * 
	 * _TFdata = FrameDataHolder(_TFconfigurable.root.parent.parent.parent).data;
	 * 
	 * CONFIGURATION on the other hand is all that which is set through the TypoFlash interface. The same swf
	 * can have several Configurable Objects, and while each share the same CONTENT property on their data
	 * they have different CONFIGURATION. The Configuration Key is generated from a mixture of the database ids
	 * and the rootline of depth location of the configurable in the display list. This is the only way I have found
	 * to generate a unique id from within flash. The weakness is that you cannot move around the components
	 * in any way without loosing the TypoFlash configuration. A special copy and paste can be used for that.
	 * 
	 * public function getPageData() {
			var d = ContentRendering.getData(_TFkey);
			for (var n in d) {
				_TFdata.CONFIGURATION[n] = d[n];
			}
        };
	 * ...
	 * @author Borg
	 */
	public dynamic class TFData extends Object{
		
		public var CONTENT:TFContent;
		public var CONFIGURATION:TFConfData;
		
		
		public function TFData() 	{
			CONTENT = new TFContent({});
			CONFIGURATION = new TFConfData();
		}
		
	}
	
}