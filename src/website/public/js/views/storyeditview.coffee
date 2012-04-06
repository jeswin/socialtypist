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
        @container.append "<div class=\"editable title\"><h1 class=\"title\">#{story.title}</h1></div>"
        title = @container.find('.editable.title')
        title.data 'title', story.title
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

   

    saveTitle: () =>
        editable = $('#story-editor .editable.title')
        editable.click () =>
            @editTitle()
        editable.removeClass 'selected'
        editable.html "<h1 class=\"title\">#{$('.title-editor input').val()}</h1>"
        

    
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
            editable.unbind 'click' #unbind for now. rebind once we are done editing.
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
        editable.html "<img src=\"#{part.value}\" alt=\"#{alt}\" />"



    renderVideoPart: (editable) =>
        part = editable.data 'part'
        editable.html @makeHtml part.value           

            
        
    editPart: (editable) ->
        part = editable.data 'part'
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
        editable.html "
            <form>
                <select class=\"size span2\">
                    <option>H2</option>
                    <option>H3</option>
                    <option>H4</option>
                    <option>H5</option>
                    <option>H6</option>                    
                </select>
                <br />
                <input type=\"text\" class=\"span6\" value=\"#{part.value ? ''}\" />
                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"
        editable.find('.size').val(part.size ? 'H2')
                
        editable.find('.save').click () =>
            @savePart editable, () =>
                part.size = editable.find('select').val()
                part.value = editable.find('input').val()
                editable.html @makeHtml @getHeadingPrefix(part.size) + part.value
                                
                
                
    editTextPart: (editable) =>                   
        part = editable.data 'part'
        
        if editable.height() > 480
            rows = 28
        else if editable.height() > 240
            rows = 16
        else
            rows = 8
                
        editable.html "
            <form>
                <textarea rows=\"#{rows}\">#{part.value}</textarea>
                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"

        editable.find('.save').click () =>
            editable.click () =>
                @editPart editable
            part = editable.data 'part'
            #do save on server
            editable.removeClass 'selected'
            part.value = editable.find('textarea').val()
            editable.html @makeHtml editable.find('textarea').val()
            #do save on server
            return false


    editImagePart: (editable) =>        
        part = editable.data 'part'
        editable.html "
            <form>
                <input type=\"text\" class=\"span6\" value=\"#{part.value}\" />
                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"


    editVideoPart: (editable) =>        
        part = editable.data 'part'
        editable.html "
            <form>
                <input type=\"text\" class=\"span6\" value=\"#{part.value}\" />
                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"


    
    savePart: (editable, fnEdit) =>
        editable.click () =>
            @editPart editable
        editable.removeClass 'selected'
        
        fnEdit()

        #do save on server
        part = editable.data 'part'

        return false

       
    cancelPartEdit: (editable) =>
        editable.click () =>
            @editPart editable
        part = editable.data 'part'
        editable.removeClass 'selected'
        editable.html @makeHtml part.value
    
    
    
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
            
        added.find('.add').click () =>
            part = { 
                type: added.find('.part-type').val(), 
                _id: SocialTypist.Utils.uniqueId() 
            }
            editable = @createPartContainer part, added.prev()
            added.remove()
            editable.data 'part', part 
            @editPart editable
            return false
            
        added.find('.cancel').click () =>
            added.remove()
            return false

    makeHtml: (markdown) =>
        if markdown
            @showdown.makeHtml markdown
        else
            ''

    
    getHeadingPrefix: (size) =>
        switch size
            when 'H1' then '#'
            when 'H2' then '##'
            when 'H3' then '###'
            when 'H4' then '####'
            when 'H5' then '#####'
            when 'H6' then '######'                                                
            
                
this.SocialTypist.StoryEditView = StoryEditView
    
