//
// CatmullRom.as - Generate cubic Catmull-Rom spline that interpolates a set of data points.  
//
// Reference:  www.algorithmist.net/arclen1.html
//
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.  
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special
// incidental, or consequential damages, including, without limitation, lost
// revenues, lost profits, or loss of prospective economic advantage, resulting
// from the use or misuse of this software program.
//
// Programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
//
// Note:  First and last coordinate array elements are reserved for 'outer' control points.  User-specified
// knots are placed in between the first and last elements.
//
// Note:  Class defaults to auto-tangent, uniform parameterization.
//

package Singularity.Geom.P3D
{
  import flash.display.Graphics;
    
  import Singularity.Numeric.Consts;
  import Singularity.Numeric.Gauss;
  
  import Singularity.Geom.P3D.Composite;
  import Singularity.Geom.P3D.Cubic;
  
  public class CatmullRom extends Composite
  {
    // core
    private var __x:Array;                // x-coordinates
    private var __y:Array;                // y-coordinates
    private var __z:Array;                // z-coordinates
    private var __tangent:String;         // endpoint (implicit tangent) specification
    private var __coef:Array;             // coefficients for each segment
    private var __t:Number;               // current t-value
    private var __s:Number;               // current arc-length
    private var __xHold:Number;           // holder for rightmost x-coordinate control point
    private var __yHold:Number;           // holder for rightmost y-coordinate of control point
    private var __zHold:Number;           // holder for rightmost z-coordinate of control point
    private var __index:Number;           // current index into coefficient array
    private var __localParam:Number;      // local (segment-based) parameter
    private var __knots:Number;           // knot count
    private var __prevIndex:Number;       // previous index reference
    private var __isClosed:Boolean;       // true is spline is automatically closed

/**
* @description 	Method: CatmullRom() - Construct a new Catmull-Rom instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function CatmullRom()
    {
      __error.classname  = "CatmullRom";

      __x    = new Array();
      __y    = new Array();
      __z    = new Array();
      __coef = new Array();

      __x.push(0);
      __y.push(0);
      __z.push(0);

      __tangent    = Consts.AUTO;
      __param      = Consts.UNIFORM;
      __t          = -1;
      __s          = -1;
      __prevIndex  = -1;
      __arcLength  = -1;
      __xHold      = 0;
      __yHold      = 0;
      __zHold      = 0;
      __knots      = 0;
    }
    
    public function getControlPoint(_i:uint):Object
    {
      if( _i == 0 )
        return {X:__x[0], Y:__y[0], Z:__z[0]};
      else
      	return {X:__x[__knots+1], Y:__y[__knots+1], Z:__z[__knots+1]};
    }

    public function set tangent(_s:String):void
    {
      if( _s == Consts.AUTO || _s == Consts.EXPLICIT )
        __tangent = _s;

      __invalidate = true;
    }
    
    public function set closed(_b:Boolean):void { __isClosed = _b; }
    
    public override function __integrand(_t:Number):Number
    {
      var x:Number = __coef[__index].getXPrime(_t);
      var y:Number = __coef[__index].getYPrime(_t);
      var z:Number = __coef[__index].getZPrime(_t);

      return Math.sqrt( x*x + y*y + z*z );
    }
/**
* @description 	Method: addControlPoint( _xCoord:Number, _yCoord:Number, _zCoord:Number ) - Add a control point
*
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
* @param _zcoord:Number - control point, z-coordinate
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function addControlPoint( _xCoord:Number, _yCoord:Number, _zCoord:Number ):void
    {
      __error.methodname = "addControlPoint()";

      // Note:  No checking for duplicate coordinates -- you break it, you buy it!
      if( isNaN(_xCoord) )
      {
        __error.message = "Invalid x-coordinate";
        dispatchEvent(__error);
        return;
      }

      if( isNaN(_yCoord) )
      {
        __error.message = "Invalid y-coordinate";
        dispatchEvent(__error);
        return;
      }
      
       if( isNaN(_zCoord) )
      {
        __error.message = "Invalid z-coordinate";
        dispatchEvent(__error);
        return;
      }

      __x.push(_xCoord);
      __y.push(_yCoord);
      __z.push(_zCoord);

      __knots++;
    }

/**
* @description 	Method: setOuterPoint( _flag:String, _xCoord:Number, _yCoord:Number, _zCoord:Number ) - Add control point outside the knot range
*
* @param _flag:String   - indicate which extreme to place point - F (modify first control point) or L (last control point)
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
* @param _zCoord:Number - control point, z-coordinate
*
*
* @return Nothing
*
* @since 1.0
*
*/
    public function setOuterPoint( _flag:String, _xCoord:Number, _yCoord:Number, _zCoord:Number ):void
    {
      __error.methodname = "setOuterPoint()";

      // Note:  No checking for duplicate coordinates -- you break it, you buy it!
      if( isNaN(_xCoord) )
      {
        __error.message = "Invalid x-coordinate";
        dispatchEvent(__error);
        return;
      }

      if( isNaN(_yCoord) )
      {
        __error.message = "Invalid y-coordinate";
        dispatchEvent(__error);
        return;
      }
      
      if( isNaN(_zCoord) )
      {
        __error.message = "Invalid z-coordinate";
        dispatchEvent(__error);
        return;
      }

      if( _flag == Consts.FIRST )
      {
        __x[0] = _xCoord;
        __y[0] = _yCoord;
        __z[0] = _zCoord;
      }
      else
      {
        __xHold = _xCoord;
        __yHold = _yCoord;
        __zHold = _zCoord;
      }
    }

/**
* @description 	Method: reset() - Remove all control points and initialize spline for new control point entry
*
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function reset():void
    {
      __x.splice(0);
      __y.splice(0);
      __z.splice(0);
      __coef.splice(0);

      __x.push(0);
      __y.push(0);
      __z.push(0);

      __knots      = 0;
      __prevIndex  = -1;
      __arcLength  = -1;
      __t          = -1;
      __s          = -1;
      __invalidate = true;
    }

/**
* @description 	Method: moveControlPoint(_indx:uint, _newX:Number, _newY:Number, _newZ:Number) - Move a control point
*
* @param _indx:uint   - Index of control point
* @param _newX:Number - New x-coordinate
* @param _newY:Number - New y-coordinate
* @param _newZ:Number - New z-coordinate
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function moveControlPoint(_indx:uint, _newX:Number, _newY:Number, _newZ:Number):void
    {
      __error.methodname = "moveControlPoint";
      if( _indx < 0 || _indx > __knots-1 )
      {
        __error.message = "Invalid index: " + _indx.toString() + " , total knots: " + __knots.toString();
        dispatchEvent(__error);
        return;
      }
 
      if( isNaN(_newX) )
      {
        __error.message = "Invalid x-coordinate";
        dispatchEvent(__error);
        return;
      }

      if( isNaN(_newY) )
      {
        __error.message = "Invalid y-coordinate";
        dispatchEvent(__error);
        return;
      }
      
      if( isNaN(_newZ) )
      {
        __error.message = "Invalid z-coordinate";
        dispatchEvent(__error);
        return;
      }

      // recall indices are offset by one because of the implicit tangent point at the beginning
      // of the array
      __x[_indx+1] = _newX; 
      __y[_indx+1] = _newY;
      __z[_indx+1] = _newZ;

      // The process could be more efficient by updating only computations affected by
      // the local knot move -- this is left as an exercise.
      __arcLength  = -1;
      __invalidate = true;
    }

/**
* @description 	Method: getX( _t:Number ) - Return x-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: x-value of Catmull-Rom spline at input t.
*
* @since 1.0
*
*/
    public override function getX(_t:Number):Number
    {
      if( __knots < 2 )
        return ( (__knots==1) ? __x[1] : 0 );
    
      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);

      return 0.5*__coef[__index].getX(__localParam);
    }

/**
* @description 	Method: getXPrime(_t:Number) - Return dx/dt for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: Value of dx/dt, provided input is in [0,1].
*
* @since 1.0
*
*/
    public function getXPrime(_t:Number):Number
    {
      if( __knots < 2 )
        return 0;

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return 0.5*__coef[__index].getXPrime(__localParam);
    }

/**
* @description 	Method: getY( _t:Number ) - Return y-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: y-value of Catmull-Rom spline at input t.
*
* @since 1.0
*
*/
    public override function getY(_t:Number):Number
    {
      if( __knots < 2 )
        return ( (__knots==1) ? __y[1] : 0 );

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return 0.5*__coef[__index].getY(__localParam);
    }

/**
* @description 	Method: getYPrime( _t:Number ) - Return dy/dt for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: Value of dy/dt, provided input is in [0,1].
*
* @since 1.0
*
*/
    public function getYPrime(_t:Number):Number
    {
      if( __knots < 2 )
        return 0;

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return 0.5*__coef[__index].getYPrime(__localParam);
    }
    
    /**
* @description 	Method: getZ( _t:Number ) - Return z-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: z-value of Catmull-Rom spline at input t
*
* @since 1.0
*
*/
    public override function getZ(_t:Number):Number
    {
      if( __knots < 2 )
        return ( (__knots==1) ? __z[1] : 0 );

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return 0.5*__coef[__index].getZ(__localParam);
    }

/**
* @description 	Method: getZPrime( _t:Number ) - Return dz/dt for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: Value of dz/dt, provided input is in [0,1].
*
* @since 1.0
*
*/
    public function getZPrime(_t:Number):Number
    {
      if( __knots < 2 )
        return 0;

      if( __invalidate )
        __computeCoef();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return 0.5*__coef[__index].getZPrime(__localParam);
    }


/**
* @description 	Method: tAtKnot(_k:Number):Number - Return t-value at a particular knot index
*
* @param _k:Number - Knot index, starting at zero
*
* @return Number: t-value corresponding to knot at index _k, provided k is in-range.  Returns -1 otherwise.
*
* @since 1.0
*
*/
    public function tAtKnot(_k:Number):Number
    {
      if( _k < 0 || _k > __knots-1 )
        return -1;

      var t:Number = 0;
      if( __param == Consts.ARC_LENGTH )
        t = 0;                   // to be added
      else if( __param == Consts.UNIFORM )
      {
        if( _k == 0 )
          t = 0;
        else if( _k == (__knots-1) )
          t = 1;
        else
          t = Number(_k)/Number((__knots-1));
      }
      
      return t;
    }

/**
* @description 	Method: arcLength() - Return arc-length of the entire curve by numerical integration
*
* @return Number: Estimate of total arc length of the curve
*
* @since 1.0
*
*/
    public override function arcLength():Number
    {
      if ( __arcLength != -1 )
        return __arcLength;

      // compute the length of each segment and sum
      var len:Number = 0;
      if( __knots < 2 )
        return len;

      if( __invalidate )
        __computeCoef();

      for( var i:uint=1; i<__knots; ++i )
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
      if( __knots < 2 || _t == 0 )
        return len;

      if( __invalidate )
        __computeCoef();

      var t:Number = (_t<0) ? 0 : _t;
      t            = (t>1) ? 1 : t;

      // determine which segment corresponds to the input value and the local parameter for that segment
      var N1:Number     = __knots-1;
      var N1t:Number    = N1*t;
      var f:Number      = Math.floor(N1t);
      var maxSeg:Number = Math.min(f+1, N1);
      var param:Number  = N1t - f;

      // compute full curve length up to, but not including final segment
      for( var i:uint=1; i<maxSeg; ++i )
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

    // compute polynomical coefficients
    private function __computeCoef():void
    {
      // fill out endpoints based on user selection
      if( __tangent == Consts.AUTO )
        __computeEndpoints();
      else
      {
        __x[__knots+1] = __xHold;
        __y[__knots+1] = __yHold;
        __z[__knots+1] = __zHold;
      }

      // loop over segments
      for( var i:uint=1; i<__knots; ++i )
      {
      	var c:Cubic = __coef[i];
        if( c == null )
          c = new Cubic();
        else
          c.reset();

        c.addCoef( 2.0*__x[i], 2.0*__y[i], 2.0*__z[i] );
        
        c.addCoef( __x[i+1] - __x[i-1], __y[i+1] - __y[i-1], __z[i+1] - __z[i-1] );

        c.addCoef( 2.0*__x[i-1] - 5.0*__x[i] + 4.0*__x[i+1] - __x[i+2], 
                   2.0*__y[i-1] - 5.0*__y[i] + 4.0*__y[i+1] - __y[i+2],
                   2.0*__z[i-1] - 5.0*__z[i] + 4.0*__z[i+1] - __z[i+2] );

        c.addCoef(  -__x[i-1] + 3.0*__x[i] - 3.0*__x[i+1] + __x[i+2],  
                    -__y[i-1] + 3.0*__y[i] - 3.0*__y[i+1] + __y[i+2],
                    -__z[i-1] + 3.0*__z[i] - 3.0*__z[i+1] + __z[i+2] );

        __coef[i] = c;
      }

      __invalidate = false;
      __parameterize();
    }

    // parameterize spline
    private function __parameterize():void
    {
      // this is a bit innefficient, but will be made tighter in the future.  Place a spline knot at
      // each of the C-R knots and two knots in between.  If spline knots are already in place, then
      // this method was most likely called as a result of moving one or more C-R knots, so regenerate
      // the entire set of interpolation knots.
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
        var knotsInv:Number = 1.0/Number(__knots-1);
        
        for( var i:uint=1; i<__knots-1; i++ )
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
    
    private function __setParam(_t:Number):void
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
      if( __knots == 2 )
      {
        __index      = 1;
        __localParam = __t;
      }
      else 
      {
        if( __t == 0 )
        {
          __index = 1;
          __localParam = 0;
        }
        else if( __t == 1.0 )
        {
          __index      = __knots-1;
          __localParam = 1.0;
        }
        else
        {
          var N1:Number  = __knots-1;
          var N1t:Number = N1*__t;
          var f:Number   = Math.floor(N1t);
          __index        = Math.min(f+1, N1);
          __localParam   = N1t - f;
        }
      }
    }

    // compute endpoints at extremes of knot sequence - simple reflection about endpoints
    private function __computeEndpoints():void
    {
      if( __isClosed )
      {
      	addControlPoint(__x[1], __y[1], __z[1]);
      	__closedSplineEndpoints();
      }
      else
      {
        // simple reflection
        __x[0] = 2.0*__x[1] - __x[2];
        __y[0] = 2.0*__y[1] - __y[2];
        __z[0] = 2.0*__z[1] - __z[2];

        __x[__knots+1] = 2.0*__x[__knots] - __x[__knots-1];
        __y[__knots+1] = 2.0*__y[__knots] - __y[__knots-1];
        __z[__knots+1] = 2.0*__z[__knots] - __z[__knots-1];
      }
    }
    
    private function __closedSplineEndpoints():void
    {   
      var x1:Number  = __x[1];
      var y1:Number  = __y[1];
      var z1:Number  = __z[1];
      var dX1:Number = __x[2] - x1;
      var dY1:Number = __y[2] - y1;
      var dZ1:Number = __z[2] - z1;
      var dX2:Number = __x[__knots-1] - x1;
      var dY2:Number = __y[__knots-1] - y1;
      var dZ2:Number = __z[__knots-1] - z1;
      var d1:Number  = Math.sqrt(dX1*dX1 + dY1*dY1 + dZ1*dZ1);
      var d2:Number  = Math.sqrt(dX2*dX2 + dY2*dY2 + dZ2*dZ2);
      dX1 /= d1;
      dY1 /= d1;
      dZ1 /= d1;
      dX2 /= d2;
      dY2 /= d2;
      dZ2 /= d2;
      
      __x[0]         = x1 + d1*dX2;
      __y[0]         = y1 + d1*dY2;
      __z[0]         = z1 + d1*dZ2;
      __x[__knots+1] = x1 + d2*dX1;
      __y[__knots+1] = y1 + d2*dY1;
      __z[__knots+1] = z1 + d2*dZ1;
    }
  }
}