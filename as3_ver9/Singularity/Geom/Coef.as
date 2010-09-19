//
// Coef.as - polynomial coefficients for parametric polynomials of arbitrary order.    
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
// Programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
// Note:  This is a crude implementation, meant to support the aribitrary-order Bezier curve which is itself
// used only for teaching purposes.
//
//

package Singularity.Geom
{
  public class Coef
  {
    // properties
    private var __cX:Array;
    private var __cY:Array;
    private var __len:int;
    
    public function Coef()
    {
      __cX  = new Array();
      __cY  = new Array();
      __len = 0;
    }
    
    public function get degree():uint { return __cX.length; }

    public function reset():void
    {
      __cX.splice(0);
      __cY.splice(0);
      __len = 0;
    }
    
    public function addCoef( _cX:Number, _cY:Number ):void
    {
      __cX.push(_cX);
      __cY.push(_cY);
      __len++;
    }
    
    public function getCoef( _indx:uint ):Object 
    { 
      return {X:__cX[_indx], Y:__cY[_indx]}
    }

    public function getX(_t:Number):Number
    {
      if( __len > 1 )
      {
        var p:Number = __cX[__len-1];
        for( var i:int=__len-2; i>=0; i-- )
          p = _t*p + __cX[i];
               
        return p;
      }
      else
        return __cX[0];
    }

    public function getY(_t:Number):Number
    {
      if( __len > 1 )
      {
        var p:Number = __cY[__len-1];
        for( var i:int=__len-2; i>=0; i-- )
          p = _t*p + __cY[i];
        
        return p;
      }
      else
        return __cY[0];
    }
  }
}