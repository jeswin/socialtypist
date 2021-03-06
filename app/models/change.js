// Generated by CoffeeScript 1.3.1
(function() {
  var BaseModel, Change,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  BaseModel = require('./basemodel').BaseModel;

  Change = (function(_super) {

    __extends(Change, _super);

    Change.name = 'Change';

    function Change() {
      this.save = __bind(this.save, this);
      return Change.__super__.constructor.apply(this, arguments);
    }

    Change._meta = {
      type: Change,
      collection: 'changes'
    };

    Change.prototype.save = function(cb) {
      this.timestamp = new Date().getTime();
      return Change.__super__.save.call(this, cb);
    };

    return Change;

  })(BaseModel);

  exports.Change = Change;

}).call(this);
