controller = require('./controller')
dbconf = require '../../models/dbconf'
database = new (require '../../common/database').Database(dbconf.default)       
models = new (require '../../models').Models(dbconf.default) 
conf = require '../conf'

#QUICK ADMIN HACK
class AdminController extends controller.Controller

    constructor: () ->



    addFeatured: (req, res, next) =>
        if  req.query.adminKey != conf.adminKey
            res.send { success: false, message: 'BAD_KEY'}
        else
            models.Story.getById req.query.storyid, (err, story) =>                
                entry = { type: 'FEATURED', story: req.query.storyid, content: story.cache.html }
                database.insert 'sitesettings', entry, () =>
                    res.send { success: true }


        
    removeFeatured: (req, res, next) =>
        if  req.query.adminKey != conf.adminKey
            res.send { success: false, message: 'BAD_KEY'}
        else
            database.remove 'sitesettings', { type: 'FEATURED', story: req.query.storyid }, () =>
                res.send { success: true }


                
    reloadSettings: (req, res, next) =>
        if  req.query.adminKey != conf.adminKey
            res.send { success: false, message: 'BAD_KEY'}
        else    
            database.find 'sitesettings', {}, (err, cursor) =>
                cursor.toArray (err, items) =>
                    global.cachingWhale.add 'sitesettings', items
                    res.send { success: true, message: 'Reloaded settings.'}
                


exports.AdminController = AdminController            
            
            
