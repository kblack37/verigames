/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas.responses;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import com.google.gson.annotations.Expose;

public class MatchResponse {

  @Expose
  public Boolean success;
  @Expose
  public Boolean timeout;
  @Expose
  public String id; // will be null if !success
  @Expose
  public Boolean constrained;
  @Expose
  public List<Match> matches = new ArrayList<Match>(); // will be null if !success

  public Set<String> getBidders() {
    Set<String> bidders = new HashSet<String>();
    for (Match bid : matches) {
      bidders.add(bid.levelId);
    }
    return bidders;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"success\" : " + success + ", ");
    sb.append("\"timeout\" : " + timeout + ", ");
    sb.append("\"playerId\" : " + id + ", ");
    sb.append("\"constrained\" : " + constrained + " , ");
    sb.append("\"matches\" : [ ");
    Boolean needComma = false;
    for (Match bid : matches) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append(bid.toString());
    }
    sb.append("] }");
    return sb.toString();
  }

  public static class Match {
    @Expose
    public final String playerId;
    @Expose
    public final String levelId;
    @Expose
    public final Double bid;

    public Match(String playerId, String levelId, Double bidAmount) {
      this.playerId = playerId;
      this.levelId = levelId;
      bid = bidAmount;
    }

    @Override
    public String toString() {
      return ("{ \"bid\" : " + bid + ", \"playerId\" : \"" + playerId + "\", \"levelId\" : \"" + levelId + "\" }");
    }
  }

}
