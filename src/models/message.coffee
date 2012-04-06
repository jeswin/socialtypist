BaseModel = require('./basemodel').BaseModel

class Message extends BaseModel

    @_meta: {
        type: Message,
        collection: 'messages'
    }


exports.Message = Message
