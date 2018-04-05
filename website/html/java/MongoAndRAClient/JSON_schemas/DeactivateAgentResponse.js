/**
 * The Deactivate Agent Response Schema.
 *
 * This is the RA response to a deactivate agent request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var DeactivateAgentResponseSchema = new Schema({
    success			: { type : Boolean, required : true},
	timeout			: { type : Boolean, required : true},
    id				: { type : String, required: true },
	alreadyInactive	: { type : Boolean, required : true }
});