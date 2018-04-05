/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.hadoop.chukwa.database;

import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.chukwa.util.DatabaseWriter;
import org.apache.hadoop.chukwa.util.RegexUtil;

public class Macro {
    private static Log log = LogFactory.getLog(Macro.class);
    private boolean forCharting = false;
    private long current = 0;
    private long start = 0;
    private long end = 0;
    private static DatabaseConfig dbc = new DatabaseConfig();
    private static DatabaseWriter db = null;
	@SuppressWarnings("trusted") // initially null
    private @Trusted String query = null;
    private HttpServletRequest request = null;

    public Macro(long timestamp, @Trusted String query) {
        this.current = timestamp;
        this.start = timestamp;
        this.end = timestamp;
        this.query = query;
    }

    public Macro(long startTime, long endTime, @Trusted String query) {
        this.current = endTime;
        this.start = startTime;
        this.end = endTime;
        forCharting = true;	
        this.query = query;
    }
    
    public Macro(long startTime, long endTime, @Trusted String query, HttpServletRequest request) {
        this.request = request;
        this.current = endTime;
        this.start = startTime;
        this.end = endTime;
        forCharting = true; 
        this.query = query;        
    }
    public HashMap<@Trusted String,String> findMacros(@Trusted String query) throws SQLException {
        boolean add=false;
        HashMap<@Trusted String,String> macroList = new HashMap<@Trusted String,String>();
        String macro="";
        for(int i=0;i<query.length();i++) {
            if(query.charAt(i)==']') {
                add=false;
                if(!macroList.containsKey(macro)) {
                    if (!RegexUtil.isRegex(macro)) {
                      throw new Error("error parsing regex " + macro + ": " + RegexUtil.regexError(macro));
                    }
                    @SuppressWarnings("trusted") // made from trusted String query
                    String subString = computeMacro((@Trusted String)macro);
                    macroList.put((@Trusted String)macro,subString);	    			
                }
                macro="";
            }
            if(add) {
                macro=macro+query.charAt(i);
            }
            if(query.charAt(i)=='[') {
                add=true;
            }
        }
        return macroList;
    }

    @SuppressWarnings("trusted") // There are a lot of casts here. The only place where
    // I am unsure that the return is trusted is line 267. But the only constructor which sets 
    // request to be non-null is never used. So that is probably dead code. 
    public @Trusted String computeMacro(/*@Regex*/ @Trusted String macro) throws SQLException {
        Pattern p = Pattern.compile("past_(.*)_minutes");
        Matcher matcher = p.matcher(macro);
        if(macro.indexOf("avg(")==0 || macro.indexOf("group_avg(")==0 || macro.indexOf("sum(")==0) {
            @Trusted String meta="";
            @Trusted String[] table = null;
            if(forCharting) {
                table = dbc.findTableNameForCharts((@Trusted String) macro.substring(macro.indexOf("(")+1,macro.indexOf(")")), start, end);
            } else {
                @SuppressWarnings("trusted") // substring operation
                /*@Regex*/ @Trusted String regex = (@Trusted String) macro.substring(macro.indexOf("(")+1,macro.indexOf(")"));
                table = dbc.findTableName(regex, start, end);
            }
            try {
                String cluster = System.getProperty("CLUSTER");
                if(cluster==null) {
                    cluster="unknown";
                }
                db = new DatabaseWriter(cluster);
                DatabaseMetaData dbMetaData = db.getConnection().getMetaData();
                ResultSet rs = dbMetaData.getColumns ( null,null,table[0], null);
                boolean first=true;
                while(rs.next()) {
                    if(!first) {
                        meta = meta+",";
                    }
                    @SuppressWarnings("trusted") // comes from inside the database
                    @Trusted String name = (@Trusted String) rs.getString(4);
                    int type = rs.getInt(5);
                    if(type==java.sql.Types.VARCHAR) {
                        if(macro.indexOf("group_avg(")<0) {
                            meta=meta+"count("+name+") as "+name;
                        } else {
                            meta=meta+name;
                        }
                        first=false;
                    } else if(type==java.sql.Types.DOUBLE ||
                            type==java.sql.Types.FLOAT ||
                            type==java.sql.Types.INTEGER) {
                        if(macro.indexOf("sum(")==0) {
                            meta=meta+"sum("+name+")";	            			
                        } else {
                            meta=meta+"avg("+name+")";
                        }
                        first=false;
                    } else if(type==java.sql.Types.TIMESTAMP) {
                        meta=meta+name;	            			
                        first=false;
                    } else {
                        if(macro.indexOf("sum(")==0) {
                            meta=meta+"SUM("+name+")";
                        } else {
                            meta=meta+"AVG("+name+")";	            			
                        }
                        first=false;
                    }
                }
                db.close();
                if(first) {
                    throw new SQLException("Table is undefined.");
                }
            } catch(SQLException ex) {
                throw new SQLException("Table does not exist:"+ table[0]);
            }
            return meta;
        } else if(macro.indexOf("now")==0) {
            SimpleDateFormat sdf = new SimpleDateFormat();
            return (@Trusted String) DatabaseWriter.formatTimeStamp(current);
        } else if(macro.intern()=="start".intern()) {
            return (@Trusted String) DatabaseWriter.formatTimeStamp(start);
        } else if(macro.intern()=="end".intern()) {
            return (@Trusted String) DatabaseWriter.formatTimeStamp(end);
        } else if(matcher.find()) {
            int period = Integer.parseInt(matcher.group(1));
            long timestamp = current - (current % (period*60*1000L)) - (period*60*1000L);
            return (@Trusted String) DatabaseWriter.formatTimeStamp(timestamp);
        } else if(macro.indexOf("past_hour")==0) {
            return (@Trusted String) DatabaseWriter.formatTimeStamp(current-3600*1000L);
        } else if(macro.endsWith("_week")) {
            long partition = current / DatabaseConfig.WEEK;
            if(partition<=0) {
                partition=1;
            }
            String[] buffers = macro.split("_");
            StringBuffer tableName = new StringBuffer();
            for(int i=0;i<buffers.length-1;i++) {
                tableName.append(buffers[i]);
                tableName.append("_");
            }
            tableName.append(partition);
            tableName.append("_week");
            return (@Trusted String) tableName.toString(); // Just adds in the partition number
        } else if(macro.endsWith("_month")) {
            long partition = current / DatabaseConfig.MONTH;
            if(partition<=0) {
                partition=1;
            }
            String[] buffers = macro.split("_");
            StringBuffer tableName = new StringBuffer();
            for(int i=0;i<buffers.length-1;i++) {
                tableName.append(buffers[i]);
                tableName.append("_");
            }
            tableName.append(partition);
            tableName.append("_month");
            return (@Trusted String) tableName.toString(); // Just adds in the partition number
        } else if(macro.endsWith("_quarter")) {
            long partition = current / DatabaseConfig.QUARTER;
            if(partition<=0) {
                partition=1;
            }
            String[] buffers = macro.split("_");
            StringBuffer tableName = new StringBuffer();
            for(int i=0;i<buffers.length-1;i++) {
                tableName.append(buffers[i]);
                tableName.append("_");
            }
            tableName.append(partition);
            tableName.append("_quarter");
            return (@Trusted String) tableName.toString(); // Just adds in the partition number
        } else if(macro.endsWith("_year")) {
            long partition = current / DatabaseConfig.YEAR;
            if(partition<=0) {
                partition=1;
            }
            String[] buffers = macro.split("_");
            StringBuffer tableName = new StringBuffer();
            for(int i=0;i<buffers.length-1;i++) {
                tableName.append(buffers[i]);
                tableName.append("_");
            }
            tableName.append(partition);
            tableName.append("_year");
            return (@Trusted String) tableName.toString(); // Just adds in the partition number
        } else if(macro.endsWith("_decade")) {
            long partition = current / DatabaseConfig.DECADE;
            if(partition<=0) {
                partition=1;
            }
            String[] buffers = macro.split("_");
            StringBuffer tableName = new StringBuffer();
            for(int i=0;i<buffers.length-1;i++) {
                tableName.append(buffers[i]);
                tableName.append("_");
            }
            tableName.append(partition);
            tableName.append("_decade");
            return (@Trusted String) tableName.toString(); // Just adds in the partition number
        }
        if(forCharting) {
            if(macro.startsWith("session(") && request!=null){
                String keyword = macro.substring(macro.indexOf("(")+1,macro.indexOf(")"));
                String[] objects = null;
                if(request.getSession().getAttribute(keyword)!=null) {
                    objects = ((String)request.getSession().getAttribute(keyword)).split(",");
                }
                StringBuffer buf = new StringBuffer();
                boolean first = true;
                if(objects!=null) {
                    for(String object : objects) {
                        if(!first) {
                            buf.append(" or ");
                        }
                        first = false;
                        buf.append(macro.substring(macro.indexOf("(")+1,macro.indexOf(")"))+"='"+object+"'");
                    }
                    return buf.toString();
                }
                return "";
            } else {
                @Trusted String[] tableList = dbc.findTableNameForCharts(macro, start, end);
                StringBuffer buf = new StringBuffer();
                boolean first = true;
                for(String table : tableList) {
                    if(!first) {
                        buf.append("|");
                    }
                    first = false;
                    buf.append(table);
                }
                return (@Trusted String) buf.toString(); // Ors together trusted strings
            }
        }
        @Trusted String[] tableList = dbc.findTableName(macro,current,current);
        return tableList[0];
    }
    public @Trusted String toString() {
        try {
        HashMap<@Trusted String, String> macroList = findMacros(query);
        Iterator<@Trusted String> macroKeys = macroList.keySet().iterator();
        while(macroKeys.hasNext()) {
            String mkey = macroKeys.next();
            if(macroList.get(mkey).contains("|")) {
                StringBuffer buf = new StringBuffer();
                String[] tableList = macroList.get(mkey).split("\\|");
                boolean first = true;
                for(String table : tableList) {
                	@SuppressWarnings("trusted")
                    String newQuery = query.replace("["+mkey+"]", table);
                    if(!first) {
                        buf.append(" union ");
                    }
                    buf.append("(");
                    buf.append(newQuery);
                    buf.append(")");
                    first = false;
                }
                query = (@Trusted String) buf.toString();
            } else {
                log.debug("replacing:"+mkey+" with "+macroList.get(mkey));
                query = (@Trusted String) query.replace("["+mkey+"]", macroList.get(mkey));
            }
        }
        } catch(SQLException ex) {
            log.error(query);
            log.error(ex.getMessage());
        }
        return query;
    }

}
