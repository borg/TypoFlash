//
// BaseBone.as - Contains low-level properties and methods common to standard Bones and Connectors
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

package Singularity.Rigs
{
  import flash.display.Sprite;
  
  import flash.events.MouseEvent;
      
  import Singularity.Numeric.Consts;
  import Singularity.Rigs.IChain;
  import Singularity.Rigs.Template;
  
  public class BaseBone extends Sprite
  { 
  	// custom low-level event types
  	public static const BONE_NONE:String      = "NONE";
  	public static const BONE_ROLL_OVER:String = "ROVR";
  	public static const BONE_ROLL_OUT:String  = "ROUT";
  	public static const BONE_SELECTED:String  = "BSEL";
  	public static const ON_INITIAL:String     = "OI";
  	public static const ON_FINAL:String       = "OF";
  	
  	// type of FK motion
  	public static const NONE:String      = "N";
  	public static const FK_MOVE:String   = "M";
  	public static const FK_ROTATE:String = "R";
  	
  	// properties
  	public var NAME:String;                  // name associated with this bone or connector
  	public var ID:uint;                      // numeric ID associated with this bone or connector
  	public var ENABLED:Boolean;              // true if the connector is enabled
  	public var RENDERABLE:Boolean;           // true if the connector is renderable
  	public var LINE_THICKNESS:uint;          // line thickness for drawing
  	public var LINE_COLOR:uint;              // line color
  	public var FILL_COLOR:uint;              // fill color
  	public var ROLL_OVER_COLOR:uint;         // mouse over fill color
  	public var SELECTED_COLOR:uint;          // selected fill color
  	
  	// core
  	protected var __length:Number;           // length of bone or connector;
  	protected var __isSelected:Boolean;      // true if bone or connector is selected
  	protected var __mouseEvent:String;       // type of mouse event
  	protected var __fk:String;               // type of FK currently applied
  	
  	// drawing
  	protected var __custom:Array;            // array of custom points [ (x0,y0), (x1,y1) ... ]
  	protected var __custPoints:uint;         // number of custom drawing points
  	
  	// joint limits
  	protected var __lowerLimit:Number;
  	protected var __upperLimit:Number;
  	protected var __linkedTo:IChain;
  	protected var __unconstrained:Boolean;
    
  	// references to custom handlers
  	protected var __onInitial:Function;
  	protected var __onFinal:Function;
  	protected var __rollOverHandler:Function;
  	protected var __rollOutHandler:Function;
  	protected var __selectedHandler:Function;
  	
    public function BaseBone():void
    {
      super();
  	 
  	  __length          = 0;
  	  __mouseEvent      = BONE_NONE;
  	  __isSelected      = false;
  	  __unconstrained   = true;
  	  __onInitial       = null;
  	  __onFinal         = null;
  	  __rollOverHandler = null;
  	  __rollOutHandler  = null;
  	  __selectedHandler = null;
  	  
  	  __lowerLimit = -Consts.TWO_PI;
  	  __upperLimit = Consts.TWO_PI;
  	  __linkedTo   = null;
  	  
  	  __custom     = null; // this reference must be obtained from a Template
  	  __custPoints = 0; 
  	  __fk         = BaseBone.NONE;
  	  
  	  addEventListener(MouseEvent.ROLL_OVER, __onRollOver);
  	  addEventListener(MouseEvent.ROLL_OUT , __onRollOut );
  	  addEventListener(MouseEvent.CLICK    , __onSelected);
    }

    public function get mouseEvent():String { return __mouseEvent; }
    public function get lowerLimit():Number { return __lowerLimit; }
    public function get upperLimit():Number { return __upperLimit; }
    
    public function set lowerLimit(_r:Number):void 
    { 
      __lowerLimit = _r; 
      __unconstrained = (__lowerLimit == -Consts.TWO_PI) && (__upperLimit == Consts.TWO_PI);  
    }
    
    public function set upperLimit(_r:Number):void 
    { 
      __upperLimit = _r; 
      __unconstrained = (__lowerLimit == -Consts.TWO_PI) && (__upperLimit == Consts.TWO_PI); 
    }
    
    public function set linkedTo(_c:IChain):void { __linkedTo = _c; }
    
/**
* @description 	Method: setTemplate(_t:Template, _reset:Boolean=false, _useYScale:Boolean=false, _scaleTo:Number) - Use a symmetric drawing Template to define bone shape
*
* @param _t:Template        - Template reference
* @param _reset:Boolean     - true if resetting the template
* @param _useYScale:Boolean - true if y-coords in symmetric part of Template are nonlinearly scaled
* @param _scaleTo:Number    - target for y-scale
*
* @return Nothing - this method uses symmetry to map the Template to the current bone orientation 
*
* Note:  Bone must have defined length before setting Template, otherwise it's normalized to zero length
*
* @since 1.0
*
*/
    public function setTemplate(_t:Template, _reset:Boolean=false, _useYScale:Boolean=false, _scaleTo:Number=0):void
    {
      if( _reset )
        __custom.splice(0);
      
      // reflect template points about the positive x-axis to complete the point set
      __custom       = _t.getPoints();
      var count:uint = _t.count;
      var s:Number   = _useYScale ? _scaleTo/_t.max : 1;
        
      var j:uint    = 0;
      var base:uint = 2*count;
      for( var i:uint=count-2; i>0; i-- )
      {
      	// x-coordinate
        __custom[2*count+j] = __custom[2*i];
        
        // y-coordinate
        if( _useYScale )
          __custom[2*i+1] *= s;
        
        __custom[2*count+j+1] = -__custom[2*i+1];
        
        j += 2;
      }
        
      // scale all points to match bone length
      __custPoints = 2*(count-1);
      s            = __length/100;
      
      j = 0;
      for( i=0; i<__custPoints; i++ )
      {
        __custom[j]   *= s;
        
        if( !_useYScale )
          __custom[j+1] *= s;
          
        j += 2;
      }
    }
    
/**
* @description 	Method: register(_e:String, _f:Function) - Low-level event registration
*
* @param _cX:Number - x-coordinate of terminal joint
* @param _cY:Number - y-coordinate of terminal joint
*
* @return Nothing
*
* @since 1.0
*
*/
    public function register(_e:String, _f:Function):void
    {
      switch(_e)
      {
      	case ON_INITIAL :
      	   __onInitial = _f;
      	break;
      	
      	case ON_FINAL :
  	      __onFinal = _f;
      	break;
      	
      	case BONE_ROLL_OVER :
      	   __rollOverHandler = _f;
      	break;
      	
      	case BONE_ROLL_OUT :
  	      __rollOutHandler  = _f;
      	break;
      	
      	case BONE_SELECTED :
  	      __selectedHandler = _f;
      	break;
      }	
    }
    
    // mouse rollOver event
    protected function __onRollOver(_e:MouseEvent):void
    {
      if( ENABLED && RENDERABLE && !__isSelected )
      {
      	__mouseEvent = BONE_ROLL_OVER;
        __redraw(ROLL_OVER_COLOR);
      
        if( __rollOverHandler != null )
          __rollOverHandler(this);
      }
    }
    
    // mouse rollOut event
    protected function __onRollOut(_e:MouseEvent):void
    {
      if( ENABLED && RENDERABLE && !__isSelected )
      {
        __mouseEvent = BONE_ROLL_OUT;
        __redraw(FILL_COLOR);
      
        if( __rollOutHandler != null )
          __rollOutHandler(this);
      }
    }
    
    // selected event (mouse click)
    protected function __onSelected(_e:MouseEvent):void
    {   
      if( ENABLED && RENDERABLE )
      {
      	__mouseEvent = BONE_SELECTED;
        __isSelected = true;
      
        __redraw(SELECTED_COLOR);
      
        if( __selectedHandler != null )
          __selectedHandler(this);
      }
    }
    
    // This method *must* be implemented in the subclass
    protected function __redraw(_c:uint):void
    {
      throw new Error("BaseBone::__redraw() must be overriden");
    }
  }
}
