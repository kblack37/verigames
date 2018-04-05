/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.responses;

import com.google.gson.annotations.Expose;

public class CreatePrincipalResponse {

  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String principalType;
  @Expose
  public String id;

  public CreatePrincipalResponse(Boolean success, Boolean timeout, String typeCreated, String id) {
    this.success = success;
    this.timeout = timeout;
    principalType = typeCreated;
    this.id = id;

  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    if(principalType != null)
    	sb.append("\"principalType\" : \"" + principalType.toString() + "\", ");
    sb.append("\"playerId\" : " + id + " } ");
    return sb.toString();
  }
}
