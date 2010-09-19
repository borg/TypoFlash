//
// IParametric.as - Interface for single-segment parametric curves
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
// programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//

package Singularity.Geom
{
  import flash.display.Shape;
  import flash.geom.Point;
  
  public interface IParametric
  {
  	// access the degree of this parametric curve
  	function get degree():uint;
  	
  	// Setters for drawing methods
  	function set color(_c:uint):void;
  	function set thickness(_t:uint):void;
  	function set container(_s:Shape):void;
  	
  	// get auto-computed parameter for specified segment (in interpolation)
  	function getParam(_seg:uint):Number;
  	  	
  	// add a single control point
  	function addControlPoint( _xCoord:Number, _yCoord:Number ):void
  	
  	// move a single control point at the specified index
  	function moveControlPoint(_indx:uint, _newX:Number, _newY:Number):void
  	
  	// access the coordinates of a specified control point
  	function getControlPoint(_indx:uint):Point
  	
  	// compute the arc length of the curve
  	function arcLength():Number
  	
  	// draw the curve
  	function draw(_t:Number):void
  	
  	// redraw the curve with a new color setting, leaving internal setting unchanged
  	function reColor(_c:Number):void
  	
  	// redraw the curve with the default color and thickness settings
  	function reDraw():void
  	
  	// reset all control points
  	function reset():void
  	
  	// return the x-coordinate of the curve for a given parameter value
    function getX(_t:Number):Number

    // return the y-coordinate of the curve for a given parameter value
    function getY(_t:Number):Number
    
    // return the x-coordinate of the curve's first derivative for a given parameter value
    function getXPrime(_t:Number):Number

    // return the y-coordinate of the curve's first derivative for a given parameter value
    function getYPrime(_t:Number):Number
    
    // return the parameter value at minimum x
    function tAtMinX():Number;
    
    // return the parameter value at minimum y
    function tAtMinY():Number;
    
    // return the parameter value at maximum x
    function tAtMaxX():Number;
    
    // return the parameter value at maximum y
    function tAtMaxY():Number;
    
    // interpolate a set of control points (usually used to fit low-order Bezier curves to a set of points with automatic parameterization)
    function interpolate(_points:Array):void
    
    // return the i-th coefficient of the parametric curve (coefficients used to evaluate the curve in nested form)
    function getCoef(_i:uint):Object;
    
    // return a String representation of the curve
    function toString():String
  }
}