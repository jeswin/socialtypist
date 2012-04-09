async = require 'async'
BaseModel = require('./basemodel').BaseModel
markdown = require("node-markdown").Markdown
sanitize = require("../common/mdsanitizer").sanitize

class Story extends BaseModel

    @_meta: {
        type: Story,
        collection: 'stories',
        logging: {
            isLogged: true,
            onInsert: 'NEW_STORY'
        }
    }



    @getById: (id, cb) =>
        Story._database.findOne 'stories', { '_id': @_database.ObjectId(id) }, (err, result) =>
            cb null, if result then new Story(result)



    getParts: (cb) =>
        Story._database.find 'storyparts', { '$or': ({ _id: Story._database.ObjectId(partId) } for partId in @parts)  }, (err, parts) =>
            parts.toArray (err, items) =>
                results = []
                for partId in @parts
                    part = (item for item in items when item._id.toString() == partId)[0]
                    part = new Story._models.StoryPart part
                    results.push part                    
                cb null, results



    save: (user, cb) =>
        allowedTags = 'a|b|blockquote|code|del|dd|dl|dt|em|h1|h2|h3|h4|h5|h6|i|img|li|ol|p|pre|sup|sub|strong|strike|ul|br|hr'
        allowedAttributes = {
            'img': 'src|width|height|alt',
            'a':   'href',
            '*':   'title'
        }
    
        @timestamp = new Date().getTime()
        if not @_id
            @createdBy = user
            @owners = [user]
            @authors = []
            @parts = []
            @published = false
            @title = sanitize @title, allowedTags, allowedAttributes
            super () =>
                async.series [
                        ((cb) =>
                            part = new Story._models.StoryPart()
                            part.type = "HEADING"
                            part.size = 'H2'
                            part.value = "Sample Heading. Click to edit."
                            @createPart part, null, user, cb),                        
                        ((cb) =>
                            part = new Story._models.StoryPart()
                            part.type = "TEXT"
                            part.value = "This is some sample content. Click to edit."
                            @createPart part, [@parts[0]], user, cb)                        
                    ], () => cb()
                
        else
            #Only owners may save
            if @isOwner user
                @title = sanitize @title, allowedTags, allowedAttributes
                super cb
            else
                throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }

            
            
    publish: (user, cb) =>
        allowedTags = 'a|b|blockquote|code|del|dd|dl|dt|em|h1|h2|h3|h4|h5|h6|i|img|li|ol|p|pre|sup|sub|strong|strike|ul|br|hr'
        allowedAttributes = {
            'img': 'src|width|height|alt',
            'a':   'href',
            '*':   'title'
        }
              
        @html = markdown '#' + @title, true, allowedTags, allowedAttributes

        @getParts (err, parts) =>
        
            for part in parts                
                @html += part.getHtml()
                
            @save user, cb
  
  
    ###
        Adds a new part to the story.
            1. previousParts is a list of part-ids which occur before the newly added part. (Walked backwards in the DOM, if dom has #a, #b, #c, previousParts = [c,b,a])
               Insertion will happen at the first "previous-part" found in the @parts collection. 
    ###
    createPart: (part, previousParts, user, cb) =>
        #only authors may add a part
        if @isAuthor user
            part.author = user
            part.story = @_id.toString()
            part.timestamp = new Date().getTime()
            part.save () =>
                        
                insertAt = 0 #Will insert at 0 if no other location is found. But this is unlikely.
                
                if previousParts                    
                    for previous in previousParts
                        #Insert after the first found previous part.
                        index = @parts.indexOf previous
                        if index != -1
                            insertAt = index + 1
                            break
                        
                @parts.splice insertAt, 0, part._id.toString()                    
                @save user, cb

        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }

    
    
    updatePart: (part, user, cb) =>
        if @isAuthor user
            part.timestamp = new Date().getTime()
            part.save cb 
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
    
    
    
    deletePart: (part, user, cb) =>
        if @isAuthor user
            index = @parts.indexOf part
            if index != -1
                @parts.splice index, 1
                @save user, cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
        
    
          
    addAuthor: (author, user, cb) =>
        if @isOwner user
            #Confirm is not already an owner.
            if @authors.indexOf author == -1
                @authors.push author
                @save user, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeAuthor: (author, user, cb) =>
        if @isOwner user
            #See if author is among authors
            if @authors.indexOf author > -1
                @authors = (u for u in @authors when u != author)
                @save user, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    addOwner: (owner, user, cb) =>
        if @isOwner user
            #Confirm is not already an owner.
            if @owners.indexOf owner == -1
                @owners.push owner
                @save user, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeOwner: (owner, user, cb) =>
        if @isOwner user
            #See if owner is among owners.
            if @owners.indexOf owner > -1
                @owners = (u for u in @owners when u != owner)
                @save user, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }
            
        
    
    isAuthor: (user) =>
        @owners.indexOf user > -1 or @authors.indexOf user > -1
            
            
        
    isOwner: (user) =>
        @owners.indexOf user > -1
        
        
    

exports.Story = Story
