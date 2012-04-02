BaseModel = require('./basemodel').BaseModel

class Story extends BaseModel

    @_meta = {
        type: Story,
        collection: 'stories',
        logging: {
            isLogged: true,
            onInsert: 'NEW_STORY'
        }
    }

    
    save: (user, cb) =>
        if not this.parts?.length
            part = new Story._models.Part()
            part.type = "MARKER"
            part.value = "START"
            part.save () =>
                this.parts = [part._id.toString()]
                this.owners = [user]
                Story.__super__.save.apply @, [cb] #coz CS will complain calling super from anon functions, at least for now.                
        else
            #only owners may save
            if @isOwner user
                super cb
            else
                throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }
            

           
    addPart: (part, after, user, cb) =>
        #only authors may add a part
        if @isAuthor user
            part.author = user
            part.save () =>
                @parts.splice (@parts.indexOf(after) + 1), 0, part._id.toString()
                @save cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }

    
    
    updatePart: (part, user, cb) =>
        if @isAuthor user
            part.save cb 
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
    
    
    
    removePart: (part, user, cb) =>
        if @isAuthor user
            @parts.splice @parts.indexOf part._id.toString(), 1
            @save cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
        
    
    
    changePart: (oldPart, newPart, user, cb) =>
        if @isAuthor user
            @parts.splice @parts.indexOf oldPart._id.toString(), 1, newPart._id.toString()
            @save cb
        else
            throw { type: 'NOT_AUTHOR', message: 'You are not an author on this story. Cannot modify.' }
        
        
    addAuthor: (author, user, cb) =>
        if @isOwner user            
            if @authors.indexOf(author) == -1
                @authors.push author
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeAuthor: (author, user, cb) =>
        if @isOwner user
            if @authors.indexOf(author) > -1
                @authors.splice @authors.indexOf author, 1
                @save cb                
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }


    addOwner: (owner, user, cb) =>
        if @isOwner user
            if @owners.indexOf(owner) == -1
                @owners.push owner
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }



    removeOwner: (owner, user, cb) =>
        if @isOwner user
            if @owners.indexOf(owner) > -1
                @owners.splice @owners.indexOf owner, 1
                @save cb
        else
            throw { type: 'NOT_OWNER', message: 'You do not own this story. Cannot modify.' }
            
        
    
    isAuthor: (username) =>
        return owners.indexOf(username) > -1 or authors.indexOf(username) > -1
            
            
        
    isOwner: (username) =>
        return owners.indexOf(username) > -1
    


exports.Story = Story
