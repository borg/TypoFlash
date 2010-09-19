//
// PV3DSpline.as - General-purpose 3D (bezier) spline specifically designed for use with Papervision 3D. 
//
//
// copyright (c) 2007, Jim Armstrong.  All Rights Reserved.  
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special
// incidental, or consequential damages, including, without limitation, lost
// revenues, lost profits, or loss of prospective economic advantage, resulting
// from the use or misuse of this software program.
//
// Programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
// Note:  Usage of this class requires some familiarity with the Camull-Rom spline class
//

package Singularity.Geom.P3D
{   
  import Singularity.Numeric.Consts;
  import Singularity.Geom.P3D.BezierSpline;
  
  import org.papervision3d.objects.DisplayObject3D;
  
  import org.papervision3d.materials.ColorMaterial;
  import org.papervision3d.materials.special.LineMaterial;
  
  import org.papervision3d.scenes.Scene3D;
  
  import org.papervision3d.core.geom.Lines3D;
  import org.papervision3d.core.geom.renderables.Line3D;
  import org.papervision3d.core.geom.renderables.Vertex3D;
  import org.papervision3d.objects.primitives.Sphere;
  
  public class PV3DSpline extends BezierSpline
  {
    // core
    private var __lines:Lines3D;             // reference to each renderable line collection
    private var __renderableLines:Array;     // collection of individual Line3D reference for each renderable line
    
    private var __lineMaterial:LineMaterial; // material applied to renderable lines
    
    private var __lookAt:DisplayObject3D;    // dummy object for controlled object to look at (for orientation)

/**
* @description 	Method: PV3DSpline() - Construct a new PV3DSpline instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function PV3DSpline()
    {
      super();
      __error.classname  = "PV3DSpline";

      __lineMaterial = new LineMaterial(0xccccff, 100);
      
      __lines  = new Lines3D(__lineMaterial, "lines");
      __lookAt = new DisplayObject3D();
      
      __renderableLines = new Array();
    }
    
    public function addToScene(_s:Scene3D):void { _s.addChild(__lines,"__lines__"); }
    
/**
* @description 	Method: reset() - Reset the spline and prepare for new control point entry
*
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function reset():void
    {
      super.reset();
      
      var numLines:Number = __renderableLines.length;
      for( var i:uint=0; i<numLines; ++i )
        __lines.removeLine(__renderableLines[i]);
        
      __renderableLines.splice(0);
    }
    
/**
* @description 	Method: orient(_t:Number, _obj:DisplayObject3D) - Orient an object to the spline path at the specified parameter value
*
*
* @return Nothing - object is moved to the spline path at the specified parameter and oriented along the spline tangent at that parameter value
*
* @since 1.0
*
* Note:  Detailed roll control will be added in the future.
*
*/
  public function orient(_t:Number, _obj:DisplayObject3D):void
  { 
    var myX:Number = getX(_t);
    var myY:Number = getY(_t);
    var myZ:Number = getZ(_t);
    
    _obj.x = myX;
    _obj.y = myY;
    _obj.z = myZ;
    
    // small increment along derivative at _t
    __lookAt.x = myX + 0.2*getXPrime(_t);
    __lookAt.y = myY + 0.2*getYPrime(_t);
    __lookAt.z = myZ + 0.2*getZPrime(_t);
    
    _obj.lookAt(__lookAt);
  }

/**
* @description 	Method: draw(_t:Number, _color:Number, _thick:uint) - Render the spline by drawing 3d lines from point-to-point
*
* @param _t:Number     - parameter value in [0,1] - defaults to full curve
* @param _color:Number - line color (defaults to grey)
* @param _thick:uint   - line thickness (defaults to 1)
*
* @return Nothing - spline is drawn from t=0 to _t
*
* @since 1.0
*
*
*/
    public function draw(_t:Number=1.0, _color:Number=0xcccccc, _thick:uint=1):void
    {
      if( _t == 0 )
        return;
        
      __lineMaterial.lineColor = _color;
        
      var p:Number = Math.max(0,Math.min(1.0,_t));
      
      var len:Number    = arcLength();
      var deltaT:Number = 2.0/len;
      var v0:Vertex3D   = new Vertex3D( getX(0), getY(0), getZ(0) );
      
      for( var t:Number=deltaT; t<=p; t+=deltaT )
      { 
        var v1:Vertex3D = new Vertex3D( getX(t), getY(t), getZ(t) );
        var line:Line3D = new Line3D(__lines, __lineMaterial, _thick, v0, v1 );
        __lines.addLine(line);
        __renderableLines.push(line);
        
        v0 = v1;
      }
        
      v1  = new Vertex3D( getX(p), getY(p), getZ(p) );
      line = new Line3D(__lines, __lineMaterial, _thick, v0, v1 );
      __lines.addLine(line);
    }

  }
}