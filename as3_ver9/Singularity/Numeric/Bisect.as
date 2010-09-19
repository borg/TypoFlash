//
// Bisect.as - A simple implementation of bisection to identify intervals of a function in which there is a sign change.
// This is a generic implementation, unlike the version inside the Bezier classes that is embedded for a bit extra
// performance.
//
// copyright (c) 2006-2008, Jim Armstrong.  All Rights Reserved.
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
// Version 1.0
//

package Singularity.Numeric
{ 
  public class Bisect
  {
  	private static const BISECT_LIMIT:Number = 0.05;  // will probably make this changeable in the future
  	
    public function Bisect()
    {
      // Empty
    }

/**
* @description 	Method: bisection( _f:Function, _left:Number, _right:Number ):Object
*
* @param _f:Function function whose root(s) are desired
* @param _left:Number leftmost x-coordinate of interval to be bisected
* @param _right:Number rightmost x-coordinate of interval to be bisected
*
* @return Object 'left' property contains the leftmost x-coordinate of the interval and 'right' property contains the rightmost x-coordinate of the interval
*
* @since 1.0
*
*/

    public static function bisection(_f:Function, _left:Number, _right:Number):Object
    {
      if( Math.abs(_right-_left) <= BISECT_LIMIT )
      {
        return null;
      }
        
      var leftInterval:Number = _left;
      var rightInterval:Number = _right;
      
      var left:Number   = _left;
      var right:Number  = _right;
      var middle:Number = 0.5*(left+right);
      if( _f(left)*_f(right) <= 0 )
      {
        leftInterval  = left;
        rightInterval = right;
        return null;
      }
      else
      {
        bisection(_f, left, middle);
        bisection(_f, middle, right);
      }
      
      return {left:leftInterval, right:rightInterval}
    }
    
  }
}