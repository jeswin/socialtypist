(function() {
  var BaseModel, Story,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  BaseModel = require('./basemodel').BaseModel;

  Story = (function(_super) {

    __extends(Story, _super);

    function Story() {
      this.isOwner = __bind(this.isOwner, this);
      this.isAuthor = __bind(this.isAuthor, this);
      this.removeOwner = __bind(this.removeOwner, this);
      this.addOwner = __bind(this.addOwner, this);
      this.removeAuthor = __bind(this.removeAuthor, this);
      this.addAuthor = __bind(this.addAuthor, this);
      this.changePart = __bind(this.changePart, this);
      this.removePart = __bind(this.removePart, this);
      this.updatePart = __bind(this.updatePart, this);
      this.addPart = __bind(this.addPart, this);
      this.save = __bind(this.save, this);
      Story.__super__.constructor.apply(this, arguments);
    }

    Story._meta = {
      type: Story,
      collection: 'stories',
      logging: {
        isLogged: true,
        onInsert: 'NEW_STORY'
      }
    };

    Story.prototype.save = function(user, cb) {
      var part, _ref,
        _this = this;
      if (!((_ref = this.parts) != null ? _ref.length : void 0)) {
        part = new Story._models.Part();
        part.type = "MARKER";
        part.value = "START";
        return part.save(function() {
          _this.parts = [part._id.toString()];
          _this.owners = [user];
          return Story.__super__.save.apply(_this, [cb]);
        });
      } else {
        if (this.isOwner(user)) {
          return Story.__super__.save.call(this, cb);
        } else {
          throw {
            type: 'NOT_OWNER',
            message: 'You do not own this story. Cannot modify.'
          };
        }
      }
    };

    Story.prototype.addPart = function(part, after, user, cb) {
      var _this = this;
      if (this.isAuthor(user)) {
        part.author = user;
        return part.save(function() {
          _this.parts.splice(_this.parts.indexOf(after) + 1, 0, part._id.toString());
          return _this.save(cb);
        });
      } else {
        throw {
          type: 'NOT_AUTHOR',
          message: 'You are not an author on this story. Cannot modify.'
        };
      }
    };

    Story.prototype.updatePart = function(part, user, cb) {
      if (this.isAuthor(user)) {
        return part.save(cb);
      } else {
        throw {
          type: 'NOT_AUTHOR',
          message: 'You are not an author on this story. Cannot modify.'
        };
      }
    };

    Story.prototype.removePart = function(part, user, cb) {
      if (this.isAuthor(user)) {
        this.parts.splice(this.parts.indexOf(part._id.toString(), 1));
        return this.save(cb);
      } else {
        throw {
          type: 'NOT_AUTHOR',
          message: 'You are not an author on this story. Cannot modify.'
        };
      }
    };

    Story.prototype.changePart = function(oldPart, newPart, user, cb) {
      if (this.isAuthor(user)) {
        this.parts.splice(this.parts.indexOf(oldPart._id.toString(), 1, newPart._id.toString()));
        return this.save(cb);
      } else {
        throw {
          type: 'NOT_AUTHOR',
          message: 'You are not an author on this story. Cannot modify.'
        };
      }
    };

    Story.prototype.addAuthor = function(author, user, cb) {
      if (this.isOwner(user)) {
        if (this.authors.indexOf(author) === -1) {
          this.authors.push(author);
          return this.save(cb);
        }
      } else {
        throw {
          type: 'NOT_OWNER',
          message: 'You do not own this story. Cannot modify.'
        };
      }
    };

    Story.prototype.removeAuthor = function(author, user, cb) {
      if (this.isOwner(user)) {
        if (this.authors.indexOf(author) > -1) {
          this.authors.splice(this.authors.indexOf(author, 1));
          return this.save(cb);
        }
      } else {
        throw {
          type: 'NOT_OWNER',
          message: 'You do not own this story. Cannot modify.'
        };
      }
    };

    Story.prototype.addOwner = function(owner, user, cb) {
      if (this.isOwner(user)) {
        if (this.owners.indexOf(owner) === -1) {
          this.owners.push(owner);
          return this.save(cb);
        }
      } else {
        throw {
          type: 'NOT_OWNER',
          message: 'You do not own this story. Cannot modify.'
        };
      }
    };

    Story.prototype.removeOwner = function(owner, user, cb) {
      if (this.isOwner(user)) {
        if (this.owners.indexOf(owner) > -1) {
          this.owners.splice(this.owners.indexOf(owner, 1));
          return this.save(cb);
        }
      } else {
        throw {
          type: 'NOT_OWNER',
          message: 'You do not own this story. Cannot modify.'
        };
      }
    };

    Story.prototype.isAuthor = function(username) {
      return owners.indexOf(username) > -1 || authors.indexOf(username) > -1;
    };

    Story.prototype.isOwner = function(username) {
      return owners.indexOf(username) > -1;
    };

    return Story;

  })(BaseModel);

  exports.Story = Story;

}).call(this);
