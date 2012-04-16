class StoryEditView

    constructor: (@story, @editor) ->
        @setupNav()
        @setActiveTab 'content'
        @renderRightPane()
        


    setupNav: () =>
        @editor.find('.nav-settings a').click () => @setActiveTab 'settings'
        @editor.find('.nav-content a').click () => @setActiveTab 'content'
        @editor.find('.nav-messages a').click () => @setActiveTab 'messages'
        @editor.find('.nav-history a').click () => @setActiveTab 'history'
        


    setActiveTab: (tab) ->
        @editor.find('.tab-content').html ''
        @editor.find('.nav-pills li').removeClass 'active'
        switch tab
            when 'settings'
                @editor.find('.nav-pills li.nav-settings').addClass 'active'
                new SettingsPane @story, @editor, @
            when 'content' 
                @editor.find('.nav-pills li.nav-content').addClass 'active'                
                new ContentPane @story, @editor, @
            when 'messages'
                @editor.find('.nav-pills li.nav-messages').addClass 'active'                            
                new MessagePane @story, @editor, @
            when 'history' 
                @editor.find('.nav-pills li.nav-history').addClass 'active'                            
                new HistoryPane @story, @editor, @



    renderRightPane: () =>
        @populateAuthors()
        @setupLiveUpdate()



    populateAuthors: () =>
        authorsContainer = @editor.find('.rpane .authors')
        authorsContainer.html '
            <h3>Authors</h3>
            <ul class="iconic-summary"></ul>'
        authorsElem = authorsContainer.find 'ul'
        
        authors = @story.cache.owners.concat @story.cache.authors
        
        for author in authors
            authorsElem.append "
                <li>
                    <div class=\"icon\">
                        <img src=\"http://graph.facebook.com/#{author.domainid}/picture?type=square\" />
                    </div>
                    <div class=\"summary\">
                        <h3>#{author.name}</h3>
                        <p>Owner</p>
                    </div>
                </li>"


    
    setupLiveUpdate: () =>



class MessagePane

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
        
    
    
    cancelAddMessage: () =>
        @container.find('.add-message').hide()
        @container.find('.show-send-message').show()
        
        
    
    addMessage: () =>
        $.post "/stories/#{@story._id}/messages", { message: @container.find('.add-message textarea').val() }, (err, response) =>
            if response.success
                @container.find('.add-message').hide()
                @container.find('.show-send-message').show()
    
    
    
    loadMessages: () =>
        $.get "/stories/#{@story._id}/messages", (response) =>
            @container.find('.message-list').html '<ul class="iconic-summary"></ul>'
            messageListElem = @container.find('.message-list ul')
            
            for message in response.messages
                try
                    if message.type is 'AUTHOR_ACCESS_REQUEST'
                        messageListElem.append "
                            <li>
                                <div class=\"icon\">
                                    <img src=\"http://graph.facebook.com/#{message.cache.from.domainid}/picture?type=square\" />
                                </div>
                                <div class=\"summary\">
                                    <h2>#{message.cache.from.name}</h2>
                                    <div class=\"text\">
                                        #{message.content}
                                    </div>
                                </div>
                            <li>"
                    else
                        messageListElem.append "
                            <li>
                                <div class=\"icon\">
                                    <img src=\"http://graph.facebook.com/#{message.cache.from.domainid}/picture?type=square\" />
                                </div>
                                <div class=\"summary\">
                                    <h2>#{message.cache.from.name}</h2>
                                    <div class=\"text\">
                                        #{message.content}
                                    </div>
                                </div>
                            <li>"
                catch err
                            
        
    


class SettingsPane

    constructor: (@story, @editor, @view) ->
        @editor.find('.tab-content').html('<div class="settings-pane"></div>')
        @container = @editor.find('.settings-pane')

        #create a slug
        slug = @story.title.toLowerCase().replace(/[^\w ]+/g,'').replace(/\ +/g,'-')

        prefix = @story.publishedDate        
        if not prefix
            today = new Date()            
            year = today.getYear() + 1900
            month = today.getMonth()
            month = if month < 10 then '0' + month else month
            date = today.getDate()
            date = if date < 10 then '0' + date else date                
            prefix = year + month + date + ''
            
        
        @container.html "
            <form>
                <p>
                    <label>Tags</label>
                    <input type=\"text\" value=\"#{@story.tags}\" class=\"span6\" />
                </p>
                <p>
                    <label>Url for your story</label>
                    <span class=\"light\">socialtypist.com/#{prefix}/</span><input type=\"text\" value=\"#{slug}\" class=\"span6\" /><br />
                </p>
                <p>
                    <label>Description (optional)</label>
                    <textarea class=\"span6\" rows=\"6\"></textarea>
                </p>
                <p>
                    <a class=\"btn save\" href=\"#\">Save Settings</a>
                </p>
            </form>
            <hr />"
            
        owners = ({ type: 'owner', user: user } for user in @story.cache.owners)
        authors = ({ type: 'author', user: user } for user in @story.cache.authors)
        all = (u for u in (owners.concat authors) when u.user._id == @story.createdBy)

        if all.length
            @container.append "
                <h3>Authors</h3>
                <ul class=\"authors iconic-summary\">
                </ul>"
                    
            authorsElem = @container.find('.authors')
            for i in all
                authorsElem.append "
                    <li>
                        <div class=\"icon\">
                            <img src=\"http://graph.facebook.com/#{i.user.domainid}/picture?type=square\" />
                        </div>
                        <div class=\"summary\">
                            <h3>#{i.user.name}</h3>
                            <p class=\"author-actions\"></p>
                        </div>
                    </li>"
                
                actionElem = authorsElem.find('li p.author-actions').last()
                if i.user._id != @story.createdBy                    
                    if i.type == 'owner'
                        actionElem.html '<a href="#" class="remove">remove</a>'
                else
                    actionElem.html 'owner'
        

class ContentPane
    
    constructor: (@story, @editor, @view) ->
        @editor.find('.tab-content').html('<div class="story"></div>')
        @container = $(@editor.find('.story'))

        @showdown = new Showdown.converter()
        @editor.find('.publish-button').click () =>
            $.post "/stories/#{@story._id}/publish", () =>
                window.location.href = "/stories/#{@story._id}"

        @createTitle()        
        @createParts()        


    
    createTitle: () =>
        @container.append "<div class=\"editable title\"><h1>#{@story.title}</h1></div>"
        title = @container.find('.editable.title')
        title.data 'title', @story.title
        title.click () =>
            @editTitle()            



    editTitle: () =>
        editable = $('#story-editor .editable.title')        

        editable.unbind 'click' #unbind for now. rebind once we are done editing.
        editable.addClass 'selected'
        val = editable.data 'title'

        editable.html "
            <form class=\"title-editor\">
                <input type=\"text\" class=\"span6\" /><br />
                <p class=\"left\">
                    <a class=\"save btn small action\" href=\"#\"><i class=\"icon-ok\"></i>Save section</a> <i class=\"icon-remove\"></i><a class=\"cancel small action\" href=\"#\">cancel</a>
                </p>
                <hr />
                <p class=\"add-section\"><i class=\"icon-arrow-down\"></i><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"


        editable.find('.title-editor input').val val

        editable.find('a.save').click () =>
            @saveTitle()
            return false
            
        editable.find('a.cancel').click () =>
            @cancelTitleEdit()
            return false

        editable.find('.insert').click () =>
            @addSection 'start'
            return false           

        #Pressing enter in the input box should do a save. 
        editable.find('input').keypress (e) =>
            if e.which == 13
                @saveTitle()
                return false

   
    saveTitle: () =>
        editable = $('#story-editor .editable.title')
        val = $('.title-editor input').val()
        $.put "/stories/#{story._id}", { title: val }, (response) =>
            if response.success
                editable.click () =>
                    @editTitle()
                editable.removeClass 'selected'
                editable.html "<h1 class=\"title\">#{val}</h1>"
                editable.data 'title', val
        

    
    cancelTitleEdit: () =>
        editable = $('#story-editor .editable.title')
        editable.click () =>
            @editTitle()
        editable.removeClass 'selected'
        editable.html "<h1 class=\"title\">#{editable.data 'title'}</h1>"        
        


    createParts: () =>
        @container.append '<ul id="part-editor" class="story"></ul>'
        @container.append '<p class=\"add-section\"><i class=\"icon-arrow-down\"></i><a class=\"small action insert\" href=\"#\">add new section</a></p>'
        @container.find('.add-section a').click () =>
            @addSection 'end'
            return false 
        
        @editor = @container.find('#part-editor').first()
                    
        if @story._objects.parts.length        
            for part in @story._objects.parts
                editable = @createPartContainer part, editable
                editable.data 'part', part 
                @renderPartContent editable  



    createPartContainer: (part, previousElement) =>
        #See if the part is already there. Happens in case of an update.
        editable = @editor.find("#storypart_#{part._id}")
        
        #if the part is not found, create it.
        if not editable.length                
            #first item?
            if not previousElement or not previousElement.length
                @editor.prepend "<li class=\"content editable\" id=\"storypart_#{part._id}\"><br /></li>"
            else
                $("<li class=\"content editable\" id=\"storypart_#{part._id}\"></li>").insertAfter previousElement
    
            editable = @editor.find("#storypart_#{part._id}")                
        
        return editable        
    


    renderPartContent: (editable) =>
        editable.click () =>
            @editPart editable
                
        switch editable.data('part').type
            when 'HEADING' then @renderHeadingPart editable
            when 'TEXT' then @renderTextPart editable
            when 'IMAGE' then @renderImagePart editable
            when 'VIDEO' then @renderVideoPart editable  
                                    
        return editable



    renderHeadingPart: (editable) =>
        part = editable.data 'part'
        editable.html @makeHtml @getHeadingPrefix(part.size) + part.value     
    


    renderTextPart: (editable) =>
        part = editable.data 'part'
        editable.html @makeHtml part.value           



    renderImagePart: (editable) =>
        part = editable.data 'part'
        alt = part.alt ? ''
        editable.html "<p class=\"image-container\"><img src=\"#{part.value}\" alt=\"#{alt}\" /></p>"



    renderVideoPart: (editable) =>
        part = editable.data 'part'
        r = /https?:\/\/www\.youtube\.com\/watch\?v\=(\w+)/
        res = part.value.match(r)
        if res 
            videoId = res[1]              
            embed = "<p class=\"media\"><iframe width=\"480\" height=\"360\" src=\"https://www.youtube.com/embed/#{videoId}\" frameborder=\"0\" allowfullscreen></iframe></p>"
            editable.html embed

            
        
    editPart: (editable) =>
        part = editable.data 'part'
        editable.unbind 'click' #unbind for now. rebind once we are done editing.
        editable.addClass 'selected'
        
        switch part.type
            when 'HEADING' then @editHeadingPart editable
            when 'TEXT' then @editTextPart editable
            when 'IMAGE' then @editImagePart editable
            when 'VIDEO' then @editVideoPart editable

        editable.find('.cancel').click () =>
            @cancelPartEdit editable
            return false

        editable.find('.delete').click () =>
            @removePart editable
            return false
            
        editable.find('.insert').click () =>
            @addSection editable
            return false
            
        editable.find('textarea').focus()    
        
        
        
    editHeadingPart: (editable) =>   
        part = editable.data 'part'         
        @createForm editable, "
            <form>
                <select class=\"size span2\">
                    <option value=\"H2\">H2</option>
                    <option value=\"H3\">H3</option>
                    <option value=\"H4\">H4</option>
                </select>
                <br />
                <input type=\"text\" class=\"span6\" value=\"#{part.value ? ''}\" />
                <p class=\"left\">
                    <a class=\"save btn small action\" href=\"#\"><i class=\"icon-ok\"></i>Save section</a> <i class=\"icon-remove\"></i><a class=\"cancel small action\" href=\"#\">cancel</a>
                    <i class=\"icon-trash\"></i><a class=\"delete action small unsafe\" href=\"#\">delete?</a>
                </p>
                <hr />
                <p class=\"add-section\"><i class=\"icon-arrow-down\"></i><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"
        
        editable.find('select').focus()
        
        editable.find('.size').val(part.size ? 'H2')
        
        fnUpdatePart = () =>
            part.size = editable.find('select').val()
            part.value = editable.find('input').val()
        
        fnAfterSave = () =>
            editable.html @makeHtml @getHeadingPrefix(part.size) + part.value
        
        save = () =>
            @savePart editable, fnUpdatePart, fnAfterSave
                
        editable.find('.save').click save
                                
        #Pressing enter in the input box should do a save. 
        editable.find('input').keypress (e) =>
            if e.which == 13
                save()
        

                
    editTextPart: (editable) =>                   
        part = editable.data 'part'
        
        if editable.height() > 480
            rows = 28
        else if editable.height() > 240
            rows = 16
        else
            rows = 8
                
        @createForm editable, "
            <form>
                <textarea rows=\"#{rows}\">#{part.value ? ''}</textarea>
                <p class=\"left\">
                    <a class=\"save btn small action\" href=\"#\"><i class=\"icon-ok\"></i>Save section</a> <i class=\"icon-remove\"></i><a class=\"cancel small action\" href=\"#\">cancel</a>
                    <i class=\"icon-trash\"></i><a class=\"delete action small unsafe\" href=\"#\">delete?</a>
                </p>
                <hr />
                <p class=\"add-section\"><i class=\"icon-arrow-down\"></i><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"

        fnUpdatePart = () =>
            part.value = editable.find('textarea').val()
            
        fnAfterSave = () =>
            editable.html @makeHtml part.value

        editable.find('.save').click () =>
            @savePart editable, fnUpdatePart, fnAfterSave
                
            

    editImagePart: (editable) =>        
        part = editable.data 'part'
        @createForm editable, "
            <div class=\"with-url\">
                <form>
                    Image url: <input type=\"text\" class=\"url span5\" value=\"#{part.value ? ''}\" /> or <a href=\"#\" class=\"upload\">Upload file</a>
                    <p class=\"left\">
                        <a class=\"save btn small action\" href=\"#\"><i class=\"icon-ok\"></i>Save section</a> <i class=\"icon-remove\"></i><a class=\"cancel small action\" href=\"#\">cancel</a>
                        <i class=\"icon-trash\"></i><a class=\"delete action small unsafe\" href=\"#\">delete?</a>
                    </p>
                    <hr />
                    <p class=\"add-section\"><i class=\"icon-arrow-down\"></i><a class=\"small action insert\" href=\"#\">insert section below</a></p>
                </form>
            </div>
            <div class=\"with-upload\" style=\"display:none\">
                <form class=\"upload-form\" name=\"form\" action=\"upload\" method=\"POST\" target=\"upload-frame\" enctype=\"multipart/form-data\" >
                    <input type=\"file\" name=\"file\" /><br />
                    <a href=\"#\" class=\"btn upload\">Upload</a> <a class=\"cancel small action\" href=\"#\">cancel</a>
                    <iframe id=\"upload-frame\" name=\"upload-frame\" src=\"\" style=\"display:none;height:0;width:0\"></iframe>
                </form>
            </div>"
            
        editable.find('.with-url .upload').click () =>
            editable.find('.with-url').hide()
            editable.find('.with-upload').show()
            editable.find('.with-upload .upload').click () =>
                frame = editable.find('#upload-frame')
                frame.unbind 'load'
                frame.load () =>
                    url = $(frame[0].contentWindow.document).text()
                    editable.find('input.url').val url
                    @savePart editable, fnUpdatePart, fnAfterSave
                editable.find('.upload-form').submit()
                

        fnUpdatePart = () =>
            src = editable.find('input.url').val()
            part.value = src

        fnAfterSave = () =>
            editable.html @makeHtml "<p class=\"media\"><img src=\"#{part.value}\" alt=\"\" /></p>"

        editable.find('.save').click () =>
            @savePart editable, fnUpdatePart, fnAfterSave




    editVideoPart: (editable) =>        
        part = editable.data 'part'
        @createForm editable, "
            <form>
                YouTube url: <input type=\"text\" class=\"span5\" value=\"#{part.value ? ''}\" />
                <p class=\"left\">
                    <a class=\"save btn small action\" href=\"#\"><i class=\"icon-ok\"></i>Save section</a> <i class=\"icon-remove\"></i><a class=\"cancel small action\" href=\"#\">cancel</a>
                    <i class=\"icon-trash\"></i><a class=\"delete action small unsafe\" href=\"#\">delete?</a>
                </p>
                <hr />
                <p class=\"add-section\"><i class=\"icon-arrow-down\"></i><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"
            
        fnUpdatePart = () =>
            url = editable.find('input').val()
            part.source = "youtube" #The only one we support for now.
            part.value = url
            
        fnAfterSave = () =>
            r = /https?:\/\/www\.youtube\.com\/watch\?v\=(\w+)/
            res = part.value.match(r)
            if res 
                videoId = res[1]              
                embed = "<p class=\"media\"><iframe width=\"480\" height=\"360\" src=\"https://www.youtube.com/embed/#{videoId}\" frameborder=\"0\" allowfullscreen></iframe></p>"
                editable.html embed
            
            
        editable.find('.save').click () =>
            @savePart editable, fnUpdatePart, fnAfterSave
                
                
    
    savePart: (editable, fnUpdatePart, fnAfterSave) =>
        fnUpdatePart()

        part = editable.data 'part'  
        postData = {}      
        SocialTypist.Utils.extend postData, part

        onComplete = (response) =>
            if response.success
                editable.click () =>
                    @editPart editable
                editable.removeClass 'selected'
                fnAfterSave()

        #Update existing part PUT /stories/#{@story._id}/parts/#{part._id}
        if not part.isNew
            $.put "/stories/#{@story._id}/parts/#{part._id}", postData, onComplete
                    
        #Create a new part POST /stories/#{@story._id}/parts
        else
            delete postData._id
            delete postData.isNew
            postData.previousParts = ($(element).data('part')._id for element in editable.prevAll() when not $(element).data('part').isNew)
            $.post "/stories/#{@story._id}/parts", postData, (response) =>
                if response.success
                    part._id = response._id
                    delete part.isNew
                onComplete response
                    
        return false


       
    cancelPartEdit: (editable) =>
        part = editable.data 'part'
        if not part.isNew
            editable.removeClass 'selected'
            @renderPartContent editable
        else
            editable.remove()
        
    
    
    removePart: (editable) =>
        part = editable.data 'part'

        if not part.isNew
            $.delete_ "/stories/#{@story._id}/parts/#{part._id}", {}, (response) =>
                if response.success
                    editable.remove()
        else
            editable.remove()


    
    addSection: (previous) =>
        #if there is already an open 'unsaved/add section', don't create a new one.        
        elem = switch previous
            when 'start' then $('#part-editor').children().first()
            when 'end' then $('#part-editor').children().last()
            else previous.next()
        if elem.hasClass 'unsaved'
            return
    
        content = "
            <li class=\"unsaved form\" style=\"padding-left: 24px;\">
                <ul class=\"action-list\">
                    <li><i class=\"icon-align-justify\"></i><a href=\"#\" class=\"text\">Text content</a></li>
                    <li><i class=\"icon-font\"></i><a href=\"#\" class=\"heading\">Heading</a></li>
                    <li><i class=\"icon-picture\"></i><a href=\"#\" class=\"image\">Image</a></li>
                    <li><i class=\"icon-facetime-video\"></i><a href=\"#\" class=\"video\">Video</a></li>
                </ul>
                <div class=\"clear\"></div>
                <p>
                    <i class=\"icon-remove\"></i><a style=\"font-size: 12px\" href=\"#\" class=\"cancel\">cancel</a>
                </p>
            </li>"
        
        if previous == 'start'
            $('#part-editor').prepend content
            added = $('#part-editor').children().first()
        else if previous == 'end'
            $('#part-editor').append content
            added = $('#part-editor').children().last()
        else
            $(content).insertAfter previous
            added = previous.next()
            
        added.find('select').focus()
    
        addSection = (partType) =>
            part = { 
                type: partType,
                _id: SocialTypist.Utils.uniqueId(),
                isNew: true,
                value: ''
            }
            editable = @createPartContainer part, added.prev()
            added.remove()
            editable.data 'part', part 
            @editPart editable
            
        added.find('.text').click () =>
            addSection 'TEXT'
            return false

        added.find('.heading').click () =>
            addSection 'HEADING'
            return false

        added.find('.image').click () =>
            addSection 'IMAGE'
            return false

        added.find('.video').click () =>
            addSection 'VIDEO'
            return false
           
        added.find('.cancel').click () =>
            added.remove()
            return false


    makeHtml: (markdown) =>
        if markdown
            @showdown.makeHtml markdown
        else
            ''
            
            
    
    createForm: (parent, html) =>
        parent.html html
        parent.children('form').last().submit () =>
            false
            
            
    
    getHeadingPrefix: (size) =>
        switch size
            when 'H1' then '#'
            when 'H2' then '##'
            when 'H3' then '###'
            when 'H4' then '####'
            when 'H5' then '#####'
            when 'H6' then '######'                                                
        
                
this.SocialTypist.StoryEditView = StoryEditView
    
