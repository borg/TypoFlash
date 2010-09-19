//
// Bone.as - Constants used in a variety of applications.
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
// Note:  For increased performance many public properties are used that might normally be
// private properties with getter/setter functions to check for argument validity.

package Singularity.Rigs
{
  import flash.display.Sprite;
  import flash.events.MouseEvent;
 
  import Singularity.Geom.BezierSpline;
  
  import Singularity.Numeric.Consts;
  
  import Singularity.Rigs.BaseBone;
  import Singularity.Rigs.Template;
  import flash.display.Shape;
  
  public class Bone extends BaseBone implements IBone
  {
  	// these variables control the drawing of the 'flare' points of a standard bone
  	public static const ALPHA:Number = 0.2;
  	public static const THETA:Number = Consts.PI_8;
  	
  	// bone type (for drawing)
  	public static const STANDARD:String = "ST";
  	public static const CUSTOM:String   = "CU";
  	 
  	// properties
  	public var INTERPOLATE:Boolean;    // true if using spline interpolation on custom drawing points, false to connect via straight lines
  	public var NEXT:IBone;             // next bone in chain
  	public var PREV:IBone;             // previous bone in chain
  	public var IS_ROOT:Boolean;        // true if this is the root bone of a chain
  	public var IS_END:Boolean;         // true if this is the terminal bone of a chain
  	public var IS_STRETCH:Boolean;     // true if bone allows stretch/squash
  	
  	// core
  	private var __x0:Number;           // x-coordinate of initial joint
  	private var __y0:Number;           // y-coordinate of initial joint
  	private var __x1:Number;           // x-coordinate of terminal joint
  	private var __y1:Number;           // y-coordinate of terminal joint
  	private var __xL:Number;           // x-coordinate, left flare point, standard bone
  	private var __yL:Number;           // y-coordinate, left flare point, standard bone
  	private var __xR:Number;           // x-coordinate, right flare point, standard bone
  	private var __yR:Number;           // y-coordinate, right flare point, standard bone
  	private var __deltaX:Number;       // current x-delta between initial and terminal points
  	private var __deltaY:Number;       // current y-delta between initial and terminal points
  	private var __flare:Number;        // length of flare points
  	private var __drawType:String;     // 'standard' or 'square' bone
  	private var __drawing:Boolean;     // true if draw is in progress
  	private var __angle:Number;        // angle bone makes with positive x-axis
  	private var __deltaAngle:Number;   // orientation delta angle
  	
  	// manage joint limits
  	private var __posAmount:Number;    // amount of positive (clockwise) rotation relative to parent
  	private var __negAmount:Number;    // amount of negative (ccw) rotation relative to parent
  	
  	// cubic bezier spline (only used for custom drawing of segmented limbs)
  	private var __spline:BezierSpline;
  	private var __splineShape:Shape;
  	
  	// references to custom handlers
  	private var __dummy:Function;
  	
    public function Bone():void
    {
      super();
      init();
      
      addEventListener(MouseEvent.ROLL_OVER, __onRollOver);
      addEventListener(MouseEvent.ROLL_OUT , __onRollOut );
      addEventListener(MouseEvent.CLICK    , __onSelected);
      
      __onInitial       = null
      __onFinal         = null;
      __rollOverHandler = null;
  	  __rollOutHandler  = null;
  	  __selectedHandler = null;
  	  
  	  __dummy = function():void{}
    }
    
    public function init():void
    {
      NAME            = "Bone";
  	  ID              = 0;
      NEXT            = null;
  	  PREV            = null;
  	  ENABLED         = false;
  	  RENDERABLE      = true;
  	  INTERPOLATE     = false;
  	  IS_ROOT         = false;
  	  IS_END          = false;
  	  IS_STRETCH      = false;
  	  LINE_THICKNESS  = 1;
   	  LINE_COLOR      = 0x666666;
  	  FILL_COLOR      = 0x999999;
  	  ROLL_OVER_COLOR = 0x6699cc;
  	  SELECTED_COLOR  = 0xff3333;
  	
  	  __x0         = 0;
  	  __y0         = 0;
  	  __x1         = 0;
  	  __y1         = 0;
  	  __xL         = 0;
  	  __yL         = 0;
  	  __xR         = 0;
  	  __yR         = 0;
  	  __length     = 0;
  	  __deltaX     = 0;
      __deltaY     = 0;
      __flare      = 0;
      __angle      = 0;
      __isSelected = false;
      __drawing    = false;
      __drawType   = STANDARD;
      __fk         = BaseBone.NONE;
      
      __spline      = null;
      __splineShape = null;
      
      graphics.clear();
    }
    
    public function get initX():Number     { return __x0;     }
    public function get initY():Number     { return __y0;     }
    public function get terminalX():Number { return __x1;     }
    public function get terminalY():Number { return __y1;     }
    public function get length():Number    { return __length; }
    
    public function get orientation():Number    { return (__angle>=0) ? __angle : Consts.TWO_PI+__angle; }
    public function get endOrientation():Number { return (__angle>=0) ? __angle : Consts.TWO_PI+__angle; }
    public function get angle():Number          { return __angle; }
    
    public function getFKType():String     { return __fk;         }
    public function getDeltaAngle():Number { return __deltaAngle; }
    
    // change the bone's orientation by rotating to a new angle either clockwise or counter-clockwise
    public function set orientation(_rad:Number):void
    { 
      // current orientation in [0,2pi] relative to positive x-axis
      var orient:Number = (__angle>=0) ? __angle : Consts.TWO_PI+__angle;
      
      // input orientation
      var myAngle:Number = (_rad >= 0) ? _rad  : Consts.TWO_PI+_rad;
      
      // compute delta angle
      var dA:Number = myAngle - orient;
      
      // changes in orientation should be very small - a big gap indicates moving from near 2PI across zero or vice versa.
      if( Math.abs(dA) > Math.PI )
        dA = (dA < 0 ) ? dA+Consts.TWO_PI : dA-Consts.TWO_PI;
      
      if( !__unconstrained )
      {
        // would this orientation cause a rotational limit to be exceeded?
        // if root bone, get parent orientation from __linkedTo - otherwise from PREV
        var parent:Object = (PREV != null) ? PREV : __linkedTo;
      
        // is there a parent orientation to check against?
        if( parent != null )
        {
      	  // upper and lower limits relative to parent orientation - lower limit is always a negative value 
      	  // 'end' orienation is either bone orientation, end-of-chain orientation, or connector orientation
      	  var p0:Number    = parent.endOrientation;
      	  var lower:Number = p0+lowerLimit;
          lower = (lower>0) ? lower : Consts.TWO_PI+lower;

          var upper:Number = p0+upperLimit;
          upper = (upper<=Consts.TWO_PI) ? upper : upper-Consts.TWO_PI;

      	  if( !__isInLimit(lower, upper, myAngle) )
      	    return;
        }
      }
      
      __fk         = BaseBone.FK_ROTATE;
      __angle      = myAngle;
      __deltaAngle = dA;
      var c:Number = Math.cos(__deltaAngle);
      var s:Number = Math.sin(__deltaAngle);
      
      // rotate (__deltaX,__deltaY) dA radians about the origin and then translate to (__x0,__y0) to compute new terminal point
      var newDX:Number = __deltaX*c - __deltaY*s;
      var newDY:Number = __deltaX*s + __deltaY*c;
      
      // changing orientation does not alter the bone's length
      __x1     = newDX+__x0;
      __y1     = newDY+__y0;
      __deltaX = newDX;
      __deltaY = newDY;
      
      // rotate the bone, then propagate forward
      this.rotation = __angle*Consts.RAD_TO_DEG;
      if( NEXT != null )
        NEXT.moveAndRotate(__x1, __y1, __deltaAngle, c, s);
      else
      {
      	// execute handler at completion of FK propagation
        if( __onFinal != null )
          __onFinal(this, __deltaAngle);
      }
    }
    
    // arguments are (absolute) lower limit, upper limit, and new child orientation
    private function __isInLimit( _lower:Number, _upper:Number, _child:Number ):Boolean
    {
      // compensate for periodicity in using absolute orientations - there are better ways, but this is conceptually simple
      if( _lower > _upper )
      {
        if( _child >= Math.PI && _child <= Consts.TWO_PI )
          return ( _child >= _lower && _child <= (Consts.TWO_PI+_upper) )
        else
          return ( (_child+Consts.TWO_PI) >= _lower && _child <= _upper )
      }
      else
        return ( _child >= _lower && _child <= _upper ) 
    }
    
    // set the drawing type to 'STANDARD' or 'CUSTOM' (setting draw type to CUSTOM requires a Template)
    public function set drawType(_s:String):void
    {
      if( _s == STANDARD ||_s == CUSTOM )
        __drawType = _s;	
    }
  	
/**
* @description 	Method: setInitial(_cX:Number, _cY:Number) - Set initial joint coordinates
*
* @param _cX:Number - x-coordinate of initial joint
* @param _cY:Number - y-coordinate of initial joint
*
* @return Nothing
*
* @since 1.0
*
*/
    public function setInitial(_cX:Number, _cY:Number):void
    {
      __x0 = _cX;
      __y0 = _cY;
      
      // distance is inlined for greater performance
      __deltaX = __x1-__x0;
      __deltaY = __y1-__y0;
      __length = Math.sqrt(__deltaX*__deltaX + __deltaY*__deltaY);	
      __flare  = ALPHA*__length;
    }
    
/**
* @description 	Method: setTerminal(_cX:Number, _cY:Number) - Set terminal joint coordinates
*
* @param _cX:Number - x-coordinate of terminal joint
* @param _cY:Number - y-coordinate of terminal joint
*
* @return Nothing
*
* @since 1.0
*
*/
    public function setTerminal(_cX:Number, _cY:Number):void
    {
      if( !__drawing )
      {
        __x1 = _cX;
        __y1 = _cY;
      
        // distance is inlined for greater performance
        __deltaX = __x1-__x0;
        __deltaY = __y1-__y0;
        __length = Math.sqrt(__deltaX*__deltaX + __deltaY*__deltaY);	
        __flare  = ALPHA*__length;
        __angle  = Math.atan2(__deltaY, __deltaX);
      }
    }
    
/**
* @description 	Method: moveInitial(_newX:Number, _newY:Number) - Move the initial joint to the new coordinates and offset terminal joint to maintain orientation
*
* @param _newX:Number - x-coordinate of terminal joint
* @param _newY:Number - y-coordinate of terminal joint
*
* @return Nothing
*
* @since 1.0
*
*/
    public function moveInitial(_newX:Number, _newY:Number):void
    {
      var dX:Number = _newX-__x0;
      var dY:Number = _newY-__y0;
      __fk          = BaseBone.FK_MOVE;
     
      // deltaX and deltaY are unchanged on move
      __x0  = _newX;
      __y0  = _newY;
      __x1 += dX;
      __y1 += dY;
      
      // re-position the bone, then propagate forward
      this.x = __x0;
      this.y = __y0;
      
      if( NEXT != null )
        NEXT.moveInitial(__x1,__y1);
      else
      {
      	// execute handler at completion of FK propagation
        if( __onFinal != null )
          __onFinal(this, 0);
      }
    }

/**
* @description 	Method: moveAndRotate(_newX:Number, _newY:Number, _deltaAngle:Number, _c:Number, _s:Number) - Move bone to new coordinates and rotate
*
* @param _newX:Number       - x-coordinate of terminal joint
* @param _newY:Number       - y-coordinate of terminal joint
* @param _deltaAngle:Number - delta Angle
* @param _c:Number          - cos(deltaAngle) previously computed in parent bone
* @param _s:Number          - sin(deltaAngle) previously computed in parent bone
* @return Nothing
*
* @since 1.0
*
*/
    public function moveAndRotate(_newX:Number, _newY:Number, _deltaAngle:Number, _c:Number, _s:Number):void
    { 
      // Neither translation or rotation change the bone's length. 
      __x0     = _newX;
      __y0     = _newY;
      __fk     = BaseBone.FK_ROTATE;
      __angle += _deltaAngle;
      
      var newDX:Number = __deltaX*_c - __deltaY*_s;
      var newDY:Number = __deltaX*_s + __deltaY*_c;
      
      __x1     = newDX+__x0;
      __y1     = newDY+__y0;
      __deltaX = newDX;
      __deltaY = newDY;
      
      // re-orient the bone, then propagate forward
      this.rotation += _deltaAngle*Consts.RAD_TO_DEG;
      this.x         = __x0;
      this.y         = __y0;
      
      if( NEXT != null )
        NEXT.moveAndRotate(__x1, __y1, _deltaAngle, _c, _s);
      else
      {
      	// execute handler at completion of FK propagation
        if( __onFinal != null )
          __onFinal(this, _deltaAngle);
      }
    }
    
/**
* @description 	Method: reorient(_newX:Number, _newY:Number, _angle:Number, _move:Boolean=true, _rotate:Boolean=true) - Place the bone in a new orientation without triggering FK
*
* @param _newX:Number    - optional new initial x-coordinate
* @param _newY:Number    - optional new initial y-coordinate
* @param _angle:Number   - new bone orientation in radians
* @param _move:Boolean   - true if the bone is both moved and rotated, false if rotation only
* @param _rotate:Boolean - true if bone sprite orientation is set, otherwise caller is responsible for redrawing the bone
*
* @since 1.0
*
*/
    public function reorient(_newX:Number, _newY:Number, _angle:Number, _move:Boolean=true, _rotate:Boolean=true):void
    {
      __angle = _angle;
      
      if( _move )
      {
        __x0   = _newX;
        __y0   = _newY;
        this.x = __x0;
        this.y = __y0;
      } 
      
      __x1 = __x0 + __length*Math.cos(__angle);
      __y1 = __y0 + __length*Math.sin(__angle);
      
      if( _rotate )
        this.rotation = __angle*Consts.RAD_TO_DEG;
    }
  
/**
* @description 	Method: destruct() - Deep-six this bone :)
*
* @since 1.0
*
*/    
    public function destruct():void
    { 
      init();
      
      removeEventListener(MouseEvent.ROLL_OVER, __onRollOver);
      removeEventListener(MouseEvent.ROLL_OUT , __onRollOut );
      removeEventListener(MouseEvent.CLICK    , __onSelected);
      
      // don't set these references to null as they may currently point to methods outside this instance.  References 
      // are currently set to a dummy function so that there are no extraneous references to methods outside this instance.
      __onInitial       = __dummy;
      __onFinal         = __dummy;
      __rollOverHandler = __dummy;
      __rollOutHandler  = __dummy;
      __selectedHandler = __dummy;
    }
    
    public function enableMouseEvents():void
    {
      ENABLED = true;
      addEventListener(MouseEvent.ROLL_OVER, __onRollOver);
      addEventListener(MouseEvent.ROLL_OUT , __onRollOut );
      addEventListener(MouseEvent.CLICK    , __onSelected);
    }
    
    public function disableMouseEvents():void
    {
      ENABLED = false;
      removeEventListener(MouseEvent.ROLL_OVER, __onRollOver);
      removeEventListener(MouseEvent.ROLL_OUT , __onRollOut );
      removeEventListener(MouseEvent.CLICK    , __onSelected);
    }
    
    public function draw():void
    {
      if( __drawing )
        return;
        
      if( RENDERABLE )
      {
        __drawing = true;
        graphics.clear();
        graphics.lineStyle(LINE_THICKNESS, LINE_COLOR);
        graphics.beginFill(FILL_COLOR,1);
      
        if( __drawType == STANDARD )
        {
          if( __splineShape != null )
            __splineShape.graphics.clear();
            
          __std();
        }
        else
          __drawCustom();
      }
    }
  
    public function select():void
    {
      // highlight only; no mouse interaction - do not fire selected handler
      __redraw(SELECTED_COLOR);
    }
    
    public function deselect():void
    {
      __redraw(FILL_COLOR);
      __isSelected = false;
    }
    
    private function __std():void
    {
      __angle = Math.atan2(__deltaY, __deltaX);
      
      // create the two 'flare' points to draw the bone
      var c:Number     = Math.cos(THETA);
      var s:Number     = Math.sin(THETA);
      __xL             = __flare*c;
      __yL             = -__flare*s;    
      __xR             = __flare*c;
      __yR             = __flare*s;

      graphics.moveTo(0,0);
      graphics.lineTo(__xL,__yL);
      graphics.lineTo(__length,0);
      graphics.lineTo(__xR,__yR);
      graphics.lineTo(0,0);
      
      graphics.endFill();
      
      this.x        = __x0;
      this.y        = __y0;
      this.rotation = __angle*Consts.RAD_TO_DEG;
      __drawing     = false;
    }
    
    private function __drawCustom():void
    {
      __angle = Math.atan2(__deltaY, __deltaX);
      
      if( INTERPOLATE )
      {
        // Spline creation and init. is just-in-time to avoid memory overhead if it is not needed
        if( __spline == null )
        {
          __spline = new BezierSpline();
          __spline.addControlPoint(__custom[0], __custom[1]);
          var j:uint = 2;
          for( var i:uint=1; i<__custPoints; i++ )
          {
            __spline.addControlPoint(__custom[j],__custom[j+1]);
            j += 2;
          }
          
          // duplicate the initial point to round out the control point set (make sure the spline is closed)
          __spline.addControlPoint(__custom[0], __custom[1]);
          
          // spline is drawn into a Shape - create one and add it to the Bone's display list
          // this will be made more compact in a future release
          __splineShape      = new Shape();
          __spline.container = __splineShape;
          
          addChild(__splineShape);
        }
        
        __spline.drawFilled(LINE_COLOR, FILL_COLOR);
      }
      else
      {
      	if( __splineShape != null )
          __splineShape.graphics.clear();
            
        graphics.moveTo(__custom[0], __custom[1]);
        j = 2;
        for( i=1; i<__custPoints; i++ )
        {
          graphics.lineTo(__custom[j],__custom[j+1]);
          j += 2;
        }
        graphics.endFill();
      }
      
      this.x        = __x0;
      this.y        = __y0;
      this.rotation = __angle*Consts.RAD_TO_DEG;
      __drawing     = false;
    }
  
    protected override function __redraw(_c:uint):void
    {
      if( RENDERABLE )
      {
        graphics.clear();
        graphics.lineStyle(LINE_THICKNESS, LINE_COLOR);
        graphics.beginFill(_c,1);
      
        if( __drawType == STANDARD )
          __redrawStd();
        else
          __redrawCustom();
      }
    }
    
    private function __redrawStd():void
    {
      graphics.moveTo(0,0);
      graphics.lineTo(__xL,__yL);
      graphics.lineTo(__length,0);
      graphics.lineTo(__xR,__yR);
      graphics.lineTo(0,0);
      graphics.endFill();
      
      graphics.endFill();
      
      this.x = __x0;
      this.y = __y0;	
    }
    
    private function __redrawCustom():void
    {
      graphics.moveTo(__custom[0], __custom[1]);
      var j:uint = 2;
      for( var i:uint=1; i<__custPoints; i++ )
      {
        graphics.lineTo(__custom[j],__custom[j+1]);
        j += 2;
      }
      graphics.endFill();
      
      this.x        = __x0;
      this.y        = __y0;
      this.rotation = __angle*Consts.RAD_TO_DEG;
    }
  }
}
