/**
 * The Create Principal Response Schema
 *
 * This is the RA response to an create principal request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var GetPrincipalStatusResponse = new Schema({
    success			: { type : Boolean, required : true},
	timeout			: { type : Boolean, required : true},
	id				: { type : String, required: true },
	principalType	: { type : String, required : true},
	inCache			: { type : Boolean, required : true},
	active			: { type : Boolean, required : true}
});