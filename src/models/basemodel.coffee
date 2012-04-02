utils = require('../common/utils')

class BaseModel

    constructor: (params) ->
        utils.extend(this, params)
        meta = this.constructor._meta

           
           
    @get: (params, cb) ->
        meta = @_meta
        @_database.findOne meta.collection, params, (err, result) ->
            cb err, if result then new meta.type(result)
            
           
    @getById: (id, cb) ->
        meta = @_meta
        @_database.findOne meta.collection, { _id: @_database.ObjectId(id) }, (err, result) ->
            cb err, if result then new meta.type()


    save: (cb) ->
        meta = this.constructor._meta
        if not this._id?
            if meta.logging?.isLogged
                event = {}
                event.type = meta.logging.onInsert
                event.data = this
                meta.type._database.insert 'events', event, () -> 
            meta.type._database.insert meta.collection, this, () ->
                if cb?
                    cb()
        else
            meta.type._database.update meta.collection, this, () ->
                if cb?
                    cb()


exports.BaseModel = BaseModel

