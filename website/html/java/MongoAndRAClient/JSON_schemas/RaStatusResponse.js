/**
 * The Resource Allocator Status Response Schema
 *
 * This is the RA response to the an RA Status Request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var RaStatusResponse = new Schema({
    success				: { type : Boolean, required : true},
	timeout				: { type : Boolean, required : true},
	playersInCache		: [ { type : String, required: true } ],
	levelsInCache		: [ { type : String, required: true } ],
	activePlayerAgents	: [ { type : String, required: true } ],
	activeLevelAgents	: [ { type : String, required: true } ],
	activeAuctions		: [ { type : String, required: true } ],
	activeEscrows		: [ { type : String, required: true } ]
});