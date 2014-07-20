
var Proactionary = Proactionary === undefined ? {} : Proactionary;

Proactionary = (function() {


    function start() {
        alert("hello, proactionary");
    }

    return {
        hello: start
    };

})();