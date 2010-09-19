/**
	* <p><code>Linear</code> Linear easing function, adopted from robertpenner.com.</p>
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
  public class Linear extends Easing
  {
    public function Linear()
    {
      super();
      
      __type = LINEAR;
    }
	   
	  override public function easeIn (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		   return c*t/d + b;
	  }
	   
	  override public function easeOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		   return c*t/d + b;
	  }
	   
	  override public function easeInOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		   return c*t/d + b;
	  }
	}
}
