/**
 * The Search Levels Response Schema
 *
 * This is the RA response to an search levels request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var SetPrincipalMetadataResponseSchema = new Schema({
    success			: { type : Boolean, required : true},
	timeout			: { type : Boolean, required : true},
	principalType	: { type : String, required : true},
    ids				: [ { type : String, required: false } ]
});