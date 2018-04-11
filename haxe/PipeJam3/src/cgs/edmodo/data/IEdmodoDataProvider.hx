package cgs.edmodo.data;


interface IEdmodoDataProvider
{

    function getUserData(userToken : String) : EdmodoUserData
    ;
    
    function getGroupData(groupID : Int) : EdmodoGroupData
    ;
}
