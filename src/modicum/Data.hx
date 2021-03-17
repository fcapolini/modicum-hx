package modicum;

interface DataConsumer {
	function setData(d:Dynamic, ?useDatapath:Bool=true): Void;
}

class Data {
	var data: Dynamic;
	var consumers = new List<DataConsumer>();

	public function new(d:Dynamic) {
		data = d;
	}

	public function setData(d:Dynamic) {
		data = d;
		for (c in consumers) {
			c.setData(d);
		}
	}

	public function addConsumer(c:DataConsumer, setData=true) {
		consumers.add(c);
		setData ? c.setData(data) : null;
	}

	public function removeConsumer(c:DataConsumer, setNull=false) {
		consumers.remove(c);
		setNull ? c.setData(null) : null;
	}

}
