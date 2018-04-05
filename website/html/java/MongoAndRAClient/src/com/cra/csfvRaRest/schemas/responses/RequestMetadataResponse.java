/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.responses;

import com.cra.csfvRaRest.schemas.Metadata;
import com.google.gson.annotations.Expose;

public class RequestMetadataResponse {

  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String id;
  @Expose
  public Metadata metadata;

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    sb.append("\"id\" : \"" + id + "\", ");
    if(metadata != null)
    	sb.append("\"metadata\" : \"" + metadata.toString() + " }");
    return sb.toString();
  }

}
