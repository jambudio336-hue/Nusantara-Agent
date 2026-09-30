package com.mazkiplay.nusantara;
import java.io.*;import java.net.*;import java.nio.charset.StandardCharsets;import java.util.concurrent.*;import java.util.*;
public final class DataEngine{
 private static final ExecutorService IO=Executors.newFixedThreadPool(6);
 private static final ConcurrentHashMap<String,String> CACHE=new ConcurrentHashMap<>();
 public static String get(String url,int connectMs,int readMs)throws Exception{
  String hit=CACHE.get(url);if(hit!=null)return hit;
  HttpURLConnection c=(HttpURLConnection)new URL(url).openConnection();c.setConnectTimeout(connectMs);c.setReadTimeout(readMs);c.setUseCaches(true);c.setRequestProperty("User-Agent","Nusantara-Agent/0.4");
  int code=c.getResponseCode();InputStream in=code>=200&&code<300?c.getInputStream():c.getErrorStream();String s=read(in);if(code<200||code>=300)throw new IOException("HTTP "+code);CACHE.put(url,s);return s;
 }
 public static CompletableFuture<String> getAsync(String url){return CompletableFuture.supplyAsync(()->{try{return get(url,8000,18000);}catch(Exception e){throw new CompletionException(e);}},IO);}
 public static String read(InputStream in)throws Exception{if(in==null)return "";BufferedReader r=new BufferedReader(new InputStreamReader(in,StandardCharsets.UTF_8));StringBuilder s=new StringBuilder();String z;while((z=r.readLine())!=null)s.append(z);return s.toString();}
 public static void invalidate(String url){CACHE.remove(url);}public static void clear(){CACHE.clear();}public static void shutdown(){IO.shutdownNow();}
}