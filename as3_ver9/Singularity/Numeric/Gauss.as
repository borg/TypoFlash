//
// Gauss.as - Gauss-Legendre Numerical Integration. 
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
// Programmed by:  Jim Armstrong, Singularity (www.algorithmist.net)
//

package Singularity.Numeric
{
  import flash.events.EventDispatcher;
  import Singularity.Events.SingularityEvent;

  public class Gauss extends EventDispatcher
  {
    public static const MAX_POINTS:Number = 8;

    // core
    private var __abscissa:Array;         // abscissa table
    private var __weight:Array;           // weight table
    private var __error:SingularityEvent; // reference to standard error event

/**
* @description 	Method: Gauss() - Construct a new Gauss instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function Gauss()
    { 
      __abscissa = new Array();
      __weight   = new Array();
      
      __error           = new SingularityEvent(SingularityEvent.ERROR);
      __error.classname = "Gauss";

      // N=2
      __abscissa.push(-0.5773502692);
      __abscissa.push( 0.5773502692);

      __weight.push(1);
      __weight.push(1);

      // N=3
      __abscissa.push(-0.7745966692);
      __abscissa.push( 0.7745966692);
      __abscissa.push(0);
    
      __weight.push(0.5555555556); 
      __weight.push(0.5555555556);
      __weight.push(0.8888888888);

      // N=4
      __abscissa.push(-0.8611363116);
      __abscissa.push( 0.8611363116);
      __abscissa.push(-0.3399810436);
      __abscissa.push( 0.3399810436);

      __weight.push(0.3478548451);
      __weight.push(0.3478548451);
      __weight.push(0.6521451549);
      __weight.push(0.6521451549);

      // N=5
      __abscissa.push(-0.9061798459);
      __abscissa.push( 0.9061798459);
      __abscissa.push(-0.5384693101);
      __abscissa.push( 0.5384693101);
      __abscissa.push( 0.0000000000);

      __weight.push(0.2369268851);
      __weight.push(0.2369268851);
      __weight.push(0.4786286705);
      __weight.push(0.4786286705);
      __weight.push(0.5688888888);
 
      // N=6
      __abscissa.push(-0.9324695142);
      __abscissa.push( 0.9324695142);
      __abscissa.push(-0.6612093865);
      __abscissa.push( 0.6612093865);
      __abscissa.push(-0.2386191861);
      __abscissa.push( 0.2386191861);

      __weight.push(0.1713244924);
      __weight.push(0.1713244924);
      __weight.push(0.3607615730);
      __weight.push(0.3607615730);
      __weight.push(0.4679139346);
      __weight.push(0.4679139346);
 
      // N=7
      __abscissa.push(-0.9491079123);
      __abscissa.push( 0.9491079123);
      __abscissa.push(-0.7415311856);
      __abscissa.push( 0.7415311856);
      __abscissa.push(-0.4058451514);
      __abscissa.push( 0.4058451514);
      __abscissa.push( 0.0000000000);

      __weight.push(0.1294849662);
      __weight.push(0.1294849662);
      __weight.push(0.2797053915);
      __weight.push(0.2797053915);
      __weight.push(0.3818300505);
      __weight.push(0.3818300505);
      __weight.push(0.4179591837);

      // N=8
      __abscissa.push(-0.9602898565); 
      __abscissa.push( 0.9602898565);
      __abscissa.push(-0.7966664774);
      __abscissa.push( 0.7966664774);
      __abscissa.push(-0.5255324099);
      __abscissa.push( 0.5255324099);
      __abscissa.push(-0.1834346425); 
      __abscissa.push( 0.1834346425);

      __weight.push(0.1012285363);
      __weight.push(0.1012285363);
      __weight.push(0.2223810345);
      __weight.push(0.2223810345);
      __weight.push(0.3137066459);
      __weight.push(0.3137066459);
      __weight.push(0.3626837834);
      __weight.push(0.3626837834);
    }

/**
* @description 	Method: eval(_f:Function, _a:Number, _b:Number, _n:Number) - Approximate integral over specified range
*
* @param _f:Function - Reference to function to be integrated - must accept a numerical argument and return 
*                      the function value at that argument.
*
* @param _a:Number   - Left-hand value of interval.
* @param _b:Number   - Right-hand value of inteval.
* @param _n:Number   - Number of points -- must be between 2 and 8
*
* @return Number - approximate integral value over [_a, _b]
*
* @since 1.0
*
*/
    public function eval(_f:Function, _a:Number, _b:Number, _n:uint):Number
    {
      __error.methodname = "eval()";
      if( isNaN(_a) || isNaN(_b) )
      {
        __error.message = "Invalid interval values";
        dispatchEvent(__error);
        return 0;
      } 

      if( _a >= _b )
      {
        __error.message = "Left-hand interval value overlaps right-hand value";
        dispatchEvent(__error);
        return 0;
      }

      if( !(_f is Function) )
      {
        __error.message = "Invalid function reference";
        dispatchEvent(__error);
        return 0;
      }
 
      if( isNaN(_n) || _n < 2 )
      {
        __error.message = "Invalid number of intervals: " + _n.toString();
        dispatchEvent(__error);
        return 0;
      }

      var n:uint = Math.max(_n,2);
      n          = Math.min(n,MAX_POINTS);

      var l:uint     = (n==2) ? 0 : n*(n-1)/2 - 1;
      var sum:Number = 0;

      if( _a == -1 && _b == 1 )
      {
        for( var i:uint=0; i<n; ++i )
          sum += _f(__abscissa[l+i])*__weight[l+i];

        return sum;
      }
      else
      {
        // change of variable
        var mult:Number = 0.5*(_b-_a);
        var ab2:Number  = 0.5*(_a+_b);
        for( i=0; i<n; ++i )
          sum += _f(ab2 + mult*__abscissa[l+i])*__weight[l+i];

        return mult*sum;
      }
    }
  }
}