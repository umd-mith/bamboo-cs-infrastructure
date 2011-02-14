Utukku.namespace('Engine');

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
 
          while(v >= stop) {
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

          while(v <= stop) {
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

  Engine.TagLib = function(ns) {
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
          return Utukku.Engine.MapIterator(
            Utukku.Engine.UnionIterator(args),
            mappings[name]
          );
        }
        else {
          return Utukku.Engine.MapIterator( args, mappings[name] );
        }
      }
      else if( name in reductions ) {
        if( $.isArray(args) ) {
          return Utukku.Engine.ReductionIterator(
            Utukku.Engine.UnionIterator(args),
            reductions[name]
          );
        }
        else {
          return Utukku.Engine.ReductionIterator( args, reductions[name] );
        }
      }
      else if( name in consolidations ) {
        if( $.isArray(args) ) {
          return Utukku.Engine.ReductionIterator(
            Utukku.Engine.UnionIterator(args),
            consolidations[name]
          );
        }
        else {
          return Utukku.Engine.ReductionIterator( args, consolidations[name] );
        }
      }
      else if( name in functions ) {
        return functions[name](args);
      }
      else {
        return Utukku.Engine.NullIterator()
      }
    };

    return that;
  };

  Engine.RemoteLib = function(client, ns, config) {
    var that = { };

    if( ns in handlers ) {
      return handlers[ns];
    }


    that.function_to_iterator = function(name, args) {
      var iterators = { }, vars = [ ], expression;
      /* hook to client for remote functions */

      if( !$.isArray(args) ) { 
        args = [ args ];
      }

      console.log("function_to_iterator for remote function ", name, args);
      if( $.inArray(name, config.mappings) != -1 ) {
        if( args.length == 0 ) {
          return Engine.NullIterator();
        }
        else if( args.length == 1 ) {
          iterators.arg = args[0];
        }
        else {
          iterators.arg = Engine.UnionIterator(args);
        }
        vars = [ 'arg' ]
      }
      else {
        return Engine.NullIterator();
      }
      expression = 'x:' + name + '(';
      if( vars.length > 0 ) {
        expression = expression + '$';
        expression = expression + vars.join(", $");
      }
      expression = expression + ')';
      return Utukku.Client.FlowIterator(client, expression, { x: ns }, iterators);
    };

    handlers[ns] = that;

    console.log("Registering handler for ", ns, config);

    return that;
  };

  Engine.has_handler = function(ns) {
    return ( ns in handlers );
  };

})(jQuery, Utukku.Engine);
