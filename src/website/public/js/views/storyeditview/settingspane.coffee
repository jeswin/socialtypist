class SettingsPane

    constructor: (@story, @editor, @view) ->
        @editor.find('.tab-content').html('<div class="settings-pane"></div>')
        @container = @editor.find('.settings-pane')

        #create a slug
        slug = @story.slug ? @story.title.toLowerCase().replace(/[^\w ]+/g,'').replace(/\ +/g,'-')

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
            <form class=\"story-settings-form\">
                <p>
                    <label>Summary</label>
                    <textarea class=\"summary span6\" rows=\"6\">#{@story.summary}</textarea>
                </p>
                <p>
                    <label>Tags</label>
                    <input type=\"text\" value=\"#{@story.tags}\" class=\"tags span6\" />
                </p>
                <p>
                    <label>Url for your story</label>
                    <span class=\"light\">http://www.socialtypist.com/#{prefix}/</span><br /><input type=\"text\" value=\"#{slug}\" class=\"slug span6\" /><br />
                </p>
                <p>
                    <a class=\"btn save\" href=\"#\">Save Settings</a>
                </p>
            </form>
            <hr />"
        
        $('.story-settings-form .save').click @saveSettings
        
        owners = ({ type: 'owner', user: user } for user in @story.cache.owners)
        authors = ({ type: 'author', user: user } for user in @story.cache.authors)
        all = owners.concat authors
        #all = (u for u in (owners.concat authors) when u.user._id == @story.createdBy)

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
        
        
    saveSettings: () =>
        onResponse = () =>
            alert 'saved'
            
        tags = $('.story-settings-form .tags').val()
        summary = $('.story-settings-form .summary').val()
        slug = $('.story-settings-form .slug').val()
        $.put "/stories/#{@story._id}", { tags: tags, summary: summary, slug: slug }, onResponse
        
        return false
        
this.SocialTypist.StoryEditView.SettingsPane = SettingsPane
