package;

class ElemShader implements peote.view.Element
{
	// always hardcoded for full size of Display
	@sizeX @const @formula("uResolution.x") var w:Float;
	@sizeY @const @formula("uResolution.y") var h:Float;
}
