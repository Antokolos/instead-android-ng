package com.nlbhub.instead.launcher.simple;

import android.content.Context;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.standalone.Settings;
import com.nlbhub.instead.standalone.StorageResolver;

public class LastGame extends Settings {
	private String title;
	private String name;
	private String title_def;
	private int filtr;
	private int list;
	private String lang;	    
    private MyPrefs pr;
    private boolean flagsync;

	public LastGame() {
		super();
	}

	// TODO: maybe remove this contructor and make all initialization of this class via SettingsFactory
	public LastGame(Context p) {
		this();
		init(p);
	}

	@Override
	public void init(Context p) {
		super.init(p);
		pr = new MyPrefs(p, InsteadApplication.ApplicationName);
		title_def =  p.getString(R.string.bundledgame);
 		filtr = pr.get("filtr", FilterConstants.ALL);
 		list = pr.get("list", Globals.BASIC);		
 		lang = pr.get("lang", Globals.Lang.ALL);
 		name = pr.get("name", StorageResolver.BundledGame);
 		title = pr.get("title", title_def);
		super.setMusic(pr.get("music", Settings.MUSIC_DEFAULT));
        super.setNativelog(pr.get("nativelog", Settings.NATIVE_LOG_DEFAULT));
		super.setEnforceresolution(pr.get("enforceresolution", Settings.ENFORCE_RESOLUTION_DEFAULT));
 		super.setScreenOff(pr.get("scroff", Settings.SCREEN_OFF_DEFAULT));
 		super.setKeyboard(pr.get("keyb", Settings.KEYBOARD_DEFAULT));
 		super.setOvVol(pr.get("keyvol", Settings.OV_VOL_DEFAULT));
		super.setOwntheme(pr.get("owntheme", Settings.OWNTHEME_DEFAULT));
		super.setTheme(pr.get("theme", Settings.THEME_DEFAULT));
 		flagsync = pr.get("flagsync", true);
	}
	
	public void clearGame(){
 		name = StorageResolver.BundledGame;
 		title = title_def;		
 		Commit();
	}

	@Override
	public void clearAll(){
        super.clearAll();
		flagsync = true;
		filtr = FilterConstants.ALL;
 		list =  Globals.BASIC;		
 		lang = Globals.Lang.ALL;
 		name = StorageResolver.BundledGame;
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

	@Override
	public void setMusic(boolean music) {
		super.setMusic(music);
		Commit();
	}

	public void setNativelog(boolean nativelog) {
        super.setNativelog(nativelog);
        Commit();
    }

	public void setEnforceresolution(boolean enforceresolution) {
		super.setEnforceresolution(enforceresolution);
		Commit();
	}
	
	public void setScreenOff(boolean b){
		super.setScreenOff(b);
		Commit();
	}
	
	public void setKeyboard(boolean b){
		super.setKeyboard(b);
		Commit();
	}
	
	public boolean getFlagSync(){
		return flagsync;
	}
	
	public void setFlagSync(boolean b){
		flagsync = b;
		Commit();
	}
	
	public void setOvVol(boolean b){
		super.setOvVol(b);
		Commit();
	}

	@Override
	public void setOwntheme(boolean owntheme) {
		super.setOwntheme(owntheme);
		Commit();
	}

	@Override
	public void setTheme(String theme) {
		super.setTheme(theme);
		Commit();
	}

	private void Commit() {
		pr.set("flagsync", flagsync);
 		pr.set("filtr", filtr);
 		pr.set("list", list);		
 		pr.set("lang", lang);
 		pr.set("name", name);
 		pr.set("title", title);
		pr.set("music", isMusic());
        pr.set("nativelog", isNativelog());
		pr.set("enforceresolution", isEnforceresolution());
 		pr.set("scroff", getScreenOff());
 		pr.set("keyb", getKeyboard());
 		pr.set("keyvol", getOvVol());
		pr.set("owntheme", isOwntheme());
		pr.set("theme", getTheme());
		pr.commit();
	}
	
}
