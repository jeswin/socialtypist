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


    
    @getByUserId: (userid, cb) =>
        Story._models.User.getById userid, (err, user) =>
            allStories = user.ownedStories.concat user.authoredStories
            Story.getAll { '$or': ({ '_id' : @_database.ObjectId(id) } for id in allStories) }, cb



    getParts: (cb) =>
        Story._models.StoryPart.getAll { '$or': ({ _id: Story._database.ObjectId(partId) } for partId in @parts)  }, (err, items) =>
            results = []
            for partId in @parts
                part = (item for item in items when item._oid() == partId)[0]
                part = new Story._models.StoryPart part
                results.push part                    
            cb null, results



    save: (userid, cb) =>
        allowedTags = 'a|b|blockquote|code|del|dd|dl|dt|em|h1|h2|h3|h4|h5|h6|i|img|li|ol|p|pre|sup|sub|strong|strike|ul|br|hr'
        allowedAttributes = {
            'img': 'src|width|height|alt',
            'a':   'href',
            '*':   'title'
        }
    
        @timestamp = new Date().getTime()
        if not @_id
            @createdBy = userid
            @owners = [userid]
            @authors = []
            @parts = []
            @published = false
            @title = sanitize @title, allowedTags, allowedAttributes
            
            super () =>
                async.series [
                        #Also modify the user, and add this to the stories owned.
                        ((cb) =>
                            Story._models.User.getById userid, (err, user) =>
                                console.log @_oid()
                                user.ownedStories.push @_oid()
                                user.save () =>
                                    cb())
                        ((cb) =>
                            part = new Story._models.StoryPart()
                            part.type = "HEADING"
                            part.size = 'H2'
                            part.value = "Sample Heading. Click to edit."
                            @createPart part, null, userid, cb),                        
                        ((cb) =>
                            part = new Story._models.StoryPart()
                            part.type = "TEXT"
                            part.value = "This is some sample content. Click to edit."
                            @createPart part, [@parts[0]], userid, cb)                        
                    ], () => cb()
                    
                
        else
            #Only owners may save
            if @isOwner userid
                @title = sanitize @title, allowedTags, allowedAttributes
                super cb
            else
                throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }

            
            
    publish: (userid, cb) =>
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
                
            @save userid, cb
  
  
    ###
        Adds a new part to the story.
            1. previousParts is a list of part-ids which occur before the newly added part. (Walked backwards in the DOM, if dom has #a, #b, #c, previousParts = [c,b,a])
               Insertion will happen at the first "previous-part" found in the @parts collection. 
    ###
    createPart: (part, previousParts, userid, cb) =>
        #only authors may add a part
        if @isAuthor userid
            part.author = userid
            part.story = @_oid()
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
                        
                @parts.splice insertAt, 0, part._oid()                    
                @save userid, cb

        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }

    
    
    updatePart: (part, userid, cb) =>
        if @isAuthor userid
            part.timestamp = new Date().getTime()
            part.save cb 
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
    
    
    
    deletePart: (part, userid, cb) =>
        if @isAuthor userid
            index = @parts.indexOf part
            if index != -1
                @parts.splice index, 1
                @save userid, cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
        
    
          
    addAuthor: (author, userid, cb) =>
        if @isOwner userid
            #Confirm is not already an owner.
            if @authors.indexOf author == -1
                @authors.push author
                @save userid, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeAuthor: (author, userid, cb) =>
        if @isOwner userid
            #See if author is among authors
            if @authors.indexOf author > -1
                @authors = (u for u in @authors when u != author)
                @save userid, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    addOwner: (owner, userid, cb) =>
        if @isOwner userid
            #Confirm is not already an owner.
            if @owners.indexOf owner == -1
                @owners.push owner
                @save userid, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeOwner: (owner, userid, cb) =>
        if @isOwner userid
            #See if owner is among owners.
            if @owners.indexOf owner > -1
                @owners = (u for u in @owners when u != owner)
                @save userid, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }
            
        
    
    isAuthor: (userid) =>
        @owners.indexOf userid > -1 or @authors.indexOf userid > -1
            
            
        
    isOwner: (userid) =>
        @owners.indexOf userid > -1
        
        
    

exports.Story = Story
