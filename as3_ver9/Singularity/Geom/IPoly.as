//
// IPoly.as - Interface for parametric polynomials of arbitrary degree.
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

package Singularity.Geom
{
  public interface IPoly
  {
  	// access the degree of this polynomial
  	function get degree():uint;
  	
  	// access and add coefficients
    function addCoef( _cX:Number, _cY:Number):void;
    function getCoef( _indx:uint ):Object;
    
  	// clear coefficient values
    function reset():void

    // evaluate polynomial x-coordinate at a given t
    function getX(_t:Number):Number
    
    // evaluate polynomial y-coordinate at a given t
    function getY(_t:Number):Number

    // evaluate x-coordinate of derivative at a given t
    function getXPrime(_t:Number):Number
    
    // evaluate y-coordinate of derivative at a given t
    function getYPrime(_t:Number):Number

    // evaluate dy/dx at a given t
    function getDeriv(_t:Number):Number

    function toString():String
  }
}