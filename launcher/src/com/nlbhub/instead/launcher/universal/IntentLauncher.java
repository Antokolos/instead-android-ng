package com.nlbhub.instead.launcher.universal;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.nlbhub.instead.launcher.simple.ContentFileData;
import com.nlbhub.instead.launcher.simple.Globals;
import com.nlbhub.instead.standalone.ExceptionHandler;

public class IntentLauncher extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));
		super.onCreate(savedInstanceState);
		Intent intent = getIntent();
		String action = intent.getAction();
		String type = intent.getType();
		if (type != null && (Intent.ACTION_VIEW.equals(action) || Intent.ACTION_SEND.equals(action))) {
			ContentFileData contentFileData = new ContentFileData(getContentResolver(), getIntent().getData());
			boolean run = false;
			Globals.closeIdf();
			Globals.closeZip();
			Globals.closeQm();
			if(contentFileData.isIdf()){
				run = true;
				Globals.idf = contentFileData.open();
			} else if(contentFileData.isZip()){
				run = true;
				Globals.zip = contentFileData.open();
			}  else if(contentFileData.isQm()){
				run = true;
				Globals.qm = contentFileData.open();
			}  
			if (run) {
				// com.nlbhub.instead.simple.MainMenu for standalone app without favourites, library etc
				// com.nlbhub.instead.universal.UniversalMainMenu for universal app
				Intent myIntent = new Intent(this, UniversalMainMenu.class);
				startActivity(myIntent);
			}		
		}
        finish();
	}
}
