package com.nlbhub.instead.universal;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.app.Activity;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.view.ContextMenu;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.Toast;
import com.nlbhub.instead.R;
import com.nlbhub.instead.standalone.StorageResolver;
import com.nlbhub.instead.simple.Globals;

public class GameChooser extends Activity {
    private static final String PREFS_NAME
    = "instead-widgets";
private static final String GAME_KEY = "game_";
private static final String TITLE_KEY = "title_";

	private Handler h = new Handler();
	private List<String> dnames = new ArrayList<String>();
	private List<String> dtitles = new ArrayList<String>();	
	private LinearLayout l;
	int mAppWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID;
	  
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		setContentView(R.layout.dummy);
	    setResult(RESULT_CANCELED);
		l = (LinearLayout) findViewById(R.id.dummy);
		registerForContextMenu(l);
		
        Intent intent = getIntent();
        Bundle extras = intent.getExtras();
        if (extras != null) {
            mAppWidgetId = extras.getInt(
                    AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID);
        }
        
        if (mAppWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish();
        }
		

		
		l.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				finish();			
			}
		});

			readFolder();
	}
	
		Runnable r = new Runnable(){

			@Override
			public void run() {
				openMenu();	 
			}


			
		};
		
	@Override
	protected void onStart(){
		super.onStart();

	}


	private void openMenu(){
		this.openContextMenu(l);
	}

	

	private String getIndexMenu(String s){
		String n = null;
		for(int  i = 0; i < dnames.size(); i++){
			if(dnames.get(i).startsWith(s)){
				return dnames.get(i).substring(s.length(),dnames.get(i).length());			
			}
		}
		return n;
	}

	@Override
	public void onContextMenuClosed(Menu m) {
		finish();
	}
	
	
	@Override
	public boolean onContextItemSelected(MenuItem item) {
		  final Context context = GameChooser.this;
		
	    String title = item.getTitle().toString();
		String game = getIndexMenu(title); 
		

        saveTitlePref(context, mAppWidgetId, game, title);

        // Push widget update to surface with newly set prefix
        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
       	GameIcon.updateAppWidget(context, appWidgetManager,
                mAppWidgetId, game, title);

        // Make sure we pass back the original appWidgetId
        Intent resultValue = new Intent();
        resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, mAppWidgetId);
        setResult(RESULT_OK, resultValue);
        finish();

		return true;
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
			
			
			
private void readFolder() {

			dnames.clear();
			dtitles.clear();


				
				File f = new File(Globals.getOutFilePath(StorageResolver.GameDir));
				if(f.isDirectory()){
				if(f.list().length>0){
					String files[] = f.list();
					for (String temp : files) {
						File file = new File(f, temp);

							if(file.isDirectory()){
							    if(StorageResolver.isWorking(temp)){
							    	String title = Globals.getTitle(temp);
							    	if (title==null) title = temp;
							    	dnames.add(title+temp);
							    	dtitles.add(title);
							    }
							} else
							if(temp.endsWith(".idf")){
								dnames.add(temp+temp);
								dtitles.add(temp);
		
							} 
							
						
					}
				}
				}
				
				if(dnames.size()>0){ 
				Collections.sort(dtitles);
				h.postDelayed(r, 100);
				}else{
					Toast.makeText(this, getString(R.string.noidf), Toast.LENGTH_SHORT).show();
				finish();
				}
}	
	
	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {
		super.onCreateContextMenu(menu, v, menuInfo);
				menu.setHeaderTitle(getString(R.string.chgame));
		
		for(int i=0; i < dtitles.size(); i++){
											menu.add(0, v.getId(), 0, dtitles.get(i));	
		}				

	}

	
    // Write the prefix to the SharedPreferences object for this widget
    static void saveTitlePref(Context context, int appWidgetId, String game, String title) {
        SharedPreferences.Editor prefs = context.getSharedPreferences(PREFS_NAME, 0).edit();
        prefs.putString(GAME_KEY + appWidgetId, game);
        prefs.putString(TITLE_KEY + appWidgetId, title);
        prefs.commit();
    }

    // Read the prefix from the SharedPreferences object for this widget.
    // If there is no preference saved, get the default from a resource
    static String loadTitle(Context context, int appWidgetId) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, 0);
        String prefix = prefs.getString(TITLE_KEY + appWidgetId, null);
        if (prefix != null) {
            return prefix;
        } else {
            return context.getString(R.string.bundledgame);
        }
    }

    static String loadGame(Context context, int appWidgetId) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, 0);
        String prefix = prefs.getString(GAME_KEY + appWidgetId, null);
        if (prefix != null) {
            return prefix;
        } else {
            return StorageResolver.BundledGame;
        }
    }
    
    
    static void deleteTitlePref(Context context, int appWidgetId) {
    }

    static void loadAllTitlePrefs(Context context, ArrayList<Integer> appWidgetIds,
            ArrayList<String> game, ArrayList<String> title ) {
    }
	
}
