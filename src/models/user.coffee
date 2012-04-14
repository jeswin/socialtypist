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


exports.User = User
