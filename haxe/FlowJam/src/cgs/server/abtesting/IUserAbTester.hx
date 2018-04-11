package cgs.server.abtesting;

import cgs.server.responses.CgsResponseStatus;

typedef ConditionsCallback = CgsResponseStatus -> Void;

@:enum 
abstract SkeyHashVersion(Int)
{
	var NO_SKEY_HASH = 0;
	var UUID_SKEY_HASH = 1;
	var DATA_SKEY_HASH = 2;
}

interface IUserAbTester extends ICgsUserAbTester
{

    function loadTestConditions(callback : ConditionsCallback, existing : Bool = false) : Void
    ;
}
