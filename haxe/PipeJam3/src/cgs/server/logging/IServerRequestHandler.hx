package cgs.server.logging;

import cgs.server.logging.requests.IServerRequest;

interface IServerRequestHandler
{

    function request(serverRequest : IServerRequest) : Void
    ;
}
