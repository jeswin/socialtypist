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
            if story
                loginStatus = @getLoginStatus(req)
                if loginStatus.loggedIn
                    owners = (owner for owner in story.owners when owner == @getUserId())
                    authors = (author for author in story.authors when author == @getUserId())
                    isAuthor = owners.length > 0 or authors.length > 0
                else
                    isAuthor = false
                res.render 'stories/show.hbs', { loginStatus: loginStatus, story: story, isAuthor: isAuthor }
            else
                res.render 'Story does not exist.'
    
    
    
    yours: (req, res, next) =>
        models.Story.getByUserId @getUserId, (err, stories) =>
            res.render 'stories/yours.hbs', { loginStatus: @getLoginStatus(req), stories: stories }
    
    
            
    createForm: (req, res, next) =>
        res.render 'stories/create.hbs', { loginStatus: @getLoginStatus(req) }
        
        
    
    create: (req, res, next) =>
        story = new models.Story()
        story.title = req.body.title
        story.tags = req.body.tags
        story.save @getUserId(), () =>
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
            story.save @getUserId, () =>
                res.contentType 'json'
                res.send { success: true }   
        
        
    createMessage: (req, res, next) =>
        message = new models.Message()
        message.contents = req.body.message
        message.story = req.params.storyid
        message.type = req.body.type
        message.from = @getUserId()
        message.timestamp = new Date().getTime()
        message.save () =>
            res.contentType 'json'
            res.send { success: true }
        
        
    
    createPart: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            part = @getPartFromBody(req.body)
            story.createPart part, req.body.previousParts, @getUserId(), () =>
                res.contentType 'json'
                res.send { success: true, _id: part._id }



    updatePart: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            story.updatePart @getPartFromBody(req.body), @getUserId(), () =>
                res.contentType 'json'
                res.send { success: true }   
                   
                    

    deletePart: (req, res, next) =>                    
        models.Story.getById req.params.storyid, (err, story) =>
            story.deletePart req.params.partid, @getUserId(), () =>
                res.contentType 'json'
                res.send { success: true }   
                
                

    publish: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            story.publish @getUserId(), () =>
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
