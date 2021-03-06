// Generated by CoffeeScript 1.3.1
(function() {
  var Change, Event, Message, Models, Story, StoryChange, StoryPart, User;

  User = require('./user').User;

  Story = require('./story').Story;

  StoryPart = require('./storypart').StoryPart;

  StoryChange = require('./storychange').StoryChange;

  Message = require('./message').Message;

  Event = require('./event').Event;

  Change = require('./change').Change;

  Models = (function() {

    Models.name = 'Models';

    function Models(dbconf) {
      var model, _i, _len, _ref;
      this.dbconf = dbconf;
      this.User = User;
      this.Story = Story;
      this.StoryPart = StoryPart;
      this.StoryChange = StoryChange;
      this.Message = Message;
      this.Event = Event;
      this.Change = Change;
      _ref = [User, Story, StoryPart, StoryChange, Message, Event, Change];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        this.initModel(model);
      }
    }

    Models.prototype.initModel = function(model) {
      model._database = new (require('../common/database')).Database(this.dbconf);
      return model._models = this;
    };

    return Models;

  })();

  exports.Models = Models;

}).call(this);
