class MessagesPane

    constructor: (@story, @editor, @view) ->
        @editor.find('.tab-content').html('<div class="message-pane"></div>')
        @container = @editor.find('.message-pane')
        @container.html '
            <p class="show-send-message">
                <a href="#" class="btn">New message</a> <span class="padded help-inline">Message goes to all authors.</span>
            </p>
            <div class="add-message" style="display:none">
                <form class="well">
                    <p>
                        <textarea rows="6" style="width:90%"></textarea>
                        <br />
                        <a class="btn btn-small send" href="#">Send Message</a> <a href="#" class="cancel">cancel</a>
                    </p>
                </form>
            </div>
            <div class="message-list section">
            </div>'
            
        @container.find('.show-send-message a.btn').click @showAddMessage
        @container.find('.add-message .btn.send').click @addMessage
        @container.find('.add-message .cancel').click @cancelAddMessage
        
        @loadMessages()
    
    
    showAddMessage: () =>
        @container.find('.show-send-message').hide()
        @container.find('.add-message textarea').val('')
        @container.find('.add-message').show()
        false
    
    
    cancelAddMessage: () =>
        @container.find('.add-message').hide()
        @container.find('.show-send-message').show()
        false
        
    
    addMessage: () =>
        $.post "/stories/#{@story._id}/messages", { message: @container.find('.add-message textarea').val() }, (response) =>
            if response.success
                @container.find('.add-message').hide()
                @container.find('.show-send-message').show()
                @loadMessages()
        false
    
    
    loadMessages: () =>
        $.get "/stories/#{@story._id}/messages", (response) =>
            @container.find('.message-list').html '<ul class="iconic-summary"></ul>'
            messageListElem = @container.find('.message-list ul')
            
            for message in response.messages
                try
                    if message.type is 'AUTHOR_ACCESS_REQUEST'

                        if message.content
                            _content = "<div class=\"text-section\">#{message.content}</div>"
                        else
                            _content = ''
                           
                        messageListElem.append "
                            <li>
                                <div class=\"icon\">
                                    <img src=\"http://graph.facebook.com/#{message.cache.from.domainid}/picture?type=square\" />
                                </div>
                                <div class=\"summary\">
                                    <h2 style=\"display:inline\">#{message.cache.from.name}</h2> wants to co-author this story. 
                                        <a href=\"#\" class=\"approve-author\">Approve</a> or <a href=\"#\" class=\"unsafe reject-author\">reject</a>?
                                    #{_content}
                                </div>
                            </li>"
                        
                        author = message.from
                        messageListElem.children('li').last().find('.approve-author').click () =>
                            $.post "/stories/#{@story._id}/authors", { author: author }, (response) =>
                                if response.success
                                    $.delete_ "/stories/#{@story._id}/messages/#{message._id}", (response) =>
                                        @loadMessages()
                            false
                        messageListElem.children('li').last().find('.reject-author').click () =>
                            $.delete_ "/stories/#{@story._id}/messages/#{message._id}", (response) =>
                                @loadMessages()
                            false

                            
                    else
                        messageListElem.append "
                            <li>
                                <div class=\"icon\">
                                    <img src=\"http://graph.facebook.com/#{message.cache.from.domainid}/picture?type=square\" />
                                </div>
                                <div class=\"summary\">
                                    <h2>#{message.cache.from.name}</h2>
                                    <div class=\"text-section\">
                                        #{message.content}
                                    </div>
                                </div>
                            </li>"
                catch err
                    console.log JSON.stringify err

                
    
this.SocialTypist.StoryEditView.MessagesPane = MessagesPane
