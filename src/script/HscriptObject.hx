package script;

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
	
	public function parseFunction(f:HscriptFunction):Error {

		// check if a global propertie is used
		for (property => value in properties) {
			var r = new EReg('[^\\w.]$property\\b' ,"m");
			if ( r.match(f.script) ) {
				trace('found use of property "$property" inside of function "${f.name}"');
				f.interp.variables.set(property, value);
			}
		}

		// TODO: store per function what other functions is called
		// check all functions what is called inside the script
		for (fCall in functions) {
			var r = new EReg('[^\\w.]${fCall.name}\\s*\\((.*?)\\)' ,"s"); // <-- TODO: does not match if is at line-start
			// var r = new EReg('[^\\w.]${fCall.name}\\s*\\(' ,"s");
			if ( r.match(" "+f.script) ) {
				// trace(r.matchedRight()); // TODO: parse manually here to check the arguments
				var args = r.matched(1);
				trace('found "${fCall.name}($args)" call inside of function "${f.name}"');

				if (fCall.name != f.name) 
					f.interp.variables.set(fCall.name, fCall.run);
				else {
					trace("Recursive calls not tested yet.");
					//for recursive calls it use a new interpreter
					// TODO: detect also recursive calls over more then one function!
					f.interp.variables.set(fCall.name, fCall.runRecursive);
				}
			}
		}

		return f.parse();
	}


}