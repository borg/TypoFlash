//
// Ellipse.as - Very simple parameteric ellipse with arc-length parameterization - useful for distributing sprites around an elliptical shape.
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
// Programmed by: Jim Armstrong, Singularity (www.algorithmist.net)
//
// Note:  Current implementation is for horizontally oriented ellipses - arbitrary orientation is left as an exercise
//

package Singularity.Geom
{
  import Singularity.Geom.Composite;
  
  import Singularity.Numeric.Consts;
  import Singularity.Numeric.Gauss;
  
  import flash.display.Graphics;
  
  public class Ellipse extends Composite
  {
    // core
    private var __xC:Number               // x-coordinate of center
    private var __yC:Number;              // y-coordinate of center
    private var __a:Number;               // semi-major axis length
    private var __b:Number;               // semi-minor axis length
    private var __t:Number;               // current t-value
    private var __s:Number;               // current arc-length

/**
* @description 	Method: Ellipse() - Construct a new (horizontally oriented) Ellipse
*
* @return Nothing
*
* @since 1.0
*
*/
    public function Ellipse()
    {
      super();
      
      __error.classname = "Ellipse";

      __xC = 0;
      __yC = 0;
      __a  = 0;
      __b  = 0;

      __param = Consts.POLAR;
      __t     = -1;
      __s     = -1;

      __integral = new Gauss();
    }
    
    public override function __integrand(_t:Number):Number
    {
      var x:Number = -__a*Math.sin(_t); 
      var y:Number = __b*Math.cos(_t);

      return Math.sqrt( x*x + y*y );
    };

    public function get xC():Number        { return __xC; }
    public function get yC():Number        { return __yC; }
    public function get semimajor():Number { return __a;  }
    public function get semiminor():Number { return __b;  }

    public function set xC(_n:Number):void      
    {
      if( !isNaN(_n) ) 
        __xC = _n; 
    }

    public function set yC(_n:Number):void      
    {
      if( !isNaN(_n) ) 
        __yC = _n; 
    }

    public function set semimajor(_n:Number):void
    {
      if( _n > __b )
        __a = _n;  
      else
      {
        __error.methodname = "semimajor()";
        __error.message    = "Semimajor axis length: " + _n + " must be greater than semiminor axis length: " + __b.toString();
        dispatchEvent(__error);
        return;
      }
    }

    public function set semiminor(_n:Number):void
    {
      if( _n < __a )
        __b = _n;  
      else
      {
        __error.methodname = "semiminor()";
        __error.message    = "Semiminor axis length: " + _n + " must be less than semimajor axis length: " + __a.toString();
        dispatchEvent(__error);
        return;
      }
    }

/**
* @description 	Method: getX( _t:Number ) - Return x-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1] for arc-length param. or [0,2pi] for polar param.
*
* @return Number: x-coordinate of ellipse
*
* @since 1.0
*
*/
    public override function getX(_t:Number):Number
    { 
      if( __invalidate )
        __parameterize();

      // assign the parameter for this evaluation
      __setParam(_t);

      return __xC + __a*Math.cos(__t); 
    }

    private function __setParam(_t:Number):void
    {
      // if arc-length parameterization, approximate L^-1(s)
      if( __param == Consts.ARC_LENGTH )
      {
        if( _t != __s )
        {
          var t:Number = Math.max(0,_t);
          t            = Math.min(1,t);
          __t          = __spline.eval(t);
          __s          = __t;
        }
      }
      else
      {
        __t = Math.max(0,_t);
        __t = Math.min(__t,Consts.TWO_PI);
      }
    }

/**
* @description 	Method: getY( _t:Number ) - Return y-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1] for arc-length param. or [0,2pi] for polar param.
*
* @return Number: y-coordinate of ellipse
*
* @since 1.0
*
*/
    public override function getY(_t:Number):Number
    {
      if( __invalidate )
        __parameterize();

      // assign the t-parameter for this evaluation
      __setParam(_t);
    
      return __yC + __b*Math.sin(__t);
    }
    
/**
* @description 	Method: draw(_t:Number) - Draw the complete ellipse
*
* @param _t:Number - reserved for possible future use
*
* @return Number:  Make sure to set the container reference before calling any draw methods!
*
* @since 1.0
*
*/
  public override function draw(_t:Number=1.0):void
  {
  	if( __container == null )
  	{
      __error.methodname = "draw()";
      __error.message    = "Set container reference before calling draw()";
      dispatchEvent(__error);
      return;
    }
    
    var g:Graphics = __container.graphics;
    g.lineStyle(__thickness, __color);
    g.drawEllipse(__xC-__a, __yC-__b, 2*__a, 2*__b);
  }

/**
* @description 	Method: arcLength() - Return arc-length of the entire ellipse by numerical integration
*
* @return Number:  Estimate of total arc length of ellipse
*
* @since 1.0
*
*/
    public override function arcLength():Number
    {
      return 4*__integral.eval( __integrand, 0, Consts.PI_2, 8 );
    }

/**
* @description 	Method: arcLengthAt(_t:Number) - Return arc-length of ellipse on [0,_t].
*
* @param _t:Number - parameter value to describe partial curve whose arc-legnth is desired
*
* @return Number:  Estimate of arc length of ellipse from t=0 to t=_t, _t <= 2PI
*
* @since 1.0
*
*/
    public override function arcLengthAt(_t:Number):Number
    {
  	  var t:Number = Math.max(0,_t);
  	  t            = Math.min(t,Consts.TWO_PI);
  	
  	  // there are other approximations for this specific arc length -- google the topic for more info.
      return __integral.eval( __integrand, 0, t, 8 );
    }

    private function __parameterize():void
    {
      if( __a == 0 || __b == 0 )
        return;

      if( __param == Consts.ARC_LENGTH )
      {
        var normalize:Number = 1.0/arcLength();

        if( __spline.knotCount > 0 )
          __spline.deleteAllKnots();

        __spline.addControlPoint(0.0, 0.0);
  
        // this is kind of overkill - relaxing the lookup is left as an exercise
        for( var theta:Number=Consts.PI_16; theta<Consts.TWO_PI; theta+=Consts.PI_16 )
        {
          var l:Number = arcLengthAt(theta)*normalize;
          __spline.addControlPoint(l,theta);
        }

        __spline.addControlPoint(1.0, Consts.TWO_PI);
      }

      __invalidate = false;
    }
  }
}