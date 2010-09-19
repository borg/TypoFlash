//
// Knot.as - Visual representation of knot.
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
// Programmed by:  Jim Armstrong, Singularity (www.algorithmist.net)
//

package Singularity.Geom
{
  import Singularity.Events.SingularityEvent;
  
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.display.Graphics;
  
  import flash.geom.ColorTransform;
  
  public class Knot extends Sprite
  { 
    // core
    private var __id:Number;                 // id - corresponds to index, so must be >= 0
    private var __label:String;              // knot label
    private var __color:uint;                // record knot color
    private var __w:uint;                    // knot width
    private var __w2:uint;                   // knot half-width
    
    // events
    private var __rollOver:SingularityEvent; // rollover event
    private var __rollOut:SingularityEvent;  // rollout event
    private var __selected:SingularityEvent; // knot selected event 


    public function Knot(_width:uint, _c:uint)
    {
      super();
      
      __init(_width, _c);
    }

    private function __init(_width:uint, _c:uint):void
    {
      __id    = 0;
      __label = "";
      __color = _c;

      __rollOver = new SingularityEvent(SingularityEvent.ROLL_OVER);
      __rollOut  = new SingularityEvent(SingularityEvent.ROLL_OUT);
      __selected = new SingularityEvent(SingularityEvent.SELECTED);
      
      __rollOver.classname = "Knot";
      __rollOut.classname  = "Knot";
      __selected.classname = "Knot";
      
      addEventListener( MouseEvent.ROLL_OVER, __knotRollOver );
      addEventListener( MouseEvent.ROLL_OUT , __knotRollOut  );
      addEventListener( MouseEvent.CLICK    , __knotSelected );
      
      // draw the icon associated with this knot
      __w  = Math.max(6,_width);
      __w2 = Math.round(0.5*__w);
      
      graphics.lineStyle(1, 0x000000);
      graphics.beginFill(_c);
      graphics.drawRect(-__w2,-__w2, __w, __w );
    }

    private function __knotRollOver(_e:MouseEvent):void
    {
      dispatchEvent(__rollOver);
    }
    
    private function __knotRollOut(_e:MouseEvent):void
    { 
      dispatchEvent(__rollOut);
    }
    
    private function __knotSelected(_e:MouseEvent):void
    { 
      dispatchEvent(__selected);	
    }

    public function get id():uint { return __id; }

    public function set id(_i:uint):void    
    { 
      if( _i >= 0 )
        __id = _i;
    }

    public function set label(_s:String):void
    {
      if( _s != "" && _s != " " )
        __label = _s; 
    }
    
    public function color(_c:uint):void
    {
      graphics.clear();
      graphics.lineStyle(1, 0x000000);
      graphics.beginFill(_c);
      graphics.drawRect(-__w2,-__w2, __w, __w );
    }
    
    public function resetColor():void
    {
      graphics.clear();
      graphics.lineStyle(1, 0x000000);
      graphics.beginFill(__color);
      graphics.drawRect(-__w2,-__w2, __w, __w);
    }

    public function destruct():void
    {
      graphics.clear();
      
      removeEventListener( MouseEvent.ROLL_OVER, __knotRollOver );
      removeEventListener( MouseEvent.ROLL_OUT , __knotRollOut  );
      removeEventListener( MouseEvent.CLICK    , __knotSelected );
    }
  }
}