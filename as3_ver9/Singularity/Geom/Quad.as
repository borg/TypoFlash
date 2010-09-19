//
// Quad.as - Manager class for quadratic polynomial.  
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

package Singularity.Geom
{
  public class Quad implements IPoly
  {
    // core
    private var __c0X:Number;
    private var __c1X:Number;
    private var __c2X:Number;
    private var __c0Y:Number;
    private var __c1Y:Number;
    private var __c2Y:Number;
    private var __count:uint;

    public function Quad()
    {
      reset();
    }
    
    public function get degree():uint { return 2; }

    public function reset():void
    {
      __c0X = 0;
      __c1X = 0;
      __c2X = 0;
      __c0Y = 0;
      __c1Y = 0;
      __c2Y = 0;
      
      __count = 0;
    }
    
    public function addCoef( _cX:Number, _cY:Number ):void
    {
      if( __count < 3 && !isNaN(_cX) && !isNaN(_cY) )
      {
      	switch(__count)
      	{
      	  case 0:
      	    __c0X = _cX;
      	    __c0Y = _cY;
      	  break;
      	  
      	  case 1:
      	    __c1X = _cX;
      	    __c1Y = _cY;
      	  break;
      	  
      	  case 2:
      	    __c2X = _cX;
      	    __c2Y = _cY;
      	  break;
      	}
      	__count++;
      }
    }
    
    public function getCoef( _indx:uint ):Object 
    { 
      if( _indx > -1 && _indx < 3 )
      {
      	var coef:Object = new Object();
      	switch(_indx)
      	{
      	  case 0:
      	    coef.X = __c0X;
      	    coef.Y = __c0Y;
      	  break;
      	  
      	  case 1:
      	    coef.X = __c1X;
      	    coef.Y = __c1Y;
      	  break;
      	  
      	  case 2:
      	    coef.X = __c2X;
      	    coef.Y = __c2Y;
      	  break;
      	}
      }
      return coef;
    }

    public function getX(_t:Number):Number
    {
      return (__c0X + _t*(__c1X + _t*(__c2X)));
    }

    public function getY(_t:Number):Number
    {
      return (__c0Y + _t*(__c1Y + _t*(__c2Y)));
    }
    
    public function getXPrime(_t:Number):Number
    {
      return (__c1X + _t*(2.0*__c2X));
    }
    
    public function getYPrime(_t:Number):Number
    {
      return (__c1Y + _t*(2.0*__c2Y));
    }
    
    public function getDeriv(_t:Number):Number
    {
      // use chain rule
      var dy:Number = getYPrime(_t);
      var dx:Number = getXPrime(_t);
      return dy/dx;
    }

    public function toString():String
    {
      var myStr:String = "coef[0] " + __c0X + "," + __c0Y;
      myStr           += " coef[1] " + __c1X + "," + __c1Y;
      myStr           += " coef[2] " + __c2X + "," + __c2Y;
    
      return myStr;
    }
  }
}