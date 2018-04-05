/*
 * Copyright (c) 2012 TopCoder, Inc. All rights reserved.
 */
"use strict";
var mongoose = require('../services/datasources').getMongoose(),
    Schema = mongoose.Schema,
    ObjectId = Schema.Types.ObjectId;

/**
 * The Level schema.
 * @author wdorin, CRA
 * @version 1.0
 *
 * @since BUGR-7707 CSFV Gaming API Part 1 Assembly - Update 3
 * rework
 */

var LevelSchema = new Schema({
	gameId           : { type: ObjectId, ref: "Game", required: true},
    levelId         : { type: ObjectId, required: true},
    metadata   : [
        {
            priority     : { type: Number, required: true},
            status       : { type: String, "enum": LevelState, required: true},
            comment      : { type: String, required: false},
			parameter    : [
                {
                    name : { type: String, required: true},
                    value: { type: Number, required: true}
                }
            ],
            property     : [
                {
                    name : { type: String, required: true},
                    value: { type: Number, required: true}
                }
            ],
            tag          : [
				{
                    name : { type: String, required: true},
                    value: { type: Boolean, required: true}
                }
			],
			label        : [
				{
                    name : { type: String, required: true},
                    value: { type: Boolean, required: true}
                }
			],
            parentId     : { type: ObjectId, ref: "Level"},
            predecessorId: { type: ObjectId, ref: "Level"},
			validFrom : { type: Date, required: true},
			validTo : { type: Date, required: true}
        }
    ]
});

LevelSchema.index({ levelId: -1, gameId: -1}, { unique: true});

// export the schema
module.exports = {
    LevelSchema: LevelSchema
};