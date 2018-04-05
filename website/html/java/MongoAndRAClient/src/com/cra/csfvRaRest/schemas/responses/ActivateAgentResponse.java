/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.responses;

import com.google.gson.annotations.Expose;

public class ActivateAgentResponse extends AgentResponse{
  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String id;
  @Expose
  public Boolean alreadyActive;

  public ActivateAgentResponse(Boolean success, Boolean timeout, String id, Boolean alreadyActive) {
    this.success = success;
    this.timeout = timeout;
    this.id = id;
    this.alreadyActive = alreadyActive;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    if(id != null)
    	sb.append("\"playerId\" : \"" + id + "\", ");
    if(alreadyActive != null)
    	sb.append("\"alreadyActive\" : " + alreadyActive.toString() + " }");
    return sb.toString();
  }
}
