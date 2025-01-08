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
	
	@:access(hscript.Interp)
	public function parseFunction(hscriptFunction:HscriptFunction):Error {

		var err:Error = hscriptFunction.parse();
		
		// postprocessing the expr-AST if to set interpreter-variables
		// if the script contains a property or a function of this HscriptObject:
		if (err == null) {
			// reset variables to celar up old "#function"-keys
			hscriptFunction.interp.resetVariables();

			// interp.variables.set("Math",Math); // share the Math class

			// checkECalls(hscriptFunction, hscriptFunction.expr);
			checkForIdentifiers(hscriptFunction, hscriptFunction.expr);
		}

		return err;
	}


	function checkECalls(hscriptFunction:HscriptFunction,e:Expr):Void {
		switch( Tools.expr(e) )
		{
			// ----- PROPERTY -------
			case EIdent(n):
				trace("found identifier", n);
				var p = properties.get(n);
				if (p != null) {
					trace('found identifier "$n" -> is a HscriptObject property');
					hscriptFunction.interp.variables.set(n, p);
				}

			// ----- NEW --------
			case ENew(n, e):
				trace('found new $n', e);
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

					case EField(e,_): checkECalls(hscriptFunction, e);
					default:
				}				

				// traverse arguments recursive
				// TODO: check also that arguments match!
				for( a in args ) {
					// trace(a);
					checkECalls(hscriptFunction, a);
				}
			
			// ----------------------
			default: Tools.iter(e, checkECalls.bind(hscriptFunction));
		}
	}

	function checkForIdentifiers(hscriptFunction:HscriptFunction, e : Expr ) {
		var f:Expr -> Void = checkForIdentifiers.bind(hscriptFunction); // ;)
		switch( Tools.expr(e) ) {
		case EConst(_):

		case EIdent(e): _check(hscriptFunction, e);  // <-- HERE

		case EVar(_, _, e): if( e != null ) f(e);
		case EParent(e): f(e);
		case EBlock(el): for( e in el ) f(e);
		case EField(e, _): f(e);
		case EBinop(_, e1, e2): f(e1); f(e2);
		case EUnop(_, _, e): f(e);
		case ECall(e, args): f(e); for( a in args ) f(a);
		case EIf(c, e1, e2): f(c); f(e1); if( e2 != null ) f(e2);
		case EWhile(c, e): f(c); f(e);
		case EDoWhile(c, e): f(c); f(e);
		case EFor(_, it, e): f(it); f(e);
		case EBreak,EContinue:
		case EFunction(_, e, _, _): f(e);
		case EReturn(e): if( e != null ) f(e);
		case EArray(e, i): f(e); f(i);
		case EArrayDecl(el): for( e in el ) f(e);

		case ENew(e, el): _check(hscriptFunction, e); for( e in el ) f(e); // <-- HERE

		case EThrow(e): f(e);
		case ETry(e, _, _, c): f(e); f(c);
		case EObject(fl): for( fi in fl ) f(fi.e);
		case ETernary(c, e1, e2): f(c); f(e1); f(e2);
		case ESwitch(e, cases, def):
			f(e);
			for( c in cases ) {
				for( v in c.values ) f(v);
				f(c.expr);
			}
			if( def != null ) f(def);
		case EMeta(name, args, e): if( args != null ) for( a in args ) f(a); f(e);
		case ECheckType(e,_): f(e);
		}
	}

	function _check(hscriptFunction:HscriptFunction, n:String) {

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

	}

}