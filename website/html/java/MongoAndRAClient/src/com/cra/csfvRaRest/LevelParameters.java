/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import au.com.bytecode.opencsv.CSVReader;

public class LevelParameters {

  private final Integer gameId;
  private final Map<String, TraitDefinition> parameters = new HashMap<String, TraitDefinition>();

  public LevelParameters(Integer gameId, String paramsFile) {

    this.gameId = gameId;

    CSVReader cr;
    try {
      cr = new CSVReader(new FileReader(paramsFile), ',');
      String[] row = null;
      while ((row = cr.readNext()) != null) {
        String name = row[0];
        Double from = Double.valueOf(row[1]);
        Double to = Double.valueOf(row[2]);
        parameters.put(name, new TraitDefinition(name, from, to));
      }
      cr.close();
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    }

  }

  public Set<String> parameterSet() {
    return parameters.keySet();
  }

  public Map<String, TraitDefinition> parameters() {
    return parameters;
  }

  public Integer parameterCount() {
    return parameters.size();
  }

  public Integer gameId() {
    return gameId;
  }

  public static class TraitDefinition {
    private final String name;
    private final Double minValue;
    private final Double maxValue;

    public TraitDefinition(String name, Double minValue, Double maxValue) {
      this.name = name;
      this.minValue = minValue;
      this.maxValue = maxValue;
    }

    public TraitDefinition(List<String> inputs) {
      name = inputs.get(0);
      minValue = Double.valueOf(inputs.get(1));
      maxValue = Double.valueOf(inputs.get(2));
    }

    public String name() {
      return name;
    }

    public Double minValue() {
      return minValue;
    }

    public Double maxValue() {
      return maxValue;
    }

    public Double span() {
      return maxValue - minValue;
    }

    public Double random() {
      return minValue + (span() * Math.random());
    }

    @Override
    public String toString() {
      return (name + ": [" + minValue + ", " + maxValue + "]");
    }

  }

}
