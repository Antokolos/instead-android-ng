package com.silentlexx.instead.universal;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.silentlexx.instead.standalone.Globals;

public class IntentLauncher extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if(getIntent().getAction().equals(Intent.ACTION_VIEW)){
			String u = getIntent().getData().getEncodedPath();
			boolean run = false;
			Globals.idf = null;
			Globals.zip = null;
			Globals.qm = null;
			if(u.endsWith(".idf")){
				run = true;
				Globals.idf = u;
			} else if(u.endsWith(".zip")){
				run = true;
				Globals.zip = u;
			}  else if(u.endsWith(".qm")){
				run = true;
				Globals.qm = u;
			}  
			if(run){
				try {
                    // com.silentlexx.instead.standalone.MainMenu for standalone app without favourites, library etc
                    // com.silentlexx.instead.universal.UniversalMainMenu for universal app
					Intent myIntent = new Intent(this, Class.forName("com.silentlexx.instead.standalone.MainMenu"));
					startActivity(myIntent);
				} catch (ClassNotFoundException e) {
					// TODO: report error
					throw new RuntimeException(e);
				}
			}		
		}
        finish();
		
		
	}
}
