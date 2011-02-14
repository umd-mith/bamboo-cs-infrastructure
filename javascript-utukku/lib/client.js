Utukku.namespace('Client');

(function($, Client) {
  var connections = { };

  /* Client.Connection.url will be the default */

  Client.Connection = function(options) {
    var that = { }, onMessage, onOpen, onClose, connection, request_id, flows;

    request_id = 1;
    flows = { };

    that.options = options;
    if( !("url" in that.options) ) {
      that.options.url = Client.Connection.url;
    }
    
    if( options.url in connections ) {
      if( "onSuccess" in options ) {
        options.onSuccess(connections[options.url]);
      }
      return connections[options.url];
    }

    connections[options.url] = that;

    that.events = { };

    onMessage = function(msg) {
      console.debug(msg.data);
      msg = $.parseJSON(msg.data)
      if( msg.class == 'flow.namespaces.registered' ) {
        $.each(msg.data, function(ns, def) {
          console.debug(ns, def);
          Utukku.Engine.RemoteLib(that, ns, def);
        });
      }
      else if( msg.class == 'flow.produce' || msg.class == "flow.produced" ) {
        if( flows[msg.id] ) {
          flows[msg.id].message(msg.class, msg.data);
        }
      }
    };

    onOpen = function() {
console.log("Opened socket");
      if("onOpen" in that.options) {
        that.options.onOpen();
      }
    };

    onClose = function() {
console.log("Closed socket");
      if("onClose" in that.options) {
        that.options.onClose();
      }
    };

    if( "WebSocket" in window ) {
console.log("opening websocket");
      var ws = new WebSocket(that.options.url);
      ws.onopen = onOpen;
      ws.onmessage = onMessage;
      ws.onclose = onClose;
      connection = ws;
    }
    else {
      if("onError" in that.options) {
        that.options.onError();
      }
    }
    if( "onSuccess" in that.options ) {
      that.options.onSuccess(that);
    }

    that.request = function(class, data, id) {
      if($.type(id) == "null" || $.type(id) == "undefined") {
        id = Math.floor(Math.random()*123456789) + "-" + request_id;
        request_id += 1;
      }

      var c = JSON.stringify({ class:class, data:data, id:id });
console.log("sending: [", c, "]");
      ws.send(JSON.stringify({ class: class, data: data, id: id}));
      return id;
    };

    that.register_flow = function(flow) {
      flows[flow.id] = flow;
    };

    that.deregister_flow = function(flow) {
      flows[flow.id] = false;
    };

    return that;
  };

 /* options:
  *   url: server
  *   namespace:
  *   name:
  *   args:
  *   next:
  *   done:
  */
  Client.Function = function(options) {
    if(!("url" in options)) {
      options.url = Client.Connection.url;
    }
    Client.Connection({
      url: options.url,
      onSuccess: function(client) {
        var handler = Utukku.Engine.TagLib(options.namespace),
            iterator = handler.function_to_iterator(
                         options.name, options.args
                       );
        (iterator.async({
          next: options.next,
          done: options.done
        }))();
      }
    });
  };

  Client.FlowIterator = function(client, expression, namespaces, iterators) {
    var that = { };
    console.log("FlowIterator", client, expression, namespaces, iterators);
    
    that.async = function(callbacks) {
      var flow = Client.Flow(client, expression, namespaces, iterators, callbacks);
      return function() { flow.run() };
    }

    return that;
  };

  Client.Flow = function(client, expression, namespaces, iterators, callbacks) {
    var that = { }, iterator_list = [ ];

    $.each(iterators, function(key, v) {
      iterator_list.push(key);
    });

    that.id = client.request('flow.create', {
      expression: expression,
      iterators: iterator_list,
      namespaces: namespaces
    });

    client.register_flow(that);

    that.message = function(class, data) {
      if( class == 'flow.produce' ) {
        $.each(data.items, function(idx, v) { callbacks.next(v); });
      }
      else if( class == 'flow.produced' ) {
        callbacks.done();
      }
    };

    that.terminate = function() {
      callbacks.done();
      client.request('flow.close', {}, that.id);
      client.deregister_flow(that);
    };

    that.run = function() {
      $.each(iterators, function(key, val) {
        (val.async({
          next: function(v) { 
            var its = { };
            its[key] = v;
            client.request('flow.provide', {
              iterators: its
            }, that.id);
          },
          done: function() {
            client.request('flow.provided', {
              iterators: [ key ]
            }, that.id);
          }
        }))();
      });
    };
    return that;
  };

})(jQuery, Utukku.Client);
