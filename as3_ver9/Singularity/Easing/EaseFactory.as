/**
* <p><code>EaseFactory</code> A simple Factory for generating easing classes of a specified type.</p>
* 
* @author Jim Armstrong
* @version 1.0
*
* copyright (c) 2008, Jim Armstrong.  All Rights Reserved.
*
* This software program is supplied 'as is' without any warranty, express, implied, 
* or otherwise, including without limitation all warranties of merchantability or fitness
* for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
* consequential damages, including, without limitation, lost revenues, lost profits, or 
* loss of prospective economic advantage, resulting from the use or misuse of this software 
* program.
* 
*/

package Singularity.Easing
{
  public class EaseFactory implements IEasingFactory
  {
    // direct references to specific ease classes
    private var __back:Back;
    private var __bounce:Bounce;
    private var __circular:Circular;
    private var __cubic:Cubic;
    private var __elastic:Elastic;
    private var __exponential:Exponential;
    private var __linear:Linear;
    private var __none:None;
    private var __quadratic:Quadratic;
    private var __quartic:Quartic;
    private var __quintic:Quintic;
    private var __sine:Sine;
    
    // reference to current easing class
    private var __easeClass:IEasing;
    private var __easeType:String;
    
    public function EaseFactory():void
    {
      super();
      
      __easeType = Easing.NONE;
      
      __none        = new None();
      __easeClass   = __none;
      
      __back        = null;
      __bounce      = null;
      __circular    = null;
      __cubic       = null;
      __elastic     = null;
      __exponential = null;
      __linear      = null;
      __quadratic   = null;
      __quartic     = null;
      __quintic     = null;
      __sine        = null;
    }
    
    // allow caller to work with a direct reference to the easing class
    public function get easeClass():IEasing { return __easeClass; }
    
    // set the current ease reference from a pool with instances created just-in-tim
    public function set easeType(_eType:String):void
    { 
      switch( _eType )
      {
        case Easing.BACK:
          if( __back == null )
            __back = new Back();
            
          __easeClass = __back;
        break;
        
        case Easing.BOUNCE:
          if( __bounce == null )
            __bounce = new Bounce();
            
          __easeClass = __bounce;  
        break;
        
        case Easing.CIRCULAR:
          if( __circular == null )
            __circular = new Circular();
            
          __easeClass = __circular;  
        break;
        
        case Easing.CUBIC:
          if( __cubic == null )
            __cubic = new Cubic();
            
          __easeClass = __cubic;  
        break;
        
        case Easing.ELASTIC:
          if( __elastic == null )
            __elastic = new Elastic();
            
          __easeClass = __elastic;  
        break;
        
        case Easing.EXPONENTIAL:
          if( __exponential == null )
            __exponential = new Exponential();
            
          __easeClass = __exponential;  
        break;
        
        case Easing.LINEAR:
          if( __linear == null )
            __linear = new Linear();
            
          __easeClass = __linear;  
        break;
        
        case Easing.NONE:
          if( __none == null )
            __none = new None();
            
          __easeClass = __none;  
        break;
        
        case Easing.QUADRATIC:
          if( __quadratic == null )
            __quadratic = new Quadratic();
            
          __easeClass = __quadratic;  
        break;
        
        case Easing.QUINTIC:
          if( __quintic == null )
            __quintic = new Quintic();
            
          __easeClass = __quintic;  
        break;
        
        case Easing.SINE:
          if( __sine == null )
            __sine = new Sine();
            
          __easeClass = __sine;  
        break;
        
        default:
          if( __none == null )
            __none = new None();
            
          __easeClass = __none;  
        break;
      }
    }
    
    public function get easeType():String { return __easeType; }
    
    public function easeIn (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
      return __easeClass != null ? __easeClass.easeIn(t, b, c, d, optional1, optional2) : 0;
	  }
	   
	  public function easeOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  { 
	    return __easeClass != null ? __easeClass.easeOut(t, b, c, d, optional1, optional2) : 0;
	  }
	   
    public function easeInOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  return __easeClass != null ? __easeClass.easeInOut(t, b, c, d, optional1, optional2) : 0;
	  }
	}
}
