controller = require('./controller')
dbconf = require '../../models/dbconf'
models = new (require '../../models').Models(dbconf.default)
fs = require 'fs'

class StoriesController extends controller.Controller

    constructor: () ->    
        #These methods needs a logged-in user.
        for fn in ['yours', 'createForm', 'create', 'editForm', 'update', 'createPart', 'updatePart', 'deletePart', 'publish', 'upload']
            @[fn] = @ensureSession @[fn]


    
    show: (req, res, next) =>
        models.Story.getById req.params.storyid, (err, story) =>
            if story
                loginStatus = @getLoginStatus(req)
                if loginStatus.loggedIn
                    owners = (owner for owner in story.owners when owner == @getUserId(req))
                    authors = (author for author in story.authors when author == @getUserId(req))
                    isAuthor = owners.length > 0 or authors.length > 0
                else
                    isAuthor = false
                res.render 'stories/show.hbs', { loginStatus: loginStatus, story: story, isAuthor: isAuthor }
            else
                res.send 'Story does not exist.'
    
    
    
    yours: (req, res, next) =>
        models.Story.getByUserId @getUserId(req), (err, stories) =>
            for story in stories
                story.shortSummary = story.summary
            res.render 'stories/yours.hbs', { loginStatus: @getLoginStatus(req), stories: stories }
    
    
            
    createForm: (req, res, next) =>
        res.render 'stories/create.hbs', { loginStatus: @getLoginStatus(req) }
        
        
    
    create: (req, res, next) =>
        story = new models.Story()
        story.title = @getValue req.body, 'title'
        story.summary = @getValue req.body, 'summary'
        story.tags = @getValue req.body, 'tags'
        story.save @getUserId(req), () =>
            change = new models.Change()
            change.story = story._oid()
            change.type = "NEW_STORY"
            change.save () =>
                res.redirect "/stories/#{story._id}/edit"
          
  
  
    editForm: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            story.getParts (err, parts) =>
                story._objects = { parts: parts }
                res.render 'stories/edit.hbs', { loginStatus: @getLoginStatus(req), story: JSON.stringify story }
        
        
        
    update: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            oldStory = story

            #Right now we only support updating the title.
            @setValues story, req.body, ['title', 'tags', 'slug', 'summary']
            story.save @getUserId(req), () =>

                change = new models.Change()
                change.story = story._oid()
                change.type = "UPDATE_STORY"
                change.oldValue = oldStory
                change.newValue = story

                change.save () =>
                    res.contentType 'json'
                    res.send { success: true }          
        
    
    
    messages: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            story.getMessages @getUserId(req), (err, messages) =>
                res.contentType 'json'
                res.send { success: true, messages: messages }
        


    deleteMessage: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            story.deleteMessage req.params.messageid, @getUserId(req), (err, x) =>
                res.contentType 'json'
                res.send { success: true }


        
    authorRequest: (req, res, next) =>        
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            story.addMessage 'AUTHOR_ACCESS_REQUEST', req.body.message, @getUserId(req), false, () =>            
                res.contentType 'json'
                res.send { success: true }
                
                
                
    addAuthor: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            story.addAuthor @getValue(req.body, 'author'), @getUserId(req), () =>                
                change = new models.Change()
                change.story = story._oid()
                change.type = "ADD_AUTHOR"
                change.author = @getValue(req.body, 'author')
                change.save () =>
                    res.contentType 'json'
                    res.send { success: true }
                
                
                
    removeAuthor: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>        
            story.removeAuthor @getValue(req.params, 'author'), @getUserId(req), () =>
                change = new models.Change()
                change.story = story._oid()
                change.type = "REMOVE_AUTHOR"
                change.author = @getValue(req.body, 'author')
                change.save () =>
                    res.contentType 'json'
                    res.send { success: true }
            
            
       
    createMessage: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            story.addMessage 'MESSAGE', req.body.message, @getUserId(req), true, () =>
                res.contentType 'json'
                res.send { success: true }   

    
  
    fork: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            story.fork @getUserId(req), (err, forked) =>
                res.contentType 'json'
                res.send { success: true, forkedStory: forked._id }   
                
          
    
    createPart: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            part = @getPartFromBody(req.body)
            story.createPart part, req.body.previousParts, @getUserId(req), () =>
                change = new models.Change()
                change.story = story._oid()
                change.type = "CREATE_PART"
                change.user = @getUserId(req)
                change.part = part
                change.save () =>
                    res.contentType 'json'
                    res.send { success: true, _id: part._id }



    updatePart: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            #Get the existing part.
            story.getPart @getValue(req.params, 'partid'), (err, part) =>            
                oldValue = part
                newValue = @getPartFromBody(req.body)
                newValue._id = part._id
                story.updatePart newValue, @getUserId(req), () =>
                    change = new models.Change()
                    change.story = story._oid()
                    change.type = "UPDATE_PART"
                    change.user = @getUserId(req)
                    change.oldValue = oldValue
                    change.newValue = newValue
                    change.save () =>
                        res.contentType 'json'
                        res.send { success: true }   
                   
                    

    deletePart: (req, res, next) =>                    
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            story.getPart @getValue(req.params, 'partid'), (err, part) =>                
                story.deletePart @getValue(req.params, 'partid'), @getUserId(req), () =>
                    change = new models.Change()
                    change.story = story._oid()
                    change.type = "DELETE_PART"
                    change.user = @getUserId(req)
                    change.part = part
                    change.save () =>
                        res.contentType 'json'
                        res.send { success: true }   
                
                

    publish: (req, res, next) =>
        models.Story.getById @getValue(req.params, 'storyid'), (err, story) =>
            story.publish @getUserId(req), () =>
                change = new models.Change()
                change.story = story._oid()
                change.type = "PUBLISH_STORY"
                change.user = @getUserId(req)
                change.save () =>
                    res.contentType 'json'
                    res.send { success: true }   
          
        
    
    upload: (req, res, next) =>
    	if (req.files)
            targetPath = "./public/images/content/#{@getValue(req.params, 'storyid')}_#{req.files.file.name}"            
            fs.rename req.files.file.path, targetPath, (err) =>
                res.send "/public/images/content/#{@getValue(req.params, 'storyid')}_#{req.files.file.name}"
                           
        
          
    getPartFromBody: (body) =>
        part = new models.StoryPart()
        part.type = body.type
        part.value = @getValue body, 'value'
        if body.type == 'HEADING'
            part.size = @getValue body, 'size'
        if body.type == "VIDEO"
            part.source = @getValue body, 'source'
        return part
       
            
    
exports.StoriesController = StoriesController
