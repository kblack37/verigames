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

public class RaStatusReportResponse {
  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public Collection<String> playersInCache;
  @Expose
  public Collection<String> levelsInCache;
  @Expose
  public Collection<String> activePlayerAgents;
  @Expose
  public Collection<String> activeLevelAgents;
  @Expose
  public Collection<String> activeAuctions;
  @Expose
  public Collection<String> activeEscrows;

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ \"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    sb.append("\"playersInCache\" : " + listToString(playersInCache) + ", ");
    sb.append("\"levelsInCache\" : " + listToString(levelsInCache) + ", ");
    sb.append("\"activePlayerAgents\" : " + listToString(activePlayerAgents) + ", ");
    sb.append("\"activeLevelAgents\" : " + listToString(activeLevelAgents) + ", ");
    sb.append("\"activeAuctions\" : " + listToString(activeAuctions) + ", ");
    sb.append("\"activeEscrows\" : " + listToString(activeEscrows) + ", ");
    sb.append("}");
    return sb.toString();
  }

  private String listToString(Collection<? extends Object> coll) {
    StringBuilder sb = new StringBuilder();
    Boolean needComma = false;
    sb.append("[ ");
    for (Object obj : coll) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append(obj.toString());
    }
    sb.append("]");
    return sb.toString();
  }
}
