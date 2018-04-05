import java.util.ArrayList;

import com.cra.csfvRaRest.schemas.responses.CreatePrincipalResponse;


public class RALevelInserter extends RA
{
	
	public static ArrayList<String>parentIDList = new ArrayList<String>();
	
	public static ArrayList<String> nameList = new ArrayList<String>();
	
	public static void main(String[] args)
	{
		try{
			RALevelInserter raInserter = new RALevelInserter();
			String levelID = raInserter.createNewLevel();
			System.out.println("Level ID is: " + levelID);
		}
		catch(Exception e)
		{
			System.out.println(e);
		}
	}

	public RALevelInserter()
	{
		
	}
	
	public String createNewLevel()
	{
		try{
			CreatePrincipalResponse response = createLevel();
			return response.id;
		}
		catch(Exception e)
		{
			System.out.println(e);
		}
		
		return null;
	}
}
