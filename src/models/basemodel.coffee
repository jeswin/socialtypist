utils = require('../common/utils')

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)
        meta = this.constructor._meta
        if @_id
            @_id = meta.type._database.ObjectId(@_id)
           
           
    @get: (params, cb) =>
        meta = @_meta
        @_database.findOne meta.collection, params, (err, result) =>
            cb err, if result then new meta.type(result)
            
           
    @getById: (id, cb) =>
        meta = @_meta
        @_database.findOne meta.collection, { '_id': @_database.ObjectId(id) }, (err, result) =>
            cb err, if result then new meta.type()


    save: (cb) =>
        #Don't save _objects, which holds instances of linked objects.
        if @_objects?
            delete @_objects
            
        meta = this.constructor._meta
        if not this._id?
            if meta.logging?.isLogged
                event = {}
                event.type = meta.logging.onInsert
                event.data = this
                meta.type._database.insert 'events', event, () =>
            meta.type._database.insert meta.collection, this, (err, r) =>
                if cb?
                    cb err, r
        else
            meta.type._database.update meta.collection, this, (err, r) =>
                if cb?
                    cb err, r


exports.BaseModel = BaseModel

