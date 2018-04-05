/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest;

import static com.cra.csfvRaRest.PrincipalType.LEVEL;
import static com.cra.csfvRaRest.PrincipalType.PLAYER;
import static com.cra.csfvRaRest.PrincipalType.RANDOMLEVEL;
import static com.cra.csfvRaRest.PrincipalType.RANDOMPLAYER;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.cra.csfvRaRest.schemas.Constraint;
import com.cra.csfvRaRest.schemas.Constraint.RangeConstraint;
import com.cra.csfvRaRest.schemas.Metadata;
import com.cra.csfvRaRest.schemas.Metadata.Trait;
import com.cra.csfvRaRest.schemas.requests.SetLevelMetadataRequest;
import com.cra.csfvRaRest.schemas.responses.AgentStatusResponse;
import com.cra.csfvRaRest.schemas.responses.CreatePrincipalResponse;
import com.cra.csfvRaRest.schemas.responses.MatchResponse;
import com.cra.csfvRaRest.schemas.responses.PlayerStoppedLevelResponse;
import com.cra.csfvRaRest.schemas.responses.RaStatusReportResponse;
import com.cra.csfvRaRest.schemas.responses.RequestMetadataResponse;
import com.cra.csfvRaRest.schemas.responses.SearchLevelsResponse;
import com.cra.csfvRaRest.schemas.responses.SetLevelMetadataResponse;
import com.cra.csfvRaRest.schemas.responses.VersionResponse;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class CsfvRaRestTest {

  static Set<String> playerIds = new HashSet<String>();
  static Set<String> levelIds = new HashSet<String>();

  // static CsfvRaRest ra = new CsfvRaRest("localhost", 9000); // CRA Dev RA
  // static LevelParameters params = new LevelParameters(1, "config/.level_params_ratest");

  // RA Dev Server test
  // static final CsfvRaRest ra = new CsfvRaRest("ec2-23-20-198-101.compute-1.amazonaws.com", 9000); // CRA Dev RA
  // static final LevelParameters params = new LevelParameters(1, "config/.level_params_ratest");

  // RA Gameserver test
  // static CsfvRaRest ra = new CsfvRaRest("ec2-54-242-99-205.compute-1.amazonaws.com", 80); // TC Dev GameServer
  // static LevelParameters params = new LevelParameters(1, "config/.level_params_ratest");

  // GhostMap RA test
  // static CsfvRaRest ra = new CsfvRaRest("ec2-54-234-130-245.compute-1.amazonaws.com", 80); // GhostMap
  // static LevelParameters params = new LevelParameters(1, "config/.level_params_ghostmap");

  // RA Xylem test
  // static CsfvRaRest ra = new CsfvRaRest("ec2-54-234-13-157.compute-1.amazonaws.com", 80); // Xylem
  // static LevelParameters params = new LevelParameters(1, "config/.level_params_xylem");

  // RA Circuitbot test
  // static CsfvRaRest ra = new CsfvRaRest("ec2-23-20-198-82.compute-1.amazonaws.com", 80); // Circuitbot
  // static LevelParameters params = new LevelParameters(1, "config/.level_params_circuitbot");

  // RA StarJam test
   static CsfvRaRest ra = new CsfvRaRest("ec2-184-72-152-11.compute-1.amazonaws.com", 80); // StarJam
   static LevelParameters params = new LevelParameters(1, "config/.level_params_starjam");

  // RA StarJam test
  // static CsfvRaRest ra = new CsfvRaRest("ec2-23-23-40-30.compute-1.amazonaws.com", 80); // Storm
  // static LevelParameters params = new LevelParameters(1, "'.level_params_storm");

  static final Gson gson = getGson();

  private static Logger log = LoggerFactory.getLogger(CsfvRaRestTest.class);

  static String levelID;
  
	public static void main(String[] args)
	{
//		OneTimeSetUp();
//	      CreatePrincipalResponse response = ra.createPrincipal(LEVEL);
//	      if (response.success) {
//	        levelIds.add(response.id);
//	        levelID = response.id;
//	      }
//	      // and set their priority
//	      Integer priority = (int) Math.round(Math.random() * 100.0);
//	      ra.setPriority(response.id, priority);

		testLevelCreationWithMetadata("5182d053e4b0615b7829e44b");
	//	testModifyParameter();
//		testLevelSearch();
		
//		OneTimeTearDown();
	}
  /**
   * Creates 2 random players and 5 random levels for testing, sets priority for the levels, and activates them.
   */
  @BeforeClass
  public static void OneTimeSetUp() {

    log.info("Setting up");
    // Create 2 random players
    Boolean setupAgents = true;
    for (int n = 0; n < 1; n++) {
      CreatePrincipalResponse response = ra.createPrincipal(RANDOMPLAYER);
      if (response.success) {
        setupAgents &= true;
        playerIds.add(response.id);
      }
    }
    log.info((setupAgents ? "Created" : "Did not create") + " all test players");

    setupAgents = true;
    // Create 5 random levels
    for (int n = 0; n < 6; n++) {
      CreatePrincipalResponse response = ra.createPrincipal(RANDOMLEVEL);
      if (response.success) {
        setupAgents &= true;
        levelIds.add(response.id);
        levelID = response.id;
      }
      // and set their priority
      Integer priority = (int) Math.round(Math.random() * 100.0);
      setupAgents &= ra.setPriority(response.id, priority).success;
    }

    log.info((setupAgents ? "Created and established" : "Did not create or establish") + " priority for all test levels");

    // activate all these players
    setupAgents = true;
    for (String playerId : playerIds) {
      setupAgents &= ra.activateAgent(playerId, PLAYER).success;
    }
    log.info((setupAgents ? "Activated" : "Did not activate") + " all test players");

    // activate all levels
    setupAgents = true;
    for (String levelId : levelIds) {
      setupAgents &= ra.activateAgent(levelId, LEVEL).success;
    }
    log.info((setupAgents ? "Activated" : "Did not activate") + " all test levels");

    log.info("Setup complete\n");
  }

  @AfterClass
  public static void OneTimeTearDown() {
    log.info("Cleaning up test levels & players");

    // // Deactivate test players:
    Boolean deactivatedAllAgents = true;
    for (String playerId : playerIds) {
 //     deactivatedAllAgents &= ra.deactivateAgent(playerId, PLAYER).success;
    }
 //   log.info((deactivatedAllAgents ? "Deactivated" : "Did not deactivate") + " all test players");

    // deactivate all test levels
    deactivatedAllAgents = true;
//    for (String levelId : levelIds) {
//      deactivatedAllAgents &= ra.deactivateAgent(levelId, LEVEL).success;
//    }
//    log.info((deactivatedAllAgents ? "Deactivated" : "Did not deactivate") + " all test levels");

    // Clean up test players

    Boolean removedAgents = true;
    for (String idr : playerIds) {
      removedAgents &= ra.deletePrincipal(idr, PrincipalType.PLAYER).success;
    }
    log.info((removedAgents ? "Removed" : "Did not remove") + " all test players");
    // Clean up test levels
    removedAgents = true;
    for (String idr : levelIds) {
      removedAgents &= ra.deletePrincipal(idr, PrincipalType.LEVEL).success;
    }
    log.info((removedAgents ? "Removed" : "Did not remove") + " all test levels");
    log.info("Teardown completed");
  }

  public static Gson getGson() {
    GsonBuilder gson = new GsonBuilder();
    return gson.excludeFieldsWithoutExposeAnnotation().create();
  }

  // ============================START OF TESTS==================================
  @Test
  public void testReport() {
    log.info("Test Report:");
    RaStatusReportResponse report = ra.getReport();
    Assert.assertTrue(report.playersInCache.containsAll(playerIds));
    Assert.assertTrue(report.levelsInCache.containsAll(levelIds));
    Assert.assertTrue(report.activePlayerAgents.containsAll(playerIds));
    Assert.assertTrue(report.activeLevelAgents.containsAll(levelIds));
    log.info("   passed");
  }

  @Test
  public static void testLevelSearch() {
    log.info("Test Level Search");
    // Find out some detailed things about a level
    String levelId = levelIds.iterator().next();

    SearchLevelsResponse slResponse1 = ra.searchLevels(new Constraint(), 10);
    
    RequestMetadataResponse rmResponse = ra.getLevelMetadata(levelId);
    Assert.assertTrue(rmResponse.success);
    Metadata lm = rmResponse.metadata;

    // Construct a set of narrow search criteria around this level's parameters
    Constraint c1 = new Constraint();

    for (Trait trait : lm.parameters) {
      c1.parameter.add(new RangeConstraint(trait.name, true, trait.value - (1e-6 * Math.abs(trait.value)), trait.value
          + (1e-6 * Math.abs(trait.value))));
    }
    SearchLevelsResponse slResponse;
    for(int i = 1; i < 2; i++)
    {
    // perform the search on this constraint
    	System.out.println(i);
	    slResponse = ra.searchLevels(c1, 10);
	    // We expect one and only one response.
	    Assert.assertTrue(slResponse.success);
	    Assert.assertFalse(slResponse.timeout);
	    Assert.assertEquals(slResponse.ids.size(), 1);
	    Assert.assertEquals(slResponse.ids.iterator().next(), levelId);
    }
    
    //do it again just for fun
 //   slResponse = ra.searchLevels(c1, 10);
 //   Assert.assertTrue(slResponse.success);
    
    // Deactivate the level and try the search again
//   Assert.assertTrue(ra.deactivateAgent(levelId, LEVEL).success);

    AgentStatusResponse agentStatus = ra.getAgentStatus(levelId, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // perform the search on this constraint
    slResponse = ra.searchLevels(c1, 10);

    // We expect the same response.
    Assert.assertTrue(slResponse.success);
    Assert.assertFalse(slResponse.timeout);
    Assert.assertEquals(slResponse.ids.size(), 1);
    Assert.assertEquals(slResponse.ids.iterator().next(), levelId);

    // Now invert the constraint
    for (RangeConstraint rc : c1.parameter) {
      rc.isRequired = false;
    }

    // We should expect at least the four responses from the levels we created, probably more.
    // The only level that should not be in the collection is the level we used as a basis for the conditional
    slResponse = ra.searchLevels(c1, 10);

    Assert.assertTrue(slResponse.success);
    Assert.assertFalse(slResponse.timeout);
    Assert.assertTrue(slResponse.ids.size() >= 4);
    Assert.assertFalse(slResponse.ids.contains(levelId));

    // Reactivate the level
    Assert.assertTrue(ra.activateAgent(levelId, LEVEL).success);

    agentStatus = ra.getAgentStatus(levelId, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);
  }

  @Test
  public static void testLevelCreationWithMetadata(String id) {
    log.info("Test Create Level From Metadata:");

    SetLevelMetadataRequest setMetadataRequest = new SetLevelMetadataRequest();
  //  String id = "012345678910111213141516";

    setMetadataRequest.ids.add(id);
    Metadata lm = new Metadata();
    lm.priority = 10.0;
    lm.comment = "a comment";
//    lm.putTag("tag_1");
//    lm.putTag("tag_2");
//    lm.putLabel("label_1");
    lm.putParameter("difficulty", 10.0);
    lm.putParameter("type", 1.0);
    lm.putProperty("boxes", 10.0);
    lm.putProperty("lines", 10.0);
    lm.parentId = "510b270f6c4a3dc00c00008f";
    lm.predecessorId = "000000000000000000000000";
    setMetadataRequest.metadata = lm;
System.out.println("Metadata request " + setMetadataRequest);
    // Create player from metadata & verify
    Assert.assertTrue(ra.updateLevelMetadata(setMetadataRequest).success);

//    // Retrieve player metadata
//    RequestMetadataResponse request = ra.getLevelMetadata(id);
//    Assert.assertTrue(request.success);
//    // retrieved metadata matches deposited metadata
//    Assert.assertEquals(lm, request.metadata);
//
//    // Clean up level from database
//    Assert.assertTrue(ra.deletePrincipal(id, PrincipalType.LEVEL).success);
//    log.info("   passed");
  }

  @Test
  public static void testModifyParameter() {
    log.info("Test Modify Parameter:");

    String id = levelIds.iterator().next();

    // Make sure agent is active
    AgentStatusResponse agentStatus = ra.getAgentStatus(id, LEVEL);
 //   Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    RequestMetadataResponse response = ra.getLevelMetadata(id);
    Assert.assertTrue(response.success);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // Retrieving metadata and extracting a parameter trait
    Metadata lm = response.metadata;
    Metadata.Trait t1 = new Metadata.Trait(lm.parameters.iterator().next());
    t1.value *= 2;

    // Creating an update metadata function
    SetLevelMetadataRequest update = new SetLevelMetadataRequest();
    update.ids.add(id);
    update.metadata.putParameter(t1);

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update).success);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response2 = ra.getLevelMetadata(id);
    Assert.assertTrue(response2.success);
    Assert.assertNotEquals(response.metadata, response2.metadata);
    Assert.assertNotEquals(response.metadata.getParameter(t1.name), response2.metadata.getParameter(t1.name));
    response.metadata.putParameter(t1);
    Assert.assertEquals(response.metadata, response2.metadata);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    log.info("   passed");
  }

  @Test
  public void testModifyParameterOnInactive() {
    log.info("Test Modify Parameter On Inactive:");

    String id = levelIds.iterator().next();

    // Deactivate level
    Assert.assertTrue(ra.deactivateAgent(id, LEVEL).success);

    // Make sure agent is inactive
    AgentStatusResponse agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    RequestMetadataResponse response = ra.getLevelMetadata(id);
    Assert.assertTrue(response.success);

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // Retrieving metadata and extracting a parameter trait
    Metadata lm = response.metadata;
    Metadata.Trait t1 = new Metadata.Trait(lm.parameters.iterator().next());
    t1.value *= 2;

    // Creating an update metadata function
    SetLevelMetadataRequest update = new SetLevelMetadataRequest();
    update.ids.add(id);
    update.metadata.putParameter(t1);

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update).success);

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response2 = ra.getLevelMetadata(id);
    Assert.assertTrue(response2.success);
    Assert.assertNotEquals(response.metadata, response2.metadata);
    Assert.assertNotEquals(response.metadata.getParameter(t1.name), response2.metadata.getParameter(t1.name));
    response.metadata.putParameter(t1);
    Assert.assertEquals(response.metadata, response2.metadata);

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // reactivate level

    Assert.assertTrue(ra.activateAgent(id, LEVEL).success);

    // Make sure agent is now active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    log.info("   passed");
  }

  @Test
  public void testModifyProperty() {
    log.info("Test Modify Property:");

    String id = levelIds.iterator().next();

    // Make sure agent is active
    AgentStatusResponse agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    RequestMetadataResponse response = ra.getLevelMetadata(id);
    Assert.assertTrue(response.success);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // Creating an update metadata function
    SetLevelMetadataRequest update = new SetLevelMetadataRequest();
    update.ids.add(id);
    Metadata.Trait t1 = new Metadata.Trait("property_testOne", 11.11111);
    update.metadata.putProperty(t1);

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update).success);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response2 = ra.getLevelMetadata(id);
    Assert.assertTrue(response2.success);
    Assert.assertNotEquals(response.metadata, response2.metadata);
    Assert.assertNotEquals(response.metadata.getProperty(t1.name), response2.metadata.getProperty(t1.name));
    response.metadata.putProperty(t1);
    Assert.assertEquals(response.metadata, response2.metadata);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    log.info("   passed");
  }

  @Test
  public void testModifyTag() {
    log.info("Test Modify Tag:");
    String id = levelIds.iterator().next();
    // Make sure agent is active
    AgentStatusResponse agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    RequestMetadataResponse response = ra.getLevelMetadata(id);
    Assert.assertTrue(response.success);

    // Creating an update metadata function
    SetLevelMetadataRequest update = new SetLevelMetadataRequest();
    update.ids.add(id);
    update.metadata.putTag("tag_2");
    update.metadata.putTag("tag_3", true);
    update.metadata.putTag(new Metadata.Descriptor("tag_4", true));

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update).success);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response2 = ra.getLevelMetadata(id);
    Assert.assertTrue(response2.success);
    Assert.assertNotEquals(response.metadata, response2.metadata);
    Assert.assertNotEquals(response.metadata.getTagSet(), response2.metadata.getTagSet());

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // Creating an update metadata function
    SetLevelMetadataRequest update2 = new SetLevelMetadataRequest();
    update2.ids.add(id);
    update2.metadata.tags.add(new Metadata.Descriptor("tag_2", false));
    update2.metadata.tags.add(new Metadata.Descriptor("tag_3", false));
    update2.metadata.tags.add(new Metadata.Descriptor("tag_4", false));

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update2).success);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response3 = ra.getLevelMetadata(id);
    Assert.assertTrue(response3.success);
    Assert.assertNotEquals(response2.metadata, response3.metadata);
    Assert.assertNotEquals(response2.metadata.getTagSet(), response3.metadata.getTagSet());

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    Assert.assertEquals(response.metadata, response3.metadata);
    log.info("   passed");
  }

  @Test
  public void testVersion() {
    log.info("Test Version");
    VersionResponse response = ra.getVersion();
    Assert.assertTrue(response.success);
    Assert.assertFalse(response.version.isEmpty());
    log.info("   passed");
  }

  @Test
  public void testModifyTagOnInactiveLevel() {
    log.info("Test Modify Tag:");
    String id = levelIds.iterator().next();
    // Deactivate agent
    Assert.assertTrue(ra.deactivateAgent(id, LEVEL).success);
    // Make sure agent is inactive
    AgentStatusResponse agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    RequestMetadataResponse response = ra.getLevelMetadata(id);
    Assert.assertTrue(response.success);

    // Creating an update metadata function
    SetLevelMetadataRequest update = new SetLevelMetadataRequest();
    update.ids.add(id);
    update.metadata.putTag("tag_2");
    update.metadata.putTag("tag_3", true);
    update.metadata.putTag(new Metadata.Descriptor("tag_4", true));

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update).success);

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response2 = ra.getLevelMetadata(id);
    Assert.assertTrue(response2.success);
    Assert.assertNotEquals(response.metadata, response2.metadata);
    Assert.assertNotEquals(response.metadata.getTagSet(), response2.metadata.getTagSet());

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // Creating an update metadata function
    SetLevelMetadataRequest update2 = new SetLevelMetadataRequest();
    update2.ids.add(id);
    update2.metadata.tags.add(new Metadata.Descriptor("tag_2", false));
    update2.metadata.tags.add(new Metadata.Descriptor("tag_3", false));
    update2.metadata.tags.add(new Metadata.Descriptor("tag_4", false));

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update2).success);

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response3 = ra.getLevelMetadata(id);

    // Make sure tags have been added back correctly
    Assert.assertTrue(response3.success);
    Assert.assertNotEquals(response2.metadata, response3.metadata);
    Assert.assertNotEquals(response2.metadata.getTagSet(), response3.metadata.getTagSet());
    Assert.assertEquals(response.metadata, response3.metadata);

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // Reactivate level
    Assert.assertTrue(ra.activateAgent(id, LEVEL).success);

    // Make sure agent is now active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    log.info("   passed");
  }

  @Test
  public void testModifyLabel() {
    log.info("Test Modify Label:");
    String id = levelIds.iterator().next();
    // Make sure agent is active
    AgentStatusResponse agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    RequestMetadataResponse response = ra.getLevelMetadata(id);
    Assert.assertTrue(response.success);

    // Creating an update metadata function
    SetLevelMetadataRequest update = new SetLevelMetadataRequest();
    update.ids.add(id);
    update.metadata.putLabel("label_2");
    update.metadata.putLabel("label_3", true);
    update.metadata.putLabel(new Metadata.Descriptor("label_4", true));

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update).success);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response2 = ra.getLevelMetadata(id);
    Assert.assertTrue(response2.success);
    Assert.assertNotEquals(response.metadata, response2.metadata);
    Assert.assertNotEquals(response.metadata.getLabelSet(), response2.metadata.getLabelSet());

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // Creating an update metadata function
    SetLevelMetadataRequest update2 = new SetLevelMetadataRequest();
    update2.ids.add(id);
    update2.metadata.labels.add(new Metadata.Descriptor("label_2", false));
    update2.metadata.labels.add(new Metadata.Descriptor("label_3", false));
    update2.metadata.labels.add(new Metadata.Descriptor("label_4", false));

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update2).success);

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response3 = ra.getLevelMetadata(id);
    Assert.assertTrue(response3.success);
    Assert.assertNotEquals(response2.metadata, response3.metadata);
    Assert.assertNotEquals(response2.metadata.getLabelSet(), response3.metadata.getLabelSet());

    // Make sure agent is still active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    Assert.assertEquals(response.metadata, response3.metadata);
    log.info("   passed");
  }

  @Test
  public void testModifyLabelOnInactiveLevel() {
    log.info("Test Modify Label:");
    String id = levelIds.iterator().next();
    // Deactivate agent
    Assert.assertTrue(ra.deactivateAgent(id, LEVEL).success);
    // Make sure agent is inactive
    AgentStatusResponse agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    RequestMetadataResponse response = ra.getLevelMetadata(id);
    Assert.assertTrue(response.success);

    // Creating an update metadata function
    SetLevelMetadataRequest update = new SetLevelMetadataRequest();
    update.ids.add(id);
    update.metadata.putLabel("label_2");
    update.metadata.putLabel("label_3", true);
    update.metadata.putLabel(new Metadata.Descriptor("label_4", true));

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update).success);

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response2 = ra.getLevelMetadata(id);
    Assert.assertTrue(response2.success);
    Assert.assertNotEquals(response.metadata, response2.metadata);
    Assert.assertNotEquals(response.metadata.getLabelSet(), response2.metadata.getLabelSet());

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // Creating an update metadata function
    SetLevelMetadataRequest update2 = new SetLevelMetadataRequest();
    update2.ids.add(id);
    update2.metadata.labels.add(new Metadata.Descriptor("label_2", false));
    update2.metadata.labels.add(new Metadata.Descriptor("label_3", false));
    update2.metadata.labels.add(new Metadata.Descriptor("label_4", false));

    // Updating level
    Assert.assertTrue(ra.declareLevelMetadata(update2).success);

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // retrieving modified level
    RequestMetadataResponse response3 = ra.getLevelMetadata(id);

    // Make sure labels have been added back correctly
    Assert.assertTrue(response3.success);
    Assert.assertNotEquals(response2.metadata, response3.metadata);
    Assert.assertNotEquals(response2.metadata.getLabelSet(), response3.metadata.getLabelSet());
    Assert.assertEquals(response.metadata, response3.metadata);

    // Make sure agent is still inactive
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && !agentStatus.inCache && !agentStatus.active);

    // Reactivate level
    Assert.assertTrue(ra.activateAgent(id, LEVEL).success);

    // Make sure agent is now active
    agentStatus = ra.getAgentStatus(id, LEVEL);
    Assert.assertTrue(agentStatus.success && agentStatus.inCache && agentStatus.active);

    log.info("   passed");
  }

  @Test
  public void testAgentActive() {
    log.info("Test Agent Active");
    String levelId = levelIds.iterator().next();
    String playerId = playerIds.iterator().next();
    // Get activity response
    AgentStatusResponse levelStatus = ra.getAgentStatus(levelId, LEVEL);
    Assert.assertTrue(levelStatus.success && levelStatus.inCache && levelStatus.active);
    AgentStatusResponse playerStatus = ra.getAgentStatus(playerId, PLAYER);
    Assert.assertTrue(playerStatus.success && playerStatus.inCache && playerStatus.active);

    // Both level and player should be active
    Assert.assertTrue(levelStatus.success && !levelStatus.timeout);
    Assert.assertTrue(levelStatus.inCache);
    Assert.assertTrue(levelStatus.active);
    Assert.assertTrue(playerStatus.success && !playerStatus.timeout);
    Assert.assertTrue(playerStatus.inCache);
    Assert.assertTrue(playerStatus.active);
    // deactivate player and level
    Assert.assertTrue(ra.deactivateAgent(levelId, LEVEL).success);
    Assert.assertTrue(ra.deactivateAgent(playerId, PLAYER).success);
    // Refresh report
    levelStatus = ra.getAgentStatus(levelId, LEVEL);
    playerStatus = ra.getAgentStatus(playerId, PLAYER);
    // Both level and player should be inactive
    Assert.assertTrue(levelStatus.success && !levelStatus.timeout);
    Assert.assertFalse(levelStatus.inCache);
    Assert.assertFalse(levelStatus.active);
    Assert.assertTrue(playerStatus.success && !playerStatus.timeout);
    Assert.assertFalse(playerStatus.inCache);
    Assert.assertFalse(playerStatus.active);
    // reactivate player and level
    Assert.assertTrue(ra.activateAgent(levelId, LEVEL).success);
    Assert.assertTrue(ra.activateAgent(playerId, PLAYER).success);
    // Refresh report
    levelStatus = ra.getAgentStatus(levelId, LEVEL);
    playerStatus = ra.getAgentStatus(playerId, PLAYER);
    // Both level and player should be active again
    Assert.assertTrue(levelStatus.success && !levelStatus.timeout);
    Assert.assertTrue(levelStatus.inCache);
    Assert.assertTrue(levelStatus.active);
    Assert.assertTrue(playerStatus.success && !playerStatus.timeout);
    Assert.assertTrue(playerStatus.inCache);
    Assert.assertTrue(playerStatus.active);
    log.info("   passed");
  }

  @Test
  public void testConstrainedMatch() {
    log.info("Test Constrained Match");
    // Choose a player
    String playerId = playerIds.iterator().next();

    // Find the number of active levels:
    RaStatusReportResponse report = ra.getReport();
    Assert.assertTrue(report.success);
    Assert.assertFalse(report.timeout);
    Integer levelCount = report.activeLevelAgents.size();

    // get an unconstrained match
    MatchResponse matchResponse = ra.requestMatch(playerId, levelCount);

    // Verify that match was successful and that all levels bid
    Assert.assertTrue(matchResponse.success);
    Assert.assertFalse(matchResponse.timeout);
    Assert.assertTrue(matchResponse.matches.size() == levelCount);

    // get the Id of the leading level and the bid amount
    String levelId = matchResponse.matches.get(0).levelId;
    Double bid = matchResponse.matches.get(0).bid;

    // refuse match
    PlayerStoppedLevelResponse refuseResponse = ra.playerRefusedMatch(playerId);

    // verify response
    Assert.assertTrue(refuseResponse.success);
    Assert.assertFalse(refuseResponse.timeout);

    // // Wait for resources to be reallocated to the level
    // try {
    // TimeUnit.MILLISECONDS.sleep(100);
    // } catch (InterruptedException e) {
    // // TODO Auto-generated catch block
    // e.printStackTrace();
    // }

    // Get a system report to verify that the level & player are still active and that the escrow is closed:
    report = ra.getReport();
    Assert.assertTrue(report.success);
    Assert.assertFalse(report.timeout);
    Assert.assertTrue(report.levelsInCache.contains(levelId));
    Assert.assertTrue(report.playersInCache.contains(playerId));
    Assert.assertTrue(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(report.activePlayerAgents.contains(playerId));
    Assert.assertFalse(report.activeAuctions.contains(playerId));
    Assert.assertFalse(report.activeEscrows.contains(playerId));

    // do it again - the result should be identical

    matchResponse = ra.requestMatch(playerId, levelCount);

    // Verify that match was successful and the winning level and bid were the same
    Assert.assertTrue(matchResponse.success);
    Assert.assertFalse(matchResponse.timeout);
    Assert.assertTrue(matchResponse.matches.size() == levelCount);
    Assert.assertEquals(matchResponse.matches.get(0).levelId, levelId);
    Assert.assertEquals(matchResponse.matches.get(0).bid, bid);

    // refuse match again
    refuseResponse = ra.playerRefusedMatch(playerId);
    // verify response
    Assert.assertTrue(refuseResponse.success);
    Assert.assertFalse(refuseResponse.timeout);

    // Get another system report to verify that the level & player are still active and that the escrow is closed:
    report = ra.getReport();
    Assert.assertTrue(report.success);
    Assert.assertFalse(report.timeout);
    Assert.assertTrue(report.levelsInCache.contains(levelId));
    Assert.assertTrue(report.playersInCache.contains(playerId));
    Assert.assertTrue(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(report.activePlayerAgents.contains(playerId));
    Assert.assertFalse(report.activeAuctions.contains(playerId));
    Assert.assertFalse(report.activeEscrows.contains(playerId));

    // get the metadata associated with the "winning" level
    RequestMetadataResponse lmResponse = ra.getLevelMetadata(levelId);
    // verify that it worked okay
    Assert.assertTrue(lmResponse.success);
    Assert.assertFalse(lmResponse.timeout);
    Metadata lm = lmResponse.metadata;

    // add a random property, tag and label to the level
    SetLevelMetadataRequest update = new SetLevelMetadataRequest();
    update.ids.add(levelId);
    update.metadata.putLabel("label_1");
    update.metadata.putTag("tag_1");
    update.metadata.putProperty("property_1", 10.0);

    SetLevelMetadataResponse updateResponse = ra.updateLevelMetadata(update);
    // verify that it took
    Assert.assertTrue(updateResponse.success);
    Assert.assertFalse(updateResponse.timeout);

    // check the level's metadata again
    lmResponse = ra.getLevelMetadata(levelId);

    Assert.assertTrue(lmResponse.success);
    Assert.assertFalse(lmResponse.timeout);
    lm = lmResponse.metadata;
    Assert.assertTrue(lm.hasProperty(update.metadata.properties.iterator().next().name));
    Assert.assertEquals(lm.getProperty(update.metadata.properties.iterator().next().name), update.metadata.properties.iterator()
        .next().value);
    Assert.assertTrue(lm.hasTag(update.metadata.tags.iterator().next().name));
    Assert.assertTrue(lm.hasLabel(update.metadata.labels.iterator().next().name));

    // Find the parameter value of the first parameter of the winning level
    Metadata.Trait param1 = lm.parameters.iterator().next();
    // Construct a conditional around this parameter, including it.
    Constraint constraint = new Constraint();
    Constraint.RangeConstraint paramCond = new Constraint.RangeConstraint(param1.name, true, param1.value
        - Math.abs(param1.value * 1e-6), param1.value + Math.abs(param1.value * 1e-6));
    constraint.parameter.add(paramCond);

    // create a match with the above conditional - the result should be identical as before
    matchResponse = ra.requestMatchWithConstraint(playerId, levelCount, constraint);

    // Verify that match was still successful and the winning level and bid were the same (it should just have 1 bid)
    Assert.assertTrue(matchResponse.success);
    Assert.assertFalse(matchResponse.timeout);
    Assert.assertEquals(matchResponse.matches.get(0).levelId, levelId);
    Assert.assertEquals(matchResponse.matches.get(0).bid, bid);
    Assert.assertEquals(matchResponse.matches.size(), 1);

    // refuse match again
    refuseResponse = ra.playerRefusedMatch(playerId);

    // verify response
    Assert.assertTrue(refuseResponse.success);
    Assert.assertFalse(refuseResponse.timeout);

    // Get another system report to verify that the level & player are still active and that the escrow is closed:
    report = ra.getReport();
    Assert.assertTrue(report.success);
    Assert.assertFalse(report.timeout);
    Assert.assertTrue(report.levelsInCache.contains(levelId));
    Assert.assertTrue(report.playersInCache.contains(playerId));
    Assert.assertTrue(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(report.activePlayerAgents.contains(playerId));
    Assert.assertFalse(report.activeAuctions.contains(playerId));
    Assert.assertFalse(report.activeEscrows.contains(playerId));

    // make the conditional now exclude the level
    constraint.parameter.iterator().next().isRequired = false;

    // create a match with the failing conditional - the result should be different this time
    matchResponse = ra.requestMatchWithConstraint(playerId, levelCount, constraint);

    // Verify that match was successful but that the winning level and bid were different
    Assert.assertTrue(matchResponse.success);
    Assert.assertFalse(matchResponse.timeout);
    Assert.assertNotEquals(matchResponse.matches.get(0).levelId, levelId);
    Assert.assertNotEquals(matchResponse.matches.get(0).bid, bid);

    // refuse match again
    refuseResponse = ra.playerRefusedMatch(playerId);

    // verify response
    Assert.assertTrue(refuseResponse.success);
    Assert.assertFalse(refuseResponse.timeout);

    // Get another system report to verify that the level & player are still active and that the escrow is closed:
    report = ra.getReport();
    Assert.assertTrue(report.success);
    Assert.assertFalse(report.timeout);
    Assert.assertTrue(report.levelsInCache.contains(levelId));
    Assert.assertTrue(report.playersInCache.contains(playerId));
    Assert.assertTrue(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(report.activePlayerAgents.contains(playerId));
    Assert.assertFalse(report.activeAuctions.contains(playerId));
    Assert.assertFalse(report.activeEscrows.contains(playerId));

    // Restore conditional and add tight property, tag and label conditions
    constraint.parameter.iterator().next().isRequired = true;

    Metadata.Trait prop1 = update.metadata.properties.iterator().next();
    Constraint.RangeConstraint propCond = new Constraint.RangeConstraint(prop1.name, true, param1.value
        - Math.abs(param1.value * 1e-6), param1.value + Math.abs(param1.value * 1e-6));
    propCond.name = prop1.name;
    propCond.isRequired = true;
    propCond.from = prop1.value - (prop1.value * 1e-6);
    propCond.to = prop1.value + (prop1.value * 1e-6);
    constraint.property.add(propCond);

    Metadata.Descriptor tagDesc = update.metadata.tags.iterator().next();
    Constraint.DescriptorConstraint tagCond = new Constraint.DescriptorConstraint(tagDesc.name, true);
    constraint.tag.add(tagCond);

    Metadata.Descriptor labelDesc = update.metadata.labels.iterator().next();
    Constraint.DescriptorConstraint labelCond = new Constraint.DescriptorConstraint(labelDesc.name, true);
    constraint.label.add(labelCond);

    // verify that the new conditional still matches only the targeted level in a match
    matchResponse = ra.requestMatchWithConstraint(playerId, levelCount, constraint);

    // Verify that match was still successful and the winning level and bid were the same (it should just have 1 bid)
    Assert.assertTrue(matchResponse.success);
    Assert.assertFalse(matchResponse.timeout);
    Assert.assertEquals(matchResponse.matches.get(0).levelId, levelId);
    Assert.assertEquals(matchResponse.matches.get(0).bid, bid);
    Assert.assertEquals(matchResponse.matches.size(), 1);

    // refuse match again
    refuseResponse = ra.playerRefusedMatch(playerId);

    // verify response
    Assert.assertTrue(refuseResponse.success);
    Assert.assertFalse(refuseResponse.timeout);

    // Get another system report to verify that the level & player are still active and that the escrow is closed:
    report = ra.getReport();
    Assert.assertTrue(report.success);
    Assert.assertFalse(report.timeout);
    Assert.assertTrue(report.levelsInCache.contains(levelId));
    Assert.assertTrue(report.playersInCache.contains(playerId));
    Assert.assertTrue(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(report.activePlayerAgents.contains(playerId));
    Assert.assertFalse(report.activeAuctions.contains(playerId));
    Assert.assertFalse(report.activeEscrows.contains(playerId));

    log.info("   passed");
  }

  @Test
  public void testBasicWorkflow() {
    log.info("Test Basic Workflow:");

    // Deactivate a player and a level
    String playerId = playerIds.iterator().next();
    String levelId = levelIds.iterator().next();
    Assert.assertTrue(ra.deactivateAgent(playerId, PLAYER).success);
    Assert.assertTrue(ra.deactivateAgent(levelId, LEVEL).success);

    // Test to see that the player and level are no longer active
    RaStatusReportResponse report = ra.getReport();
    Assert.assertFalse(report.playersInCache.contains(playerId));
    Assert.assertFalse(report.levelsInCache.contains(levelId));
    Assert.assertFalse(report.activePlayerAgents.contains(playerId));
    Assert.assertFalse(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(Collections.disjoint(report.activeAuctions, playerIds));
    Assert.assertTrue(Collections.disjoint(report.activeEscrows, playerIds));

    // Reactivate a player and a level
    Assert.assertTrue(ra.activateAgent(playerId, PLAYER).success);
    Assert.assertTrue(ra.activateAgent(levelId, LEVEL).success);

    // make sure player and level are reactivated
    report = ra.getReport();
    Assert.assertTrue(report.playersInCache.contains(playerId));
    Assert.assertTrue(report.levelsInCache.contains(levelId));
    Assert.assertTrue(report.activePlayerAgents.contains(playerId));
    Assert.assertTrue(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(Collections.disjoint(report.activeAuctions, playerIds));
    Assert.assertTrue(Collections.disjoint(report.activeEscrows, playerIds));

    // request a match for a player
    MatchResponse matchResponse = ra.requestMatch(playerId, 2);
    Assert.assertTrue(matchResponse.success);
    Assert.assertEquals(matchResponse.matches.size(), 2);

    // make sure the player has an escrow open for all bid levels
    // and no 1 else does
    Set<String> otherPlayers = new HashSet<String>(playerIds);
    otherPlayers.remove(playerId);

    report = ra.getReport();
    Assert.assertTrue(report.playersInCache.contains(playerId));
    Assert.assertTrue(report.levelsInCache.contains(levelId));
    Assert.assertTrue(report.activePlayerAgents.contains(playerId));
    Assert.assertTrue(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(Collections.disjoint(report.activeAuctions, playerIds));
    Assert.assertTrue(report.activeEscrows.contains(playerId));
    Assert.assertTrue(Collections.disjoint(report.activeAuctions, otherPlayers));

    // Start a level from a bid
    String startedLevelId = matchResponse.getBidders().iterator().next();
    Assert.assertTrue(ra.playerStartedLevel(playerId, startedLevelId).success);

    // make sure the player still has an escrow open for all bid levels
    report = ra.getReport();
    Assert.assertTrue(report.playersInCache.contains(playerId));
    Assert.assertTrue(report.levelsInCache.contains(levelId));
    Assert.assertTrue(report.activePlayerAgents.contains(playerId));
    Assert.assertTrue(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(Collections.disjoint(report.activeAuctions, playerIds));
    Assert.assertTrue(report.activeEscrows.contains(playerId));
    Assert.assertTrue(Collections.disjoint(report.activeAuctions, otherPlayers));

    // Stop the level
    PlayerStoppedLevelResponse stopResponse = ra.playerStoppedLevel(playerId);
    Assert.assertTrue(stopResponse.success);
    Assert.assertFalse(stopResponse.timeout);

    // make sure all escrows are closed
    report = ra.getReport();
    Assert.assertTrue(report.playersInCache.contains(playerId));
    Assert.assertTrue(report.levelsInCache.contains(levelId));
    Assert.assertTrue(report.activePlayerAgents.contains(playerId));
    Assert.assertTrue(report.activeLevelAgents.contains(levelId));
    Assert.assertTrue(Collections.disjoint(report.activeAuctions, playerIds));
    Assert.assertTrue(Collections.disjoint(report.activeAuctions, playerIds));

    // make a performance report
    Assert.assertTrue(ra.reportPlayerMetric(playerId, startedLevelId, ReportType.PERFORMANCE, 50).success);

    // make a preference report
    Assert.assertTrue(ra.reportPlayerMetric(playerId, startedLevelId, ReportType.PREFERENCE, -50).success);

    log.info("   passed");
  }
}