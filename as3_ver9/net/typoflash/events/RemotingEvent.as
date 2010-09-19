package net.typoflash.events{
	import flash.events.Event;



	public class RemotingEvent extends Event {
		public static const REQUEST:String = "onRequest";
		public static const DATA:String = "onData";
		public static const FAULT:String = "onFault";
		//these changes need to be global somehow..can send them from global["CORE"] for instance
		public static const CHANGED_RECORD:String = "onRecordChanged";//send table and data (including uid as data property)
		public static const NEW_RECORD:String = "onRecordNew";
		public static const DELETED_RECORD:String = "onRecordDeleted";
		
		public var data:*;
		


		
		public function RemotingEvent(type:String,d:*=''){
			data = d;
			super(type, true);
		
		}
		
		public override function clone():Event {
			return new RemotingEvent(type,data);
		}
	}
}