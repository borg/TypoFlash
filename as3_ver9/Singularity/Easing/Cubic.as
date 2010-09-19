/**
	* <p><code>Cubic</code> Cubic easing function, adopted from robertpenner.com.</p>
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
	*/

package Singularity.Easing
{
  public class Cubic extends Easing
  {
    public function Cubic()
    {
      super();
      
      __type = CUBIC;
    }
	   
	  override public function easeIn (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		   return c*(t/=d)*t*t + b;
	  }
	   
	  override public function easeOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		   return c*((t=t/d-1)*t*t + 1) + b;
	  }
	   
	  override public function easeInOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		   if ((t/=d/2) < 1) 
		   {
		     return c/2*t*t*t + b;
		   }
		   
		   return c/2*((t-=2)*t*t + 2) + b;
	  }
	}
}
