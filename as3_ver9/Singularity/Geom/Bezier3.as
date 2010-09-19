//
// Bezier3.as - Generate cubic Bezier curve given four control points.  Curve evaluation using
// nested multiplication.  This version supports plotting via recursive subdivision, however the
// implementation is intended for *illustration* of a 'textbook' successive midpoint approximation --
// this class is NOT coded for performance.
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
// Programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
// Note:  Set the container reference before calling any drawing methods
//
// Version 1.1 - Added Bezier y-at-x method
//         1.2 - New Parametric methods and updated for arc-length parameterization
//

package Singularity.Geom
{
  import flash.display.Graphics;
  import flash.geom.ColorTransform;
  
  import Singularity.Geom.Parametric;
  import Singularity.Numeric.Consts;
  import Singularity.Numeric.SimpleRoot;
  import Singularity.Numeric.Solve2x2;
  import flash.geom.Point;

  public class Bezier3 extends Parametric
  {
  	// properties
    public var FIT:uint;                 // fitness metric for stopping subdivision -- ranges from 1-10.  1 = very tight fit.  10 = very loose fit.
    
  	// core
    protected var __p0X:Number;            // x-coordinate, first control point
    protected var __p0Y:Number;            // y-coordinate, first control point
    protected var __p1X:Number;            // x-coordinate, second control point
    protected var __p1Y:Number;            // y-coordinate, second control point
    protected var __p2X:Number;            // x-coordinate, third control point
    protected var __p2Y:Number;            // y-coordinate, third control point
    protected var __p3X:Number;            // x-coordinate, fourth control point
    protected var __p3Y:Number;            // y-coordinate, fourth control point

    // subdivisions
    protected var __cubicCage:Array;       // each element contains an array of four control points, describing the subdivided cage
    protected var __numSeg:Number;         // number of cubic segments making up the complete curve         
    protected var __tolerance:Number;      // actual tolerance on distance squared between quad(0.5) and cubic(0.5)
    protected var __distSQ:Array;          // tolerance (1-10) maps into this distance squared scale
    protected var __isTol:Array;           // true if the ith segment is within tolerance
    protected var __pX:Number;             // x-coordinate of 'intersection' point of quad control cage
    protected var __pY:Number;             // y-coordinate of 'intersection' point of quad control cage
    
    // root-finding (y at x)
    protected var __root:SimpleRoot;
    protected var __left:Number;
    protected var __right:Number;
    protected var __bisectIter:uint;
    protected var __bisectLimit:Number;
    
    // four-point interpolation
    protected var __t1:Number;
    protected var __t2:Number;
    protected var __solver:Solve2x2;

/**
* @description 	Method: Bezier3() - Construct a new Bezier3 instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function Bezier3()
    {
      FIT = 1;
          
      __p0X         = 0;
      __p0Y         = 0;
      __p1X         = 0;
      __p1Y         = 0;
      __p2X         = 0;
      __p2Y         = 0;
      __p3X         = 0;
      __p3Y         = 0;
      __pX          = 0;
      __pY          = 0;
      __left        = 0;
      __right       = 0;
      __bisectIter  = 0;
      __bisectLimit = 0;
      __t1          = 0;
      __t2          = 0;
      
      __cubicCage  = new Array();
      __distSQ     = new Array();
      __isTol      = new Array();
      __coef       = new Cubic();
      __invalidate = true;
      __numSeg     = 1;

      __distSQ[0] = 4;
      __distSQ[1] = 9;
      __distSQ[2] = 16;
      __distSQ[3] = 25;
      __distSQ[4] = 36;
      __distSQ[5] = 49;
      __distSQ[6] = 64;
      __distSQ[7] = 81;
      __distSQ[8] = 121;
      __distSQ[9] = 144;

      __tolerance = __distSQ[FIT-1];
      
      __error.classname = "Bezier3";

      __coef      = new Cubic();
      __container = null;
      __solver    = null;
      
      __root = null;
    }

/**
* @description 	Method: addControlPoint( _xCoord:Number, _yCoord:Number ) - Add a control point
*
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
*
* @return Nothing - Adds control points in order called up to two four.  Attempt to add more than
* the required number of control points results in an error.
*
* @since 1.0
*
*/
    public override function addControlPoint( _xCoord:Number, _yCoord:Number ):void
    {
      if( __count == 4 )
      {
        __error.methodname = "addControlPoint()";
        __error.message    = "Point limit exceeded";
        dispatchEvent( __error );
        return;
      }

     switch( __count )
      {
        case 0 :
          __p0X = _xCoord;
          __p0Y = _yCoord;
          __count++;
        break;
      
        case 1 :
          __p1X = _xCoord;
          __p1Y = _yCoord;
          __count++;
        break;
        
        case 2 :
          __p2X = _xCoord;
          __p2Y = _yCoord;
          __count++;
        break;
        
        case 3 :
          __p3X = _xCoord;
          __p3Y = _yCoord;
          __count++;
        break;
      }
      __invalidate = true;
    }
    
/**
* @description 	Method: moveControlPoint(_indx:uint, _newX:Number, _newY:Number) - Move a control point
*
* @param _indx:uint - Index of control point (0, 1, 2, or 3)
* @param _newX:Number - New x-coordinate
* @param _newY:Number - New y-coordinate
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function moveControlPoint(_indx:uint, _newX:Number, _newY:Number):void
    {
      __error.methodname = "moveControlPoint()";
      
      if( _indx < 0 || _indx > 3 )
      {
        __error.message = "Invalid index: " + _indx.toString();
        dispatchEvent(__error);
        return;
      }
 
      if( isNaN(_newX) )
      {
        __error.message = "Invalid x-coordinate.";
        dispatchEvent(__error);
        return;
      }

      if( isNaN(_newY) )
      {
        __error.message = "Invalid y-coordinate.";
        dispatchEvent(__error);
        return;
      }
  
      switch( _indx )
      {
        case 0 :
          __p0X = _newX; 
          __p0Y = _newY;
        break;
      
        case 1 :
          __p1X = _newX;
          __p1Y = _newY;
        break;
    
        case 2 :
          __p2X = _newX;
          __p2Y = _newY;
        break;
        
        case 3 :
          __p3X = _newX;
          __p3Y = _newY;
        break;
      }

      __invalidate = true;
      __resetSubdiv();
    }

/**
* @description 	Method: getControlPoint(_indx:uint) - accesss the specified control point
*
* @param _indx:uint - Index of control point (0, 1, 2, or 3)
*
* @return Point reference to a <code>Point</code> representing the control vertex or (0,0) if the index is out of range for a cubic curve
*
* @since 1.2
*
*/
    override public function getControlPoint(_indx:uint):Point
    {
      switch( _indx )
      {
        case 0:
          return new Point(__p0X, __p0Y);
        break;
        
        case 1:
          return new Point(__p1X, __p1Y);
        break;
        
        case 2:
          return new Point(__p2X, __p2Y);
        break;
        
        case 3:
          return new Point(__p3X, __p3Y);
        break;    	
      }	
      
      return new Point(0,0);
    }
    
/**
* @description 	Method: reset() - Remove control points
*
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function reset():void
    {
      __p0X = 0;
      __p0Y = 0;
      __p1X = 0;
      __p1Y = 0;
      __p2X = 0;
      __p2Y = 0;
      __p3X = 0;
      __p3Y = 0;
      __t1  = 0;
      __t2  = 0;

      __invalidate = true;
      __count      = 0;

      __coef.reset();
      __resetSubdiv();
    }


/**
* @description 	Method: getX( _t:Number ) - Return x-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: x-coordinate of cubic Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
*
* @since 1.2
*
*/
    public override function getX(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();
    
       __setParam(t);
      return __coef.getX(__t);
    }

/**
* @description 	Method: getY( _t:Number ) - Return y-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: y-coordinate of cubic Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
*
* @since 1.2
*
*/
    public override function getY(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();

       __setParam(t);
      return __coef.getY(__t);
    }
    
/**
* @description 	Method: getXPrime( _t:Number ) - Return x-coordinate of first deriviative for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: x-coordinate of first derivative of cubic bezier.
*
* @since 1.2
*
*/
    public override function getXPrime(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();
    
      return __coef.getXPrime(t);
    }

/**
* @description 	Method: getYPrime( _t:Number ) - Return y-coordinate of first derivative for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: y-coordinate of first derivative of cubic Bezier.
*
* @since 1.2
*
*/
    public override function getYPrime(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();

      return __coef.getYPrime(t);
    }

/**
* @description 	Method: draw(_t:Number) - Draw the cubic Bezier up to the specified parameter
*
* @param _t:Number - parameter value in [0,1]
*
* @return Nothing - cubic curve is plotted from t=0 to t=_t.
*
* @since 1.0
*
*/
    public override function draw(_t:Number):void
    {
      if( _t<=0 || _t>1 )
        return; 
      else if( _t < 1 )
        // this will be made more efficient in the future
        __linePlot(_t);
      else
      {
      	if( __invalidate )
          __computeCoef();
        
        // The following could be implemented with recursive calls in Flash, but serves to illustrate the process in 
        // an easy to understand, if less elegant manner.  There is also (traditionally) a lot of overhead to
        // implement recursive calls at runtime in any programming language.
        var finished:Boolean = false;
        
        // compute tolerance based on current user-specified fit
        var __fit:uint = Math.max(1,FIT);
        __fit          = Math.min(10,__fit);
        __tolerance    = __distSQ[__fit-1];
        
        // You could add a segment counter to prohibit too many iterations
        while( !finished )
        {
          // test each segment
          finished = true;
          for( var i:uint=0; i<__numSeg; ++i )
          {
            var knots:Array = __cubicCage[i];
            __intersect(knots);
            if( __numSeg == 1 )
            {
              // force at least one subdivision
              __isTol[i] = false;
              finished   = false;	
            }
            else
            {
              __isTol[i] = (__midpointDeltaSq(knots) <= __tolerance);
              finished   = finished && __isTol[i];
            }
          }

          if( !finished )
          {
            var segs:uint = __numSeg;
            var j:uint    = 0;
            for( i=0; i<segs; ++i )
            {
              if( !__isTol[j] )
              {
                __subdivide(0.5, j+1);
                j += 2;
              }
              else
                j++;
            }
          }
        }

        __plot();
      }
    }
    
/**
* @description 	Method: arcLength() - Return arc-length of the *entire* curve by numerical integration
*
* @return Number: Estimate of total arc length of the curve
*
* @since 1.0
*
*/
    public override function arcLength():Number
    {
      if( __invalidate )
        __computeCoef();

      return __integral.eval( __integrand, 0, 1, 5 );
    }
    
    
/**
* @description 	Method: reColor(_c:Number) - Recolor the quad. curve
*
* @param _c:Number - Hex code for curve color
*
* @return Nothing
*
* @since 1.0
*
* Note:  For performance reasons, no error checking is performed
*
*/
    public override function reColor(_c:Number):void
    {
      var g:Graphics = __container.graphics;
      
      var colorXForm:ColorTransform = __container.transform.colorTransform;
      colorXForm.color = _c;
      __container.transform.colorTransform = colorXForm;
    }

/**
* @description 	Method: reDraw() - Redraw the curve with its base color
*
* @return Nothing
*
* @since 1.0
*
* Note:  For performance reasons, no error checking is performed
*
*/
    public override function reDraw():void
    {
      var g:Graphics = __container.graphics;
      
      var colorXForm:ColorTransform = __container.transform.colorTransform;
      colorXForm.color = __color;
      __container.transform.colorTransform = colorXForm;
    }

/**
* @description 	Method: interpolate( _points:Array ) - Compute control points so that cubic Bezier passes through four points
*
* @param _points:Array - array of three Objects with x- and y-coordinates in .X and .Y properties.  These points represent the coordinates of the interpolation points.
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function interpolate(_points:Array):void
    {
      // no error-checking ... you break it, you buy it.
      var p0:Object = _points[0];
      __p0X        = p0.x;
      __p0Y        = p0.y;
     
      var p1:Object = _points[1];
      var p2:Object = _points[2];
      
      var p3:Object = _points[3];
      __p3X         = p3.x;
      __p3Y         = p3.y;
      
      // currently, this method auto-parameterizes the curve using chord-length parameterization.  A future version might allow inputting the two t-values, but this is more
      // user-friendly (what an over-used term :)  As an exercise, try uniform parameterization - t1 = 13/ and 52 = 2/3.
      var deltaX:Number = p1.x - p0.x;
      var deltaY:Number = p1.y - p0.y;
      var d1:Number     = Math.sqrt(deltaX*deltaX + deltaY*deltaY);
      
      deltaX        = p2.x - p1.x;
      deltaY        = p2.y - p1.y;
      var d2:Number = Math.sqrt(deltaX*deltaX + deltaY*deltaY);
      
      deltaX        = p3.x - p2.x;
      deltaY        = p3.y - p2.y;
      var d3:Number = Math.sqrt(deltaX*deltaX + deltaY*deltaY);
      
      var d:Number = d1 + d2 + d3;
      __t1         = d1/d;
      __t2         = (d1+d2)/d;
      
      // there are four unknowns (x- and y-coords for P1 and P2), which are solved as two separate sets of two equations in two unknowns
      var t12:Number = __t1*__t1;
      var t13:Number = __t1*t12;
      
      var t22:Number = __t2*__t2;
      var t23:Number = __t2*t22;
      
      // x-coordinates of P1 and P2 (t = t1 and t2) - exercise: eliminate redudant computations in these equations
      var a11:Number = 3*t13 - 6*t12 + 3*__t1;
      var a12:Number = -3*t13 + 3*t12;
      var a21:Number = 3*t23 - 6*t22 + 3*__t2;
      var a22:Number = -3*t23 + 3*t22;
      
      var b1:Number = -t13*__p3X + __p0X*(t13 - 3*t12 + 3*__t1 -1) + p1.x;
      var b2:Number = -t23*__p3X + __p0X*(t23 - 3*t22 + 3*__t2 -1) + p2.x;
      
      if( __solver == null )
      {
        __solver = new Solve2x2();
      }
      
      // exercise - handle situation where determinant is less than or equal to zero tolerance - what happens with nearly or exactly coincident
      // interior interpolation points?
      var p:Point = __solver.solve(a11, a12, a21, a22, b1, b2);
      __p1X       = p.x
      __p2X       = p.y;
     
      // y-coordinates of P1 and P2 (t = t1 and t2)      
      b1 = -t13*__p3Y + __p0Y*(t13 - 3*t12 + 3*__t1 -1) + p1.y;
      b2 = -t23*__p3Y + __p0Y*(t23 - 3*t22 + 3*__t2 -1) + p2.y;
      
      // resolving with same coefficients, but new RHS
      p     = __solver.solve(a11, a12, a21, a22, b1, b2, 0.00001, true);
      __p1Y = p.x
      __p2Y = p.y;
         
      __invalidate = true;
      __count      = 4;
    }
    
    public override function getParam(_seg:uint):Number 
    {
      switch( _seg )
      {
        case 1:
          return __t1;
        break;
        
        case 2:
          return __t2;
        break;
        
        default:
          return 0;
      }
    }
    
/**
* @description 	Method: yAtX( _x:Number ) - Return the set of y-coordinates corresponding to the input x-coordinate
*
* @param _x:Number x-coordinate at which the desired y-coordinates are desired
*
* @return Array set of (t,y)-coordinates at the input x-coordinate provided that the x-coordinate is inside the range
* covered by the quadratic Bezier in [0,1]; that is there must exist t in [0,1] such that Bx(t) = _x.  If the input
* x-coordinate is not inside the range covered by the Bezier curve, the returned array is empty.  Otherwise, the
* array contains either one or two y-coordinates.  There are issues with curves that are exactly or nearly (for
* numerical purposes) vertical in which there could theoretically be an infinite number of y-coordinates for a single
* x-coordinate.  This method does not work in such cases, although compensation might be added in the future.
*
* Each array element is a reference to an <code>Object</code> whose 't' parameter represents the Bezier t parameter.  The
* <code>Object</code> 'y' property is the corresponding y-value.  The returned (t,y) coordinates may be used by the caller
* to determine which of two returned y-coordinates might be preferred over the other.
*
* @since 1.1
*
*/
    // exercise - make the root-finding tolerance an optional parameter or provide a setter function to allow it to be
    // set by the caller in advance
    public function yAtX(_x:Number):Array
    {
      if( isNaN(_x) )
      {
        return [];
      }
      
      // the necessary y-coordinates are the intersection of the curve with the line x = _x.  The curve is generated in the
      // form c0 + c1*t + c2*t^2 + c3*t^3, so the intersection satisfies the equation 
      // Bx(t) = _x or Bx(t) - _x = 0, or c0x-_x + c1x*t + c2x*t^2 + c3x*t^3 = 0.
      if( __invalidate )
        __computeCoef();
        
      // this is written out in individual steps for clarity
      var c0:Object  = __coef.getCoef(0);
      var c1:Object  = __coef.getCoef(1);
      var c2:Object  = __coef.getCoef(2);
      var c3:Object  = __coef.getCoef(3);
      var c0X:Number = c0.X;
      var c1X:Number = c1.X;
      var c2X:Number = c2.X;
      var c3X:Number = c3.X;
       
      // Find one root - any root - then factor out (t-r) to get a quadratic poly. for the remaining roots
      var f:Function = function(_t:Number):Number { return _t*(c1X + _t*(c2X + _t*(c3X))) + c0X-_x; }
         
      if( __root == null )
        __root = new SimpleRoot();
      
      // some curves that loop around on themselves may require bisection
      __left        = 0;
      __right       = 1;
      __bisectLimit = 0.05;
      __bisect(f, __left, __right);
        
      // experiment with tolerance - but not too tight :)  
      var t0:Number = __root.findRoot(__left, __right, f, 50, 0.0000001);
      var eval:Number = Math.abs(f(t0));
      if( eval > 0.0000001 )
        return [];   // compensate in case method quits due to error (no event listener here)
      
      var result:Array = new Array();
      if( t0 <= 1 )
        result.push({t:t0, y:getY(t0)});  
      
      // Factor theorem: t-r is a factor of the cubic polynomial if r is a root.  Use this to reduce to a quadratic poly.
      // using synthetic division
      var a:Number = c3.X;
      var b:Number = t0*a+c2.X;
      var c:Number = t0*b+c1.X;
      
      // process the quadratic for the remaining two possible roots
      var d:Number = b*b - 4*a*c;
      if( d < 0 )
      {
        return result;
      }
      
      d             = Math.sqrt(d);
      a             = 1/(a + a);
      var t1:Number = (d-b)*a;
      var t2:Number = (-b-d)*a;
      
      if( t1 >= 0 && t1 <=1 )
        result.push({t:t1, y:getY(t1)});
        
      if( t2 >= 0 && t2 <=1 )
        result.push({t:t2, y:getY(t2)});
        
      return result;
    }
    
    // bisect the specified range to isolate an interval with a root.
    protected function __bisect(_f:Function, _left:Number, _right:Number):void
    {
      if( Math.abs(_right-_left) <= __bisectLimit )
      {
        return;
      }
        
      var left:Number   = _left;
      var right:Number  = _right;
      var middle:Number = 0.5*(left+right);
      if( _f(left)*_f(right) <= 0 )
      {
        __left  = left;
        __right = right;
        return;
      }
      else
      {
        __bisect(_f, left, middle);
        __bisect(_f, middle, right);
      }
    }
    
    // split the current control cage at t
    protected function __subdivide( _t:Number, _j:uint ):void
    {
      var t1:Number   = 1.0 - _t;
      var left:Array  = new Array();   // left cubic segment
      var right:Array = new Array();   // right cubic segment
      var knots:Array = __cubicCage[_j-1];

      // p1X = knots[0]; p1Y = knots[1]; p2X = knots[2]; p2Y = knots[3]; p3X = knots[4]; p3Y = knots[5]; p4X = knots[6]; p4Y = knots[7]
      left[0] = knots[0];
      left[1] = knots[1];

      var p11X:Number = t1*knots[0] + _t*knots[2];
      var p11Y:Number = t1*knots[1] + _t*knots[3];

      var p21X:Number = t1*knots[2] + _t*knots[4];
      var p21Y:Number = t1*knots[3] + _t*knots[5];

      var p31X:Number = t1*knots[4] + _t*knots[6];
      var p31Y:Number = t1*knots[5] + _t*knots[7];

      var p12X:Number = t1*p11X + _t*p21X;
      var p12Y:Number = t1*p11Y + _t*p21Y;

      var p22X:Number = t1*p21X + _t*p31X;
      var p22Y:Number = t1*p21Y + _t*p31Y;

      var p13X:Number = t1*p12X + _t*p22X;
      var p13Y:Number = t1*p12Y + _t*p22Y;

      left[2] = p11X;
      left[3] = p11Y;

      left[4] = p12X;
      left[5] = p12Y;

      left[6] = p13X;
      left[7] = p13Y;

      right[0] = p13X;
      right[1] = p13Y;

      right[2] = p22X;
      right[3] = p22Y;

      right[4] = p31X;
      right[5] = p31Y;

      right[6] = knots[6];
      right[7] = knots[7];

      if( __cubicCage.length == 1 )
      {
        __cubicCage[0] = left;
        __cubicCage[1] = right;
      }
      else
      {
        delete __cubicCage[_j-1];

        // index _j-1 is overwritten and index _j is inserted
        for( var i:uint=__cubicCage.length; i>_j; i-- )
          __cubicCage[i] = __cubicCage[i-1];

        __cubicCage[_j]   = right;
        __cubicCage[_j-1] = left;
      }

      __numSeg++;
    }

    protected function __plot():void
    {
      // show complete cubic and quad control cages as well as approximating plot
      var g:Graphics = __container.graphics;
      g.clear();
      g.lineStyle(__thickness, __color);

      for( var i:uint=0; i<__numSeg; ++i )
      {  
        // plot cubic cage for this segment
        var knots:Array = __cubicCage[i];

        // compute middle control point for quad. bezier
        __intersect(knots);

        // quadratic segment
        g.moveTo(knots[0], knots[1]);
        g.curveTo(__pX, __pY, knots[6], knots[7]);

      }
    }
    
    protected function __linePlot(_t:Number):void
    {
      var p:Number = Math.max(1.0,_t);
            
      // in the future, this method will be replaced by an initial subdivision at t=_t followed by 
      // recursive midpoint subdivision on the left control cage.
      var d:Number = p*this.arcLength();

      var deltaT:Number = 2.0/d;
      var g:Graphics    = __container.graphics;
      g.clear();
      g.lineStyle(__thickness, __color);
      
      g.moveTo(__p0X,__p0Y);
      for( var t:Number=deltaT; t<=p; t+=deltaT )
        g.lineTo(getX(t), getY(t)); 
    }

    // compute intersection of p0-p1 and p3-p2 segments
    protected function __intersect(_points:Array):void
    {
      var deltaX1:Number = _points[2] - _points[0];
      var deltaX2:Number = _points[4] - _points[6];
      var d1Abs:Number   = Math.abs(deltaX1);
      var d2Abs:Number   = Math.abs(deltaX2);
      var m1:Number      = 0;
      var m2:Number      = 0;

      if( d1Abs <= Consts.ZERO_TOL )
      {
        __pX  = _points[0];
        m2    = (_points[5] - _points[7])/deltaX2;
        __pY  = (d2Abs <= Consts.ZERO_TOL) ? (_points[0] + 3*(_points[1]-_points[0])) : (m2*(_points[0]-_points[6])+_points[7]);
      }
      else if( d2Abs <= Consts.ZERO_TOL )
      {
        __pX = _points[6];
        m1   = (_points[3] - _points[1])/deltaX1;
        __pY = (d1Abs <= Consts.ZERO_TOL) ? (_points[4] + 3*(_points[4]-_points[6])) : (m1*(_points[6]-_points[0])+_points[1]);
      }
      else if( Math.abs(m1) <= Consts.ZERO_TOL && Math.abs(m2) <= Consts.ZERO_TOL )
      {
        __pX = 0.5*(_points[2] + _points[4]);
        __pY = 0.5*(_points[3] + _points[5]);
      }
      else
      {
        m1 = (_points[3] - _points[1])/deltaX1;
        m2 = (_points[5] - _points[7])/deltaX2;

        if( Math.abs(m1) <= Consts.ZERO_TOL && Math.abs(m2) <= Consts.ZERO_TOL )
        {
           __pX = 0.5*(_points[0] + _points[6]);
           __pY = 0.5*(_points[1] + _points[7]);
        }
        else
        {
          var b1:Number = _points[1] - m1*_points[0];
          var b2:Number = _points[7] - m2*_points[6];
          __pX          = (b2-b1)/(m1-m2);
          __pY          = m1*__pX + b1;
        }
      }
      
      __invalidate = true;
    }

    // compute square of distance between cubic and quad. segments at t=0.5
    protected function __midpointDeltaSq(_points:Array):Number
    {
      // cubic cage at points (_points[0], _points[1]), (_points[2], _points[3]), (_points[4], _points[5]), (_points[6], _points[7])
      // quadratic cage at points (_points[0], _points[1]), (__pX, __pY), (_points[6], _points[7])

      var deltaX:Number = _points[0] + 4*__pX - 3*(_points[2]+_points[4]) + _points[6];
      var deltaY:Number = _points[1] + 4*__pY - 3*(_points[3]+_points[5]) + _points[7];
    
      return 0.015625*(deltaX*deltaX + deltaY*deltaY);
    }

    // reset subdivision because control point was moved
    protected function __resetSubdiv():void
    {
      __cubicCage.splice(0);
      __isTol.splice(0);

      __numSeg = 1;
    }

    public override function __computeCoef():void
    {
      if( __count < 3 )
  	  {
  	    __error.methodname = "__computeCoef()";
  	    __error.message    = "Insufficient number of control points";
  	    dispatchEvent(__error);
  	  }
  	  else
  	  {
  	  	__coef.reset();
  	  	
        __coef.addCoef( __p0X, __p0Y )
        
        var dX:Number = 3.0*(__p1X-__p0X);
        var dY:Number = 3.0*(__p1Y-__p0Y);
        __coef.addCoef(dX, dY);

        var bX:Number = 3.0*(__p2X-__p1X) - dX;
        var bY:Number = 3.0*(__p2Y-__p1Y) - dY;
        __coef.addCoef(bX, bY);
        
        __coef.addCoef(__p3X - __p0X - dX - bX, __p3Y - __p0Y - dY - bY);

        // copy original cage for use in subdivision.
        var c:Array = new Array();
        c[0] = __p0X;
        c[1] = __p0Y;
        c[2] = __p1X;
        c[3] = __p1Y;
        c[4] = __p2X;
        c[5] = __p2Y;
        c[6] = __p3X;
        c[7] = __p3Y;

        __cubicCage[0] = c;

        __arcLength  = -1;
        __parameterize();
        __invalidate = false;
      }
    }
  }
}