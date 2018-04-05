/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.responses;

import com.google.gson.annotations.Expose;

public class DeletePrincipalResponse {
  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String principalType;
  @Expose
  public String id;

  public DeletePrincipalResponse(Boolean success, Boolean timeout, String principalType, String id) {
    this.success = success;
    this.timeout = timeout;
    this.principalType = principalType;
    this.id = id;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    sb.append("\"principalType\" : " + principalType + "\" } ");
    sb.append("\"playerId\" : \"" + id.toString() + "\" }");
    return sb.toString();
  }
}
