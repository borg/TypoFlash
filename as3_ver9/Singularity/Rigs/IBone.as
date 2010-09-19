//
// IBone.as - Interface for a single Bone
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
  public interface IBone
  {
  	// assign the type of geometric figure used to draw the bone
  	function set drawType(_s:String):void;
  	
  	// set initial joint coordinates
    function setInitial(_cX:Number, _cY:Number):void;
    
    // set terminal joint coordinates
    function setTerminal(_cX:Number, _cY:Number):void;
    
    // move the initial coordinates, offsetting terminal coordinates to maintain orientation
    function moveInitial(_newX:Number, _newY:Number):void;
    
    // move the bone and rotate into a new orientation
    function moveAndRotate(_newX:Number, _newY:Number, _newAngle:Number, _c:Number, _s:Number):void;
    
  	// initialize bone, also used to reset bone parameters other than handlers
    function init():void;

    // deep-six the bone, preparing the class instance to be marked for garbage collection
    function destruct():void;
    
    // draw the Bone
    function draw():void;
    
    // select this bone outside of mouse interaction
    function select():void;
    
    // deselect the bone
    function deselect():void;
    
    // register handlers for low-level interaction, bypassing normal event system
    function register(_e:String, _f:Function):void;
  }

}
