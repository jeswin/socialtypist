class Client
    constructor: () ->
        @setLoginStatus()


    initFB: (@FB) ->

    

    makeRestrictedLink: (url, selector) ->
        $(selector).click () =>
            if not loggedIn
                callback = (response) ->
                    if response.authResponse
                        @FB.api '/me', (aboutMe) =>
                            aboutMe.domain = 'facebook'
                            $.post '/addSession', aboutMe, () =>
                                window.location.href = url
            
                @FB.login callback, { scope: 'email,user_location' }
            else
                window.location.href = url
                
                
        
    setLoginStatus: () ->
        if loggedIn
            $('.login .loginStatus').click @logoutLink
        else
            $('.login .loginStatus').click @loginLink
    


    loginLink: () =>
        callback = (response) ->
            if response.authResponse
                @FB.api '/me', (aboutMe) =>
                    aboutMe.domain = 'facebook'       
                    $.post '/addSession', aboutMe, () =>                        
                        window.location.reload()
    
        @FB.login callback, { scope: 'email,user_location' }
        return false
        
        

    logoutLink: () =>
        @FB.getLoginStatus (response) =>
            if response.status == 'connected'
                $.get '/removeSession', () =>
                    @FB.logout () =>
                        window.location.href = "/"
            else
                $.get '/removeSession', () =>
                    window.location.href = "/"
            return false

    
        
this.SocialTypist.Client = Client
