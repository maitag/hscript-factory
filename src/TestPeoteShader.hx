package;

import lime.app.Application;
import lime.ui.Window;

import haxe.Exception;
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

typedef Buffer_Elem = Buffer<ElemShader>;
	

class TestPeoteShader extends Application
{
	var peoteView:PeoteView;
	var display:Display;
	var program:Program;
	
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
		display = new Display(700, 0, window.width-700, window.height);
		peoteView.addDisplay(display);


		var buffer = new Buffer<ElemShader>(1);
		buffer.addElement(new ElemShader());
		program = new Program(buffer);

		// and before we forget ;:)
		display.addProgram(program);

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

		funky = new HscriptFunction("test shader injection", [],

"program.injectIntoFragmentShader(
'
vec4 funky_color()
{
  vec2 uv = vTexCoord;
  return vec4(uv.x, uv.y, uv.x * uv.y, 1.0);
}
',
true
);

// shit... -> fullyForgotTheColorFOrmula???
program.setColorFormula('funky_color()');

"
		);

		ui.codeArea.textPage.text = funky.script;
		ui.codeArea.textPage.xOffset = ui.codeArea.textPage.yOffset = 0;
		ui.codeArea.textPage.updateLayout();


		object = new HscriptObject("test", ["peoteView"=>peoteView, "display"=>display, "program"=>program ] );
		object.addFunction(funky);	
	}	

	public function onRun()
	{	
		funky.script = ui.codeArea.textPage.text;
		
		
		var e = object.parseFunction(funky);
		trace(funky.expr);
		
		if (e != null) 
		{
			ui.logArea.log( "parse error:" + e.toString() + "\n");
			// ui.logArea.log( 'line:${e.line+1}, pos:(${e.pmin},${e.pmax}), error: ${e.toString()}\n' );
			ui.codeArea.textPage.select(0, 66666666, e.line, e.line);
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
			catch (e:Exception) {
				ui.logArea.log( "execution error Exception:" + e.toString() + "\n");
				var line:Int = funky.interp.posInfos().lineNumber;
				ui.codeArea.textPage.select(0, 666666, line, line);
				// trace(e.stack);
			}
		}
	}
	
}