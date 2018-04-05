/**
 * The Level Metadata schema.
 * @author wdorin, CRA
 * @version 1.0
 *
 * principally used in the Set Level Metadata Request schema and the Get Level Metadata Report schema.
 */

var LevelMetadataSchema = new Schema({
	priority		: { type: Number, required : true  },
	comment			: { type: String, required : true  },
	parameters		: [ { type : Trait, required : true } ],
	properties		: [ { type : Trait, required : true } ],
	tags			: [ { type : Trait, required : true } ],
	labels			: [ { type : Trait, required : true } ],
	parentId		: { type: String, required : true  },
	predecessorId	: { type: String, required : true  }
});
	
var TraitSchema = new Schema({
	name : { type: String, required: true},
	value: { type: Number, required: true}
});

var DescriptorSchema = new Schema({
	name : { type: String, required: true},
	value: { type: Number, required: true}
});