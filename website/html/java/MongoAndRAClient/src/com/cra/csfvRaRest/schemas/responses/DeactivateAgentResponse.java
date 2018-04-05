/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.responses;

import java.util.Collection;

import com.google.gson.annotations.Expose;

public class DeactivateAgentResponse  extends AgentResponse{

  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String id;
  @Expose
  public Collection<String> alreadyInactive;

  public DeactivateAgentResponse(Boolean success, Boolean timeout, String id, Collection<String> alreadyInactive) {
    this.success = success;
    this.timeout = timeout;
    this.id = id;
    this.alreadyInactive = alreadyInactive;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    if(id != null)
    	sb.append("\"playerId\" : \"" + id.toString() + "\", ");
    if(alreadyInactive != null)
    	sb.append("\"alreadyInactive\" : " + alreadyInactive.toString() + " } ");
    return sb.toString();
  }

}
