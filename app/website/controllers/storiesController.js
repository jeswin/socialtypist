(function() {
  var StoriesController, controller, dbconf, everyauth, models,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  controller = require('./controller');

  everyauth = require('everyauth');

  dbconf = require('../../models/dbconf');

  models = new (require('../../models')).Models(dbconf["default"]);

  StoriesController = (function(_super) {

    __extends(StoriesController, _super);

    function StoriesController() {
      this.item = __bind(this.item, this);
      this.write_post = __bind(this.write_post, this);
      this.write = __bind(this.write, this);
      this.index = __bind(this.index, this);
    }

    StoriesController.prototype.index = function(req, res, next) {
      return res.render('stories/index.hbs', {
        loginStatus: this.getLoginStatus(req)
      });
    };

    StoriesController.prototype.write = function(req, res, next) {
      return res.render('stories/write.hbs', {
        loginStatus: this.getLoginStatus(req)
      });
    };

    StoriesController.prototype.write_post = function(req, res, next) {
      var story,
        _this = this;
      story = new models.Story();
      story.name = req.body.name;
      story.collaborators = parseInt(req.body.collaborators);
      story.tags = req.body.tags;
      return story.save(req.session.user.username, function() {
        return res.redirect("/stories/" + story._id);
      });
    };

    StoriesController.prototype.item = function(req, res, next) {
      var _this = this;
      return Story.get(req.params.id, function(story) {});
    };

    return StoriesController;

  })(controller.Controller);

  exports.StoriesController = StoriesController;

}).call(this);
