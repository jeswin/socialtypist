BaseModel = require('./basemodel').BaseModel

class StoryChange extends BaseModel

    @_meta: {
        type: StoryChange,
        collection: 'storychanges'
    }


exports.StoryChange = StoryChange
