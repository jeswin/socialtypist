BaseModel = require('./basemodel').BaseModel

class Change extends BaseModel

    @_meta: {
        type: Change,
        collection: 'changes'
    }


exports.Change = Change
