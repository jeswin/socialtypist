(function() {
  var BaseModel, Part,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  BaseModel = require('./basemodel').BaseModel;

  Part = (function(_super) {

    __extends(Part, _super);

    function Part() {
      Part.__super__.constructor.apply(this, arguments);
    }

    Part._meta = {
      type: Part,
      collection: 'parts'
    };

    return Part;

  })(BaseModel);

  exports.Part = Part;

}).call(this);
