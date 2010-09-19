/**
	* <p><code>Exponential</code> Exponential easing function, adopted from robertpenner.com.</p>
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
  public class Exponential extends Easing
  {
    public function Exponential()
    {
      super();
      
      __type = EXPONENTIAL;
    }
    
	  override public function easeIn (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		   return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b;
	  }
	 
	  override public function easeOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		   return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
	  }
	  
	  override public function easeInOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  if( t==0 ) 
		  {
		   return b;
		  }
		  
		  if( t==d )
		  {
		    return b+c;
		  }
		    
		  if( (t/=d/2) < 1 )
		  {
		    return c/2 * Math.pow(2, 10 * (t - 1)) + b;
		  }
		    
		  return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
    }
  }
}
