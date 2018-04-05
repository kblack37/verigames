/**
 * Update Principals schema.
 * 
 * This is the JSON object returned by SetPriority
 * @author wdorin, CRA
 * @version 1.0
 */
var UpdatePrincipalsResponseSchema = new Schema({
    success			: {type: Boolean, required: true},
	timeout			: {type: Boolean, required: true},
    principalType	: { type: String, required: true},
    ids				: [ { type: String, required: true} ]
});
