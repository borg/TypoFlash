//
// Solve2x2.as - A simple solver for two equations and two unknowns using Cramer's rule.  If the determinant is close to zero
// a zero vector is returned as the solution.
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
  import flash.geom.Point;
  
  public class Solve2x2
  {
  	private var __determinant:Number;                // value of determinant
  	
    public function Solve2x2()
    {
      __determinant = 0;
    }

    public function get determinant():Number { return __determinant; }
    
/**
* @description 	Method: solve( _a11:Number, _a12:Number, _a21:Number, _a22:Number, _a:Number, _b:Number, _zerTol:Number=0.00001, _resolve:Boolean=false ):Point
*
* @param _a11:Number coefficient of x in first equation
* @param _a12:Number coefficient of y in first equation
* @param _a21:Number coefficient of x in second equation
* @param _a22:Number coefficient of y in second equation
* @param _b1:Number right-hand side value in first equation
* @param _b2:Number right-hand side value in second equation
* @param _zeroTol:Number optional zero-tolerance for determinant
* @default 0.00001
* @param _resolve:Boolean true if resolving a new system of equations with same coefficients, but different RHS
* @default false
*
* @return Point contains solution values or zero-vector if determinant is less than or equal to zero tolerance
*
* @since 1.0
*
*/
    public function solve( _a11:Number, _a12:Number, _a21:Number, _a22:Number, _b1:Number, _b2:Number, _zeroTol:Number=0.00001, _resolve:Boolean=false ):Point
    {
      if( !_resolve )
      {
        __determinant = _a11*_a22 - _a12*_a21;
      }
      
      // exercise - dispatch an event if the determinant is near zero
      if( __determinant > _zeroTol )
      {
        var x:Number = (_a22*_b1 - _a12*_b2)/__determinant;
        var y:Number = (_a11*_b2 - _a21*_b1)/__determinant;
        
        return new Point(x,y);          
      }
      
      return new Point(0,0);
    }
  }
}