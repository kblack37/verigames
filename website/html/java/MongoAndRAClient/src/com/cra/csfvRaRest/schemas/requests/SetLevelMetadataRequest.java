/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.requests;

import java.util.Collection;
import java.util.HashSet;
import com.cra.csfvRaRest.schemas.Metadata;
import com.google.gson.annotations.Expose;

public class SetLevelMetadataRequest {

  @Expose
  public Collection<String> ids = new HashSet<String>();
  @Expose
  public Metadata metadata = new Metadata();

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"ids\" : [ ");
    Boolean needComma = false;
    for (String id : ids) {
    	if(id!=null)
    	{
	      needComma = (needComma) ? null != sb.append(", ") : true;
	      sb.append("\"" + id.toString() + "\"");
    	}
    }
    sb.append("], ");
    sb.append("\"metadata\" : " + metadata.toString() + " }");
    return sb.toString();
  }
}
