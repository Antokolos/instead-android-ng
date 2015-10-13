package com.nlbhub.instead.simple;


import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.Spinner;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.R;
import com.nlbhub.instead.standalone.StorageResolver;
import com.nlbhub.instead.standalone.fs.SystemPathResolver;

public class Options extends Activity {
	private Button reset;
	private CheckBox music;
	private CheckBox ourtheme;
	private CheckBox nativelog;
	private CheckBox enforceresolution;
	private CheckBox scroff;
	private CheckBox keyb;
	private CheckBox keyvol;
	private Spinner spinner;
	private LastGame lastGame;
	private int theme;
	private String arr[];
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		lastGame = new LastGame(this);
		
		setContentView(R.layout.options);

		reset = (Button) findViewById(R.id.reset);

		reset.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				resetCfgDialog();
			}
		});

		music = (CheckBox) findViewById(R.id.music);
		ourtheme = (CheckBox) findViewById(R.id.ourtheme);
        nativelog = (CheckBox) findViewById(R.id.nativelog);
		enforceresolution = (CheckBox) findViewById(R.id.enforceresolution);
		scroff = (CheckBox) findViewById(R.id.scroff);
		keyb = (CheckBox) findViewById(R.id.virtkey);
		keyvol = (CheckBox) findViewById(R.id.volkey);
		spinner =(Spinner) findViewById(R.id.spinner);
		readDir();
  		ArrayAdapter adapter = new ArrayAdapter(this, android.R.layout.simple_spinner_item, arr);
		adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
		spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener(){
		    @Override
		    public void onItemSelected(AdapterView<?> parent, View v, int position, long id) {
		    	theme = position;
		     }

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {

			}			
			
		});
		
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.opmenu1, menu);
		return true;
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
	case R.id.saveopt:
		saveOptions();
		finish();
		break;
	case R.id.cancelopt:
		finish();
		break;
	}		
		return true;
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		readOptions();
		// Log.d(Globals.TAG, "Option: Resume");
	}
	
	
	private void resetCfgDialog(){
		DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_POSITIVE:
						deleteCfg();
					break;

				case DialogInterface.BUTTON_NEGATIVE:

					break;
				}
			}
		};

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.warning);
		builder.setTitle(getString(R.string.atention));
		builder.setMessage(getString(R.string.resetsd))
				.setPositiveButton(getString(R.string.yes), dialogClickListener)
				.setNegativeButton(getString(R.string.no), dialogClickListener)
				.show();

	}
	
	private void deleteCfg(){
		(new File(this.getFilesDir()+"/"+ Globals.GameListFileName)).delete();
		(new File(this.getFilesDir()+"/"+Globals.GameListAltFileName)).delete();
		(new File(this.getFilesDir()+"/"+ Globals.GameListNLBDemosFileName)).delete();
		(new File(this.getFilesDir()+"/"+Globals.GameListNLBFullFileName)).delete();
		lastGame.clearAll();
		(new File(Globals.getOutFilePath(StorageResolver.DataFlag))).delete();
		(new File(Globals.getOutFilePath(StorageResolver.Options))).delete();
		finish();
	}
	
	private void readDir(){
		List<String> ls = getThemesList();
        arr = ls.toArray(new String[ls.size()]);
	}

	private List<String> getThemesList() {
		List<String> ls = new ArrayList<String>();
		try {
			SystemPathResolver pathResolver = new SystemPathResolver("data", getApplicationContext());
			File f = new File(pathResolver.resolvePath("themes"));
			if(f.isDirectory()){
            if(f.list().length>0){
                String files[] = f.list();
                for (String temp : files) {
                    File file = new File(f, temp);
                    if(file.isDirectory()){
                        //Log.d("DIR",temp);
                        ls.add(temp);
                    }
                }
            }
            }
		} catch (IOException e) {
			Log.e(InsteadApplication.ApplicationName, "Exception when retrieving themes list", e);
		}
		return ls;
	}

	private void readOptions() {
		nativelog.setChecked(lastGame.isNativelog());
		enforceresolution.setChecked(lastGame.isEnforceresolution());
		scroff.setChecked(lastGame.getScreenOff());
		keyb.setChecked(lastGame.getKeyboard());
		keyvol.setChecked(lastGame.getOvVol());
		music.setChecked(lastGame.isMusic());
		ourtheme.setChecked(lastGame.isOwntheme());
		findTheme(lastGame.getTheme());
	}
	
	
	private void findTheme(String s){
		for (int i=0; i < arr.length; i++){
			if(s.toLowerCase().equals(arr[i].toLowerCase())){
				theme = i;
				spinner.setSelection(theme);
				return;
			}
		}
	}

	private void saveOptions() {
        lastGame.setNativelog(nativelog.isChecked());
		lastGame.setEnforceresolution(enforceresolution.isChecked());
		lastGame.setScreenOff(scroff.isChecked());
		lastGame.setKeyboard(keyb.isChecked());
		lastGame.setOvVol(keyvol.isChecked());
		lastGame.setMusic(music.isChecked());
		lastGame.setOwntheme(ourtheme.isChecked());
		if (arr.length > 0) {
			lastGame.setTheme(arr[theme]);
		}
	}

	   @Override
	   public boolean onKeyDown(int keyCode, KeyEvent event)  {
	       if (keyCode == KeyEvent.KEYCODE_BACK) {
	    		saveOptions();
	       }
	       return super.onKeyDown(keyCode, event);
	   }
	
}
