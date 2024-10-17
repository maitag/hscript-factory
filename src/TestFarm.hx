package;

import lime.app.Application;
import lime.ui.Window;

import script.HscriptFarm;
import script.HscriptFunction;
import script.HscriptObject;

class TestFarm extends Application
{

	override function onWindowCreate():Void
	{
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try init(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function init(window:Window)
	{
		var farm = new HscriptFarm();
		
		var f1 = new HscriptFunction("f1", [ "numbers" => [10,20,30] ],
		"
			var sum = 0; //sum += f3();
			for( n in numbers )
				sum += f2( [ 'x' => n ] );  // <-- calls f2 here
			return sum + globalState;
		");

		var f2  = new HscriptFunction("f2", [ "x" => 2,  "y" => 3 ],
		"
			return x + y;
		");

		var obj = new HscriptObject("test", ["globalState" => 42] );
		obj.addFunction(f1);
		obj.addFunction(f2);

		obj.parse(); // parse all into object-context

		trace( f1.run( [ ] ) ); // testing
		// trace( f2.run( [ "x" => 5 ] )   );
	}
	



}