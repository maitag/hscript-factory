package script;

import hscript.Parser;

class HscriptFarm {

	public static var parser(get, null):Parser = null;
	static function get_parser():Parser {
		if (parser == null) parser = new hscript.Parser();
		return parser;
	}
	
	var objects = new Map<String, HscriptObject>();

	public function new() {
	}

	public function addObject(obj:HscriptObject) {
		objects.set(obj.name, obj);
	}

	// Main-Object ?

	// TODO: copy/clone, load/save


}