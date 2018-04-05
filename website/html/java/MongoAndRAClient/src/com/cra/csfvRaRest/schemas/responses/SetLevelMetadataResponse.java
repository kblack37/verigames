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

public class SetLevelMetadataResponse {
  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String principalType;
  @Expose
  public Collection<String> ids;

  public SetLevelMetadataResponse(Boolean success, Boolean timeout, String principalType, Collection<String> ids) {
    this.success = success;
    this.timeout = timeout;
    this.principalType = principalType;
    this.ids = ids;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    sb.append("\"principalType\" : " + principalType + ", ");
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
