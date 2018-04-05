/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import com.google.gson.annotations.Expose;

public class Constraint {

  @Expose
  public Collection<RangeConstraint> parameter = new ArrayList<RangeConstraint>(); // parameters
  @Expose
  public Collection<RangeConstraint> property = new ArrayList<RangeConstraint>(); // properties
  @Expose
  public Collection<DescriptorConstraint> tag = new ArrayList<DescriptorConstraint>(); // tags
  @Expose
  public Collection<DescriptorConstraint> label = new ArrayList<DescriptorConstraint>(); // labels
  @Expose
  public Collection<RangeConstraint> priority = new ArrayList<RangeConstraint>();
  @Expose
  public Collection<DescriptorConstraint> parentId = new ArrayList<DescriptorConstraint>();
  @Expose
  public Collection<DescriptorConstraint> predecessorId = new ArrayList<DescriptorConstraint>();

  public Boolean matches(Metadata metadata) {

    // test all parameters for matches
    for (RangeConstraint rcst : parameter) {
      Double traitValue = metadata.getParameter(rcst.name);
      if (false == rcst.matches(traitValue)) {
        return false;
      }
    }

    // test all properties for matches
    for (RangeConstraint rcst : property) {
      Double traitValue = metadata.getProperty(rcst.name);
      if (false == rcst.matches(traitValue)) {
        return false;
      }
    }

    // test all tags for matches
    for (DescriptorConstraint dcst : tag) {
      Collection<String> descColl = metadata.getTagSet();
      if (false == dcst.matches(descColl)) {
        return false;
      }
    }

    // test all labels for matches
    for (DescriptorConstraint dcst : label) {
      Collection<String> descColl = metadata.getLabelSet();
      if (false == dcst.matches(descColl)) {
        return false;
      }
    }

    // test parentId constraints for mismatches
    for (DescriptorConstraint dcst : parentId) {
      if (false == dcst.matches(metadata.parentId)) {
        return false;
      }
    }

    // test parentId constraints for mismatches
    for (DescriptorConstraint dcst : predecessorId) {
      if (false == dcst.matches(metadata.predecessorId)) {
        return false;
      }
    }

    // test priority constraints for matches
    for (RangeConstraint rcst : priority) {
      if (false == rcst.matches(metadata.priority)) {
        return false;
      }
    }

    return true;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    sb.append("\"parameter\" : ");
    sb.append(collectionToString(parameter));
    sb.append(", ");
    sb.append("\"property\" : ");
    sb.append(collectionToString(property));
    sb.append(", ");
    sb.append("\"tag\" : ");
    sb.append(collectionToString(tag));
    sb.append(", ");
    sb.append("\"label\" : ");
    sb.append(collectionToString(label));
    sb.append(", ");
    if (null != priority) {
      sb.append("\"priority\" : ");
      sb.append(priority.toString());
      sb.append(", ");
    }
    sb.append("\"parentId\" : ");
    sb.append(collectionToString(parentId));
    sb.append(", ");
    sb.append("\"predecessorId\" : ");
    sb.append(collectionToString(predecessorId));
    sb.append(" }");

    return sb.toString();
  }

  private String collectionToString(Collection<? extends Object> coll) {
    StringBuilder sb = new StringBuilder();
    Boolean needComma = false;
    sb.append("[ ");
    for (Object obj : coll) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append(obj.toString());
    }
    sb.append(" ]");
    return sb.toString();
  }

  public static class RangeConstraint {
    @Expose
    public String name;
    @Expose
    public Boolean isRequired; // as opposed to isRestricted
    @Expose
    public Double from;
    @Expose
    public Double to;

    public RangeConstraint(String name, Boolean isRequired, Double from, Double to) {
      this.name = name;
      this.isRequired = isRequired;
      this.from = from;
      this.to = to;
    }

    public Boolean matches(Double x) {
      if (null == x) {
        return !isRequired;
      }
      if (isRequired) {
        return ((x.compareTo(from) >= 0) && (x.compareTo(to) <= 0));
      } else {
        return ((x.compareTo(from) < 0) || (x.compareTo(to) > 0));
      }
    }

    @Override
    public String toString() {
      return ("{ \"name\" : \"" + name + "\", \"isRequired\" : " + isRequired + ", \"from\" : " + from.toString() + ", \"to\" : "
          + to.toString() + " }");
    }
  }

  public static class DescriptorConstraint {
    @Expose
    public String name;
    @Expose
    public Boolean isRequired;

    public DescriptorConstraint(String name, Boolean isRequired) {
      this.name = name;
      this.isRequired = isRequired;

    }

    public Boolean matches(Collection<String> desc) {

      if (null == desc) {
        return !isRequired;
      }

      for (String entry : desc) {
        if (name.equals(entry)) {
          return isRequired;
        }
      }
      return !isRequired;
    }

    public Boolean matches(String desc) {
      if (null == desc) {
        return !isRequired;
      }
      return matches(Arrays.asList(desc));
    }

    @Override
    public String toString() {
      return ("{ \"name\" : \"" + name + "\", \"isRequired\" : " + isRequired + " }");
    }
  }

}
