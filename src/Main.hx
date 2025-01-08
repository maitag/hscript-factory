package;

import lime.app.Application;
import lime.ui.Window;

import haxe.Exception;
import hscript.Expr.Error;
import hscript.Expr.ErrorDef;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

import ui.Ui;
import script.HscriptFarm;
import script.HscriptFunction;
import script.HscriptObject;

class Main extends Application
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
	
	public var object:HscriptObject;
	public var funky:HscriptFunction; // little hack to make it testable still at NOW

	public function onUIInit() 
	{
		// -------------- Farmers joy --------------------

		var farm = new HscriptFarm();

		funky = new HscriptFunction("funky", ["p" => 3],
'//trace("hello world", globalState);
log(p);
if (p>0) funky(["p"=>p-1]); // <- recursive call
return "end";
'
		);
		
		ui.codeArea.textPage.text = funky.script;
		ui.codeArea.textPage.xOffset = ui.codeArea.textPage.yOffset = 0;
		ui.codeArea.textPage.updateLayout();

		object = new HscriptObject("test", [
				"globalState" => 43,
				"Math" => Math,
				"log" => ui.logArea.log,
				"stamp" => haxe.Timer.stamp,
				"Timer" => haxe.Timer
			]);
		object.addFunction(funky);
	}	

	public function onRun()
	{	
		funky.script = ui.codeArea.textPage.text;
		
		
		var e = object.parseFunction(funky);
		// trace(funky.expr);
		
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

		// trace(funky.interp.variables);

	}
	
}