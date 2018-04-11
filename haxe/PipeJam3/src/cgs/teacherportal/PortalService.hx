package cgs.teacherportal;

import openfl.utils.Dictionary;
import cgs.server.CgsService;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.messages.Message;
import cgs.server.logging.quests.QuestLogger;
import cgs.server.logging.requests.ServerRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.teacherportal.data.QuestPerformance;
import flash.net.URLLoaderDataFormat;

class PortalService extends CgsService
{
    private static inline var LOG_QUEST_PERFORMANCE : String = "userperformance/log";
    
    private var _pendingPerformance : Dictionary<String, Dynamic>;
    
    public function new(
            requestHandler : IUrlRequestHandler,
            serverTag : String, version : Int = CURRENT_VERSION)
    {
        super(requestHandler, serverTag, version);
    }
    
    /**
     * Log quest performance to the server. QuestPerformance instance can be created
     * by called cgsUser.createQuestPeformance before the end of the associated quest
     * is logged.
     * 
     * @param peformance the performance to be logged to the server.
     */
    public function logUserPerformance(performance : QuestPerformance) : Void
    {
        if (performance.hasQuestEnded)
        {
            localLogQuestPerformance(performance);
        }
        else
        {
            //Send the performance after the quest end is logged.
            performance.addEndedCallback(handlePerformanceReady);
            _pendingPerformance[performance.questLogger] = performance;
        }
    }
    
    private function handlePerformanceReady(logger : QuestLogger) : Void
    {
        var perf : QuestPerformance = _pendingPerformance[logger];
        if (perf != null)
        {
            This is an intentional compilation error. See the README for handling the delete keyword
            delete _pendingPerformance[logger];
            
            localLogQuestPerformance(perf);
        }
    }
    
    private function localLogQuestPerformance(performance : QuestPerformance) : Void
    {
        var message : Message = performance.createMessage();
        
        message.addProperty("performance", performance.performance);
        message.addProperty("won", (performance.won) ? 1 : 0);
        message.addProperty("moves", performance.numberMoves);
        message.addProperty("playtime", performance.activePlaytime);
        message.addProperty("start_time", performance.startTime);
        message.addProperty("end_time", performance.endTime);
        message.addProperty("qid", performance.questId);
        
        var request : ServerRequest = new ServerRequest(
        LOG_QUEST_PERFORMANCE, null, message.messageObject, null, null, 
        URLLoaderDataFormat.TEXT, null, performance.gameServerData);
        
        if (performance.isDqidValid())
        {
            message.addProperty("dqid", performance.dqid);
        }
        else
        {
            performance.addDqidCallback(function handleDqid(dqid : String) : Void
                    {
                        message.addProperty("dqid", dqid);
                    });
            request.addDependencyById(performance.dqidRequestId, true);
        }
        
        request.message = message;
        request.requestType = ServerRequest.POST;
        request.generalUrl = url;
        request.urlType = ServerRequest.GENERAL_URL;
        
        requestHandler.sendUrlRequest(request);
    }
}
