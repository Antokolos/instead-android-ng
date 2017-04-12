package com.nlbhub.instead.launcher.simple;

import android.util.Log;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.standalone.StorageResolver;

import java.io.*;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static com.nlbhub.instead.standalone.StorageResolver.*;

public class Globals {

	//public static final String TAG = "LEXX_Activity";

	public static final int EGL_ver = 1;
	public static final String ZipName = "data.zip";
	public static final String GameListFileName = "game_list.xml";
	public static final String GameListAltFileName = "game_list_alt.xml";
    public static final String GameListNLBDemosFileName = "game_list_nlb_demos.xml";
    public static final String GameListNLBFullFileName = "game_list_nlb_full.xml";
	public static final String DirURQ = "urq";
	public static final String StringURQ = "\\[URQ\\]";
	public static final String PORTRET_KEY = "portrait";
	public static final int BASIC = 1;
	public static final int ALTER = 2;
	public static final int NLBDEMO = 3;
	public static final int NLBFULL = 4;
	public static final int AUTO = 0;
	public static final int PORTRAIT = 1;
	public static final int LANDSCAPE = 2;

	//VARS
    public static boolean FlagSync = false;	
	public static ContentFileData idf = null;
	public static ContentFileData zip = null;
	public static ContentFileData qm = null;

//	public static String game = null;
//	public static String title = null;
	
	public class Lang {
		public static final String RU = "ru";
		public static final String EN = "en";
		public static final String ALL = "";
	}

	public static void closeIdf() {
		if (idf != null) {
			idf.close();
			idf = null;
		}
	}

	public static void closeZip() {
		if (zip != null) {
			zip.close();
			zip = null;
		}
	}

	public static void closeQm() {
		if (qm != null) {
			qm.close();
			qm = null;
		}
	}

	public static String getStorage(){
		return StorageResolver.getStorage();
	}

	public static String getGamePath(String f){
		return getOutFilePath(GameDir+f);
	}
	
	public static String getAutoSavePath(String f){
		return getOutFilePath(SaveDir+f+"/autosave");
	}

	// TODO: move all similar methods to StorageResolver
	public static String getOutFilePath(final String filename) {
		return StorageResolver.getOutFilePath(filename);
	};

    public static String getOutFilePath(final String subDir, final String filename) {
        return StorageResolver.getOutFilePath(subDir, filename);
    };

	public static Map<String, String> getOutFilePaths(final String subDir, final String[] filenames) {
		Map<String, String> result = new HashMap<String, String>();
		for (String filename : filenames) {
			result.put(filename, StorageResolver.getOutFilePath(subDir, filename));
		}
		return result;
	};

	public static String getOutGamePath(final String filename) {
		return getProgramDirOnSD() + "/" + GameDir + filename;
	};

	public static String getTitle(String t){
		final int N = 6;
		String lang = Lang.EN;
		if (       Locale.getDefault().toString().equals("ru_RU")
				|| Locale.getDefault().toString().equals("ru") 
				|| Locale.getDefault().toString().equals("uk_UA")
				|| Locale.getDefault().toString().equals("uk")
				|| Locale.getDefault().toString().equals("be_BE")
				|| Locale.getDefault().toString().equals("be")) {
			 lang = Lang.RU;
		}
		Map<String, String> paths = Globals.getOutFilePaths(GameDir + "/" + t, MainLuaFiles);
		String line = null;
		String ru = null;
		String en = null;
//		boolean urq = false;
		BufferedReader input = null;
		try {
			for (String path : paths.values()) {
				File file = new File(path);
				if (!file.exists()) {
					continue;
				}
				input = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
				for (int i = 0; i < N; i++) {
					line = input.readLine();
					if (line != null) {
						if (line.matches(".*\\$Name\\(ru\\):.*")) {
							ru = matchUrl(line, ".*\\$Name\\(ru\\):(.*)\\$");
						} else if (line.matches(".*\\$Name:.*")) {
							en = matchUrl(line, ".*\\$Name:(.*)\\$");
						}
							/*
							else if (line.matches(".*urq.lua.*")) {
								urq = true;
							}
							*/
					}
				}
				input.close();
				break;
			}
		} catch (Exception e) {
			Log.e("INSTEAD","Title 1", e);
			return t;
		} 
		String s = null;
	try {

		if(lang.equals(Lang.RU) && ru!=null) {
			s = ru;
		} else if(en!=null){
			s = en;
		} else {
			s = t;
		}
			
		while(s.startsWith(" ")){
			s = s.substring(1, s.length());
		} 
		}  catch (Exception e){
			Log.e("INSTEAD","Title 2", e);
			return t;
		}
	
		//if(urq) s= "[URQ] "+s;
		return s;
	}
	
	public static String matchUrl(String url, String patt){
		Matcher m;  
	try{
		m = Pattern.compile(patt).matcher(url);
	  } catch(NullPointerException e){
		  return null;
	  }
		
		if(m.find()) return	m.toMatchResult().group(1);
		return null;
    }
	
	public static int getIcon(String game){
		int ico;
    	if(game.endsWith(".idf")) {
			ico = R.drawable.idf48;
		} else if(game.equals("rangers")){
			ico = R.drawable.rangers48;
		} else if(game.equals("urq")){
			ico = R.drawable.urq48;
		}   else		{
			ico = R.drawable.game48; 
		}
    	return ico;
	}
	
	
}


