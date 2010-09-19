/**
  * <p><code>Sine</code> Sine easing function, adopted from robertpenner.com.</p>
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
  public class Sine extends Easing
  {
    public function Sine()
    {
      super();
      
      __type = SINE;
    }
    
	  override public function easeIn (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  return -c*Math.cos(t/d * (Math.PI/2)) + c + b;
	  }
	   
	  override public function easeOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  return c*Math.sin(t/d * (Math.PI/2)) + b;
	  }
	   
	  override public function easeInOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  return -c/2*(Math.cos(Math.PI*t/d) - 1) + b;
	  }
	}
}
