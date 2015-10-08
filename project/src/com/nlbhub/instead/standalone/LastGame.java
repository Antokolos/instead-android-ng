package com.nlbhub.instead.standalone;

import android.content.Context;
import com.nlbhub.instead.R;
import com.nlbhub.instead.universal.GameList;


public class LastGame {

	private String title;
	private String name;
	private String title_def;
	private int filtr;
	private int list;
	private String lang;	    
    private MyPrefs pr;
	private boolean nativelog;
	private boolean enforceorientation;
	private boolean enforceresolution;
    private boolean scroff;
    private boolean flagsync;
    private boolean keyb;
    private boolean keyvol;
    
	public LastGame(Context p){
		pr = new MyPrefs(p, Globals.ApplicationName);
		title_def =  p.getString(R.string.bundledgame);
 		filtr = pr.get("filtr", GameList.ALL);
 		list = pr.get("list", Globals.BASIC);		
 		lang = pr.get("lang", Globals.Lang.ALL);
 		name = pr.get("name", Globals.BundledGame);
 		title = pr.get("title", title_def);
        nativelog = pr.get("nativelog", Globals.NATIVE_LOG_DEFAULT);
		enforceorientation = pr.get("enforceorientation", Globals.ENFORCE_ORIENTATION_DEFAULT);
		enforceresolution = pr.get("enforceresolution", Globals.ENFORCE_RESOLUTION_DEFAULT);
 		scroff = pr.get("scroff", true);
 		keyb = pr.get("keyb", true);
 		keyvol = pr.get("keyvol", false);
 		flagsync = pr.get("flagsync", true);
	}
	
	public void clearGame(){
 		name = Globals.BundledGame;
 		title = title_def;		
 		Commit();
	}

	public void clearAll(){
        nativelog = Globals.NATIVE_LOG_DEFAULT;
		enforceorientation = Globals.ENFORCE_ORIENTATION_DEFAULT;
		enforceresolution = Globals.ENFORCE_RESOLUTION_DEFAULT;
		scroff = true;
		flagsync = true;
		keyb = true;
		keyvol = false;
		filtr = GameList.ALL;
 		list =  Globals.BASIC;		
 		lang = Globals.Lang.ALL;
 		name = Globals.BundledGame;
 		title = title_def;		
 		Commit();
	}

	
	
	public String getTitle(){
		return title;
	}

	public String getLang(){
		if(lang.equals("null")){ 
			lang = Globals.Lang.ALL;
		}
		return lang;
	}
	
	public String getName(){
		return name;
	}

	public int getFiltr(){
		return filtr;
	}
	
	public int getListNo(){
		return list;
	}
	
	
	public void setLast(String t, String n){
		title = t;
		name = n;
		Commit();
	}

	public void setTitle(String t){
		title = t;
		Commit();
	}

	public void setLang(String l){
		if(l.equals("null")){ 
			l = Globals.Lang.ALL;
		}
		lang = l;
		Commit();
	}
	
	
	public void setFiltr(int f){
		filtr = f;
		Commit();
	}

	public void setListNo(int l){	
		list = l;
		Commit();
	}


    public boolean isNativelog() {
        return nativelog;
    }

    public void setNativelog(boolean nativelog) {
        this.nativelog = nativelog;
        Commit();
    }

	public boolean isEnforceorientation() {
		return enforceorientation;
	}

	public void setEnforceorientation(boolean enforceorientation) {
		this.enforceorientation = enforceorientation;
		Commit();
	}

	public boolean isEnforceresolution() {
		return enforceresolution;
	}

	public void setEnforceresolution(boolean enforceresolution) {
		this.enforceresolution = enforceresolution;
		Commit();
	}

	public boolean getScreenOff(){
		return scroff;
	}
	
	public void setScreenOff(boolean b){
		scroff = b;
		Commit();
	}

	public boolean getKeyboard(){
		return keyb;
	}
	
	public void setKeyboard(boolean b){
		keyb = b;
		Commit();
	}
	
	public boolean getFlagSync(){
		return flagsync;
	}
	
	public void setFlagSync(boolean b){
		flagsync = b;
		Commit();
	}

	public boolean getOvVol(){
		return keyvol;
	}
	
	public void setOvVol(boolean b){
		keyvol = b;
		Commit();
	}

	
	
	private void Commit() {
		pr.set("flagsync", flagsync);
 		pr.set("filtr", filtr);
 		pr.set("list", list);		
 		pr.set("lang", lang);
 		pr.set("name", name);
 		pr.set("title", title);
        pr.set("nativelog", nativelog);
		pr.set("enforceorientation", enforceorientation);
		pr.set("enforceresolution", enforceresolution);
 		pr.set("scroff", scroff);
 		pr.set("keyb", keyb);
 		pr.set("keyvol", keyvol);
 		pr.commit();
	}
	
}
