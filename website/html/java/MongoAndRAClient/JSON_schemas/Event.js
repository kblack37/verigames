/*
 * Copyright (c) 2012 TopCoder, Inc. All rights reserved.
 */
"use strict";
var mongoose = require('../services/datasources').getMongoose(),
    Schema = mongoose.Schema,
    ObjectId = Schema.Types.ObjectId;

/**
 * The event schema.
 * @author vangavroche, TCSASSEMBLER
 * @version 1.0
 *
 * @since Module Assembly - CSFV Gaming API REST Controllers v1.0
 * change playerId to ObjectId of User
 *
 *  @since Module Assembly - CSFV Gaming API Part 2 version 1.0
 * remove uique index for playerId and levelId,because finishLevel may create events with same playerId and levelId
 */
var EventSchema = new Schema({
    //The action could be but not limited to "started", "finished", "quit", "abandoned", and "paused", "resumed"
    action    : { type: String, required: true},
    playerId    : { type: ObjectId, ref: "User", required: true},
    levelId   : { type: ObjectId, ref: "Level", required: true},
    reportedOn: { type: Date, required: true}
});


// export the schema
module.exports = {
    EventSchema: EventSchema
};