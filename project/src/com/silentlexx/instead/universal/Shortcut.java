package com.silentlexx.instead.universal;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Parcelable;
import android.view.ContextMenu;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.ContextMenu.ContextMenuInfo;
import android.widget.LinearLayout;
import android.widget.Toast;
import com.silentlexx.instead.R;
import com.silentlexx.instead.standalone.Globals;
import com.silentlexx.instead.SDLActivity;

public class Shortcut extends Activity {
	private Handler h = new Handler();
	private List<String> dnames = new ArrayList<String>();
	private List<String> dtitles = new ArrayList<String>();	
	private LinearLayout l;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        final Intent intent = getIntent();
        final String action = intent.getAction();


		requestWindowFeature(Window.FEATURE_NO_TITLE);

		setContentView(R.layout.dummy);
        
    
		l = (LinearLayout) findViewById(R.id.dummy);
		registerForContextMenu(l);

		l.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				finish();			
			}
		});

    	readFolder();
    	
        if (Intent.ACTION_CREATE_SHORTCUT.equals(action)) {
			h.postDelayed(r, 100);
            return;
        }


        String game = intent.getStringExtra(Globals.ApplicationName);
        
        startApp(game);
		
		finish();
	}
	
	
	private void startApp(String game) {
		  if(Globals.isWorking(game) || (game.endsWith(".idf") && 
				  (new File(Globals.getOutFilePath(Globals.GameDir
		    				+ game)).exists()))){	
			Intent myIntent = new Intent(this, SDLActivity.class);
			Bundle b = new Bundle();
			b.putString("game", game);
			myIntent.putExtras(b);
			startActivity(myIntent);
		  } else {
				Toast.makeText(this, getString(R.string.game)+" \""+game+"\" "+getString(R.string.ag_new), 
						Toast.LENGTH_SHORT).show();			  
		  }

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

	    String title = item.getTitle().toString();
	    String game = getIndexMenu(title); 
		
		setupShortcut(title, game);    

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


				
				File f = new File(Globals.getOutFilePath(Globals.GameDir));
				if(f.isDirectory()){
				if(f.list().length>0){
					String files[] = f.list();
					for (String temp : files) {
						File file = new File(f, temp);

							if(file.isDirectory()){
							    if(Globals.isWorking(temp)){	
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
				}else{
					Toast.makeText(this, getString(R.string.noidf), Toast.LENGTH_SHORT).show();
				finish();
				}
}	
	
Runnable r = new Runnable(){

	@Override
	public void run() {
		openMenu();	 
	}


	
};

	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {
		super.onCreateContextMenu(menu, v, menuInfo);
				menu.setHeaderTitle(getString(R.string.chgame));
		
		for(int i=0; i < dtitles.size(); i++){
											menu.add(0, v.getId(), 0, dtitles.get(i));	
		}				

	}

	
	
    private void setupShortcut(String name, String game) {
    	
        Intent shortcutIntent = new Intent(Intent.ACTION_MAIN);
        shortcutIntent.setClassName(this, this.getClass().getName());
        shortcutIntent.putExtra(Globals.ApplicationName, game);

        Intent intent = new Intent();
        intent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, shortcutIntent);
        intent.putExtra(Intent.EXTRA_SHORTCUT_NAME, name);
        Parcelable iconResource = Intent.ShortcutIconResource.fromContext(
                this,  Globals.getIcon(game));
        intent.putExtra(Intent.EXTRA_SHORTCUT_ICON_RESOURCE, iconResource);

        setResult(RESULT_OK, intent);
    }
}
