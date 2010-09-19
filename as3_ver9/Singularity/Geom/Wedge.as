/**
* Wedge.as - Simple pie-shaped wedge drawing class using a quad. Bezier as a primitive.
*
* copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.  For educational use only - commercial use strictly prohibited.
*
* This software program is supplied 'as is' without any warranty, express, implied, 
* or otherwise, including without limitation all warranties of merchantability or fitness
* for a particular purpose.  2112 F/X shall not be liable for any special
* incidental, or consequential damages, including, without limitation, lost
* revenues, lost profits, or loss of prospective economic advantage, resulting
* from the use or misuse of this software program.
*
* @author Jim Armstrong
* @version 1.0
*
* Note:  For performance reasons, there is minimal error-checking
*/
package Singularity.Geom
{
  import flash.display.Shape;
  import flash.display.Graphics;
	
  public class Wedge
  {
    public static const PI4_INV:Number = 4.0/Math.PI;

    private var __radius:Number;        // radius of circular arc
    private var __xC:Number;            // x-coordinate of center
    private var __yC:Number;            // y-coordinate of center
    private var __startAngle:Number;    // start-angle in radians
    private var __endAngle:Number;      // end-angle in radians
    private var __delta:Number;         // difference between start and end angles
    private var __radInv:Number;        // inverse of radius

    // quad. bezier fit through these points
    private var __p0X:Number;
    private var __p0Y:Number;
    private var __p1X:Number;
    private var __p1Y:Number;
    private var __p2X:Number;
    private var __p2Y:Number;

/**
* @description 	Method: Wedge(_r:Number, _xC:Number, _yC:Number, _start:Number, _end:Number) - Construct a new Wedge instance
*
* @param _r:Number     - radius value in px
* @param _xC:Number    - x-coordinate of center
* @param _yC:Number    - y-coordinate of center
* @param _start:Number - start angle in radians
* @param _end:Number   - end angle in radians
*
* @return Nothing
*
* @since 1.0
*
* Note: All angle arguments *must* be in radians
*/
    public function Wedge(_r:Number, _xC:Number, _yC:Number, _start:Number, _end:Number)
    {
      __radius = _r > 0 ? _r : 10;
      __xC     = _xC;
      __yC     = _yC;
      __radInv = 1.0/__radius;

      __startAngle = _start;
      __endAngle   = _end;
      __delta      = __endAngle - __startAngle;

      __p0X = 0;
      __p0Y = 0;
      __p1X = 0;
      __p1Y = 0;
      __p2X = 0;
      __p2Y = 0;
    }

    public function set xC(_n:Number):void { __xC = _n; }
    public function set yC(_n:Number):void { __yC = _n; }
    
    public function set startAngle(_n:Number):void { __startAngle = _n; }
    
    public function set endAngle(_n:Number):void   
    { 
      __endAngle = _n; 
      __delta    = __endAngle - __startAngle;  
    }

/**
* @description 	Method: draw( _s:Shape, _lineThick:Number, _lineColor:Number, _fillColor:Number, _fillAlpha:Number ) - Draw the wedge
*
* @param _s:Shape           - reference to Shape in which wedge is drawn
* @param _lineThick:Number - line thickness
* @param _lineColor:Number - line color
* @param _fillColor:Number - fill color
* @param _fillAlpha:Number - fill alpha
*
* @return Nothing - Note that this method draws the wedge from scratch; it is less efficient if the
* end angle is constantly incremented and the wedge continuously redrawn.
*
* @since 1.0
*
*/
    public function draw( _s:Shape, _lineThick:Number, _lineColor:Number, _fillColor:Number, _fillAlpha:Number ):void
    {
      if( _s == null || __delta == 0 )
        return;

      var thick:Number = Math.max(0,_lineThick);
      
      var g:Graphics = _s.graphics;
      g.clear();
      g.lineStyle(thick,_lineColor);
      g.beginFill(_fillColor,_fillAlpha);

      // break total arc into an equal number of segments of at most PI/4 rad.
      var numSeg:Number = Math.ceil(Math.abs(__delta*PI4_INV));
	  var arc:Number    = __delta/numSeg;

      // p is the vector from the origin of the wedge to (p0X,p0Y)
      // q is the vector from the origin of the wedge to (p2X,p2Y)
      // the vector p+q bisects the angle between p and q.  The middle interpolation point is
      // 'radius' units along that bisector.
      var pX:Number    = __radius*Math.cos(__startAngle);
      var pY:Number    = __radius*Math.sin(__startAngle);
      __p0X            = __xC + pX;
      __p0Y            = __yC + pY;
      var qX:Number    = 0;
      var qY:Number    = 0;
      var angle:Number = __startAngle;
 
      // wedge begins with a line from starting point to initial p.
      g.moveTo(__xC,__yC);
      g.lineTo(__p0X,__p0Y);

      // approximate each arc with a quad. Bezier
      for( var i:uint=0; i<numSeg; ++i )
      {
        angle += arc;
        qX     = __radius*Math.cos(angle);
        qY     = __radius*Math.sin(angle);
        __p2X  = __xC + qX;
        __p2Y  = __yC + qY;

        // unit vector in direction of bisector - alternative approach is two more trig. calcs to compute the coordinates.
        // let's have some fun and do it a different way.
        var dX:Number = (pX+qX)*__radInv;
        var dY:Number = (pY+qY)*__radInv;
        var d:Number  = Math.sqrt(dX*dX + dY*dY);
        dX /= d;
        dY /= d;

        // middle interpolation point is a distance of 'radius' units along direction of bisecting unit vector
        __p1X  = __xC + __radius*dX;
        __p1Y  = __yC + __radius*dY;

        // compute control point so that quad. Bezier passes through (__p0X,__p0Y), (__p1X,__p1Y), and (__p2X,__p2Y) at t=0.5
        var cX:Number = 2.0*__p1X - 0.5*(__p0X + __p2X);
        var cY:Number = 2.0*__p1Y - 0.5*(__p0Y + __p2Y);

        // You can compute the control point directly with nothing but sin & cos, but if memory serves it takes
        // four more trig comps. for a total of six per loop iteration.
        g.curveTo(cX, cY, __p2X, __p2Y);

        // end point is start point for next iteration
        __p0X = __p2X;
        __p0Y = __p2Y;
        pX    = qX;
        pY    = qY;
      }
    
      // draw line from last point on the arc to the origin of the wedge
      g.lineTo(__xC,__yC);
      g.endFill();
    }
  }
}