
import java.util.ArrayList;

import com.cra.csfvRaRest.CsfvRaRest;
import com.cra.csfvRaRest.LevelParameters;
import com.cra.csfvRaRest.PrincipalType;
import com.cra.csfvRaRest.schemas.Constraint;
import com.cra.csfvRaRest.schemas.Metadata;
import com.cra.csfvRaRest.schemas.requests.SetLevelMetadataRequest;
import com.cra.csfvRaRest.schemas.responses.*;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.jayway.restassured.RestAssured;

public class RA
{
	int gameId = 1;
	static final Gson gson = getGson();

	static String productionServer = "http://api.flowjam.verigames.com";//"http://ec2-54-226-188-147.compute-1.amazonaws.com"; 
	static String stagingRAServer = "http://ec2-23-22-125-169.compute-1.amazonaws.com";
	static String url = productionServer;
	int port = 80;
	
  public RA() {
    this.init(url, port);
  }

  private void init(String baseURI, Integer portNumber) {
    RestAssured.baseURI = "http://" + baseURI;
    RestAssured.port = portNumber;
    RestAssured.basePath = "";
  }

  public static Gson getGson() {
    GsonBuilder gson = new GsonBuilder();
    return gson.excludeFieldsWithoutExposeAnnotation().create();
  }
  // RA StarJam test
   static CsfvRaRest ra = new CsfvRaRest(url, 80); // StarJam
   static LevelParameters params = new LevelParameters(1, "config/.level_params_starjam");

	
   public String getVersion()
	{	
	   String requestUrl = "/ra/version";

	   System.out.println("request " + requestUrl);
	   String jsonString = RestAssured.get(requestUrl).body().asString();
	    System.out.println(jsonString);
	    return jsonString;
	}
   
   public String agentExists(String id, PrincipalType principalType)
	{	
	   String requestUrl = null;
	   switch (principalType) {
	    case LEVEL:
	      requestUrl = "/ra/games/" + gameId + "/levels/" + id + "/exists";
	      break;
	    case PLAYER:
	      requestUrl = "/ra/games/" + gameId + "/players/" + id + "/exists";
	      break;
	    }
	   System.out.println("request " + requestUrl);
	   String jsonString = RestAssured.get(requestUrl).body().asString();
	    System.out.println(jsonString);
	    return jsonString;
	}
   
	public AgentResponse activateAgent(String playerID, boolean makeActive)
	{	
		if(makeActive)
			return ra.activateAgent(playerID, PrincipalType.PLAYER);
		else
			return ra.deactivateAgent(playerID, PrincipalType.PLAYER);
	}
	
	public AgentResponse activateLevel(String levelID, boolean makeActive)
	{	
		if(makeActive)
			return ra.activateAgent(levelID, PrincipalType.LEVEL);
		else
			return ra.deactivateAgent(levelID, PrincipalType.LEVEL);
	}
	
	public DeletePrincipalResponse deleteAgent(String id, PrincipalType principalType)
	{
		String requestUrl;
	    switch (principalType) {
	    case LEVEL:
	      requestUrl = "/ra/games/" + gameId + "/levels/" + id;
	      break;
	    case PLAYER:
	      requestUrl = "/ra/games/" + gameId + "/players/" + id;
	      break;
	    default:
	      return new DeletePrincipalResponse(false, false, "NOTHING", "000000000000000000000000");
	    }
	    String jsonString = RestAssured.delete(requestUrl).body().asString();
	    DeletePrincipalResponse response = gson.fromJson(jsonString, DeletePrincipalResponse.class);
	    return response;
	}
	
	public CreatePrincipalResponse createPrincipal(PrincipalType principalType) {
	    String requestUrl;
	    switch (principalType) {
	    case RANDOMLEVEL:
	      requestUrl = "/ra/games/" + gameId + "/levels/random";
	      break;
	    case LEVEL:
	      requestUrl = "/ra/games/" + gameId + "/levels/new";
	      break;
	    case RANDOMPLAYER:
	      requestUrl = "/ra/games/" + gameId + "/players/random";
	      break;
	    case PLAYER:
	      requestUrl = "/ra/games/" + gameId + "/players/new";
	      break;
	    default:
	      return new CreatePrincipalResponse(false, false, "NOTHING", "000000000000000000000000");
	    }
	    String jsonString = RestAssured.post(requestUrl).body().asString();
	    System.out.println(jsonString);
	    CreatePrincipalResponse response = gson.fromJson(jsonString, CreatePrincipalResponse.class);
	    return response;
	  }
	
	public CreatePrincipalResponse createExistingPrincipal(PrincipalType principalType, String id) {
	    String requestUrl;
	    switch (principalType) {
	    case LEVEL:
	      requestUrl = "/ra/games/" + gameId + "/levels/"+id+"/new";
	      break;
	    case PLAYER:
	      requestUrl = "/ra/games/" + gameId + "/players/"+id+"/new";
	      break;
	    default:
	      return new CreatePrincipalResponse(false, false, "NOTHING", "000000000000000000000000");
	    }
	    System.out.println("URL: " + requestUrl);
	    String jsonString = RestAssured.post(requestUrl).body().asString();
	    CreatePrincipalResponse response = gson.fromJson(jsonString, CreatePrincipalResponse.class);
	    System.out.println("Response: " + response.toString());
	    return response;
	  }

	  public DeletePrincipalResponse deletePrincipal(String id, PrincipalType principalType) {
	    String requestUrl;
	    switch (principalType) {
	    case LEVEL:
	      requestUrl = "/ra/games/" + gameId + "/levels/" + id;
	      break;
	    case PLAYER:
	      requestUrl = "/ra/games/" + gameId + "/players/" + id;
	      break;
	    default:
	      return new DeletePrincipalResponse(false, false, "NOTHING", "000000000000000000000000");
	    }
	    String jsonString = RestAssured.delete(requestUrl).body().asString();
	    DeletePrincipalResponse response = gson.fromJson(jsonString, DeletePrincipalResponse.class);
	    return response;
	  }
	  
	  public DeletePrincipalResponse deleteLevel(String id)
	  {
		  return deletePrincipal(id, PrincipalType.LEVEL);
	  }
	  
	public CreatePrincipalResponse createRandomLevel()
	{
		return createPrincipal(PrincipalType.RANDOMLEVEL);
	}
	
	public CreatePrincipalResponse createLevel()
	{
		return createPrincipal(PrincipalType.LEVEL);
	}

	    
    public ActivateManyAgentsResponse activateAllAgents(PrincipalType principalType) {
        String requestUrl;
        switch (principalType) {
        case LEVEL:
          requestUrl = "/ra/games/" + gameId + "/activateAllLevels";
          break;
        case PLAYER:
          requestUrl = "/ra/games/" + gameId + "/players/all/activate";
          break;
        default:
          return new ActivateManyAgentsResponse(false, false, "NOTHING", new ArrayList<String>());
        }
        System.out.println("URL: " + requestUrl);
        String jsonString = RestAssured.put(requestUrl).body().asString();
        ActivateManyAgentsResponse response = gson.fromJson(jsonString, ActivateManyAgentsResponse.class);
        System.out.println("Response: " + response.toString());
        return response;
      }
    
    public ActivateManyAgentsResponse deactivateAllAgents(PrincipalType principalType) {
        String requestUrl;
        switch (principalType) {
        case LEVEL:
          requestUrl = "/ra/games/" + gameId + "/deactivateAllLevels";
          break;
        case PLAYER:
          requestUrl = "/ra/games/" + gameId + "/players/all/deactivate";
          break;
        default:
          return new ActivateManyAgentsResponse(false, false, "NOTHING", new ArrayList<String>());
        }
        System.out.println("URL: " + requestUrl);
        String jsonString = RestAssured.put(requestUrl).body().asString();
        ActivateManyAgentsResponse response = gson.fromJson(jsonString, ActivateManyAgentsResponse.class);
        System.out.println("Response: " + response.toString());
        return response;
      }
    
    public void getReport()
    {
    	RaStatusReportResponse report = ra.getReport();
    	System.out.println(report);
    }
/*	
	public HttpResponse activateAllLevels(boolean makeActive)
	{
		String getLevelMetadata;
		if(makeActive)
			getLevelMetadata = "/ra/games/1/activateAllLevels";
		else
			getLevelMetadata = "/ra/games/1/deactivateAllLevels";
		try{
			HttpResponse response = doPut(url, getLevelMetadata);
			return response;
		}
		catch(Exception e)
		{
		}
		return null;
	}
*/
	 public MatchResponse requestMatch(String id, Integer count) {
	    return requestMatchWithConstraint(id, count, new Constraint());
	  }
	
	  public MatchResponse requestMatchWithConstraint(String playerId, Integer count, Constraint cst) {
	    String requestUrl = "/ra/games/" + gameId + "/players/" + playerId + "/count/" + count + "/match";
	    String requestBodyJson = gson.toJson(cst);
	    String jsonString = RestAssured.given().contentType("application/json").body(requestBodyJson).when().post(requestUrl).body()
	        .asString();
	    MatchResponse response = gson.fromJson(jsonString, MatchResponse.class);
	    System.out.println("Response: " + response.toString());
	    return response;
	  }
  
	public PlayerStoppedLevelResponse refuseMatches(String playerID)
	{
		String requestUrl = "/ra/games/" + gameId + "/player/" + playerID + "/refused";
	    String jsonString = RestAssured.put(requestUrl).body().asString();
	    PlayerStoppedLevelResponse response = gson.fromJson(jsonString, PlayerStoppedLevelResponse.class);
	    System.out.println("Response: " + response.toString());
	    return response;
	}

	public SetLevelMetadataResponse setPriority(String levelId, int priority)
	{	
		   String requestUrl = "/ra/games/" + gameId + "/levels/" + levelId + "/priority/" + priority + "/set";
		    String jsonString = RestAssured.put(requestUrl).body().asString();
		    SetLevelMetadataResponse response = gson.fromJson(jsonString, SetLevelMetadataResponse.class);
		    return response;
	}

	
	//doesn't seem to work...
	public SearchLevelsResponse searchForLevels(int count)
	{
		String requestUrl = "/ra/games/1/levels/count/" + count + "/search";
	    String requestBodyJson = gson.toJson(new Constraint());
	    String jsonString = RestAssured.given().contentType("application/json").body(requestBodyJson).when().post(requestUrl).body()
	        .asString();
	    SearchLevelsResponse response = gson.fromJson(jsonString, SearchLevelsResponse.class);
	    System.out.println("Response: " + response.toString());
	    return response;
	}


/*	
	public HttpResponse getLevelStatusReport(String levelID)
	{
		String getLevelMetadata = "/ra/games/1/levels/" + levelID + "/active";
		try{
			HttpResponse response = doGet(url, getLevelMetadata);
			return response;
		}
		catch(Exception e)
		{
		}
		return null;	
	}
	*/

	  public RequestMetadataResponse getLevelMetadata(String levelId) {
	    String requestUrl = "/ra/games/" + gameId + "/levels/" + levelId + "/metadata";
	    String jsonString = RestAssured.get(requestUrl).body().asString();
	    RequestMetadataResponse response = gson.fromJson(jsonString, RequestMetadataResponse.class);
	    return response;
	  }

	  public PlayerStoppedLevelResponse playerStoppedLevel(String playerId) {
	    String requestUrl = "/ra/games/" + gameId + "/players/" + playerId + "/stopped";
	    String jsonString = RestAssured.put(requestUrl).body().asString();
	    PlayerStoppedLevelResponse response = gson.fromJson(jsonString, PlayerStoppedLevelResponse.class);
	    return response;
	  }

	  public SetLevelMetadataResponse declareLevelMetadata(SetLevelMetadataRequest levelMetadata) {
	    String requestUrl = "/ra/games/" + gameId + "/levels/metadata";
	    String requestBodyJson = gson.toJson(levelMetadata);
	    String jsonString = RestAssured.given().contentType("application/json").body(requestBodyJson).when().post(requestUrl).body()
	        .asString();
	    SetLevelMetadataResponse response = gson.fromJson(jsonString, SetLevelMetadataResponse.class);
	    return response;
	  }

	  public SetLevelMetadataResponse updateLevelMetadata(SetLevelMetadataRequest levelMetadata) {
	    String requestUrl = "/ra/games/" + gameId + "/levels/metadata";
	    String requestBodyJson = gson.toJson(levelMetadata);
	    String jsonString = RestAssured.given().contentType("application/json").body(requestBodyJson).when().put(requestUrl).body()
	        .asString();
	    SetLevelMetadataResponse response = gson.fromJson(jsonString, SetLevelMetadataResponse.class);
	    return response;
	  }
	  
	  public static void testLevelCreationWithMetadata(String id) {

		    SetLevelMetadataRequest setMetadataRequest = new SetLevelMetadataRequest();

		    setMetadataRequest.ids.add(id);
		    Metadata lm = new Metadata();
		    lm.priority = 10.0;
		    lm.comment = "a comment";
		    lm.putParameter("difficulty", 10.0);
		    lm.putParameter("type", 1.0);
		    lm.putProperty("boxes", 10.0);
		    lm.putProperty("lines", 10.0);
		    lm.parentId = "000000000000000000000000";
		    lm.predecessorId = "000000000000000000000000";
		    setMetadataRequest.metadata = lm;
		
		    System.out.println("Metadata request " + setMetadataRequest);
	  }
	  
	  public void printResponseAndEntity(Object responseObj)
	  {
		  if(responseObj != null)
			  System.out.println("Response " + responseObj.toString());
	  }
}
