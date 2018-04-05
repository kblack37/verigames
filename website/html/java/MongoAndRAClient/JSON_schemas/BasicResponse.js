/**
 * The Basic Response Schema.
 *
 * This is the RA response to:
 *	 match refusal report request
 *	 level stopped report request
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var BasicResponseSchema = new Schema({
 {
    success			: { type: Boolean, required: true},
	timeout			: { type: Boolean, required: true},
    id				: { type: String, required: true}
}