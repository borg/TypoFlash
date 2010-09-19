//
// BZFactory.as - Bezier factory - manages Class instances corresponding to single-segment Bezier curves of arbitrary order
// (provided such classes exist in the Singularity library).  Current implementation supports quad. and cubic curves -- quartic
// and quintic to be added in the future.
//
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, 
// or consequential damages, including, without limitation, lost revenues, lost profits, 
// or loss of prospective economic advantage, resulting from the use or misuse of this 
// software program.
//
// Programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
//

package Singularity.Geom
{
  import Singularity.Geom.Parametric;
  import Singularity.Geom.Bezier2;
  import Singularity.Geom.Bezier3;
  
  public class BZFactory
  {
  	private static const MAX_POINTS:uint = 4;
  	
  	// core
    private var __instances:Array;

    public function BZFactory()
    {
      __instances = new Array();
      
      for( var i:uint=0; i<MAX_POINTS; ++i )
        __instances[i] = null;
    }
    
    // return appropriate Bezier instance given number of control points
    public function getInstance(_n:uint):Parametric
    {
      if( _n < 2 || _n > MAX_POINTS )
        return null;
        
      if( __instances[_n-1] == null )
      {
      	var newParametric:Parametric = null;
        switch(_n)
        {
          case 3 :
            newParametric = new Bezier2();
          break;
            
          case 4 :
            newParametric = new Bezier3();
          break;
        } 		
      	__instances[_n-1] = newParametric;
      	return newParametric;
      }
      else
        return __instances[_n-1];
    }
  }
}