class Controller        
    constructor: () ->
    
    getLoginStatus: (req) ->
        if req.session.user?.username
            status = {
                loggedIn: true,
                js: "window.loggedIn = true; window.username = '#{req.session.user.username}';",
                header: "<a class=\"loginStatus\" href=\"#\">Logout</a> <span class=\"username\">#{req.session.user.username}</span>"
            }
        else
            status = {
                loggedIn: false,
                js: "window.loggedIn = false; window.username = null;",
                header: '<img src="/public/images/facebook.png" /><a class="loginStatus" href="#">Login</a>'
            }
        return status
        
exports.Controller = Controller


