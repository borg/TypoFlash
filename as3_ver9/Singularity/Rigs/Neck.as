//
// Neck.as- Manager class for a Biped Neck (with a single optional terminator at the end effecor).
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
// Note:  Interactivity is disabled by default so that mouse interaction does not interfere with a GUI
// driving chain generation.  After the chain is completed, enabled it to react to mouse events.

package Singularity.Rigs
{
  import flash.display.Sprite;
  import flash.display.Shape;
    
  import flash.events.MouseEvent;
  
  import Singularity.Numeric.Consts;
  
  public class Neck extends Connector
  { 
  	
    public function Neck(_x:Number, _y:Number, _w:Number, _h:Number, _t:Template, _r:uint, _c:uint):void
    {
      super(_x, _y, _w, _h);
      
      NAME         = "Neck";
  	  ID           = 0
  	  ENABLED      = false;
  	  
  	  __pivotX  = _x + 0.5*_w;
  	  __pivotY  = _y + _h;
  	  __x0      = __pivotX;
  	  __y0      = __pivotY;
  	  __length  = _h;
  	  __angle   = Consts.THREE_PI_2;
  	  
  	  FILL_COLOR      = _r;
  	  ROLL_OVER_COLOR = _c;
  	  SELECTED_COLOR  = 0xff3300;
  	  
  	  // nonlinear scale to fit bounding-box (use half-width due to symmetry)
  	  setTemplate(_t,false,true,0.5*_w);
  	  
  	  // neck is not automatically drawn or enabled on construction -- this is up to the Rig
    }
    
    // assign terminator coordinates
    protected override function __assignTerminators(_x:Number, _y:Number, _w:Number, _h:Number):void
    { 
      __leftX = _x;
      __leftY = _y+0.5*_h;
      
      __midX = _x + 0.5*_w;
      __midY = _y;
      
      __rightX = _x + _w;
      __rightY = __leftY;
    }
  }
}
