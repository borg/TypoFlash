//
// PSpline3.as - Generate parametric cubic splines, x(t) and y(t), t in [0,1], given a set of knots.  
//
// Reference:  http://www.algorithmist.net/spline.html
//
// copyright (c) 2005-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
//        This code is built around the Spline3 class for clarity.  Additional performance could
//        be gained by merging the Spline3 code and eliminating redundant computations.
//
// Programmed by: Jim Armstrong, Singularity (www.algorithmist.net)
//
// Note:  Set the container reference before calling any drawing methods
//

package Singularity.Geom
{ 
  import flash.display.Graphics;
  
  import Singularity.Geom.Composite;
  import Singularity.Geom.Spline3;
  
  public class PSpline3 extends Composite
  {
    private var __t:Array;                // parameter - values are in [0,1]
    private var __x:Array;                // x(t)
    private var __y:Array;                // y(t)
    private var __d:Array;                // euclidian distance between knots

    private var __totalDist:Number;       // total linear distance along set of knots
    private var __knots:Number;           // current knot count

    // Spline3 references
    private var __xSpline3:Spline3;       // cubic-spline representation of x(t)
    private var __ySpline3:Spline3;       // cubic-spline representation of y(t)

/**
* @description 	Method: PSpline3() - Construct a new PSpline3 instance
*
* @return Nothing
*
* @since 1.0
*
*/
  public function PSpline3()
  {
  	super();
  	
    __error.classname = "PSpline3()";

    __t = new Array();
    __x = new Array();
    __y = new Array();
    __d = new Array();

    __invalidate = true;
    __knots      = 0;

    __xSpline3 = new Spline3();
    __ySpline3 = new Spline3();
  }

  public function get knotCount():Number { return __knots; }
  
  public function get chordLength():Number
  {
    if( __invalidate )
      __computeKnots();

    return __totalDist;
  }

/**
* @description 	Method: addControlPoint( _xKnot:Number, _yKnot:Number ) - Add a knot (x-y pair)
*
* @param _xKnot:Number - x-coordinate of knot
* @param _yKnot:Number - y-coordinate of knot
*
* @return Nothing
*
* @since 1.0
*
*/
  public override function addControlPoint(_xKnot:Number, _yKnot:Number):void
  {
    __error.methodname = "addControlPoint()";

    if( isNaN(_xKnot) )
    {
      __error.message = "invalid x-coordinate at knot: " + (__knots+1);
      dispatchEvent(__error);
      return;
    }
    
    if( isNaN(_yKnot) )
    {
      __error.message = "invalid y-coordinate at knot: " + (__knots+1);
      dispatchEvent(__error);
      return;
    }

    __invalidate = true;

    __x.push(_xKnot);
    __y.push(_yKnot);
    __knots++;
  }

  // remove knot at index
  private function __remove(_indx:Number):void
  {
    for( var i:uint=_indx; i<__knots; ++i)
    { 
      __t[i] = __t[i+1];
      __x[i] = __x[i+1];
      __y[i] = __y[i+1];
      __d[i] = __d[i+1];
    }
    __t.pop();
    __x.pop();
    __y.pop();
    __d.pop();
    __knots--;
  }

/**
* @description 	Method: removeKnotAt( _indx:uint ) - Delete knot at the specified index
*
* @param _indx:uint - index of knot to delete
*
* @return Nothing
*
* @since 1.0
*
*/
  public function removeKnotAt(_indx:uint):void
  {
    __error.methodname = "removeKnotAt()";

    if( _indx < 0 || _indx >= __knots )
    {
      __error.message = "Index: " + _indx.toString() + " is out of range.";
      dispatchEvent(__error);
      return;
    };

    __remove(_indx);
    __invalidate = true;
  }


/**
* @description 	Method: reset() - Delete all knots from the collection and prepare for new knot input
*
*
* @return Nothing
*
* @since 1.0
*
*/
  public override function reset():void
  {
    __t.splice(0);
    __x.splice(0);
    __y.splice(0);
    __d.splice(0);
 
    __xSpline3.deleteAllKnots();
    __ySpline3.deleteAllKnots();

    __knots      = 0;
    __invalidate = true;
  }

/**
* @description 	Method: moveControlPoint( _i:uint, _xKnot:Number, _yKnot:Number ) - Move the knot at the specified index to a new location
* with new x and y.
*
* @param _i:uint       - Index of knot to replace
* @param _xKnot:Number - x-coordinate of replacement knot
* @param _yKnot:Number - y-coordinate of replacement knot
*
* @return Nothing - If index is valid, knot at that index is overwritten with new (x,y)
*
* @since 1.0
*
*/
  public override function moveControlPoint( _i:uint, _xKnot:Number, _yKnot:Number):void
  {
    __error.methodname = "moveControlPoint()";

    if( _i < 0 || _i > __knots-1 )
    {
      __error.message = "Invalid index: " + _i.toString();
      dispatchEvent(__error);
      return;
    }

    if( isNaN(_xKnot) || isNaN(_yKnot) )
    {
      __error.message = "Invalid coordinates";
      dispatchEvent(__error);
      return;
    };

    __x[_i] = _xKnot;
    __y[_i] = _yKnot;

    // this is faster than invalidate and recompute from scratch
    __updateKnots(_i);
    __invalidate = false;
  }

/**
* @description 	Method: getX( _t:Number ) - Return x-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: - NaN if there are no knots
*                 - x[0] if there is only one knot
*                 - Spline x-coordinate at the input parameter value, if there are two or more knots
*
* @since 1.0
*
*/
  public override function getX(_t:Number):Number
  {
    if( __knots == 0 )
      return NaN;
    else if( __knots == 1 )
      return __x[0];
    else
    {
      if( __invalidate )
        __computeKnots();

      return __xSpline3.eval(_t);
    }
  }

/**
* @description 	Method: getY( _t:Number ) - Return y-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: - NaN if there are no knots
*                 - y[0] if there is only one knot
*                 - Spline y-coordinate at the input parameter value, if there are two or more knots
*
* @since 1.0
*
*/
  public override function getY(_t:Number):Number
  {
    if( __knots == 0 )
      return NaN;
    else if( __knots == 1 )
      return __y[0];
    else
    {
      if( __invalidate )
        __computeKnots();

      return __ySpline3.eval(_t);
    }
  }
  
/**
* @description 	Method: draw(_t:Number) - Draw the parametric spline using a point-to-point method
*
* @param _t:Number - parameter value in [0,1] - defaults to entire spline
*
* @return Nothing - arc is drawn in designated container from t=0 to _t
*
* @since 1.0
*
* For performance reasons, error checking is at a minimum -- make sure container is set before calling any
* drawing methods!
*
*/
    public override function draw(_t:Number=1.0):void
    {
      if( _t == 0 )
        return;
        
      var p:Number = Math.max(1.0,_t);
      
      if( __invalidate )
        __computeKnots();
      
      var deltaT:Number = 2.0/(p*__totalDist);
      var g:Graphics = __container.graphics;
      g.clear();
      g.lineStyle(__thickness, __color);
      
      g.moveTo(__x[0],__y[0]);
      for( var t:Number=deltaT; t<=p; t+=deltaT )
        g.lineTo(getX(t), getY(t)); 
    }

    // compute parameter values based on current knots - pass (t,x) and (t,y) onto Spline3 classes
    private function __computeKnots():void
    {
      __totalDist = 0.0;
      __d[0]      = 0.0;
      __t[0]      = 0.0;
     for( var i:uint=1; i<__knots; ++i )
      { 
        var dX:Number = __x[i] - __x[i-1];
        var dY:Number = __y[i] - __y[i-1];
        __d[i]        = Math.sqrt( dX*dX + dY*dY );
        __totalDist  += __d[i];
      }

      __xSpline3.deleteAllKnots();
      __ySpline3.deleteAllKnots();

      __xSpline3.addControlPoint(0.0,__x[0]);
      __ySpline3.addControlPoint(0.0,__y[0]);

      var dist:Number = 0.0;
      for( i=1; i<__knots; ++i )
      {
        // dist measures cumulative (straight-line) distance along knots
        dist += __d[i];

        // normalize to [0,1] - chord-length parametrization;
        __t[i] = dist/__totalDist;
      
       // add knots
        __xSpline3.addControlPoint(__t[i], __x[i]);
        __ySpline3.addControlPoint(__t[i], __y[i]);
      }

      __invalidate = false;
    }

    // update parameter values based on changing only a single knot - pass (t,x) and (t,y) onto Spline3 classes
    private function __updateKnots(_i:uint):void
    {
      // first and last knots affect only one segment
      if( _i == 0 )
        __updateOne(1);
      else if( _i == __knots-1 )
        __updateOne(__knots-1);
      else
      {
        __updateOne(_i);
        __updateOne(_i+1);
      }

     // recompute __t
      __recomputeT();
   
      __xSpline3.moveControlPoint( _i, __t[_i], __x[_i] );
      __ySpline3.moveControlPoint( _i, __t[_i], __y[_i] );
    }

    private function __updateOne(_i:uint):void
    {
      __totalDist   -= __d[_i];
      var xD:Number  = __x[_i] - __x[_i-1];
      var yD:Number  = __y[_i] - __y[_i-1];
      __d[_i]        = Math.sqrt(xD*xD + yD*yD);
      __totalDist   += __d[_i];
    }

    private function __recomputeT():void
    {
      var dist:Number = 0.0;
      for( var i:uint=1; i<__knots; ++i )
      {
        dist  += __d[i];
        __t[i] = dist/__totalDist; 
      }
    }
  }
}