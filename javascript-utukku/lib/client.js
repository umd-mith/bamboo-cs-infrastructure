Utukku.namespace('Client');

(function($, Client) {
  var connections = { };

  /* Client.Connection.url will be the default */

  Client.Connection = function(options) {
    var that = { }, onMessage, onOpen, onClose, connection;

console.log("Client.Connection", options);
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
      msg = $.parseJSON(msg.data)
      console.debug(msg);
      if( msg.class == 'flow.namespaces.registered' ) {
        $.each(msg.data, function(ns, def) {
          console.debug(ns, def);
          Utukku.Engine.RemoteLib(that, ns, def);
        });
      }
      else if( msg.class == 'flow.produce' ) {
      }
      else if( msg.class == 'flow.produced' ) {
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
    return that;
  };

  Client.Function = function(options) {
    Client.Connection({
      url: options.url,
      onSuccess: function(client) {
        var handler = Utukku.Engine.TagLib(options.namespace),
            iterator = handler.function_to_iterator(
                         options.name, options.iterators
                       );
        (iterator.async({
          next: options.next,
          done: options.done
        }))();
      }
    });
  };

})(jQuery, Utukku.Client);
