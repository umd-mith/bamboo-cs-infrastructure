Utukku.namespace('Client');

(function($, Client) {
  var connections = { };

  Client.Connection = function(options) {
    var that = { }, onMessage, onOpen, onClose, connection;

    that.options = options;


    that.events = { };

    onMessage = function(msg) {
      if( msg.class == 'flow.registered' ) {
        foreach ns in msg.data {
          Utukku.Engine.RemoteLib(that, ns, msg.data[ns]);
        }
      }
      else if( msg.class == 'flow.produce' ) {
      }
      else if( msg.class == 'flow.produced' ) {
      }
    };

    onOpen = function() {
      that.options.onOpen();
    };

    onClose = function() {
      that.options.onClose();
    };

    if( "WebSocket" in window ) {
      if( options.url in connections ) {
        connection = connections[options.url];
      }
      else {
        var ws = new WebSocket(that.options.url);
        ws.onopen = onOpen;
        ws.onmessage = onMessage;
        ws.onclose = onClose;
        connections[options.url] = ws;
        connection = ws;
      }
    }
    else {
      that.options.onError();
    }
    if( "onSuccess" in options ) {
      options.onSuccess(that);
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
