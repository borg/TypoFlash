	/**
	* <p><code>Bounce</code> Back easing function, adopted from robertpenner.com.</p>
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
  public class Bounce extends Easing 
  {
    public function Bounce()
    {
      super();
      
      __type = BOUNCE;
    }
    
    override public function easeOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  if ((t/=d) < (1/2.75)) 
		  {
			   return c*(7.5625*t*t) + b;
		  } 
		  else if (t < (2/2.75)) 
		  {
			   return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
		  } 
		  else if (t < (2.5/2.75)) 
		  {
			   return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
		  } 
		  else 
		  {
			   return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
		  }
		}

    override public function easeIn (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
	    return c - easeOut (d-t, 0, c, d) + b;
	  }
	   
    override public function easeInOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  if (t < d/2) 
		  {
		    return easeIn (t*2, 0, c, d) * .5 + b;
		  }
		  else 
		  {
		      return easeOut (t*2-d, 0, c, d) * .5 + c*.5 + b;
      }
 	  }
 	}
}
