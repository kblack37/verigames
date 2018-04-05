/**
 * The Match Response Schema.
 *
 * This is the RA response to a match request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var MatchResponseSchema = new Schema({
 {
    success			: { type: Boolean, required: true},
	timeout			: { type: Boolean, required: true},
    id				: { type: String, required: true},
	constrained		: { type: Boolean, required: true},
    matches			: [ { type: Match, required: true} ]
}

var MatchSchema = new Schema({
 {
	bid			: [	{ type : Number, required : true } ],
	playerId	: [	{ type : Boolean, required : true } ],
	levelId		: [	{ type : Number, required : true } ]
}