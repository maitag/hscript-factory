package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;

import ui.Ui;
import script.HscriptFarm;
import script.HscriptFunction;
import script.HscriptObject;

class TestPeoteView extends Application
{
	var peoteView:PeoteView;
	var display:Display;
	var ui:Ui;

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
		peoteView = new PeoteView(window);
		
		display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);

		ui = new Ui(peoteView, onUIInit, onRun);		
	}

	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------

	public var object:HscriptObject;
	public static var funky:HscriptFunction; // little hack to make it testable still at NOW

	public function onUIInit() 
	{
		// -------------- Farmers joy --------------------

		var farm = new HscriptFarm();

		funky = new HscriptFunction("funky1", [ ],
		"
			return globalState;
		");

		object = new HscriptObject("test", ["globalState" => 42] );
		object.addFunction(funky);
	}	

	public function onRun(funky:HscriptFunction)
	{
		object.parse(); // parse all funks into object context
		ui.logArea.log(
			(funky.run( [ ] ):String)
		);
	}

}