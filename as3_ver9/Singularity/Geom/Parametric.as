//
// Parametric.as - Base class for single-segment parametric curves.
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

package Singularity.Geom
{
  import Singularity.Events.SingularityEvent;
  import Singularity.Numeric.Consts;
  import Singularity.Numeric.Gauss;
  
  import flash.display.Shape;
  import flash.events.EventDispatcher;
  import flash.geom.Point;
  import flash.utils.getQualifiedClassName;
  
  public class Parametric extends EventDispatcher implements IParametric
  {
    // core
    protected var __count:uint;                  // count number of points added
    protected var __invalidate:Boolean;          // true if current coefficients are invalid
    protected var __coef:IPoly;                  // polynomial curve that implements IPoly interface
    protected var __error:SingularityEvent;      // reference to standard Error event
    protected var __container:Shape;             // reference to Shape in which curve is drawn

    // Arc-length computation and parameterization
    protected var __arcLength:Number;            // estimate of arc length;
    protected var __integrand:Function;          // function to integrate to compute arc length
    protected var __integral:Gauss;              // Gauss-Legendre integration class
    protected var __param:String;                // parameterization method
    protected var __spline:FastCubicSpline;      // interpolate arc-length vs. t
    
    protected var __t:Number;                    // current t-value
    protected var __s:Number;                    // current arc-length

    // drawing
    protected var __color:Number;                // arc color
    protected var __thickness:Number;            // arc thickness

/**
* @description 	Method: Parameteric() - Construct a new base parametric curve
*
* @return Nothing
*
* @since 1.0
*
*/
    public function Parametric()
    {
      __color      = 0x0000ff;
      __thickness  = 1;
      __count      = 0;
      __invalidate = true;
      __container  = null;

      __error           = new SingularityEvent(SingularityEvent.ERROR);
      __error.classname = "Parametric";
      
      __integrand = function(_t:Number):Number
      {
        var x:Number = __coef.getXPrime(_t);
        var y:Number = __coef.getYPrime(_t);

        return Math.sqrt( x*x + y*y );
      };

      __integral = new Gauss();
      __integral.addEventListener( SingularityEvent.ERROR, __onError );
      
      __spline = new FastCubicSpline();
      
      __param     = Consts.UNIFORM;
      __arcLength = -1;
      __t         = 0;
      __s         = 0;
    }

    private function __onError(_e:SingularityEvent):void
    {
      __error.message = _e.toString() + " during numerical integration.";
      dispatchEvent( __error );
    }
    
    public function get degree():uint { return __coef.degree; }
    
    public function set parameterize(_s:String):void
    {
      if( _s == Consts.ARC_LENGTH || _s == Consts.UNIFORM )
      {
        __param      = _s;
        __invalidate = true;
      }
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
    
/**
* @description 	Method: arcLength() - Return arc-length of the *entire* curve by numerical integration
*
* @return Number: Estimate of total arc length of the curve
*
* @since 1.0
*
*/
    public function arcLength():Number
    {
     if ( __arcLength != -1 )
       return __arcLength;
        
      if( __invalidate )
        __computeCoef();

      var len:Number = __integral.eval( __integrand, 0, 1, 5 );
      __arcLength    = len;
      
      return len;
    }
    
/**
* @description 	Method: arcLengthAt(_t:Number) - Return arc-length of curve segment on [0,_t].
*
* @param _t:Number - parameter value to describe partial curve whose arc-length is desired
*
* @return Number: Estimate of arc length of curve segment from t=0 to t=_t.
*
* @since 1.0
*
*/
    public function arcLengthAt(_t:Number):Number
    { 
      if( __invalidate )
        __computeCoef();

      var t:Number = (_t<0) ? 0 : _t;
      t            = (t>1) ? 1 : t;
     
      return __integral.eval( __integrand, 0, t, 8 );
    }
 
/**
* @description 	Method: getCoef(_i:uint) - Return the i-th coefficient of the parameteric curve (coefficients used to evaluate the curve in nested form)
*
* @return Object - no range-checking on the argument; you break it ... you buy it!
*
* @since 1.1
*
*/
    public function getCoef(_i:uint):Object
    {
      return __coef.getCoef(_i);
    }
    
    // parameterize curve
    protected function __parameterize():void
    {
      if( __param == Consts.ARC_LENGTH )
      {
        if( __spline.knotCount > 0 )
          __spline.deleteAllKnots();
          
        var arcLen:Array = new Array();
        var len:Number   = __integral.eval( __integrand, 0, 0.1, 8 );
        arcLen[0]        = len;
        
        len      += __integral.eval( __integrand, 0.1, 0.2, 8 );
        arcLen[1] = len;
        
        len      += __integral.eval( __integrand, 0.2, 0.3, 8 );
        arcLen[2] = len;
        
        len      += __integral.eval( __integrand, 0.3, 0.4, 8 );
        arcLen[3] = len;
        
        len      += __integral.eval( __integrand, 0.4, 0.5, 8 );
        arcLen[4] = len;
        
        len      += __integral.eval( __integrand, 0.5, 0.6, 8 );
        arcLen[5] = len;
        
        len      += __integral.eval( __integrand, 0.6, 0.7, 8 );
        arcLen[6] = len;
        
        len      += __integral.eval( __integrand, 0.7, 0.8, 8 );
        arcLen[7] = len;
        
        len      += __integral.eval( __integrand, 0.8, 0.9, 8 );
        arcLen[8] = len;
        
        len      += __integral.eval( __integrand, 0.9, 1.0, 8 );
        arcLen[9] = len;
        
        var normalize:Number = 1.0/len;

        // x-coordinate of spline knot is normalized arc-length, y-coordinate is t-value for uniform parameterization
        __spline.addControlPoint(0.0, 0.0);
        
        var l:Number = arcLen[0]*normalize;
        __spline.addControlPoint(l,0.1);
        
        l = arcLen[1]*normalize;
        __spline.addControlPoint(l,0.2);
        
        l = arcLen[2]*normalize;
        __spline.addControlPoint(l,0.3);
        
        l = arcLen[3]*normalize;
        __spline.addControlPoint(l,0.4);
        
        l = arcLen[4]*normalize;
        __spline.addControlPoint(l,0.5);
        
        l = arcLen[5]*normalize;
        __spline.addControlPoint(l,0.6);
        
        l = arcLen[6]*normalize;
        __spline.addControlPoint(l,0.7);
        
        l = arcLen[7]*normalize;
        __spline.addControlPoint(l,0.8);
        
         l = arcLen[8]*normalize;
        __spline.addControlPoint(l,0.9);

        // last control point, t=1, normalized arc-length = 1
        __spline.addControlPoint(1.0, 1.0);
      }
    }
    
    // assign the t-parameter for this evaluation
    protected function __setParam(_t:Number):void
    {
      var t:Number = (_t<0) ? 0 : _t;
      t            = (t>1)  ? 1 : t;

      // if arc-length parameterization, approximate L^-1(s)
      if( __param == Consts.ARC_LENGTH )
      {
        if( t != __s )
        {
          __t = __spline.eval(t);
          __s = t;
        }
      }
      else
      {
        if( t != __t )
          __t = t;
      }
    }

    override public function toString():String
    {
      return flash.utils.getQualifiedClassName(this);  
    }
    
    // Pseudo-abstract methods should be implemented in subclass
    
    public function getParam(_seg:uint):Number {throw new Error("Parametric::getParam() must be overriden");}
    
  	public function addControlPoint( _xCoord:Number, _yCoord:Number ):void {throw new Error("Parametric::addControlPoint() must be overriden")}
  	
  	public function moveControlPoint(_indx:uint, _newX:Number, _newY:Number):void {throw new Error("Parametric::moveControlPoint() must be overriden")}
  	
  	public function getControlPoint(_indx:uint):Point {throw new Error("Parametric::getControlPoint() must be overriden")}
  	
  	public function draw(_t:Number):void {throw new Error("Parametric::draw() must be overriden")}
  	
  	public function reColor(_c:Number):void {throw new Error("Parametric::reColor() must be overriden")}
  	
  	public function reDraw():void {throw new Error("Parametric::reDraw() must be overriden")}
  	
  	public function reset():void {throw new Error("Parametric::reset() must be overriden")}
  	
    public function getX(_t:Number):Number {throw new Error("Parametric::getX() must be overriden")}

    public function getY(_t:Number):Number {throw new Error("Parametric::getY() must be overriden")}
    
    public function getXPrime(_t:Number):Number {throw new Error("Parametric::getXPrime() must be overriden")}

    public function getYPrime(_t:Number):Number {throw new Error("Parametric::getYPrime() must be overriden")}
    
    public function interpolate(_points:Array):void {throw new Error("Parametric::interpolate() must be overriden")}
    
    public function __computeCoef():void { throw new Error("Parametric::__computeCoef() must be overriden") }
    
    public function tAtMinX():Number { throw new Error("Parametric::tAtMinX() not implemented in this Class") }
    
    public function tAtMinY():Number { throw new Error("Parametric::tAtMinY() not implemented in this Class") }
    
    public function tAtMaxX():Number { throw new Error("Parametric::tAtMaxX() not implemented in this Class") }
    
    public function tAtMaxY():Number { throw new Error("Parametric::tAtMaxY() not implemented in this Class") }
  }
}