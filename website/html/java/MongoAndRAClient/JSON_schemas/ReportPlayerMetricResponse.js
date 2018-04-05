/**
 * The Report Player Metric Response Schema.
 *
 * This is the RA response to an Report Player Metric request (Performance and Preference)
 *
 * @author wdorin, CRA
 * @version 1.0
 */
var ReportPlayerMetricResponse = new Schema({
    success			: { type : Boolean, required : true},
	timeout			: { type : Boolean, required : true},
	playerId		: { type : String, required : true},
    levelId			: { type : String, required: true },
	typeOfUpdate	: { type : String, required : true},
    metric			: { type : Number, required: true },
});