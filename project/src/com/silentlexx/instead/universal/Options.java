package com.silentlexx.instead.universal;


import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
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
import com.silentlexx.instead.R;
import com.silentlexx.instead.standalone.Globals;
import com.silentlexx.instead.standalone.LastGame;

public class Options extends Activity {
	final static int VSMALL = 0;
	final static int SMALL = 8;
	final static int NORMAL = 12;
	final static int LAGE = 15;
	final static int VLAGE = 20;
	private int fsize;
	private boolean is_f = false;
	private Button sfont;
	private Button reset;
	private CheckBox music;
	private CheckBox click;
	private CheckBox ourtheme;
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

		sfont = (Button) findViewById(R.id.sfont);

		sfont.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				openContextMenu(arg0);
			}
		});

		this.registerForContextMenu(sfont);
		

		music = (CheckBox) findViewById(R.id.music);
		click = (CheckBox) findViewById(R.id.click);
		ourtheme = (CheckBox) findViewById(R.id.ourtheme);
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
		rewriteRC();
		finish();
		break;
	case R.id.cancelopt:
		finish();
		break;
	}		
		return true;
	}
	
	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {
		super.onCreateContextMenu(menu, v, menuInfo);
				
				menu.setHeaderTitle(getString(R.string.fontsize));
		
				menu.add(0, v.getId(), 0, getString(R.string.vsmall));
		
				menu.add(0, v.getId(), 0, getString(R.string.fsmall));

				menu.add(0, v.getId(), 0, getString(R.string.fnormal));

		    	menu.add(0, v.getId(), 0, getString(R.string.flage));
		    	
		    	menu.add(0, v.getId(), 0, getString(R.string.fvlage));
		    	
	}
	
	@Override
	public boolean onContextItemSelected(MenuItem item) {

		if (item.getTitle() == getString(R.string.vsmall)) {
			fsize = VSMALL;
			is_f = true;
			
		} else if (item.getTitle() == getString(R.string.fsmall)) {
			fsize = SMALL;
			is_f = true;
			
		} else if (item.getTitle() == getString(R.string.fnormal)) {
			fsize = NORMAL;
			is_f = true;
						
		} else if (item.getTitle() == getString(R.string.flage)) {
			fsize = LAGE;
			is_f = true;
						
		} else if (item.getTitle() == getString(R.string.fvlage)) {
			fsize = VLAGE;
			is_f = true;
			
		} else {
			is_f = false;
			return false;
		}

		return true;
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		readRC();
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
		lastGame.clearAll();
		(new File(Globals.getOutFilePath(Globals.DataFlag))).delete();
		(new File(Globals.getOutFilePath(Globals.Options))).delete();
		finish();
	}
	
	private void  readDir(){
		List<String> ls = new ArrayList<String>();
		File f = new File(Globals.getOutFilePath("themes"));
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

        arr = new String[ls.size()]; 
        for(int i = 0; i < ls.size(); i++){
      	  arr[i] = ls.get(i);
        }
        ls.clear();

		
	}

	public static boolean isPortrait(){
		boolean b = false;
		boolean c = true;
		String path = Globals.getOutFilePath(Globals.Options);
		BufferedReader input = null;
		try {
			input = new BufferedReader(new InputStreamReader(
					new FileInputStream(new File(path)), "UTF-8"));


			String line = null;
			while ((line = input.readLine()) != null) {

				if (line.toLowerCase().matches("owntheme\\ *=\\ *1.*")){
						c = false;
				}
				
				if (line.toLowerCase().matches("theme.*"+Globals.PORTRET_KEY.toLowerCase()+".*")) {
						b = true;
				} 
				}
	
		} catch (Exception e) {
		}
				
		if(c && b){
			return true;
		} else {
			return false;
		}
	}
	
	
	
	private void readRC() {
	/*	
		if(lastGame.getOreintation()==Globals.PORTRAIT){
			portrait.setChecked(true);
		} else {
			portrait.setChecked(false);
		}
	*/
		

		
		scroff.setChecked(lastGame.getScreenOff());
		keyb.setChecked(lastGame.getKeyboard());
		keyvol.setChecked(lastGame.getOvVol());
		
		String path = Globals.getOutFilePath(Globals.Options);
		BufferedReader input = null;
		try {
			input = new BufferedReader(new InputStreamReader(
					new FileInputStream(new File(path)), "UTF-8"));
		} catch (UnsupportedEncodingException e) {
		} catch (FileNotFoundException e) {
		}

		try {
			String line = null;
			while ((line = input.readLine()) != null) {

				try {
					if (line.toLowerCase().matches(
							"music\\ *=\\ *1.*")) {
						music.setChecked(true);
					} else
					if (line.toLowerCase().matches(
							"click\\ *=\\ *1.*")) {
						click.setChecked(true);
					} else
					if (line.toLowerCase().matches(
							"owntheme\\ *=\\ *1.*")) {
						ourtheme.setChecked(true);
					} else
					if (line.toLowerCase().matches(
							"theme.*")) {
						String tmp = line.replaceAll("\\s", "");
						String[] tokens = tmp.split("=");
						if(tokens.length==2){
							findTheme(tokens[1]);
						}

					}
				} catch (NullPointerException e) {
				}
			}

		} catch (IOException e) {
		} catch (NullPointerException e) {
		}

		try {
			input.close();
		} catch (IOException e) {
		}
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
	
	
	

	private String getOpt(boolean b) {
		if (b) {
			return "1";
		} else {
			return "0";
		}
	}

	private void rewriteRC() {
	
		lastGame.setScreenOff(scroff.isChecked());
		lastGame.setKeyboard(keyb.isChecked());
		lastGame.setOvVol(keyvol.isChecked());
		
		String path = Globals.getOutFilePath(Globals.Options);
		String rc = "";
		BufferedReader input = null;
		try {
			input = new BufferedReader(new InputStreamReader(
					new FileInputStream(new File(path)), "UTF-8"));
		} catch (UnsupportedEncodingException e) {
			Log.e("Error", e.toString());
		} catch (FileNotFoundException e) {
			Log.e("Error", e.toString());
		}

		try {
			String line = null;
			while ((line = input.readLine()) != null) {
				try {
					if (line.toLowerCase()
							.matches("music\\ *=\\ *.*")) {
						rc = rc + "music = " + getOpt(music.isChecked()) + "\n";
					} else if (line.toLowerCase().matches(
							"click\\ *=\\ *.*")) {
						rc = rc + "click = " + getOpt(click.isChecked()) + "\n";
					} else if (line.toLowerCase().matches(
							"owntheme\\ *=\\ *.*")) {
						rc = rc + "owntheme = " + getOpt(ourtheme.isChecked())	+ "\n";
					} else if (is_f && line.toLowerCase().matches(
					"fscale\\ *=\\ *.*")) {
			        	rc = rc + "fscale = " + Integer.toString(fsize) + "\n";
					} else if (line.toLowerCase().matches(
					"theme\\ *=\\ *.*")) {
			        	rc = rc + "theme = " + arr[theme] + "\n";
					}else {
						rc = rc + line + "\n";
					}

				} catch (NullPointerException e) {
				}
				;
			}

		} catch (IOException e) {
		}
		try {
			input.close();
		} catch (IOException e) {
		}

		(new File(path)).delete();

		OutputStream out = null;
		byte buf[] = rc.getBytes();
		try {
			out = new FileOutputStream(path);
			out.write(buf);
			out.close();
		} catch (FileNotFoundException e) {
		} catch (SecurityException e) {
		} catch (java.io.IOException e) {
			// Log.e("Instead ERROR", "Error writing file " + path);
			return;
		}
		;

	}

	   @Override
	   public boolean onKeyDown(int keyCode, KeyEvent event)  {
	       if (keyCode == KeyEvent.KEYCODE_BACK) {
	    		rewriteRC();   
	       }
	       return super.onKeyDown(keyCode, event);
	   }
	
}
