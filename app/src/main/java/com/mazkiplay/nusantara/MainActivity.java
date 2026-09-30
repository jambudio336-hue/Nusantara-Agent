package com.mazkiplay.nusantara;

import android.app.*;
import android.os.*;
import android.graphics.*;
import android.graphics.pdf.PdfDocument;
import android.content.*;
import android.content.res.ColorStateList;
import android.security.keystore.*;
import android.util.Base64;
import android.view.*;
import android.view.inputmethod.InputMethodManager;
import android.widget.*;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.util.*;
import java.util.concurrent.*;
import javax.crypto.*;
import javax.crypto.spec.GCMParameterSpec;
import org.json.*;

public class MainActivity extends Activity {
    private static final String ENDPOINT="https://openrouter.ai/api/v1/";
    private static final String KEY_ALIAS="nusantara_agent_key";
    private final int BG=Color.rgb(8,8,10), PANEL=Color.rgb(18,18,22), PANEL2=Color.rgb(25,25,30);
    private final int TEXT=Color.rgb(245,245,247), MUTED=Color.rgb(155,155,165), ACCENT=Color.rgb(16,163,127), USER=Color.rgb(35,35,43);
    private LinearLayout root, messages;
    private EditText composer, keyInput;
    private TextView connectionStatus, modelStatus;
    private Spinner modelSpinner;
    private SharedPreferences prefs;
    private SecretKey secret;
    private final ArrayList<JSONObject> history=new ArrayList<>();
    private ExecutorService io=Executors.newCachedThreadPool();

    @Override public void onCreate(Bundle b){
        super.onCreate(b);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        prefs=getSharedPreferences("nusantara_secure",MODE_PRIVATE);
        secret=getKey();
        showChat();
    }

    private SecretKey getKey(){
        try{
            KeyStore ks=KeyStore.getInstance("AndroidKeyStore"); ks.load(null);
            if(!ks.containsAlias(KEY_ALIAS)){
                KeyGenerator g=KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES,"AndroidKeyStore");
                g.init(new KeyGenParameterSpec.Builder(KEY_ALIAS,KeyProperties.PURPOSE_ENCRYPT|KeyProperties.PURPOSE_DECRYPT)
                    .setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build());
                g.generateKey();
            }
            return (SecretKey)ks.getKey(KEY_ALIAS,null);
        }catch(Exception e){ return null; }
    }

    private TextView text(String s,float size){
        TextView t=new TextView(this); t.setText(s); t.setTextColor(TEXT); t.setTextSize(size);
        t.setPadding(dp(16),dp(10),dp(16),dp(10)); t.setLineSpacing(0,1.12f); return t;
    }
    private TextView label(String s,float size){
        TextView t=text(s,size); t.setTextColor(MUTED); return t;
    }
    private Button button(String s){
        Button b=new Button(this); b.setText(s); b.setTextColor(TEXT); b.setAllCaps(false);
        b.setBackgroundTintList(ColorStateList.valueOf(PANEL2)); return b;
    }
    private int dp(int n){return Math.round(n*getResources().getDisplayMetrics().density);}
    private void pad(View v,int l,int t,int r,int b){v.setPadding(dp(l),dp(t),dp(r),dp(b));}

    private void base(boolean settings){
        root=new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL); root.setBackgroundColor(BG);
        root.setPadding(dp(10),dp(8),dp(10),dp(8));
        setContentView(root);
        LinearLayout top=new LinearLayout(this); top.setGravity(Gravity.CENTER_VERTICAL);
        TextView brand=text("◈  NUSANTARA AGENT",19); brand.setTypeface(null,Typeface.BOLD);
        top.addView(brand,new LinearLayout.LayoutParams(0,-2,1));
        Button action=button(settings?"← Chat":"⚙ Settings"); top.addView(action,new LinearLayout.LayoutParams(dp(105),dp(48)));
        root.addView(top);
        action.setOnClickListener(v->{if(settings)showChat();else showSettings();});
    }

    private void showChat(){
        base(false);
        LinearLayout statusBar=new LinearLayout(this); statusBar.setGravity(Gravity.CENTER_VERTICAL);
        TextView status=text("●  READY",12); status.setTextColor(ACCENT);
        TextView model=text("AUTO",12); model.setTextColor(MUTED); model.setGravity(Gravity.RIGHT);
        statusBar.addView(status,new LinearLayout.LayoutParams(0,-2,1)); statusBar.addView(model,new LinearLayout.LayoutParams(0,-2,1));
        root.addView(statusBar);
        ScrollView scroll=new ScrollView(this); scroll.setFillViewport(true);
        messages=new LinearLayout(this); messages.setOrientation(LinearLayout.VERTICAL); messages.setPadding(2,dp(8),2,dp(8));
        scroll.addView(messages);
        root.addView(scroll,new LinearLayout.LayoutParams(-1,0,1));
        if(history.isEmpty()) addBubble(false,"NUSANTARA AGENT","Siap. Masukkan API key OpenRouter di Settings, lalu pilih model. Semua request memakai API key milik pengguna dan disimpan terenkripsi di perangkat.");
        else for(JSONObject h:history) addBubble(h.optString("role").equals("user"),h.optString("role").equals("user")?"GUE":"NUSANTARA",h.optString("content"));
        LinearLayout tools=new LinearLayout(this);
        Button clear=button("＋ Chat Baru"); tools.addView(clear,new LinearLayout.LayoutParams(dp(105),dp(46)));
        composer=new EditText(this); composer.setHint("Message Nusantara Agent…"); composer.setHintTextColor(MUTED); composer.setTextColor(TEXT); composer.setSingleLine(false); composer.setMaxLines(5);
        composer.setBackgroundColor(PANEL); pad(composer,12,4,12,4);
        tools.addView(composer,new LinearLayout.LayoutParams(0,dp(52),1));
        Button send=button("➤"); tools.addView(send,new LinearLayout.LayoutParams(dp(58),dp(52)));
        root.addView(tools);
        clear.setOnClickListener(v->{history.clear();showChat();});
        send.setOnClickListener(v->sendMessage());
        composer.setOnEditorActionListener((v,a,e)->{if(e!=null&&e.getKeyCode()==KeyEvent.KEYCODE_ENTER&&!e.isShiftPressed()){sendMessage();return true;}return false;});
    }

    private void addBubble(boolean user,String who,String body){
        LinearLayout wrap=new LinearLayout(this); wrap.setOrientation(LinearLayout.VERTICAL); wrap.setPadding(dp(4),dp(5),dp(4),dp(5));
        TextView h=text(who,12); h.setTypeface(null,Typeface.BOLD); h.setTextColor(user?Color.rgb(120,190,255):ACCENT);
        TextView b=text(body,15); b.setBackgroundColor(user?USER:PANEL); b.setTextIsSelectable(true);
        wrap.addView(h); wrap.addView(b);
        Button pdf=button("📄 PDF"); pdf.setTextSize(12); wrap.addView(pdf,new LinearLayout.LayoutParams(-2,dp(40))); pdf.setOnClickListener(v->savePdf(who,body));
        messages.addView(wrap,new LinearLayout.LayoutParams(-1,-2));
    }

    private void sendMessage(){
        if(composer==null)return;
        String q=composer.getText().toString().trim(); if(q.isEmpty())return;
        composer.setText(""); ((InputMethodManager)getSystemService(INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(composer.getWindowToken(),0);
        history.add(msg("user",q)); addBubble(true,"GUE",q);
        addBubble(false,"NUSANTARA","⏳ Menghubungkan ke OpenRouter…");
        io.submit(()->{
            try{
                String k=loadKey(); if(k.isEmpty())throw new Exception("API key belum tersimpan. Buka Settings → Test Connection.");
                String model=getModel();
                JSONObject body=new JSONObject(); body.put("model",model);
                JSONArray msgs=new JSONArray();
                JSONObject sys=new JSONObject(); sys.put("role","system"); sys.put("content","You are Nusantara Agent, a helpful Indonesian AI agent. Be concise, technical, and practical.");
                msgs.put(sys);
                for(JSONObject h:history)msgs.put(h);
                body.put("messages",msgs); body.put("temperature",0.7); body.put("stream",false);
                String raw=request("chat/completions",k,body.toString(),"POST");
                JSONObject o=new JSONObject(raw);
                String answer=o.optJSONArray("choices")!=null?o.getJSONArray("choices").getJSONObject(0).getJSONObject("message").optString("content",""): "";
                if(answer.isEmpty() && o.has("error")) throw new Exception(apiError(o));
                history.add(msg("assistant",answer));
                runOnUiThread(()->{showChat();});
            }catch(Exception e){
                String err=e.getMessage()==null?e.toString():e.getMessage();
                runOnUiThread(()->{history.add(msg("assistant","ERROR: "+err));showChat();});
            }
        });
    }

    private JSONObject msg(String role,String content){JSONObject o=new JSONObject();try{o.put("role",role);o.put("content",content);}catch(Exception ignored){}return o;}

    private String getModel(){
        if(modelSpinner!=null && modelSpinner.getSelectedItem()!=null){
            String m=modelSpinner.getSelectedItem().toString();
            if(!m.equals("AUTO"))return m;
        }
        String saved=prefs.getString("model","");
        return saved.isEmpty()?"openai/gpt-5-mini":saved;
    }

    private String apiError(JSONObject o){
        JSONObject e=o.optJSONObject("error"); return e==null?o.toString():e.optString("message","API error")+" (code "+e.optString("code","?")+")";
    }

    private String request(String path,String k,String body,String method)throws Exception{
        HttpURLConnection c=(HttpURLConnection)new URL(ENDPOINT+path).openConnection();
        c.setRequestMethod(method); c.setConnectTimeout(20000); c.setReadTimeout(90000);
        c.setRequestProperty("Authorization","Bearer "+k); c.setRequestProperty("Content-Type","application/json");
        c.setRequestProperty("Accept","application/json");
        c.setRequestProperty("HTTP-Referer","https://github.com/jambudio336-hue/Nusantara-Agent");
        c.setRequestProperty("X-Title","Nusantara Agent");
        if(body!=null){c.setDoOutput(true);try(OutputStream os=c.getOutputStream()){os.write(body.getBytes(StandardCharsets.UTF_8));}}
        int code=c.getResponseCode(); InputStream is=code>=200&&code<300?c.getInputStream():c.getErrorStream();
        String s=read(is); if(code<200||code>=300)throw new Exception("OpenRouter HTTP "+code+": "+compact(s)); return s;
    }

    private String requestGet(String path,String k)throws Exception{return request(path,k,null,"GET");}
    private String read(InputStream in)throws Exception{
        if(in==null)return "";
        BufferedReader r=new BufferedReader(new InputStreamReader(in,StandardCharsets.UTF_8)); StringBuilder s=new StringBuilder(); String x;
        while((x=r.readLine())!=null)s.append(x); return s.toString();
    }
    private String compact(String s){return s==null?"":(s.length()>700?s.substring(0,700)+"…":s);}

    private void showSettings(){
        base(true);
        ScrollView sc=new ScrollView(this); LinearLayout box=new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL); box.setPadding(dp(6),dp(8),dp(6),dp(24));
        TextView h=text("OpenRouter",24); h.setTypeface(null,Typeface.BOLD); box.addView(h);
        box.addView(label("BYO API key • disimpan terenkripsi di Android Keystore",13));
        keyInput=new EditText(this); keyInput.setHint("sk-or-v1-…"); keyInput.setHintTextColor(MUTED); keyInput.setTextColor(TEXT); keyInput.setSingleLine(true); keyInput.setInputType(129); pad(keyInput,12,5,12,5);
        String old=loadKey(); if(!old.isEmpty())keyInput.setText(old); box.addView(keyInput,new LinearLayout.LayoutParams(-1,dp(56)));
        Button test=button("✓  TEST CONNECTION"); box.addView(test,new LinearLayout.LayoutParams(-1,dp(52)));
        connectionStatus=label("⚪  NOT READY",15); box.addView(connectionStatus);
        modelStatus=label("Model catalog belum dimuat.",13); box.addView(modelStatus);
        modelSpinner=new Spinner(this); box.addView(modelSpinner,new LinearLayout.LayoutParams(-1,dp(52)));
        Button refresh=button("↻  REFRESH MODELS"); box.addView(refresh,new LinearLayout.LayoutParams(-1,dp(50)));
        TextView info=label("API key tidak ditanam di APK/source. Nusantara Agent memanggil https://openrouter.ai/api/v1/ langsung dari perangkat.",12); box.addView(info);
        sc.addView(box); root.addView(sc,new LinearLayout.LayoutParams(-1,0,1));
        test.setOnClickListener(v->testConnection()); refresh.setOnClickListener(v->discoverModels());
        if(!old.isEmpty()) connectionStatus.setText("🟡  KEY TERSIMPAN — tekan Test Connection");
    }

    private void testConnection(){
        final String k=keyInput.getText().toString().trim();
        if(k.isEmpty()){connectionStatus.setText("🔴  NOT READY — API key kosong");return;}
        saveKey(k); connectionStatus.setText("🟡  CHECKING…");
        io.submit(()->{
            try{
                String raw=requestGet("models",k); JSONObject o=new JSONObject(raw); JSONArray data=o.optJSONArray("data");
                if(data==null)throw new Exception("Respons /models tidak memiliki data");
                runOnUiThread(()->{connectionStatus.setText("🟢  READY — OpenRouter Connected");modelStatus.setText("✓ "+data.length()+" model terdeteksi");discoverModels();});
            }catch(Exception e){
                runOnUiThread(()->connectionStatus.setText("🔴  NOT READY — "+(e.getMessage()==null?e.toString():e.getMessage())));
            }
        });
    }

    private void discoverModels(){
        final String k=loadKey();
        if(k.isEmpty()){modelStatus.setText("Masukkan API key terlebih dahulu.");return;}
        modelStatus.setText("⏳ Memuat model…");
        io.submit(()->{
            try{
                JSONObject o=new JSONObject(requestGet("models",k)); JSONArray a=o.getJSONArray("data");
                ArrayList<String> list=new ArrayList<>(); list.add("AUTO");
                for(int i=0;i<a.length();i++){String id=a.getJSONObject(i).optString("id","");if(!id.isEmpty())list.add(id);}
                runOnUiThread(()->{
                    String current=prefs.getString("model","");
                    ArrayAdapter<String> ad=new ArrayAdapter<String>(this,android.R.layout.simple_spinner_dropdown_item,list);
                    modelSpinner.setAdapter(ad);
                    int pos=current.isEmpty()?0:list.indexOf(current); if(pos<0)pos=0; modelSpinner.setSelection(pos);
                    modelSpinner.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener(){
                        public void onItemSelected(android.widget.AdapterView<?> p,View v,int pos,long id){prefs.edit().putString("model",list.get(pos).equals("AUTO")?"":list.get(pos)).apply();}
                        public void onNothingSelected(android.widget.AdapterView<?> p){}
                    });
                    modelStatus.setText("✓ "+list.size()+" pilihan model siap");
                });
            }catch(Exception e){runOnUiThread(()->modelStatus.setText("🔴 Gagal memuat model: "+compact(e.getMessage())));}
        });
    }

    private void saveKey(String s){
        try{
            if(secret==null)return;
            Cipher c=Cipher.getInstance("AES/GCM/NoPadding"); c.init(Cipher.ENCRYPT_MODE,secret);
            String iv=Base64.encodeToString(c.getIV(),Base64.NO_WRAP), enc=Base64.encodeToString(c.doFinal(s.getBytes(StandardCharsets.UTF_8)),Base64.NO_WRAP);
            prefs.edit().putString("key",iv+"."+enc).apply();
        }catch(Exception ignored){}
    }
    private String loadKey(){
        try{
            String z=prefs.getString("key",""); if(z.isEmpty()||secret==null)return "";
            int dot=z.indexOf('.'); if(dot<0)return ""; String[] p=new String[]{z.substring(0,dot),z.substring(dot+1)};
            Cipher c=Cipher.getInstance("AES/GCM/NoPadding"); c.init(Cipher.DECRYPT_MODE,secret,new GCMParameterSpec(128,Base64.decode(p[0],Base64.NO_WRAP)));
            return new String(c.doFinal(Base64.decode(p[1],Base64.NO_WRAP)),StandardCharsets.UTF_8);
        }catch(Exception e){return "";}
    }

    private void savePdf(String who,String body){
        try{
            PdfDocument d=new PdfDocument(); PdfDocument.PageInfo pi=new PdfDocument.PageInfo.Builder(595,842,1).create(); PdfDocument.Page p=d.startPage(pi);
            Canvas c=p.getCanvas(); Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG); paint.setTextSize(13); int y=40; int page=1;
            String[] words=body.split(" "); String line=who+": "; float max=535;
            for(String w:words){
                String test=line+(line.trim().isEmpty()?w:" "+w);
                if(paint.measureText(test)>max){c.drawText(line,30,y,paint);y+=20;line=w;if(y>800){d.finishPage(p);p=d.startPage(new PdfDocument.PageInfo.Builder(595,842,++page).create());c=p.getCanvas();y=40;}}
                else line=test;
            }
            if(!line.isEmpty())c.drawText(line,30,y,paint); d.finishPage(p);
            File f=new File(getExternalFilesDir(null),"Nusantara-"+System.currentTimeMillis()+".pdf");
            try(FileOutputStream out=new FileOutputStream(f)){d.writeTo(out);} d.close();
            Toast.makeText(this,"PDF tersimpan",Toast.LENGTH_LONG).show();
        }catch(Exception e){Toast.makeText(this,"PDF error: "+e.getMessage(),Toast.LENGTH_LONG).show();}
    }

    @Override protected void onDestroy(){super.onDestroy();io.shutdownNow();}
}