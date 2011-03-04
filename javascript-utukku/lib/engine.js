Utukku.namespace('Engine');

(function($, Engine) {
  /*
   * iterator = Utukku.Engine.ConstantIterator([ values ... ]);
   * f = iterator.async({
   *       next: function(v) { },
   *       done: function()  { }
   *     });
   * f();
   */
  Engine.ConstantIterator = function(values) {
    var that = { is_iterator: true };

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

  /*
   * iterator = Utukku.Engine.ConstantRangeIterator(first, last);
   */
  Engine.ConstantRangeIterator = function(start, stop) {
    var that = { is_iterator: true };

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

  /*
   * iterator = Utukku.Engine.NullIterator();
   */
  Engine.NullIterator = function() {
    var that = { is_iterator: true };

    that.async = function(callbacks) {
      return function() {
        callbacks.done();
      };
    };

    return that;
  };

  /*
   * iterator = Utukku.Engine.MapIterator(iterator, mapping);
   */
  Engine.MapIterator = function(iterator, mapping) {
    var that = { is_iterator: true };

    that.async = function(callbacks) {
      var next = callbacks['next'] || function(v) { },
          done = callbacks['done'] || function() { };
      return iterator.async({
        next: function(v) {
          next(mapping(v));
        },
        done: done
      });
    }

    return that;
  };

  var handlers = { };

  /*
   * my_lib = Utukku.Engine.TagLib(namespace);
   *
   * my_lib.mapping(name, function(v) { ... });
   *
   * my_lib.reduction(name, { 
   *          init: function() { },
   *          next: function(pad, v) { },
   *          finish: function(pad) { }
   *        });
   *
   * my_lib.consolidation(name, { 
   *          init: function() { },
   *          next: function(pad, v) { },
   *          finish: function(pad) { }
   *        });
   *
   * my_lib.function(name, function(args) { ... });
   *
   * my_lib.function_to_iterator(name, args);
   */
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

  /*
   * Utukku.Engine.RemoteLib(client, namespace, configuration);
   *
   * N.B.: this is used by the client to process the registered namespaces
   *       returned by the server.
   */
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
      else if( $.inArray(name, config.functions) != -1 ) {
        $.each(args, function(idx, arg) {
          vars.push("arg_" + idx);
          iterators["arg_" + idx] = arg;
        });
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

    return that;
  };

  /*
   * Utukku.Engine.has_handler(namespace)
   *
   * Returns true if a handler is registered for the namespace
   */
  Engine.has_handler = function(ns) {
    return ( ns in handlers );
  };

})(jQuery, Utukku.Engine);
