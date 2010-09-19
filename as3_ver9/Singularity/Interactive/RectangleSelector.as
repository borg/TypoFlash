//
// RectangleSelector.as - Select a rectangular area by holding and dragging the mouse.
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

package Singularity.Interactive
{
  import mx.core.Application;
  
  import flash.display.Sprite;
  import flash.display.Shape;
  import flash.events.MouseEvent;
  
  import Singularity.Events.SingularityEvent;
  import flash.display.Shape;
  import flash.display.Graphics;
  
  public class RectangleSelector extends Sprite
  {
    // core
    private var __xStart:uint;                 // x-coord. at beginning of drag
    private var __yStart:uint;                 // y-coord. at beginning of drag
    private var __xEnd:uint;                   // x-coord. at end of drag
    private var __yEnd:uint;                   // y-coord. at end of drag
    private var __xL:uint;                     // x-coord. of upper, left-hand corner of select rectangle
    private var __yL:uint;                     // y-coord. of upper, left-hand corner of select rectangle
    private var __xR:uint;                     // x-coord. of right-most extent of select rectangle
    private var __yR:uint;                     // y-coord. of lowest extent of select rectangle
    private var __width:uint;                  // width of selection area
    private var __height:uint;                 // height of selection area
    private var __tracking:Boolean;            // true if tracking mouse coords to draw rect
    
    private var __background:Shape;            // background of selection area
    private var __rectangle:Shape;             // red rectangle drawn here
    
    private var __completed:SingularityEvent;  // reference to COMPLETE event
    
/**
* @description 	Method: PointSelector(_x:uint, _y:uint, _w:uint, _h:unit, _c:uint) - Construct a new point selector
*
* @param _x:uint    - x-coordinate of upper, left-hand corner of background
* @param _y:unit    - y-coordinate of upper, left-hand corner of background
* @param _w:uint    - width of background rectangle
* @param _h:unit    - height of background rectangle
* @param _c:unit    - color of background rectangle
* @param _b:Boolean - true if background displayed
*
* @return Nothing
*
* @since 1.0
*
*/
    public function RectangleSelector(_x:uint, _y:uint, _w:uint, _h:uint, _c:uint, _b:Boolean=true)
    {
      __xL       = _x;
      __yL       = _y;
      __xStart   = _x;
      __yStart   = _y;
      __xEnd     = 0;
      __yEnd     = 0;
      __tracking = false;
      
      // minimum draw area is 10x10
      __width  = Math.max(10,_w);
      __height = Math.max(10,_h);
      __xR     = __xL + __width;
      __yR     = __yL + __height;
      
      __background = new Shape();
      __rectangle  = new Shape();
      
      __completed = new SingularityEvent(SingularityEvent.COMPLETE);
      

      __drawBackground(_x, _y, _w, _h, _c, _b);
      
      addEventListener(MouseEvent.MOUSE_DOWN, __onMouseDown);
      addEventListener(MouseEvent.MOUSE_UP  , __onMouseUp  );
      addEventListener(MouseEvent.MOUSE_MOVE, __mouseTrack );
      
      addChild(__background);
      addChild(__rectangle );
    }
    
    public function get xLeft():uint  { return __xL; }
    public function get yLeft():uint  { return __yL; }
    public function get xRight():uint { return __xR; }
    public function get yRight():uint { return __yR; }
    
    public function disable():void
    {
      __tracking = false;
      removeEventListener(MouseEvent.MOUSE_MOVE, __mouseTrack);
    }
    
    public function enable():void
    {
      addEventListener(MouseEvent.MOUSE_MOVE, __mouseTrack);
    }

    private function __onMouseDown(_e:MouseEvent):void
    {
      __xStart   = _e.localX;
      __yStart   = _e.localY;
      __tracking = true;
    }
    
    private function __onMouseUp(_e:MouseEvent):void
    {
      __rectangle.graphics.clear();
      
      __xEnd = _e.localX;
      __yEnd = _e.localY;
      
      removeEventListener(MouseEvent.MOUSE_MOVE, __mouseTrack);
      
      // set rectangle coordinates	
      if( __xEnd <= __xStart )
      {
      	// rectangle drawn to the left
      	__xL = __xEnd;
      	__xR = __xStart;
      }
      else
      {
      	// rectangle drawn to the right
      	__xL = __xStart;
      	__xR = __xEnd;
      }
      
      if( __yEnd >= __yStart )
      {
        // rectangle was drawn right and down
      	__yL = __yStart;
      	__yR = __yEnd;
      }
      else
      {
        // rectangle drawn right and up	
        __yL = __yEnd;
        __yR = __yStart;
      }
      
      dispatchEvent(__completed);
    }
    
    private function __mouseTrack(_e:MouseEvent):void
    {
      if( __tracking )
      {
        var curX:Number = __background.mouseX;
        var curY:Number = __background.mouseY;
      
        var g:Graphics = __rectangle.graphics;
        g.clear();
        g.lineStyle(1,0xff0000);
        g.moveTo(__xStart, __yStart);
      
        // draw red rectangle	
        g.lineTo(__xStart, curY    );
        g.lineTo(curX    , curY    );
        g.lineTo(curX    , __yStart);
        g.lineTo(__xStart, __yStart);
      }
    }
    
    private function __drawBackground(_x:uint, _y:uint, _w:uint, _h:uint, _c:uint, _b:Boolean):void
    {
      var g:Graphics = __background.graphics;
      g.lineStyle(1);
      g.beginFill(_c);

      g.drawRect(_x, _y, _w, _h);
      if( !_b )
        __background.alpha = 1;
    }
  }
}