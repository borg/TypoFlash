//
// Biped.as - Humanoid Biped Rig.  Current implemetation is for symmetric characters.
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
//
// Note:  Chain interactivity is disabled by default so that mouse interaction does not interfere with a GUI
// driving chain generation.  After the chain is completed, enabled it to react to mouse events.

package Singularity.Rigs
{
  import flash.display.Sprite;
  import flash.display.Shape;
    
  import Singularity.Events.SingularityEvent;
  import Singularity.Numeric.Consts;
  
  import Singularity.Rigs.Arm;
  import Singularity.Rigs.BaseBone;
  import Singularity.Rigs.Chain;
  import Singularity.Rigs.Clavicle;
  import Singularity.Rigs.Foot;
  import Singularity.Rigs.Hand;
  import Singularity.Rigs.Head;
  import Singularity.Rigs.IChain;
  import Singularity.Rigs.Neck;
  import Singularity.Rigs.Pelvis;
  import Singularity.Rigs.SimpleSpine;
  import flash.display.Graphics;

      
  public class Biped extends Sprite implements IChain
  { 
  	// limbs
  	public static const HEAD:String            = "H";
  	public static const NECK:String            = "N";
  	public static const PELVIS:String          = "P";
  	public static const SPINE:String           = "S";
  	public static const LEFT_CLAVICLE:String   = "LC";
  	public static const LEFT_UPPER_ARM:String  = "LUA";
  	public static const LEFT_FOREARM:String    = "LF";
  	public static const LEFT_HAND:String       = "LH";
  	public static const LEFT_UPPER_LEG:String  = "LUL";
  	public static const LEFT_LOWER_LEG:String  = "LLL";
  	public static const LEFT_FOOT:String       = "LF";
  	public static const RIGHT_CLAVICLE:String  = "LC";
  	public static const RIGHT_UPPER_ARM:String = "LUA";
  	public static const RIGHT_FOREARM:String   = "LF";
  	public static const RIGHT_HAND:String      = "LH";
  	public static const RIGHT_UPPER_LEG:String = "LUL";
  	public static const RIGHT_LOWER_LEG:String = "LLL";
  	public static const RIGHT_FOOT:String      = "LF";
  	
  	// bounding-box fractions
  	public static const COM_Y:Number    = 0.525;
  	public static const HEAD_X:Number   = 0.153;
  	public static const HEAD_Y:Number   = 0.153;
  	public static const NECK_X:Number   = 0.05;
  	public static const NECK_Y:Number   = 0.053;
  	public static const CLAV_X:Number   = 0.2222;
  	public static const CLAV_Y:Number   = 0.0231;
  	public static const ARM_X:Number    = 0.198;
  	public static const ARM_Y:Number    = 0.3025;
  	public static const PELVIS_X:Number = 0.298;
  	public static const PELVIS_Y:Number = 0.095;
  	public static const LEG_X:Number    = 0.1;
  	public static const LEG_Y:Number    = 0.521;
  	public static const SPINE_X:Number  = 0.435;
  	public static const SPINE_Y:Number  = 0.2725;
  	
  	// drawing
  	public static const YELLOW:uint           = 0xe8d441;
  	public static const YELLOW_OVER:uint      = 0xffcc33;
  	public static const LIGHT_BLUE:uint       = 0xa6caf0;
  	public static const LIGHT_BLUE_OVER:uint  = 0x9999ff;
  	public static const BLUE:uint             = 0x1c1cb1;
  	public static const BLUE_OVER:uint        = 0x6699cc;
  	public static const SPINE_GREEN:uint      = 0x086e86;
  	public static const SPINE_GREEN_OVER:uint = 0x009999;
  	public static const ARM_GREEN:uint        = 0x068606;
  	public static const ARM_GREEN_OVER:uint   = 0x006666;
  	
  	// control renderable and enabled properties of any limb
  	public static const ENABLED:String    = "E";
  	public static const RENDERABLE:String = "R";
  	
  	// properties
  	public var NAME:String;               // name associated with this Biped
  	public var ID:uint;                   // numeric ID associated with this Biped
  	public var SHOW_BOUNDING:Boolean;     // if true, show bounding boxes on initial draw (leave false except for demo or debugging)
  	
  	// COM
  	private var __COM:Shape;              // Center-of-Mass (visual representation)
  	private var __comX:Number;            // COM x-coordinate
  	private var __comY:Number;            // COM y-coordinate
  	private var __angle:Number;           // Biped orientation relative to pos. x-axis
  	
  	// core
  	private var __linkedTo:IChain;        // what is the COM linked to?
  	private var __links:Array;            // All Chains and connectors linked to the COM - including those outside the Biped (allows for chains outside the normal limb set)
  	private var __numLinks:uint;          // total number of direct links to the COM
  	private var __head:Head;              // Biped head
  	private var __neck:Neck;              // Biped neck
  	private var __leftClavicle:Clavicle;  // Biped left clavicle
  	private var __leftArm:Arm;            // Biped left arm
  	private var __leftHand:Hand;          // Biped left hand
  	private var __leftLeg:Leg;            // Biped left leg
  	private var __leftFoot:Foot;          // Biped left foot
  	private var __spine:SimpleSpine;      // Biped spine
  	private var __rightClavicle:Clavicle; // Biped right clavicle
  	private var __rightArm:Arm;           // Biped right arm
  	private var __rightHand:Hand;         // Biped right hand
  	private var __rightLeg:Leg;           // Biped right leg
  	private var __rightFoot:Foot;         // Biped right foot
  	private var __pelvis:Pelvis;          // Biped pelvis 
  	private var __selected:Object;        // reference to current selection
  	private var __comSelected:Boolean;    // true if the COM is selected
  	private var __limbs:Object;           // hash of all Biped limbs, indexed by symbolic name
  	private var __error:SingularityEvent; // reference to error event
  	private var __mouseEvent:String;      // most recent type of mouse interaction
  	
  	// drawing templates - also used for skinning of segmented characters
  	private var __headTemplate:Template;
  	private var __neckTemplate:Template;
  	private var __clavicleTemplate:Template;
  	private var __upperArmTemplate:Template;
  	private var __foreArmTemplate:Template;
  	private var __handTemplate:Template;
  	private var __upperLegTemplate:Template;
  	private var __lowerLegTemplate:Template;
  	private var __footTemplate:Template;
  	private var __spineTemplate:Template;
  	private var __pelvisTemplate:Template;
  	
  	// Low-level notification of events
  	private var __notify:Function;
  	
  	
  	// A rig is constructed from a bounding-box
    public function Biped(_x:Number, _y:Number, _w:Number, _h:Number):void
    {
      super();
          
      NAME          = "Biped";
  	  ID            = 0
  	  SHOW_BOUNDING = true;
  	
  	  __COM         = new Shape();
  	  __angle       = Consts.PI_2;
  	  __numLinks    = 0;
  	  __selected    = null;
  	  __notify      = null;
  	  __limbs       = new Object();
  	  __links       = new Array();
  	  __comSelected = false;
  	  
  	  __linkedTo      = null;
  	  __head          = null;
  	  __neck          = null;
  	  __leftClavicle  = null;
  	  __leftArm       = null;
  	  __leftHand      = null;
  	  __leftLeg       = null;
  	  __leftFoot      = null;
  	  __spine         = null;
  	  __rightClavicle = null;
  	  __rightArm      = null;
  	  __rightHand     = null;
  	  __rightLeg      = null;
  	  __rightFoot     = null;
  	  __pelvis        = null;
  	  
  	  __error           = new SingularityEvent(SingularityEvent.ERROR);
      __error.classname = "Biped";
  	  
  	  __mouseEvent = BaseBone.BONE_NONE;
  	  
  	  // Default Templates (arm and leg chains have their own default Templates, so these won't be changed unless overriden by the caller)
  	  
  	  // Foot Template
      __footTemplate = new Template();
      __footTemplate.insert(0,15);
      __footTemplate.insert(25,50);
      __footTemplate.insert(100,50);
        
      // Hand Template
      __handTemplate = new Template();
      __handTemplate.insert(0,20);
      __handTemplate.insert(25,50);
      __handTemplate.insert(85,60);
      __handTemplate.insert(100,35);
        
      // Head Template
      __headTemplate = new Template();
      __headTemplate.insert(0,40);
      __headTemplate.insert(25,60);
      __headTemplate.insert(85,60);
      __headTemplate.insert(100,45);
        
      // Spine Template
      __spineTemplate = new Template();
      __spineTemplate.insert(0,15);
      __spineTemplate.insert(20,25);
      __spineTemplate.insert(75,35);
      __spineTemplate.insert(85,35);
      __spineTemplate.insert(95,28);
      __spineTemplate.insert(100,22);
        
      // Clavicle Template
      __clavicleTemplate = new Template();
      __clavicleTemplate.insert(0,3);
      __clavicleTemplate.insert(5,3);
      __clavicleTemplate.insert(20,5);
      __clavicleTemplate.insert(85,5);
      __clavicleTemplate.insert(90,8);
      __clavicleTemplate.insert(95,8);
      __clavicleTemplate.insert(100,5);
        
      // Pelvis Template
      __pelvisTemplate= new Template();
      __pelvisTemplate.insert(0,100);
      __pelvisTemplate.insert(35,100);
      __pelvisTemplate.insert(100,40);
      
      // Neck Template
      __neckTemplate = new Template();
      __neckTemplate.insert(0,50);
      __neckTemplate.insert(100,50);
      
      // arm templates
      __upperArmTemplate = new Template();
      __upperArmTemplate.insert(0,5);
      __upperArmTemplate.insert(10,8);
      __upperArmTemplate.insert(90,8);
      __upperArmTemplate.insert(96,5);
      
      __foreArmTemplate = new Template();
      __foreArmTemplate.insert(0,3);
      __foreArmTemplate.insert(10,6);
      __foreArmTemplate.insert(90,6);
      __foreArmTemplate.insert(96,3);
      
      // leg templates
      __upperLegTemplate = new Template();
      __upperLegTemplate.insert(0,5);
      __upperLegTemplate.insert(10,8);
      __upperLegTemplate.insert(60,11);
      __upperLegTemplate.insert(96,5);
      __upperLegTemplate.insert(100,5);
      
      __lowerLegTemplate = new Template();
      __lowerLegTemplate.insert(0,3);
      __lowerLegTemplate.insert(10,6);
      __lowerLegTemplate.insert(45,8);
      __lowerLegTemplate.insert(96,3);
      __lowerLegTemplate.insert(100,3);
      
      // Biped links are created inside bounding box - each added to the display list after creation
      __createBiped(_x, _y, _w, _h);
      
  	  __drawCOM(_h);
  	  __COM.visible = false;
  	  addChild(__COM);
    }

    private function __createBiped(_x:Number, _y:Number, _w:Number, _h:Number):void
    {
      // Set COM coordinates
      __comX = _x + 0.5*_w;
  	  __comY = _y + COM_Y*_h;
  	  
  	  // pelvis bounding box - position pelvis so that center of box corresponds with the COM
  	  var pelvisW:Number = PELVIS_X*_w;
  	  var pelvisH:Number = PELVIS_Y*_h;
  	  var pelvisX:Number = __comX - 0.5*pelvisW;
  	  var pelvisY:Number = __comY - 0.5*pelvisH;
  	  
  	  __pelvis        = new Pelvis(pelvisX, pelvisY, pelvisW, pelvisH, __pelvisTemplate, YELLOW, YELLOW_OVER);
  	  __limbs[PELVIS] = __pelvis;
  	  
  	  __pelvis.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __pelvis.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __pelvis.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__pelvis);
  	  
  	  // pelvis is direct-linked to COM
  	  addLink(__pelvis);
  	  
  	  // Spine
  	  var spineW:Number = SPINE_X*_w;
  	  var spineH:Number = SPINE_Y*_h;
  	  var spineX:Number = __comX - 0.5*spineW;
  	  var spineY:Number = pelvisY - spineH;
  	  
  	  __spine        = new SimpleSpine(spineX, spineY, spineW, spineH, __spineTemplate, SPINE_GREEN, SPINE_GREEN_OVER);
  	  __limbs[SPINE] = __spine;
  	  
  	  // Spine is linked to the mid-terminator of the Pelvis - spine auto-orients on creation
  	  __pelvis.link(__spine, Connector.MIDDLE, false);
  	  
  	  __spine.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __spine.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __spine.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__spine);
  	  
  	  // Neck
  	  var neckH:Number = NECK_Y*_h;
  	  var neckW:Number = neckH;
  	  var neckX:Number = __comX - 0.5*neckW;
  	  var neckY:Number = spineY - neckH;
  	  
  	  __neck        = new Neck(neckX, neckY, neckW, neckH, __neckTemplate, SPINE_GREEN, SPINE_GREEN_OVER);
  	  __limbs[NECK] = __neck;
  	  
  	  // Neck is linked to the mid-terminator of the Spine
  	  __spine.link(__neck, Connector.MIDDLE, false);
  	  
  	  __neck.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __neck.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __neck.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__neck);
  	  
  	  // Left clavicle
  	  var lcW:Number = CLAV_X*_w;
  	  var lcH:Number = 0.5*neckH;
  	  var lcX:Number = __neck.rightX;
  	  var lcY:Number = __neck.rightY;
  	  
  	  __leftClavicle = new Clavicle(lcX, lcY, lcW, lcH, Clavicle.LEFT, __clavicleTemplate, SPINE_GREEN, SPINE_GREEN_OVER);
  	  
  	  // Left-clavicle is linked to the right-terminator of the Neck
  	  __neck.link(__leftClavicle, Connector.RIGHT, false);
  	  
  	  __leftClavicle.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __leftClavicle.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __leftClavicle.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__leftClavicle);
  	  
  	  // Right clavicle
  	  var rcW:Number = CLAV_X*_w;
  	  var rcH:Number = 0.5*neckH;
  	  var rcX:Number = __neck.leftX-rcW;
  	  var rcY:Number = __neck.leftY;
  	  
  	  __rightClavicle = new Clavicle(rcX, rcY, rcW, rcH, Clavicle.RIGHT, __clavicleTemplate, SPINE_GREEN, SPINE_GREEN_OVER);
  	  
  	  // Right-clavicle is linked to the left-terminator of the Neck
  	  __neck.link(__rightClavicle, Connector.LEFT, false);
  	  
  	  __rightClavicle.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __rightClavicle.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __rightClavicle.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__rightClavicle);
  	  
  	  // Head
  	  var headW:Number = HEAD_X*_w;
  	  var headH:Number = HEAD_Y*_h;
  	  var headX:Number = __comX-0.5*headW;
  	  var headY:Number = neckY-headH;
  	  
  	  __head = new Head(headX, headY, headW, headH, __headTemplate, LIGHT_BLUE, LIGHT_BLUE_OVER);
  	  
  	  // Head is linked to the middle-terminator of the Neck
  	  __neck.link(__head, Connector.MIDDLE, false);
  	  
  	  __head.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __head.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __head.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__head);
  	  
  	  // left arm (Biped facing forward)
  	  var lArmX:Number = __leftClavicle.midX;
  	  var lArmY:Number = __leftClavicle.midY;
  	  var armW:Number  = ARM_X*_w;
  	  var armH:Number  = ARM_Y*_h;
  	  
  	  __leftArm = new Arm(lArmX, lArmY, armW, armH, Arm.LEFT, __upperArmTemplate, __foreArmTemplate, BLUE, BLUE_OVER);
  	  
  	  // Left Arm is linked to the middle-terminator of the Left Clavicle
  	  __leftClavicle.link(__leftArm, Connector.MIDDLE, false);
  	  
  	  __leftArm.setNotify(__onChainNotify);
      __leftArm.setNotify(__onChainNotify);
      __leftArm.setNotify(__onChainNotify);
      
  	  addChild(__leftArm);
  	  
  	  // left hand
  	  var handW:Number  = armW*0.25;
  	  var handH:Number  = armH*0.15;
  	  var lhandX:Number = lArmX + armW;
  	  var lhandY:Number = lArmY + armH;
  	  
  	  __leftHand = new Hand(lhandX, lhandY, handW, handH, Hand.LEFT, __handTemplate, BLUE, BLUE_OVER);
  	  
  	  // Left Hand is linked to the end-effector of the left arm chain
  	  __leftArm.link(__leftHand, true);
  	  
  	  __leftHand.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __leftHand.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __leftHand.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__leftHand);
  	  
  	  // right arm (Biped facing forward)
  	  var rArmX:Number = __rightClavicle.midX-armW;
  	  var rArmY:Number = __rightClavicle.midY;
  	  
  	  __rightArm = new Arm(rArmX, rArmY, armW, armH, Arm.RIGHT, __upperArmTemplate, __foreArmTemplate, ARM_GREEN, ARM_GREEN_OVER);
  	  
  	  // Right Arm is linked to the middle-terminator of the Right Clavicle
  	  __rightClavicle.link(__rightArm, Connector.MIDDLE, false);
  	  
  	  __rightArm.setNotify(__onChainNotify);
      __rightArm.setNotify(__onChainNotify);
      __rightArm.setNotify(__onChainNotify);
      
  	  addChild(__rightArm);
  	  
  	  // right hand
  	  var rhandX:Number = rArmX-handW;
  	  var rhandY:Number = rArmY + armH;
  	  
  	  __rightHand = new Hand(rhandX, rhandY, handW, handH, Hand.RIGHT, __handTemplate, ARM_GREEN, ARM_GREEN_OVER);
  	  
  	  // Right Hand is linked to the end-effector of the right arm chain
  	  __rightArm.link(__rightHand, true);
  	  
  	  __rightHand.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __rightHand.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __rightHand.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__rightHand);
  	  
  	  // left leg (Biped facing forward)
  	  var lLegX:Number = __pelvis.rightX;
  	  var lLegY:Number = __pelvis.rightY;
  	  var legW:Number  = LEG_X*_w;
  	  var legH:Number  = LEG_Y*_h;
  	  
  	  __leftLeg = new Leg(lLegX, lLegY, legW, legH, Leg.LEFT, __upperLegTemplate, __lowerLegTemplate, BLUE, BLUE_OVER);
  	  
  	  // Left Leg is linked to the right-terminator of the Pelvis
  	  __pelvis.link(__leftLeg, Connector.RIGHT, false);
  	  
  	  __leftLeg.setNotify(__onChainNotify);
      __leftLeg.setNotify(__onChainNotify);
      __leftLeg.setNotify(__onChainNotify);
      
  	  addChild(__leftLeg);
  	  
  	  // right leg (Biped facing forward)
  	  var rLegX:Number = __pelvis.leftX-legW;
  	  var rLegY:Number = __pelvis.leftY;
  	  
  	  __rightLeg = new Leg(rLegX, rLegY, legW, legH, Leg.RIGHT, __upperLegTemplate, __lowerLegTemplate, ARM_GREEN, ARM_GREEN_OVER);
  	  
  	  // Right Leg is linked to the left-terminator of the Pelvis
  	  __pelvis.link(__rightLeg, Connector.LEFT, false);
  	  
  	  __rightLeg.setNotify(__onChainNotify);
      __rightLeg.setNotify(__onChainNotify);
      __rightLeg.setNotify(__onChainNotify);
      
  	  addChild(__rightLeg);
  	  
  	  // left foot
  	  var footW:Number  = legW*0.7;
  	  var footH:Number  = legH*0.075;
  	  var lfootX:Number = __leftLeg.endX - 0.5*footW;
  	  var lfootY:Number = lLegY + legH;
  	  
  	  __leftFoot = new Foot(lfootX, lfootY, footW, footH, Foot.LEFT, __footTemplate, BLUE, BLUE_OVER);
  	  
  	  // Left Foot is linked to the end-effector of the left leg chain, but retains default orientation
  	  __leftLeg.link(__leftFoot, false);
  	  
  	  __leftFoot.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __leftFoot.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __leftFoot.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__leftFoot);
  	  
  	  // right foot
  	  var rfootX:Number = __rightLeg.endX - 0.5*footW;
  	  var rfootY:Number = rLegY + legH;
  	  
  	  __rightFoot = new Foot(rfootX, rfootY, footW, footH, Foot.RIGHT, __footTemplate, ARM_GREEN, ARM_GREEN_OVER);
  	  
  	  // Right Foot is linked to the end-effector of the right leg chain, but retains default orientation
  	  __rightLeg.link(__rightFoot, false);
  	  
  	  __rightFoot.register(BaseBone.BONE_ROLL_OVER, __onChainNotify);
      __rightFoot.register(BaseBone.BONE_ROLL_OUT , __onChainNotify);
      __rightFoot.register(BaseBone.BONE_SELECTED , __onChainNotify);
      
  	  addChild(__rightFoot);
    }
    
    public function get mouseEvent():String     { return __mouseEvent; }
    public function get selected():Object       { return __selected;   }
    public function get orientation():Number    { return (__angle>=0) ? __angle : Consts.TWO_PI+__angle; }
    public function get endOrientation():Number { return (__angle>=0) ? __angle : Consts.TWO_PI+__angle; }
    public function get linkedTo():IChain       { return __linkedTo; }
    
    public function isComSelected():Boolean { return __comSelected; }
    
    // enable or disable all limbs in the Biped
    public function set enabled(_b:Boolean):void
    {
      if( __head != null )
        __head.ENABLED = _b;
        
      if( __neck != null )
        __neck.ENABLED = _b;
      
      if( __leftClavicle != null )
        __leftClavicle.ENABLED = _b;
      
      if( __rightClavicle != null )
        __rightClavicle.ENABLED = _b;
      
      if( __leftArm != null )
        __leftArm.enabled = _b;
      
      if( __rightArm != null )
        __rightArm.enabled = _b;
        
      if( __leftHand != null )
        __leftHand.ENABLED = _b;
      
      if( __rightHand != null )
        __rightHand.ENABLED = _b;
      
      if( __spine != null )
        __spine.ENABLED = _b;
      
      if( __pelvis != null )
        __pelvis.ENABLED = _b;
      
      if( __leftLeg != null )
        __leftLeg.enabled = _b;
      
      if( __rightLeg != null )
        __rightLeg.enabled = _b;
    } 
    
    public function set linkedTo(_c:IChain):void { __linkedTo = _c; }
    
/**
* @description 	Method: addLink(_l:IChain) - add a link to the Biped COM
*
* @param _l:Object - reference to Connector or Chain to be linked to the COM - must implement the IChain interface
*
* @return Nothing - COM movement and rotation is propagated to all linked chains and connectors
*
* @since 1.0
*
*/
    public function addLink(_l:IChain):void
    {
      // no error-checking ... you break it, you buy it.  Unlinking may be added later.
      __links.push(_l);
      _l.linkedTo = this;
      __numLinks++;
    }
/**
* @description 	Method: setProperty(_limb:String, _type:String, _b:Boolean) - set the renderable or enabled property on the specified limb
*
* @return Nothing
*
* @since 1.0
*
*/
    public function setProperty(_limb:String, _type:String, _b:Boolean):void
    {
      var l:*            = __limbs[_limb];
      __error.methodname = "setProperty()";
            	
      if( l == undefined )
      {	
        __error.message = "limb: " + _limb + " is not defined in the Biped.";
        dispatchEvent( __error );
        return;
      }
      
      if( _type == RENDERABLE )
        l.RENDERABLE = _b;
      else if( _type == ENABLED )
        l.ENABLED = _b;
      else
      {
        __error.message = "Invalid property: " + _type + ", must be Biped.RENDERABLE or Biped.ENABLED.";
        dispatchEvent( __error );
        return;
      }
    }
    
/**
* @description 	Method: setNotify(_f:Function) - set the notification function reference
*
* @param _f:Function - reference to notification function
*
* @return Nothing - On low-level bone interaction _f(this) will be called.  Accessor functions and public properties may be used to query
* the type of mouse interaction.  Use the current() accesor function to obtain a reference to the current Bone (rollOver or rollOut).  Use
* the selected() accessor to obtain a reference to the Bone clicked on by the user.
*
* @since 1.0
*
*/
    public function setNotify(_f:Function):void
    {
      if( _f is Function )
        __notify = _f;
    }
    
/**
* @description 	Method: selectCOM(_b:Boolean) - select and highlight the rig's COM
*
* @param _b:Boolean - true if COM is selected
*
* @return Nothing 
*
* @since 1.0
*
*/
    public function selectCOM( _b:Boolean ):void
    {
	  __selected    = _b ? __COM : null;
	  __comSelected = _b;
	  __COM.visible = _b;
    }
    
/**
* @description 	Method: move(_newX:Number, _newY:Number) - move the rig's COM - FK causes remainder of chain to move
*
* @param _newX:Number - new x-coordinate
* @param _newY:Number - new y-coordiante
*
* @return Nothing - COM is moved and this motion is propagated to remaining bones in chain
*
* @since 1.0
*
*/
    public function move( _newX:Number, _newY:Number ):void
    { 
      __comX = _newX;
      __comY = _newY;
      
      if( __comSelected )
      {
        __COM.x = __comX;
        __COM.y = __comY;
      }
      
      for( var i:uint; i<__numLinks; ++i )
        __links[i].move(_newX,_newY);
    }
    
/**
* @description 	Method: rotate(_angle:Number) - rotate the rig about the COM
*
* @param _angle:Number - rotation angle in radians in [0,2pi]
* 
* @return Nothing 
*
* @since 1.0
*
*/
    public function rotate( _angle:Number ):void
    {
      // compute the delta angle
      var newAngle:Number   = (_angle >= 0) ? _angle  : Consts.TWO_PI+_angle;
      var deltaAngle:Number = newAngle - this.orientation;
      __angle               = newAngle;
      
      for( var i:uint; i<__numLinks; ++i )
        __links[i].offsetOrientation(deltaAngle);
    }
    
    public function moveAndRotate(_newX:Number, _newY:Number, _deltaAngle:Number):void
    {
      // to be implemented
    }
    
/**
* @description 	Method: draw() - draw the Biped
*
* @return Nothing - draw all Biped components, however, some may not be renderable
*
* @since 1.0
*
*/
    public function draw():void
    {
      // in the future, it may be allowable to delete a limb, so test each on individually
      if( __head != null )
      {
        __head.draw();
        
        if( SHOW_BOUNDING )
        {
          var g:Graphics = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__head.boundX,__head.boundY,__head.boundW,__head.boundH);
        }
      }
        
      if( __neck != null )
      {
        __neck.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__neck.boundX,__neck.boundY,__neck.boundW,__neck.boundH);
        }
      }
      
      if( __leftClavicle != null )
      {
        __leftClavicle.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__leftClavicle.boundX,__leftClavicle.boundY,__leftClavicle.boundW,__leftClavicle.boundH);
        }
      }
      
      if( __rightClavicle != null )
      {
        __rightClavicle.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__rightClavicle.boundX,__rightClavicle.boundY,__rightClavicle.boundW,__rightClavicle.boundH);
        }
      }
      
      if( __leftArm != null )
      {
        __leftArm.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__leftArm.boundX,__leftArm.boundY,__leftArm.boundW,__leftArm.boundH);
        }
      }
      
      if( __leftHand != null )
      {
        __leftHand.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__leftHand.boundX,__leftHand.boundY,__leftHand.boundW,__leftHand.boundH);
        }
      }
      
      if( __rightArm != null )
      {
        __rightArm.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__rightArm.boundX,__rightArm.boundY,__rightArm.boundW,__rightArm.boundH);
        }
      }
      
      if( __rightHand != null )
      {
        __rightHand.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__rightHand.boundX,__rightHand.boundY,__rightHand.boundW,__rightHand.boundH);
        }
      }
      
      if( __spine != null )
      {
        __spine.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__spine.boundX,__spine.boundY,__spine.boundW,__spine.boundH);
        }
      }
      
      if( __pelvis != null )
      {
        __pelvis.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__pelvis.boundX,__pelvis.boundY,__pelvis.boundW,__pelvis.boundH);
        }
      }
      
      if( __leftLeg != null )
      {
        __leftLeg.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__leftLeg.boundX,__leftLeg.boundY,__leftLeg.boundW,__leftLeg.boundH);
        }
      }
      
      if( __rightLeg != null )
      {
        __rightLeg.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__rightLeg.boundX,__rightLeg.boundY,__rightLeg.boundW,__rightLeg.boundH);
        }
      }
      
      if( __leftFoot != null )
      {
        __leftFoot.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__leftFoot.boundX,__leftFoot.boundY,__leftFoot.boundW,__leftFoot.boundH);
        }
      }
      
      if( __rightFoot != null )
      {
        __rightFoot.draw();
        
        if( SHOW_BOUNDING )
        {
          g = this.graphics;
  	      g.lineStyle(1,0xff0000);
  	      g.drawRect(__rightFoot.boundX,__rightFoot.boundY,__rightFoot.boundW,__rightFoot.boundH);
        }
      }
    }
    
    // this function handles low-level notification from any chain or connector
    private function __onChainNotify(_c:*):void
    {
      // notification is from a Bone or a Connector
      __selected   = _c;
      __mouseEvent = _c.mouseEvent;
            
      if( __notify != null )
        __notify(this);
    }
    
    // draw the Chain's COM
    private function __drawCOM(_h:Number):void
    {
      var h:Number   = 0.2*PELVIS_Y*_h + 2;
      var g:Graphics = __COM.graphics;
      g.lineStyle(1,0xffffff);
      g.moveTo(0,-h);
      g.lineTo(h,0);
      g.lineTo(0,h);
      g.lineTo(-h,0);
      g.lineTo(0,-h);
      g.lineTo(0,h);
      g.moveTo(-h,0);
      g.lineTo(h,0);
      
      __COM.x = __comX;
      __COM.y = __comY;
      
      // COM is never redrawn - only moved
      __COM.cacheAsBitmap = true;
    }
  }
}
