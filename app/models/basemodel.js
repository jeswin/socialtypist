(function() {
  var BaseModel, utils;

  utils = require('../common/utils');

  BaseModel = (function() {

    function BaseModel(params) {
      var meta;
      utils.extend(this, params);
      meta = this.constructor._meta;
    }

    BaseModel.get = function(params, cb) {
      var meta;
      meta = this._meta;
      return this._database.findOne(meta.collection, params, function(err, result) {
        return cb(err, result ? new meta.type(result) : void 0);
      });
    };

    BaseModel.getById = function(id, cb) {
      var meta;
      meta = this._meta;
      return this._database.findOne(meta.collection, {
        _id: this._database.ObjectId(id)
      }, function(err, result) {
        return cb(err, result ? new meta.type() : void 0);
      });
    };

    BaseModel.prototype.save = function(cb) {
      var event, meta, _ref;
      meta = this.constructor._meta;
      if (!(this._id != null)) {
        if ((_ref = meta.logging) != null ? _ref.isLogged : void 0) {
          event = {};
          event.type = meta.logging.onInsert;
          event.data = this;
          meta.type._database.insert('events', event, function() {});
        }
        return meta.type._database.insert(meta.collection, this, function() {
          if (cb != null) return cb();
        });
      } else {
        return meta.type._database.update(meta.collection, this, function() {
          if (cb != null) return cb();
        });
      }
    };

    return BaseModel;

  })();

  exports.BaseModel = BaseModel;

}).call(this);
