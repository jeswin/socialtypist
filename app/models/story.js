// Generated by CoffeeScript 1.3.1
(function() {
  var BaseModel, Exception, Story, async, markdown, sanitize,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  async = require('async');

  BaseModel = require('./basemodel').BaseModel;

  markdown = require("node-markdown").Markdown;

  sanitize = require("../common/mdsanitizer").sanitize;

  Exception = require("../common/exception").Exception;

  Story = (function(_super) {

    __extends(Story, _super);

    Story.name = 'Story';

    function Story() {
      this.recreateCache = __bind(this.recreateCache, this);

      this.isOwner = __bind(this.isOwner, this);

      this.isAuthor = __bind(this.isAuthor, this);

      this.deleteMessage = __bind(this.deleteMessage, this);

      this.addMessage = __bind(this.addMessage, this);

      this.getMessages = __bind(this.getMessages, this);

      this.removeOwner = __bind(this.removeOwner, this);

      this.addOwner = __bind(this.addOwner, this);

      this.removeAuthor = __bind(this.removeAuthor, this);

      this.addAuthor = __bind(this.addAuthor, this);

      this.deletePart = __bind(this.deletePart, this);

      this.updatePart = __bind(this.updatePart, this);

      this.getPart = __bind(this.getPart, this);

      this.createPart = __bind(this.createPart, this);

      this.publish = __bind(this.publish, this);

      this.save = __bind(this.save, this);

      this.getParts = __bind(this.getParts, this);

      this.getShortSummary = __bind(this.getShortSummary, this);

      this.fork = __bind(this.fork, this);
      return Story.__super__.constructor.apply(this, arguments);
    }

    Story._meta = {
      type: Story,
      collection: 'stories',
      logging: {
        isLogged: true,
        onInsert: 'NEW_STORY'
      }
    };

    Story.getByUserId = function(userid, cb) {
      return Story._models.User.getById(userid, function(err, user) {
        var allStories, id;
        allStories = user.ownedStories.concat(user.authoredStories);
        return Story.getAll({
          '$or': (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = allStories.length; _i < _len; _i++) {
              id = allStories[_i];
              _results.push({
                '_id': this._database.ObjectId(id)
              });
            }
            return _results;
          }).call(Story)
        }, cb);
      });
    };

    Story.prototype.fork = function(userid, cb) {
      var forked,
        _this = this;
      forked = new Story(this);
      delete forked._id;
      forked.forkSource = this._oid();
      forked.forkRoot = this.forkRoot != null ? this.forkRoot : this._oid();
      if (forked.updatedBy) {
        delete forked.updatedBy;
      }
      if (forked.published) {
        delete forked.published;
        delete forked.publishedTimestamp;
        delete forked.publishedDate;
      }
      return forked.save(userid, function() {
        return _this.getParts(function(err, parts) {
          var part, partSave;
          partSave = function(part) {
            return function(cb) {
              part = new Story._models.StoryPart(part);
              delete part._id;
              part.createdBy = userid;
              part.story = forked._oid();
              return part.save(function() {
                return cb();
              });
            };
          };
          return async.series((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = parts.length; _i < _len; _i++) {
              part = parts[_i];
              _results.push(partSave(part));
            }
            return _results;
          })(), function() {
            return cb(null, forked);
          });
        });
      });
    };

    Story.prototype.getShortSummary = function() {
      var _ref;
      return (_ref = this.summary) != null ? _ref : '';
    };

    Story.prototype.getParts = function(cb) {
      var partId,
        _this = this;
      return Story._models.StoryPart.getAll({
        '$or': (function() {
          var _i, _len, _ref, _results;
          _ref = this.parts;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            partId = _ref[_i];
            _results.push({
              _id: Story._database.ObjectId(partId)
            });
          }
          return _results;
        }).call(this)
      }, function(err, items) {
        var item, part, partId, results, _i, _len, _ref;
        results = [];
        _ref = _this.parts;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          partId = _ref[_i];
          part = ((function() {
            var _j, _len1, _results;
            _results = [];
            for (_j = 0, _len1 = items.length; _j < _len1; _j++) {
              item = items[_j];
              if (item._id.toString() === partId) {
                _results.push(item);
              }
            }
            return _results;
          })())[0];
          part = new Story._models.StoryPart(part);
          results.push(part);
        }
        return cb(null, results);
      });
    };

    Story.prototype.save = function(userid, cb) {
      var allowedAttributes, allowedTags,
        _this = this;
      allowedTags = 'a|b|blockquote|code|del|dd|dl|dt|em|h1|h2|h3|h4|h5|h6|i|img|li|ol|p|pre|sup|sub|strong|strike|ul|br|hr';
      allowedAttributes = {
        'img': 'src|width|height|alt',
        'a': 'href',
        '*': 'title'
      };
      this.timestamp = new Date().getTime();
      if (!(this._id != null)) {
        this.createdBy = userid;
        this.owners = [userid];
        this.authors = [];
        this.parts = [];
        this.title = sanitize(this.title, allowedTags, allowedAttributes);
        this.forks = [];
        this.cache = {
          html: '',
          owners: [],
          authors: []
        };
        return Story.__super__.save.call(this, function() {
          return async.series([
            (function(cb) {
              return Story._models.User.getById(userid, function(err, user) {
                user.ownedStories.push(_this._oid());
                _this.cache.owners.push(user.getBasicInfo());
                return user.save(function() {
                  return cb();
                });
              });
            }), (function(cb) {
              var part;
              part = new Story._models.StoryPart();
              part.type = "HEADING";
              part.size = 'H2';
              part.value = "Sample Heading. Click to edit.";
              return _this.createPart(part, null, userid, cb);
            }), (function(cb) {
              var part;
              part = new Story._models.StoryPart();
              part.type = "TEXT";
              part.value = "This is some sample content. Click to edit.";
              return _this.createPart(part, [_this.parts[0]], userid, cb);
            })
          ], function() {
            return cb();
          });
        });
      } else {
        if (this.isOwner(userid)) {
          this.title = sanitize(this.title, allowedTags, allowedAttributes);
          return Story.__super__.save.call(this, cb);
        } else {
          throw new Exception('NOT_OWNER', 'You do not own this story. Cannot modify.');
        }
      }
    };

    Story.prototype.publish = function(userid, cb) {
      var allowedAttributes, allowedTags, date, month, today, year,
        _this = this;
      allowedTags = 'a|b|blockquote|code|del|dd|dl|dt|em|h1|h2|h3|h4|h5|h6|i|img|li|ol|p|pre|sup|sub|strong|strike|ul|br|hr';
      allowedAttributes = {
        'img': 'src|width|height|alt',
        'a': 'href',
        '*': 'title'
      };
      if (!this.published) {
        this.published = true;
        today = new Date();
        this.publishedTimestamp = today.getTime();
        year = today.getYear() + 1900;
        month = today.getMonth();
        month = month < 10 ? '0' + month : month;
        date = today.getDate();
        date = date < 10 ? '0' + date : date;
        this.publishedDate = year + month + date + '';
      }
      this.cache.html = markdown('#' + this.title, true, allowedTags, allowedAttributes);
      return this.getParts(function(err, parts) {
        var part, _i, _len;
        for (_i = 0, _len = parts.length; _i < _len; _i++) {
          part = parts[_i];
          _this.cache.html += part.getHtml();
        }
        return _this.save(userid, cb);
      });
    };

    /*
            Adds a new part to the story.
                1. previousParts is a list of part-ids which occur before the newly added part. (Walked backwards in the DOM, if dom has #a, #b, #c, previousParts = [c,b,a])
                   Insertion will happen at the first "previous-part" found in the @parts collection.
    */


    Story.prototype.createPart = function(part, previousParts, userid, cb) {
      var _this = this;
      if (this.isAuthor(userid)) {
        part.createdBy = userid;
        part.story = this._oid();
        part.timestamp = new Date().getTime();
        return part.save(function() {
          var index, insertAt, previous, _i, _len;
          insertAt = 0;
          if (previousParts) {
            for (_i = 0, _len = previousParts.length; _i < _len; _i++) {
              previous = previousParts[_i];
              index = _this.parts.indexOf(previous);
              if (index !== -1) {
                insertAt = index + 1;
                break;
              }
            }
          }
          _this.parts.splice(insertAt, 0, part._oid());
          return _this.save(userid, cb);
        });
      } else {
        throw new Exception('NOT_AUTHOR', 'You are not an author on this story. Cannot modify.');
      }
    };

    Story.prototype.getPart = function(id, cb) {
      var _this = this;
      return Story._models.StoryPart.getById(id, function(err, part) {
        if (part.story === _this._oid()) {
          return cb(err, part);
        } else {
          throw new Exception("PART_NOT_IN_STORY", "The requested part(id:" + part._id + ", story:" + part.story + ") is not in this story.");
        }
      });
    };

    Story.prototype.updatePart = function(part, userid, cb) {
      if (this.isAuthor(userid)) {
        part.updatedBy = userid;
        part.timestamp = new Date().getTime();
        return part.save(cb);
      } else {
        throw new Exception('NOT_AUTHOR', 'You are not an author on this story. Cannot modify.');
      }
    };

    Story.prototype.deletePart = function(part, userid, cb) {
      var index;
      if (this.isAuthor(userid)) {
        index = this.parts.indexOf(part);
        if (index !== -1) {
          this.parts.splice(index, 1);
          return this.save(userid, cb);
        }
      } else {
        throw new Exception('NOT_AUTHOR', 'You are not an author on this story. Cannot modify.');
      }
    };

    Story.prototype.addAuthor = function(author, userid, cb) {
      var _this = this;
      if (this.isOwner(userid)) {
        if (this.authors.indexOf(author) === -1 && this.owners.indexOf(author) === -1) {
          return Story._models.User.getById(author, function(err, user) {
            _this.authors.push(author);
            _this.cache.authors.push(user);
            return _this.save(userid, cb);
          });
        }
      } else {
        throw new Exception('NOT_OWNER', 'You do not own this story. Cannot modify.');
      }
    };

    Story.prototype.removeAuthor = function(author, userid, cb) {
      var u;
      if (this.isOwner(userid)) {
        if (this.authors.indexOf(author) > -1) {
          this.authors = (function() {
            var _i, _len, _ref, _results;
            _ref = this.authors;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              u = _ref[_i];
              if (u !== author) {
                _results.push(u);
              }
            }
            return _results;
          }).call(this);
          this.cache.authors = (function() {
            var _i, _len, _ref, _results;
            _ref = this.cache.authors;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              u = _ref[_i];
              if (u._id.toString() !== author) {
                _results.push(u);
              }
            }
            return _results;
          }).call(this);
          return this.save(userid, cb);
        }
      } else {
        throw new Exception('NOT_OWNER', 'You do not own this story. Cannot modify.');
      }
    };

    Story.prototype.addOwner = function(owner, userid, cb) {
      var _this = this;
      if (this.isOwner(userid)) {
        if (this.owners.indexOf(owner) === -1) {
          return Story._models.User.getById(author, function(err, user) {
            _this.owners.push(owner);
            _this.cache.owners.push(user);
            return _this.save(userid, cb);
          });
        }
      } else {
        throw new Exception('NOT_OWNER', 'You do not own this story. Cannot modify.');
      }
    };

    Story.prototype.removeOwner = function(owner, userid, cb) {
      var u;
      if (this.isOwner(userid)) {
        if (this.owners.indexOf(owner) > -1) {
          this.owners = (function() {
            var _i, _len, _ref, _results;
            _ref = this.owners;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              u = _ref[_i];
              if (u !== owner) {
                _results.push(u);
              }
            }
            return _results;
          }).call(this);
          this.cache.owners = (function() {
            var _i, _len, _ref, _results;
            _ref = this.cache.owners;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              u = _ref[_i];
              if (u._id.toString() !== owner) {
                _results.push(u);
              }
            }
            return _results;
          }).call(this);
          return this.save(userid, cb);
        }
      } else {
        throw new Exception('NOT_OWNER', 'You do not own this story. Cannot modify.');
      }
    };

    Story.prototype.getMessages = function(userid, cb) {
      var _this = this;
      if (this.isAuthor(userid)) {
        return Story._models.Message.getAll({
          story: this._oid(),
          deleted: false
        }, function(err, messages) {
          return cb(err, messages != null ? messages.reverse() : void 0);
        });
      } else {
        throw new Exception('NOT_AUTHOR', 'You are not an author on this story. Cannot fetch.');
      }
    };

    Story.prototype.addMessage = function(type, content, userid, checkAccess, cb) {
      var _this = this;
      if ((checkAccess && this.isAuthor(userid)) || !checkAccess) {
        return Story._models.User.getById(userid, function(err, user) {
          var message;
          message = new Story._models.Message();
          message.type = type;
          message.content = content;
          message.from = userid;
          message.cache = {
            from: {
              domainid: user.domainid,
              name: user.name,
              location: user.location
            }
          };
          message.story = _this._oid();
          message.deleted = false;
          return message.save(function() {
            return cb();
          });
        });
      }
    };

    Story.prototype.deleteMessage = function(messageid, userid, cb) {
      var _this = this;
      if (this.isOwner(userid)) {
        return Story._models.Message.getById(messageid, function(err, message) {
          message.deleted = true;
          return message.save(cb);
        });
      } else {
        throw new Exception('NOT_OWNER', 'Only owners may delete a message.');
      }
    };

    Story.prototype.isAuthor = function(userid) {
      return this.owners.indexOf(userid) > -1 || this.authors.indexOf(userid) > -1;
    };

    Story.prototype.isOwner = function(userid) {
      return this.owners.indexOf(userid) > -1;
    };

    Story.prototype.recreateCache = function() {};

    return Story;

  }).call(this, BaseModel);

  exports.Story = Story;

}).call(this);
