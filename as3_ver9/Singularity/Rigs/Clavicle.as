//
// Clavicle.as - Manager class for a single-link Biped Clavicle (used for 2D characters with single-segment torso)
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
//
// Note:  Unlike other connectors, the clavicle pivot points depend on 'left' or 'right' orientation, so
// an extra argument is required in the constructor.

package Singularity.Rigs
{
  import Singularity.Numeric.Consts;
  
  import Singularity.Rigs.Connector;
  import Singularity.Rigs.Template;
  
  public class Clavicle extends Connector
  { 
    public static const LEFT:String  = "L";
    public static const RIGHT:String = "R";
    
  	// The rig *must* supply a drawing Template for the clavicle 
    public function Clavicle(_x:Number, _y:Number, _w:Number, _h:Number, _o:String, _t:Template, _r:uint, _c:uint):void
    {
      super(_x, _y, _w, _h);
      
      NAME    = (_o == LEFT ) ? "L_CLAVICLE" : "R_CLAVICLE";
  	  ID      = (_o == LEFT ) ? 0 : 1
  	  ENABLED = false;
  	  
  	  __pivotX      = _x;
  	  __pivotY      = _y+0.5*_h;
  	  __x0          = __pivotX;
  	  __y0          = __pivotY;
  	  var mX:Number = 0;
  	  var mY:Number = __pivotY;
  	  
  	  // pivot points and terminators depend on orientation - left clavicle extends to the right on Stage as Biped is facing forward
  	  if( _o == LEFT )
  	  {
  	  	__angle = Math.atan2(_h,_w);
        mX      = _w;   
  	  }
  	  else
  	  {
  	    __angle = Math.atan2(_h,-_w);
  	  	mX      = -_w;
  	  }
  	    
  	  // only the mid-terminator is used and needs to be transformed based on the angle
  	  __length     = _w;
  	  var a:Number = (_o==LEFT) ? __angle : __angle-Math.PI;
  	  var c:Number = Math.cos(a);
  	  var s:Number = Math.sin(a);
  	  
      __midX = mX*c + __x0;
      __midY = mX*s + __y0;
  	  
  	  FILL_COLOR      = _r;
  	  ROLL_OVER_COLOR = _c;
  	  SELECTED_COLOR  = 0xff3300;
  	  
  	  // nonlinear scale to fit bounding-box (use half-height due to symmetry)
  	  setTemplate(_t,false,true,0.5*_h);
  	  
  	  // spine is not automatically drawn or enabled on construction -- this is up to the Rig
    }
    
    // assign terminator coordinates
    protected override function __assignTerminators(_x:Number, _y:Number, _w:Number, _h:Number):void
    { 
      // empty
    }
  }
}
