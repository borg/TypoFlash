//
// Leg.as - Two-link chain representing a Biped leg.
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
// Note:  Chain interactivity is disabled by default so that mouse interaction does not interfere with a GUI
// driving chain generation.  After the chain is completed, enabled it to react to mouse events.

package Singularity.Rigs
{
  import flash.display.Sprite;
  import flash.display.Shape;
    
  import Singularity.Numeric.Consts;
  
  import Singularity.Rigs.Bone;
  import Singularity.Rigs.Chain;
  import Singularity.Rigs.Template;
  
  public class Leg extends Chain
  { 
  	public static const LEFT:String       = "L";
  	public static const RIGHT:String      = "R";
  	public static const UPPER_LEG:String  = "UL";
  	public static const LOWER_LEG:String  = "LL";
  	public static const UPPER_FRAC:Number = 0.49;   // fraction of total leg distance used for upper leg
  	
  	// core
    private var __boundX:Number;         // bounding-box x-coordinate
  	private var __boundY:Number;         // bounding-box y-coordinate
  	private var __boundW:Number;         // bounding-box width
  	private var __boundH:Number;         // bounding-box height
  	
  	// an leg is constructed inside a bounding box and orientation depends on type of arm (LEFT or RIGHT)
    public function Leg(_x:Number, _y:Number, _w:Number, _h:Number, _type:String, _uLeg:Template, _lLeg:Template, _f:uint, _r:uint):void
    {
      super();
      
      NAME = (_type==LEFT) ? "L_Leg" : "R_LEG";
      
      __construct(_x, _y, _w, _h, _type, _uLeg, _lLeg);
      
      // set fill and rollOver colors
      fillColor     = _f;
      rollOverColor = _r;
      selectedColor = 0xff3300;
      
      __boundX = _x;
  	  __boundY = _y;
  	  __boundW = _w;
  	  __boundH = _h;
    }
    
    public function get boundX():Number { return __boundX; }
    public function get boundY():Number { return __boundY; }
    public function get boundW():Number { return __boundW; }
    public function get boundH():Number { return __boundH; }
    
    // construct the two leg bones - the Biped is considered facing forward, so right leg is to the left of centerline on stage
    private function __construct(_x:Number, _y:Number, _w:Number, _h:Number, _type:String, _uLeg:Template, _lLeg:Template):void
    {
      // note - the bounding-box width should be kept low to ensure the legs do not flare out too much
      
      // total distance of upper-arm and forearm bones
      var d:Number = Math.sqrt(_w*_w + _h*_h);
      
      var uX:Number;     // x-coordinate of unit-vector in arm direction
  	  var uY:Number;     // y-coordinate of unit-vector in arm direction
  	  var rootX:Number;  // x-coordinate of chain root
  	  var rootY:Number;  // y-coordinate of chain root
  	  var endX:Number;   // x-coordinate of chain end (end joint of forearm)
  	  var endY:Number;   // y-coordinage of chain end (end joint of forearm)
  	  var name:String;   // root name of each bone (indicating left or right arm)
  	  
      if( _type == LEFT )
      {
        rootX = _x;
        rootY = _y;
        endX  = _x+_w;
        endY  = _y+_h;
      	uX    = _w/d;
      	uY    = _h/d;
      	name  = "L_";
      }
      else
      {
      	rootX = _x+_w;
        rootY = _y;
        endX  = _x;
        endY  = _y+_h;
      	uX    = -_w/d;
      	uY    = _h/d;
      	name  = "R_";
      }
      
      var upperRatio:Number = UPPER_FRAC*d;
      var upperX:Number     = upperRatio*uX + rootX;
      var upperY:Number     = upperRatio*uY + rootY;
      
      addBoneAt(rootX, rootY, upperX, upperY, name+"UPPER_LEG", 0, Bone.CUSTOM, _uLeg, false);
      addBoneAt(upperX, upperY, endX, endY, name+"LOWER_LEG", 1, Bone.CUSTOM, _lLeg, false);
    }
    
  }
}
