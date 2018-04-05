/**
 * The Get Level Metadata Response Schema
 *
 * This is the RA response to an get level metadata request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var GetLevelMetadataResponseSchema = new Schema({
    success			: { type : Boolean, required : true},
	timeout			: { type : Boolean, required : true},
    id				: { type : String, required : true },
	metadata		: { type : LevelMetadata, required : true}
});