//
// Chain.as - Manager for a linked chain of Bones.  A chain also serves as a display container for all bones, allowing
// them to be layered and visually mangaged as a group.
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
// Note:  Chain interactivity is disabled by default so that mouse interaction does not interfere with a GUI
// driving chain generation.  After the chain is completed, enabled it to react to mouse events.

package Singularity.Rigs
{
  import flash.display.Sprite;
  import flash.display.Shape;
    
  import Singularity.Numeric.Consts;
  
  import Singularity.Rigs.BaseBone;
  import Singularity.Rigs.IChain;
  import Singularity.Rigs.Template;
  
  public class Chain extends Sprite implements IChain
  { 
  	// properties
  	public var NAME:String;              // name associated with this chain
  	public var ID:uint;                  // numeric ID associated with this chain
  	
  	// core
  	protected var __bones:Array;         // collection of bones
  	protected var __count:uint;          // current bone count
  	protected var __current:Bone         // reference to currently active bone based on mouse action
  	protected var __previous:Bone;       // reference to previously selected bone
    protected var __selected:Bone        // reference to currently selected bone
    protected var __rootBone:Bone;       // permanent reference to root bone in the chain
    protected var __terminalBone:Bone;   // permanent reference to the termainal bone in the chain
    protected var __mouseEvent:String;   // type of bone mouse event
    protected var __notify:Function;     // notification function to execute on low-level bone interaction
    protected var __linkedTo:IChain;     // chain or connector that this chain is linked to
  	
  	// drawing properties (apply to all bones in the chain)
    protected var __lineThickness:uint;  // line thickness for drawing
  	protected var __lineColor:uint;      // line color
  	protected var __fillColor:uint;      // fill color
  	protected var __rollOverColor:uint;  // mouse over fill color
  	protected var __selectedColor:uint;  // selected fill color

  	// end effector
  	protected var __isPinned:Boolean;    // true if end-effector is pinned
  	
  	// chains linked forward to this one
  	protected var __forward:Array;
  	
    public function Chain():void
    {
      __init();
    }
    
    private function __init():void
    {
      NAME = "Chain";
  	  ID   = 0
  	
  	  __bones         = new Array();
  	  __forward       = new Array();
  	  __current       = null;
      __selected      = null;
      __notify        = null;
      __rootBone      = null;
      __terminalBone  = null;
      __linkedTo      = null;
  	  __lineThickness = 1;
   	  __lineColor     = 0x666666;
  	  __fillColor     = 0x999999;
  	  __rollOverColor = 0x6699cc;
  	  __selectedColor = 0xff3333;
  	  __mouseEvent    = BaseBone.BONE_NONE;

  	  __count    = 0;

  	  __isPinned = false;
    }
    
    public function get mouseEvent():String     { return __mouseEvent;               }
    public function get current():Bone          { return __current;                  }
    public function get selected():Bone         { return __selected;                 }
    public function get endX():Number           { return __terminalBone.terminalX;   }
    public function get endY():Number           { return __terminalBone.terminalY;   }
    public function get initOrientation():Number{ return __rootBone.orientation;     }
    public function get endOrientation():Number { return __terminalBone.orientation; }
    public function get linkedTo():IChain       { return __linkedTo;                 }
    public function get orientation():Number    { return __rootBone.orientation;     }
    
    public function getBone(_i:uint):Bone { return __bones[_i] }
    
    public function set linkedTo(_c:IChain):void
    {
      __linkedTo = _c;
      // __rootBone.linkedTo = _c;	
    }
    
    // following setters affect all bones in the chain
    public function set enabled(_b:Boolean):void
    {
      for( var i:uint=0; i<__count; ++i )
      {
        var b:Bone = __bones[i];
        if( _b )
          b.enableMouseEvents();
        else
          b.disableMouseEvents();
      }
    }
    
    public function set renderable(_b:Boolean):void
    {
      for( var i:uint=0; i<__count; ++i )
        __bones[i].RENDERABLE = _b;
    }
    
    public function set drawType(_s:String):void
    {
      for( var i:uint=0; i<__count; ++i )
        __bones[i].drawType = _s;
    }
    
    public function set lineThickness(_n:uint):void
    {
      __lineThickness = _n;
      for( var i:uint=0; i<__count; ++i )
        __bones[i].LINE_THICKNESS = _n;
    }
    
    public function set lineColor(_n:uint):void
    {
      __lineColor = _n;
      for( var i:uint=0; i<__count; ++i )
        __bones[i].LINE_COLOR = _n;
    }
    
    public function set fillColor(_n:uint):void
    {
      __fillColor = _n;
      for( var i:uint=0; i<__count; ++i )
        __bones[i].FILL_COLOR = _n;
    }
    
    public function set rollOverColor(_n:uint):void
    {
      __rollOverColor = _n;
      for( var i:uint=0; i<__count; ++i )
        __bones[i].ROLL_OVER_COLOR = _n;
    }
    
    public function set selectedColor(_n:uint):void
    {
      __selectedColor = _n;
      for( var i:uint=0; i<__count; ++i )
        __bones[i].SELECTED_COLOR = _n;
    }
    
    public function set splineInterpolation(_b:Boolean):void
    {
      for( var i:uint=0; i<__count; ++i )
        __bones[i].INTERPOLATE = _b;
    }
    
    // link one chain to another chain (or Connector) to propagate FK motion
    public function link(_c:IChain, _orient:Boolean=true):void
    {
      // Note that any item linked forward must implement the IChain Interface
      if( _c != null )
      {
        __forward.push(_c);
        _c.linkedTo = this;
        
        // snap chain to end-effector location with optional matching of orientation
        var endX:Number = __terminalBone.terminalX;
        var endY:Number = __terminalBone.terminalY;
        
        if( _orient )
          _c.moveAndRotate( endX, endY, __terminalBone.orientation-_c.orientation );
        else
          _c.move(endX, endY);
      }
    }
    
    // unlink all forward chains
    public function unlink():void
    {
      __forward.splice(0);
    }

/**
* @description 	Method: setNotify(_f:Function) - set the notification function reference
*
* @param _f:Function - reference to notification function
*
* @return Nothing - On low-level bone interaction _f(this) will be called.  Accessor functions and public properties may be used to query
* the type of mouse interaction.  Use the current() accesor function to obtain a reference to the current Bone (rollOver or rollOut).  Use
* the selected() accessor to obtain a reference to the Bone clicked on by the user.
*
* @since 1.0
*
*/
    public function setNotify(_f:Function):void
    {
      if( _f is Function )
        __notify = _f;
    }

/**
* @description 	Method: addBone(_b:Bone) - add a bone to the chain
*
* @param _b:Bone   - reference to Bone instance to be added
*
* @return Nothing - All bone properties should be set before calling this method
*
* @since 1.0
*
*/
    public function addBone(_b:Bone):void
    {
      __bones[__count] = _b;
      __previous       = (__count == 0) ? null : __current;
      __current        = _b;
 
      __current.IS_ROOT = (__count == 0);
      __current.IS_END  = true;
      
      addChild(__current);
      
      if( __count > 0 )
      {
        __previous.IS_END = false;
        __previous.NEXT   = __current;
        __current.PREV    = __previous;
        __terminalBone    = __current;
      }
      else
      {
        __rootBone     = __current;
        __terminalBone = __current;
      }
        
      __count++;
      
      // low-level handlers
      _b.register(BaseBone.BONE_ROLL_OVER, __onBoneRollOver);
      _b.register(BaseBone.BONE_ROLL_OUT , __onBoneRollOut );
      _b.register(BaseBone.BONE_SELECTED , __onBoneSelected);
      _b.register(BaseBone.ON_FINAL      , __onFKEnd       );
    }
    
/**
* @description 	Method: addBoneAt(_x0:Number, _y0:Number, _x1:Number, _y1:Number, _name:String, _id:uint, _type:String, _template:Template, _renderable:Boolean) - add a bone at the specified joint coordinates
*
* @param _x0:Number          - x-coordinate of initial joint
* @param _y0:Number          - y-coordinate of initial joint
* @param _x1:Number          - x-coordinate of terminal joint
* @param _y1:Number          - y-coordinate of terminal joint
* @param _name:String        - bone name 
* @param _id:uint            - bone id
* @param _type:String        - bone type (for drawing)
* @param _renderable:Boolean - true if the bone is renderable
*
* @return Nothing - All bone properties should be set before calling this method
*
* @since 1.0
*
*/
    public function addBoneAt(_x0:Number, _y0:Number, _x1:Number, _y1:Number, _name:String, _id:uint, _type:String, _template:Template=null, _renderable:Boolean=true):void
    {
      var b:Bone   = new Bone();
      b.NAME       = _name;
      b.ID         = _id;
      b.drawType   = _type;
      b.RENDERABLE = _renderable;
      
      b.setInitial(_x0, _y0);
      b.setTerminal(_x1, _y1);
      
      // setTemplate() needs to be called after setTerminal() so that the length of the bone is known
      if( _type == Bone.CUSTOM && _template != null )
        b.setTemplate(_template);
        
      addBone(b);
      
      b.draw();
    }
    
/**
* @description 	Method: createBone() - add a bone to the chain and return a reference to the created bone - used for GUI's that create bones interactively
*
* @return Bone - Reference to created bone - most common use is to create bones interactively with a GUI
*
* @since 1.0
*
*/
    public function createBone():Bone
    {
      var b:Bone = new Bone();
      addBone(b);
      return b;
    }
    
    public function draw():void
    {
      for( var i:uint=0; i<__bones.length; ++i )
      {
        var b:Bone   = __bones[i];
        b.RENDERABLE = true;
        b.draw();
      }		
    }
    
/**
* @description 	Method: pop() - pop bone off the end of the chain
*
* @return Nothing - bone at end of the chain is deleted
*
* @since 1.0
*
*/
    public function pop():void
    {
      var b:Bone = __bones.pop();
      
      // remove from end of display list
      removeChild(b);
      
      // destroy the bone 
      b.destruct();
      b = null;  
      
      __count               = __bones.length;
      __terminalBone        = __bones[__count-1];
      __terminalBone.IS_END = true;
      __terminalBone.NEXT   = null;
    }
  
/**
* @description 	Method: invalidate() - chain orientation has been externally changed - anything linked forward is no longer valid in position or orientation
*
* @return Nothing - all items linked forward are moved and re-oriented
*
* @since 1.0
*
*/  
    public function invalidate():void
    {
      // note - an optional argument will be added in the future to force orientation to match the chain
      var links:uint = __forward.length;
      if( links > 0 )
      {
        // end-effector coordinates
        var endX:Number = this.endX;
        var endY:Number = this.endY;
      	
      	for( var i:uint=0; i<links; ++i )
      	{
      	  var c:IChain  = __forward[i];
      	  var dA:Number = this.endOrientation - c.orientation; 
      	  c.moveAndRotate(endX, endY, dA);
      	}	
      }
    }
    
/**
* @description 	Method: selectRoot() - select or highlight the root bone of the chain - no handlers are fired
*
* @return Nothing -
*
* @since 1.0
*
*/
    public function selectRoot():void
    {
      __rootBone.select();	
    }
    
/**
* @description 	Method: move(_newX:Number, _newY:Number) - move the root bone of the chain - FK causes remainder of chain to move
*
* @param _newX:Number - new x-coordinate
* @param _newY:Number - new y-coordiante
*
* @return Nothing - root bone is moved and this motion is propagated to remaining bones in chain
*
* @since 1.0
*
*/
    public function move( _newX:Number, _newY:Number ):void
    {
      __rootBone.moveInitial(_newX, _newY);
    }
    
/**
* @description 	Method: moveAndRotate(_newX:Number, _newY:Number, _deltaAngle:Number) - move the root bone of the chain and rotate by the input delta angle
*
* @param _newX:Number       - new x-coordinate
* @param _newY:Number       - new y-coordiante
* @param _deltaAngle:Number - delta angle
 * 
* @return Nothing - root bone is moved to new coordinates; this is the only bone in the chain that may have its initial joint directly translated
*
* @since 1.0
*
*/
    public function moveAndRotate( _newX:Number, _newY:Number, _deltaAngle:Number ):void
    {
      __rootBone.moveAndRotate(_newX, _newY, _deltaAngle, Math.cos(_deltaAngle), Math.sin(_deltaAngle));
    }
    
    // change the connector's orientation by the input delta angle (radians in the range [0,2pi]
    public function offsetOrientation(_deltaAngle:Number):void
    {
      // to be implemented	
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
      for( var i:uint=0; i<__count; ++i )
      {
        var b:Bone = __bones[i];
        b.destruct();
        removeChild(b);
      }	
    }

    // handle low-level bone rollOver event
    private function __onBoneRollOver(_b:Bone):void
    {
      __current    = _b;
      __mouseEvent = BaseBone.BONE_ROLL_OVER;
      
      if( __notify != null )
        __notify(this);
    }
    
    // handle low-level bone rollOut event
    private function __onBoneRollOut(_b:Bone):void
    {
      __current    = _b;
      __mouseEvent = BaseBone.BONE_ROLL_OUT;
      
      if( __notify != null )
        __notify(this);
    }
    
    // handle low-level bone selected event
    private function __onBoneSelected(_b:Bone):void
    {
      if( __selected != null )
        __selected.deselect();
        
      __selected   = _b;
      __current    = _b;
      __mouseEvent = BaseBone.BONE_SELECTED;
      
      if( __notify != null )
        __notify(this);
    }
    
    // handle end-of-fk propagation event -- get the type of FK motion and pass it onto all linked chains 
    // delta-angle is passed forward from terminal bone in previous chain
    private function __onFKEnd(_b:Bone, _dA:Number):void
    {
      var links:uint = __forward.length;
      if( links > 0 )
      {
        // end-effector coordinates
        var endX:Number = this.endX;
        var endY:Number = this.endY;
      	
        switch( _b.getFKType() )
        {
          case BaseBone.FK_MOVE :
            for( var i:uint=0; i<links; ++i )
              __forward[i].move(endX, endY);
          break;
      	  
          case BaseBone.FK_ROTATE:
      	    for( i=0; i<links; ++i )
      	    {
      	      var c:IChain = __forward[i];
      	      c.moveAndRotate(endX, endY, _dA);
      	    }
      	  break;	
        }
      }
    }
  }
}
