/**
 * The Activate Many Agents Response Schema.
 *
 * This is the RA response to an activate many agents request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var ActivateManyAgentResponseSchema = new Schema({
    success			: { type : Boolean, required : true},
	timeout			: { type : Boolean, required : true},
	typeOfAgent		: { type : String, required : true},
    ids				: [ { type : String, required: false } ]
});