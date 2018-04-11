package cgs.server.logging;

import cgs.server.logging.requests.IServerRequest;

interface ILogRequestHandler
{

    function sendLogRequest(request : IServerRequest) : Void
    ;
}
