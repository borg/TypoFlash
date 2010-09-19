package net.typoflash.layout {
	
	import flash.geom.Rectangle;
	import flash.events.EventDispatcher;
	
	/**
	 * Defines constraints for a layout.  The LayoutConstraint
	 * class serves as both a base class for layout instances as
	 * well as the class used by the children property of those
	 * instances.  When you make use of the children property of
	 * your Layout instances, you would generally define it as a
	 * LayoutConstraint instance.
	 *
	 * @author Trevor McCauley, www.senocular.com
	 * @date August 22, 2008
	 * @version 1.0.1
	 */
	public class LayoutConstraint extends EventDispatcher {
		
		public static const FAVOR_WIDTH:String		= "favorWidth";
		public static const FAVOR_HEIGHT:String		= "favorHeight";
		public static const FAVOR_LARGEST:String	= "favorLargest";
		public static const FAVOR_SMALLEST:String	= "favorSmallest";
		
		private var _horizontalCenter:Number;
		/**
		 * When set, if left or right is not set, the layout
		 * will be centered horizontally offset by the numeric
		 * value of this property.
		 */
		public function get horizontalCenter():Number {
			return _horizontalCenter;
		}

		public function set horizontalCenter(value:Number):void {
			_horizontalCenter = value;
			_percentHorizontalCenter = NaN;
			if (!invalid) invalidate();
		}
		private var _percentHorizontalCenter:Number;
		/**
		 * When set, if left or right is not set, the layout
		 * will be centered horizontally offset by the value
		 * of this property multiplied by the containing width.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentHorizontalCenter():Number {
			return _percentHorizontalCenter;
		}

		public function set percentHorizontalCenter(value:Number):void {
			_percentHorizontalCenter = value;
			if (!invalid) invalidate();
		}
		private var _minHorizontalCenter:Number;
		/**
		 * The minimum horizontal center location that can be applied
		 * through percentHorizontalCenter.
		 */
		public function get minHorizontalCenter():Number {
			return _minHorizontalCenter;
		}

		public function set minHorizontalCenter(value:Number):void {
			_minHorizontalCenter = value;
			if (!invalid) invalidate();
		}
		private var _maxHorizontalCenter:Number;
		/**
		 * The maximum horizontal center location that can be applied
		 * through percentHorizontalCenter.
		 */
		public function get maxHorizontalCenter():Number {
			return _maxHorizontalCenter;
		}

		public function set maxHorizontalCenter(value:Number):void {
			_maxHorizontalCenter = value;
			if (!invalid) invalidate();
		}
		
		private var _verticalCenter:Number;
		/**
		 * When set, if top or bottom is not set, the layout
		 * will be centered vertically offset by the numeric
		 * value of this property.
		 */
		public function get verticalCenter():Number {
			return _verticalCenter;
		}

		public function set verticalCenter(value:Number):void {
			_verticalCenter = value;
			_percentVerticalCenter = NaN;
			if (!invalid) invalidate();
		}
		private var _percentVerticalCenter:Number;
		/**
		 * When set, if top or bottom is not set, the layout
		 * will be centered vertically offset by the value
		 * of this multiplied by to the containing height.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentVerticalCenter():Number {
			return _percentVerticalCenter;
		}

		public function set percentVerticalCenter(value:Number):void {
			_percentVerticalCenter = value;
			if (!invalid) invalidate();
		}
		private var _minVerticalCenter:Number;
		/**
		 * The minimum vertical center location that can be applied
		 * through percentVerticalCenter.
		 */
		public function get minVerticalCenter():Number {
			return _minVerticalCenter;
		}

		public function set minVerticalCenter(value:Number):void {
			_minVerticalCenter = value;
			if (!invalid) invalidate();
		}
		private var _maxVerticalCenter:Number;
		/**
		 * The maximum vertical center location that can be applied
		 * through percentVerticalCenter.
		 */
		public function get maxVerticalCenter():Number {
			return _maxVerticalCenter;
		}

		public function set maxVerticalCenter(value:Number):void {
			_maxVerticalCenter = value;
			if (!invalid) invalidate();
		}
		
		private var _top:Number;
		/**
		 * When set, the top of the layout will be located
		 * offset from the top of it's container by the
		 * value of this property.
		 */
		public function get top():Number {
			return _top;
		}

		public function set top(value:Number):void {
			_top = value;
			_percentTop = NaN;
			if (!invalid) invalidate();
		}
		private var _percentTop:Number;
		/**
		 * When set, the top of the layout will be located
		 * offset by the value of this property multiplied
		 * by the containing height.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentTop():Number {
			return _percentTop;
		}

		public function set percentTop(value:Number):void {
			_percentTop = value;
			if (!invalid) invalidate();
		}
		private var _offsetTop:Number = 0;
		/**
		 * Add additional offset to be added to the top
		 * value after it has been set.
		 */
		public function get offsetTop():Number {
			return _offsetTop;
		}

		public function set offsetTop(value:Number):void {
			_offsetTop = value;
			if (!invalid) invalidate();
		}
		private var _minTop:Number;
		/**
		 * The minimum top location that can be applied
		 * to the layout boundaries.
		 */
		public function get minTop():Number {
			return _minTop;
		}

		public function set minTop(value:Number):void {
			_minTop = value;
			if (!invalid) invalidate();
		}
		private var _maxTop:Number;
		/**
		 * The maximum top location that can be applied
		 * to the layout boundaries.
		 */
		public function get maxTop():Number {
			return _maxTop;
		}

		public function set maxTop(value:Number):void {
			_maxTop = value;
			if (!invalid) invalidate();
		}
		
		private var _right:Number;
		/**
		 * When set, the right of the layout will be located
		 * offset by the value of this property multiplied
		 * by the containing width.
		 */
		public function get right():Number {
			return _right;
		}

		public function set right(value:Number):void {
			_right = value;
			_percentRight = NaN;
			if (!invalid) invalidate();
		}
		private var _percentRight:Number;
		/**
		 * When set, the right of the layout will be located
		 * offset by the value of this property multiplied
		 * by the containing width.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentRight():Number {
			return _percentRight;
		}

		public function set percentRight(value:Number):void {
			_percentRight = value;
			if (!invalid) invalidate();
		}
		private var _offsetRight:Number = 0;
		/**
		 * Add additional offset to be added to the right
		 * value after it has been set.
		 */
		public function get offsetRight():Number {
			return _offsetRight;
		}

		public function set offsetRight(value:Number):void {
			_offsetRight = value;
			if (!invalid) invalidate();
		}
		private var _minRight:Number;
		/**
		 * The minimum right location that can be applied
		 * to the layout boundaries.
		 */
		public function get minRight():Number {
			return _minRight;
		}

		public function set minRight(value:Number):void {
			_minRight = value;
			if (!invalid) invalidate();
		}
		private var _maxRight:Number;
		/**
		 * The maximum right location that can be applied
		 * to the layout boundaries.
		 */
		public function get maxRight():Number {
			return _maxRight;
		}

		public function set maxRight(value:Number):void {
			_maxRight = value;
			if (!invalid) invalidate();
		}
		
		private var _bottom:Number;
		/**
		 * When set, the bottom of the layout will be located
		 * offset from the bottom of it's container by the
		 * value of this property.
		 */
		public function get bottom():Number {
			return _bottom;
		}

		public function set bottom(value:Number):void {
			_bottom = value;
			_percentBottom = NaN;
			if (!invalid) invalidate();
		}
		private var _percentBottom:Number;
		/**
		 * When set, the bottom of the layout will be located
		 * offset by the value of this property multiplied
		 * by the containing height.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentBottom():Number {
			return _percentBottom;
		}

		public function set percentBottom(value:Number):void {
			_percentBottom = value;
			if (!invalid) invalidate();
		}
		private var _offsetBottom:Number = 0;
		/**
		 * Add additional offset to be added to the bottom
		 * value after it has been set.
		 */
		public function get offsetBottom():Number {
			return _offsetBottom;
		}

		public function set offsetBottom(value:Number):void {
			_offsetBottom = value;
			if (!invalid) invalidate();
		}
		private var _minBottom:Number;
		/**
		 * The minimum bottom location that can be applied
		 * to the layout boundaries.
		 */
		public function get minBottom():Number {
			return _minBottom;
		}

		public function set minBottom(value:Number):void {
			_minBottom = value;
			if (!invalid) invalidate();
		}
		private var _maxBottom:Number;
		/**
		 * The maximum bottom location that can be applied
		 * to the layout boundaries.
		 */
		public function get maxBottom():Number {
			return _maxBottom;
		}

		public function set maxBottom(value:Number):void {
			_maxBottom = value;
			if (!invalid) invalidate();
		}
		
		private var _left:Number;
		/**
		 * When set, the left of the layout will be located
		 * offset by the value of this property multiplied
		 * by the containing width.
		 */
		public function get left():Number {
			return _left;
		}

		public function set left(value:Number):void {
			_left = value;
			_percentLeft = NaN;
			if (!invalid) invalidate();
		}
		private var _percentLeft:Number;
		/**
		 * When set, the left of the layout will be located
		 * offset by the value of this property multiplied
		 * by the containing width.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentLeft():Number {
			return _percentLeft;
		}

		public function set percentLeft(value:Number):void {
			_percentLeft = value;
			if (!invalid) invalidate();
		}
		private var _offsetLeft:Number = 0;
		/**
		 * Add additional offset to be added to the left
		 * value after it has been set.
		 */
		public function get offsetLeft():Number {
			return _offsetLeft;
		}

		public function set offsetLeft(value:Number):void {
			_offsetLeft = value;
			if (!invalid) invalidate();
		}
		private var _minLeft:Number;
		/**
		 * The minimum left location that can be applied
		 * to the layout boundaries.
		 */
		public function get minLeft():Number {
			return _minLeft;
		}

		public function set minLeft(value:Number):void {
			_minLeft = value;
			if (!invalid) invalidate();
		}
		private var _maxLeft:Number;
		/**
		 * The maximum left location that can be applied
		 * to the layout boundaries.
		 */
		public function get maxLeft():Number {
			return _maxLeft;
		}

		public function set maxLeft(value:Number):void {
			_maxLeft = value;
			if (!invalid) invalidate();
		}
		
		private var _x:Number = 0;
		/**
		 * Defines the x location (top left) of the layout boundary.
		 * Unlike left, x does not affect a layout's width.  Once
		 * left (or percentLeft) is set, the x value no longer applies.
		 * If percentX exists when x is set, percentX will be
		 * overridden and be given a value of NaN.
		 * When a Layout is created for a display object, this is
		 * defined as the x location of that display object.
		 * The value of x itself cannot be NaN.
		 */
		public function get x():Number {
			return _x;
		}

		public function set x(value:Number):void {
			if (isNaN(value)) return;
			_x = value;
			_percentX = NaN;
			_rect.x = _x;
			if (!invalid) invalidate();
		}
		private var _percentX:Number;
		/**
		 * When set, the x location of the layout will be
		 * located at the value of this property multiplied
		 * by the containing width.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentX():Number {
			return _percentX;
		}

		public function set percentX(value:Number):void {
			_percentX = value;
			if (!invalid) invalidate();
		}
		private var _minX:Number;
		/**
		 * The minimum x location that can be applied
		 * to the layout boundaries.
		 */
		public function get minX():Number {
			return _minX;
		}

		public function set minX(value:Number):void {
			_minX = value;
			if (!invalid) invalidate();
		}
		private var _maxX:Number;
		/**
		 * The maximum x location that can be applied
		 * to the layout boundaries.
		 */
		public function get maxX():Number {
			return _maxX;
		}

		public function set maxX(value:Number):void {
			_maxX = value;
			if (!invalid) invalidate();
		}
		
		private var _y:Number = 0;
		/**
		 * Defines the y location (top left) of the layout boundary.
		 * Unlike top, y does not affect a layout's height.  Once
		 * top (or percentTop) is set, the y value no longer applies.
		 * If percentY exists when y is set, percentY will be
		 * overridden and be given a value of NaN.
		 * When a Layout is created for a display object, this is
		 * defined as the y location of that display object.
		 * The value of y itself cannot be NaN.
		 */
		public function get y():Number {
			return _y;
		}

		public function set y(value:Number):void {
			if (isNaN(value)) return;
			_y = value;
			_percentY = NaN;
			_rect.y = _y;
			if (!invalid) invalidate();
		}
		private var _percentY:Number;
		/**
		 * When set, the y location of the layout will be
		 * located at the value of this property multiplied
		 * by the containing height.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentY():Number {
			return _percentY;
		}

		public function set percentY(value:Number):void {
			_percentY = value;
			if (!invalid) invalidate();
		}
		private var _minY:Number;
		/**
		 * The minimum y location that can be applied
		 * to the layout boundaries.
		 */
		public function get minY():Number {
			return _minY;
		}

		public function set minY(value:Number):void {
			_minY = value;
			if (!invalid) invalidate();
		}
		private var _maxY:Number;
		/**
		 * The maximum y location that can be applied
		 * to the layout boundaries.
		 */
		public function get maxY():Number {
			return _maxY;
		}

		public function set maxY(value:Number):void {
			_maxY = value;
			if (!invalid) invalidate();
		}
		
		private var _width:Number = 100;
		/**
		 * Defines the width of the layout boundary.
		 * Once left (or percentLeft) or right (or percentRight)
		 * is set, the width value no longer applies. If
		 * percentWidth exists when width is set, percentWidth
		 * will be overridden and be given a value of NaN.
		 * When a Layout is created for a display object, this is
		 * defined as the width of that display object.
		 * The value of width itself cannot be NaN.
		 */
		public function get width():Number {
			return _width;
		}

		public function set width(value:Number):void {
			if (isNaN(value)) return;
			_width = value;
			_rect.width = _width;
			_percentWidth = NaN;
			if (!invalid) invalidate();
		}
		private var _percentWidth:Number;
		/**
		 * When set, the width of the layout will be
		 * set as the value of this property multiplied
		 * by the containing width.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentWidth():Number {
			return _percentWidth;
		}

		public function set percentWidth(value:Number):void {
			_percentWidth = value;
			if (!invalid) invalidate();
		}
		private var _minWidth:Number;
		/**
		 * The minimum width that can be applied
		 * to the layout boundaries.
		 */
		public function get minWidth():Number {
			return _minWidth;
		}

		public function set minWidth(value:Number):void {
			_minWidth = value;
			if (!invalid) invalidate();
		}
		private var _maxWidth:Number;
		/**
		 * The maximum width that can be applied
		 * to the layout boundaries.
		 */
		public function get maxWidth():Number {
			return _maxWidth;
		}

		public function set maxWidth(value:Number):void {
			_maxWidth = value;
			if (!invalid) invalidate();
		}
		
		private var _height:Number = 100;
		/**
		 * Defines the height of the layout boundary.
		 * Once top (or percentTop) or bottom (or percentBottom)
		 * is set, the width value no longer applies. If
		 * percentWidth exists when width is set, percentWidth
		 * will be overridden and be given a value of NaN.
		 * When a Layout is created for a display object, this is
		 * defined as the height of that display object.
		 * The value of height itself cannot be NaN.
		 */
		public function get height():Number {
			return _height;
		}

		public function set height(value:Number):void {
			if (isNaN(value)) return;
			_height = value;
			_rect.height = _height;
			_percentHeight = NaN;
			if (!invalid) invalidate();
		}
		private var _percentHeight:Number;
		/**
		 * When set, the height of the layout will be
		 * set as the value of this property multiplied
		 * by the containing height.
		 * A value of 0 represents 0% and 1 represents 100%.
		 */
		public function get percentHeight():Number {
			return _percentHeight;
		}

		public function set percentHeight(value:Number):void {
			_percentHeight = value;
			if (!invalid) invalidate();
		}
		private var _minHeight:Number;
		/**
		 * The minimum height that can be applied
		 * to the layout boundaries.
		 */
		public function get minHeight():Number {
			return _minHeight;
		}

		public function set minHeight(value:Number):void {
			_minHeight = value;
			if (!invalid) invalidate();
		}
		private var _maxHeight:Number;
		/**
		 * The maximum height that can be applied
		 * to the layout boundaries.
		 */
		public function get maxHeight():Number {
			return _maxHeight;
		}

		public function set maxHeight(value:Number):void {
			_maxHeight = value;
			if (!invalid) invalidate();
		}
			
		private var _maintainAspectRatio:Boolean;
		/**
		 * When true, the size of the layout will always
		 * maintain an aspect ratio relative to the ratio
		 * of the current width and height properties, even
		 * if those properties are not in control of the
		 * height and width of the layout.
		 */
		public function get maintainAspectRatio():Boolean {
			return _maintainAspectRatio;
		}

		public function set maintainAspectRatio(value:Boolean):void {
			_maintainAspectRatio = value;
			if (!invalid) invalidate();
		}
			
		private var _maintainAspectRatioPolicy:String = "favorSmallest";
		/**
		 * Determines how aspect ratio is maintained when
		 * maintainAspectRatio is true.
		 */
		public function get maintainAspectRatioPolicy():String {
			return _maintainAspectRatioPolicy;
		}

		public function set maintainAspectRatioPolicy(value:String):void {
			_maintainAspectRatioPolicy = value;
			if (!invalid) invalidate();
		}
		
		/**
		 * @private
		 */
		internal var _rect:Rectangle = new Rectangle();
		/** 
		 * The rectangle that defines the boundaries of the
		 * layout instance.  This rectangle should be used
		 * to assertain the layout's position and size over
		 * using the x, y, height, and width properties as
		 * it accounts for min/max settings and other limits.
		 * This rectangle may not be up to date if referenced
		 * prior to the layout being properly updated with draw().
		 */
		public function get rect():Rectangle {
			return _rect.clone();
		}
		
		/**
		 * @private
		 */
		internal var owner:Layout;
		
		/**
		 * @private
		 */
		internal var invalid:Boolean = false;
			
		/**
		 * Creates a new LayoutConstraint instance. LayoutConstraint
		 * instances are used by layouts and layout children to define
		 * how a target or other layouts are constrained within a
		 * containing layout.
		 * @param initRect An initializing rectangle to define the 
		 * 		position and size (rect) of the new constraint.
		 */
		public function LayoutConstraint(initRect:Rectangle = null) {
			// define rect if provided
			if (initRect) {
				_rect = initRect.clone();
				_x = _rect.x;
				_y = _rect.y;
				_width = _rect.width;
				_height = _rect.height;
			}
		}
		
		/**
		 * Creates a new copy of the current LayoutConstraint instance.
		 */
		public function clone():LayoutConstraint {
			var constraint:LayoutConstraint = new LayoutConstraint();
			constraint.match(this);
			constraint._rect = _rect.clone();
			return constraint;
		}
		
		/**
		 * Utility function for initializing constraint properties from
		 * a generic object instance.
		 * @param	initObject An object Object with key-value combinations
		 * that relate to the constraint values to be copied into this 
		 * LayoutConstraint instance.
		 */
		public function init(initObject:Object):void {
			for (var p:String in initObject){
				try{
					this[p] = initObject[p];
				}catch(error:Error){
					// fail silently
				}
			}
		}
		
		/**
		 * Sets all the constraint properties of the current constraint
		 * to match the properties of the constraint passed.
		 * @param constraint The LayoutConstraint instance to have
		 * 		the current instance match.
		 */
		public function match(constraint:LayoutConstraint):void {
			if (constraint == null) return;
			_x = constraint._x;
			_percentX = constraint._percentX;
			_minX = constraint._minX;
			_maxX = constraint._maxX;
			_y = constraint._y;
			_percentY = constraint._percentY;
			_minY = constraint._minY;
			_maxY = constraint._maxY;
			_width = constraint._width;
			_percentWidth = constraint._percentWidth;
			_minWidth = constraint._minWidth;
			_maxWidth = constraint._maxWidth;
			_height = constraint._height;
			_percentHeight = constraint._percentHeight;
			_minHeight = constraint._minHeight;
			_maxHeight = constraint._maxHeight;
			_top = constraint._top;
			_percentTop = constraint._percentTop;
			_minTop = constraint._minTop;
			_maxTop = constraint._maxTop;
			_offsetTop = constraint._offsetTop;
			_right = constraint._right;
			_percentRight = constraint._percentRight;
			_minRight = constraint._minRight;
			_maxRight = constraint._maxRight;
			_offsetRight = constraint._offsetRight;
			_bottom = constraint._bottom;
			_percentBottom = constraint._percentBottom;
			_minBottom = constraint._minBottom;
			_maxBottom = constraint._maxBottom;
			_offsetBottom = constraint._offsetBottom;
			_left = constraint._left;
			_percentLeft = constraint._percentLeft;
			_minLeft = constraint._minLeft;
			_maxLeft = constraint._maxLeft;
			_offsetLeft = constraint._offsetLeft;
			_horizontalCenter = constraint._horizontalCenter;
			_percentHorizontalCenter = constraint._percentHorizontalCenter;
			_minHorizontalCenter = constraint._minHorizontalCenter;
			_maxHorizontalCenter = constraint._maxHorizontalCenter;
			_verticalCenter = constraint._verticalCenter;
			_percentVerticalCenter = constraint._percentVerticalCenter;
			_minVerticalCenter = constraint._minVerticalCenter;
			_maxVerticalCenter = constraint._maxVerticalCenter;
			_maintainAspectRatio = constraint._maintainAspectRatio;
			_maintainAspectRatioPolicy = constraint._maintainAspectRatioPolicy;
			invalidate();
		}
		
		/**
		 * Applies the constraints to the given rectangle updating
		 * the rect property of this instance. This used when drawn
		 * to update a layout within the bounds of its parent layout.
		 * @param container The containing rectangle in which
		 * 		to fit the constraint.
		 */
		public function setIn(container:Rectangle):void {
				
			// reusable value
			var currValue:Number;
			
			// horizontal
			// place
			var noLeft:Boolean = isNaN(_left);
			var noPercentLeft:Boolean = isNaN(_percentLeft);
			var noRight:Boolean = isNaN(_right);
			var noPercentRight:Boolean = isNaN(_percentRight);
			var noHorizontalCenter:Boolean = isNaN(_horizontalCenter);
			var noPercentHorizontalCenter:Boolean = isNaN(_percentHorizontalCenter);
			var alignedLeft:Boolean = !Boolean(noLeft && noPercentLeft);
			var alignedRight:Boolean = !Boolean(noRight && noPercentRight);
			
			if (container){
				if (!alignedLeft && !alignedRight) {
					if (noHorizontalCenter && noPercentHorizontalCenter) { // normal
						_rect.width = isNaN(_percentWidth) ? _width : _percentWidth*container.width;
						_rect.x = isNaN(_percentX) ? _x + container.left : _percentX*container.width;
					}else{ // centered
						
						_rect.width = isNaN(_percentWidth) ? _width : _percentWidth*container.width;
						if (noPercentHorizontalCenter) {
							_rect.x = _horizontalCenter - _rect.width/2 + container.left + container.width/2;
						}else{
							
							// center with limits
							currValue = _percentHorizontalCenter*container.width;
							if (!isNaN(_minHorizontalCenter) && _minHorizontalCenter > currValue) {
								currValue = _minHorizontalCenter;
							}else if (!isNaN(_maxHorizontalCenter) && _maxHorizontalCenter < currValue) {
								currValue = _maxHorizontalCenter;
							}
							_rect.x = currValue - _rect.width/2 + container.left;
						}
					}
					
				}else if (!alignedRight) { // left
					_rect.width = isNaN(_percentWidth) ? _width : _percentWidth*container.width;
					_rect.x = noPercentLeft ? container.left + _left : container.left + _percentLeft*container.width;
				}else if (!alignedLeft) { // right
					_rect.width = isNaN(_percentWidth) ? _width : _percentWidth*container.width;
					_rect.x = noPercentRight ? container.right - _right - _rect.width : container.right - _percentRight*container.width - _rect.width;
				}else{ // right and left (boxed)
					_rect.right = noPercentRight ? container.right - _right : container.right - _percentRight*container.width;
					_rect.left = noPercentLeft ? container.left + _left : container.left + _percentLeft*container.width;
				}
			}
			
			// apply offsets
			if (_offsetLeft) _rect.left += _offsetLeft;
			if (_offsetRight) _rect.right -= _offsetRight;
				
			// apply limits
			if (!isNaN(_minX)){
				currValue = container.x + _minX;
				if (currValue > _rect.x) _rect.x = currValue;
			}
			if (!isNaN(_maxX)){
				currValue = container.x + _maxX;
				if (currValue < _rect.x) _rect.x = currValue;
			}
			if (!isNaN(_minLeft)){
				currValue = container.left + _minLeft;
				if (currValue > _rect.left) _rect.left = currValue;
			}
			if (!isNaN(_maxLeft)){
				currValue = container.left + _maxLeft;
				if (currValue < _rect.left) _rect.left = currValue;
			}
			if (!isNaN(_minRight)){
				currValue = container.right - _minRight;
				if (currValue < _rect.right) _rect.right = currValue;
			}
			if (!isNaN(_maxRight)){
				currValue = container.right - _maxRight;
				if (currValue > _rect.right) _rect.right = currValue;
			}
			currValue = 0;
			if (!isNaN(_minWidth) && _minWidth > _rect.width){
				currValue = _rect.width - _minWidth;
			}else if (!isNaN(_maxWidth) && _maxWidth < _rect.width){
				currValue = _rect.width - _maxWidth;
			}
			if (currValue){ // if change in width, adjust position
				if (!alignedLeft) {
					if (alignedRight) { // right 
						_rect.x += currValue;
					}else if (!(noHorizontalCenter && noPercentHorizontalCenter)) { // centered
						_rect.x += currValue/2;
					}
				}else if (alignedLeft && alignedRight) { // boxed
					_rect.x += currValue/2;
				}
				// fit width
				_rect.width -= currValue;
			}
			
			// vertical
			// place
			var noTop:Boolean = isNaN(_top);
			var noPercentTop:Boolean = isNaN(_percentTop);
			var noBottom:Boolean = isNaN(_bottom);
			var noPercentBottom:Boolean = isNaN(_percentBottom);
			var noVerticalCenter:Boolean = isNaN(_verticalCenter);
			var noPercentVerticalCenter:Boolean = isNaN(_percentVerticalCenter);
			var alignedTop:Boolean = !Boolean(noTop && noPercentTop);
			var alignedBottom:Boolean = !Boolean(noBottom && noPercentBottom);
			
			if (container){
				if (!alignedTop && !alignedBottom) {
					
					if (noVerticalCenter && noPercentVerticalCenter) { // normal
						_rect.height = isNaN(_percentHeight) ? _height : _percentHeight*container.height;
						_rect.y = isNaN(_percentY) ? _y + container.top : _percentY*container.height;
					}else{ // centered
						_rect.height = isNaN(_percentHeight) ? _height : _percentHeight*container.height;
						if (noPercentVerticalCenter) {
							_rect.y = _verticalCenter - _rect.height/2 + container.top + container.height/2;
						}else{
							
							// center with limits
							currValue = _percentVerticalCenter*container.height;
							if (!isNaN(_minVerticalCenter) && _minVerticalCenter > currValue) {
								currValue = _minVerticalCenter;
							}else if (!isNaN(_maxVerticalCenter) && _maxVerticalCenter < currValue) {
								currValue = _maxVerticalCenter;
							}
							_rect.y = currValue - _rect.height/2 + container.top;
						}
					}
					
				}else if (!alignedBottom) { // top
					_rect.height = isNaN(_percentHeight) ? _height : _percentHeight*container.height;
					_rect.y = noPercentTop ? container.top + _top : container.top + _percentTop*container.height;
				}else if (!alignedTop) { // bottom
					_rect.height = isNaN(_percentHeight) ? _height : _percentHeight*container.height;
					_rect.y = noPercentBottom ? container.bottom - _bottom - _rect.height : container.bottom - _percentBottom*container.height - _rect.height;
				}else{ // top and bottom (boxed)
					_rect.bottom = noPercentBottom ? container.bottom - _bottom : container.bottom - _percentBottom*container.height;
					_rect.top = noPercentTop ? container.top + _top : container.top + _percentTop*container.height;
				}
			}
			
			// apply offsets
			if (_offsetTop) _rect.top += _offsetTop;
			if (_offsetBottom) _rect.bottom -= _offsetBottom;
				
			// apply limits
			if (!isNaN(_minY)){
				currValue = container.y + _minY;
				if (currValue > _rect.y) _rect.y = currValue;
			}
			if (!isNaN(_maxY)){
				currValue = container.y + _maxY;
				if (currValue < _rect.y) _rect.y = currValue;
			}
			if (!isNaN(_minTop)){
				currValue = container.top + _minTop;
				if (currValue > _rect.top) _rect.top = currValue;
			}
			if (!isNaN(_maxTop)){
				currValue = container.top + _maxTop;
				if (currValue < _rect.top) _rect.top = currValue;
			}
			if (!isNaN(_minBottom)){
				currValue = container.bottom - _minBottom;
				if (currValue < _rect.bottom) _rect.bottom = currValue;
			}
			if (!isNaN(_maxBottom)){
				currValue = container.bottom - _maxBottom;
				if (currValue > _rect.bottom) _rect.bottom = currValue;
			}
			currValue = 0;
			if (!isNaN(_minHeight) && _minHeight > _rect.height){
				currValue = _rect.height - _minHeight;
			}else if (!isNaN(_maxHeight) && _maxHeight < _rect.height){
				currValue = _rect.height - _maxHeight;
			}
			if (currValue){ // if change in height, adjust position
				if (!alignedTop) {
					if (alignedBottom) { // bottom 
						_rect.y += currValue;
					}else if (!(noVerticalCenter && noPercentVerticalCenter)) { // centered
						_rect.y += currValue/2;
					}
				}else if (alignedTop && alignedBottom) { // boxed
					_rect.y += currValue/2;
				}
				// fit height
				_rect.height -= currValue;
			}
			
			// maintaining aspect if applicable; use width and height for aspect
			// only apply if one dimension is static and the other dynamic
			// matintainAspectRatioPolicy determines which dimension is
			// used as the base of the ratio
			// maintaining aspect has highest priority so it is evaluated last
			if (_maintainAspectRatio && _height && _width) {
								
				var sizeRatio:Number = _height/_width;
				var rectRatio:Number = _rect.height/_rect.width;
				
				var favorWidth:Boolean;
				var favorHeight:Boolean;
					
				switch(_maintainAspectRatioPolicy){
					
					case FAVOR_WIDTH:
						favorWidth = true;
						break;
						
					case FAVOR_HEIGHT:
						favorHeight = true;
						break;
						
					case FAVOR_LARGEST:
						favorWidth	= Boolean(sizeRatio > rectRatio);
						favorHeight	= Boolean(sizeRatio < rectRatio);
						break;
						
					case FAVOR_SMALLEST:
					default:
						favorWidth	= Boolean(sizeRatio < rectRatio);
						favorHeight	= Boolean(sizeRatio > rectRatio);
						break;
				}
		
				if (favorHeight) { // change width
					currValue = _rect.height/sizeRatio;
					
					if (!alignedLeft) {
						if (alignedRight) { // right 
							_rect.x += _rect.width - currValue;
						}else if (!(noHorizontalCenter && noPercentHorizontalCenter)) { // centered
							_rect.x += (_rect.width - currValue)/2;
						}
					}else if (alignedLeft && alignedRight) { // boxed
						_rect.x += (_rect.width - currValue)/2;
					}
					_rect.width = currValue;
					
				}else if (favorWidth) { // change height
					
					currValue = _rect.width * sizeRatio;
					
					if (!alignedTop) {
						if (alignedBottom) { // bottom 
							_rect.y += _rect.height - currValue;
						}else if (!(noVerticalCenter && noPercentVerticalCenter)) { // centered
							_rect.y += (_rect.height - currValue)/2;
						}
					}else if (alignedTop && alignedBottom) { // boxed
						_rect.y += (_rect.height - currValue)/2;
					}
					_rect.height = currValue;
				} // else it should be an exact fit
			}
		}
		
		/**
		 * Invalidates this instance and its owner
		 * @private
		 */
		internal function invalidate():void {
			if (owner && this != owner) owner.invalidate();
			invalid = true;
		}

	}
}