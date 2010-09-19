//
// CubicCage.as - Simple holder class for cubic Bezier control points.    
//
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, 
// or consequential damages, including, without limitation, lost revenues, lost profits, 
// or loss of prospective economic advantage, resulting from the use or misuse of this 
// software program.
//
// Programmed by:  Jim Armstrong, Singularity (www.algorithmist.net)
//

package Singularity.Geom.P3D
{ 
  import flash.display.Graphics;
  import flash.display.Shape;
	
  public class CubicCage
  {
    // properties
    public var P0X:Number;
    public var P1X:Number;
    public var P2X:Number;
    public var P3X:Number;
    public var P0Y:Number;
    public var P1Y:Number;
    public var P2Y:Number;
    public var P3Y:Number;

    public function CubicCage()
    {
      init();
    }
  
    public function init():void
    {
      P0X = 0;
      P1X = 0;
      P2X = 0;
      P3X = 0;
      P0Y = 0;
      P1Y = 0;
      P2Y = 0;
      P3Y = 0;
    }

    public function draw(_s:Shape, _c:Number):void
    {
      var g:Graphics = _s.graphics;
      g.lineStyle(0, _c, 100);
      g.moveTo(P0X, P0Y);
      g.lineTo(P1X, P1Y);
      g.lineTo(P2X, P2Y);
      g.lineTo(P3X, P3Y);
    }
  }
}