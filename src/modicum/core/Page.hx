package modicum.core;

using modicum.core.DomTools;

class Page extends View {
	public var doc: DomDocument;
	public var head: View;
	public var body: View;
	
	public function new(?d:DomDocument, ?cb:Page->Void) {
		this.doc = d != null ? d : DomTools.getDefaultDoc();
		super(null, {dom: doc.domRoot()}, (p) -> {
			head = new View(p, {dom: doc.domHead()});
			body = new View(p, {dom: doc.domBody()});
			cb != null ? cb(this) : null;
		});
	}

}
