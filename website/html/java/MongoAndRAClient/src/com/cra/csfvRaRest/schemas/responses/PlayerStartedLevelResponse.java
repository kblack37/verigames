/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.responses;

import com.google.gson.annotations.Expose;

public class PlayerStartedLevelResponse {
  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String playerId;
  @Expose
  public String levelId;

  public PlayerStartedLevelResponse(Boolean success, Boolean timeout, String playerId, String levelId) {
    this.success = success;
    this.timeout = timeout;
    this.playerId = playerId;
    this.levelId = levelId;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    sb.append("\"playerId\" : \"" + playerId + "\", ");
    sb.append("\"levelId\" : " + levelId + " }");
    return sb.toString();
  }
}
