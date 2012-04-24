class StoryView

    constructor: (@story) ->
        $('.author-request-btn').click @showAuthorRequest
        $('.author-request-form .send').click @sendAuthorRequest
        $('.author-request-form .cancel').click @cancelAuthorRequest        
        $('.contribute-section .fork-story').click @forkStory


    showAuthorRequest: () =>
        $('.author-request-form').show()
        return false
        
        
        
    sendAuthorRequest: () =>
        $.post "/stories/#{story}/authorRequest", { message: $('.author-request-form textarea').val() }, (response) =>
            if response.success
                $('.author-request-form').hide()
                $('.author-request-form textarea').val('')
                $('.author-request-btn').replaceWith '<span>Request sent to owner.</span>'
                return false
                
    
        
    cancelAuthorRequest: () =>
        $('.author-request-form').hide()
        $('.author-request-form textarea').val('')
        return false
        
        
        
    forkStory: () =>
        $('body').append '
            <div class="modal" id="modal-box">
                <div class="modal-header">
                    <a class="close" data-dismiss="modal">×</a>
                    <h3>Fork a story</h3>
                </div>
                <div class="modal-body">
                    <p>
                        <label>You are creating a copy of this story. Give it a new name.</label>
                        <input type="text" style="width:400px" />
                    </p>
                </div>
                <div class="modal-footer">
                    <a href="#" class="btn">Fork</a>
                    <a href="#">cancel</a>
                </div>
            </div>'
        $('#modal-box').modal()
        ###
        $.post "/stories/#{story}/fork", { }, (response) =>
            
            if response.success
                window.location.href = "/stories/#{response.forkedStory}/edit"
        ###

SocialTypist.StoryView = StoryView
