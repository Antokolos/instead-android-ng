package com.nlbhub.instead.universal;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.OpenableColumns;
import com.nlbhub.instead.standalone.ContentFileData;
import com.nlbhub.instead.standalone.Globals;

public class IntentLauncher extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (getIntent().getAction().equals(Intent.ACTION_VIEW)) {
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
				// com.nlbhub.instead.standalone.MainMenu for standalone app without favourites, library etc
				// com.nlbhub.instead.universal.UniversalMainMenu for universal app
				Intent myIntent = new Intent(this, UniversalMainMenu.class);
				startActivity(myIntent);
			}		
		}
        finish();
	}
}
