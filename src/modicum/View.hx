package modicum;

import modicum.Data.DataConsumer;
using modicum.DomTools;

typedef ViewProps = {
	?dom: DomElement,
	?markup: String,
	?plug: String,
	?datapath: (View, Dynamic)->Dynamic,
	?ondata: (View, Dynamic)->Void,
	?childrendata: (View, Dynamic)->Dynamic,
}

class View implements DataConsumer {
	public var parent(default,null): View;
	public var root(default,null): View;
	public var children(default,null): Array<View>;
	public var dom(default,null): DomElement;
	public var userdata: Dynamic;

	public static function getBody(): View {
		return body;
	}

	//TODO: willDispose when unlinked
	public function new(parent:View, props:ViewProps, ?didInit:(View)->Void, ?cloneOf:View) {
		this.parent = parent;
		this.root = parent != null
			? parent.root
			: (cloneOf != null ? cloneOf.root : this);
		this.props = props;
		this.didInit = didInit;
		this.cloneOf = cloneOf;
		this.children = [];
		dom = makeDom();
		init();
		link();
		didInit != null ? didInit(this) : null;
	}

	public function dispose() {
		for (child in children) {
			child.dispose();
		}
		unlink();
	}

	public inline function getId(): String {
		return dom.domGetAttr('id');
	}

	public inline function setId(id:String) {
		dom.domSetAttr('id', id);
	}

	public inline function setNode(aka:String, text:String) {
		cast(nodes.get(aka), DomText).domSetValue(text);
	}

	public inline function getElement(aka:String): DomElement {
		return cast nodes.get(aka);
	}

	public function setData(d:Dynamic, ?useDatapath:Bool=true) {
		useDatapath && props.datapath != null ? d = props.datapath(this, d) : null;
		if (Std.is(d, Array)) {
			setArray(cast d);
		} else if (d != null) {
			dom.domSetClass('hidden', false);
			props.ondata != null ? props.ondata(this, d) : null;
			props.childrendata != null ? d = props.childrendata(this, d) : null;
			for (child in children) {
				child.setData(d);
			}
		} else {
			dom.domSetClass('hidden', true);
			clearClones();
		}
	}

	public function setDataRange(start:Int, ?end:Int) {
		rangeStart = start;
		rangeEnd = end;
		rangeData != null ? setArray(rangeData) : null;
	}

	public function setError(e:String) {
	}

	// =========================================================================
	// private
	// =========================================================================
	static var NODE_RE = ~/\[\[(\w+)\]\]/;
	static var body = new View(null, {dom:DomTools.getDefaultDoc().domBody()});
	var props: ViewProps;
	var didInit: (View)->Void;
	var nodes: Map<String, DomNode>;

	function link() {
		if (parent != null) {
			var plug = props.plug != null ? props.plug : 'default';
			var pdom = parent.getElement(plug);
			if (cloneOf != null) {
				props.dom != null ? null : pdom.domAppend(dom, cloneOf.dom);
			} else {
				parent.children.push(this);
				props.dom != null ? null : pdom.domAppend(dom);
			}
		}
	}

	function unlink() {
		if (parent != null) {
			cloneOf != null ? null : parent.children.remove(this);
			dom.remove();
		}
	}

	function init() {
		nodes = new Map();
		collectNodes(dom);
		nodes.exists('default') ? null : nodes.set('default', dom);
		nodes.set('root', dom);
		if (props.ondata != null) {
			dom.domSetClass('hidden', true);
		}
	}

	function makeDom() {
		var ret: DomElement;
		if (props.dom != null) {
			ret = props.dom;
		} else if (props.markup != null) {
			var e = root.dom.domOwnerDocument().domCreateElement('div');
			e.innerHTML = ~/\n\s+/g.replace(props.markup, '\n');
			ret = e.domFirstElementChild();
		} else {
			ret = root.dom.domOwnerDocument().domCreateElement('div');
		}
		return ret;
	}

	function collectNodes(e:DomElement) {
		var aka = e.getAttribute('aka');
		if (aka != null) {
			e.domSetAttr('aka', null);
			nodes.set(aka, e);
		}
		e.domMapChildren((n) -> {
			if (Std.is(n, DomElement)) {
				collectNodes(cast n);
			} else if (Std.is(n, DomText)) {
				if (NODE_RE.match(cast(n, DomText).domGetValue())) {
					cast(n, DomText).domSetValue('');
					nodes.set(NODE_RE.matched(1), n);
				}
			}
			return true;
		});
	}

	// =========================================================================
	// replication
	// =========================================================================
	var rangeStart = 0;
	var rangeEnd = null;
	var rangeData: Array<Dynamic>;
	var cloneOf: View;
	var clones: Array<View>;

	/*
	Clones are Views whose cloneOf is set and they're only linked into
	the DOM, but not added to the View tree.
	Depending on array length:
	- if zero, only the original View exists and it's hidden
	- if one, only the original View exists, populated and visible
	- if more than one, the original View is the last element of the sequence
	*/
	function setArray(v:Array<Dynamic>) {
		rangeData = v;
		if (rangeStart != 0 || rangeEnd != null) {
			v = rangeEnd != null
				? v.slice(rangeStart, rangeEnd)
				: v.slice(rangeStart);
		}
		var count:Int = cast Math.max(v.length - 1, 0);
		clones != null ? null : clones = [];
		for (i in 0...count) {
			if (i >= clones.length) {
				clones.push(new View(parent, props, didInit, this));
			}
			clones[i].setData(v[i], false);
		}
		clearClones(count);
		setData(v.length > 0 ? v[v.length - 1] : null, false);
	}

	function clearClones(count=0) {
		if (clones != null) {
			while (clones.length > count) {
				clones.pop().unlink();
			}
		}
	}

}
