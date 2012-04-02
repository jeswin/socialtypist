controller = require('./controller')
everyauth = require 'everyauth'
dbconf = require '../../models/dbconf'
models = new (require '../../models').Models(dbconf.default)

class StoriesController extends controller.Controller

    constructor: () ->



    index: (req, res, next) =>
        res.render 'stories/index.hbs', { loginStatus: @getLoginStatus(req) }
        
        
            
    write: (req, res, next) =>
        res.render 'stories/write.hbs', { loginStatus: @getLoginStatus(req) }
        
        
    
    write_post: (req, res, next) =>
        story = new models.Story()
        story.name = req.body.name
        story.collaborators = parseInt req.body.collaborators
        story.tags = req.body.tags
        story.save req.session.user.username, () =>
            res.redirect "/stories/#{story._id}"
          
          
          
    item: (req, res, next) =>
        Story.get req.params.id, (story) =>
            
    
exports.StoriesController = StoriesController
