Mongo = require 'mongodb'
utils = require './utils'

class Database
    constructor: (@conf) ->


    getDb: () ->
        #return new Db('signalsDb', new Server(host, port, {}), {native_parser:true})
        return new Mongo.Db(@conf.name, new Mongo.Server(@conf.host, @conf.port, {}), {})


    execute: (task) ->
        db = @getDb()
        db.open (err, db) ->
            try
                task db, (err) ->
            catch e
                utils.dumpError e



    insert: (collectionName, document, cb) ->
        @execute (db, completionCB) ->
            db.collection collectionName, (err, collection) ->
                collection.insert document, { safe: true }, (e, r) ->
                    cb(e, r[0])
                    completionCB(e)



    update: (collectionName, document, cb) ->
        @execute (db, completionCB) ->
            db.collection collectionName, (err, collection) ->
                collection.update { _id: document._id }, document, { safe:true }, (e, r) ->
                    cb(e, r)
                    completionCB(e)



    updateMany: (collectionName, params, document, cb) ->
        @execute (db, completionCB) ->
            db.collection collectionName, (err, collection) ->
                collection.update params, document, { safe: true, multi: true }, (e, r) ->
                    cb(e, r)
                    completionCB(e)



    find: (collectionName, query, cb) ->
        @execute (db, completionCB) ->
            db.collection collectionName, (err, collection) ->
                cursor = collection.find query
                cb err, cursor
                completionCB(err)
                

                
    findOne: (collectionName, query, cb) ->        
        @find collectionName, query, (err, cursor) ->
            cursor.nextObject (err, item) ->
                cb err, item
        

                    
    remove: (collection, document, cb) ->
        @execute (db, completionCB) ->
            db.collection collectionName, (err, collection) ->
                collection.remove { _id: document._id }, { safe:true }, (e, r) ->
                    cb(e, r)
                    completionCB(e)
                    

    ObjectId: (id) ->
        if typeof id == "string" then new Mongo.BSONPure.ObjectID(id) else id

exports.Database = Database
