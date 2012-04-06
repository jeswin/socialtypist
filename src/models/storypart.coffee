BaseModel = require('./basemodel').BaseModel

class StoryPart extends BaseModel

    @_meta: {
        type: StoryPart,
        collection: 'storyparts'
    }


    getValue: () =>

        if @type is "HEADER"
            if @value.level is "H1"
                return "# #{@value.text}"
            if @value.level is "H2"
                return "## #{@value.text}"
            if @value.level is "H3"
                return "### #{@value.text}"
            if @value.level is "H4"
                return "#### #{@value.text}"
            if @value.level is "H5"
                return "##### #{@value.text}"
            if @value.level is "H6"
                return "###### #{@value.text}"
                
        if @type is "IMAGE"
            return "![#{@value.alt}] (#{@value.link})"
                    
        if @type is "RAW"
            return @value
                        

exports.StoryPart = StoryPart
