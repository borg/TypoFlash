//
// BezierSpline.as - Cubic Bezier spline designed to be used for applications where CV and tangent
// information is exported from a 3D package.  Arc-length parameterization is supported for velocity
// control in path animation.  Unlike it's 2D counterpart, there are no optimized drawing methods.
// The spline is intended to be sampled, not drawn.
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
//
//

package Singularity.Geom.P3D
{
  import Singularity.Events.SingularityEvent;
  
  import Singularity.Geom.P3D.Composite;
  import Singularity.Geom.P3D.FastBezier;
  
  import Singularity.Numeric.Consts;
  import Singularity.Numeric.Gauss;
  
  public class BezierSpline extends Composite
  {
  	// core
    private var __closed:Boolean;                  // true if the path is closed
  	private var __parameterization:String;      // spline parameterization, arc-length or uniform
    private var __cv:Array;                     // interpolated control vertices or knots
    private var __inVec:Array;                  // in-vector or tangent for each vertex (except first)
    private var __outVec:Array;                 // out-vector or tangent for each vertex (except last)
    private var __bezier:Array;                 // FastBezier instance for each cubic segment
    private var __t:Number;                     // local parameter value corresponding to input parameter value
    private var __s:Number;                     // current arc-length
    private var __index:uint;                   // index of cubic segment corresponding to input parameter value

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
      
      __parameterization = Consts.UNIFORM;
      
      __cv     = new Array();
      __inVec  = new Array();
      __outVec = new Array();
      __bezier = new Array();
      
      __closed = false;
    }

    public function get knots():Number   { return __cv.length; }
    public function get closed():Boolean { return __closed;    }
    
    public function set closed(_b:Boolean):void { __closed = _b; }
      
    public override function __integrand(_t:Number):Number
    {
      var x:Number = __bezier[__index].getXPrime(_t);
      var y:Number = __bezier[__index].getYPrime(_t);
      var z:Number = __bezier[__index].getZPrime(_t);

      return Math.sqrt( x*x + y*y + z*z );
    }
    
/**
* @description 	Method: addControlPoint( _xCoord:Number, _yCoord:Number, _zCoord:Number ) - Add a control Vertex
*
* @param _xCoord:Number - CV x-coordinate
* @param _yCoord:Number - CV y-coordinate
* @param _zCoord:Number - CV z-coordinate
*
* @return Nothing 
*
* @since 1.0
*
*/
    public override function addControlPoint( _xCoord:Number, _yCoord:Number, _zCoord:Number ):void
    {
      if( !isNaN(_xCoord) && !isNaN(_yCoord) && !isNaN(_zCoord) )
      {
        __cv.push({X:_xCoord, Y:_yCoord, Z:_zCoord});

        __index = __cv.length-1;
        if( __index > 0 )
        {
          var b:FastBezier    = new FastBezier();
          __bezier[__index-1] = b;
        }
      } 
    }
    
/**
* @description 	Method: moveControlPoint(_indx:uint, _newX:Number, _newY:Number, _newZ:Number) - Move a CV
*
* @param _indx:Number - Index of CV
* @param _newX:Number - New x-coordinate
* @param _newZ:Number - New z-coordinate
* 
*
* @return Nothing - Note that for best performance, there is no error-checking on the index or numerical values.  You break it - you buy it!
*
* @since 1.0
*
*/
    public override function moveControlPoint(_indx:uint, _newX:Number, _newY:Number, _newZ:Number):void
    {
      var cv:Object = __cv[_indx];

      var dX:Number = _newX - cv.X;
      var dY:Number = _newY - cv.Y;
      var dZ:Number = _newZ - cv.Z;
      cv.X          = _newX;
      cv.Y          = _newY;
      cv.Z          = _newZ;
      
      // shift in- and out-tangents by the delta
      var inV:Object = __inVec[_indx];
      inV.X         += dX;
      inV.Y         += dY;
      inV.Z         += dZ;
         
      var outV:Object = __outVec[_indx];
      outV.X         += dX;
      outV.Y         += dY;
      outV.Z         += dZ;
      __invalidate = true;
    }
    
/**
* @description 	Method: inTangent( _indx:Number, _xCoord:Number, _yCoord:Number, _zCoord:Number ) - Set the in-vector for a CV
*
* @param _indx:Number   - CV index
* @param _xCoord:Number - in-vector x-coordinate
* @param _yCoord:Number - in-vector y-coordinate
* @param _zCoord:Number - in-vector z-coordinate
*
* @return Nothing - Note:  The coordinates are actual coordinates of the endpoints of the tangent handle, not a relative vector.  
* The coordinates are used to set the control cage for a single cubic Bezier segment.
*
* @since 1.0
*
*/
    public function inTangent( _indx:uint, _xCoord:Number, _yCoord:Number, _zCoord:Number ):void
    {
      if( !isNaN(_xCoord) && !isNaN(_yCoord) && !isNaN(_zCoord) && _indx >= 0 )
        __inVec[_indx] = ({X:_xCoord, Y:_yCoord, Z:_zCoord});
    }
    
/**
* @description 	Method: outTangent( _indx:Number, _xCoord:Number, _yCoord:Number, _zCoord:Number ) - Set the in-vector for a CV
*
* @param _indx:Number   - CV index
* @param _xCoord:Number - out-vector x-coordinate
* @param _yCoord:Number - out-vector y-coordinate
* @param _zCoord:Number - out-vector z-coordinate
*
* @return Nothing -  Note:  The coordinates are actual coordinates of the endpoints of the tangent handle, not a relative vector.  
* The coordinates are used to set the control cage for a single cubic Bezier segment.
*
* @since 1.0
*
*/
    public function outTangent( _indx:uint, _xCoord:Number, _yCoord:Number, _zCoord:Number ):void
    {
      if( !isNaN(_xCoord) && !isNaN(_yCoord) && !isNaN(_zCoord) && _indx >= 0 )
        __outVec[_indx] = ({X:_xCoord, Y:_yCoord, Z:_zCoord});
    }

/**
* @description 	Method: reset() - Remove all CV's and reset for new data entry
*
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function reset():void
    {
      __cv.splice(0);
   
      for( var i:uint=0; i<__bezier.length; ++i )
        __bezier[i].reset();

      __bezier.splice(0);
      __inVec.splice(0);
      __outVec.splice(0);

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
* @description 	Method: getXPrime( _t:Number ) - Return dx/dt for the specified parameter value
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: dx/dt at the specified parameter
*
* @since 1.0
*
*/
    public function getXPrime(_t:Number):Number
    {
      if( __invalidate )
        __assignControlPoints();

      __interval(_t);
 
      return __bezier[__index].getXPrime(__t);
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
* @description 	Method: getYPrime( _t:Number ) - Return dy/dt for the specified parameter value
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: dy/dt for the specified parameter
*
* @since 1.0
*
*/
    public function getYPrime(_t:Number):Number
    {
      if( __invalidate )
        __assignControlPoints();

      __interval(_t);
 
      return __bezier[__index].getYPrime(__t);
    }
    
/**
* @description 	Method: getZ( _t:Number ) - Return z-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: z-coordinate of spline
*
* @since 1.0
*
*/
    public override function getZ(_t:Number):Number
    {
      if( __invalidate )
        __assignControlPoints();

      __interval(_t);
 
      return __bezier[__index].getZ(__t);
    }
    
/**
* @description 	Method: getZPrime( _t:Number ) - Return dz/dt for the specified parameter value
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: dz/dt at the specified parameter
*
* @since 1.0
*
*/
    public function getZPrime(_t:Number):Number
    {
      if( __invalidate )
        __assignControlPoints();

      __interval(_t);
 
      return __bezier[__index].getZPrime(__t);
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
      var k:uint     = __cv.length-1;

      if( k < 2 )
        return len;

      //trace( "closed: " + __closed );
      for( var i:uint=0; i<k; ++i )
      {
        __index = i;
        //trace( "index: " + i );
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
      var k:uint     = __cv.length;
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
      var k:Number = __cv.length;
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
      var cv:Object = __cv[0];
      if( __closed )
      	addControlPoint(cv.X, cv.Y, cv.Z);  // force another bezier segment

      // first segment
      var b:FastBezier = __bezier[0];
      b.addControlPoint( cv.X, cv.Y, cv.Z );
      
      var outV:Object = __outVec[0];
      b.addControlPoint( outV.X, outV.Y, outV.Z );
      
      var inV:Object = __inVec[1];
      b.addControlPoint( inV.X, inV.Y, inV.Z );
      
      cv = __cv[1];
      b.addControlPoint( cv.X, cv.Y, cv.Z );
      
      // inner segments
      for( var i:uint=1; i<__bezier.length-1; ++i )
      {
        b  = __bezier[i];
        cv = __cv[i];
        b.addControlPoint( cv.X, cv.Y, cv.Z );
      
        outV = __outVec[i];
        b.addControlPoint( outV.X, outV.Y, outV.Z );
      
        inV = __inVec[i+1];
        b.addControlPoint( inV.X, inV.Y, inV.Z );
      
        cv = __cv[i+1];
        b.addControlPoint( cv.X, cv.Y, cv.Z );
      }
      
      // final segment (closed order)
      var l:Number = __bezier.length-1;
      if( !__closed )
      {
        b  = __bezier[l];
        cv = __cv[l];
        b.addControlPoint( cv.X, cv.Y, cv.Z );
      
        outV = __outVec[l];
        b.addControlPoint( outV.X, outV.Y, outV.Z );
      
        inV = __inVec[l+1];
        b.addControlPoint( inV.X, inV.Y, inV.Z );
      
        cv = __cv[l+1];
        b.addControlPoint( cv.X, cv.Y, cv.Z );
      }
      else
      {
      	b  = __bezier[l];
        cv = __cv[l];
        b.addControlPoint( cv.X, cv.Y, cv.Z );
      
        outV = __outVec[l];
        b.addControlPoint( outV.X, outV.Y, outV.Z );
      
        inV = __inVec[0];
        b.addControlPoint( inV.X, inV.Y, inV.Z );
      
        cv = __cv[l+1];
        b.addControlPoint( cv.X, cv.Y, cv.Z );
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
        var k:uint          = __cv.length;
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