class Exception
    
    constructor: (@type, @message) ->
        
        
    toString: () =>        
        "#{@type}, #{@message}"
        
        
exports.Exception = Exception
