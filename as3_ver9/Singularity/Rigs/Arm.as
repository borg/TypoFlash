//
// Arm.as - Two-link chain representing a Biped arm
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
  
  public class Arm extends Chain
  { 
  	public static const LEFT:String       = "L";
  	public static const RIGHT:String      = "R";
  	public static const UPPER_ARM:String  = "U";
  	public static const FORE_ARM:String   = "F";
  	public static const UPPER_FRAC:Number = 0.48;   // fraction of total arm distance used for upper arm
  	
  	// core
  	private var __boundX:Number;         // bounding-box x-coordinate
  	private var __boundY:Number;         // bounding-box y-coordinate
  	private var __boundW:Number;         // bounding-box width
  	private var __boundH:Number;         // bounding-box height
  	
  	// an arm is constructed inside a bounding box and orientation depends on type of arm (LEFT or RIGHT)
    public function Arm(_x:Number, _y:Number, _w:Number, _h:Number, _type:String, _uArm:Template, _fArm:Template, _f:uint, _r:uint):void
    {
      super();
      
      NAME = "Arm";
      
      __construct(_x, _y, _w, _h, _type, _uArm, _fArm);
      
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
    
    // construct the upper-arm and forearm chains - the Biped is considered facing forward, so right arm is flared out to the left of centerline on stage
    private function __construct(_x:Number, _y:Number, _w:Number, _h:Number, _type:String, _uArm:Template, _fArm:Template):void
    {
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
      
      addBoneAt(rootX, rootY, upperX, upperY, name+"UPPER_ARM", 0, Bone.CUSTOM, _uArm, false);
      addBoneAt(upperX, upperY, endX, endY, name+"FOREARM", 1, Bone.CUSTOM, _fArm, false);
    }
    
  }
}
