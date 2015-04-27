package com.silentlexx.instead;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

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
				Intent myIntent = new Intent(this, MainMenu.class);
				startActivity(myIntent);
			}		
		}
        finish();
		
		
	}
}
