(function() {
  var Controller;

  Controller = (function() {

    function Controller() {}

    Controller.prototype.getLoginStatus = function(req) {
      var status, _ref;
      if ((_ref = req.session.user) != null ? _ref.username : void 0) {
        status = {
          loggedIn: true,
          js: "window.loggedIn = true; window.username = '" + req.session.user.username + "';",
          header: "<a class=\"loginStatus\" href=\"#\">Logout</a> <span class=\"username\">" + req.session.user.username + "</span>"
        };
      } else {
        status = {
          loggedIn: false,
          js: "window.loggedIn = false; window.username = null;",
          header: '<img src="/public/images/facebook.png" /><a class="loginStatus" href="#">Login</a>'
        };
      }
      return status;
    };

    return Controller;

  })();

  exports.Controller = Controller;

}).call(this);
