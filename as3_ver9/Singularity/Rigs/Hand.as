//
// Hand.as - Manager class for a simple Biped Hand (finger links not currently used for simple 2D characters - this will be implemented later with a MultiConnector).
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
  import Singularity.Numeric.Consts;
  
  import Singularity.Rigs.Connector;
  import Singularity.Rigs.IChain;
  import Singularity.Rigs.Template;
  
  public class Hand extends Connector implements IChain
  { 
  	public static const LEFT:String  = "L";
  	public static const RIGHT:String = "R";
  	
  	// The rig *must* supply a drawing Template for the hand
    public function Hand(_x:Number, _y:Number, _w:Number, _h:Number, _type:String, _t:Template, _r:uint, _c:uint):void
    {
      super(_x, _y, _w, _h);
      
      NAME    = (_type == LEFT ) ? "L_Hand" : "R_HAND";
  	  ID      = (_type == LEFT ) ? 0 : 1;
  	  ENABLED = false;
  	  
  	  __pivotX   = _x + 0.5*_w;
  	  __pivotY   = _y;
  	  __x0       = __pivotX;
  	  __y0       = __pivotY;
  	  __length   = _h;
  	  __angle    = Consts.PI_2;
  	  __linkedTo = null;
  	  
  	  FILL_COLOR      = _r;
  	  ROLL_OVER_COLOR = _c;
  	  SELECTED_COLOR  = 0xff3300;
  	  
  	  // nonlinear scale to fit bounding-box (use half-width due to symmetry)
  	  setTemplate(_t,false,true,0.5*_w);
  	  
  	  // hand is not automatically drawn or enabled on construction -- this is up to the Rig
    }

    // assign terminator coordinates
    protected override function __assignTerminators(_x:Number, _y:Number, _w:Number, _h:Number):void
    { 
      __leftX = _x;
      __leftY = _y;
      
      __rightX = _x+_w;
      __rightY = _y;
    }
  }
}
