package script;

import hscript.Parser;

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

		if (properties != null)
			for (k => v in properties) f.interp.variables.set(k, v);

		functions.set(f.name, f);
	}
	
	
	public function parse() {
		for (f in functions) parseFunction(f);
	}
	
	public function parseFunction(f:HscriptFunction) {

		// check all functions what is called inside the script
		for (fCall in functions) {
			var r = new EReg('[^\\w]${fCall.name}\\((.*?)\\)' ,"m"); // <-- TODO TODO TODO
			// var r = new EReg('[^\\w]${fCall.name}\\s*\\(' ,"m");
			if ( r.match(f.script) ) {
				var args = r.matched(1);
				trace('found ${fCall.name}($args) call inside of ${f.name}');
				f.interp.variables.set(fCall.name, fCall.run);
			}
		}

		f.parse();
	}


}