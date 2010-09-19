/**
* <p><code>Easing</code> Pseudo-abstract base class from which general easing classes are derived.</p>
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
  public class Easing implements IEasing
  {
    // symbolic easing codes
    public static const BACK:String        = "back";
    public static const BOUNCE:String      = "bounce";
    public static const CIRCULAR:String    = "circular";
    public static const CUBIC:String       = "cubic";
    public static const ELASTIC:String     = "elastic";
    public static const EXPONENTIAL:String = "exponential";
    public static const LINEAR:String      = "linear";
    public static const NONE:String        = "none";
    public static const QUADRATIC:String   = "quadratic";
    public static const QUARTIC:String     = "quartic";
    public static const QUINTIC:String     = "quintic";
    public static const SINE:String        = "sine";
    
    protected var __type:String;    // type of easing
    
    public function Easing():void
    {
      __type = NONE;
    }
    
    public function get easeType():String { return __type; }
   
    public function easeIn (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
      throw new Error("Easing::easeIn() must be implemented in derived class");
	  }
	   
	  public function easeOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
	    throw new Error("Easing::easeOut() must be implemented in derived class");
	  }
	   
    public function easeInOut (t:Number, b:Number, c:Number, d:Number, optional1:Number=0, optional2:Number=0):Number 
	  {
		   throw new Error("Easing::easeInOut() must be implemented in derived class");
	  }
	}
}
