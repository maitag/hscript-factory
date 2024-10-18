package;

import lime.app.Application;
import lime.ui.Window;

import hscript.Expr.Error;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;

import ui.Ui;
import script.HscriptFarm;
import script.HscriptFunction;
import script.HscriptObject;

typedef Buffer_Elem = Buffer<Elem>;
	

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
	public var funky:HscriptFunction; // little hack to make it testable still at NOW

	public function onUIInit() 
	{
		// -------------- Farmers joy --------------------

		var farm = new HscriptFarm();

		funky = new HscriptFunction("funky1", [], "var d = new Display(700, 0, 200, 200, 0x442211ff);
var b = new Buffer(111);
var p = new Program(b);
d.addProgram(p);
peoteView.addDisplay(d);

var e = new Elem();
b.addElement(e);"
		);

		ui.codeArea.textPage.text = funky.script;
		ui.codeArea.textPage.xOffset = ui.codeArea.textPage.yOffset = 0;
		ui.codeArea.textPage.updateLayout();

		// to prevent DCE for Elem and Buffer_Elem
		var dummyE = new Elem();
		var dummyB = new Buffer_Elem(10);
		dummyB.addElement(dummyE);

		object = new HscriptObject("test", ["peoteView"=>peoteView, "Display"=>Display, "Program"=>Program, "Buffer"=>Buffer_Elem, "Elem"=>Elem ] );
		object.addFunction(funky);	
	}	

	public function onRun()
	{	
		funky.script = ui.codeArea.textPage.text;
		
		var e = object.parseFunction(funky);
		if (e != null) 
		{
			ui.logArea.log( "parse error:" + e.toString() + "\n");
			// ui.logArea.log( 'line:${e.line+1}, pos:(${e.pmin},${e.pmax}), error: ${e.toString()}\n' );
			ui.codeArea.textPage.select(0, 666666, e.line, e.line);
		}
		else {
			try {
				ui.logArea.log(
					(funky.run( [ ] ):String) + "\n"
				);
			} 
			catch (e:Error) {
				ui.logArea.log( "execution error:" + e.toString() + "\n");
				ui.codeArea.textPage.select(0, 666666, e.line, e.line);
			}
		}
	}
	
}