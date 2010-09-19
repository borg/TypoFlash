//
// Composite.as - Base class for composite or piecewise curves.
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
// Programmed by:  Jim Armstrong, Singularity (www.algorithmist.net)
//

package Singularity.Geom
{
  import flash.events.EventDispatcher;
  import flash.display.Graphics;
  import flash.display.Shape;
  import flash.geom.ColorTransform;

  import Singularity.Events.SingularityEvent;
  
  import Singularity.Numeric.Consts;
  import Singularity.Numeric.Gauss;
  import Singularity.Geom.FastCubicSpline;
  
  public class Composite extends EventDispatcher
  {
    // core
    protected var __count:uint;                  // count number of points added
    protected var __invalidate:Boolean;          // true if current coefficients are invalid
    protected var __error:SingularityEvent;      // reference to standard Error event
    protected var __container:Shape;             // reference to Shape in which curve is drawn
    protected var __consts:Consts;               // reference to commonly used constants

    // drawing
    protected var __color:Number;                // arc color
    protected var __thickness:Number;            // arc thickness
    
    // Arc-length computation and parameterization
    protected var __param:String;                // parameterization method
    protected var __integral:Gauss;              // Gauss-Legendre integration class
    protected var __arcLength:Number;            // current arc length
    protected var __spline:FastCubicSpline;      // interpolate arc-length vs. t

/**
* @description 	Method: Composite() - Construct a new base composite curve
*
* @return Nothing
*
* @since 1.0
*
*/
    public function Composite()
    {
      __color      = 0x0000ff;
      __thickness  = 1;
      __count      = 0;
      __invalidate = true;
      __container  = null;
      __arcLength  = -1;

      __error           = new SingularityEvent(SingularityEvent.ERROR);
      __error.classname = "Composite";
      
      __consts = new Consts();
      __spline = new FastCubicSpline();

      __integral = new Gauss();
    }
    
    public function set color(_c:uint):void
    {
      __color = _c;
    }

    public function set thickness(_t:uint):void
    {
      __thickness = Math.round(_t);
    }
    
    public function set container(_s:Shape):void
    {
      __container = _s;
    }
    
    public function set parameterize(_s:String):void
    {
      if( _s == Consts.ARC_LENGTH || _s == Consts.UNIFORM )
      {
        __param      = _s;
        __invalidate = true;
      }
    }
    
    public function reColor(_c:Number):void
    {
      var g:Graphics = __container.graphics;
      
      var colorXForm:ColorTransform = __container.transform.colorTransform;
      colorXForm.color = _c;
      __container.transform.colorTransform = colorXForm;
    }

    public function reDraw():void
    {
      var g:Graphics = __container.graphics;
      
      var colorXForm:ColorTransform = __container.transform.colorTransform;
      colorXForm.color = __color;
      __container.transform.colorTransform = colorXForm;
    }

    // Following methods should be overridden in subclass    
    public function __integrand(_t:Number):Number { throw new Error("Composite::__integrand() must be overriden") }
    
    public function arcLength():Number { throw new Error("Composite::arcLength() must be overriden") }
    
    public function arcLengthAt(_t:Number):Number { throw new Error("Composite::arcLengthAt() must be overriden") }
      
    public function addControlPoint( _xCoord:Number, _yCoord:Number ):void {throw new Error("Composite::addControlPoint() must be overriden")}
    
    public function moveControlPoint(_indx:uint, _newX:Number, _newY:Number):void {throw new Error("Composite::addControlPoint() must be overriden")}
    
    public function draw(_t:Number=1.0):void {throw new Error("Composite::draw() must be overriden")}
  	
    public function reset():void {throw new Error("Composite::reset() must be overriden")}
  	
    public function getX(_t:Number):Number {throw new Error("Composite::getX() must be overriden")}

    public function getY(_t:Number):Number {throw new Error("Composite::getY() must be overriden")}
    
  }
}