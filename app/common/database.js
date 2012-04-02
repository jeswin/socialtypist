(function() {
  var Database, Mongo, utils;

  Mongo = require('mongodb');

  utils = require('./utils');

  Database = (function() {

    function Database(conf) {
      this.conf = conf;
    }

    Database.prototype.getDb = function() {
      return new Mongo.Db(this.conf.name, new Mongo.Server(this.conf.host, this.conf.port, {}), {});
    };

    Database.prototype.execute = function(task) {
      var db;
      db = this.getDb();
      return db.open(function(err, db) {
        try {
          return task(db, function(err) {});
        } catch (e) {
          return utils.dumpError(e);
        }
      });
    };

    Database.prototype.insert = function(collectionName, document, cb) {
      return this.execute(function(db, completionCB) {
        return db.collection(collectionName, function(err, collection) {
          document.createdDate = new Mongo.Long(new Date().getTime());
          return collection.insert(document, {
            safe: true
          }, function(e, r) {
            cb(e, r[0]);
            return completionCB(e);
          });
        });
      });
    };

    Database.prototype.updateFields = function(collectionName, criteria, document, cb) {
      return this.execute(function(db, completionCB) {
        return db.collection(collectionName, function(err, collection) {
          return collection.update(criteria, document, function(e, r) {
            cb(e, r);
            return completionCB(e);
          });
        });
      });
    };

    Database.prototype.update = function(collectionName, document, cb) {
      return this.execute(function(db, completionCB) {
        return db.collection(collectionName, function(err, collection) {
          return collection.update({
            _id: document._id
          }, document, {
            safe: true
          }, function(e, r) {
            cb(e, r);
            return completionCB(e);
          });
        });
      });
    };

    Database.prototype.updateMany = function(collectionName, params, document, cb) {
      return this.execute(function(db, completionCB) {
        return db.collection(collectionName, function(err, collection) {
          return collection.update(params, document, function(e, r) {
            cb(e, r);
            return completionCB(e);
          });
        });
      });
    };

    Database.prototype.find = function(collectionName, params, cb) {
      return this.execute(function(db, completionCB) {
        return db.collection(collectionName, function(err, collection) {
          return collection.find(params).toArray(function(e, r) {
            cb(e, r);
            return completionCB(e);
          });
        });
      });
    };

    Database.prototype.findWithOptions = function(collectionName, params, options, cb) {
      return this.execute(function(db, completionCB) {
        return db.collection(collectionName, function(err, collection) {
          return collection.find(params, options).toArray(function(e, r) {
            cb(e, r);
            return completionCB(e);
          });
        });
      });
    };

    Database.prototype.findOne = function(collectionName, params, cb) {
      return this.execute(function(db, completionCB) {
        return db.collection(collectionName, function(err, collection) {
          return collection.findOne(params, function(e, r) {
            cb(e, r);
            return completionCB(e);
          });
        });
      });
    };

    Database.prototype.construct = function(collectionName, params, constructor, cb) {
      return this.findOne(collectionName, params, function(err, result) {
        if (!err) {
          if (result) {
            return cb(err, new constructor(result));
          } else {
            return cb(err, null);
          }
        } else {
          return utils.dumpError(err);
        }
      });
    };

    Database.prototype.ObjectId = function(id) {
      if (id instanceof String) {
        return new Mongo.BSONPure.ObjectID(id);
      } else {
        return id;
      }
    };

    return Database;

  })();

  exports.Database = Database;

}).call(this);
