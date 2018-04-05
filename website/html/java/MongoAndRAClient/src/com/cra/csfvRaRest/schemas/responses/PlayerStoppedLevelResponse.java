/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.responses;

import com.google.gson.annotations.Expose;

public class PlayerStoppedLevelResponse {
  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String playerId;

  public PlayerStoppedLevelResponse(Boolean success, Boolean timeout, String playerId) {
    this.success = success;
    this.timeout = timeout;
    this.playerId = playerId;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    sb.append("\"playerId\" : \"" + playerId + "\" }");
    return sb.toString();
  }
}
