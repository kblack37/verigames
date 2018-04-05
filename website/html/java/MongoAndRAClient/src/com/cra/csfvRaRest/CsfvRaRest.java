/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest;

import java.util.ArrayList;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.cra.csfvRaRest.schemas.Constraint;
import com.cra.csfvRaRest.schemas.requests.SetLevelMetadataRequest;
import com.cra.csfvRaRest.schemas.responses.ActivateAgentResponse;
import com.cra.csfvRaRest.schemas.responses.ActivateManyAgentsResponse;
import com.cra.csfvRaRest.schemas.responses.AgentStatusResponse;
import com.cra.csfvRaRest.schemas.responses.CreatePrincipalResponse;
import com.cra.csfvRaRest.schemas.responses.DeactivateAgentResponse;
import com.cra.csfvRaRest.schemas.responses.DeactivateManyAgentsResponse;
import com.cra.csfvRaRest.schemas.responses.DeletePrincipalResponse;
import com.cra.csfvRaRest.schemas.responses.MatchResponse;
import com.cra.csfvRaRest.schemas.responses.PlayerStartedLevelResponse;
import com.cra.csfvRaRest.schemas.responses.PlayerStoppedLevelResponse;
import com.cra.csfvRaRest.schemas.responses.RaStatusReportResponse;
import com.cra.csfvRaRest.schemas.responses.ReportPlayerMetricResponse;
import com.cra.csfvRaRest.schemas.responses.RequestMetadataResponse;
import com.cra.csfvRaRest.schemas.responses.SearchLevelsResponse;
import com.cra.csfvRaRest.schemas.responses.SetLevelMetadataResponse;
import com.cra.csfvRaRest.schemas.responses.VersionResponse;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.jayway.restassured.RestAssured;

public class CsfvRaRest {
  static final Gson gson = getGson();
  private static Logger log = LoggerFactory.getLogger(CsfvRaRest.class);
  private final Integer gameId = 1;

  public CsfvRaRest(String baseURI, Integer portNumber) {
    this.init(baseURI, portNumber);
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
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.post(requestUrl).body().asString();
    CreatePrincipalResponse response = gson.fromJson(jsonString, CreatePrincipalResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }
  
  public CreatePrincipalResponse createExistingPrincipal(PrincipalType principalType, String id) {
	    String requestUrl;
	    switch (principalType) {
	    case LEVEL:
	      requestUrl = "/ra/games/" + gameId + "/levels/new";
	      break;
	    case PLAYER:
	      requestUrl = "/ra/games/" + gameId + "/players/id/new";
	      break;
	    default:
	      return new CreatePrincipalResponse(false, false, "NOTHING", "000000000000000000000000");
	    }
	    log.debug("URL: " + requestUrl);
	    String jsonString = RestAssured.post(requestUrl).body().asString();
	    CreatePrincipalResponse response = gson.fromJson(jsonString, CreatePrincipalResponse.class);
	    log.debug("Response: " + response.toString());
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
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.delete(requestUrl).body().asString();
    DeletePrincipalResponse response = gson.fromJson(jsonString, DeletePrincipalResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public SetLevelMetadataResponse setPriority(String levelId, Integer priority) {
    String requestUrl = "/ra/games/" + gameId + "/levels/" + levelId + "/priority/" + priority + "/set";
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.put(requestUrl).body().asString();
    SetLevelMetadataResponse response = gson.fromJson(jsonString, SetLevelMetadataResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public ActivateManyAgentsResponse activateAllAgents(PrincipalType principalType) {
    String requestUrl;
    switch (principalType) {
    case LEVEL:
      requestUrl = "/ra/games/" + gameId + "/activateAllLevels";
      break;
    case PLAYER:
      requestUrl = "/ra/games/" + gameId + "/activateAllPlayers";
      break;
    default:
      return new ActivateManyAgentsResponse(false, false, "NOTHING", new ArrayList<String>());
    }
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.put(requestUrl).body().asString();
    ActivateManyAgentsResponse response = gson.fromJson(jsonString, ActivateManyAgentsResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public DeactivateManyAgentsResponse deactivateAllAgents(PrincipalType principalType) {
    String requestUrl;
    switch (principalType) {
    case LEVEL:
      requestUrl = "/ra/games/" + gameId + "/activateAllLevels";
      break;
    case PLAYER:
      requestUrl = "/ra/games/" + gameId + "/activateAllPlayers";
      break;
    default:
      return new DeactivateManyAgentsResponse(false, false, "NOTHING", new ArrayList<String>());
    }
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.put(requestUrl).body().asString();
    DeactivateManyAgentsResponse response = gson.fromJson(jsonString, DeactivateManyAgentsResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public RaStatusReportResponse getReport() {
    String requestUrl = "/ra/games/" + gameId + "/report";
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.get(requestUrl).body().asString();
    RaStatusReportResponse response = gson.fromJson(jsonString, RaStatusReportResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public VersionResponse getVersion() {
    String requestUrl = "/ra/version";
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.get(requestUrl).body().asString();
    VersionResponse response = gson.fromJson(jsonString, VersionResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public DeactivateAgentResponse deactivateAgent(String id, PrincipalType principalType) {
    String requestUrl;
    switch (principalType) {
    case LEVEL:
      requestUrl = "/ra/games/" + gameId + "/levels/" + id + "/deactivate";
      break;
    case PLAYER:
      requestUrl = "/ra/games/" + gameId + "/players/" + id + "/deactivate";
      break;
    default:
      return new DeactivateAgentResponse(false, false, id, null);
    }
    System.out.println("URL: " + requestUrl);
    String jsonString = RestAssured.put(requestUrl).body().asString();
    DeactivateAgentResponse response  = gson.fromJson(jsonString, DeactivateAgentResponse.class);
//    log.debug("Response: " + response.toString());
    return response;
  }

  public ActivateAgentResponse activateAgent(String id, PrincipalType principalType) {
    String requestUrl;
    switch (principalType) {
    case LEVEL:
      requestUrl = "/ra/games/" + gameId + "/levels/" + id + "/activate";
      break;
    case PLAYER:
      requestUrl = "/ra/games/" + gameId + "/players/" + id + "/activate";
      break;
    default:
      return new ActivateAgentResponse(false, false, id, false);
    }
    System.out.println("URL: " + requestUrl);
    String jsonString = RestAssured.put(requestUrl).body().asString();
    System.out.println("response: " + jsonString);
//    ActivateAgentResponse response = gson.fromJson(jsonString, ActivateAgentResponse.class);
//    System.out.println("Response: " + response.toString());
    return null;
  }

  public PlayerStartedLevelResponse playerStartedLevel(String playerId, String levelId) {
    String requestUrl = "/ra/games/" + gameId + "/players/" + playerId + "/levels/" + levelId + "/started";
    System.out.println("URL: " + requestUrl);
    String jsonString = RestAssured.put(requestUrl).body().asString();
    PlayerStartedLevelResponse response = gson.fromJson(jsonString, PlayerStartedLevelResponse.class);
    System.out.println("Response: " + response.toString());
    return response;
  }

  public MatchResponse requestMatch(String id, Integer count) {
    return requestMatchWithConstraint(id, count, new Constraint());
  }

  public MatchResponse requestMatchWithConstraint(String playerId, Integer count, Constraint cst) {
    String requestUrl = "/ra/games/" + gameId + "/players/" + playerId + "/count/" + count + "/match";
    log.debug("URL: " + requestUrl);
    String requestBodyJson = gson.toJson(cst);
    log.debug("Request Body: " + requestBodyJson);
    String jsonString = RestAssured.given().contentType("application/json").body(requestBodyJson).when().post(requestUrl).body()
        .asString();
    MatchResponse response = gson.fromJson(jsonString, MatchResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public SearchLevelsResponse searchLevels(Constraint cst, Integer count) {
    String requestUrl = "/ra/games/" + gameId + "/levels/count/" + count + "/search";
    log.debug("URL: " + requestUrl);
    String requestBodyJson = gson.toJson(cst);
    log.debug("Request Body: " + requestBodyJson);
    String jsonString = RestAssured.given().contentType("application/json").body(requestBodyJson).when().post(requestUrl).body()
        .asString();
    SearchLevelsResponse response = gson.fromJson(jsonString, SearchLevelsResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  
  public RequestMetadataResponse getLevelMetadata(String levelId) {
    String requestUrl = "/ra/games/" + gameId + "/levels/" + levelId + "/metadata";
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.get(requestUrl).body().asString();
    RequestMetadataResponse response = gson.fromJson(jsonString, RequestMetadataResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public PlayerStoppedLevelResponse playerStoppedLevel(String playerId) {
    String requestUrl = "/ra/games/" + gameId + "/players/" + playerId + "/stopped";
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.put(requestUrl).body().asString();
    PlayerStoppedLevelResponse response = gson.fromJson(jsonString, PlayerStoppedLevelResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public SetLevelMetadataResponse declareLevelMetadata(SetLevelMetadataRequest levelMetadata) {
    String requestUrl = "/ra/games/" + gameId + "/levels/metadata";
    log.debug("URL: " + requestUrl);
    String requestBodyJson = gson.toJson(levelMetadata);
    log.debug("Request Body: " + requestBodyJson);
    String jsonString = RestAssured.given().contentType("application/json").body(requestBodyJson).when().post(requestUrl).body()
        .asString();
    SetLevelMetadataResponse response = gson.fromJson(jsonString, SetLevelMetadataResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public SetLevelMetadataResponse updateLevelMetadata(SetLevelMetadataRequest levelMetadata) {
    String requestUrl = "/ra/games/" + gameId + "/levels/metadata";
    log.debug("URL: " + requestUrl);
    String requestBodyJson = gson.toJson(levelMetadata);
    log.debug("Request Body: " + requestBodyJson);
    String jsonString = RestAssured.given().contentType("application/json").body(requestBodyJson).when().put(requestUrl).body()
        .asString();
    SetLevelMetadataResponse response = gson.fromJson(jsonString, SetLevelMetadataResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public ReportPlayerMetricResponse reportPlayerMetric(String playerId, String levelId, ReportType reportType, Integer metric) {
    String requestUrl;
    switch (reportType) {
    case PERFORMANCE:
      requestUrl = "/ra/games/" + gameId + "/players/" + playerId + "/levels/" + levelId + "/performance/" + metric + "/report";
      break;
    case PREFERENCE:
      requestUrl = "/ra/games/" + gameId + "/players/" + playerId + "/levels/" + levelId + "/preference/" + metric + "/report";
      break;
    default:
      return new ReportPlayerMetricResponse(false, false, playerId, levelId, "NONE", 0.0);
    }
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.post(requestUrl).body().asString();
    log.debug("JSON String response" + jsonString);
    ReportPlayerMetricResponse response = gson.fromJson(jsonString, ReportPlayerMetricResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public AgentStatusResponse getAgentStatus(String id, PrincipalType principalType) {

    String requestUrl;
    switch (principalType) {
    case LEVEL:
      requestUrl = "/ra/games/" + gameId + "/levels/" + id + "/active";
      break;
    case PLAYER:
      requestUrl = "/ra/games/" + gameId + "/players/" + id + "/active";
      break;
    default:
      return new AgentStatusResponse(false, false, id, "UNKNOWN", false, false);
    }
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.get(requestUrl).body().asString();
    log.debug("Response String: " + jsonString);
    AgentStatusResponse response = gson.fromJson(jsonString, AgentStatusResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

  public PlayerStoppedLevelResponse playerRefusedMatch(String playerId) {
    String requestUrl = "/ra/games/" + gameId + "/players/" + playerId + "/stopped";
    log.debug("URL: " + requestUrl);
    String jsonString = RestAssured.put(requestUrl).body().asString();
    PlayerStoppedLevelResponse response = gson.fromJson(jsonString, PlayerStoppedLevelResponse.class);
    log.debug("Response: " + response.toString());
    return response;
  }

}
