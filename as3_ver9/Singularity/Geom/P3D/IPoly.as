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

package Singularity.Geom.P3D
{
  public interface IPoly
  {
    function addCoef( _cX:Number, _cY:Number, _cZ:Number ):void;
    function getCoef( _indx:uint ):Object;
    
  	// clear coefficient values
    function reset():void

    // evaluate polynomial x-coordinate at a given t
    function getX(_t:Number):Number
    
    // evaluate polynomial y-coordinate at a given t
    function getY(_t:Number):Number
    
    // evaluate polynomial z-coordinate at a given t
    function getZ(_t:Number):Number

    // evaluate dx/dt
    function getXPrime(_t:Number):Number
    
    // evaluate dy/dt
    function getYPrime(_t:Number):Number
    
    // evaluate dz/dt
    function getZPrime(_t:Number):Number

    // evaluate dy/dx
    function getDyDx(_t:Number):Number
    
    // evaluate dz/dx at a given t
    function getDzDx(_t:Number):Number

    function toString():String
  }
}