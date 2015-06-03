package com.silentlexx.instead.standalone;

import android.content.Context;
import com.silentlexx.instead.R;
import com.silentlexx.instead.universal.GameList;


public class LastGame {

	private String title;
	private String name;
	private String title_def;
	private int filtr;
	private int list;
	private String lang;	    
    private MyPrefs pr;
    private boolean scroff;
    private boolean flagsync;
    private boolean keyb;
    private boolean keyvol;
    
	public LastGame(Context p){
		pr = new MyPrefs(p, Globals.ApplicationName);
		title_def =  p.getString(R.string.tutorial);
 		filtr = pr.get("filtr", GameList.ALL);
 		list = pr.get("list", Globals.BASIC);		
 		lang = pr.get("lang", Globals.Lang.ALL);
 		name = pr.get("name", Globals.TutorialGame);
 		title = pr.get("title", title_def);
 		scroff = pr.get("scroff", true);
 		keyb = pr.get("keyb", true);
 		keyvol = pr.get("keyvol", false);
 		flagsync = pr.get("flagsync", true);
	}
	
	public void clearGame(){
 		name = Globals.TutorialGame;
 		title = title_def;		
 		Commit();
	}

	public void clearAll(){
		scroff = true;
		flagsync = true;
		keyb = true;
		keyvol = false;
		filtr = GameList.ALL;
 		list =  Globals.BASIC;		
 		lang = Globals.Lang.ALL;
 		name = Globals.TutorialGame;
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
 		pr.set("scroff", scroff);
 		pr.set("keyb", keyb);
 		pr.set("keyvol", keyvol);
 		pr.commit();
	}
	
}
