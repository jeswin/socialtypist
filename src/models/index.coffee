User = require('./user').User
Story = require('./story').Story
Part = require('./part').Part
Event = require('./event').Event

class Models
    constructor: (@dbconf) ->
        @User = User
        @Story = Story
        @Part = Part
        @Event = Event
        
        @initModel(model) for model in [User, Story, Part, Event]

    initModel: (model) ->
        model._database = new (require '../common/database').Database(@dbconf)
        model._models = this

exports.Models = Models
