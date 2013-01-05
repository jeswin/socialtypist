Exception = require('../../common/exception').Exception

class Controller        
    constructor: () ->
    
    getLoginStatus: (req) ->
        if req.session.user?.username
            status = {
                loggedIn: true,
                js: "window.authProvider = '#{req.session.authProvider}'; window.loggedIn = true; window.username = '#{req.session.user.username}'; window.userid = '#{req.session.user._id}';",
                header: "<a class=\"logoutLink\" href=\"/logout\">Logout</a> <span class=\"username\">#{req.session.user.username}</span>"
            }
        else
            status = {
                loggedIn: false,
                js: "window.loggedIn = false; window.username = null;window.userid = null;",
                header: "<img src=\"/public/images/facebook.png\" /><a class=\"needs-session\" href=\"#\">Login</a>" #We support only facebook now.
            }
        return status
        
        
    ensureSession: (fn) ->
        return (req, res, next) ->
            if req.session.user?
                fn req, res, next
            else
                res.redirect "/login?redirect=#{req.url}"


    getUser: (req) =>
        if req.session.user?
            return req.session.user
        else
            throw new Exception 'NOT_LOGGED_IN', ''

        
        
    getUserId: (req) =>
        if req.session.user?
            return req.session.user._id.toString()
        else
            throw new Exception 'NOT_LOGGED_IN', ''
        
        
        
    getValue: (src, field, safe = true) =>
        return src[field]
        
        
        
    setValues: (target, src, fields, options = {}) =>
    
        if not options.safe?
            options.safe = true
        if not options.ignoreEmpty
            options.ignoreEmpty = true

        setValue = (src, targetField, srcField) =>
            val = @getValue src, srcField, options.safe
            if options.ignoreEmpty
                if val?
                    target[field] = val
            else
                target[field] = val

        if fields.constructor == Array
            for field in fields
                setValue src, field, field
        else
            for ft, fsrc of fields
                setValue src, ft, fsrc
                
            
    
        
exports.Controller = Controller


