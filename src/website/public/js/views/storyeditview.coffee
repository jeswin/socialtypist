class StoryEditView

    constructor: (@story, @editor) ->
        @renderRightPane()
        @onHashChange()
        $(window).bind 'hashchange', @onHashChange



    onHashChange: () =>
        @setActiveTab if window.location.hash then window.location.hash else '#nav-content'



    setActiveTab: (tab) ->
        @editor.find('.tab-content').html ''
        @editor.find('.nav-pills li').removeClass 'active'
        switch tab
            when '#nav-settings'
                @editor.find('.nav-pills li.nav-settings').addClass 'active'
                new SocialTypist.StoryEditView.SettingsPane @story, @editor, @
            when '#nav-content' 
                @editor.find('.nav-pills li.nav-content').addClass 'active'                
                new SocialTypist.StoryEditView.ContentPane @story, @editor, @
            when '#nav-messages'
                @editor.find('.nav-pills li.nav-messages').addClass 'active'                            
                new SocialTypist.StoryEditView.MessagesPane @story, @editor, @
            when '#nav-history' 
                @editor.find('.nav-pills li.nav-history').addClass 'active'                            
                new SocialTypist.StoryEditView.HistoryPane @story, @editor, @
            when '#nav-forks' 
                @editor.find('.nav-pills li.nav-history').addClass 'active'                            
                new SocialTypist.StoryEditView.ForksPane @story, @editor, @



    renderRightPane: () =>
        @populateAuthors()
        @setupLiveUpdate()



    populateAuthors: () =>
        authorsContainer = @editor.find('.rpane .authors')
        authorsContainer.html '
            <h3>Authors</h3>
            <ul class="iconic-summary"></ul>'
        authorsElem = authorsContainer.find 'ul'
        
        fn = (list, userType) =>
            for author in list
                authorsElem.append "
                    <li>
                        <div class=\"icon\">
                            <img src=\"http://graph.facebook.com/#{author.domainid}/picture?type=square\" />
                        </div>
                        <div class=\"summary\">
                            <h3>#{author.name}</h3>
                            <p>#{userType}</p>
                        </div>
                    </li>"

        fn @story.cache.owners, 'Owner'
        fn @story.cache.authors, 'Author'
    
    
    
    setupLiveUpdate: () =>






        


                
this.SocialTypist.StoryEditView = StoryEditView
    
