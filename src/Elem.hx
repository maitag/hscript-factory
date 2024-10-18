package;

import peote.view.Color;
import peote.view.Element;

class Elem implements Element
{
	// Position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	
	@posY public var y:Int;
	
	
	// Size in pixel
	@sizeX public var w=100;
	
	@sizeY public var h:Int=100;
	
	
	// Rotation around pivot point
	@rotation public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX public var px:Int = 0;

	// pivot y (rotation offset)
	@pivotY public var py:Int = 0;
	
	
	// Color (RGBA)
	@color public var c:Color;
	
		
	// z-index for depth
	@zIndex 	
	public var z:Int = 0; //@const(1) // max 0x3FFFFFFF , min -0xC0000000
	
	
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, rotation:Float=0.0, pivotX:Int=0, pivotY:Int=0, zIndex:Int=0, color:Int=0xff0000ff )
	{
		x = positionX;
		y = positionY;
		w = width;
		h = height;
		r = rotation;
		px = pivotX;
		py = pivotY;
		z = zIndex;
		c = color;
	}

}
