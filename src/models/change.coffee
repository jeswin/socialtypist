BaseModel = require('./basemodel').BaseModel

class Change extends BaseModel

    @_meta: {
        type: Change,
        collection: 'changes'
    }
    
    
    save: (cb) =>
        @timestamp = new Date().getTime()
        super cb
        


exports.Change = Change
