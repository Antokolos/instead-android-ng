package com.silentlexx.instead.standalone;

import android.content.Context;
import android.content.SharedPreferences;

public class MyPrefs {
	public static final String STRING = null;
	public static final int INT = 0;
	public static final boolean BOOL = false;
	private SharedPreferences pr;
	SharedPreferences.Editor ed;
	
	public MyPrefs(Context p, final String PREFS_STRING){
	    pr = p.getSharedPreferences(PREFS_STRING, 0);		
	    ed = pr.edit();
	}
	
	public void  clear(){
		ed.clear();
	}
	
	public void commit(){
		ed.commit();
	}

	public void set(String key, int value){
		ed.putInt(key, value);
	}

	public void set(String key, String value){
		ed.putString(key, value);
	}
	
	public void set(String key, boolean value){
		ed.putBoolean(key, value);
	}
	
	public String get(String key, String defValue){
		return pr.getString(key, defValue);
	}

	public int get(String key, int defValue){
		return pr.getInt(key, defValue);
	}
	
	public boolean get(String key, boolean defValue){
		return pr.getBoolean(key, defValue);
	}
	

	public String getString(String key){
		return get(key, STRING);
	}

	public int getInt(String key){
		return get(key, INT);
	}
	
	public boolean getBool(String key){
		return get(key, BOOL);
	}
	
}
