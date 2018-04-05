/**
 * The Constraint Schema.
 *
 * This is the sole input to the Search Levels Request call
 * 	it's also used by the Match Request call
 *
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var ConstraintSchema = new Schema({
 {
	parameter		: [	{ type : RangeConstraint, required : false } ],
	property		: [	{ type : RangeConstraint, required : false } ],
	tag				: [	{ type : DescriptorConstraint, required : false } ],
	label			: [	{ type : DescriptorConstraint, required : false } ],
	priority		: [	{ type : RangeConstraint, required : false } ],
	parentId		: [	{ type : DescriptorConstraint, required : false } ],
	predecessorId	: [	{ type : DescriptorConstraint, required : false } ]
}

var RangeConstraintSchema = new Schema({
 {
	name		: [	{ type : String, required : true } ],
	isRequired	: [	{ type : Boolean, required : true } ],
	from		: [	{ type : Number, required : true } ],
	to			: [	{ type : Nubmer, required : true } ]
}

var DescriptorConstraintSchema = new Schema({
 {
	name		: [	{ type : String, required : true } ],
	isRequired	: [	{ type : Boolean, required : true } ]
}