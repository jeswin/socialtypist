(function() {
  var BaseModel, User,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  BaseModel = require('./basemodel').BaseModel;

  User = (function(_super) {

    __extends(User, _super);

    function User() {
      User.__super__.constructor.apply(this, arguments);
    }

    User._meta = {
      type: User,
      collection: 'users',
      logging: {
        isLogged: true,
        onInsert: 'NEW_USER'
      }
    };

    return User;

  })(BaseModel);

  exports.User = User;

}).call(this);
