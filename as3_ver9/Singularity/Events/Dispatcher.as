package Singularity.Events
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;
 
  public class Dispatcher implements IEventDispatcher 
  {
    private var __myDispatcher:EventDispatcher;
       
    public function Dispatcher() 
    {
      __myDispatcher = new EventDispatcher(this);
    }
   
    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
    {
      __myDispatcher.addEventListener.apply(null, arguments);
    }

    public function dispatchEvent(event:Event):Boolean 
    {
      return __myDispatcher.dispatchEvent.apply(null, arguments);
    }
           
    public function hasEventListener(type:String):Boolean 
    {
      return __myDispatcher.hasEventListener.apply(null, arguments);
    }
           
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
    {
      __myDispatcher.removeEventListener.apply(null, arguments);
    }
           
    public function willTrigger(type:String):Boolean 
    {
      return __myDispatcher.willTrigger.apply(null, arguments);
    }
  }
}