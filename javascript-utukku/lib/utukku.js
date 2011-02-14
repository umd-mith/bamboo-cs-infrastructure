var Utukku = Utukku || {};


(function($, Utukku) {
  if(window.console != undefined && window.console.log != undefined) {
    Utukku.debug = function() {
      console.log(Array.prototype.slice.call(arguments));
    };
  }
  else {
    Utukku.debug = function() { };
  }

  var genericNamespacer = function(base, nom) {
    if( typeof(base[nom]) == "undefined" ) {
      base[nom] = { };
      base[nom].namespace = function(nom2) {
        return genericNamespacer(base[nom], nom2);
      };
      base[nom].debug = Utukku.debug;
    }

    return base[nom];
  };

  Utukku.namespace = function(nom) {
    return genericNamespacer(Utukku, nom);
  };
})(jQuery, Utukku);
