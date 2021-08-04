package modicum.core;

#if server
	import htmlparser.HtmlDocument;
	import htmlparser.HtmlNodeElement;
	import htmlparser.HtmlNodeText;
	import htmlparser.HtmlNode;
	typedef DomDocument = HtmlDocument;
	typedef DomElement = HtmlNodeElement;
	typedef DomText = HtmlNodeText;
	typedef DomNode = HtmlNode;
#else
	import js.Browser;
	import js.html.Document;
	import js.html.Element;
	import js.html.Node;
	typedef DomDocument = Document;
	typedef DomElement = Element;
	typedef DomText = Node;
	typedef DomNode = Node;
#end

class DomTools {

	public static function getDefaultDoc(): DomDocument {
#if server
		return new HtmlDocument('<html><head></head><body></body></html>');
#else
		return Browser.document;
#end
	}

	public static function domRoot(d:DomDocument): DomElement {
#if server
		return d.children[0];
#else
		return null;//TODO
#end
	}

	public static function domBody(d:DomDocument) {
#if server
		var res = d.find('body');
		return (res.length > 0 ? res[0] : null);
#else
		return d.body;
#end
	}

	public static function domHead(d:DomDocument) {
#if server
		var res = d.find('head');
		return (res.length > 0 ? res[0] : null);
#else
		return d.head;
#end
	}

	public static inline function domOwnerDocument(e:DomElement): DomDocument {
#if server
		return null;
#else
		return e.ownerDocument;
#end
	}

	public static inline function domCreateElement(doc:DomDocument,
												   tag:String): DomElement {
#if server
		return new HtmlNodeElement(tag, []);
#else
		return doc.createElement(tag);
#end
	}

	public static inline function domCreateNode(doc:DomDocument,
												s:String): DomNode {
#if server
		return new HtmlNodeText(s);
#else
		return doc.createTextNode(s);
#end
	}

	public static inline function domAppend(p:DomElement, child:DomNode, ?before:DomNode) {
#if server
		p.addChild(child, before);
#else
		before == null ? p.appendChild(child) : p.insertBefore(child, before);
#end
	}

	public static inline function domFirstElementChild(e:DomElement): DomElement {
#if server
		return e.children.length > 0 ? e.children[0] : null;
#else
		return e.firstElementChild;
#end
	}

	public static inline function domMapChildren(e:DomElement, f:(DomNode)->Bool) {
#if server
		for (n in e.nodes) if (!f(cast n)) break;
#else
		for (n in e.childNodes) if (!f(n)) break;
#end
	}

	public static function domTagname(e:DomElement): String {
#if server
		return e.name;
#else
		return e.tagName;
#end
	}
	
	public static inline function domSetAttr(e:DomElement, k:String, ?v:String) {
#if server
		v != null ? e.setAttribute(k, v) : e.removeAttribute(k);
#else
		v != null ? e.setAttribute(k, v) : e.removeAttribute(k);
#end
	}

	public static inline function domSetAttr2(e:DomElement, k:String, ?v:String) {
#if server
		e.setAttribute(k, v);
#else
		e.setAttribute(k, v);
#end
	}

	public static inline function domGetAttr(e:DomElement, k:String): String {
#if server
		return e.getAttribute(k);
#else
		return e.getAttribute(k);
#end
	}
		
	public static inline function domMapAttributes(e:DomElement, f:(String,String)->Bool) {
#if server
		for (a in e.attributes) if (!f(a.name, a.value)) break;
#else
		//TODO
#end
	}

	public static inline function domSetClass(e:DomElement, k:String, v:Bool) {
#if server
		//TODO
#else
		v ? e.classList.add(k) : e.classList.remove(k);
#end
	}

	public static inline function domSetInnerHTML(e:DomElement, v:String) {
#if server
		//TODO
#else
		e.innerHTML = v;
#end		
	}

	public static inline function domGetValue(n:DomText): String {
#if server
		return n.text;
#else
		return n.nodeValue;
#end
	}

	public static inline function domSetValue(n:DomText, v:String) {
#if server
		n.text = v;
#else
		n.nodeValue = v;
#end
	}

	public static inline function domCleanMarkup(markup:String): String {
		return ~/\n\s+/g.replace(markup, '\n');
	}

}
