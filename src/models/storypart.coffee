BaseModel = require('./basemodel').BaseModel
markdown = require("node-markdown").Markdown
sanitize = require("../common/mdsanitizer").sanitize

class StoryPart extends BaseModel

    @_meta: {
        type: StoryPart,
        collection: 'storyparts'
    }
    
    getHtml: () =>
        if @type is "TEXT"
            @toHtml @value
        
        else if @type is "HEADING"
            if @size is "H1"
                @toHtml "# #{@value}"
            else if @size is "H2"
                @toHtml "## #{@value}"
            else if @size is "H3"
                @toHtml "### #{@value}"
            else if @size is "H4"
                @toHtml "#### #{@value}"
            else if @size is "H5"
                @toHtml "##### #{@value}"
            else if @size is "H6"
                @toHtml "###### #{@value}"
                        
        else if @type is "IMAGE"
            "<p class=\"media\"><img src=\"#{@value}\" alt=\"\" /></p>"
        
        else if @type is "VIDEO"
            r = /https?:\/\/www\.youtube\.com\/watch\?v\=(\w+)/
            res = @value.match(r)
            if res 
                videoId = res[1]              
                "<p class=\"media\"><iframe width=\"480\" height=\"360\" src=\"https://www.youtube.com/embed/#{videoId}\" frameborder=\"0\" allowfullscreen></iframe></p>"

    
    save: (cb) =>    
        allowedTags = 'a|b|blockquote|code|del|dd|dl|dt|em|h1|h2|h3|h4|h5|h6|i|img|li|ol|p|pre|sup|sub|strong|strike|ul|br|hr'
        allowedAttributes = {
            'img': 'src|width|height|alt',
            'a':   'href',
            '*':   'title'
        }
        @value = sanitize @value, allowedTags, allowedAttributes
        @html = @getHtml()
        super cb

    
    
    toHtml: (input) =>
        allowedTags = 'a|b|blockquote|code|del|dd|dl|dt|em|h1|h2|h3|h4|h5|h6|i|img|li|ol|p|pre|sup|sub|strong|strike|ul|br|hr'
        allowedAttributes = {
            'img': 'src|width|height|alt',
            'a':   'href',
            '*':   'title'
        }
        markdown input, true, allowedTags, allowedAttributes


exports.StoryPart = StoryPart
