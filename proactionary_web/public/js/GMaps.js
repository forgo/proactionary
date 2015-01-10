//-------------------------------------------------------------------------------
// PROACTIONARY.COM
//-------------------------------------------------------------------------------
// GMaps.js
// ------------------------------------------------------------------------------
// Author: Elliott Richerson
// Created: July 20, 2014
// Modified: July 20, 2014
// ------------------------------------------------------------------------------
// Google Map Utility

var GMaps = GMaps === undefined ? {} : GMaps;

GMaps = (function() {

	 // Google Map Javascript API V3
    var map;
    var mybox;
    var marker;
    var rangeCircle;
    var rangeRectangle;
    var eventMarkers;

    function createMarkerForPoint(point) {

        return new google.maps.Marker({
            position: point
        });
    }

    function reorientOnMarker(range,events) {
        if(marker) {
            if(rangeCircle) {
                rangeCircle.setMap(null);
            }
            if(rangeRectangle) {
                rangeRectangle.setMap(null);
            }
            // Convert range form miles to meters for Google API units
            range_meters = range * 1609.34;

            // Create New Range Circle Around Marker
            // var circleOptions = {
            //     strokeColor: '#298FD9',
            //     strokeOpacity: 0.8,
            //     strokeWeight: 2,
            //     fillColor: '#298FD9',
            //     fillOpacity: 0.25,
            //     map: map,
            //     center: marker.position,
            //     radius: range_meters,
            //     clickable: false
            // };
            var rectangleOptions = {
                strokeColor: '#298FD9',
                strokeOpacity: 0.8,
                strokeWeight: 2,
                fillColor: '#298FD9',
                fillOpacity: 0.25,
                map: map,
                bounds: mybox,
                clickable: false
            };
            rangeRectangle = new google.maps.Rectangle(rectangleOptions);
            // rangeCircle = new google.maps.Circle(circleOptions);

            map.panTo(marker.getPosition());
        }

        // Clear Existing Event Markers, If There Are Any
        if (eventMarkers) {
            for (i = 0; i < eventMarkers.length; i++) { 
                eventMarkers[i].setMap(null);
            }
        }
        else {
            eventMarkers = [];
        }

        // Iterate Over the Passed In Events, an Create New Markers for Each
        n_markers = 0;
        if(events) {
            for (i = 0; i < events.length; i++) {
                if (events[i]["show_marker"]) {
                    var pos = {lat: parseFloat(events[i]["latitude"]), lng: parseFloat(events[i]["longitude"])};
                    eventMarkers[n_markers++] = new google.maps.Marker({
                        title: events[i]["name"],
                        icon: {
                            path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW,
                            strokeColor: "green",
                            scale: 3
                        },
                        position: pos,
                        map: map
                    });
                }

            }
        }
    }

    function placeMarker(location, range) {

        // If Marker Already Exists, Remove it From the Map
        if(marker) {
            marker.setMap(null);
        }

        // If Range Circle Already Exists, Remove it From the Map
        if(rangeCircle) {
            rangeCircle.setMap(null);
        }
        if(rangeRectangle) {
            rangeRectangle.setMap(null);
        }

        // Create a New Marker Where the User Clicked
        marker = new google.maps.Marker({
            position: location, 
            map: map
        });

        reorientOnMarker(range, null);
    }

    function createBoundsForMarkers(markers) {

        var mapBounds = new google.maps.LatLngBounds();

        for (var i = markers.length - 1; i >= 0; i--) {

            mapBounds.extend(markers[i].getPosition());
        
        };
        return mapBounds;
    }


    function getBoundsZoomLevel(bounds) {

        var mapID = 'map-canvas';
        var mapDiv = document.getElementById(mapID);

        var mapDim = Geometry.dimensions(mapDiv);

        var WORLD_DIM = { height: 256, width: 256 };
        var ZOOM_MAX = 21;

        function latRad(lat) {
            var sin = Math.sin(lat * Math.PI / 180);
            var radX2 = Math.log((1 + sin) / (1 - sin)) / 2;
            return Math.max(Math.min(radX2, Math.PI), -Math.PI) / 2;
        }

        function zoom(mapPx, worldPx, fraction) {
            return Math.floor(Math.log(mapPx / worldPx / fraction) / Math.LN2);
        }

        var ne = bounds.getNorthEast();
        var sw = bounds.getSouthWest();

        var latFraction = (latRad(ne.lat()) - latRad(sw.lat())) / Math.PI;
        
        var lngDiff = ne.lng() - sw.lng();
        var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;
        
        var latZoom = zoom(mapDim.height, WORLD_DIM.height, latFraction);
        var lngZoom = zoom(mapDim.width, WORLD_DIM.width, lngFraction);

        return Math.min(latZoom, lngZoom, ZOOM_MAX);
    }

	function ready()
    {
        // Google Maps Loaded Asynchronously, Now Run Event Default Filter
        Events.update();
    }

    return {

    	load: function() {
    		var script_id = "gmaps-script";
    		// Map Exists, So Let's Configure It
    		if (document.getElementById(script_id)) {
    			ready();
    		}
    		// Map Does Not Exist, Attach Script, and Configure In Callback
    		else {
    			var script = document.createElement('script');
    			script.setAttribute('id', script_id);
    			script.type = 'text/javascript';
    			script.src = 'https://maps.googleapis.com/maps/api/js?'+
                             'key=AIzaSyCvlKD1fzzo11fNeJf6Lh8Ohxx1Hy__jnc&'+
                             'v=3.exp&'+
                			 'callback=GMaps.load';
                document.body.appendChild(script);
    		}
    	},
    	frameAndCenter: function(min, max, center, range) {


            mybox = new google.maps.LatLngBounds(
                    new google.maps.LatLng(min["lat"], min["lng"]),
                    new google.maps.LatLng(max["lat"], max["lng"]));

    		var points = [min,max];
	        var markers = [];

	        for (var i = points.length - 1; i >= 0; i--) {
	            markers.push(createMarkerForPoint(points[i]));
	        };

	        var bounds = (markers.length > 0) ? createBoundsForMarkers(markers) : null;

            var mapID = 'map-canvas';
            var mapDiv = document.getElementById(mapID);

            var mapOptions = {
                zoom: (bounds) ? getBoundsZoomLevel(bounds) : 0,
                center: (bounds) ? bounds.getCenter() : {lat: 0.0, lng: 0.0},
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            if(!map) {
                map = new google.maps.Map(mapDiv, mapOptions);

                // Create Initial Marker on Center
                placeMarker(mapOptions["center"], range);

                google.maps.event.addListener(map, 'click', function(event) {
                    placeMarker(event.latLng, range);
                    Events.mapClick({"lat":event.latLng.lat(), "lng":event.latLng.lng()}, range);
                });
            }
            else {
                map.setOptions(mapOptions);
            }


    	},
        reorientOnMarker: function(range,events) {
            reorientOnMarker(range,events);
        },
    	invalidCoordinates: function(coordinates) {
	    	if(coordinates.length == 0) {
	    		return true;
	    	}

	        for (var i = coordinates.length - 1; i >= 0; i--) {
	            if (coordinates[i] == undefined || coordinates[i] == "") {
	            	return true
	            }
	        };
	        return false;
    	}
    };

})();