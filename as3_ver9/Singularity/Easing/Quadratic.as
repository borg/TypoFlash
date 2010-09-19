/**
 	* <p><code>Quadratic</code> Quadratic easing function, adopted from robertpenner.com.</p>
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
  public class Quadratic extends Easing
  {
    public function Quadratic()
    {
      super();
      
      __type = QUADRATIC;
    }
    
	  override public function easeIn (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number
	  {
		  return c*(t/=d)*t + b;
	  }
	 
	  override public function easeOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  return -c *(t/=d)*(t-2) + b;
	  }
	   
	  override public function easeInOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  if( (t/=d/2) < 1 ) 
		  {
		    return c/2*t*t + b;
		  }
		    
		  return -c/2 * ((--t)*(t-2) - 1) + b;
	  }
  }
}
