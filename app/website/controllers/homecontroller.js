// Generated by CoffeeScript 1.2.1-pre
(function() {
  var FACEBOOK_APP_ID, FACEBOOK_SECRET, FaceBookClient, HomeController, controller, dbconf, everyauth, models, querystring,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  controller = require('./controller');

  everyauth = require('everyauth');

  dbconf = require('../../models/dbconf');

  models = new (require('../../models')).Models(dbconf["default"]);

  querystring = require('querystring');

  FaceBookClient = require('../../common/facebookclient').FaceBookClient;

  FACEBOOK_APP_ID = '259516830808506';

  FACEBOOK_SECRET = '5402abb9c3003f767889e57e00f2b499';

  HomeController = (function(_super) {

    __extends(HomeController, _super);

    HomeController.name = 'HomeController';

    function HomeController() {
      this.addSession_INSECURE = __bind(this.addSession_INSECURE, this);

      this.addSession = __bind(this.addSession, this);

      this.index = __bind(this.index, this);

    }

    HomeController.prototype.index = function(req, res, next) {
      return res.render('home/index.hbs', {
        loginStatus: this.getLoginStatus(req)
      });
    };

    HomeController.prototype.addSession = function(req, res, next) {
      var client, options,
        _this = this;
      if (req.body.domain === 'facebook') {
        client = new FaceBookClient();
        options = {
          path: '/me?' + querystring.stringify({
            access_token: req.body.response.authResponse.accessToken,
            client_id: FACEBOOK_APP_ID,
            client_secret: FACEBOOK_SECRET
          })
        };
        return client.secureGraphRequest(options, function(err, userDetails) {
          return _this.getOrCreateFBUser(userDetails, 'facebook', function(err, user) {
            req.session.authProvider = 'facebook';
            req.session.domainResponse = req.body.response;
            req.session.accessToken = req.body.response.authResponse.accessToken;
            req.session.user = user;
            res.contentType('json');
            return res.send({
              success: true
            });
          });
        });
      }
    };

    HomeController.prototype.addSession_INSECURE = function(req, res, next) {
      var _this = this;
      if (require('../conf').deployment !== 'DEBUG') {
        throw {
          type: 'BAD_MODE',
          message: 'This insecure function is callable only in debug mode.'
        };
      }
      if (req.body.domain === 'facebook') {
        return this.getOrCreateFBUser(req.body.userDetails, function(err, user) {
          req.session.authProvider = 'facebook';
          req.session.domainResponse = req.body.response;
          req.session.accessToken = req.body.response.authResponse.accessToken;
          req.session.user = user;
          res.contentType('json');
          return res.send({
            success: true
          });
        });
      }
    };

    HomeController.prototype.getOrCreateFBUser = function(userDetails, cb) {
      var _this = this;
      return models.User.get({
        domain: 'facebook',
        username: userDetails.username
      }, function(err, user) {
        if (user != null) {
          return cb(null, user);
        } else {
          user = new models.User();
          user.domain = 'facebook';
          user.domainid = userDetails.id;
          user.username = userDetails.username;
          user.name = userDetails.name;
          user.firstName = userDetails.first_name;
          user.lastName = userDetails.last_name;
          user.location = userDetails.location;
          return user.save(function() {
            return cb(null, user);
          });
        }
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