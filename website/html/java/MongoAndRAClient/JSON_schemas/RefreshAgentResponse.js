/**
 * The Activate Agent Response Schema.
 *
 * This is the RA response to an activate agent request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var ActivateAgentResponseSchema = new Schema({
    success			: { type : Boolean, required : true},
	timeout			: { type : Boolean, required : true},
	principalType	: { type : String, required : true},
    id				: { type : String, required: true }
});