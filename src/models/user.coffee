BaseModel = require('./basemodel').BaseModel

class User extends BaseModel
    
    @_meta = {
        type: User,
        collection: 'users',
        logging: {
            isLogged: true,
            onInsert: 'NEW_USER'
        }
    }


exports.User = User
