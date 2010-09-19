//
// FastBezier.as - Cubic bezier curve with plotting via recursive subdivision.  This version
// allows up to three subdivision sweeps (with an initial division at an inflection point) 
// to provide a better tradeoff between accuracy and performance.
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
// Note:  For peformance reasons, there is no error checking on any input to any method in this Class.
//

package Singularity.Geom
{
  import Singularity.Numeric.Consts;
  import Singularity.Geom.Cubic;
  import flash.display.Shape;
  
  import flash.display.Graphics;
    
  public class FastBezier
  {
    private var __p0X:Number;            // x-coordinate, first control point
    private var __p0Y:Number;            // y-coordinate, first control point
    private var __p1X:Number;            // x-coordinate, second control point
    private var __p1Y:Number;            // y-coordinate, second control point
    private var __p2X:Number;            // x-coordinate, third control point
    private var __p2Y:Number;            // y-coordinate, third control point
    private var __p3X:Number;            // x-coordinate, fourth control point
    private var __p3Y:Number;            // y-coordinate, fourth control point
    private var __count:uint;            // counts number of control points
    private var __invalidate:Boolean;    // true if current cubic coefficients are not valid

    private var __coef:Cubic;            // quick reference to initial coefficients

    // subdivisions
    private var __left1:Array;           // left-1 control cage
    private var __left2:Array;           // left-2 control cage
    private var __left1a:Array;          // left-3 control cage
    private var __left2a:Array;          // left-4 control cage
    private var __right1:Array;          // right-1 control cage
    private var __right2:Array;          // right-2 control cage
    private var __right1a:Array;         // right-3 control cage
    private var __right2a:Array;         // right-4 control cage
    private var __pX:Number;             // x-coord of quad control point
    private var __pY:Number;             // y-coord of quad control point
    private var __subdiv:Number;         // total number of subdivision passes (1 or 2)
    private var __t1:Number;
    private var __t2:Number;
    private var __t3:Number;

/**
* @description 	Method: FastBezier() - Construct a new FastBezier instance (defaults to highest quality)
*
* @return Nothing
*
* @since 1.0
*
*/
    public function FastBezier()
    {
      __p0X    = 0;
      __p0Y    = 0;
      __p1X    = 0;
      __p1Y    = 0;
      __p2X    = 0;
      __p2Y    = 0;
      __p3X    = 0;
      __p3Y    = 0;
      __pX     = 0;
      __pY     = 0;
      __t1     = 0;
      __t2     = 0;
      __t3     = 0;
      __subdiv = 3;

      __left1      = new Array();
      __right1     = new Array();
      __left2      = new Array();
      __right2     = new Array();
      __left1a     = new Array();
      __right1a    = new Array();
      __left2a     = new Array();
      __right2a    = new Array();
      __coef       = new Cubic();
      
      __count      = 0;
      __invalidate = true;
    }

    public function set subdivisions(_s:uint):void
    {
      if( _s == 1 || _s == 2 || _s == 3 )
        __subdiv = _s;
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
    public function addControlPoint( _xCoord:Number, _yCoord:Number ):void
    {
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
* @description 	Method: reset() - Remove control points
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
      __p1X = 0;
      __p1Y = 0;
      __p2X = 0;
      __p2Y = 0;
      __p3X = 0;
      __p3Y = 0;

      __invalidate = true;
      __count      = 0;

      __coef.reset();
    }

/**
* @description 	Method: moveControlPoint(_indx:Number, _newX:Number, _newY:Number) - Move a control point
*
* @param _indx:Number - Index of control point (0, 1, 2, or 3)
* @param _newX:Number - New x-coordinate
* @param _newY:Number - New y-coordinate
*
* @return Nothing - To support faster animation, there is no error checking
*
* @since 1.0
*
*/
    public function moveControlPoint(_indx:uint, _newX:Number, _newY:Number):void
    {
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


    // split the current control cage at t - number of sub-cages increases exponentially
    private function __split( _t:Number ):void
    {
      var t1:Number = 1.0 - _t;
      var p11X:Number = 0;
      var p11Y:Number = 0;
      var p21X:Number = 0;
      var p21Y:Number = 0;
      var p31X:Number = 0;
      var p31Y:Number = 0;
      var p12X:Number = 0;
      var p12Y:Number = 0;
      var p22X:Number = 0;
      var p22Y:Number = 0;
      var p13X:Number = 0;
      var p13Y:Number = 0;

      // manually unroll the recursion; first sweep is at t
      p11X = t1*__p0X + _t*__p1X;
      p11Y = t1*__p0Y + _t*__p1Y;

      p21X = t1*__p1X + _t*__p2X;
      p21Y = t1*__p1Y + _t*__p2Y;

      p31X = t1*__p2X + _t*__p3X;
      p31Y = t1*__p2Y + _t*__p3Y;

      p12X = t1*p11X + _t*p21X;
      p12Y = t1*p11Y + _t*p21Y;

      p22X = t1*p21X + _t*p31X;
      p22Y = t1*p21Y + _t*p31Y;

      p13X = t1*p12X + _t*p22X;
      p13Y = t1*p12Y + _t*p22Y;
    
      __setCoef(__left1, __right1, __p0X, __p0Y, p11X, p11Y, p12X, p12Y, p13X, p13Y, p22X, p22Y, p31X, p31Y, __p3X, __p3Y);
    
      // subsequent sweeps are all midpoint subdivision
      if( __subdiv == 2 || __subdiv == 3 )
      {  
        // left1 splits into left1 and left2
        p11X = 0.5*__left1[0] + 0.5*__left1[2];
        p11Y = 0.5*__left1[1] + 0.5*__left1[3];

        p21X = 0.5*__left1[2] + 0.5*__left1[4];
        p21Y = 0.5*__left1[3] + 0.5*__left1[5];

        p31X = 0.5*__left1[4] + 0.5*__left1[6];
        p31Y = 0.5*__left1[5] + 0.5*__left1[7];

        p12X = 0.5*p11X + 0.5*p21X;
        p12Y = 0.5*p11Y + 0.5*p21Y;

        p22X = 0.5*p21X + 0.5*p31X;
        p22Y = 0.5*p21Y + 0.5*p31Y;

        p13X = 0.5*p12X + 0.5*p22X;
        p13Y = 0.5*p12Y + 0.5*p22Y;
 
        __setCoef(__left1, __left2, __left1[0], __left1[1], p11X, p11Y, p12X, p12Y, p13X, p13Y, p22X, p22Y, p31X, p31Y, __left1[6], __left1[7]);

        // right1 splits into right1 and right2
        p11X = 0.5*__right1[0] + 0.5*__right1[2];
        p11Y = 0.5*__right1[1] + 0.5*__right1[3];

        p21X = 0.5*__right1[2] + 0.5*__right1[4];
        p21Y = 0.5*__right1[3] + 0.5*__right1[5];

        p31X = 0.5*__right1[4] + 0.5*__right1[6];
        p31Y = 0.5*__right1[5] + 0.5*__right1[7];

        p12X = 0.5*p11X + 0.5*p21X;
        p12Y = 0.5*p11Y + 0.5*p21Y;

        p22X = 0.5*p21X + 0.5*p31X;
        p22Y = 0.5*p21Y + 0.5*p31Y;

        p13X = 0.5*p12X + 0.5*p22X;
        p13Y = 0.5*p12Y + 0.5*p22Y;
 
        __setCoef(__right1, __right2, __right1[0], __right1[1], p11X, p11Y, p12X, p12Y, p13X, p13Y, p22X, p22Y, p31X, p31Y, __right1[6], __right1[7]);
      }
      
      if( __subdiv == 3 )
      {  
        // left1 splits into left1 and left1a
        p11X = 0.5*__left1[0] + 0.5*__left1[2];
        p11Y = 0.5*__left1[1] + 0.5*__left1[3];

        p21X = 0.5*__left1[2] + 0.5*__left1[4];
        p21Y = 0.5*__left1[3] + 0.5*__left1[5];

        p31X = 0.5*__left1[4] + 0.5*__left1[6];
        p31Y = 0.5*__left1[5] + 0.5*__left1[7];

        p12X = 0.5*p11X + 0.5*p21X;
        p12Y = 0.5*p11Y + 0.5*p21Y;

        p22X = 0.5*p21X + 0.5*p31X;
        p22Y = 0.5*p21Y + 0.5*p31Y;

        p13X = 0.5*p12X + 0.5*p22X;
        p13Y = 0.5*p12Y + 0.5*p22Y;
 
        __setCoef(__left1, __left1a, __left1[0], __left1[1], p11X, p11Y, p12X, p12Y, p13X, p13Y, p22X, p22Y, p31X, p31Y, __left1[6], __left1[7]);

        // right1 splits into right1 and right1a
        p11X = 0.5*__right1[0] + 0.5*__right1[2];
        p11Y = 0.5*__right1[1] + 0.5*__right1[3];

        p21X = 0.5*__right1[2] + 0.5*__right1[4];
        p21Y = 0.5*__right1[3] + 0.5*__right1[5];

        p31X = 0.5*__right1[4] + 0.5*__right1[6];
        p31Y = 0.5*__right1[5] + 0.5*__right1[7];

        p12X = 0.5*p11X + 0.5*p21X;
        p12Y = 0.5*p11Y + 0.5*p21Y;

        p22X = 0.5*p21X + 0.5*p31X;
        p22Y = 0.5*p21Y + 0.5*p31Y;

        p13X = 0.5*p12X + 0.5*p22X;
        p13Y = 0.5*p12Y + 0.5*p22Y;
 
        __setCoef(__right1, __right1a, __right1[0], __right1[1], p11X, p11Y, p12X, p12Y, p13X, p13Y, p22X, p22Y, p31X, p31Y, __right1[6], __right1[7]);
        
        // left2 splits into left2 and left2a
        p11X = 0.5*__left2[0] + 0.5*__left2[2];
        p11Y = 0.5*__left2[1] + 0.5*__left2[3];

        p21X = 0.5*__left2[2] + 0.5*__left2[4];
        p21Y = 0.5*__left2[3] + 0.5*__left2[5];

        p31X = 0.5*__left2[4] + 0.5*__left2[6];
        p31Y = 0.5*__left2[5] + 0.5*__left2[7];

        p12X = 0.5*p11X + 0.5*p21X;
        p12Y = 0.5*p11Y + 0.5*p21Y;

        p22X = 0.5*p21X + 0.5*p31X;
        p22Y = 0.5*p21Y + 0.5*p31Y;

        p13X = 0.5*p12X + 0.5*p22X;
        p13Y = 0.5*p12Y + 0.5*p22Y;
 
        __setCoef(__left2, __left2a, __left2[0], __left2[1], p11X, p11Y, p12X, p12Y, p13X, p13Y, p22X, p22Y, p31X, p31Y, __left2[6], __left2[7]);

        // right2 splits into right2 and right2a
        p11X = 0.5*__right2[0] + 0.5*__right2[2];
        p11Y = 0.5*__right2[1] + 0.5*__right2[3];

        p21X = 0.5*__right2[2] + 0.5*__right2[4];
        p21Y = 0.5*__right2[3] + 0.5*__right2[5];

        p31X = 0.5*__right2[4] + 0.5*__right2[6];
        p31Y = 0.5*__right2[5] + 0.5*__right2[7];

        p12X = 0.5*p11X + 0.5*p21X;
        p12Y = 0.5*p11Y + 0.5*p21Y;

        p22X = 0.5*p21X + 0.5*p31X;
        p22Y = 0.5*p21Y + 0.5*p31Y;

        p13X = 0.5*p12X + 0.5*p22X;
        p13Y = 0.5*p12Y + 0.5*p22Y;
 
        __setCoef(__right2, __right2a, __right2[0], __right2[1], p11X, p11Y, p12X, p12Y, p13X, p13Y, p22X, p22Y, p31X, p31Y, __right2[6], __right2[7]);
      }
    }

    private function __setCoef(_l:Array, _r:Array, _p1X:Number, _p1Y:Number, _p11X:Number, _p11Y:Number,
                               _p12X:Number, _p12Y:Number, _p13X:Number, _p13Y:Number, _p22X:Number, _p22Y:Number,
                               _p31X:Number, _p31Y:Number, _p4X:Number, _p4Y:Number ):void
    {
      _l[0] = _p1X;
      _l[1] = _p1Y;

      _l[2] = _p11X;
      _l[3] = _p11Y;

      _l[4] = _p12X;
      _l[5] = _p12Y;

      _l[6] = _p13X;
      _l[7] = _p13Y;

      _r[0] = _p13X;
      _r[1] = _p13Y;

      _r[2] = _p22X;
      _r[3] = _p22Y;

      _r[4] = _p31X;
      _r[5] = _p31Y;

      _r[6] = _p4X;
      _r[7] = _p4Y;
    }
/**
* @description 	Method: draw(_s:Shape, _t:uint, _c:uint, _isClosed:Boolean) - Draw the cubic Bezier using a quadratic approximation, based on subdivision
*
* @param _s:Shape - Reference to Shape in which curve is drawn
* @param _t:uint  - line thickness
* @param _c:uint  - Hex code for curve color
* @param _isClosed - true if this curve is part of a larger closed shape (no initial moveTo call).  In this case, it is the responsibility
* of the caller to perform the very first moveTo().
*
* @return Nothing
*
* @since 1.1
*
*/
    public function draw(_s:Shape, _t:uint, _c:uint, _isClosed:Boolean):void
    {
      // give priority to inflection points first.
      var t:Number = __inflect();

      if( t == -1 )
        t = 0.5;

      __split(t);

      __plot(_s, _t, _c, _isClosed);
    }

    // compute inflection points for the cubic segment (return -1 if no inflection points exist)
    private function __inflect():Number
    {
      var aX:Number = -__p0X + 3*(__p1X - __p2X) + __p3X;
      var aY:Number = -__p0Y + 3*(__p1Y - __p2Y) + __p3Y;

      var bX:Number = 3*(__p0X - 2*__p1X + __p2X);
      var bY:Number = 3*(__p0Y - 2*__p1Y + __p2Y);

      var cX:Number = 3*(__p1X -__p0X);
      var cY:Number = 3*(__p1Y -__p0Y);

      var dInverse:Number = 1.0/(aY*bX - aX*bY);
      var tC:Number       = -0.5*((aY*cX - aX*cY)*dInverse);
      var radical:Number  = tC*tC - Consts.ONE_THIRD*((bY*cX - bX*cY)*dInverse);

      if( radical < 0 )
        return -1;
      else
      {
        var tS:Number = Math.sqrt(radical);
        var t1:Number = tC - tS;
        var t2:Number = tC + tS;
        t1            = (t1 > 0 && t1 <1) ? t1 : -1;
        t2            = (t2 > 0 && t2 <1) ? t2 : -1;

        // if both roots are in (0,1), take the one farthest from an endpoint
        if( t1 != -1 && t2 != -1 )
        {
          var d1:Number = Math.min(t1, 1-t1);
          var d2:Number = Math.min(t2, 1-t2);
          return (d1<d2) ? t2 : t1;
        }
        else
          return Math.max(t1,t2);
      }
    }

    private function __plot(_s:Shape, _thick:uint, _c:uint, _isClosed:Boolean):void
    {
      var g:Graphics = _s.graphics;
      g.lineStyle(_thick, _c);
        
      switch( __subdiv )
      {
      	case 1:
          // first quad. segment
          __intersect(__left1);

          if( !_isClosed )
            g.moveTo(__left1[0], __left1[1]);
            
          g.curveTo(__pX, __pY, __left1[6], __left1[7]);
    
          // second quad. segment
          __intersect(__right1);

          g.curveTo(__pX, __pY, __right1[6], __right1[7]);
        break;
        
        case 2:
          // first quad. segment
          __intersect(__left1);

          if( !_isClosed )
            g.moveTo(__left1[0], __left1[1]);
            
          g.curveTo(__pX, __pY, __left1[6], __left1[7]);
    
          // second quad. segment
          __intersect(__left2);

          g.curveTo(__pX, __pY, __left2[6], __left2[7]);
    
          // third quad. segment
          __intersect(__right1);

          g.curveTo(__pX, __pY, __right1[6], __right1[7]);

          // fourth quad. segment
          __intersect(__right2);

          g.curveTo(__pX, __pY, __right2[6], __right2[7]);
        break;
        
        case 3:
          // first quad. segment
          __intersect(__left1);

          if( !_isClosed )
            g.moveTo(__left1[0], __left1[1]);
            
          g.curveTo(__pX, __pY, __left1[6], __left1[7]);
    
          // second quad. segment
          __intersect(__left1a);

          g.curveTo(__pX, __pY, __left1a[6], __left1a[7]);
    
          // third quad. segment
          __intersect(__left2);

          g.curveTo(__pX, __pY, __left2[6], __left2[7]);
          
          // fourth quad. segment
          __intersect(__left2a);

          g.curveTo(__pX, __pY, __left2a[6], __left2a[7]);
    
          // fifth quad. segment
          __intersect(__right1);

          g.curveTo(__pX, __pY, __right1[6], __right1[7]);
          
          // sixth quad. segment
          __intersect(__right1a);

          g.curveTo(__pX, __pY, __right1a[6], __right1a[7]);

          // seventh quad. segment
          __intersect(__right2);

          g.curveTo(__pX, __pY, __right2[6], __right2[7]);
          
          // eighth quad. segment
          __intersect(__right2a);

          g.curveTo(__pX, __pY, __right2a[6], __right2a[7]);
        break;
      }
    }

    // Compute intersection of p0-p1 and p3-p2 segments, handling near-zero and near-infinite slopes
    private function __intersect(_points:Array):void
    {
      var deltaX1:Number = _points[2] - _points[0];
      var deltaX2:Number = _points[4] - _points[6];
      var d1Abs:Number   = Math.abs(deltaX1);
      var d2Abs:Number   = Math.abs(deltaX2);
      var m1:Number      = 0;
      var m2:Number      = 0;

      if( d1Abs <= Consts.ZERO_TOL )
      {
        __pX = _points[0];
        m2   = (_points[5] - _points[7])/deltaX2;
        __pY = (d2Abs <= Consts.ZERO_TOL) ? (_points[0] + 3*(_points[1]-_points[0])) : (m2*(_points[0]-_points[6])+_points[7]);
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
    }

    private function __computeCoef():void
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

      __invalidate = false;
    } 
  }
}