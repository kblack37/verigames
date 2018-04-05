package constraints 
{
	
	public interface INodeProps 
	{
		function isClause():Boolean;
		function isNarrow():Boolean;
		function isSelected():Boolean;
		function isSolved():Boolean;
		function hasError():Boolean;
	}
	
}