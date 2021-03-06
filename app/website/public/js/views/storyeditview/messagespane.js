// Generated by CoffeeScript 1.3.1
(function() {
  var MessagesPane,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  MessagesPane = (function() {

    MessagesPane.name = 'MessagesPane';

    function MessagesPane(story, editor, view) {
      this.story = story;
      this.editor = editor;
      this.view = view;
      this.loadMessages = __bind(this.loadMessages, this);

      this.addMessage = __bind(this.addMessage, this);

      this.cancelAddMessage = __bind(this.cancelAddMessage, this);

      this.showAddMessage = __bind(this.showAddMessage, this);

      this.editor.find('.tab-content').html('<div class="message-pane"></div>');
      this.container = this.editor.find('.message-pane');
      this.container.html('\
            <p class="show-send-message">\
                <a href="#" class="btn">New message</a> <span class="padded help-inline">Message goes to all authors.</span>\
            </p>\
            <div class="add-message" style="display:none">\
                <form class="well">\
                    <p>\
                        <textarea rows="6" style="width:90%"></textarea>\
                        <br />\
                        <a class="btn btn-small send" href="#">Send Message</a> <a href="#" class="cancel">cancel</a>\
                    </p>\
                </form>\
            </div>\
            <div class="message-list section">\
            </div>');
      this.container.find('.show-send-message a.btn').click(this.showAddMessage);
      this.container.find('.add-message .btn.send').click(this.addMessage);
      this.container.find('.add-message .cancel').click(this.cancelAddMessage);
      this.loadMessages();
    }

    MessagesPane.prototype.showAddMessage = function() {
      this.container.find('.show-send-message').hide();
      this.container.find('.add-message textarea').val('');
      this.container.find('.add-message').show();
      return false;
    };

    MessagesPane.prototype.cancelAddMessage = function() {
      this.container.find('.add-message').hide();
      this.container.find('.show-send-message').show();
      return false;
    };

    MessagesPane.prototype.addMessage = function() {
      var _this = this;
      $.post("/stories/" + this.story._id + "/messages", {
        message: this.container.find('.add-message textarea').val()
      }, function(response) {
        if (response.success) {
          _this.container.find('.add-message').hide();
          _this.container.find('.show-send-message').show();
          return _this.loadMessages();
        }
      });
      return false;
    };

    MessagesPane.prototype.loadMessages = function() {
      var _this = this;
      return $.get("/stories/" + this.story._id + "/messages", function(response) {
        var author, message, messageListElem, _content, _i, _len, _ref, _results;
        _this.container.find('.message-list').html('<ul class="iconic-summary"></ul>');
        messageListElem = _this.container.find('.message-list ul');
        _ref = response.messages;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          message = _ref[_i];
          try {
            if (message.type === 'AUTHOR_ACCESS_REQUEST') {
              if (message.content) {
                _content = "<div class=\"text-section\">" + message.content + "</div>";
              } else {
                _content = '';
              }
              messageListElem.append("                            <li>                                <div class=\"icon\">                                    <img src=\"http://graph.facebook.com/" + message.cache.from.domainid + "/picture?type=square\" />                                </div>                                <div class=\"summary\">                                    <h2 style=\"display:inline\">" + message.cache.from.name + "</h2> wants to co-author this story.                                         <a href=\"#\" class=\"approve-author\">Approve</a> or <a href=\"#\" class=\"unsafe reject-author\">reject</a>?                                    " + _content + "                                </div>                            </li>");
              author = message.from;
              messageListElem.children('li').last().find('.approve-author').click(function() {
                $.post("/stories/" + _this.story._id + "/authors", {
                  author: author
                }, function(response) {
                  if (response.success) {
                    return $.delete_("/stories/" + _this.story._id + "/messages/" + message._id, function(response) {
                      return _this.loadMessages();
                    });
                  }
                });
                return false;
              });
              _results.push(messageListElem.children('li').last().find('.reject-author').click(function() {
                $.delete_("/stories/" + _this.story._id + "/messages/" + message._id, function(response) {
                  return _this.loadMessages();
                });
                return false;
              }));
            } else {
              _results.push(messageListElem.append("                            <li>                                <div class=\"icon\">                                    <img src=\"http://graph.facebook.com/" + message.cache.from.domainid + "/picture?type=square\" />                                </div>                                <div class=\"summary\">                                    <h2>" + message.cache.from.name + "</h2>                                    <div class=\"text-section\">                                        " + message.content + "                                    </div>                                </div>                            </li>"));
            }
          } catch (err) {
            _results.push(console.log(JSON.stringify(err)));
          }
        }
        return _results;
      });
    };

    return MessagesPane;

  })();

  this.SocialTypist.StoryEditView.MessagesPane = MessagesPane;

}).call(this);
