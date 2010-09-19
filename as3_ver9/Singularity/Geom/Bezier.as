package Singularity.Geom
{
//
// Bezier.as - Arbitrary-order Bezier curve.  This class is intended to illustrate numerical issues and
// a very general application of DeCasteljau's method.  For educational purposes only - this class has
// little practical benefit other than as a teaching tool.
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
//
  import flash.display.Graphics;
  
  import Singularity.Numeric.Binomial;
  import Singularity.Numeric.Consts;

  public class Bezier
  {
    // properties
    private var __useCoef:Boolean;        // true if precomputed coefficients are generated and used
    
  	private var __x:Array;                // array of x-coordinates
  	private var __y:Array;                // array of y-coordinates

    private var __binomial:Binomial;      // binomial coefficients
    private var __pascal:Array;           // specific row of Pascal's triangle for naive evaluation
    private var __coef:Coef;              // used for pregenerated and stored coefficients
    private var __invalidate:Boolean;     // true if previous coef. computations are invalid
/**
* @description 	Method: Bezier() - Construct a new Bezier instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function Bezier()
    {
      __x      = new Array();
      __y      = new Array();
      __pascal = new Array();
      
      __binomial = new Binomial();
      __coef     = new Coef();
      
      __useCoef    = false;
      __invalidate = false;
    }

    public function set useCoef(_b:Boolean):void
    {
      __useCoef    = _b;
      __invalidate = true;      
    }

/**
* @description 	Method: addControlPoint( _xCoord:Number, _yCoord:Number ) - Add a control point
*
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
*
* @return Nothing - Adds control points in order called.
*
* @since 1.0
*
*/
    public function addControlPoint( _xCoord:Number, _yCoord:Number ):void
    {
      __x.push(_xCoord);
      __y.push(_yCoord);
  
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
      __x.splice(0);
      __y.splice(0);
      __pascal.splice(0);
      
      __coef.reset();
    }


/**
* @description 	Method: getX( _t:Number ) - Return x-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: x-coordinate of Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
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
    
      return __useCoef ? __coef.getX(t) : __naiveX(t);
    }
    
    // return x(t) using the naive or direct formula
    private function __naiveX(_t:Number):Number
    {
      // yes, this is pretty naive :)
      var t1:Number   = 1.0 - _t;
      var eval:Number = 0;
      
      // kids, don't do this at home ...
      var n:uint = __x.length;
      for( var i:uint=0; i<n; ++i )
        eval += __pascal[i]*__x[i]*Math.pow(t1,n-i-1)*Math.pow(_t,i);
        
      return eval;
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

      return __useCoef ? __coef.getY(t) : __naiveY(t);
    }
    
    // return y(t) using the naive or direct formula
    private function __naiveY(_t:Number):Number
    {
      // again, very naive :)
      var t1:Number   = 1.0 - _t;
      var eval:Number = 0;
      
      // kids, don't do this at home, especially since the power computations are duplicated from computing x(t)
      var n:uint = __y.length;
      for( var i:uint=0; i<n; ++i )
        eval += __pascal[i]*__y[i]*Math.pow(t1,n-i-1)*Math.pow(_t,i);
        
      return eval;
    }

    private function __computeCoef():void
    {
      // straight evaluation or precompute coefficients???
      if( !__useCoef )
      {
        __pascal.splice(0);
        __pascal = __binomial.getRow(__x.length-1);
      }
      else
      {
        __coef.reset();
        
        // direct and straightforward, but a bit on the naive side ... how about getting rid of those factorials?
        var n:int        = __x.length-1;
        var nFact:Number = __factorial(n);
        for( var j:int=0; j<=n; ++j )
        {
          var myObj:Object = __summation(j);
          var xC:Number    = myObj.x;
          var yC:Number    = myObj.y;
        
          var mult:Number = nFact/__factorial(n-j);
          xC               *= mult;
          yC               *= mult;
          
          __coef.addCoef(xC, yC); 
        }
      }
      
      __invalidate = false;
    }
    
    // as an exercise, try manually in-lining this function and optimizing the computations across outer loop iterations
    private function __summation(_j:int):Object
    {
      var iFact:Number    = 1.0;
      var minusOne:Number = (_j%2 == 0) ? 1.0 : -1;
      
      // this directly implements the formula, but is not optimized
      var xSum:Number = 0;
      var ySum:Number = 0;
      for( var i:int=0; i<=_j; ++i )
      {
        var jmiFact:Number = __factorial(_j-i);
        var denom:Number   = iFact*jmiFact;
        xSum              += (minusOne*__x[i])/denom;
        ySum              += (minusOne*__y[i])/denom;
        iFact             *= Number(i+1);  
        minusOne          *= -1.0;
      }
      
      return {x:xSum, y:ySum}; 
    }
    
    // hint - inline and optimize ...
    private function __factorial(_i:int):Number
    {
      if( _i == 0 )
        return 1.0;
        
      var j:int = _i;
      var k:int = _i;
      while( --j > 0 )
        k *= j;
        
      return Number(k);
    }
  }

}