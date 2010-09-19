//
// Cubic.as - Simple holder class for cubic polynomial coefficients.    
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
//

package Singularity.Geom.P3D
{
  public class Cubic implements Singularity.Geom.P3D.IPoly
  {
    // properties
    private var __c0X:Number;
    private var __c1X:Number;
    private var __c2X:Number;
    private var __c3X:Number;
    private var __c0Y:Number;
    private var __c1Y:Number;
    private var __c2Y:Number;
    private var __c3Y:Number;
    private var __c0Z:Number;
    private var __c1Z:Number;
    private var __c2Z:Number;
    private var __c3Z:Number;
    private var __count:uint;

    public function Cubic()
    {
      reset();
    }

    public function reset():void
    {
      __c0X = 0;
      __c1X = 0;
      __c2X = 0;
      __c3X = 0;
      __c0Y = 0;
      __c1Y = 0;
      __c2Y = 0;
      __c3Y = 0;
      __c0Z = 0;
      __c1Z = 0;
      __c2Z = 0;
      __c3Z = 0;
      
      __count = 0;
    }
    
    public function addCoef( _cX:Number, _cY:Number, _cZ:Number ):void
    {
      if( __count < 4 && !isNaN(_cX) && !isNaN(_cY) )
      {
      	switch(__count)
      	{
      	  case 0:
      	    __c0X = _cX;
      	    __c0Y = _cY;
      	    __c0Z = _cZ;
      	  break;
      	  
      	  case 1:
      	    __c1X = _cX;
      	    __c1Y = _cY;
      	    __c1Z = _cZ;
      	  break;
      	  
      	  case 2:
      	    __c2X = _cX;
      	    __c2Y = _cY;
      	    __c2Z = _cZ;
      	  break;
      	  
      	  case 3:
      	    __c3X = _cX;
      	    __c3Y = _cY;
      	    __c3Z = _cZ;
      	  break;
      	}
      	__count++;
      }
    }
    
    public function getCoef( _indx:uint ):Object 
    { 
      if( _indx > -1 && _indx < 4 )
      {
      	var coef:Object = new Object();
      	switch(_indx)
      	{
      	  case 0:
      	    coef.X = __c0X;
      	    coef.Y = __c0Y;
      	    coef.Z = __c0Z;
      	  break;
      	  
      	  case 1:
      	    coef.X = __c1X;
      	    coef.Y = __c1Y;
      	    coef.Z = __c1Z;
      	  break;
      	  
      	  case 2:
      	    coef.X = __c2X;
      	    coef.Y = __c2Y;
      	    coef.Z = __c2Z;
      	  break;
      	  
      	  case 3:
      	    coef.X = __c3X;
      	    coef.Y = __c3Y;
      	    coef.Z = __c3Z;
      	  break;
      	}
      }
      return coef;
    }


    public function getX(_t:Number):Number
    {
      return (__c0X + _t*(__c1X + _t*(__c2X + _t*(__c3X))));
    }

    public function getY(_t:Number):Number
    {
      return (__c0Y + _t*(__c1Y + _t*(__c2Y + _t*(__c3Y))));
    }
    
    public function getZ(_t:Number):Number
    {
      return (__c0Z + _t*(__c1Z + _t*(__c2Z + _t*(__c3Z))));
    }
    
    public function getXPrime(_t:Number):Number
    {
      return (__c1X + _t*(2.0*__c2X + _t*(3.0*__c3X)));
    }
    
    public function getYPrime(_t:Number):Number
    {
      return (__c1Y + _t*(2.0*__c2Y + _t*(3.0*__c3Y)));
    }
    
    public function getZPrime(_t:Number):Number
    {
      return (__c1Z + _t*(2.0*__c2Z + _t*(3.0*__c3Z)));
    }
    
    public function getDyDx(_t:Number):Number
    {
      // use chain rule
      var dy:Number = getYPrime(_t);
      var dx:Number = getXPrime(_t);
      return dy/dx;
    }
    
    public function getDzDx(_t:Number):Number
    {
      // use chain rule
      var dz:Number = getZPrime(_t);
      var dx:Number = getXPrime(_t);
      return dz/dx;
    }

    public function toString():String
    {
      var myStr:String = "coef[0] " + __c0X + "," + __c0Y + "," + __c0Z;
      myStr           += " coef[1] " + __c1X + "," + __c1Y + "," + __c1Z;
      myStr           += " coef[2] " + __c2X + "," + __c2Y + "," + __c2Z;
      myStr           += " coef[3] " + __c3X + "," + __c3Y + "," + __c3Z;
    
      return myStr;
    }
  }
}