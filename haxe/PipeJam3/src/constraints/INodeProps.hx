package constraints;


interface INodeProps
{

    function isClause() : Bool
    ;
    function isNarrow() : Bool
    ;
    function isSelected() : Bool
    ;
    function isSolved() : Bool
    ;
    function hasError() : Bool
    ;
}

