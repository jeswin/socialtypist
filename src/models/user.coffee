BaseModel = require('./basemodel').BaseModel

class User extends BaseModel
    
    @_meta: {
        type: User,
        collection: 'users',
        logging: {
            isLogged: true,
            onInsert: 'NEW_USER'
        }
    }
    
    save: (cb) =>
        if not @_id?
            @ownedStories = []
            @authoredStories = []
            @cache = {}
        super cb


    getBasicInfo: () =>
        return {
            _id: @_id.toString(),
            username: @username,
            name: @name,
            firstName: @firstName,
            lastName: @lastName,
            domain: @domain,
            domainid: @domainid,
            location: @location
        }

exports.User = User
