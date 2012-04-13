window.DEBUG = true

class Client
    constructor: () ->
        @setLoginStatus()


    initFB: (@FB) ->

    

    makeRestrictedLink: (url, selector) ->
        $(selector).click () =>
            if not loggedIn
                #We have a fscked up situation here. FB api randomly works on localhost.
                #   You can get around this with port forwarding on my router, but I am just not gonna bother.
                #   I am just going to send user details from the browser while in DEBUG mode.

                #Call your local server something like local.example.com for this to work, or see above.        
                if DEBUG and /http(s?):\/\/local\./.test window.location.href
                    callback = (response) ->
                        if response.authResponse
                            @FB.api '/me', (userDetails) =>
                                $.post '/addSession_INSECURE', { domain: 'facebook', response: response, userDetails: userDetails }, () =>
                                    window.location.reload()
                
                    @FB.login callback, { scope: 'email,user_location' }
                    return false
                    
                else
                    callback = (response) ->
                        if response.authResponse
                            $.post '/addSession', { domain: 'facebook', response: response }, () =>                        
                                window.location.reload()

                    @FB.login callback, { scope: 'email,user_location' }
                    return false
            else
                window.location.href = url
                
                
        
    setLoginStatus: () ->
        if loggedIn
            if authProvider == 'facebook'
                $('.login .logoutLink').click @fbLogoutLink
        else
            $('.login .fbLoginLink').click @fbLoginLink
    


    fbLoginLink: () =>
        
        #We have a fscked up situation here. FB api randomly works on localhost.
        #   You can get around this with port forwarding on my router, but I am just not gonna bother.
        #   I am just going to send user details from the browser while in DEBUG mode.

        #Call your local server something like local.example.com for this to work, or see above.        
        if DEBUG and /http(s?):\/\/local\./.test window.location.href
            console.log 'Adding an insecure session.'
            callback = (response) ->
                if response.authResponse
                    @FB.api '/me', (userDetails) =>
                        $.post '/addSession_INSECURE', { domain: 'facebook', response: response, userDetails: userDetails }, () =>
                            window.location.reload()
        
            @FB.login callback, { scope: 'email,user_location' }
            return false
            
        else
            callback = (response) ->
                if response.authResponse
                    $.post '/addSession', { domain: 'facebook', response: response }, () =>                        
                        window.location.reload()

            @FB.login callback, { scope: 'email,user_location' }
            return false
            
        

    fbLogoutLink: () =>
        $.get '/removeSession', () =>
            #Load facebook SDK here.
            window.location.reload()
                        
        ###
        @FB.getLoginStatus (response) =>
            if response.status == 'connected'
                $.get '/removeSession', () =>
                    @FB.logout () =>
                        window.location.href = "/"
            else
                $.get '/removeSession', () =>
                    window.location.href = "/"
            return false
        ###
    
        
this.SocialTypist.Client = Client
