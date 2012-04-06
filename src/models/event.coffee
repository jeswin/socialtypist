BaseModel = require('./basemodel').BaseModel

class Event extends BaseModel

    @_meta: {
        type: Event,
        collection: 'events'
    }
    
exports.Event = Event
