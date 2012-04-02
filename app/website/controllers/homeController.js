(function() {
  var HomeController, controller, dbconf, everyauth, models,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  controller = require('./controller');

  everyauth = require('everyauth');

  dbconf = require('../../models/dbconf');

  models = new (require('../../models')).Models(dbconf["default"]);

  HomeController = (function(_super) {

    __extends(HomeController, _super);

    function HomeController() {
      this.addSession = __bind(this.addSession, this);
      this.index = __bind(this.index, this);
    }

    HomeController.prototype.index = function(req, res, next) {
      return res.render('home/index.hbs', {
        loginStatus: this.getLoginStatus(req)
      });
    };

    HomeController.prototype.addSession = function(req, res, next) {
      var _this = this;
      return models.User.get({
        username: req.body.username
      }, function(err, user) {
        if (!(user != null)) user = new models.User();
        user.fbid = req.body.id;
        user.username = req.body.username;
        user.name = req.body.name;
        user.firstName = req.body.first_name;
        user.lastName = req.body.last_name;
        user.location = req.body.location;
        return user.save(function() {
          req.session.user = user;
          res.contentType('json');
          return res.send({
            success: true
          });
        });
      });
    };

    HomeController.prototype.removeSession = function(req, res, next) {
      delete req.session.user;
      res.contentType('json');
      return res.send({
        success: true
      });
    };

    return HomeController;

  })(controller.Controller);

  exports.HomeController = HomeController;

}).call(this);
