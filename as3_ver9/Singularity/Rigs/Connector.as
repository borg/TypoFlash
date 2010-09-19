//
// Connector.as - Single-bone chain with single initial joint and multiple terminal joints used to
// connect other chains.  Current implementation uses three terminator joints - 'LEFT', 'MIDDLE', and
// 'RIGHT'.  
//
// Noe: This is a pseudo-abstract base class from which rig-specific connectors such as a Pelvis
// are derived.  Noted methods should be overridden and implemented in the subclass.
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
// Note:  Interactivity is disabled by default so that mouse interaction does not interfere with a GUI
// driving chain generation.  After the chain is completed, enabled it to react to mouse events.

package Singularity.Rigs
{
  import flash.display.Sprite;
  import flash.display.Shape;
  
  import flash.events.MouseEvent;
      
  import Singularity.Numeric.Consts;
  
  import Singularity.Rigs.BaseBone;
  import Singularity.Rigs.IChain;
  import Singularity.Rigs.Template;
  
  public class Connector extends BaseBone implements IChain
  { 
  	// terminal points
  	public static const LEFT:String   = "L";
  	public static const MIDDLE:String = "M";
  	public static const RIGHT:String  = "R";
  	
  	// core
  	protected var __pivotX:Number;           // x-coordinate of pivot point
  	protected var __pivotY:Number;           // y-coordinate of pivot point
  	protected var __x0:Number;               // x-coordinate of connector origin
  	protected var __y0:Number;               // y-coordinate of connector origin
  	protected var __angle:Number;            // atan2 orientation angle
  	protected var __boundX:Number;           // x-coordinate of connector bounding-box
  	protected var __boundY:Number;           // y-coordinate of connector bounding-box
  	protected var __width:Number;            // width of bounding-box for the connnector
  	protected var __height:Number;           // height of bounding-box for the connector
    
    // terminal points or terminators
    protected var __leftX:Number;            // left-terminal point, x-coordinate
    protected var __leftY:Number;            // left-terminal point, y-coordinate
    protected var __midX:Number;             // middle-terminal point, x-coordinate
    protected var __midY:Number;             // middle-terminal point, y-coordinate
    protected var __rightX:Number;           // right-terminal point, x-coordinate
    protected var __rightY:Number;           // right-terminal point, y-coordinate
    protected var __leftOrientation:Number;  // orientation angle for left-terminator
    protected var __midOrientation:Number;   // orientation angle for mid-terminator
    protected var __rightOrientation:Number; // orientation angle for right-terminator

  	// effector pinning
  	protected var __leftPinned:Boolean;
  	protected var __midPinnned:Boolean;
  	protected var __rightPinned:Boolean;
  	
  	// connectors or chains linked forward to this one
  	protected var __linkLeft:IChain;
  	protected var __linkMiddle:IChain;
  	protected var __linkRight:IChain;
  	
  	// a connector is centered within a specified bounding box whose upper, whose left-hand corner is specified in the constructor 
    public function Connector(_x:Number, _y:Number, _w:Number, _h:Number):void
    {
      super();
      
      NAME            = "Connector";
  	  ID              = 0
  	  ENABLED         = false;
  	  RENDERABLE      = true;
  	  LINE_THICKNESS  = 1;
   	  LINE_COLOR      = 0x666666;
  	  FILL_COLOR      = 0x999999;
  	  ROLL_OVER_COLOR = 0x6699cc;
  	  SELECTED_COLOR  = 0xff3333;
  	
  	  __pivotX  = _x + 0.5*_w;
  	  __pivotY  = _y + 0.5*_h;
  	  __length  = _h;
  	  __angle   = -Consts.PI_2;
  	  __boundX  = _x;
  	  __boundY  = _y;
  	  __width   = _w;
  	  __height  = _h;
  	  
  	  __leftX         = 0;
      __leftY         = 0;
      __midX          = 0;
      __midY          = 0;
      __rightX        = 0;
      __rightY        = 0;
      __leftPinned    = false;
  	  __midPinnned    = false;
  	  __rightPinned   = false;
  	  __isSelected    = false;
  	  __linkLeft      = null;
  	  __linkMiddle    = null;
  	  __linkRight     = null;
  	  __mouseEvent    = BaseBone.BONE_NONE;
  	  
  	  __assignTerminators(_x, _y, _w, _h);
    }
    
    public function get boundX():Number           { return __boundX;           }
    public function get boundY():Number           { return __boundY;           }
    public function get boundW():Number           { return __width;            }
    public function get boundH():Number           { return __height;           }
    public function get originX():Number          { return __x0;               }
    public function get originY():Number          { return __y0;               }
    public function get pivotX():Number           { return __pivotX;           }
    public function get pivotY():Number           { return __pivotY;           }
    public function get leftX():Number            { return __leftX;            }
    public function get midX():Number             { return __midX;             }
    public function get rightX():Number           { return __rightX;           }
    public function get leftY():Number            { return __leftY;            }
    public function get midY():Number             { return __midY;             }
    public function get rightY():Number           { return __rightY;           }
    public function get leftOrientation():Number  { return __leftOrientation;  }
    public function get midOrientation():Number   { return __midOrientation;   }
    public function get rightOrientation():Number { return __rightOrientation; }
    
    public function get linkedTo():IChain       { return __linkedTo; }
    public function get orientation():Number    { return (__angle>=0) ? __angle : Consts.TWO_PI+__angle; }
    public function get endOrientation():Number { return (__angle>=0) ? __angle : Consts.TWO_PI+__angle; }
    
    // length is open to interpretation - currently distance between pivot and mid-terminator
    public function get length():Number
    {
      var dX:Number = __midX-__pivotX;
      var dY:Number = __midY-__pivotY;
      return Math.sqrt(dX*dX + dY*dY);
    }
        
    // link one chain to another to one of the terminators
    public function link(_c:IChain, _terminator:String, _orient:Boolean=true):void
    {
      // note - orient=true not yet debugged - it's not used in Biped
      if( _c != null )
      { 
      	_c.linkedTo = this;
      	
        switch( _terminator )
        {
          case LEFT: 
            if( _orient )
              _c.moveAndRotate( __leftX, __leftY, __leftOrientation-_c.orientation );
            else
              _c.move(__leftX, __leftY);
              
            __linkLeft = _c;
          break;
          
          case MIDDLE :
            if( _orient )
              _c.moveAndRotate( __midX, __midY, __midOrientation-_c.orientation );
            else
              _c.move(__midX, __midY);
              
            __linkMiddle = _c;
          break;
          
          case RIGHT :
            if( _orient )
              _c.moveAndRotate( __rightX, __rightY, __rightOrientation-_c.orientation );
            else
              _c.move(__rightX, __rightY);
              
            __linkRight = _c;
          break;
        }
      }
    }
    
    // unlink all forward chains
    public function unlink():void
    {
      __linkLeft   = null;
  	  __linkMiddle = null;
  	  __linkRight  = null;
    }

/**
* @description 	Method: select() - select or highlight the connector - no handlers are fired
*
* @return Nothing
*
* @since 1.0
*
*/
    public function select():void
    {
      __isSelected = true;
      __redraw(SELECTED_COLOR);
    }
    
/**
* @description 	Method: deselect() - deselect the connector
*
* @return Nothing
*
* @since 1.0
*
*/
    public function deselect():void
    {
      __isSelected = false;
      __redraw(FILL_COLOR);
    }
    
    // change the connector's orientation by the input delta angle (radians in the range [0,2pi]
    public function offsetOrientation(_deltaAngle:Number):void
    { 
      // test to see if new angle would violate a joint limit
      if( !__unconstrained )
      {
        var orient:Number = __angle+_deltaAngle;
        orient            = (orient>=0) ? orient : Consts.TWO_PI+orient;
      
        // is there a parent orientation to check against?
        if( __linkedTo != null )
        {
      	  // upper and lower limits relative to parent orientation - lower limit is always a negative value 
      	  var p0:Number    = __linkedTo.endOrientation;
      	  var lower:Number = p0+lowerLimit;
          lower = (lower>0) ? lower : Consts.TWO_PI+lower;

          var upper:Number = p0+upperLimit;
          upper = (upper<=Consts.TWO_PI) ? upper : upper-Consts.TWO_PI;
      	
      	  if( !__isInLimit(lower, upper, orient) )
      	    return;
        }
      }
      
      __fk = BaseBone.FK_ROTATE;
      
      var c:Number = Math.cos(_deltaAngle);
      var s:Number = Math.sin(_deltaAngle);
      
      var originXDelta:Number = __x0 - __pivotX;
      var originYDelta:Number = __y0 - __pivotY;
      
      __x0 = originXDelta*c - originYDelta*s + __pivotX;
      __y0 = originXDelta*s + originYDelta*c + __pivotY;
      
      var leftXDelta:Number = __leftX - __pivotX;
      var leftYDelta:Number = __leftY - __pivotY;
      
      __leftX = leftXDelta*c - leftYDelta*s + __pivotX;
      __leftY = leftXDelta*s + leftYDelta*c + __pivotY;

      var midXDelta:Number = __midX - __pivotX;
      var midYDelta:Number = __midY - __pivotY;
      
      __midX = midXDelta*c - midYDelta*s + __pivotX;
      __midY = midXDelta*s + midYDelta*c + __pivotY;
      
      var rightXDelta:Number = __rightX - __pivotX;
      var rightYDelta:Number = __rightY - __pivotY;
      
      __rightX = rightXDelta*c - rightYDelta*s + __pivotX;
      __rightY = rightXDelta*s + rightYDelta*c + __pivotY;
      
      // rotate the connector about the pivot (which also means a translation if the origin and pivot do not coincide), then propagate forward
      __angle      += _deltaAngle;
      __angle       = (__angle>Consts.TWO_PI) ? __angle-Consts.TWO_PI : __angle;
      __angle       = (__angle<-Consts.TWO_PI) ? __angle+Consts.TWO_PI : __angle;
      
      this.x        = __x0;
      this.y        = __y0;
      this.rotation = __angle*Consts.RAD_TO_DEG;
      
      if( __linkLeft != null )
        __linkLeft.moveAndRotate(__leftX, __leftY, _deltaAngle);
     
      if( __linkMiddle != null )
        __linkMiddle.moveAndRotate(__midX, __midY, _deltaAngle);
        
      if( __linkRight != null )
        __linkRight.moveAndRotate(__rightX, __rightY, _deltaAngle);
    }
    
    // arguments are (absolute) lower limit, upper limit, and target child orientation
    // this code is currently duplicated in Bone class, so it could have been put in BaseBone.
    // reason for the duplication is that they may be implemented slightly differently in the
    // future.
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
    
/**
* @description 	Method: move(_newX:Number, _newY:Number) - move the connector
*
* @param _newX:Number - new x-coordinate
* @param _newY:Number - new y-coordiante
*
* @return Nothing - connector pivot is moved and this motion is propagated to remaining bones linked to terminators
*
* @since 1.0
*
*/
    public function move( _newX:Number, _newY:Number ):void
    {
      var dX:Number = _newX - __pivotX;
      var dY:Number = _newY - __pivotY;
 
      __x0     += dX;
      __y0     += dY;
      __leftX  += dX;
      __leftY  += dY;
      __midX   += dX;
      __midY   += dY;
      __rightX += dX;
      __rightY += dY;

      __pivotX = _newX;
      __pivotY = _newY;
      
      this.x = __x0;
      this.y = __y0;
      
      if( __linkLeft != null )
        __linkLeft.move(__leftX, __leftY);
        
      if( __linkMiddle != null )
        __linkMiddle.move(__midX, __midY);
      
      if( __linkRight != null )
        __linkRight.move(__rightX, __rightY);
    }
    
/**
* @description 	Method: moveAndRotate(_newX:Number, _newY:Number, _deltaAngle:Number) - move the connector and rotate by the input delta angle
*
* @param _newX:Number       - new x-coordinate
* @param _newY:Number       - new y-coordinate
* @param _deltaAngle:Number - delta angle
* 
* @return Nothing - 
*
* @since 1.0
*
*/
    public function moveAndRotate( _newX:Number, _newY:Number, _deltaAngle:Number ):void
    {
      __fk          = BaseBone.FK_ROTATE;
      var dX:Number = _newX - __pivotX;
      var dY:Number = _newY - __pivotY;
 
      __x0     += dX;
      __y0     += dY;     
      __leftX  += dX;
      __leftY  += dY;
      __midX   += dX;
      __midY   += dY;
      __rightX += dX;
      __rightY += dY;

      __pivotX = _newX;
      __pivotY = _newY;
      
      this.x = __x0;
      this.y = __y0;

      var c:Number = Math.cos(_deltaAngle);
      var s:Number = Math.sin(_deltaAngle);
      
      var leftXDelta:Number = __leftX - __pivotX;
      var leftYDelta:Number = __leftY - __pivotY;
      
      __leftX = leftXDelta*c - leftYDelta*s + __pivotX;
      __leftY = leftXDelta*s + leftYDelta*c + __pivotY;

      var midXDelta:Number = __midX - __pivotX;
      var midYDelta:Number = __midY - __pivotY;
      
      __midX = midXDelta*c - midYDelta*s + __pivotX;
      __midY = midXDelta*s + midYDelta*c + __pivotY;
      
      var rightXDelta:Number = __rightX - __pivotX;
      var rightYDelta:Number = __rightY - __pivotY;
      
      __rightX = rightXDelta*c - rightYDelta*s + __pivotX;
      __rightY = rightXDelta*s + rightYDelta*c + __pivotY;
      
      // rotate the connector about the pivot (which also means a translation if the origin and pivot do not coincide), then propagate forward
      __angle += _deltaAngle;
      __angle  = (__angle>Consts.TWO_PI) ? __angle-Consts.TWO_PI : __angle;
      __angle  = (__angle<-Consts.TWO_PI) ? __angle+Consts.TWO_PI : __angle;
      
      this.rotation = __angle*Consts.RAD_TO_DEG;
   
      if( __linkLeft != null )
        __linkLeft.moveAndRotate(__leftX, __leftY, _deltaAngle);
     
      if( __linkMiddle != null )
        __linkMiddle.moveAndRotate(__midX, __midY, _deltaAngle);
        
      if( __linkRight != null )
        __linkRight.moveAndRotate(__rightX, __rightY, _deltaAngle);
    }
    
/**
* @description 	Method: destruct() - destruct all bones in the chain, allowing the class instance to be marked for garbage collection
*
* @return Nothing - DO NOT call methods on this instance after calling destruct()
*
* @since 1.0
*
*/
    public function destruct():void
    { 
      removeEventListener(MouseEvent.ROLL_OVER, __onRollOver);
  	  removeEventListener(MouseEvent.ROLL_OUT , __onRollOut );
  	  removeEventListener(MouseEvent.CLICK    , __onSelected);
    }
    
/**
* @description 	Method: draw() - draw the connector
*
* @return Nothing - The standard draw method uses Bone Templates, i.e. setTemplate(), then draw().
*
* @since 1.0
*
*/
    public function draw():void
    {
      if( RENDERABLE )
      {
        graphics.clear();
        graphics.lineStyle(LINE_THICKNESS, LINE_COLOR);
        graphics.beginFill(FILL_COLOR,1);
      
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
    
    protected override function __redraw(_c:uint):void
    {
      graphics.clear();
      graphics.lineStyle(LINE_THICKNESS, LINE_COLOR);
      graphics.beginFill(_c,1);
        
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
    
    // assign terminator coodinates
    protected function __assignTerminators(_x:Number, _y:Number, _w:Number, _h:Number):void
    {
      throw new Error("Connector::__assignTerminators() must be overriden");
    }

    // handle end-of-fk propagation event -- get the type of FK motion and pass it onto all linked chains 
    private function __onFKEnd(_b:Bone):void
    {
      switch( _b.getFKType() )
      {
        case BaseBone.FK_MOVE :
          if( __linkLeft != null )
            __linkLeft.move(__leftX, __leftY);
            
          // middle terminator not currently used
          if( __linkRight != null )
            __linkLeft.move(__leftX, __leftY);
        break;
      	  
        case BaseBone.FK_ROTATE:
          if( __linkLeft != null )
          {
      	    var dA:Number = __leftOrientation-__linkLeft.orientation;
      	    __linkLeft.moveAndRotate(__leftX, __leftY, dA);
      	  }
      	    
      	  if( __linkRight != null )
      	  {
      	    dA = __rightOrientation-__linkRight.orientation;
      	    __linkRight.moveAndRotate(__rightX, __rightY, dA);
      	  }
      	break;	
      }
    }
  }
}
