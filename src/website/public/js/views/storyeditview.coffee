class StoryEditView

    constructor: (@story, container) ->
        @container = $(container)
        @initialize()



    initialize: () =>
        @showdown = new Showdown.converter()

    
    
    render: () =>
        @renderTitle()        
        @renderParts()        
        

    
    renderTitle: () =>
        @container.append "<div class=\"editable title\"><h1 class=\"title\">#{story.title}</h1></div>"
        title = @container.find('.editable.title')
        title.data 'title', story.title
        @bindTitleEditClick title
        


    editTitle: () =>
        editable = $('#story-editor .editable.title')        
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
        @bindTitleEditClick editable
        editable.removeClass 'selected'
        editable.html "<h1 class=\"title\">#{$('.title-editor input').val()}</h1>"
        

    
    cancelTitleEdit: () =>
        editable = $('#story-editor .editable.title')
        @bindTitleEditClick editable
        editable.removeClass 'selected'
        editable.html "<h1 class=\"title\">#{editable.data 'title'}</h1>"        
        


    renderParts: () =>
        @container.append '<ul id="part-editor" class="story"></ul>'
        @container.append '<p class="add-section"><span class="plus">+</span><a class="small action" href="#">add new section</a></p>'
        @container.find('.add-section a').click () =>
            @addSection 'end'
            return false 
        
        @editor = @container.find('#part-editor').first()
                    
        if @story._objects.parts.length        
            for part in @story._objects.parts
                previous = @renderPart part, previous
        #else...

    

    renderPart: (part, previousElement) =>        
        #See if the part is already there. Happens in case of an update.
        partElem = @editor.find("#storypart_#{part._id}")
        
        #if the part is not found, create it.
        if not partElem.length                
            #first item?
            if not previousElement
                @editor.prepends "<li class=\"content editable\" id=\"storypart_#{part._id}\"><br /></li>"
            else
                $("<li class=\"content editable\" id=\"storypart_#{part._id}\"></li>").insertAfter previousElement
    
            partElem = @editor.find("#storypart_#{part._id}")                
            
        partElem.data 'part', part      
        
        switch part.type
            when 'HEADING' then @renderHeadingPart partElem
            when 'TEXT' then @renderTextPart partElem
            when 'IMAGE' then @renderImagePart partElem
            when 'VIDEO' then @renderVideoPart partElem  
                                    
        @bindPartEditClick partElem
                                 
        return partElem



    bindTitleEditClick: (title) =>
        title.click () =>
            title.unbind 'click' #unbind for now. rebind once we are done editing.
            @editTitle()            
    
    
    
    bindPartEditClick: (partElem) =>
        partElem.click () =>
            partElem.unbind 'click' #unbind for now. rebind once we are done editing.
            @editPart partElem



    renderHeadingPart: (partElem) =>
        part = partElem.data 'part'

        headingSize = switch part.size
            when 'H1' then '#'
            when 'H2' then '##'
            when 'H3' then '###'
            when 'H4' then '####'
            when 'H5' then '#####'
            when 'H6' then '######'                                                
            
        partElem.html @showdown.makeHtml headingSize + part.value           
    


    renderTextPart: (partElem) =>
        part = partElem.data 'part'
        partElem.html @showdown.makeHtml part.value           



    renderImagePart: (partElem) =>
        part = partElem.data 'part'
        alt = part.alt ? ''
        partElem.html "<img src=\"#{part.value}\" alt=\"#{alt}\" />"



    renderVideoPart: (partElem) =>
        part = partElem.data 'part'
        partElem.html @showdown.makeHtml part.value           

            
        
    editPart: (elem) ->
        part = elem.data 'part'
        elem.addClass 'selected'
        
        switch part.type
            when 'HEADING' then @editHeadingPart elem
            when 'TEXT' then @editTextPart elem
            when 'IMAGE' then @editImagePart elem
            when 'VIDEO' then @editVideoPart elem
                
        elem.find('.save').click () =>
            @savePart elem
            return false

        elem.find('.cancel').click () =>
            @cancelPartEdit elem
            return false

        elem.find('.delete').click () =>
            @deletePart elem
            return false
            
        elem.find('.insert').click () =>
            @addSection elem
            return false
            
        elem.find('textarea').focus()    
        
        
        
    editHeadingPart: (elem) =>   
        part = elem.data 'part'         
        elem.html "
            <form>
                <input type=\"text\" class=\"span6\" value=\"#{part.value}\" />
                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"

                
    editTextPart: (elem) =>                   
        part = elem.data 'part'
        
        if elem.height() > 480
            rows = 28
        else if elem.height() > 240
            rows = 16
        else
            rows = 8
                
        elem.html "
            <form>
                <textarea rows=\"#{rows}\">#{part.value}</textarea>
                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"


    editImagePart: (elem) =>        
        part = elem.data 'part'
        elem.html "
            <form>
                <input type=\"text\" class=\"span6\" value=\"#{part.value}\" />
                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"


    editVideoPart: (elem) =>        
        part = elem.data 'part'
        elem.html "
            <form>
                <input type=\"text\" class=\"span6\" value=\"#{part.value}\" />
                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>
                <hr />
                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>
            </form>"



    
    savePart: (elem) =>
        @bindPartEditClick elem        
        part = elem.data 'part'
        #do save on server
        elem.removeClass 'selected'
        part.value = elem.find('textarea').val()
        elem.html @showdown.makeHtml elem.find('textarea').val()
        #do save on server
        
        
    cancelPartEdit: (elem) =>
        @bindPartEditClick elem        
        part = elem.data 'part'
        elem.removeClass 'selected'
        elem.html @showdown.makeHtml part.value
    
    
    
    deletePart: (elem) =>
        @bindPartEditClick elem        
        part = elem.data 'part'
        #do delete on server.
        elem.remove()

    
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
                <select class=\"part-type\">
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
            part = { type: added.find('.part-type').val() }
            @renderPart part, added.previous()
            
            
        added.find('.cancel').click () =>
            added.remove()
            return false

    
                
this.SocialTypist.StoryEditView = StoryEditView
    
