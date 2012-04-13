controller = require('./controller')
everyauth = require 'everyauth'
dbconf = require '../../models/dbconf'
models = new (require '../../models').Models(dbconf.default)
fs = require 'fs'

class StoriesController extends controller.Controller

    constructor: () ->    
        #These methods needs a logged-in user.
        for fn in ['yours', 'createForm', 'create', 'editForm', 'update', 'createPart', 'updatePart', 'deletePart', 'publish', 'upload']
            @[fn] = @ensureSession @[fn]



    index: (req, res, next) =>
        res.render 'stories/index.hbs', { loginStatus: @getLoginStatus(req) }
        
    
    
    show: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            res.render 'stories/show.hbs', { loginStatus: @getLoginStatus(req), content: story.html }
    
    
    
    yours: (req, res, next) =>
        models.Story.getByUserId req.session.user._id, (err, stories) =>
            res.render 'stories/yours.hbs', { loginStatus: @getLoginStatus(req), stories: stories }
    
    
            
    createForm: (req, res, next) =>
        res.render 'stories/create.hbs', { loginStatus: @getLoginStatus(req) }
        
        
    
    create: (req, res, next) =>
        story = new models.Story()
        story.title = req.body.title
        story.description = req.body.description
        story.collaborators = parseInt req.body.collaborators
        story.tags = req.body.tags
        story.messageToAuthors = req.body.messageToAuthors
        story.save req.session.user, () =>
            res.redirect "/stories/#{story._id}/edit"
          
  
  
    editForm: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            story.getParts (err, parts) =>
                story._objects = { parts: parts }
                res.render 'stories/edit.hbs', { loginStatus: @getLoginStatus(req), story: JSON.stringify story }
        
        
        
    update: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            #Right now we only support updating the title.
            story.title = req.body.title
            story.save req.session.user._id, () =>
                res.contentType 'json'
                res.send { success: true }   
        
        
    
    createPart: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            part = @getPartFromBody(req.body)
            story.createPart part, req.body.previousParts, req.session.user._id, () =>
                res.contentType 'json'
                res.send { success: true, _id: part._id }



    updatePart: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            story.updatePart @getPartFromBody(req.body), req.session.user._id, () =>
                res.contentType 'json'
                res.send { success: true }   
                   
                    

    deletePart: (req, res, next) =>                    
        models.Story.getById req.params.storyid, (err, story) =>
            story.deletePart req.params.partid, req.session.user._id, () =>
                res.contentType 'json'
                res.send { success: true }   
                
                

    publish: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            story.publish req.session.user._id, () =>
                res.contentType 'json'
                res.send { success: true }   
          
        
    
    upload: (req, res, next) =>
    	if (req.files)    	    
            targetPath = "./public/images/content/#{req.params.storyid}_#{req.files.file.name}"            
            fs.rename req.files.file.path, targetPath, (err) =>
                res.send "/public/images/content/#{req.params.storyid}_#{req.files.file.name}"
                           
        
          
    getPartFromBody: (body) =>
        part = new models.StoryPart body
       
            
    
exports.StoriesController = StoriesController
