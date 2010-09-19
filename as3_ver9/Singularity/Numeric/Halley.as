/**
* <p>Halley.as - Compute simple roots of the equation f(x) = 0 given a starting point and convergence criteria, using
* Halley's method.  To use, set the iteration limit and tolerance, then call the <code>findRoot</code> method.</p>
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
  public class Halley
  {
    // experimentation with these values is encouraged
    private static const TOLERANCE:Number = 0.000001;
    private static const ZERO_TOL:Number  = 0.0000000000000001;
    private static const ITER_LIMIT:uint  = 100;
    
    private var __iter:uint;        // number of iterations
    private var __iterLimit:uint;   // maximum number of allowed iterations
    private var __tolerance:Number; // tolerance for convergence (absolute error between iterates)
    private var __previous:Number;  // value of previous iteration
  
    public function Halley()
    {
      __iter      = 0;
      __iterLimit = ITER_LIMIT;
      __tolerance = TOLERANCE;
      __previous  = 0;
    }
    
    // access iteration count
    public function get iterations():uint { return __iter; }
    
    // allow caller to access previous iteration value to determine 'closeness' of iterates at stopping criteria
    public function get previousIterate():Number { return __previous; }
    
    // set the convergence tolerance
    public function set tolerance(_tol:Number):void
    {
      if( _tol > 0 )
        __tolerance = _tol;
    }
    
    // set the iteration limit (should be greater than zero)
    public function set iterLimit(_limit:uint):void { __iterLimit = _limit > 0 ? _limit : 1; }

/**
* <code>findRoot</code> finds a single root given convergence tolerance and starting point
*
* @param _start:Number desired starting point for iteration
* @param _function:Function reference to <code>Function</code> to evalute f(x)
* @param _deriv:Function reference to <code>Function</code> to evaluate f'(x)
* @param _secondDeriv:Function reference to <code>Function</code> to evaluate f''(x)
*
* @since 1.0
*
* @return Number: Approximation of desired root or iterate value at which iteration limit was met (the method always performs at
* least one iteration)
*
*/
    public function findRoot( _start:Number, _function:Function, _deriv:Function, _secondDeriv:Function ):Number   
    {
      __iter     = 0;
      __previous = _start;
      
      if( _function == null || _deriv == null )
        return __previous;
        
     
      // Exercise - modify stopping criteria to use relative error - what situations might lead to problems in the formula?
      // see Wikipedia article
      __iter               = 1;
      var f:Number         = _function(__previous);
      var deriv:Number     = _deriv(__previous);
      var x:Number         = __previous - (2*f*deriv) / (2*deriv*deriv - f*_secondDeriv(__previous));
      var finished:Boolean = Math.abs(x - __previous) < __tolerance;
      
      while( __iter < __iterLimit && !finished )
      {
        __previous = x;
        
        f        = _function(__previous);
        deriv    = _deriv(__previous);
        x        = __previous - (2*f*deriv) / (2*deriv*deriv - f*_secondDeriv(__previous));
        finished = Math.abs(x - __previous) < __tolerance;
      
        __iter++;
      }
      
      return x;
    }
  }
}