//
// Consts.as - Constants used in a variety of applications.
//
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
// Programmed by:  Jim Armstrong, Singularity (www.algorithmist.net)

package Singularity.Numeric
{ 
  public class Consts
  {
    public static const ZERO_TOL:Number = 0.0001; // zero tolerance
    
    public static const PI_2:Number       = 0.5*Math.PI;
    public static const PI_4:Number       = 0.25*Math.PI;
    public static const PI_8:Number       = 0.125*Math.PI;
    public static const PI_16:Number      = 0.0625*Math.PI; 
    public static const TWO_PI:Number     = 2.0*Math.PI;
    public static const THREE_PI_2:Number = 1.5*Math.PI;
    public static const ONE_THIRD:Number  = 1.0/3.0;
    public static const TWO_THIRDS:Number = ONE_THIRD + ONE_THIRD;
    public static const ONE_SIXTH:Number  = 1.0/6.0;
    public static const DEG_TO_RAD:Number = Math.PI/180;
    public static const RAD_TO_DEG:Number = 180/Math.PI;
    
    public static const CIRCLE_ALPHA:Number = 4*(Math.sqrt(2)-1)/3.0;
    
    public static const ON:Boolean  = true;
    public static const OFF:Boolean = false;
    
    public static const AUTO:String         = "A";
    public static const DUPLICATE:String    = "D";
    public static const EXPLICIT:String     = "E";
    public static const CHORD_LENGTH:String = "C";
    public static const ARC_LENGTH:String   = "AL";
    public static const UNIFORM:String      = "U";
    public static const FIRST:String        = "F"; 
    public static const LAST:String         = "L";
    public static const POLAR:String        = "P";
    
    // Machine-dependent
    private var __epsilon:Number;
    	
    public function Consts()
    {
      // Machine epsilon ala Eispack
      var __fourThirds:Number = 4.0/3.0;
      var __third:Number      = __fourThirds - 1.0;
      var __one:Number        = __third + __third + __third;
      __epsilon               = Math.abs(1.0 - __one);
    }

    public function get EPSILON():Number { return __epsilon; }
  }
}