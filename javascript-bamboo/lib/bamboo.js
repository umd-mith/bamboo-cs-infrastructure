var Bamboo = Bamboo || {};

(function($, Bamboo) {
  if(window.console != undefined && window.console.log != undefined) {
    Bamboo.debug = function() {
      console.log(Array.prototype.slice.call(arguments));
    };
  }
  else {
    Bamboo.debug = function() { };
  }

  var genericNamespacer = function(base, nom) {
    if( typeof(base[nom]) == "undefined" ) {
      base[nom] = { };
      base[nom].namespace = function(nom2) {
        return genericNamespacer(base[nom], nom2);
      };
      base[nom].debug = Bamboo.debug;
    }

    return base[nom];
  };

  Bamboo.namespace = function(nom) {
    return genericNamespacer(Bamboo, nom);
  };
})(jQuery, Bamboo);
