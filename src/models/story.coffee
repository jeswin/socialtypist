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


    @getById: (id, cb) =>
        Story._database.findOne 'stories', { '_id': @_database.ObjectId(id) }, (err, result) =>
            cb null, if result then new Story(result)


    
    getParts: (cb) =>
        Story._database.find 'storyparts', { '$or': ({ _id: Story._database.ObjectId(partid) } for partid in @parts)  }, (err, parts) =>
            parts.toArray (err, items) =>
                results = []
                for partid in @parts
                    part = (item for item in items when item._id.toString() == partid)[0]
                    part = new Story._models.StoryPart part
                    results.push part                    
                cb null, results

                    
    
    save: (user, cb) =>
        if not @parts?.length
            @createdBy = user            
            @owners = [user]
            @authors = []
            @parts = []
            super () =>
                async.series [
                        ((cb) =>
                            part = new Story._models.StoryPart()
                            part.type = "HEADING"
                            part.size = 'H2'
                            part.value = "Sample Heading. Click to edit."
                            @addPart part, null, user, cb),                        
                        ((cb) =>
                            part = new Story._models.StoryPart()
                            part.type = "TEXT"
                            part.value = "This is some sample content. Click to edit."
                            @addPart part, @parts[0], user, cb)                        
                    ], () => cb()
                
        else
            #only owners may save
            if @isOwner user._id.toString()
                super cb
            else
                throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }

            
          
          
    addPart: (part, after, user, cb) =>
        #only authors may add a part
        if @isAuthor user._id.toString()
            part.author = user
            part.story = @_id.toString()
            part.save () =>
                @parts.splice (@parts.indexOf(after) + 1), 0, part._id.toString()
                @save user, cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }

    
    
    updatePart: (part, user, cb) =>
        if @isAuthor user._id.toString()
            part.save cb 
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
    
    
    
    removePart: (part, user, cb) =>
        if @isAuthor user._id.toString()
            @parts.splice @parts.indexOf part._id.toString(), 1
            @save cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
        
    
    
    changePart: (oldPart, newPart, user, cb) =>
        if @isAuthor user._id.toString()
            @parts.splice @parts.indexOf oldPart._id.toString(), 1, newPart._id.toString()
            @save cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
        
  

    addChange: (change, cb) =>
        change = 1


        
    addAuthor: (author, user, cb) =>
        if @isOwner user._id.toString()       
            #Confirm is not already an owner.
            existing = (u for u in @authors when u._id.toString() == author._id.toString())
            if not existing.length
                @authors.push author
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeAuthor: (authorId, user, cb) =>
        if @isOwner user._id.toString()
            #See if author is among authors
            existing = (u for u in @authors when u._id.toString() == authorId)
            if exiting.length
                @authors = (u for u in @authors when u._id.toString() != authorId)
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }


    addOwner: (owner, user, cb) =>
        if @isOwner user._id.toString()
            #Confirm is not already an owner.
            existing = (u for u in @owners when u._id.toString() == owner._id.toString())
            if not existing.length
                @owners.push owner
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeOwner: (ownerId, user, cb) =>
        if @isOwner user._id.toString()
            #See if owner is among owners.
            existing = (u for u in @owners when u._id.toString() == ownerId)
            if exiting.length
                @owners = (u for u in @owners when u._id.toString() != ownerId)
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }
            
        
    
    isAuthor: (userId) =>
        authors = (u for u in @authors when u._id.toString() == userId)
        owners = (u for u in @owners when u._id.toString() == userId)
        return authors.length > 0 or owners.length > 0
            
            
        
    isOwner: (userId) =>
        matches = (u for u in @owners when u._id.toString() == userId)
        return matches.length > 0
    

exports.Story = Story
