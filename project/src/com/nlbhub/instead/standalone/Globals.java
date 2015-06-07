package com.nlbhub.instead.standalone;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;
import com.nlbhub.instead.R;

public class Globals {

	public static final String ApplicationName = "Instead-NG";
	
	public static String AppVer(Context c) {
		PackageInfo pi;
		try {
			pi = c.getPackageManager().getPackageInfo(c.getPackageName(), 0);
		} catch (NameNotFoundException e) {
				e.printStackTrace();
				return "Not Found";
		}
		return pi.versionName;
	}

	//public static final String TAG = "LEXX_Activity";

	public static final int EGL_ver = 1;
	public static final String ZipName = "data.zip";
	public static final String GameListFileName = "game_list.xml";
	public static final String GameListAltFileName = "game_list_alt.xml";
    public static final String GameListNLBFileName = "game_list_nlb.xml";
    public static final String GameListNLBPaidFileName = "game_list_nlb_paid.xml";
	public static final String GameListDownloadUrl = "http://instead.syscall.ru/pool/game_list.xml";
	public static final String GameListAltDownloadUrl = "http://instead-games.ru/xml.php";
    public static final String GameListNLBFreeDownloadUrl = "http://nlbproject.com/services/getfreegames";
    public static final String GameListNLBPaidDownloadUrl = "http://nlbproject.com/services/getpaidgames";
	public static final String GameDir = "appdata/games/";
	public static final String SaveDir = "appdata/saves/";
	public static final String Options = "appdata/insteadrc";
	public static final String MainLua = "/main.lua";
	public static final String DataFlag = ".version";
	public static final String BundledGame = "bundled";
	public static final String DirURQ = "urq";
	public static final String StringURQ = "\\[URQ\\]";
	public static final String PORTRET_KEY = "portrait";
	public static final int BASIC = 1;
	public static final int ALTER = 2;
	public static final int NLBFREE = 3;
	public static final int NLBPAID = 4;
	public static final int AUTO = 0;
	public static final int PORTRAIT = 1;
	public static final int LANDSCAPE = 2;
	public static final int IN_MAX = 16;	

	//VARS
    public static boolean FlagSync = false;	
	public static String idf = null;
	public static String zip = null;
	public static String qm = null;
//	public static String game = null;
//	public static String title = null;
	
	public class Lang {
		public static final String RU = "ru";
		public static final String EN = "en";
		public static final String ALL = "";
	}

	public static String getStorage(){
		return android.os.Environment.getExternalStorageDirectory().toString()+"/";
	}

	public static String getGamePath(String f){
		return getOutFilePath(GameDir+f);
	}
	
	public static String getAutoSavePath(String f){
		return getOutFilePath(SaveDir+f+"/autosave");
	}
	
	public static String getOutFilePath(final String filename) {
		return getStorage() + Globals.ApplicationName + "/" + filename;
	};

	public static String getOutGamePath(final String filename) {
		return getStorage() + Globals.ApplicationName + "/" + GameDir + filename;
	};
	
	public static void delete(File file) {

		if (file.isDirectory()) {

			if (file.list().length == 0) {

				file.delete();

			} else {

				String files[] = file.list();

				for (String temp : files) {
					File fileDelete = new File(file, temp);
					delete(fileDelete);
				}
				if (file.list().length == 0) {
					
					try{
					file.delete();
					} catch(NullPointerException e){
						
					}
				}
			}

		} else {
			
			try{
			file.delete();
			} catch(NullPointerException e){
				
			}
		}
	}
	
	public static boolean isWorking(String f){
		String path = Globals.getOutFilePath(Globals.GameDir) + "/" + f + Globals.MainLua;		
		return (new File(path)).isFile();
	}
	

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
		String path = Globals.getOutFilePath(Globals.GameDir) + "/" + t + Globals.MainLua;
		String line = null;
		String ru = null;
		String en = null;
//		boolean urq = false;
		BufferedReader input = null;
		try {
				input = new BufferedReader(new InputStreamReader(
				new FileInputStream(new File(path)), "UTF-8"));
				for (int i =0; i < N ; i++){
					line = input.readLine();	
					if(line!=null){
						if (line.matches(".*\\$Name\\(ru\\):.*")){			
							ru = matchUrl(line, ".*\\$Name\\(ru\\):(.*)\\$");
						} else 
							if(line.matches(".*\\$Name:.*")) {
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


