package script;

import hscript.Expr;
import hscript.Expr.Error;
import hscript.Interp;

@:allow(script)
class HscriptFunction {

	public var name(default, null):String;
	public var params:Map<String,Dynamic>;
	public var script:String;

	public var expr:Expr;
	public var interp:Interp;

	public function new(name:String, params:Map<String,Dynamic>, script:String) {
		this.name = name;
		this.params = params;
		this.script = script;
		
		interp = new Interp();
	}

	function parse():Error {
		HscriptFarm.parser.line = 0;
		try	expr = HscriptFarm.parser.parseString(script)
		catch (e:Error) return(e);
		return null;
	}

	public function run(?p:Map<String,Dynamic>):Dynamic {
		// use given function parameters p or the default value from params
		if (p != null) {
			for (k => v in params) {
				if ( p.exists(k) ) interp.variables.set(k, p.get(k));
				else interp.variables.set(k, v);
			}
		}
		else for (k => v in params) interp.variables.set(k, v);
		
		return interp.execute(expr);
	}

	public function runRecursive(?p:Map<String,Dynamic>):Dynamic {

		var newInterp = new Interp();
		newInterp.variables = interp.variables.copy();

		// use given function parameters p or the default value from params
		if (p != null) {
			for (k => v in params) {
				if ( p.exists(k) ) newInterp.variables.set(k, p.get(k));
				else newInterp.variables.set(k, v);
			}
		}
		else for (k => v in params) newInterp.variables.set(k, v);
		
		return newInterp.execute(expr);
	}
}