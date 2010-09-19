/**
* <p><code>Back</code> Back easing function, adopted from robertpenner.com.</p>
* 
* This software is derived from code bearing the copyright notice,
*
* Copyright © 2001 Robert Penner
* All rights reserved.
*
* and governed by terms of use at http://www.robertpenner.com/easing_terms_of_use.html
*
* @version 1.0
*
* 
*/

package Singularity.Easing
{
  public class Back extends Easing
  {
    public function Back()
    {
      super();
      
      __type = BACK;
    }
    
    override public function easeIn (t:Number, b:Number, c:Number, d:Number, s:Number=0, optional2:Number=0):Number 
	  {
	    if( s == 0 )
	    {
	      s = 1.70158;
	    }
		    
	    return c*(t/=d)*t*((s+1)*t - s) + b;
	  }
	   
	  override public function easeOut (t:Number, b:Number, c:Number, d:Number, s:Number=0, optional2:Number=0):Number 
	  {
	    if( s == 0 )
	    { 
	      s = 1.70158;
      }
		    
		  return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
	  }
	   
    override public function easeInOut (t:Number, b:Number, c:Number, d:Number, s:Number=0, optional2:Number=0):Number 
	  {
		  if( s == 0 )
		  {
		    s = 1.70158;
		  }
		     
		  if ((t/=d/2) < 1) 
		  {
		    return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
		  }
		    
		  return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
	  }
	}
}
