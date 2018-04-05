/**
 * The Level Started Response Schema.
 *
 * This is the RA response to a level started report request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var LevelStartedResponseSchema = new Schema({
    success			: { type : Boolean, required : true},
	timeout			: { type : Boolean, required : true},
    playerId		: { type : String, required: true },
	levelId			: { type : Boolean, required : true }
});