(function() {
  var Client,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Client = (function() {

    function Client() {
      this.logoutLink = __bind(this.logoutLink, this);
      this.loginLink = __bind(this.loginLink, this);      this.setLoginStatus();
    }

    Client.prototype.initFB = function(FB) {
      this.FB = FB;
    };

    Client.prototype.makeRestrictedLink = function(url, selector) {
      var _this = this;
      return $(selector).click(function() {
        var callback;
        if (!loggedIn) {
          callback = function(response) {
            var _this = this;
            if (response.authResponse) {
              return this.FB.api('/me', function(aboutMe) {
                return $.post('/addSession', aboutMe, function() {
                  return window.location.href = url;
                });
              });
            }
          };
          return _this.FB.login(callback, {
            scope: 'email,user_location'
          });
        } else {
          return window.location.href = url;
        }
      });
    };

    Client.prototype.setLoginStatus = function() {
      if (loggedIn) {
        return $('.login .loginStatus').click(this.logoutLink);
      } else {
        return $('.login .loginStatus').click(this.loginLink);
      }
    };

    Client.prototype.loginLink = function() {
      var callback;
      callback = function(response) {
        var _this = this;
        if (response.authResponse) {
          return this.FB.api('/me', function(aboutMe) {
            return $.post('/addSession', aboutMe, function() {
              return window.location.reload();
            });
          });
        }
      };
      this.FB.login(callback, {
        scope: 'email,user_location'
      });
      return false;
    };

    Client.prototype.logoutLink = function() {
      var _this = this;
      return this.FB.getLoginStatus(function(response) {
        if (response.status === 'connected') {
          $.get('/removeSession', function() {
            return _this.FB.logout(function() {
              return window.location.href = "/";
            });
          });
        } else {
          $.get('/removeSession', function() {
            return window.location.href = "/";
          });
        }
        return false;
      });
    };

    return Client;

  })();

  this.SocialTypist.Client = Client;

}).call(this);
