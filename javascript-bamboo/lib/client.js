Bamboo.namespace('Client');

(function($, Client) {
  var connections = { };

  Client.Connection = function(options) {
    var that = { }, onMessage, onOpen, onClose, connection;

    that.options = options;


    that.events = { };

    onMessage = function(msg) {
      
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
      that.options.onerror();
    }
    if( "onSuccess" in options ) {
      options.onSuccess(that);
    }
    return that;
  };


})(jQuery, Bamboo.Client);
