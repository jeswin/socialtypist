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
        
        
    ensureSession: (fn) ->
        return (req, res, next) ->
            if req.session.user?
                fn req, res, next
            else
                res.redirect '/login'
        
        
exports.Controller = Controller


