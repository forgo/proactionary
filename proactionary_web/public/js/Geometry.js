// Geometry Utilities for Page Elements

var Geometry = Geometry === undefined ? {} : Geometry;

Geometry = (function() {

    var TAU = 2 * Math.PI // Full Rotation [radians]

    return {
        position: function(element) {
            return { 
                top: element.getBoundingClientRect().top,
                left: element.getBoundingClientRect().left,
                bottom: element.getBoundingClientRect.bottom,
                right: element.getBoundingClientRect.right
            }
        },
        dimensions: function(element) {
            var width, height;
            if(element.getBoundingClientRect().width) {
                width = element.getBoundingClientRect().width;  // modern browsers
            }
            else {
                width = element.offsetWidth;    // old IE
            }

            if (element.getBoundingClientRect().height) {
                height = element.getBoundingClientRect().height; // modern browsers
            }
            else {
                height = element.offsetHeight;  // old IE
            }
            return {width: width, height: height};
        }
    };
})();

