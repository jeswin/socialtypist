this.SocialTypist = {}
this.SocialTypist.Utils = {}


this.SocialTypist.Utils.random = (n) ->
    Math.floor(Math.random() * n)

this.SocialTypist.Utils.pickRandom = (array) ->
    rand = Math.floor(Math.random() * array.length)
    return array[rand]

this.SocialTypist.Utils.uniqueId = (length=16) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length
  
this.SocialTypist.Utils.extend = (target, source) ->
    for key, val of source
        if typeof val != "function"
            target[key] = val  
