/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.responses;

import com.google.gson.annotations.Expose;

public class AgentStatusResponse {
  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String id;
  @Expose
  public String principalType;
  @Expose
  public Boolean inCache;
  @Expose
  public Boolean active;

  public AgentStatusResponse(Boolean success, Boolean timeout, String id, String principalType, Boolean inCache, Boolean active) {
    this.success = success;
    this.timeout = timeout;
    this.id = id;
    this.principalType = principalType;
    this.inCache = inCache;
    this.active = active;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    sb.append("\"id\" : \"" + id + "\", ");
    sb.append("\"principalType\" : " + principalType + ", ");
    sb.append("\"inCache\" : " + inCache + ", ");
    sb.append("\"active\" : " + active.toString() + " }");
    return sb.toString();
  }

}
