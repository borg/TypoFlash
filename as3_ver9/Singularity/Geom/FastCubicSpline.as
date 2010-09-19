//
// FastCubicSpline.as - Natural cubic spline without the generality of the Composite::Spline 3 class.  
//
// Reference:  http://www.algorithmist.net/spline.html
//
// copyright (c) 2005-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special
// incidental, or consequential damages, including, without limitation, lost
// revenues, lost profits, or loss of prospective economic advantage, resulting
// from the use or misuse of this software program.
//
//
// Note:  Although some attempt has been made to optimize operation count and complexity, this code
//        is written more for clarity than Actionscript performance.
//
// Programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
//
// Important notes:  1) Intervals must be non-overlapping.  Insertion preserves this constraint.
//
//                   2) Knot insertion/deletion causes a complete regeneration of coefficients.
//                      This version of the code is optimized for a single set of knots.
//

package Singularity.Geom
{
  
  public class FastCubicSpline
  {
    // read associated white paper for details on these variables
    private var __t:Array;
    private var __y:Array;
    private var __u:Array;
    private var __v:Array;
    private var __h:Array;
    private var __b:Array;
    private var __z:Array;

    private var __hInv:Array;             // precomputed h^-1 values
    private var __delta:Number;           // current x-t(i)
    private var __knots:uint;             // current knot count
    
    private var __invalidate:Boolean;     // true if coefs are invalid

/**
* @description 	Method: Spline3() - Construct a new Spline3 instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function FastCubicSpline()
    {
      __t    = new Array();
      __y    = new Array();
      __u    = new Array();
      __v    = new Array();
      __h    = new Array();
      __b    = new Array();
      __z    = new Array();
      __hInv = new Array();

      __invalidate = true;
      __delta      = 0.0;
      __knots      = 0;
    }

    // return knot count
    public function get knotCount():Number { return __knots; }

    // return array of Objects with X and Y properties containing knot coordinates
    public function get knots():Array
    {
      var knotArr:Array = new Array();
      for( var i:uint=0; i<__knots; ++i )
        knotArr.push({X:__t[i], Y:__y[i]});

      return knotArr;
    }

/**
* @description 	Method: addControlPoint( _xKnot:Number, _yKnot:Number ) - Add/Insert a knot in a manner that maintains
* non-overlapping intervals.  This method rearranges knot order, if necessary, to maintain non-overlapping intervals.
*
* @param _t:Number - x-coordinate of knot to add
* @param _y:Number - y-coordinate of knot to add
*
* @return Nothing
*
* @since 1.0
*
*/
    public function addControlPoint(_xKnot:Number, _yKnot:Number):void
    {
      __invalidate = true;

      if( __t.length == 0 )
      {
        __t.push(_xKnot);
        __y.push(_yKnot);
        __knots++;
      }
      else
      {
        if ( _xKnot > __t[__knots-1] )
        {
          __t.push(_xKnot);
          __y.push(_yKnot);
          __knots++;
        }
        else if( _xKnot < __t[0] )
          __insert(_xKnot, _yKnot, 0);
        else
        {
          if( __knots > 1 )
          {
            for( var i:int=0; i<__knots-1; ++i )
            {
              if( _xKnot > __t[i] && _xKnot < __t[i+1] )
                __insert(_xKnot, _yKnot, i+1 );
            }
          }
        }
      }
    }

    // insert knot at index
    private function __insert(_xKnot:Number, _yKnot:Number, _indx:int):void
    {
      __t.splice(_indx, 0, _xKnot );
      __y.splice(_indx, 0, _yKnot );

      __knots++;
    }
    
/**
* @description 	Method: deleteAllKnots() - Delete all knots
*
* @return Nothing
*
* @since 1.0
*
*/
    public function deleteAllKnots():void
    {
      __t.splice(0);
      __y.splice(0);

      __knots      = 0;
      __invalidate = true;
    }


/**
* @description 	Method: eval( _xKnot:Number ) - Evaluate spline at a given x-coordinate
*
* @param _xKnot:Number - x-coordinate to evaluate spline
*
* @return Number: - NaN if there are no knots
*                 - y[0] if there is only one knot
*                 - Spline value at the input x-coordinate, if there are two or more knots
*
* @since 1.0
*
*/
    public function eval(_xKnot:Number):Number
    {
      if( __knots == 0 )
        return NaN;
      else if( __knots == 1 )
        return __y[0];
      else
      {
        if( __invalidate )
          __computeZ();

        // determine interval
        var i:uint = 0;
        __delta    = _xKnot - __t[0];
        for( var j:uint=__knots-2; j>=0; j-- )
        {
          if( _xKnot >= __t[j] )
          {
            __delta = _xKnot - __t[j];
            i = j;
            break;
          }
        }

        var b:Number = (__y[i+1] - __y[i])*__hInv[i] - __h[i]*(__z[i+1] + 2.0*__z[i])*0.1666666666666667;
        var q:Number = 0.5*__z[i] + __delta*(__z[i+1]-__z[i])*0.1666666666666667*__hInv[i];
        var r:Number = b + __delta*q;
        var s:Number = __y[i] + __delta*r;

        return s;
      }
    }

    // compute z[i] based on current knots
    private function __computeZ():void
    {
      // reference the white paper for details on this code

      // pre-generate h^-1 since the same quantity could be repeatedly calculated in eval()
      for( var i:uint=0; i<__knots-1; ++i )
      {
        __h[i]    = __t[i+1] - __t[i];
        __hInv[i] = 1.0/__h[i];
        __b[i]    = (__y[i+1] - __y[i])*__hInv[i];
      }

      // recurrence relations for u(i) and v(i) -- tridiagonal solver
      __u[1] = 2.0*(__h[0]+__h[1]);
      __v[1] = 6.0*(__b[1]-__b[0]);
   
      for( i=2; i<__knots-1; ++i )
      {
        __u[i] = 2.0*(__h[i]+__h[i-1]) - (__h[i-1]*__h[i-1])/__u[i-1];
        __v[i] = 6.0*(__b[i]-__b[i-1]) - (__h[i-1]*__v[i-1])/__u[i-1];
      }

      // compute z(i)
      __z[__knots-1] = 0.0;
      for( i=__knots-2; i>=1; i-- )
        __z[i] = (__v[i]-__h[i]*__z[i+1])/__u[i];

      __z[0] = 0.0;

      __invalidate = false;
    }
  }
}