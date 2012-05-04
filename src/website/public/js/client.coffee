window.DEBUG = true

class Client
    constructor: () ->
        if not loggedIn
            needsLogin = $('.needs-session')
            for link in needsLogin
                link = $(link)
                href = link.attr('href')
                url = if href != '#' then href
                @createLoginLink url, link
        


    initFB: (@FB) ->

    

    createLoginLink: (url, selector) ->
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
                                    if url
                                        window.location.href = url
                                    else
                                        window.location.reload()
                
                    @FB.login callback, { scope: 'email,user_location' }
                    return false
                    
                else
                    callback = (response) ->
                        if response.authResponse
                            $.post '/addSession', { domain: 'facebook', response: response }, () =>                        
                                    if url
                                        window.location.href = url
                                    else
                                        window.location.reload()

                    @FB.login callback, { scope: 'email,user_location' }
                    return false
            else
                window.location.href = url
                
                
        
        
this.SocialTypist.Client = Client
