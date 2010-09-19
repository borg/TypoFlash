//
// IChain.as - Base Interface for a single chain or connnector
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

package Singularity.Rigs
{
  public interface IChain
  {
    function get linkedTo():IChain;
    function get orientation():Number;
    function get endOrientation():Number;
    function set linkedTo(_c:IChain):void;
    
    function move(_newX:Number, _newY:Number):void;
    
    function moveAndRotate(_newX:Number, _newY:Number, _deltaAngle:Number):void;
  }

}
