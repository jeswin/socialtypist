class StoryEditView

    constructor: (@story, container) ->
        @container = $(container)
        @initialize()



    initialize: () =>
        @showdown = new Showdown.converter()

    
    
    render: () =>
        @createTitle()        
        @createParts()        
        

    
    createTitle: () =>
        @container.append "<div class=\"editable title\"><h1 class=\"title\">#{@story.title}</h1></div>"
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
                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
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
        $.post "/stories/#{story._id}/saveTitle", { title: val }, (response) =>
            console.log response
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
        @container.append '<p class="add-section"><span class="plus">+</span><a class="small action" href="#">add new section</a></p>'
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
        editable.html @makeHtml part.value           

            
        
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
            @deletePart editable
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
                    <option value=\"H5\">H5</option>
                    <option value=\"H6\">H6</option>                    
                </select>
                <br />
                <input type=\"text\" class=\"span6\" value=\"#{part.value ? ''}\" />
                <p class=\"left\">
                    <a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a>
                    <a class=\"delete action small unsafe\" href=\"#\">delete?</a>
                </p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
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
                    <a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a>
                    <a class=\"delete action small unsafe\" href=\"#\">delete?</a>                
                </p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
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
            <form>
                Image url: <input type=\"text\" class=\"span5\" value=\"#{part.value ? ''}\" /> or <a href=\"#\" class=\"upload\">Upload file</a>
                <p class=\"left\">
                    <a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a>
                    <a class=\"delete action small unsafe\" href=\"#\">delete?</a>                    
                </p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"

        fnUpdatePart = () =>
            src = editable.find('input').val()
            part.value = src

        fnAfterSave = () =>
            editable.html @makeHtml "<div class=\"media\"><img src=\"#{part.value}\" alt=\"\" /></div>"

        editable.find('.save').click () =>
            @savePart editable, fnUpdatePart, fnAfterSave
                


    editVideoPart: (editable) =>        
        part = editable.data 'part'
        @createForm editable, "
            <form>
                YouTube url: <input type=\"text\" class=\"span5\" value=\"#{part.value ? ''}\" />
                <p class=\"left\">
                    <a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a>
                    <a class=\"delete action small unsafe\" href=\"#\">delete?</a>
                </p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"
            
        fnUpdatePart = () =>
            url = editable.find('input').val()
            part.value = url
            
        fnAfterSave = () =>
            r = /https?:\/\/www\.youtube\.com\/watch\?v\=(\w+)/
            res = part.value.match(r)
            if res 
                videoId = res[1]              
                embed = "<div class=\"media\"><iframe width=\"480\" height=\"360\" src=\"https://www.youtube.com/embed/#{videoId}\" frameborder=\"0\" allowfullscreen></iframe></div>"
                editable.html embed
            
            
        editable.find('.save').click () =>
            @savePart editable, fnUpdatePart, fnAfterSave
                
                
    
    savePart: (editable, fnUpdatePart, fnAfterSave) =>
        fnUpdatePart()
        part = editable.data 'part'
        
        postData = {}
        if part.isNew
            postData.previousParts = ($(element).data('part')._id for element in editable.prevAll() when not $(element).data('part').isNew)
            delete part.isNew
            delete part._id
        postData.part = part
        
        $.post "/stories/#{@story._id}/savePart", postData, (response) =>
            if response.success
                if response.partId
                    part._id = response.partId
                editable.click () =>
                    @editPart editable
                editable.removeClass 'selected'      
                fnAfterSave()

        return false


       
    cancelPartEdit: (editable) =>
        part = editable.data 'part'
        editable.removeClass 'selected'
        @renderPartContent editable
    
    
    
    deletePart: (editable) =>
        editable.click () =>
            @editPart editable
        part = editable.data 'part'
        #do delete on server.
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
            <li class=\"unsaved form\">
                <select class=\"part-type span2\">
                    <option value=\"HEADING\">Heading</option>
                    <option value=\"TEXT\" selected=\"selected\">Text</option>
                    <option value=\"IMAGE\">Image</option>
                    <option value=\"VIDEO\">Video</option>
                </select>
                <p>
                    <a href=\"#\" class=\"btn add\">Add</a>
                    <a href=\"#\" class=\"small action cancel\">cancel</a>
                </p>
            </li>
        "
        
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
    
        addSection = () =>
            part = { 
                type: added.find('.part-type').val(), 
                _id: SocialTypist.Utils.uniqueId(),
                isNew: true,
                value: ''
            }
            editable = @createPartContainer part, added.prev()
            added.remove()
            editable.data 'part', part 
            @editPart editable
            
        added.find('.add').click () =>
            addSection()
            return false
            
        
        #Add also if the user presses enter while on the select box.
        added.find('select').keypress (e) =>
            if e.which == 13
                addSection()
            
            
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
    
