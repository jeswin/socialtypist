controller = require('./controller')
everyauth = require 'everyauth'
dbconf = require '../../models/dbconf'
models = new (require '../../models').Models(dbconf.default)

class HomeController extends controller.Controller
    constructor: () ->

    index: (req, res, next) =>
        res.render 'home/index.hbs', { loginStatus: @getLoginStatus(req) }
        
        

    addSession: (req, res, next) =>

        #see if there is such a user
        models.User.get { domain: req.body.domain, username: req.body.username }, (err, user) =>
        
            respond = (user) =>
                req.session.user = user
                res.contentType 'json'
                res.send { success: true }                
        
            if user?
                respond user
                
            else                            
                #User doesn't exist. create.
                user = new models.User()
                
                if req.body.domain == 'facebook'
                    user.domain = 'facebook'
                    user.domainid = req.body.id
                    user.username = req.body.username
                    user.name = req.body.name
                    user.firstName = req.body.first_name
                    user.lastName = req.body.last_name
                    user.location = req.body.location
                    user.save () =>
                        respond user
                
            
            
    removeSession: (req, res, next) ->
        delete req.session.user
        res.contentType 'json'
        res.send { success: true }
                
                
    
exports.HomeController = HomeController
