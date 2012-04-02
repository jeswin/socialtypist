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
                document.createdDate = new Mongo.Long(new Date().getTime())
                collection.insert document, { safe: true }, (e, r) ->
                    cb(e, r[0])
                    completionCB(e)

    updateFields: (collectionName, criteria, document, cb) ->
        @execute (db, completionCB) ->
            db.collection collectionName, (err, collection) ->
                collection.update criteria, document, (e, r) ->
                    cb(e, r)
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
                collection.update params, document, (e, r) ->
                    cb(e, r)
                    completionCB(e)

    find: (collectionName, params, cb) ->
        @execute (db, completionCB) ->
            db.collection collectionName, (err, collection) ->
                collection.find(params).toArray (e ,r) ->
                    cb(e, r)
                    completionCB(e)

    # could be done in a better way
    findWithOptions: (collectionName, params, options, cb) ->
        @execute (db, completionCB) ->
            db.collection collectionName, (err, collection) ->
                collection.find(params, options).toArray (e ,r) ->
                    cb(e, r)
                    completionCB(e)

    findOne: (collectionName, params, cb) ->
        @execute (db, completionCB) ->
            db.collection collectionName, (err, collection) ->
                collection.findOne params, (e ,r) ->
                    cb(e, r)
                    completionCB(e)

    construct: (collectionName, params, constructor, cb) ->
        @findOne collectionName, params, (err, result) ->
            if not err
                if result
                    cb err, new constructor(result)
                else
                    cb err, null
            else
                utils.dumpError err

    ObjectId: (id) ->
        if id instanceof String then new Mongo.BSONPure.ObjectID(id) else id

exports.Database = Database
