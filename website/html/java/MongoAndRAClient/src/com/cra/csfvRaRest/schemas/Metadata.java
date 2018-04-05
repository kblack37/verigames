/////////////////////////////////////////////////////////////////////////////// 
// Charles River Analytics, Inc., Cambridge, Massachusetts 
// Copyright (C) 2013. All Rights Reserved. 
// See http://www.cra.com or email info@cra.com for more information. 
/////////////////////////////////////////////////////////////////////////////// 
// Author: wdorin@cra.com
/////////////////////////////////////////////////////////////////////////////// 

package com.cra.csfvRaRest.schemas;

import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import org.apache.commons.collections.CollectionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.google.gson.annotations.Expose;

public class Metadata {
  // Class containing level metadata

  @Expose
  public Double priority;
  @Expose
  public String comment;
  @Expose
  public Set<Trait> parameters = new HashSet<Trait>();
  @Expose
  public Set<Trait> properties = new HashSet<Trait>();
  @Expose
  public Set<Descriptor> tags = new HashSet<Descriptor>();
  @Expose
  public Set<Descriptor> labels = new HashSet<Descriptor>();
  @Expose
  public String parentId = "";
  @Expose
  public String predecessorId = "";

  public void removeParameter(String name) {
    Iterator<Trait> iter = parameters.iterator();
    while (iter.hasNext()) {
      Trait trait = iter.next();
      if (trait.name.equals(name)) {
        iter.remove();
      }
    }
  }

  public void removeProperty(String name) {
    Iterator<Trait> iter = properties.iterator();
    while (iter.hasNext()) {
      Trait trait = iter.next();
      if (trait.name.equals(name)) {
        iter.remove();
      }
    }
  }

  public void putParameter(Trait trait) {
    putParameter(trait.name, trait.value);
  }

  public void putParameter(String name, Double value) {
    removeParameter(name);
    parameters.add(new Trait(name, value));
  }

  public void putProperty(Trait trait) {
    putProperty(trait.name, trait.value);
  }

  public void putProperty(String name, Double value) {
    removeProperty(name);
    properties.add(new Trait(name, value));
  }

  public void removeTag(String name) {
    Iterator<Descriptor> iter = tags.iterator();
    while (iter.hasNext()) {
      Descriptor desc = iter.next();
      if (desc.name.equals(name)) {
        iter.remove();
      }
    }
  }

  public void removeLabel(String name) {
    Iterator<Descriptor> iter = labels.iterator();
    while (iter.hasNext()) {
      Descriptor desc = iter.next();
      if (desc.name.equals(name)) {
        iter.remove();
      }
    }
  }

  public void putTag(String name) {
    removeTag(name);
    tags.add(new Descriptor(name, true));
  }

  public void putTag(String name, Boolean keep) {
    removeTag(name);
    if (true == keep) {
      tags.add(new Descriptor(name, true));
    }
  }

  public void putTag(Descriptor desc) {
    putTag(desc.name, desc.value);
  }

  public void putLabel(String name) {
    removeLabel(name);
    labels.add(new Descriptor(name, true));
  }

  public void putLabel(String name, Boolean keep) {
    removeLabel(name);
    if (true == keep) {
      labels.add(new Descriptor(name, true));
    }
  }

  public void putLabel(Descriptor desc) {
    putLabel(desc.name, desc.value);
  }

  public Set<String> getParameterSet() {
    Set<String> names = new HashSet<String>();
    for (Trait trait : parameters) {
      names.add(trait.name);
    }
    return names;
  }

  public Set<String> getPropertySet() {
    Set<String> names = new HashSet<String>();
    for (Trait trait : properties) {
      names.add(trait.name);
    }
    return names;
  }

  public Set<String> getTagSet() {
    Set<String> names = new HashSet<String>();
    for (Descriptor desc : tags) {
      if (true == desc.value) {
        names.add(desc.name);
      }
    }
    return names;
  }

  public Set<String> getLabelSet() {
    Set<String> names = new HashSet<String>();
    for (Descriptor desc : labels) {
      if (true == desc.value) {
        names.add(desc.name);
      }
    }
    return names;
  }

  public Boolean hasParameter(String name) {
    for (Trait trait : parameters) {
      if (trait.name.equals(name)) {
        return true;
      }
    }
    return false;
  }

  public Boolean hasProperty(String name) {
    for (Trait trait : properties) {
      if (trait.name.equals(name)) {
        return true;
      }
    }
    return false;
  }

  public Boolean hasTag(String name) {
    for (Descriptor desc : tags) {
      if (desc.name.equals(name)) {
        return true;
      }
    }
    return false;
  }

  public Boolean hasLabel(String name) {
    for (Descriptor desc : labels) {
      if (desc.name.equals(name)) {
        return true;
      }
    }
    return false;
  }

  public Double getParameter(String name) {
    for (Trait trait : parameters) {
      if (trait.name.equals(name)) {
        return trait.value;
      }
    }
    return null;
  }

  public Double getProperty(String name) {
    for (Trait trait : properties) {
      if (trait.name.equals(name)) {
        return trait.value;
      }
    }
    return null;
  }

  @SuppressWarnings("unused")
  private static final Logger log = LoggerFactory.getLogger(Metadata.class);

  private boolean nullCheckingEquals(Object obj1, Object obj2) {
    if ((null == obj1) && (null == obj2)) {
      return true;
    }
    if ((null == obj1) || (null == obj2)) {
      return false;
    }
    return obj1.equals(obj2);
  }

  private boolean nullCheckCollections(Collection<? extends Object> c1, Collection<? extends Object> c2) {
    if ((null == c1) && (null == c2)) {
      return true;
    }
    if ((null == c1) || (null == c2)) {
      return false;
    }

    return (CollectionUtils.isEqualCollection(c1, c2));

  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof Metadata)) {
      return false;
    }

    Metadata lm = (Metadata) obj;

    boolean eq = true;
    eq &= nullCheckingEquals(comment, lm.comment);
    eq &= nullCheckingEquals(parentId, lm.parentId);
    eq &= nullCheckingEquals(predecessorId, lm.predecessorId);
    eq &= nullCheckingEquals(priority, lm.priority);
    eq &= nullCheckCollections(parameters, lm.parameters);
    eq &= nullCheckCollections(properties, lm.properties);

    eq &= nullCheckCollections(tags, lm.tags);
    eq &= nullCheckCollections(labels, lm.labels);
    return eq;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("{ ");
    Boolean needComma = false;
    if (null != priority) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append("priority : " + priority.toString());
    }

    if (null != comment) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append("comment : " + comment.toString());
    }

    Boolean needComma2 = false;
    if (null != parameters) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append("parameters : [ ");
      for (Trait trait : parameters) {
        needComma2 = (needComma2) ? null != sb.append(", ") : true;
        sb.append(trait.toString());
      }
      sb.append(" ]");
    }

    needComma2 = false;
    if (null != properties) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append("properties : [ ");
      for (Trait trait : properties) {
        needComma2 = (needComma2) ? null != sb.append(", ") : true;
        sb.append(trait.toString());
      }
      sb.append(" ]");
    }

    needComma2 = false;
    if (null != tags) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append("tags : [ ");
      for (Descriptor desc : tags) {
        needComma2 = (needComma2) ? null != sb.append(", ") : true;
        sb.append(desc.toString());
      }
      sb.append(" ]");
    }

    needComma2 = false;
    if (null != labels) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append("labels : [ ");
      for (Descriptor desc : labels) {
        needComma2 = (needComma2) ? null != sb.append(", ") : true;
        sb.append(desc.toString());
      }
      sb.append(" ]");
    }

    if (null != parentId) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append("parentId : " + parentId.toString());
    }
    if (null != predecessorId) {
      needComma = (needComma) ? null != sb.append(", ") : true;
      sb.append("predecessorId : " + predecessorId.toString());
    }
    
    if (null != predecessorId) {
        needComma = (needComma) ? null != sb.append(", ") : true;
        sb.append("fileID : " + "\"42\"");
      }

    sb.append(" }");
    return sb.toString();
  }

  public static class Trait {
    @Expose
    public final String name;
    @Expose
    public Double value;

    public Trait(final String name, final Double value) {
      this.name = name;
      this.value = value;
    }

    public Trait(Trait t) {
      this(new String(t.name), new Double(t.value));
    }

    @Override
    public boolean equals(Object obj) {
      if (!(obj instanceof Trait)) {
        return false;
      }
      Trait t = (Trait) obj;
      return (nullCheckingEquals(name, t.name) && nullCheckingEquals(value, t.value));
    }

    private boolean nullCheckingEquals(Object obj1, Object obj2) {
      if ((null == obj1) && (null == obj2)) {
        return true;
      }
      if ((null == obj1) || (null == obj2)) {
        return false;
      }
      return obj1.equals(obj2);
    }

    @Override
    public String toString() {
      String valString = (null == value) ? "null" : value.toString();
      return ("{ \"name\" : \"" + name + "\", \"value\" : " + valString + " }");
    }

    @Override
    public int hashCode() {
      return this.toString().hashCode();
    }
  }

  public static class Descriptor {

    @Expose
    public final String name;
    @Expose
    public Boolean value;

    public Descriptor(final String name, final Boolean value) {
      this.name = name;
      this.value = value;
    }

    public Descriptor(Descriptor d) {
      this(new String(d.name), new Boolean(d.value));
    }

    @Override
    public boolean equals(Object obj) {
      if (!(obj instanceof Descriptor)) {
        return false;
      }
      Descriptor d = (Descriptor) obj;
      return (nullCheckingEquals(name, d.name) && nullCheckingEquals(value, d.value));
    }

    private boolean nullCheckingEquals(Object obj1, Object obj2) {
      if ((null == obj1) && (null == obj2)) {
        return true;
      }
      if ((null == obj1) || (null == obj2)) {
        return false;
      }
      return obj1.equals(obj2);
    }

    @Override
    public String toString() {
      String valString = (null == value) ? "null" : value.toString();
      return ("{ \"name\" : \"" + name + "\", \"value\" : " + valString + " }");
    }

    @Override
    public int hashCode() {
      return (this.toString()).hashCode();
    }

  }
}
