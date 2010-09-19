//
// Bezier2.as - Quadratic Bezier.
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
// Note:  Set the container reference before calling any drawing methods
//
// Version 1.1 - added y-at-x method
//

package Singularity.Geom
{
  import Singularity.Geom.Quad;
  import Singularity.Geom.Parametric;
  
  import Singularity.Numeric.Consts;
  
  import flash.display.Shape;
  import flash.display.Graphics;
  import flash.geom.ColorTransform;
  import flash.geom.Point;
  import flash.utils.getQualifiedClassName;
  
  public class Bezier2 extends Parametric
  {
  	// core
    private var __p0X:Number;             // x-coordinate, first control point
    private var __p0Y:Number;             // y-coordinate, first control point
    private var __p1X:Number;             // x-coordinate, second control point
    private var __p1Y:Number;             // y-coordinate, second control point
    private var __p2X:Number;             // x-coordinate, third control point
    private var __p2Y:Number;             // y-coordinate, third control point
    private var __autoParam:Number;       // parameter value from automatic chord-length parameterization during interpolation

    // Subdivision
    private var __cX:Number;              // left-cage control point, x-coordinate
    private var __cY:Number;              // left-cage control point, y-coordinate
    private var __pX:Number;              // subdivision anchor point, x-coordinate
    private var __pY:Number;              // subdivision anchor point, y-coordinate
    
/**
* @description 	Method: Bezier2() - Construct a new Bezier2 instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function Bezier2()
    {
      super();
      
      __p0X = 0;
      __p0Y = 0;
      __p1X = 0;
      __p1Y = 0;
      __p2X = 0;
      __p2Y = 0;

      __cX = 0;
      __cY = 0;
      __pX = 0;
      __pY = 0;
      
      __error.classname = "Bezier2";

      __coef      = new Quad();
      __container = null;
    }
    
    override public function toString():String
    {
      var myStr:String = flash.utils.getQualifiedClassName(this) + "::";
      myStr           += "(" + __p0X + "," + __p0Y + "), "; 
      myStr           += "(" + __p1X + "," + __p1Y + "), "; 
      myStr           += "(" + __p2X + "," + __p2Y + ")"; 
      
      return myStr;
    }
    
/**
* @description 	Method: getParam( _seg:uint ) - Add a control point
*
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
*
* @return uint - Adds control points in order called up to to three
*
* @since 1.0
*
*/
    public override function getParam(_seg:uint):Number { return __autoParam;}

/**
* @description 	Method: addControlPoint( _xCoord:Number, _yCoord:Number ) - Add a control point
*
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
*
* @return Nothing - Adds control points in order called up to to three
*
* @since 1.0
*
*/
    public override function addControlPoint( _xCoord:Number, _yCoord:Number ):void
    {
      if( __count == 3 )
      {
        __error.methodname = "addControlPoint()";
        __error.message    = "Point limit exceeded";
        dispatchEvent( __error );
        return;
      }

      switch( __count )
      {
        case 0 :
          __p0X = _xCoord;
          __p0Y = _yCoord;
          __count++;
        break;
      
        case 1 :
          __p1X = _xCoord;
          __p1Y = _yCoord;
          __count++;
        break;
        
        case 2 :
          __p2X = _xCoord;
          __p2Y = _yCoord;
          __count++;
        break;
      }
      __invalidate = true;
    } 
    
/**
  * @description 	getControlPointAsObject(_index:uint) - Return an <code>Object</code> containing the x- and y-coordinates of the specified control point
  *
  * @param _index:uint - index of the desired control point, 0, 1, or 2.  
  *
  * @return Object - 'X' property contains the x-coordinate of the control point, 'Y' property contains the y-coordinateof the control point.
  *
  * @since 1.0
  *
  * Note:  For performance reasons, no error checking is performed
  *
  */
    public function getControlPointAsObject( _index:uint ):Object
    {
      switch( _index )
      {
        case 0:
          return {X:__p0X, Y:__p0Y};
        break;
          
        case 1:
          return {X:__p1X, Y:__p1Y};
        break;
        
        case 2:
          return {X:__p2X, Y:__p2Y};
        break;  
      }
      
      return null;
    }
    
/**
* @description 	Method: getControlPoint(_indx:uint) - accesss the specified control point
*
* @param _indx:uint - Index of control point (0, 1, 2)
*
* @return Point reference to a <code>Point</code> representing the control vertex or (0,0) if the index is out of range for a quadratic curve
*
* @since 1.2
*
*/
    override public function getControlPoint(_indx:uint):Point
    {
      switch( _indx )
      {
        case 0:
          return new Point(__p0X, __p0Y);
        break;
        
        case 1:
          return new Point(__p1X, __p1Y);
        break;
        
        case 2:
          return new Point(__p2X, __p2Y);
        break;
      }	
      
      return new Point(0,0);
    }

/**
* @description 	Method: moveControlPoint(_indx:uint, _newX:Number, _newY:Number) - Move a control point
*
* @param _indx:Number - Index of control point (0, 1, or 2)
* @param _newX:Number - New x-coordinate
* @param _newY:Number - New y-coordinate
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function moveControlPoint(_indx:uint, _newX:Number, _newY:Number):void
    {
      __error.methodname = "moveControlPoint()";
    
      if( _indx < 0 || _indx > 2 )
      {
        __error.message = "Invalid index: " + _indx.toString();
        dispatchEvent(__error);
        return;
      }
 
      if( isNaN(_newX) )
      {
        __error.message = "Invalid x-coordinate.";
        dispatchEvent(__error);
        return;
      }

      if( isNaN(_newY) )
      {
        __error.message = "Invalid y-coordinate.";
        dispatchEvent(__error);
        return;
      }
  
      switch( _indx )
      {
        case 0 :
          __p0X = _newX; 
          __p0Y = _newY;
        break;
      
        case 1 :
          __p1X = _newX;
          __p1Y = _newY;
        break;
    
        case 2 :
          __p2X = _newX;
          __p2Y = _newY;
        break;
      }

      __invalidate = true;
    }
  
/**
* @description 	Method: reset() - Reset control points
*
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function reset():void
    {
      __p0X        = 0;
      __p0Y        = 0;
      __p1X        = 0;
      __p1Y        = 0;
      __p2X        = 0;
      __p2Y        = 0;
      __cX         = 0;
      __cY         = 0;
      __pX         = 0;
      __pY         = 0;
      __count      = 0;
      __autoParam  = 0;
      __arcLength  = -1;
      __invalidate = true;
      
      __coef.reset();
    }

/**
* @description 	Method: draw(_t:Number) - Draw the cubic Bezier using a quadratic approximation, based on subdivision
*
* @param _t:Number - parameter value in [0,1]
*
* @return Nothing - arc is drawn in designated container from t=0 to _t
*
* @since 1.0
*
* Note:  For performance reasons, no error checking is performed
*
*/
    public override function draw(_t:Number):void
    {
      if( _t == 0 )
        return;

      var g:Graphics = __container.graphics;
      g.lineStyle(__thickness, __color);

      if( _t >= 1 )
      {
        g.moveTo(__p0X, __p0Y);
        g.curveTo( __p1X, __p1Y, __p2X, __p2Y );
      }
      else if( _t <= 0 )
        g.clear();
      else
	  {
        __subdivide(_t);
	  
	    // plot only segment from 0 to _t
	    g.moveTo(__p0X, __p0Y);
        g.curveTo( __cX, __cY, __pX, __pY );
	  }
    }

/**
* @description 	Method: reColor(_c:Number) - Recolor the quad. curve
*
* @param _c:Number - Hex code for curve color
*
* @return Nothing
*
* @since 1.0
*
* Note:  For performance reasons, no error checking is performed
*
*/
    public override function reColor(_c:Number):void
    {
      var g:Graphics = __container.graphics;
      
      var colorXForm:ColorTransform = __container.transform.colorTransform;
      colorXForm.color = _c;
      __container.transform.colorTransform = colorXForm;
    }

/**
* @description 	Method: reDraw() - Redraw the curve with its base color
*
* @return Nothing
*
* @since 1.0
*
* Note:  For performance reasons, no error checking is performed
*
*/
    public override function reDraw():void
    {
      var g:Graphics = __container.graphics;
      
      var colorXForm:ColorTransform = __container.transform.colorTransform;
      colorXForm.color = __color;
      __container.transform.colorTransform = colorXForm;
    }

    private function __subdivide(_t:Number):void
    {
      var t1:Number = 1.0 - _t;

      __cX = _t*__p1X + t1*__p0X;
      __cY = _t*__p1Y + t1*__p0Y;

      var p21X:Number = _t*__p2X + t1*__p1X;
      var p21Y:Number = _t*__p2Y + t1*__p1Y;

      __pX = _t*p21X + t1*__cX;
      __pY = _t*p21Y + t1*__cY;
    }

/**
* @description 	Method: getX( _t:Number ) - Return x-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: Value of Quadratic Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
*
* @since 1.0
*
*/
    public override function getX(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;
    
      if( __invalidate )
        __computeCoef();
 
      __setParam(t);
      return __coef.getX(__t);
    }

/**
* @description 	Method: getY( _t:Number ) - Return y-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: Value of Quadratic Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
*
* @since 1.0
*
*/
    public override function getY(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();

      __setParam(t);
      return __coef.getY(__t);
    }

/**
* @description 	Method: interpolate( _points:Array ) - Compute control points so that quad. Bezier passes through three points
*
* @param _points:Array - array of three Objects with x- and y-coordinates in .X and .Y properties.  These points represent the coordinates of the interpolation points.
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function interpolate(_points:Array):void
    {
      // compute t-value using chord-length parameterization
      var dX:Number = _points[1].x - _points[0].x;
      var dY:Number = _points[1].y - _points[0].y;
      var d1:Number = Math.sqrt(dX*dX + dY*dY);
      var d:Number  = d1;

      dX = _points[2].x - _points[1].x;
      dY = _points[2].y - _points[1].y;
      d += Math.sqrt(dX*dX + dY*dY);

      var t:Number = d1/d;

      var t1:Number    = 1.0-t;
      var tSq:Number   = t*t;
      var denom:Number = 2.0*t*t1;

      __p0X = _points[0].x;
      __p0Y = _points[0].y;

      __p1X = (_points[1].x - t1*t1*_points[0].x - tSq*_points[2].x)/denom;
      __p1Y = (_points[1].y - t1*t1*_points[0].y - tSq*_points[2].y)/denom;

      __p2X = _points[2].x;
      __p2Y = _points[2].y;

      __invalidate = true;
      __autoParam  = t;
      __count      = 2;    // make sure count is properly set for coef. generation
    }

/**
* @description 	Method: tAtMinX() - Return the parameter value at which the x-coordinate is a minimum
*
* @return Nothing - Parameter value in [0,1] at which the curve's x-coordinate is a minimum
*
* @since 1.0
*
*/
    override public function tAtMinX():Number
    {
      var tStar:Number = (__p0X - __p1X) / (__p0X - 2*__p1X + __p2X);
      var t:Number     = 0;
      var minX:Number  = getX(0);
     
      if( getX(1) < minX )
      {
        t    = 1;
        minX = getX(1);  
      }
      
      if( tStar > 0 && tStar < 1 )
      {
        if( getX(tStar) < minX )
        {
          t = tStar;  
        }  
      }
      
      return t;
    }
    
/**
* @description 	Method: tAtMaxX() - Return the parameter value at which the x-coordinate is a maximum
*
* @return Nothing - Parameter value in [0,1] at which the curve's x-coordinate is a maximum
*
* @since 1.0
*
*/
    override public function tAtMaxX():Number
    {
      var tStar:Number = (__p0X - __p1X) / (__p0X - 2*__p1X + __p2X);
      var t:Number     = 0;
      var maxX:Number  = getX(0);
     
      if( getX(1) > maxX )
      {
        t    = 1;
        maxX = getX(1);  
      }
      
      if( tStar > 0 && tStar < 1 )
      {
        if( getX(tStar) > maxX )
        {
          t = tStar;  
        }  
      }
      
      return t;
    }
    
/**
* @description 	Method: tAtMinY() - Return the parameter value at which the y-coordinate is a minimum
*
* @return Nothing - Parameter value in [0,1] at which the curve's y-coordinate is a minimum
*
* @since 1.0
*
*/
    override public function tAtMinY():Number
    {
      var tStar:Number = (__p0Y - __p1Y) / (__p0Y - 2*__p1Y + __p2Y);
      var t:Number     = 0;
      var minY:Number  = getY(0);
     
      if( getY(1) < minY )
      {
        t    = 1;
        minY = getY(1);  
      }
      
      if( tStar > 0 && tStar < 1 )
      {
        if( getY(tStar) < minY )
        {
          t = tStar;  
        }  
      }
      
      return t;
    }
    
/**
* @description 	Method: tAtMaxY() - Return the parameter value at which the y-coordinate is a maximum
*
* @return Nothing - Parameter value in [0,1] at which the curve's y-coordinate is a maximum
*
* @since 1.0
*
*/
    override public function tAtMaxY():Number
    {
      var tStar:Number = (__p0Y - __p1Y) / (__p0Y - 2*__p1Y + __p2Y);
      var t:Number     = 0;
      var maxY:Number  = getY(0);
     
      if( getY(1) > maxY )
      {
        t    = 1;
        maxY = getY(1);  
      }
      
      if( tStar > 0 && tStar < 1 )
      {
        if( getY(tStar) > maxY )
        {
          t = tStar;  
        }  
      }
      
      return t;
    }
    
/**
* @description 	Method: yAtX( _x:Number ) - Return the set of y-coordinates corresponding to the input x-coordinate
*
* @param _x:Number x-coordinate at which the desired y-coordinates are desired
*
* @return Array set of (t,y)-coordinates at the input x-coordinate provided that the x-coordinate is inside the range
* covered by the quadratic Bezier in [0,1]; that is there must exist t in [0,1] such that Bx(t) = _x.  If the input
* x-coordinate is not inside the range covered by the Bezier curve, the returned array is empty.  Otherwise, the
* array contains either one or two y-coordinates.  There are issues with curves that are exactly or nearly (for
* numerical purposes) vertical in which there could theoretically be an infinite number of y-coordinates for a single
* x-coordinate.  This method does not work in such cases, although compensation might be added in the future.
*
* Each array element is a reference to an <code>Object</code> whose 't' parameter represents the Bezier t parameter.  The
* <code>Object</code> 'y' property is the corresponding y-value.  The returned (t,y) coordinates may be used by the caller
* to determine which of two returned y-coordinates might be preferred over the other.
*
* @since 1.1
*
*/
    public function yAtX(_x:Number):Array
    {
      if( isNaN(_x) )
      {
        return [];
      }
      
      // check bounds
      var xMax:Number = getX(tAtMaxX());
      var xMin:Number = getX(tAtMinX());
      
      if( _x < xMin || _x > xMax )
      {
        return [];
      }
      
      // the necessary y-coordinates are the intersection of the curve with the line x = _x.  The curve is generated in the
      // form c0 + c1*t + c2*t^2, so the intersection satisfies the equation Bx(t) = _x or Bx(t) - _x = 0, or c0x-_x + c1x*t + c2x*t^2 = 0,
      // which is quadratic in t.  I wonder what formula can be used to solve that ????
      if( __invalidate )
        __computeCoef();
        
      // this is written out in individual steps for clarity
      var c0:Object = __coef.getCoef(0);
      var c1:Object = __coef.getCoef(1);
      var c2:Object = __coef.getCoef(2);
      
      var c:Number = c0.X - _x;
      var b:Number = c1.X;
      var a:Number = c2.X;
      
      var d:Number = b*b - 4*a*c;
      if( d < 0 )
      {
        return [];
      }
      
      d             = Math.sqrt(d);
      a             = 1/(a + a);
      var t0:Number = (d-b)*a;
      var t1:Number = (-b-d)*a;
      
      var result:Array = new Array();
      if( t0 <= 1 )
        result.push({t:t0, y:getY(t0)});
        
      if( t1 >= 0 && t1 <=1 )
        result.push({t:t1, y:getY(t1)});
        
      return result;
    }
      
    public override function __computeCoef():void
    {
  	  if( __count < 2 )
  	  {
  	    __error.methodname = "__computeCoef()";
  	    __error.message    = "Insufficient number of control points";
  	    dispatchEvent(__error);
  	  }
  	  else
  	  {
  	  	__coef.reset();
        __coef.addCoef( __p0X, __p0Y );

        __coef.addCoef( 2.0*(__p1X-__p0X), 2.0*(__p1Y-__p0Y) );

        __coef.addCoef( __p0X-2.0*__p1X+__p2X, __p0Y-2.0*__p1Y+__p2Y );

        __invalidate = false;
        __arcLength  = -1;
        __parameterize();
      }
    }
  }
}