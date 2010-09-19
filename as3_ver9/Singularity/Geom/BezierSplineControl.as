//
// BezierSplineControl.as - Construct control cages for a composite cubic Bezier spline.
//
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, 
// or consequential damages, including, without limitation, lost revenues, lost profits, 
// or loss of prospective economic advantage, resulting from the use or misuse of this 
// software program.
//
// Programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
//
// Usage:  Set knots array (knots setter), then call construct() method to construct all control
// cages.  Call construct() again after any knot move.  Anticipated usage is that most, if not all,
// knots are changed each frame, so this method recomputes all cages from scratch.
//
// Note:  For performance, there is no error checking.  You break it, you buy it :)
//

package Singularity.Geom
{
  import Singularity.Numeric.Consts;
  import flash.display.Shape;
  
  public class BezierSplineControl
  {
  	// properties
  	public var CLOSED:Boolean;     // true if closed spline
  	
    // core
    private var __bXNR:Number;     // bisector 'right' normal, x-coordinate
    private var __bYNR:Number;     // bisector 'right' normal, y-coordinate
    private var __bXNL:Number;     // bisector 'left' normal, x-coordinate
    private var __bYNL:Number;     // bisector 'left' normal, y-coordinate
    private var __pX:Number;       // reflected point, x-coordinate
    private var __pY:Number;       // reflected point, y-coordinate

    private var __dX1:Number;      // delta-x, first segment
    private var __dY1:Number;      // delta-y, first segment
    private var __dX2:Number;      // delta-x, second segment
    private var __dY2:Number;      // delta-y, second segment
    private var __d1:Number;       // first segment length
    private var __d2:Number;       // second segment length
    private var __tension:Number;  // tension parameter (1-5)
    private var __uX:Number;       // unit vector, direction of bisector, x-coordinate
    private var __uY:Number;       // unit vector, direction of bisector, y-coordinate
    private var __dist:Number;     // distance measure from segment intersection, along direction of bisector

    private var __cage:Array;      // CubicCage instances for each segment
    private var __points:Array;    // knots
    private var __numPoints:uint;  // number of knots
    private var __tensionMap:Array // map user-specified tension value (1-5) into fraction of segment distance (0.1-0.4)

    public function BezierSplineControl()
    {
      CLOSED       = false;
      
      __points     = new Array();
      __cage       = new Array();
      __tensionMap = new Array();

      __bXNR = 0;
      __bYNR = 0;
      __bXNL = 0;
      __bYNL = 0;
      __pX   = 0;
      __pY   = 0;

      __dX1  = 0;
      __dY1  = 0;
      __dX2  = 0;
      __dY2  = 0;
      __d1   = 0;
      __d2   = 0;

      __uX   = 0;
      __uY   = 0;
      __dist = 0;

      __tension   = 1;
      __numPoints = 0;

      // These are arbitrary, so experiment and have fun.  Don't go over 0.5 or very bad things will
      // happen.  Do you know why?  Less than 0.1 is kind of useless as you might as well just connect
      // the knots with lines and be done with it :)  0.3 is pretty good 'middle' ground.  Low values
      // have low tension and the tension increases as the index increases.  Lower tension increases
      // the probability of 'ripples'.
      __tensionMap[0] = 0.4;
      __tensionMap[1] = 0.3;
      __tensionMap[2] = 0.25;
      __tensionMap[3] = 0.175;
      __tensionMap[4] = 0.1;
    }

    public function get tension():Number { return __tension; }

    public function set knots(_a:Array):void
    {
      // Sets reference only; does not copy knots.  Only needs to be set once, then construct() can be called after changes to the original knot set
      __points = _a;
    }

    public function set tension(_t:Number):void
    {
      var n:Number = Math.round(_t);
      if( n > 0 && n < 6 )
        __tension = _t-1;
    }

/**
* @description 	Method: getCage(_i:Number) - draw the control cages
*
* @param _i:Number - Control-cage index (i-th segment, not i-th knot), zero based
* @return Nothing
*
* @since 1.0
*
* Note:  No out-of-range checking, caveat receptor!
*/
    public function getCage(_i:Number):CubicCage
    {
      return __cage[_i];
    }

/**
* @description 	Method: construct() - construct all control cages based on current knot set
*
* @return Nothing
*
* @since 1.0
*
*/
    public function construct():void
    {
      var count:uint = __points.length-1;
      __numPoints    = __points.length;
      
      if( count < 2 )
        return;      // safety valve

      for( var i:uint=0; i<count; ++i )
      {
        if( __cage[i] == undefined )
          __cage[i] = new CubicCage();
      }

      // Hint:  How could you insert extra knots at each end (like Catmull-Rom splines) in a manner such that
      // the bisector normal computations produced the same set of points as the reflection computations.
      // It would be a bit quicker and you could compress the following code structure into one method.  It's
      // also easier than you might think ... so think about it!
      var t:Number = __tensionMap[__tension];

      // Exercise:  Consolidate some of the common computations among the following methods.

      if( CLOSED )
        __leftClosed(t);  // 'leftmost' cage, closed spline
      else
        __left(t);        // 'leftmost' cage, open spline (requires a reflection point)

      // 'middle' cages
      for( var j:uint=1; j<count-1; ++j )
        __cageCoef(j, t);

      if( CLOSED )
        __rightClosed(t);  // 'rightmost' cage, closed spline
      else
        __right(t);        // 'rightmost' cage, open splne (requires a reflection point)
    }

/**
* @description 	Method: draw(_s:Shape, _c:Number) - draw the control cages
*
* @param _s:Shape  - reference to Shape in which control cages are drawn
* @param _c:Number - hex color code for lines
*
* @return Nothing
*
* @since 1.0
*
*/
    public function draw(_s:Shape, _c:Number):void
    {
      for( var i:uint=0; i<__cage.length; ++i )
        __cage[i].draw(_s, _c);
    }

    // compute 'middle' control cages
    private function __cageCoef(_i:uint, _t:Number):void
    {
      __getNormals(_i);
      
      var coef:CubicCage = __cage[_i];
      coef.P0X = __points[_i].X;
      coef.P0Y = __points[_i].Y;
      coef.P1X = __bXNL;
      coef.P1Y = __bYNL;

      if( __dist > Consts.ZERO_TOL )
      {
        if( __isClockWise(__points, _i) )
          __CW(_i, _t);
        else
          __CCW(_i, _t);
      }
      else
      {
        __bXNR = __points[_i].X + _t*__dX1;
        __bYNR = __points[_i].Y + _t*__dY1;

        __bXNL = __points[_i].X + _t*__dX2;
        __bYNL = __points[_i].Y + _t*__dY2;
      }

      coef.P2X = __bXNR;
      coef.P2Y = __bYNR;
      coef.P3X = __points[_i+1].X;
      coef.P3Y = __points[_i+1].Y;
    }
    
    private function __getNormals(_i:uint):void
    {
      __dX1  = __points[_i].X - __points[_i+1].X;
      __dY1  = __points[_i].Y - __points[_i+1].Y;
      __d1   = Math.sqrt(__dX1*__dX1 + __dY1*__dY1);
      __dX1 /= __d1;
      __dY1 /= __d1;

      __dX2  = __points[_i+2].X - __points[_i+1].X;
      __dY2  = __points[_i+2].Y - __points[_i+1].Y;
      __d2   = Math.sqrt(__dX2*__dX2 + __dY2*__dY2);
      __dX2 /= __d2;
      __dY2 /= __d2;

      __uX   = __dX1 + __dX2;
      __uY   = __dY1 + __dY2;
      __dist = Math.sqrt(__uX*__uX + __uY*__uY);
      __uX  /= __dist; 
      __uY  /= __dist;	
    }

    // 'leftmost' control cage, open spline
    private function __left(_t:Number):void
    {
      __getNormals(0);

      if( __dist > Consts.ZERO_TOL )
      {
        if( __isClockWise(__points, 0) )
          __CW(0, _t);
        else
          __CCW(0, _t);

        var mX:Number = 0.5*(__points[0].X + __points[1].X);
        var mY:Number = 0.5*(__points[0].Y + __points[1].Y);
        var pX:Number = __points[0].X - mX;
        var pY:Number = __points[0].Y - mY;

        // normal at midpoint
        var n:Number  = 2.0/__d1;
        var nX:Number = -n*pY;
        var nY:Number = n*pX;

        // upper triangle of symmetric transform matrix
        var a11:Number = nX*nX - nY*nY
        var a12:Number = 2*nX*nY;
        var a22:Number = nY*nY - nX*nX;

        var dX:Number = __bXNR - mX;
        var dY:Number = __bYNR - mY;

        // coordinates of reflected vector
        __pX = mX + a11*dX + a12*dY;
        __pY = mY + a12*dX + a22*dY;
      }
      else
      {
        __bXNR = __points[1].X + _t*__dX1;
        __bYNR = __points[1].Y + _t*__dY1;

        __bXNL = __points[1].X + _t*__dX2;
        __bYNL = __points[1].Y + _t*__dY2;

        __pX = __points[0].X + _t*__dX1;
        __pY = __points[0].Y + _t*__dY1;
      }
          
      var coef:CubicCage = __cage[0];

      coef.P0X = __points[0].X;
      coef.P0Y = __points[0].Y;
      coef.P1X = __pX;
      coef.P1Y = __pY;
      coef.P2X = __bXNR;
      coef.P2Y = __bYNR;
      coef.P3X = __points[1].X;
      coef.P3Y = __points[1].Y;
    }

    // 'leftmost' control cage, closed spline
    private function __leftClosed(_t:Number):void
    {
      // point order is n-2, 0, 1 (as 0 and n-1 are the same knot in a closed spline).  Use 'right normal' to set first two control cage points
      var n2:uint = __numPoints-2;
      
      // Exercise - modify the argument list for __getNormals() to work with the following computations
      __dX1  = __points[n2].X - __points[0].X;
      __dY1  = __points[n2].Y - __points[0].Y;
      __d1   = Math.sqrt(__dX1*__dX1 + __dY1*__dY1);
      __dX1 /= __d1;
      __dY1 /= __d1;

      __dX2  = __points[1].X - __points[0].X;
      __dY2  = __points[1].Y - __points[0].Y;
      __d2   = Math.sqrt(__dX2*__dX2 + __dY2*__dY2);
      __dX2 /= __d2;
      __dY2 /= __d2;

      __uX   = __dX1 + __dX2;
      __uY   = __dY1 + __dY2;
      __dist = Math.sqrt(__uX*__uX + __uY*__uY);
      __uX  /= __dist; 
      __uY  /= __dist;

      if( __dist > Consts.ZERO_TOL )
      {
      	if( ((__points[1].Y-__points[n2].Y)*(__points[0].X-__points[n2].X) > (__points[0].Y-__points[n2].Y)*(__points[1].X-__points[n2].X)) )
      	{
          var dt:Number = _t*__d2;
          __bXNL        = __points[0].X + dt*__uY;
          __bYNL        = __points[0].Y - dt*__uX;
        }
        else
        {
          dt     = _t*__d2;
          __bXNL = __points[0].X - dt*__uY;
          __bYNL = __points[0].Y + dt*__uX;
        }
      }
      else
      {
        __bXNL = __points[0].X + _t*__dX1;
        __bYNL = __points[0].Y + _t*__dY1;
      }
      
      var coef:CubicCage = __cage[0];
      coef.P0X = __points[0].X;
      coef.P0Y = __points[0].Y;
      coef.P1X = __bXNL;
      coef.P1Y = __bYNL;
      
      // now, continue as before using the point order 0, 1, 2
      __getNormals(0);

      if( __dist > Consts.ZERO_TOL )
      {
        if( __isClockWise(__points, 0) )
          __CW(0, _t);
        else
          __CCW(0, _t);
      }
      else
      {
        __bXNR = __points[1].X + _t*__dX1;
        __bYNR = __points[1].Y + _t*__dY1;

        __bXNL = __points[1].X + _t*__dX2;
        __bYNL = __points[1].Y + _t*__dY2;
      }
      
      coef.P2X = __bXNR;
      coef.P2Y = __bYNR;
      coef.P3X = __points[1].X;
      coef.P3Y = __points[1].Y;
    }

    // 'rightmost' control cage, open spline
    private function __right(_t:Number):void
    {
      if( __dist > Consts.ZERO_TOL )
      {
        var count:Number = __points.length-1;
        var mX:Number = 0.5*(__points[count-1].X + __points[count].X);
        var mY:Number = 0.5*(__points[count-1].Y + __points[count].Y);
        var pX:Number = __points[count].X - mX;
        var pY:Number = __points[count].Y - mY;

        // normal at midpoint
        var n:Number  = 2.0/__d2;
        var nX:Number = -n*pY;
        var nY:Number = n*pX;

        // upper triangle of symmetric transform matrix
        var a11:Number = nX*nX - nY*nY
        var a12:Number = 2*nX*nY;
        var a22:Number = nY*nY - nX*nX;

        var dX:Number = __bXNL - mX;
        var dY:Number = __bYNL - mY;

        // coordinates of reflected vector
        __pX = mX + a11*dX + a12*dY;
        __pY = mY + a12*dX + a22*dY;
      }
      else
      {
        __pX = __points[count].X - _t*__dX2;
        __pY = __points[count].Y - _t*__dY2;
      }

      var coef:CubicCage = __cage[count-1];

      coef.P0X = __points[count-1].X;
      coef.P0Y = __points[count-1].Y;
      coef.P1X = __bXNL;
      coef.P1Y = __bYNL;
      coef.P2X = __pX;
      coef.P2Y = __pY;
      coef.P3X = __points[count].X;
      coef.P3Y = __points[count].Y;
    }
    
    // 'rightmost' control cage, closed spline
    private function __rightClosed(_t:Number):void
    {
      // no additional computations are required as the P2X, P2Y point is a reflection of the P1X, P1Y point from the very first control cage
      var count:Number = __numPoints-1;

      var c0:CubicCage   = __cage[0];
      var coef:CubicCage = __cage[count-1];

      coef.P0X = __points[count-1].X;
      coef.P0Y = __points[count-1].Y;
      coef.P1X = __bXNL;
      coef.P1Y = __bYNL;
      coef.P2X = 2.0*__points[0].X - c0.P1X;
      coef.P2Y = 2.0*__points[0].Y - c0.P1Y;
      coef.P3X = __points[count].X;           // knot number 'count' and knot number 0 should be the same for a closed spline
      coef.P3Y = __points[count].Y;
    }


    // bisector normal computations, clockwise knot order
    private function __CW(_i:int, _t:Number):void
    {
      var dt:Number = _t*__d1;

      __bXNR = __points[_i+1].X - dt*__uY;
      __bYNR = __points[_i+1].Y + dt*__uX;

      dt     = _t*__d2;
      __bXNL = __points[_i+1].X + dt*__uY;
      __bYNL = __points[_i+1].Y - dt*__uX;
    }

    // bisector normal computations, counter-clockwise knot order
    private function __CCW(_i:int, _t:Number):void
    {
      var dt:Number = _t*__d2;

      __bXNL = __points[_i+1].X - dt*__uY;
      __bYNL = __points[_i+1].Y + dt*__uX;

      dt     = _t*__d1;
      __bXNR = __points[_i+1].X + dt*__uY;
      __bYNR = __points[_i+1].Y - dt*__uX;
    }

    // clockwise order for three-knot sequence?
    private function __isClockWise(_pts:Array, _i:Number):Boolean 
    {
      return ((_pts[_i+2].Y-_pts[_i].Y)*(_pts[_i+1].X-_pts[_i].X) > (_pts[_i+1].Y-_pts[_i].Y)*(_pts[_i+2].X-_pts[_i].X));
    }
  }
}