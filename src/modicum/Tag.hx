package modicum;

import js.Syntax;
import js.html.Element;
import modicum.View.ViewProps;

using modicum.DomTools;

/**
 * Defines a custom HTML tag
 */
class Tag {

	public function new(name:String, ?props:ViewProps,
						?didInit:(View)->Void, ?willDispose:(View)->Void) {
		this.name = name;
		this.props = props;
		this.didInit = didInit;
		this.willDispose = willDispose;
		ids = new Map();
		instances = new Map();
        var f1 = connectedCallback;
        var f2 = disconnectedCallback;
        Syntax.code('customElements.define({0}, class extends HTMLElement {
			connectedCallback() {f1(this)}
			disconnectedCallback() {f2(this)}
		})', name);
	}

	public function get(id:String) {
		return ids.get(id);
	}

	// ===================================================================================
	// private
	// ===================================================================================
	static inline var NR_PROP = '_tag_instance_nr';
	static var nextNr = 0;
	var name: String;
	var props: ViewProps;
	var didInit: (View)->Void;
	var willDispose: (View)->Void;
	var ids: Map<String, TagView>;
	var instances: Map<Int, TagView>;

	function connectedCallback(e:Element) {
		var id = e.id;
		var nr = nextNr++;
		var view = new TagView(e, props);
		id != null && id != '' ? ids.set(id, view) : null;
		Reflect.setProperty(e, NR_PROP, nr);
		instances.set(nr, view);
		didInit != null ? didInit(view) : null;
	}

	function disconnectedCallback(e:Element) {
		var nr:Int = Reflect.getProperty(e, NR_PROP);
		willDispose != null ? willDispose(instances.get(nr)) : null;
		e.id != null && e.id != '' ? ids.remove(e.id) : null;
		instances.remove(nr);
	}

}

// =======================================================================================
// TagView
// =======================================================================================

class TagView extends View {

	public function new(e:Element, ?props) {
		this.dom = e;
		super(null, props);
	}
	
	// ===================================================================================
	// private
	// ===================================================================================

	override function makeDom(): Element {
		props.markup != null ? dom.innerHTML = props.markup : null;
		return dom;
	}

}
