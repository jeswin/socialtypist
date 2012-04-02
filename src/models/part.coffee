BaseModel = require('./basemodel').BaseModel

class Part extends BaseModel

    @_meta = {
        type: Part,
        collection: 'parts'
    }


exports.Part = Part
