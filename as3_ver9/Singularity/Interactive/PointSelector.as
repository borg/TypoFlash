//
// PointSelector.as - Select points on stage via mouse click within a user-defined drawing area
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
  
  public class PointSelector extends Sprite
  {
    // core
    private var __x:uint;                      // most recently selected x-coordinate
    private var __y:uint;                      // most recently selected y-coordinate
    private var __xL:uint;                     // x-coord. of upper, left-hand corner of background
    private var __yL:uint;                     // y-coord. of upper, left-hand corner of background
    private var __xR:uint;                     // x-coord. of right-most extent of draw area
    private var __yR:uint;                     // y-coord. of lowest extent of draw area
    private var __width:uint;                  // width of drawing area
    private var __height:uint;                 // height of drawing area
    
    private var __background:Shape;            // background of drawing area
    private var __xHair:Shape;                 // cross-hair shape
    
    private var __selected:SingularityEvent;   // reference to selected event
    
/**
* @description 	Method: PointSelector(_x:uint, _y:uint, _w:uint, _h:unit, _c:uint) - Construct a new point selector
*
* @param _x:uint - x-coordinate of upper, left-hand corner of background
* @param _y:unit - y-coordinate of upper, left-hand corner of background
* @param _w:uint - width of background rectangle
* @param _h:unit - height of background rectangle
* @param _c:unit - color of background rectangle
*
* @return Nothing
*
* @since 1.0
*
*/
    public function PointSelector(_x:uint, _y:uint, _w:uint, _h:uint, _c:uint)
    {
      __x  = 0;
      __y  = 0;
      __xL = _x;
      __yL = _y;
      
      // minimum draw area is 10x10
      __width  = Math.max(10,_w);
      __height = Math.max(10,_h);
      __xR     = __xL + __width;
      __yR     = __yL + __height;
      
      __background = new Shape();
      __xHair      = new Shape();
      
      __selected = new SingularityEvent(SingularityEvent.SELECTED);
      
      __drawBackground(_c);
      __drawXHair(1,6);
      
      __xHair.visible = false;
      
      addEventListener(MouseEvent.CLICK     , __onMouseClick);
      addEventListener(MouseEvent.MOUSE_MOVE, __mouseTrack  );
      
      addChild(__background);
      addChild(__xHair);
    }
    
    public function get selectedX():uint { return __x; }
    public function get selectedY():uint { return __y; }
    
    public function disableXHair():void
    {
      __xHair.visible = false;
      removeEventListener(MouseEvent.MOUSE_MOVE, __mouseTrack);
    }
    
    public function enableXHair():void
    {
      __xHair.visible = false;
      addEventListener(MouseEvent.MOUSE_MOVE, __mouseTrack);
    }

    private function __onMouseClick(_e:MouseEvent):void
    {
      __x = _e.localX;
      __y = _e.localY;
      
      dispatchEvent(__selected);
    }
    
    private function __mouseTrack(_e:MouseEvent):void
    {
      __x = _e.localX;
      __y = _e.localY;
      
      __xHair.x       = __x;
      __xHair.y       = __y;
      __xHair.visible = __x >= __xL && __x <= __xR && __y >= __yL && __y <= __yR;  	
    }
    
    private function __drawBackground(_c:uint):void
    {
      var g:Graphics = __background.graphics;
      g.lineStyle(1);
      g.beginFill(_c);

      g.drawRect(__xL, __yL, __width, __height);
    }
    
    private function __drawXHair(_w:uint, _h:uint):void
    {
      var g:Graphics = __xHair.graphics;
      g.lineStyle(0, 0x000000);
      g.beginFill(0x000000);
      g.moveTo(-_w,-_w);
      g.lineTo(-_w,-_h);
      g.lineTo(_w,-_h);
      g.lineTo(_w,-_w);
      g.lineTo(_h,-_w);
      g.lineTo(_h,_w);
      g.lineTo(_w,_w);
      g.lineTo(_w,_h);
      g.lineTo(-_w,_h);
      g.lineTo(-_w,_w);
      g.lineTo(-_h,_w);
      g.lineTo(-_h,-_w);
      g.lineTo(-_w,-_w);
      g.endFill();
    }
  }
}