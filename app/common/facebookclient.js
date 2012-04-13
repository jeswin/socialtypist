// Generated by CoffeeScript 1.2.1-pre

/*
    CREDITS:
    Code from https://github.com/DracoBlue/node-facebook-client
*/


(function() {
  var FaceBookClient, https, querystring;

  querystring = require('querystring');

  https = require('https');

  FaceBookClient = (function() {

    FaceBookClient.name = 'FaceBookClient';

    function FaceBookClient() {}

    FaceBookClient.prototype.getOAuthCode = function(req, secret) {
      var buffer, contents, cookie, expectedSignature, hmac, json, match, parts, payload, signature;
      match = request_headers["cookie"].match(/fbsr_[\d]+\=([^; ]+)/);
      cookie = match[1];
      parts = cookie.split('.');
      buffer = new Buffer(convertBase64ToHex(parts[0].replace(/\-/g, '+').replace(/\_/g, '/'), 'base64'));
      signature = buffer.toString('hex');
      payload = parts[1];
      json = new Buffer(payload.replace(/\-/g, '+').replace(/\_/g, '/'), 'base64').toString('binary');
      contents = JSON.parse(json);
      if (!contents) return;
      hmac = crypto.createHmac('sha256', secret);
      hmac.update(payload);
      expectedSignature = hmac.digest('hex');
      if (!expectedSignature === signature) return;
      return contents['code'];
    };

    FaceBookClient.prototype.secureGraphRequest = function(options, cb) {
      var req;
      options.host = 'graph.facebook.com';
      options.secure = true;
      options.port = 443;
      options.timeout = '15000';
      options.method = 'GET';
      req = https.request(options, function(res) {
        var result;
        res.setEncoding('utf8');
        result = '';
        res.on('data', function(data) {
          return result += data;
        });
        res.on('end', function() {
          return cb(null, result);
        });
        return res.on('error', function(err) {
          return cb(err, null);
        });
      });
      return req.end();
    };

    FaceBookClient.prototype.getAccessToken = function(code, clientId, clientSecret, cb) {
      var options;
      options = {
        path: '/oauth/access_token?' + querystring.stringify({
          code: code,
          client_id: clientId,
          redirect_uri: '',
          client_secret: clientSecret
        })
      };
      return this.secureGraphRequest(options, cb);
    };

    return FaceBookClient;

  })();

  exports.FaceBookClient = FaceBookClient;

}).call(this);
