User = require('./user').User
Story = require('./story').Story
StoryPart = require('./storypart').StoryPart
StoryChange = require('./storychange').StoryChange
Message = require('./message').Message
Event = require('./event').Event

class Models
    constructor: (@dbconf) ->
        @User = User
        @Story = Story
        @StoryPart = StoryPart
        @StoryChange = StoryChange
        @Message = Message
        @Event = Event
        
        @initModel(model) for model in [User, Story, StoryPart, StoryChange, Message, Event]

    initModel: (model) ->
        model._database = new (require '../common/database').Database(@dbconf)
        model._models = this

exports.Models = Models
