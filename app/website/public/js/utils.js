(function() {

  this.SocialTypist = {};

  this.SocialTypist.Utils = {};

  this.SocialTypist.Utils.random = function(n) {
    return Math.floor(Math.random() * n);
  };

  this.SocialTypist.Utils.pickRandom = function(array) {
    var rand;
    rand = Math.floor(Math.random() * array.length);
    return array[rand];
  };

}).call(this);
