(function() {
  var Event, Models, Part, Story, User;

  User = require('./user').User;

  Story = require('./story').Story;

  Part = require('./part').Part;

  Event = require('./event').Event;

  Models = (function() {

    function Models(dbconf) {
      var model, _i, _len, _ref;
      this.dbconf = dbconf;
      this.User = User;
      this.Story = Story;
      this.Part = Part;
      this.Event = Event;
      _ref = [User, Story, Part, Event];
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
