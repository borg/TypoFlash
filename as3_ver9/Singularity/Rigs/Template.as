//
// Template.as - Symmetric Bone-drawing Template
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
// Note:  Templates define symmetric control points used to draw Bones.  Bone Templates are symmetric
// about the positive x-axis.  The first point in a Template is *always* (0,0).  The last point in a
// Template is always (100,0).  All coordinates should be positive.  
//
// The line segment from (0,0) to (100,0) is mapped along the length of a Bone.  Other points are scaled accordingly and
// the reflection (to handle symmetry) is handled in the Bone class.

package Singularity.Rigs
{
  public class Template
  { 
  	// properties
  	public var USE_SPLINE:Boolean;  // true if the Template points are interpolated with a cubic Bezier spline
  	
  	// core
    private var __points:Array;     // array of Template points (only symmetric part)
    private var __index:uint;       // index into Template point array
    private var __count:uint;       // total number of points
    private var __max:Number;       // maximum y-coord
    
    public function Template():void
    {
      USE_SPLINE = false;
      
      __points = new Array();
      __index  = 0;
      __count  = 2;
      
      __points[0] = 0;
      __points[1] = 0;
      __points[2] = 100;
      __points[3] = 0;
      
      __max = 0;
    }
    
    public function get count():uint { return __count; }
    public function get max():Number { return __max;   }
    
    // insert point into the Template
    public function insert(_x:Number, _y:Number):void
    {
      __index            += 2
      __points[__index]   = _x;
      __points[__index+1] = _y;
      __points[__index+2] = 100;
      __points[__index+3] = 0;
      
      __max = Math.max(__max,_y);
      __count++;
    }
    
    public function getPoints():Array { return __points.slice(); }
    
    // reset the Template for new data
    public function reset():void
    {
      USE_SPLINE = false;
      
      __points.splice(0);
      __index  = 0;
      __count  = 2;
      
      __points[0] = 0;
      __points[1] = 0;
      __points[2] = 100;
      __points[3] = 0;
    }
    
    // reset the current Template and copy new data from another Template
    public function copy(_t:Template):void
    {
      reset();
      
      var pts:Array = _t.getPoints();
      for( var i:uint = 0; i<pts.length; ++i )
        __points[i] = pts[i];
        
      USE_SPLINE = _t.USE_SPLINE;
      __count    = _t.count;
      __index    = __count-2;	
    }
  }
}
