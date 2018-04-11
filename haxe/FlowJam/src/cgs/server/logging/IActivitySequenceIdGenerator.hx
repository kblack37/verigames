package cgs.server.logging;


interface IActivitySequenceIdGenerator
{
    
    var nextActivitySequenceId(get, never) : Int;

}
