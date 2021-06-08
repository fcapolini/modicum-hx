package modicum;

import haxe.Json;
import haxe.Http;

interface DataConsumer {
	function setData(d:Dynamic, ?useDatapath:Bool=true): Void;
	function setError(e:String): Void;
}

class Data<T> {
	var data: T;
	var consumers = new List<DataConsumer>();
	var request: Http;
	public var error: String;

	public function new(?d:T) {
		data = d;
	}

	public function addConsumer(c:DataConsumer, setData=true): Data<T> {
		consumers.add(c);
		setData ? c.setData(data) : null;
		return this;
	}

	public function removeConsumer(c:DataConsumer, setNull=false): Data<T> {
		consumers.remove(c);
		setNull ? c.setData(null) : null;
		return this;
	}

	public function setData(d:T): Data<T> {
		data = d;
		for (c in consumers) {
			c.setData(d);
		}
		return this;
	}

	public function trigger() {
		setData(data);
	}

	public function setError(error:String) {
		request = null;
		this.error = error;
		// for (view in views) {
		// 	view.setError(error);
		// }
	}

	public function httpGet(url:String) {
		cancelRequest();
		error = null;
		request = new Http(url);
		request.onData = (text:String) -> {
			request = null;
			try {
				setData(Json.parse(text));
			} catch (ex:Dynamic) {
				error = '$ex';
			}
		}
		request.onError = setError;
		request.request();
	}

	public function cancelRequest() {
		if (request != null) {
			request.cancel();
			request = null;
		}
	}

}
