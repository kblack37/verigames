package cgs.server;

import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.ICGSServerProps;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.requests.ServerRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.ResponseStatus;
import haxe.Json;
import openfl.net.URLLoaderDataFormat;

/**
 * In most cases a request is funneled through the cgsUser object, however there are
 * some requests where we won't have a user at all. This service provides a set of
 * messages we can send without a user.
 */
class IntegrationDataService extends CgsService
{
    private var _integrationDataServiceServer : ICgsServerApi;
    
    public function new(
            requestHandler : IUrlRequestHandler, server : ICgsServerApi,
            serverTag : String, version : Int = LoggingVersion.CURRENT_VERSION, useHttps : Bool = false)
    {
        super(requestHandler, serverTag, version, useHttps);
        
        _integrationDataServiceServer = server;
    }
    
    /**
     * Check if the the given username is available for use on the server.
     *
     * @param name
     * @param userCallback listener that is called when the server responds.
     * Will be true if the name is available and false if server
     * failed or name is not available.
     */
    public function checkUserNameAvailable(name : String, userCallback : Dynamic) : Void
    {
        _integrationDataServiceServer.checkUserNameAvailable(name, userCallback);
    }
    
    /**
     * Check if the given username is available for a student that is assigned to a particular teacher
     * 
     * @param name
     *      The student name to check
     * @param teacherUid
     *      The uid of the teacher to check student names from.
     *      Can be null, but make sure the teacher code is set if that is the case.
     * @param teacherCode
     *      The teacher code that will indirectly bind the student to a teacher.
     *      Can be null, but make sure the teacher uid is set if that is the case.
     * @param userCallback
     *      Listener that is called when the server responds, accepts single parameter which is a ResponseStatus,
     *      success if the name is available for that teacher and false if the server fails or name is already taken.
     */
    public function checkStudentNameAvailable(name : String, teacherUid : String, teacherCode : String, userCallback : Dynamic) : Void
    {
        _integrationDataServiceServer.checkStudentNameAvailable(name, teacherUid, teacherCode, userCallback);
    }
    
    /**
     * Get the id of the user (one assigned from our own servers) from an external id
     * 
     * @param externalId
     *      An id used by an different organization (like Brainpop) that is used to uniquely identify
     *      a user in that organization
     * @param externalSource
     *      The id that we assigned to the organization we are checking against. (ids are stored in table labeled cgs_external_sources)
     * @param userCallback
     *      Signature userCallback(response:ResponseStatus, uid:String):void
     */
    public function getUserIdFromExternalIdAndSource(externalId : String, externalSource : Int, userCallback : Dynamic) : Void
    {
        // These need to exactly match parameters that the server is seeking
        var data : Dynamic = {
            ext_id : externalId,
            ext_s_id : externalSource
        };
        
        _integrationDataServiceServer.serverRequest(CGSServerConstants.GET_UID_BY_EXTERNAL_ID, null, data, null, 
                ServerRequest.INTEGRATION_URL, userCallback, null, 
                ServerRequest.GET, URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(_integrationDataServiceServer.getCurrentGameServerData()), 
                function(status : ResponseStatus) : Void
                {
					var uid : String = null;
					
                    // Need to manually parse the raw data to get the important parts
                    // Assuming the data comes back like data=[{IMPORTANT_PARTS}]
                    // we want to extract the middle portion
                    // HACK: there is some bizarre situations where the response is a list
                    // to parse this correctly strip off the data= and wrap the array in brackets
                    var strippedData : String = "{\"data\":" + status.rawData.substr(5) + "}";
                    var parsedData : Dynamic = Json.parse(strippedData);
                    var responseList : Array<Dynamic> = parsedData.data;
                    if (responseList.length > 0)
                    {
                        // Just return first of the list, impossible to identify the correct user
                        // if multiple no app should be expecting that
                        uid = responseList[0].uid;
                    }
                    
                    userCallback(status, uid);
                }
        );
    }
    
    /**
     * Update the external id and source of an existing user. This is useful in cases where the user starts as
     * a guest account without logging in from the external organization and then logs in later.
     * The link between the guest account and the existing user needs to be established
     * 
     * @param uid
     * @param externalId
     * @param externalSource
     * @param userCallback
     *      Function signature userCallback(status:ResponseStatus):void
     */
    public function updateExternalIdAndSourceFromUserId(uid : String,
            externalId : String,
            externalSource : Int,
            userCallback : Dynamic) : Void
    {
        var data : Dynamic = {
            uid : uid,
            ext_id : externalId,
            ext_s_id : externalSource
        };
        _integrationDataServiceServer.serverRequest(CGSServerConstants.UPDATE_EXTERNAL_ID, null, data, null, 
                ServerRequest.INTEGRATION_URL, userCallback, null, 
                ServerRequest.POST, URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(_integrationDataServiceServer.getCurrentGameServerData()), 
                function(status : ResponseStatus) : Void
                {
                    if (userCallback != null)
                    {
                        userCallback(status);
                    }
                }
        );
    }
    
    /**
     * Get back various student data packaged in an object
     * 
     * @param uid
     *      The globally unique id for the student
     * @param userCallback
     *      Function signature userCallback(student:Object):void
     *      The student is null if nothing with the uid came back
     *      Otherwise the most important fields are teacher_uid, username, grade_level, gender
     */
    public function getStudentDataFromUid(uid : String, userCallback : Dynamic) : Void
    {
        var data : Dynamic = {
            uid : uid
        };
        _integrationDataServiceServer.serverRequest(CGSServerConstants.GET_STUDENT_BY_UID, null, data, null, 
                ServerRequest.INTEGRATION_URL, userCallback, null, 
                ServerRequest.GET, URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(_integrationDataServiceServer.getCurrentGameServerData()), 
                function(status : ResponseStatus) : Void
                {
                    if (userCallback != null)
                    {
                        // Need to manually parse the raw data to get the important parts
                        // Assuming the raw data comes back like data={"tstatus": "t", "student":[]}
                        // we want to extract the portion in the first curly brackets
                        var strippedData : String = status.rawData.substr(5);
                        var parsedData : Dynamic = Json.parse(strippedData);
                        var studentData : Dynamic = null;
                        if (Reflect.hasField(parsedData, "student") && parsedData.student.length > 0)
                        {
                            studentData = parsedData.student[0];
                        }
                        
                        userCallback(studentData);
                    }
                }
        );
    }
}
