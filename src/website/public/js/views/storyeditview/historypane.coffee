class HistoryPane

    constructor: (@story, @editor, @view) ->
        @fetchHistory()
    
    
    
    fetchHistory: () =>
        $.get "/stories/#{story._id}/history", (response) =>
            console.log JSON.stringify response
            
            

this.SocialTypist.StoryEditView.HistoryPane = HistoryPane                
