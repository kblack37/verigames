package com.cgs.elements;

import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import org.apache.commons.lang3.StringEscapeUtils;
import org.xml.sax.Attributes;

public class Element
{
	public String id;
	public HashMap<String, String> attributeMap;
	public Element parent;
		
	Element(String _id)
	{
		id = _id;
		attributeMap = new HashMap<String, String>();
	}
	
	public void addAttribute(String key, String value)
	{
		attributeMap.put(key, value);
	}
	
	public String getAttribute(String key)
	{
		return attributeMap.get(key);
	}
	
	public void addAttributes(Attributes attributes)
	{
		int attributesLength = attributes.getLength();
		for(int i = 0 ; i<attributesLength; i++)
		{
		  String type = attributes.getLocalName(i);
		  String value = attributes.getValue(i);
		  addAttribute(type,value);
		}
	}
	
	public void writeAttributes(StringBuffer buffer)
	{
		Iterator<String> iter = attributeMap.keySet().iterator();
		
		while (iter.hasNext()) {
			String key = iter.next();
			String val = attributeMap.get(key);

			buffer.append("<attr name=\"" + key + "\">\r");
			buffer.append("<string>" + val + "</string>\r");
			buffer.append("</attr>\r");
		}
	}
	
	public void writeAttributeString(PrintWriter printWriter)
	{
		Iterator<String> iter = attributeMap.keySet().iterator();
		
		while (iter.hasNext()) {
			String key = iter.next();
			String val = StringEscapeUtils.escapeXml(attributeMap.get(key));

			printWriter.write(key + "=\"" + val + "\" ");
		}
	}
	
	public void write(PrintWriter printWriter)
	{
		
	}
}