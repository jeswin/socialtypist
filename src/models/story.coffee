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



    fork: (userid, cb) =>
        forked = new Story(@)
        delete forked._id
        
        forked.forkSource = @_oid()
        forked.forkRoot = if @forkRoot? then @forkRoot else @_oid()

        if forked.updatedBy
            delete forked.updatedBy                     
        if forked.published
            delete forked.published
            delete forked.publishedTimestamp
            delete forked.publishedDate
        
        forked.save userid, () =>
            #copy all the parts.
            @getParts (err, parts) =>
            
                partSave = (part) =>
                    (cb) =>
                        part = new Story._models.StoryPart part
                        delete part._id    
                        part.createdBy = userid
                        part.story = forked._oid()
                        part.save () =>
                            cb()
            
                async.series (partSave part for part in parts), () =>
                    cb null, forked


    getShortSummary: () =>
        @summary ? ''
        


    getParts: (cb) =>
        Story._models.StoryPart.getAll { '$or': ({ _id: Story._database.ObjectId(partId) } for partId in @parts)  }, (err, items) =>
            results = []
            for partId in @parts
                part = (item for item in items when item._id.toString() == partId)[0]
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
        if not @_id?
            @createdBy = userid
            @owners = [userid]
            @authors = []
            @parts = []
            @title = sanitize @title, allowedTags, allowedAttributes
            @forks = []
            @cache = {
                html: '',
                owners: [],
                authors: []
            }
            
            super () =>
                async.series [
                        #Also modify the user, and add this to the stories owned.
                        ((cb) =>
                            Story._models.User.getById userid, (err, user) =>
                                user.ownedStories.push @_oid()
                                @cache.owners.push user.getBasicInfo()
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
        
        if not @published
            @published = true
            
            today = new Date()
            @publishedTimestamp = today.getTime()
            
            year = today.getYear() + 1900
            month = today.getMonth()
            month = if month < 10 then '0' + month else month
            date = today.getDate()
            date = if date < 10 then '0' + date else date            
            @publishedDate = year + month + date + ''
                        
        #update cache.
        @cache.html = markdown '#' + @title, true, allowedTags, allowedAttributes
        @getParts (err, parts) =>        
            for part in parts                
                @cache.html += part.getHtml()
                
            @save userid, cb
  
  
  
    ###
        Adds a new part to the story.
            1. previousParts is a list of part-ids which occur before the newly added part. (Walked backwards in the DOM, if dom has #a, #b, #c, previousParts = [c,b,a])
               Insertion will happen at the first "previous-part" found in the @parts collection. 
    ###
    createPart: (part, previousParts, userid, cb) =>
        #only authors may add a part
        if @isAuthor userid
            part.createdBy = userid
            part.story = @_oid()
            part.timestamp = new Date().getTime()
            part.save () =>  
                insertAt = 0 #Will insert at 0 if no other location is found. But this is unlikely.                
                if previousParts                    
                    for previous in previousParts
                        #Insert after the first found previous part.
                        index = @parts.indexOf(previous)
                        if index != -1
                            insertAt = index + 1
                            break
                        
                @parts.splice insertAt, 0, part._oid()                    
                @save userid, cb

        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }


    
    getPart: (id, cb) =>
        Story._models.StoryPart.getById id, (err, part) =>
            if part.story is @_oid()
                cb err, part
            else
                throw { type: "PART_NOT_IN_STORY", "The requested part is not in this story." }

    
    
    updatePart: (part, userid, cb) =>
        if @isAuthor userid
            part.updatedBy = userid
            part.timestamp = new Date().getTime()
            part.save cb 
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
    
    
    
    deletePart: (part, userid, cb) =>
        if @isAuthor userid
            index = @parts.indexOf(part)
            if index != -1
                @parts.splice index, 1
                @save userid, cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
        
    
          
    addAuthor: (author, userid, cb) =>
        if @isOwner userid
            #Confirm if not already an owner.
            if @authors.indexOf(author) == -1
                Story._models.User.getById author, (err, user) =>
                    @authors.push author
                    @cache.authors.push user
                    @save userid, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeAuthor: (author, userid, cb) =>
        if @isOwner userid
            #See if author is among authors
            if @authors.indexOf(author) > -1
                @authors = (u for u in @authors when u != author)
                @cache.authors = (u for u in @cache.authors when u._id.toString() != author)
                @save userid, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    addOwner: (owner, userid, cb) =>
        if @isOwner userid
            #Confirm is not already an owner.
            if @owners.indexOf(owner) == -1
                Story._models.User.getById author, (err, user) =>                    
                    @owners.push owner
                    @cache.owners.push user
                    @save userid, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeOwner: (owner, userid, cb) =>
        if @isOwner userid
            #See if owner is among owners.
            if @owners.indexOf(owner) > -1
                @owners = (u for u in @owners when u != owner)
                @cache.owners = (u for u in @cache.owners when u._id.toString() != owner)
                @save userid, cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }


    
    getMessages: (userid, cb) =>
        if @isAuthor userid
            Story._models.Message.getAll { story: @_oid(), deleted: false }, (err, messages) =>
                cb err, messages?.reverse()
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot fetch.' }
            
    
    
    addMessage: (type, content, userid, checkAccess, cb) =>
        if (checkAccess and @isAuthor userid) or not checkAccess
            Story._models.User.getById userid, (err, user) =>
                message = new Story._models.Message()            
                message.type = type
                message.content = content
                message.from = userid
                message.cache = { from: { domainid: user.domainid, name: user.name, location: user.location } }
                message.story = @_oid()
                message.deleted = false
                message.save () =>
                    cb()
        
        
    deleteMessage: (messageid, userid, cb) =>
        if @isOwner userid
            Story._models.Message.getById messageid, (err, message) =>
                message.deleted = true
                message.save cb
        else
            throw { type: 'NOT_OWNER', message: 'Only owners may delete a message.' }
        
    
    
    isAuthor: (userid) =>
        @owners.indexOf(userid) > -1 or @authors.indexOf(userid) > -1
            
            
        
    isOwner: (userid) =>
        @owners.indexOf(userid) > -1
        

        
    #TODO
    recreateCache: () =>
        
    

exports.Story = Story
