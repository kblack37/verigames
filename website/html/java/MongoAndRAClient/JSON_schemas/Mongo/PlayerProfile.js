/*
 * Copyright (c) 2012 TopCoder, Inc. All rights reserved.
 */
"use strict";

var mongoose = require('../services/datasources').getMongoose(),
    Schema = mongoose.Schema,
    ObjectId = Schema.Types.ObjectId;

/**
 * The Player Profile schema.
 * @author wdorin
 * @version 1.0
 */
 
var LevelState = ["ACTIVE", "INACTIVE", "DRAFT"];
var PlayerProfileSchema = new Schema({
    playerId: { type: ObjectId, ref: "User", required: true},
    gameId: {type: ObjectId, ref: "Game", required: true},
	comment: { type: String, required: false},
	status: { type: String, "enum": LevelState, required: true},
	validFrom : { type: Date, required: true},
	validTo : { type: Date, required: true}

	preference: {
		parameter:  [
			{
				name: { type: String, required: true},
				rangeFrom: { type: Number, required: true},
				rangeTo: { type:Number, required: true},
				value  : { type: Number, required: true}
			}
		]
		tag: [
			{
				name: { type: String, required: true}
				value: { type: Number, required: true}
			}
		]
	},
	
	skill: {
		parameter:  [
			{
				name: { type: String, required: true},
				rangeFrom: { type: Number, required: true},
				rangeTo: { type:Number, required: true},
				value  : { type: Number, required: true}
			}
		]
		tag: [
			{
				name: { type: String, required: true}
				value: { type: Number, required: true}
			}
		]
	}
});

PlayerProfileSchema.index({ playerId: -1, gameId: -1}, { unique: true});


// export the schema
module.exports = {
    PlayerProfileSchema: PlayerProfileSchema
};