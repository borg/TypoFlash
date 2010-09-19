//
// SingularityEvent.as - Common event manager for Singularity library.
//
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.  
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
// programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
//

package Singularity.Events
{
  import flash.events.Event;
  
  public class SingularityEvent extends Event
  {
  	public static const ERROR:String     = "E";
  	public static const WARNING:String   = "W";
  	public static const INIT:String      = "I";
  	public static const COMPLETE:String  = "C";
  	public static const ROLL_OVER:String = "OVR";
  	public static const ROLL_OUT:String  = "OUT";
  	public static const SELECTED:String  = "S";
  	public static const ID:String        = "ID";
  	
  	private var __type:String;      // Event type
  	private var __message:String;   // Message associated with event
  	private var __class:String;     // Class name associated with this event
  	private var __method:String;    // Method name associated with this event
  	
    public function SingularityEvent(_typ:String, _bubbles:Boolean = false, _cancelable:Boolean = false ):void 
    {
      super(_typ, _bubbles, _cancelable);
      
      __type       = _typ;
      __message    = "";
      __class      = "";
      __method     = "";
    }
    
    public function get classname():String  { return __class;  }
    public function get methodname():String { return __method; }
    public function get errType():String    { return __type;   }
    
    public function set classname(_s:String):void
    {
      if( _s != "" )
        __class = _s;
    }
    
    public function set methodname(_m:String):void
    {
      if( _m != "" )
        __method = _m;
    }
    
    public function set message(_m:String):void
    {
      if( _m != "" )
        __message = _m;
    }
    
    public override function clone():Event
    {
      return new SingularityEvent(__type);
    }
    
    public override function toString():String 
    { 
      return "From: " + __class + "::" + __method + " , message: " + __message;
    }
  }
}