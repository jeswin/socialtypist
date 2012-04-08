async = require 'async'
BaseModel = require('./basemodel').BaseModel

class Story extends BaseModel

    @_meta: {
        type: Story,
        collection: 'stories',
        logging: {
            isLogged: true,
            onInsert: 'NEW_STORY'
        }
    }

    ###
        Gets the story with the specified id (string).
    ###
    @getById: (id, cb) =>
        Story._database.findOne 'stories', { '_id': @_database.ObjectId(id) }, (err, result) =>
            cb null, if result then new Story(result)


    ###
        Gets all the parts in the story.
    ###
    getParts: (cb) =>
        Story._database.find 'storyparts', { '$or': ({ _id: Story._database.ObjectId(partId) } for partId in @parts)  }, (err, parts) =>
            parts.toArray (err, items) =>
                results = []
                for partId in @parts
                    part = (item for item in items when item._id.toString() == partId)[0]
                    part = new Story._models.StoryPart part
                    results.push part                    
                cb null, results

                    
    ###
        Saves a story.
    ###
    save: (user, cb) =>
        if not @parts?.length
            @createdBy = user
            @owners = [user]
            @authors = []
            @parts = []
            @published = false
            super () =>
                async.series [
                        ((cb) =>
                            part = {}
                            part.type = "HEADING"
                            part.size = 'H2'
                            part.value = "Sample Heading. Click to edit."
                            @addPart part, null, user, cb),                        
                        ((cb) =>
                            part = {}
                            part.type = "TEXT"
                            part.value = "This is some sample content. Click to edit."
                            @addPart part, [@parts[0]], user, cb)                        
                    ], () => cb()
                
        else
            #Only owners may save
            if @isOwner user
                super cb
            else
                throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }

            
  
    ###
        Adds a new part to the story.
            1. previousParts is a list of part-ids which occur before the newly added part. 
               Insertion will happen at the first "previous-part" found in the @parts collection, when previousParts is walked backwards.
    ###
    addPart: (part, previousParts, user, cb) =>
        #only authors may add a part
        if @isAuthor user
            part.author = user
            part.story = @_id.toString()
            part.save () =>
                # previousParts will be originally of the form [ad,sv,fd,cf,dg]. 
                # We need to start looking from the bottom, since current part was added after dg.
                previousParts = previousParts.reverse()
                        
                insertAt = 0 #Will insert at 0 if no other location is found. But this is unlikely.
                for previous in previousParts
                    #Insert after the first found previous part.
                    index = @parts.indexOf previous
                    if index != -1
                        insertAt = index
                        break
                        
                @parts.splice insertAt, 0, part._id.toString()                    
                @save user, cb

        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }

    
    
    updatePart: (part, user, cb) =>
        if @isAuthor user                            
            part.save cb 
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
    
    
    
    removePart: (part, user, cb) =>
        if @isAuthor user
            index = @parts.indexOf part._id.toString()
            if index != -1
                @parts.splice index, 1
                @save cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
        
  
       
    addAuthor: (author, user, cb) =>
        if @isOwner user
            #Confirm is not already an owner.
            if @authors.indexOf author == -1
                @authors.push author
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeAuthor: (author, user, cb) =>
        if @isOwner user
            #See if author is among authors
            if @authors.indexOf author > -1
                @authors = (u for u in @authors when u != author)
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    addOwner: (owner, user, cb) =>
        if @isOwner user
            #Confirm is not already an owner.
            if @owners.indexOf owner == -1
                @owners.push owner
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeOwner: (owner, user, cb) =>
        if @isOwner user
            #See if owner is among owners.
            if @owners.indexOf owner > -1
                @owners = (u for u in @owners when u != owner)
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }
            
        
    
    isAuthor: (user) =>
        @owners.indexOf user > -1 or @authors.indexOf user > -1
            
            
        
    isOwner: (user) =>
        @owners.indexOf user > -1
    

exports.Story = Story
