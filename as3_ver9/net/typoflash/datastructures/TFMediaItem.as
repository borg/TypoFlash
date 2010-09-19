package net.typoflash.datastructures 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public dynamic class TFMediaItem {
		public var pid:uint;
		public var hpixels:uint;
		public var height:uint;
		public var width:uint;
		public var file_inode:String;
		public var category:String;//not list of uid, but number of categories it is in.
		public var sys_language_uid:String;
		public var file_path:String;
		public var ident:String;
		public var title:String;
		public var alt_text:String;
		public var starttime:int;
		public var file_mtime:String;
		public var t3ver_stage:String;
		public var abstract:String;
		public var loc_country:String;
		public var file_creator:String;
		public var l18n_diffsource:String;
		public var t3ver_state:String;
		public var cruser_id:uint;
		public var uid_foreign:uint;
		public var loc_city:String;
		public var deleted:String;
		public var file_type:String;
		public var t3ver_tstamp:String;
		public var height_unit:String;
		public var file_ctime:String;
		public var date_mod:String;
		public var index_type:String;
		public var t3ver_oid:String;
		public var uid_local:String;
		public var file_dl_name:String;
		public var meta:String;
		public var tablenames:String;
		public var file_status:String;
		public var file_type_version:String;
		public var file_orig_loc_desc:String;
		public var file_mime_type:String;
		public var keywords:String;
		public var tstamp:String;
		public var vpixels:uint;
		public var t3ver_count:String;
		public var description:String;
		public var l18n_parent:uint;
		public var pages:String;
		public var sorting:uint;
		public var media_type:String;
		public var file_name:String;
		public var t3ver_wsid:String;
		public var uid:uint;
		public var copyright:String;
		public var parent_id:String;
		public var sorting_foreign:String;
		public var publisher:String;
		public var t3ver_id:String;
		public var color_space:String;
		public var file_hash:String;
		public var caption:String;
		public var crdate:String;
		public var file_orig_location:String;
		public var active:String;
		public var fe_group:String;
		public var file_usage:String;
		public var search_content:String;
		public var creator:String;
		public var language:String;
		public var t3ver_label:String;
		public var hidden:String;
		public var file_size:String;
		public var instructions:String;
		public var vres:String;
		public var file_mime_subtype:String;
		public var loc_desc:String;
		public var endtime:String;
		public var date_cr:String;
		public var hres:String;

		public function TFMediaItem(o:Object) {
			for (var n in o) {
				this[n]  = o[n];
			}
			
		}
		public function toString():String {
			return "[TFMediaItem " + title +", uid: "+uid+", number of categories: " +category+"]";
		}		
	}
	
}