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

public class DeactivateManyAgentsResponse {
  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String typeOfAgent;
  @Expose
  public Collection<String> ids;

  public DeactivateManyAgentsResponse(Boolean success, Boolean timeout, String typeOfAgent, Collection<String> ids) {
    this.success = success;
    this.timeout = timeout;
    this.typeOfAgent = typeOfAgent;
    this.ids = ids;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    sb.append("\"typeOfAgent\" : " + typeOfAgent + ", ");
    sb.append("\"ids\" : [ ");
    Boolean needComma = false;
    for (String id : ids) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append("\"" + id.toString() + "\"");
    }
    sb.append("] }");
    return sb.toString();
  }
}
