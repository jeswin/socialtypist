controller = require('./controller')
dbconf = require '../../models/dbconf'
database = new (require '../../common/database').Database(dbconf.default)       
models = new (require '../../models').Models(dbconf.default) 
conf = require '../conf'

#QUICK ADMIN HACK
class AdminController extends controller.Controller

    constructor: () ->



    index: (req, res, next) =>
        if  @getValue(req.query, 'adminKey') != conf.adminKey
            res.send { success: false, message: 'BAD_KEY'}
        else
            req.session.admin = true
            
            items = []
            for item in global.cachingWhale.items.sitesettings
                items.push JSON.stringify(item).substring(0,250)
            
            res.render 'admin/index.hbs', { layout: false, items: items }



    logout: (req, res, next) =>
        req.session.destroy()
        res.send 'Logged out.'



    featured: (req, res, next) =>
        if req.session.admin
            database.find 'sitesettings', {}, (err, cursor) =>
                cursor.toArray (err, items) =>
                    res.render 'admin/featured.hbs', { items: items, layout: false }
        else
            res.send 'No session.'



    addFeatured: (req, res, next) =>
        if req.session.admin
            fn = () =>
                models.Story.getById @getValue(req.body, 'storyid'), (err, story) =>                
                    entry = { type: 'FEATURED', storyid: story._id.toString(), title: story.title, content: story.cache.html }
                    database.insert 'sitesettings', entry, () =>
                        res.redirect '/admin/featured'

        
            #if there is already such a thing, delete.
            database.findOne 'sitesettings', { type: 'FEATURED', storyid: @getValue(req.body, 'storyid') }, (err, item) =>
                if item?
                    database.removeById 'sitesettings', item._id, () =>
                        fn()
                else
                    fn()
        else
            res.send 'No session.'


        
    removeFeatured: (req, res, next) =>
        if req.session.admin
            database.removeById 'sitesettings', @getValue(req.params, 'id'), () =>
                res.redirect '/admin/featured'
        else
            res.send 'No session.'



                
    reloadSettings: (req, res, next) =>
        if req.session.admin
            database.find 'sitesettings', {}, (err, cursor) =>
                cursor.toArray (err, items) =>
                    global.cachingWhale.add 'sitesettings', items
                    res.send 'Reloaded settings.'
        else
            res.send 'No session.'
        

exports.AdminController = AdminController            
            
            
