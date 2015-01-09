//this is a tiny helper method for making JSON Http Requests
//if you want a more comprehensive solution, write it yourself
//
//the callback function will receive two arguments: the response,
// parsed as JSON, and the xhr object used inside jhr, with an added
// responseJSON property (you can probably guess what it is)
//
//this always sends a POST request, and the data is always serialized to JSON
//
//returns the xhr object used
var JHR = function ( url, data, fun ) {
	var xhr = new XMLHttpRequest();
	xhr.responseJSON = null;
	
	xhr.open( 'POST', url );
	xhr.setRequestHeader( 'Content-Type', 'application/json' );
	
	xhr.addEventListener( 'load',  function () {

		// alert(xhr.responseText);

		xhr.responseJSON = JSON.parse( xhr.responseText );
		fun( xhr.responseJSON, xhr );
	});

	xhr.send( JSON.stringify(data) );
	
	return xhr;
};

function isObject(obj) {
	return (typeof(obj) === "object");
}

function isHash(obj) {
	if (isObject(obj) && !Array.isArray(obj)) {
		for(var i in obj) {
			return true;
		}
	}
}

function encodeParam(key,value,acc) {
	x = (encodeURIComponent(key) + "=" + encodeURIComponent(value));
	return [].concat(acc,x);
}


var ccc = 0;

function traverseParams(obj, lastkey, fxn, acc) {
	var nextkey = null;
	for(var key in obj) {
		var value = obj[key];
		if(Array.isArray(obj)) { nextkey = (lastkey == null) ? key : lastkey+"[]"; }
		else if(isHash(obj)) { nextkey = (lastkey == null) ? key : lastkey+"["+key+"]"; }
		else { nextkey = (lastkey == null) ? key : lastkey; }

		if(isObject(value) && value !== null) {
			acc = traverseParams(value, nextkey, fxn, acc);
		
		}
		else {
			acc = fxn.apply(undefined, [nextkey, value, acc]);
		}
	}
	return acc;
}

var JHRGet = function ( url, params, fun ) {
	var xhr = new XMLHttpRequest();
	xhr.responseJSON = null;


	//var test = {"1": [10,20, {"a":"art","b":["bam","bang",{"list":["co","ca"]}]}], "2":3.14, "3":"yup" };

	var queries = traverseParams(params, null, encodeParam, []);
	var urlWithQuery = url + "?" + queries.join("&");
	// alert(urlWithQuery);
	xhr.open( 'GET', urlWithQuery );
	
	xhr.addEventListener( 'load',  function () {

		xhr.responseJSON = JSON.parse( xhr.responseText );
		fun( xhr.responseJSON, xhr );
	});

	xhr.send();
	
	return xhr;
};

//compatibility: anything supporting XMLHttpRequest2 http://caniuse.com/xhr2
