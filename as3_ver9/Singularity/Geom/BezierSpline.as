//
// BezierSpline.as - Piecewise cubic Bezier spline using fast drawing algorithm.  This class can be
// used for fast drawing of of a smooth curve through multiple knots, with some shape control over 
// the curve via a tension parameter.  It may also be used for general path animation with tension
// control, optional closed-path control, and velocity control (arc-length parameterization).  
//
// Reference: www.algorithmist.net/composite.html
//
//
// copyright (c) 2006-2007, 2112 F/X.  All Rights Reserved.
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
// Version 1.1 - added filled drawing method
//         1.2 - uniform and arc-length parameterization, with optional control for closed path
//
//

package Singularity.Geom
{
  import Singularity.Events.SingularityEvent;
  
  import Singularity.Geom.Composite;
  import Singularity.Geom.FastBezier;
  
  import Singularity.Numeric.Consts;
  import Singularity.Numeric.Gauss;
  
  import flash.display.Shape;
  import flash.display.Graphics;
  
  public class BezierSpline extends Composite
  {
  	// core
  	private var __closed:Boolean;                  // true if the path is closed
  	private var __parameterization:String;         // spline parameterization, arc-length or uniform
    private var __knots:Array;                     // interpolated knots (Point references)
    private var __bezier:Array;                    // FastBezier instance for each cubic segment
    private var __t:Number;                        // local parameter value corresponding to input parameter value
    private var __s:Number;                        // current arc-length
    private var __index:uint;                      // index of cubic segment corresponding to input parameter value
    private var __tension:Number;                  // spline 'tension' - lower tension increases probability of ripples
    public var __controlCage:BezierSplineControl; // control cage manager
    
    private var __quality:uint;                    // controls number of subdivision sweeps in cubic bezier segments

/**
* @description 	Method: BezierSpline() - Construct a new BezierSpline instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function BezierSpline()
    {
      super();
      
      __closed           = false;
      __parameterization = Consts.UNIFORM;
      
      __knots  = new Array();
      __bezier = new Array();

      __controlCage        = new BezierSplineControl();
      __controlCage.knots  = __knots;
      __controlCage.CLOSED = __closed;
      
      __tension = 1;
      __quality = 2;
    }
	

    public function get knots():Number   { return __knots.length; }
    public function get closed():Boolean { return __closed;       }
        
    public function set tension(_t:uint):void
    {
      var t:Number = Math.max(0,_t);
      t            = Math.min(5,t);
      __controlCage.tension = t;
    }
    
    public function set quality(_t:uint):void
    {
      var t:Number = Math.max(0,_t);
      t            = Math.min(3,t);
      __quality    = t;
    }

    public function set closed(_b:Boolean):void
    {
      __closed             = _b;
      __controlCage.CLOSED = _b;
    }
    
    public override function __integrand(_t:Number):Number
    {
      var x:Number = __bezier[__index].getXPrime(_t);
      var y:Number = __bezier[__index].getYPrime(_t);

      return Math.sqrt( x*x + y*y );
    }
/**
* @description 	Method: addControlPoint( _xCoord:Number, _yCoord:Number ) - Add a knot
*
* @param _xCoord:Number - knot x-coordinate
* @param _yCoord:Number - knot y-coordinate
*
* @return Nothing 
*
* @since 1.0
*
*/
    public override function addControlPoint( _xCoord:Number, _yCoord:Number ):void
    {
      if( !isNaN(_xCoord) && !isNaN(_yCoord) )
      {
        __knots.push({X:_xCoord, Y:_yCoord});

        __index = __knots.length-1;
        if( __index > 0 )
        {
          var b:FastBezier    = new FastBezier();
          b.subdivisions      = __quality;
          __bezier[__index-1] = b;
        }
      } 
    }
    
/**
* @description 	Method: moveControlPoint(_indx:uint, _newX:Number, _newY:Number) - Move a knot
*
* @param _indx:Number - Index of knot
* @param _newX:Number - New x-coordinate
* @param _newY:Number - New y-coordinate
*
* @return Nothing - Note that for best performance, there is no error-checking on the index or numerical knot values.  You break it - you buy it!
*
* @since 1.0
*
*/
    public override function moveControlPoint(_indx:uint, _newX:Number, _newY:Number):void
    {
      var knot:Object = __knots[_indx];

      knot.X = _newX;
      knot.Y = _newY;

      __invalidate = true;
    }

/**
* @description 	Method: reset() - Remove all knots and reset for new data entry
*
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function reset():void
    {
      __knots.splice(0);
   
      for( var i:uint=0; i<__bezier.length; ++i )
        __bezier[i].reset();

      __bezier.splice(0);

      __count      = 0;
      __arcLength  = -1;
      __invalidate = true;
    }

/**
* @description 	Method: getX( _t:Number ) - Return x-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: x-coordinate of spline
*
* @since 1.0
*
*/
    public override function getX(_t:Number):Number
    {
      if( __invalidate )
        __assignControlPoints();

      __interval(_t);
 
      return __bezier[__index].getX(__t);
    }

/**
* @description 	Method: getY( _t:Number ) - Return y-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: y-coordinate of spline
*
* @since 1.0
*
*/
    public override function getY(_t:Number):Number
    {
      if( __invalidate )
        __assignControlPoints();

      __interval(_t);
 
      return __bezier[__index].getY(__t);
    }

/**
* @description 	Method: draw(_t:Number) - Draw quadratic approximation of the cubic segment, sacrificing some accuracy for speed.  This is primarily
* intended for use in animation, not static drawing.
*
* @param _t:Number - parameter value in [0,1] -- not currently used, but reserved for possible future application.
*
* @return Nothing - Set the container reference before calling any drawing method - no error checking for performance
*
* @since 1.0
*
* Borg note: It seems that __bezier at index n can return the position dependent on the parameterization (ARC_LENGTH / UNIFORM)
* even though in itself it doesn't draw from those coords. Hence, cannot use the draw function to draw segment n.
*/
    public override function draw(_t:Number=1.0):void
    {
      if( __invalidate )
        __assignControlPoints();

      for( var i:uint=0; i<__bezier.length; ++i )
        __bezier[i].draw(__container, __thickness, __color, __closed);
    }

    
    public function get length(){
	return __bezier.length
}
/**
* @description 	Method: drawFilled(_l:Number, _f:Number) - Draw filled shape - this method is used when the spline represents a closed shape
*
* @param _l:Number - line color
* @param _f:Number - fill color
*
* @return Nothing - Set the container reference before calling any drawing method - no error checking for performance
*
* @since 1.1
*
*/
    public function drawFilled(_l:Number, _f:Number):void
    {
      if( __invalidate )
        __assignControlPoints();
      
      var g:Graphics = __container.graphics;
      g.beginFill(_f,1);
      
      // have to prime the pump in closed mode :)
      g.moveTo(__knots[0].X, __knots[0].Y );
      
      for( var i:uint=0; i<__bezier.length; ++i )
        __bezier[i].draw(__container, __thickness, _l, true);
        
      g.endFill();
    }

/**
* @description 	Method: drawControlPoints(_s:Shape, _c:Color) - Draw control points used to generate each cubic bezier curve approximation.
*
* @param _s:Shape - reference to shape in which control points are drawn
* @param _c:Color - line color
*
* @return Nothing
*
* @since 1.0
*
*/
    public function drawControlPoints(_s:Shape, _c:uint):void
    {
      if( __invalidate )
        __assignControlPoints();

      __controlCage.draw(_s, _c);
    }
    
/**
* @description 	Method: arcLength() - Return arc-length of the entire curve by numerical integration
*
* @return Number: Estimate of total arc length of the curve. 
*
* @since 1.0
*
*/
    public override function arcLength():Number
    {
      if ( __arcLength != -1 )
        return __arcLength;
        
      if( __invalidate )
        __assignControlPoints();

      // compute the length of each segment and sum
      var len:Number = 0;
      var k:uint     = __knots.length-1;

      if( k < 2 )
        return len;

      for( var i:uint=0; i<k; ++i )
      {
        __index = i;
        len    += 0.5*__integral.eval( __integrand, 0, 1, 5 );
      }

      __arcLength = len;
      return len;
    }

/**
* @description 	Method: arcLengthAt(_t:Number) - Return arc-length of curve segment on [0,_t].
*
* @param _t:Number - parameter value to describe partial curve whose arc-length is desired
*
* @return Number: Estimate of arc length of curve segment from t=0 to t=_t.
*
* @since 1.0
*
*/
    public override function arcLengthAt(_t:Number):Number
    {
      // compute the length of each segment and sum
      var len:Number = 0;
      var k:uint     = __knots.length;
      if( k < 2 || _t == 0 )
        return len;
      
      if( __invalidate )
        __assignControlPoints();

      var t:Number = (_t<0) ? 0 : _t;
      t            = (t>1) ? 1 : t;

      // determine which segment corresponds to the input value and the local parameter for that segment
      var N1:Number     = k-1;
      var N1t:Number    = N1*t;
      var f:Number      = Math.floor(N1t);
      var maxSeg:Number = Math.min(f+1, N1)-1;
      var param:Number  = N1t - f;

      // compute full curve length up to, but not including final segment
      for( var i:uint=0; i<maxSeg; ++i )
      {
        __index = i;
        len    += 0.5*__integral.eval( __integrand, 0, 1, 5 );
      }

      // add partial curve segment length, unless we're at a knot
      if( param != 0 )
      {
        __index = maxSeg;
        len    += 0.5*__integral.eval( __integrand, 0, param, 5 );
      }
            
      return len;
    }

    // compute the index of the cubic bezier segment and local parameter corresponding to the global parameter, based on parameterization
    private function __interval(_t:Number):void
    {
      var t:Number = (_t<0) ? 0 : _t;
      t            = (t>1)  ? 1 : t;
      
      // if arc-length parameterization, approximate L^-1(s)
      if( __param == Consts.ARC_LENGTH )
      {
        if( t != __s )
        {
          __t = __spline.eval(t);
          __s = t;
          __segment();
        }
      }
      else
      {
        if( t != __t )
        {
          __t = t;
          __segment();
        }      
      }
    }
    
    // compute current segment and local parameter value
    private function __segment():void
    {
      // the trivial case -- one segment
      var k:Number = __knots.length;
      if( k == 2 )
        __index = 0;
      else 
      {
        if( __t == 0 )
          __index = 0;
        else if( __t == 1.0 )
          __index = k-2;
        else
        {
          var N1:Number  = k-1;
          var N1t:Number = N1*__t;
          var f:Number   = Math.floor(N1t);
          __index        = Math.min(f+1, N1)-1;
          __t            = N1t - f;
        }
      }
    }
    
    // assign control points for each cubic segment
    private function __assignControlPoints():void
    {
      // if the spline is closed, a new control point is added so that the start and end points of the spline match
      var l1:uint = __knots.length-1;
      if( __closed && __knots[0].X != __knots[l1].X && __knots[0].Y != __knots[l1].Y )
      	addControlPoint(__knots[0].X, __knots[0].Y);

      __controlCage.construct();
    
      for( var i:uint=0; i<__bezier.length; ++i )
      {
        var c:CubicCage  = __controlCage.getCage(i);
        var b:FastBezier = __bezier[i];

        b.moveControlPoint(0, c.P0X, c.P0Y);
        b.moveControlPoint(1, c.P1X, c.P1Y);
        b.moveControlPoint(2, c.P2X, c.P2Y);
        b.moveControlPoint(3, c.P3X, c.P3Y);
      }

      __invalidate = false;
      __parameterize();
    }
    
    // parameterize composite curve - this function may vary based on the type of curve.
    private function __parameterize():void
    {
      if( __param == Consts.ARC_LENGTH )
      {
        if( __arcLength == -1 )
          var len:Number = arcLength();

        var normalize:Number = 1.0/__arcLength;
        
        if( __spline.knotCount > 0 )
          __spline.deleteAllKnots();

        // x-coordinate of spline knot is normalized arc-length, y-coordinate is t-value for uniform parameterization
        __spline.addControlPoint(0.0, 0.0);
        var prevT:Number    = 0;
        var k:uint          = __knots.length;
        var knotsInv:Number = 1.0/Number(k-1);
        
        for( var i:uint=1; i<k-1; i++ )
        {
          // get t-value at this knot for uniform parameterization
          var t:Number  = Number(i)*knotsInv;
          var t1:Number = prevT + Consts.ONE_THIRD*(t-prevT);
          var l:Number  = arcLengthAt(t1)*normalize;
          __spline.addControlPoint(l,t1);

          var t2:Number = prevT + Consts.TWO_THIRDS*(t-prevT);
          l             = arcLengthAt(t2)*normalize;
          __spline.addControlPoint(l,t2);

          l = arcLengthAt(t)*normalize;
          __spline.addControlPoint(l,t);

          prevT = t;
        }

        t1 = prevT + Consts.ONE_THIRD*(1.0-prevT);
        l  = arcLengthAt(t1)*normalize;
        __spline.addControlPoint(l,t1);

        t2 = prevT + Consts.TWO_THIRDS*(1.0-prevT);
        l  = arcLengthAt(t2)*normalize;
        __spline.addControlPoint(l,t2);

        // last knot, t=1, normalized arc-length = 1
        __spline.addControlPoint(1.0, 1.0);
      }
    }

  }
}