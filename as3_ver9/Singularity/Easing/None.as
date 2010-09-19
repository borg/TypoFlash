/**
	* <p><code>None</code> No easing function; allows no easing to be implemented in a factory, consistent with all other methdos.  This is essentially
	* linear easing which is what would be obtained with simple linear interpolation and a zero starting point for any tween.  <code>None</code> 
	* and <code>Linear</code> are interchangeable with <code>c = 1</code> and <code>b = 0</code>; that is, no-easing is a special case of linear easing.</p>
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
  public class None extends Easing
  {
    public function None()
    {
      super();
      
      __type = NONE;
    }
    
	  override public function easeIn (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  return __easeNone(t, b, c, d);
	  }
	   
	  override public function easeOut(t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  return __easeNone(t, b, c, d);
	  }
	   
	  override public function easeInOut(t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		  return __easeNone(t, b, c, d);
	  }
	   
	  private function __easeNone(t:Number, b:Number, c:Number, d:Number):Number 
	  {
		  return t/d;
	  }
	}
}
