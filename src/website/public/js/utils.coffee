this.SocialTypist = {}
this.SocialTypist.Utils = {}


this.SocialTypist.Utils.random = (n) ->
    Math.floor(Math.random() * n)

this.SocialTypist.Utils.pickRandom = (array) ->
    rand = Math.floor(Math.random() * array.length)
    return array[rand]

