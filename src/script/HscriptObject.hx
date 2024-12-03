package script;

import hscript.Expr;
import hscript.Tools;
import hscript.Expr.Error;

class HscriptObject {

	public var name(default, null):String;
	public var properties:Map<String,Dynamic> = null;

	public var functions:Map<String, HscriptFunction> = null;

	public function new(name:String, ?properties:Map<String,Dynamic>) {
		this.name = name;
		this.properties = properties;
	}

	public function addFunction(f:HscriptFunction) {

		if (functions == null) functions = new Map<String, HscriptFunction>();

		functions.set(f.name, f);
	}
	
	
	public function parse() {
		for (f in functions) {
			parseFunction(f);
		}
	}
	
	public function parseFunction(hscriptFunction:HscriptFunction):Error {

		/*
		// check if a global propertie is used
		for (property => value in properties) {
			var r = new EReg('[^\\w.]$property\\b' ,"m");
			var r1 = new EReg('^$property\\b' ,"m");
			if ( r.match(hscriptFunction.script) || r1.match(hscriptFunction.script) ) {
				trace('found use of property "$property" inside of function "${hscriptFunction.name}"');
				hscriptFunction.interp.variables.set(property, value);
			}
		}

		// check all functions what is called inside the script
		for (fCall in functions) {
			var r = new EReg('[^\\w.]${fCall.name}\\s*\\((.*?)\\)' ,"s"); // <-- TODO: does not match if is at line-start
			var r1 = new EReg('^${fCall.name}\\s*\\((.*?)\\)' ,"s"); // <-- TODO: does not match if is at line-start
			// var r = new EReg('[^\\w.]${fCall.name}\\s*\\(' ,"s");
			if ( r.match(" "+hscriptFunction.script) || r1.match(" "+hscriptFunction.script) ) {
				// trace(r.matchedRight()); // TODO: parse manually here to check the arguments
				var args = r.matched(1);
				trace('found "${fCall.name}($args)" call inside of function "${hscriptFunction.name}"');

				if (fCall.name != hscriptFunction.name) 
					hscriptFunction.interp.variables.set(fCall.name, fCall.run);
				else {
					//for recursive calls it use a new interpreter
					// TODO: detect also recursive calls over more then one function!
					hscriptFunction.interp.variables.set(fCall.name, fCall.runRecursive);
				}
			}
		}
		*/

		var err:Error = hscriptFunction.parse();
		
		// postprocessing the expr-AST if to set interpreter-variables
		// if the script contains a property or a function of this HscriptObject:
		if (err == null) checkECalls(hscriptFunction, hscriptFunction.expr);

		return err;
	}


	function checkECalls(hscriptFunction:HscriptFunction,e:Expr):Void {
		switch( Tools.expr(e) )
		{
			// ----- PROPERTY -------
			case EIdent(n):
				//trace("found identifier", n);
				var p = properties.get(n);
				if (p != null) {
					trace('found identifier "$n" -> is a HscriptObject property');
					hscriptFunction.interp.variables.set(n, p);
				}

			// ----- FUNCTION CALL -------
			case ECall(e, args):
				// trace("found function call", e);
				switch (Tools.expr(e)) {
					case EIdent(n):

						var p = properties.get(n); // check for properties as functions (TODO: make this better separate)
						if (p != null) 
						{
							trace('found identifier "$n" -> is a HscriptObject property (function call)');
							hscriptFunction.interp.variables.set(n, p);
						}
						else // check for functions
						{
							var f = functions.get(n);
							if (f != null) {
								trace('found identifier "$n" -> is a HscriptObject function');

								// TODO: store per function what other functions is called		

								if (n != hscriptFunction.name) hscriptFunction.interp.variables.set(n, f.run);
								else hscriptFunction.interp.variables.set(n, f.runRecursive);
							}
						}
					default:
				}				

				// traverse arguments recursive
				// TODO: check also that arguments match!
				for( a in args ) {
					trace(a);
					checkECalls(hscriptFunction, a);
				}
			
			// ----------------------
			default: Tools.iter(e, checkECalls.bind(hscriptFunction));
		}
	}

}