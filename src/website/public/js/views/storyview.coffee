class StoryView

    constructor: (@story) ->
        $('.author-request-btn').click @showAuthorRequest
        $('.author-request-form .send').click @sendAuthorRequest
        $('.author-request-form .cancel').click @cancelAuthorRequest        



    showAuthorRequest: () =>
        $('.author-request-form').show()
        return false
        
        
        
    sendAuthorRequest: () =>
        $.post "/stories/#{story}/messages", { type: 'AUTHOR_ACCESS_REQUEST', message: $('.author-request-form textarea').val() }, (response) =>
            debugger
            if response.success
                $('.author-request-form').hide()
                $('.author-request-form textarea').val('')
                $('.author-request-btn').replaceWith '<span>Request sent to owner.</span>'
                return false
                
    
        
    cancelAuthorRequest: () =>
        $('.author-request-form').hide()
        $('.author-request-form textarea').val('')
        return false
        


SocialTypist.StoryView = StoryView
