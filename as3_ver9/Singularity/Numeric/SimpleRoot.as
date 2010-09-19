/**
* <p>SimpleRoot.as - A straight port of Jack Crenshaw's TWBRF method for simple roots in an interval.  To use, identify an interval in which
* the function whose zero is desired has a sign change (via bisection, for example).  Call the <code>findRoot</code> method.</p>
*
* Copyright (c) 2008, Jim Armstrong.  All rights reserved.
*
* This software program is supplied 'as is' without any warranty, express, 
* implied, or otherwise, including without limitation all warranties of 
* merchantability or fitness for a particular purpose.  Jim Armstrong shall not 
* be liable for any special incidental, or consequential damages, including, 
* witout limitation, lost revenues, lost profits, or loss of prospective 
* economic advantage, resulting from the use or misuse of this software program.
*
* @author Jim Armstrong, Singularity (www.algorithmist.net)
*
* @version 1.0
*/

package Singularity.Numeric
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  
  public class SimpleRoot extends EventDispatcher
  {
    private static const TOL:Number    = 0.000001;
    private static const MAX_ITER:uint = 100;
    
    private var __iter:uint;
    
    public function SimpleRoot()
    {
      super();
      
      __iter = 0;
    }
    
    public function get iterations():uint { return __iter; }
    
/**
* <code>findRoot</code> finds a single root given an interval 
*
* @param _x0:Number root isolated in interval [_x0, _x2]
* @param _x2:Number root isolated in interval [_x0, _x2]
* @param _f:Function reference to function whose root in the interval is desired.  Function accepts a single <code>Number</code> argument.
* @param _imax:uint maximum number of iterations
* @default MAX_ITER
* @param _eps:Number tolerance value for root
* @default TOL
*
* @since 1.0
*
* @return Number: Approximation of desired root within specified tolerance and iteration limit.  In addition to too small
* an iteration limit or too tight a tolerance, some patholotical numerical conditions exist under which the method may
* incorrectly report a root.
*
*/
    public function findRoot(_x0:Number, _x2:Number, _f:Function, _imax:uint=MAX_ITER, _eps:Number=TOL):Number
    {
      var x0:Number;
      var x1:Number;
      var x2:Number;
      var y0:Number;
      var y1:Number;
      var y2:Number;
      var b:Number;
      var c:Number;
      var y10:Number;
      var y20:Number;
      var y21:Number;
      var xm:Number;
      var ym:Number;
      var temp:Number;
      
      var xmlast:Number = _x0;
      y0                = _f(_x0);
      
      if( y0 == 0.0 )
        return _x0;
  
      y2 = _f(_x2);
      if( y2 == 0.0 ) 
        return _x2;
      
      if( y2*y0 > 0.0 )
      {
        dispatchEvent( new Event("Invalid interval - no sign change - no root") );
        return _x0;
      }

      __iter = 0;
      x0     = _x0;
      x2     = _x2;
      for( var i:uint=0; i<_imax; ++i)
      {
        __iter++;
        
        x1 = 0.5 * (x2 + x0);
        y1 = _f(x1);
        if( y1 == 0.0 ) 
          return x1;
          
        if( Math.abs(x1 - x0) < _eps) 
          return x1;
          
        if( y1*y0 > 0.0 )
        {
          temp = x0;
          x0   = x2;
          x2   = temp;
          temp = y0;
          y0   = y2;
          y2   = temp;
        }
        
        y10 = y1 - y0;
        y21 = y2 - y1;
        y20 = y2 - y0;
        if( y2*y20 < 2.0*y1*y10 )
        {
          x2 = x1;
          y2 = y1;
        }
        else
        {
          b  = (x1  - x0 ) / y10;   
          c  = (y10 - y21) / (y21 * y20); 
          xm = x0 - b*y0*(1.0 - c*y1);
          ym = _f(xm);
          if( ym == 0.0 ) 
            return xm;
            
          if( Math.abs(xm - xmlast) < _eps )
            return xm;
          
          xmlast = xm;
          if( ym*y0 < 0.0 )
          {
            x2 = xm;
            y2 = ym;
          }
          else
          {
            x0 = xm;
            y0 = ym;
            x2 = x1;
            y2 = y1;
          }
        }
      }
      
      dispatchEvent( new Event( "failed to converge after maximim iterations of" + __iter ) );
      return x1;
    }  
  }
}
