Bamboo.namespace('Engine');

(function($, Engine) {
  Engine.ConstantIterator = function(values) {
    var that = { };

    if($.isArray(values)) {
      that.async = function(callbacks) {
        return function() {
          callbacks.next(values);
          callbacks.done();
        };
      };
    }
    else {
      that.async = function(callbacks) {
        return function() {
          $.each(values, function(idx, v) {
            callbacks.next(v);
          });
          callbacks.done();
        };
      };
    }

    return that;
  };

  Engine.ConstantRangeIterator = function(start, stop) {
    var that = { };

    if( start > stop ) {
      that.async = function(callbacks) {
        return function() {
          var v = start;
 
          while(start >= stop) {
            callbacks.next(v);
            v -= 1;
          }
          callbacks.done();
        };
      };
    }
    else if( start < stop ) {
      that.async = function(callbacks) {
        return function() {
          var v = start;
 
          while(start <= stop) {
            callbacks.next(v);
            v += 1;
          }
          callbacks.done();
        };
      };
    }
    else {
      that.async = function(callbacks) {
        return function() {
          callbacks.next(start);
          callbacks.done();
        };
      };
    }

    return that;
  };

  Engine.NullIterator = function() {
    var that = { };

    that.async = function(callbacks) {
      return function() {
        callbacks.done();
      };
    };

    return that;
  };

  var handlers = { };

  Engine.TagLib = function(ns) = {
    var that = { }, mappings = { }, reductions = { }, consolidations = { },
        functions = { };

    if( ns in handlers ) {
      return handlers[ns];
    }

    handlers[ns] = that;

    that.mapping = function(name, fctn) {
      mappings[name] = fctn;
    };

    that.reduction = function(name, callbacks) {
      reductions[name] = callbacks;
    };

    that.consolidation = function(name, callbacks) {
      consolidations[name] = callbacks;
    };

    that.function = function(name, fctn) {
      functions[name] = fctn;
    };

    that.function_to_iterator = function(name, args) {
      if( name in mappings ) {
        if( $.isArray(args) ) {
          return Bamboo.Engine.MapIterator(
            Bamboo.Engine.UnionIterator(args),
            mappings[name]
          );
        }
        else {
          return Bamboo.Engine.MapIterator( args, mappings[name] );
        }
      }
      else if( name in reductions ) {
        if( $.isArray(args) ) {
          return Bamboo.Engine.ReductionIterator(
            Bamboo.Engine.UnionIterator(args),
            reductions[name]
          );
        }
        else {
          return Bamboo.Engine.ReductionIterator( args, reductions[name] );
        }
      }
      else if( name in consolidations ) {
        if( $.isArray(args) ) {
          return Bamboo.Engine.ReductionIterator(
            Bamboo.Engine.UnionIterator(args),
            consolidations[name]
          );
        }
        else {
          return Bamboo.Engine.ReductionIterator( args, consolidations[name] );
        }
      }
      else if( name in functions ) {
        return functions[name](args);
      }
      else {
        return Bamboo.Engine.NullIterator()
      }
    };

    return that;
  };

  Engine.RemoteLib = function(client, ns, config) {
    var that = { };

    that.function_to_iterator = function(name, args) {
      /* hook to client for remote functions */
    };

    return that;
  };

})(jQuery, Bamboo.Engine);
