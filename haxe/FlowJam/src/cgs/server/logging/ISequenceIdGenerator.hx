package cgs.server.logging;


interface ISequenceIdGenerator
{
    
    var nextSessionSequenceId(get, never) : Int;    
    
    var nextQuestSequenceId(get, never) : Int;

}
