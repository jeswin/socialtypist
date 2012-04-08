controller = require('./controller')
everyauth = require 'everyauth'
dbconf = require '../../models/dbconf'
models = new (require '../../models').Models(dbconf.default)

class StoriesController extends controller.Controller

    constructor: () ->
    
        #These methods needs a logged-in user.
        for fn in ['write', 'write_post', 'edit']
            @[fn] = @ensureSession @[fn]



    index: (req, res, next) =>
        res.render 'stories/index.hbs', { loginStatus: @getLoginStatus(req) }
        
        
            
    create: (req, res, next) =>
        res.render 'stories/create.hbs', { loginStatus: @getLoginStatus(req) }
        
        
    
    create_post: (req, res, next) =>
        story = new models.Story()
        story.title = req.body.title
        story.description = req.body.description
        story.collaborators = parseInt req.body.collaborators
        story.tags = req.body.tags
        story.messageToAuthors = req.body.messageToAuthors
        story.save req.session.user, () =>
            res.redirect "/stories/#{story._id}/edit"
          
  
  
    edit: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            story.getParts (err, parts) =>
                story._objects = { parts: parts }
                res.render 'stories/edit.hbs', { loginStatus: @getLoginStatus(req), story: JSON.stringify story }
        
        
        
    saveTitle: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            story.title = req.body.title
            story.save req.session.user._id, () =>
                res.contentType 'json'
                res.send { success: true }   
        
        
    
    updatePart: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            if req.body.part._id?        
                story.updatePart new models.StoryPart(req.body.part), req.session.user._id, () =>
                    res.contentType 'json'
                    res.send { success: true }   
            else
                part = new models.StoryPart(req.body.part)
                story.addPart part, req.body.previousParts, req.session.user._id, () =>
                    res.contentType 'json'
                    res.send { success: true, partId: part._id }
                
    
          
    item: (req, res, next) =>
        models.Story.get req.params.id, (story) =>
            
    
exports.StoriesController = StoriesController
