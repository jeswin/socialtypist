querystring = require 'querystring'
https = require 'https'

class FaceBookAuth

    getOAuthCode: (req, secret) ->
    
        match = request_headers["cookie"].match(/fbsr_[\d]+\=([^; ]+)/)
        cookie = match[1]
        parts = cookie.split('.')
        
        buffer = new Buffer(base64_string, 'base64')

        signature = buffer.toString 'hex'
        signature = self.convertBase64ToHex parts[0].replace(/\-/g, '+').replace(/\_/g, '/')

        payload = parts[1]
        json = new Buffer(payload.replace(/\-/g, '+').replace(/\_/g, '/'), 'base64').toString('binary')
        
        contents = JSON.parse json
        
        if not contents
            return
        
        #get the signature
        hmac = crypto.createHmac('sha256', secret)
        hmac.update(payload)
        expectedSignature = hmac.digest('hex')
            
        if not expectedSignature == signature
            return
            
        return contents['code'] 
      
  
  
    getAccessToken: (code, clientId, clientSecret, cb) ->
        
        options = {
            host: 'graph.facebook.com',
            secure: true,
            path: '/oauth/access_token?' + querystring.stringify({ code: code, client_id: clientId, redirect_uri: '', client_secret: clientSecret }),
            port: 443,
            timeout: '15000'
        }
        
        req = https.request options, (res) ->
        
            res.setEncoding 'utf8'
            
            console.log("statusCode: ", res.statusCode)
            console.log("headers: ", res.headers)
            
            result = ''            
            res.on 'data', (data) ->
                console.log data
                result += data
                
            res.on 'end', () ->
                cb null, result
                
            res.on 'error', (err) ->
                cb err, null
                
        req.end()
                
                
APP_ID = '259516830808506'
SECRET = '5402abb9c3003f767889e57e00f2b499'

code = 'AQBmeep5PS8oKLH2wT9pFOLYlUf1pYUozzPXrrMGNJyEihsW9AQ-ETmD9b2Hv16fvjJNiMjBdbS674CIlGMuA4rAxHaYE7TI_GhLe__NzaIe1KXlvKo3eYaWS4pjpE4ET_0CQZXiy2wlN9ygwea9FAFArGLzUHDLYVqClB2i-RO7xR7GJP-_77PMJTGiTVZl4mw'
https = require('https')

console.log 'Connecting....'

helper = new FaceBookAuth()
helper.getAccessToken code, APP_ID, SECRET, (err, token) ->
    console.log token

