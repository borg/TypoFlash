//
// FastBezier.as - Cubic bezier curve with no error-checking.  Optimized for performance.  This curve is intended
// to be sampled, not drawn.
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
// programmed by: Jim Armstrong, Singularity (www.algorithmist.net)
// 
//

package Singularity.Geom.P3D
{
  import Singularity.Numeric.Consts;
  import Singularity.Geom.P3D.Cubic;
    
  public class FastBezier
  {
    private var __p0X:Number;            // x-coordinate, first control point
    private var __p0Y:Number;            // y-coordinate, first control point
    private var __p0Z:Number;            // z-coordinate, first control point
    private var __p1X:Number;            // x-coordinate, second control point
    private var __p1Y:Number;            // y-coordinate, second control point
    private var __p1Z:Number;            // z-coordinate, second control point
    private var __p2X:Number;            // x-coordinate, third control point
    private var __p2Y:Number;            // y-coordinate, third control point
    private var __p2Z:Number;            // z-coordinate, third control point
    private var __p3X:Number;            // x-coordinate, fourth control point
    private var __p3Y:Number;            // y-coordinate, fourth control point
    private var __p3Z:Number;            // z-coordinate, fourth control point
    private var __count:uint;            // counts number of control points
    private var __invalidate:Boolean;    // true if current cubic coefficients are not valid

    private var __coef:Cubic;            // quick reference to initial coefficients

/**
* @description 	Method: FastBezier() - Construct a new FastBezier instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function FastBezier()
    {
      __p0X  = 0;
      __p0Y  = 0;
      __p0Z  = 0;
      __p1X  = 0;
      __p1Y  = 0;
      __p1Z  = 0;
      __p2X  = 0;
      __p2Y  = 0;
      __p2Z  = 0;
      __p3X  = 0;
      __p3Y  = 0;
      __p3Z  = 0;
      __coef = new Cubic();
      
      __count      = 0;
      __invalidate = true;
    }

/**
* @description 	Method: addControlPoint( _xCoord:Number, _yCoord:Number, _zCoord ) - Add a CV
*
* @param _xCoord:Number - CV, x-coordinate
* @param _yCoord:Number - CV, y-coordinate
* @param _zCoord:Number - CV, z-coordinate
*
* @return Nothing - Adds control points in order called up to two four. 
*
* @since 1.0
*
*/
    public function addControlPoint( _xCoord:Number, _yCoord:Number, _zCoord:Number ):void
    {
      switch( __count )
      {
        case 0 :
          __p0X = _xCoord;
          __p0Y = _yCoord;
          __p0Z = _zCoord;
          __count++;
        break;
      
        case 1 :
          __p1X = _xCoord;
          __p1Y = _yCoord;
          __p1Z = _zCoord;
          __count++;
        break;
        
        case 2 :
          __p2X = _xCoord;
          __p2Y = _yCoord;
          __p2Z = _zCoord;
          __count++;
        break;
        
        case 3 :
          __p3X = _xCoord;
          __p3Y = _yCoord;
          __p3Z = _zCoord;
          __count++;
        break;
      }
      __invalidate = true;
      
    }

/**
* @description 	Method: reset() - Reset control points
*
*
* @return Nothing
*
* @since 1.0
*
*/
    public function reset():void
    {
      __p0X = 0;
      __p0Y = 0;
      __p0Z = 0;
      __p1X = 0;
      __p1Y = 0;
      __p1Z = 0;
      __p2X = 0;
      __p2Y = 0;
      __p2Z = 0;
      __p3X = 0;
      __p3Y = 0;
      __p3Z = 0;

      __invalidate = true;
      __count      = 0;

      __coef.reset();
    }

/**
* @description 	Method: moveControlPoint(_indx:Number, _newX:Number, _newY:Number, _newZ:Number) - Move a CV
*
* @param _indx:Number - Index of control point (0, 1, 2, or 3)
* @param _newX:Number - New x-coordinate
* @param _newY:Number - New y-coordinate
* @param _newZ:Number - New z-coordinate
*
* @return Nothing - To support faster animation, there is no error checking
*
* @since 1.0
*
*/
    public function moveControlPoint(_indx:uint, _newX:Number, _newY:Number, _newZ:Number):void
    {
      switch( _indx )
      {
        case 0 :
          __p0X = _newX; 
          __p0Y = _newY;
          __p0Z = _newZ;
        break;
      
        case 1 :
          __p1X = _newX;
          __p1Y = _newY;
          __p1Z = _newZ;
        break;
    
        case 2 :
          __p2X = _newX;
          __p2Y = _newY;
          __p3Z = _newZ;
        break;
        
        case 3 :
          __p3X = _newX;
          __p3Y = _newY;
          __p3Z = _newZ;
        break;
      }

      __invalidate = true;
    }

/**
* @description 	Method: getX( _t:Number ) - Return x-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: x-coordinate of cubic Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
*
* @since 1.0
*
*/
    public function getX(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();
    
      // cubic polynomial in nested form
      return __coef.getX(t);
    }

/**
* @description 	Method: getY( _t:Number ) - Return y-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: y-coordinate of cubic Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
*
* @since 1.0
*
*/
    public function getY(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();

      // cubic polynomial in nested form
      return __coef.getY(t);
    }
    
/**
* @description 	Method: getZ( _t:Number ) - Return z-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: z-coordinate of cubic Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
*
* @since 1.0
*
*/
    public function getZ(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();

      // cubic polynomial in nested form
      return __coef.getZ(t);
    }
    
/**
* @description 	Method: getXPrime( _t:Number ) - Return dx/dt for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: dx/dt of cubic Bezier curve
*
* @since 1.0
*
*/
    public function getXPrime(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();
    
      // cubic polynomial in nested form
      return __coef.getXPrime(t);
    }

/**
* @description 	Method: getYPrime( _t:Number ) - Return dy/dt for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: dy/dt of cubic Bezier curve.
*
* @since 1.0
*
*/
    public function getYPrime(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();

      // cubic polynomial in nested form
      return __coef.getYPrime(t);
    }
    
/**
* @description 	Method: getZPrime( _t:Number ) - Return dz/dt for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: dz/dt of cubic Bezier curve.
*
* @since 1.0
*
*/
    public function getZPrime(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();

      // cubic polynomial in nested form
      return __coef.getZPrime(t);
    }

    private function __computeCoef():void
    {
  	  __coef.reset();
  	  	
      __coef.addCoef( __p0X, __p0Y, __p0Z )
        
      var dX:Number = 3.0*(__p1X-__p0X);
      var dY:Number = 3.0*(__p1Y-__p0Y);
      var dZ:Number = 3.0*(__p1Z-__p0Z);
      __coef.addCoef(dX, dY, dZ);

      var bX:Number = 3.0*(__p2X-__p1X) - dX;
      var bY:Number = 3.0*(__p2Y-__p1Y) - dY;
      var bZ:Number = 3.0*(__p2Z-__p1Z) - dZ;
      __coef.addCoef(bX, bY, bZ);
        
      __coef.addCoef(__p3X - __p0X - dX - bX, __p3Y - __p0Y - dY - bY, __p3Z - __p0Z - dZ - bZ);

      __invalidate = false;
    } 
  }
}