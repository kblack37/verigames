/**
 * The Set Level Metadata Request schema.
 * @author wdorin, CRA
 * 
 * Input to the Set Level Metadata call
 *
 */

var SetLevelMetadataRequestSchema = new Schema({
    ids			: [ { type: String, required: true} ],
    metadata   : { type: LevelMetadata, required : true }
});