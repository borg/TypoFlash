/**
	* <p><code>Elastic</code> Elastic easing function, adopted from robertpenner.com.</p>
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
  public class Elastic extends Easing
  {
    public function Elastic()
    {
      super();
      
      __type = ELASTIC;
    }
    
	  override public function easeIn (t:Number, b:Number, c:Number, d:Number, a:Number=0, p:Number=0):Number 
	  {
		  if( t==0 ) 
		  {
		    return b;
		  }
		    
		  if( (t/=d)==1 ) 
		  {
		    return b+c;
		  }
		    
		  if(!p) 
		  {
		    p=d*.3;
		  }
		    
		  if( !a || a < Math.abs(c) )
		  { 
		    a            = c; 
		    var s:Number = p/4; 
		  }
		  else 
		  {
		    s = p/(2*Math.PI) * Math.asin(c/a);
		  }
		   
		  return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
	  }
	   
	  override public function easeOut (t:Number, b:Number, c:Number, d:Number, a:Number=0, p:Number=0):Number 
	  {
	    if( t == 0 ) 
	    {
	      return b;
	    }
		    
	    if( (t/=d) == 1 ) 
	    {
	      return b+c;
	    }
	    
	    if( !p ) 
	    {
	      p = d*.3;
	    }
		    
	    if( !a || a < Math.abs(c) )
	    {
	      a            = c; 
	      var s:Number = p/4; 
	    }
	    else 
	    {
	      s = p/(2*Math.PI) * Math.asin (c/a);
	    }
		    
	    return (a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b);
	  }
	   
	  override public function easeInOut (t:Number, b:Number, c:Number, d:Number, a:Number=0, p:Number=0):Number 
	  {
	    if( t == 0 ) 
	    {
	      return b;
	    }
		    
	    if( (t/=d/2) == 2 ) 
	    {
	      return b+c;
	    }
		    
	    if( !p ) 
	    {
	      p = d*(.3*1.5);
	    }
		    
	    if( !a || a < Math.abs(c) ) 
	    { 
	      a            = c; 
	      var s:Number = p/4; 
	    }
	    else 
	    {
	      s = p/(2*Math.PI) * Math.asin (c/a);
	    }
		    
	    if( t < 1 ) 
	    {
	      return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
	    }
		    
	    return a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b;
	  }
	}
}
