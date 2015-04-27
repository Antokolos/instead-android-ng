package com.silentlexx.instead;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import android.app.AlertDialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.ActivityNotFoundException;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.Html;
import android.util.Log;
import android.view.ContextMenu;
import android.view.Display;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.SimpleAdapter.ViewBinder;
import android.widget.Toast;

public class MainMenu extends ListActivity implements ViewBinder {

	private ProgressDialog dialog;
	protected boolean dwn = false;
	protected boolean onpause = false;
	private ListView listView;
	private static final String LIST_TEXT = "list_text";
	private static final String BR = "<br>";
	private  LastGame lastGame;
	private final Handler h = new Handler();
	private TextView email;
	private boolean ff = false;

	private class ListItem {
		public String text;
		public int icon;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		
		lastGame = new LastGame(this);
		Globals.FlagSync = lastGame.getFlagSync();
		dialog = new ProgressDialog(this);
		dialog.setTitle(getString(R.string.wait));
		dialog.setMessage(getString(R.string.init));
		dialog.setIndeterminate(true);
		dialog.setCancelable(false);
        setContentView(R.layout.mnhead);
        email = (TextView) findViewById(R.id.email);
        email.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				sendEmail();
			}
		});
		listView = getListView();
	//	listView.setBackgroundColor(Color.BLACK);
	//	listView.setBackgroundDrawable(this.getResources().getDrawable(
	//			R.drawable.wallpaper));
/*		if(getResX()>480) {
			LayoutParams layoutParams = new LayoutParams(480, 
			        LayoutParams.FILL_PARENT);
			listView.setLayoutParams(layoutParams);
		}
		*/
		registerForContextMenu(listView);
		showMenu();
		if (!dwn) {
			checkRC();
		} 
			if(Globals.idf!=null) IdfCopy();
			if(Globals.zip!=null) ZipInstall();
			if(Globals.qm!=null) QmInstall();
	}

	private void QmInstall() {
	 String g = Globals.matchUrl(Globals.qm, ".*\\/(.*\\.qm)");
	 String rangpath = Globals.getOutFilePath(Globals.GameDir + "rangers/"); 
	 StringBuilder stringBuilder = new StringBuilder();
	stringBuilder.append(rangpath);
	stringBuilder.append("games/");
	stringBuilder.append(g);
	String out = 	stringBuilder.toString(); 
	 if(!(new File(rangpath+Globals.MainLua)).exists()){
		 Toast.makeText(this, getString(R.string.need_rangers), Toast.LENGTH_LONG).show();
		 return;
	 }
	try {
		copyFile(Globals.qm, out);
	} catch (Exception e) {
		 Toast.makeText(this, "Copy error!", Toast.LENGTH_LONG).show();
		return;
	}
	 Globals.qm=null;
	 Toast.makeText(this, getString(R.string.rangers_inst), Toast.LENGTH_LONG).show();
	}

	private void ZipInstall() {
		DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_POSITIVE:
						loadZip();
					break;

				case DialogInterface.BUTTON_NEGATIVE:
					   Globals.zip=null;
					break;
					
				}
			}
		};

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.warning);
		builder.setTitle(getString(R.string.instzip));
		builder.setMessage(getString(R.string.instzipwarn))
				.setPositiveButton(getString(R.string.yes), dialogClickListener)
				.setNegativeButton(getString(R.string.no), dialogClickListener)
				.show();
	}

	
	
	private void loadZip() {
		dwn = true;
		ShowDialog(getString(R.string.init));
		new ZipGame(this, dialog);
	}

	private void showMenu(){
		List<Map<String, ListItem>> listData = new ArrayList<Map<String, ListItem>>();
/*
		listData.add(addListItem(getHtmlTagForName(getString(R.string.app_name))+ BR
				+ getHtmlTagForSmall(getString(R.string.start)),
				R.drawable.start));
	*/
		listData.add(addListItem(getHtmlTagForName(getString(R.string.start)),
				R.drawable.start));
		

		listData.add(addListItem(getHtmlTagForName(getString(R.string.gmlist))+
				BR+
				getHtmlTagForSmall(getString(R.string.gmwhat)),
				R.drawable.gamelist));
		
		listData.add(addListItem(getHtmlTagForName(getString(R.string.favorits))+
				BR+
				getHtmlTagForSmall(getString(R.string.favfolder)),
				R.drawable.folder_star));		
		

		
		listData.add(addListItem(getHtmlTagForName(getString(R.string.dirlist))+
				BR+
				getHtmlTagForSmall(getString(R.string.folderop)),
				R.drawable.folder));
		
		listData.add(addListItem(
				getHtmlTagForName(getString(R.string.options))+
				BR+
				getHtmlTagForSmall(getString(R.string.optwhat)),
				R.drawable.options));

		SimpleAdapter simpleAdapter = new SimpleAdapter(this, listData,
				R.layout.list_item, new String[] { LIST_TEXT },
				new int[] { R.id.list_text });
		simpleAdapter.setViewBinder(this);
		setListAdapter(simpleAdapter);
	}
	
	private String getHtmlTagForName(String s) {
		return "<b>" + s + "</b>";
	}

	private String getHtmlTagForSmall(String s) {
		return "<small><i>" + s + "</i></small>";
	}

	@Override
	protected void onListItemClick(ListView l, View v, int position, long id) {
		super.onListItemClick(l, v, position, id);
			switch (position) {
			case 0:
				startAppAlt();
				break;
			case 2:
				startFav();
				break;
			case 1:
				startGM();
				break;
				
			case 3:
				startGD();
				break;		
			case 4:
				startOpt();
				break;
			case 5:
				showAboutInstead();
				break;
			}
			

	}


	
	private void startFav() {
		if (checkInstall()) {
			Intent myIntent = new Intent(this, FavoritList.class);
			startActivity(myIntent);
		} else {
			checkRC();
		}
		
	}

	private void openMarket(){
	try {	
		String url = "market://details?id=com.silentlexx.instead";
		Intent i = new Intent(Intent.ACTION_VIEW);
		i.setData(Uri.parse(url));
		startActivity(i);
	   } catch (ActivityNotFoundException e){
		   openUrl("https://market.android.com/details?id=com.silentlexx.instead");
	   }
	}
	
    private void openUrl(String url){
    	Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
    	startActivity(browserIntent);
    }
	
	private Map<String, ListItem> addListItem(String s, int i) {
		Map<String, ListItem> iD = new HashMap<String, ListItem>();
		ListItem l = new ListItem();
		l.text = s;
		l.icon = i;
		iD.put(LIST_TEXT, l);
		return iD;
	}

	@Override
	public boolean setViewValue(View view, Object data,
			String stringRepresetation) {
		ListItem listItem = (ListItem) data;

		TextView menuItemView = (TextView) view;
		menuItemView.setText(Html.fromHtml(listItem.text));
		menuItemView.setCompoundDrawablesWithIntrinsicBounds(this
				.getResources().getDrawable(listItem.icon), null, null, null);
		return true;
	}

	private void sendEmail() {
		String [] addr = new String[1];
		addr[0] = "silentlexx@gmail.com";
		
	try{
		
		Intent sendIntent = new Intent(Intent.ACTION_SEND, Uri.parse("mailto:"));
		sendIntent.setClassName("com.google.android.gm","com.google.android.gm.ComposeActivityGmail");
		sendIntent.putExtra(Intent.EXTRA_EMAIL, addr);
		sendIntent.putExtra(Intent.EXTRA_SUBJECT, Globals.ApplicationName+" v."+Globals.AppVer(this));
		startActivity(sendIntent);

	 } catch (Exception e){
		 Toast.makeText(this, "Gmail not installed!", Toast.LENGTH_LONG).show();
	 }
	}

	public void showRun() {
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
		dwn = false;
		checkRC();
		if(Globals.idf!=null) IdfCopy();
		if(Globals.zip!=null) ZipInstall();
	    if(Globals.qm!=null) QmInstall();
	}

	public void showRunB() {
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
		dwn = false;
		Globals.zip = null;
		Globals.FlagSync = true;
		lastGame.setFlagSync(true);
	}
	
	
	private void startAppAlt() {
		if (checkInstall()) {
			Intent myIntent = new Intent(this, SDLActivity.class);
			startActivity(myIntent);
		} else {
			checkRC();
		}
	}


	private void startAppIdf() {
	 if(Globals.idf!=null){
		if (checkInstall()) {
			Intent myIntent = new Intent(this, SDLActivity.class);
			Bundle b = new Bundle();
			b.putString("idf", Globals.idf);
			Globals.idf = null;
			myIntent.putExtras(b);
			startActivity(myIntent);

		} else {
			checkRC();
		}
	 }
	}
	
	
	private void startApp(String g) {
		if (checkInstall()) {
			Intent myIntent = new Intent(this, SDLActivity.class);
			Bundle b = new Bundle();
			b.putString("game", g);
			myIntent.putExtras(b);
			startActivity(myIntent);
		} else {
			checkRC();
		}
	}

	private void startOpt() {
		if (checkInstall()) {
			Intent myIntent = new Intent(this, Options.class);
			startActivity(myIntent);
		} else {
			checkRC();
		}
	}

	private void startGM() {
		if (checkInstall()) {
			Intent myIntent = new Intent(this, GameMananger.class);
			startActivity(myIntent);
		} else {
			checkRC();
		}
	}
	
	private void startGD() {
		if (checkInstall()) {
			Intent myIntent = new Intent(this, GameDirs.class);
			startActivity(myIntent);
		} else {
			checkRC();
		}
	}

	@Override
	protected void onPause() {
		onpause = true;
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
		super.onPause();
	}

	@Override
	protected void onStop() {
		super.onStop();
	}

	@Override
	protected void onResume() {
		super.onResume();
		if (!dwn) {
			if (dialog.isShowing()) {
				dialog.dismiss();
			}
			checkRC();
		} else {
			if (onpause && !dialog.isShowing()) {
				dialog.show();
			}
		}
		onpause = false;
	}

	public void setDownGood() {
		dwn = false;
	}

	@Override
	protected void onStart() {
		super.onStart();
		// Log.d(Globals.TAG, "Main: Resume");
	}

	@Override
	protected void onDestroy() {
		// Log.d(Globals.TAG, "Main: Destroy");
		super.onDestroy();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.mmenu1, menu);
		return true;
	}

	@Override
	public void onSaveInstanceState(Bundle savedInstanceState) {
		savedInstanceState.putBoolean("onpause", onpause);
		savedInstanceState.putBoolean("dwn", dwn);
		super.onSaveInstanceState(savedInstanceState);
	}

	@Override
	public void onRestoreInstanceState(Bundle savedInstanceState) {
		super.onRestoreInstanceState(savedInstanceState);
		dwn = savedInstanceState.getBoolean("dwn");
		onpause = savedInstanceState.getBoolean("onpause");
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
	case R.id.mailme:
		sendEmail();
		break;
	case R.id.about:
		showAboutInstead();
		break;
	case R.id.market:
			openMarket();
		break;	
/*		
	case R.id.rmidf:
		  	    idf_act = DELETE_IDF;
		  	    ff = true;
				getGamesLS();
		break;	
	case R.id.runidf:
  	    idf_act = RUN_IDF;
  	    ff = true;
		getGamesLS();
break;	
*/
	}		
		return true;
	}

	public void onError(String s) {
		dialog.setCancelable(true);
		dwn = false;
		Log.e("Instead ERORR: ", s);
	}

	private void loadData() {
			dwn = true;
			ShowDialog(getString(R.string.init));
			new DataDownloader(this, dialog);
	}

	public boolean checkInstall() {
		String path = Globals.getOutFilePath(Globals.DataFlag);

		BufferedReader input = null;
		try {
			input = new BufferedReader(new InputStreamReader(
					new FileInputStream(new File(path)), "UTF-8"));
		} catch (UnsupportedEncodingException e) {
			return false;
		} catch (FileNotFoundException e) {
			return false;
		} catch (SecurityException e) {
			return false;
		}
		;

		String line;

		try {

			line = input.readLine();
			try {
				if (line.toLowerCase().matches(
						".*" + Globals.AppVer(this).toLowerCase() + ".*")) {
					input.close();
					return true;
				}
			} catch (NullPointerException e) {
				return false;
			} catch (IOException e) {
				return false;
			}
			;

		} catch (IOException e) {
			return false;
		}
		try {
			input.close();
		} catch (IOException e) {
			return false;
		}

		return false;
	}

	public void ShowDialog(String m) {
		dialog.setMessage(m);
		dialog.setCancelable(false);
		dialog.show();
	}


	private void checkRC() {
		if (checkInstall()) {
			if (!(new File(Globals.getOutFilePath(Globals.Options))).exists()) {
				CreateRC();
			}
		} else {
		//	(new File(Globals.getOutFilePath(Globals.Options))).delete();
			(new File(this.getFilesDir()+"/"+Globals.GameListFileName)).delete();
			(new File(this.getFilesDir()+"/"+Globals.GameListAltFileName)).delete();
		//	lastGame.clearAll();
			showMenu();
			loadData();
		}
		copyXml(Globals.GameListFileName);
		copyXml(Globals.GameListAltFileName);
	}

	private String getConf() {
		final String BR = "\n";
		final float xVGA = (float)320 / (float)240;
		final float HVGA = (float)480 / (float)320;
//		final float WxVGA = (float)800 / (float)480;
		
		String suff = "";
		

		suff = "-"+Globals.PORTRET_KEY.toUpperCase();
		
		
		String locale = null;
		if (Locale.getDefault().toString().equals("ru_RU")
				|| Locale.getDefault().toString().equals("ru")) {
			locale = "lang = ru\n";
		} else if (Locale.getDefault().toString().equals("uk_UA")
				|| Locale.getDefault().toString().equals("uk")) {
			locale = "lang = ua\n";
		} else if (Locale.getDefault().toString().equals("it_IT")
				|| Locale.getDefault().toString().equals("it")
				|| Locale.getDefault().toString().equals("it_CH")) {
			locale = "lang = it\n";
		} else if (Locale.getDefault().toString().equals("es_ES")
				|| Locale.getDefault().toString().equals("es")) {
			locale = "lang = es\n";
		} else if (Locale.getDefault().toString().equals("be_BE")
				|| Locale.getDefault().toString().equals("be")) {
			locale = "lang = ru\n";
		} else {
			locale = "lang = en\n";
		}

		float res = getResRatio();
		//Log.d("RES",Float.toString(res)+" == "+Float.toString(xVGA));
		String theme = null;
		if (res == xVGA) {
			theme = "theme = android-xVGA"+suff+BR;
		} else

		if (res == HVGA) {
			theme = "theme = android-HVGA"+suff+BR;
		} else
		{
			if (Build.VERSION.SDK_INT > 10 && getResX()>900 ) {
				theme = "theme = android-Tablet"+BR;
			} else {
				theme = "theme = android-WxVGA"+suff+BR;
			}
		}
//		Log.d("res", theme+" "+Float.toString(res));
		

		String s = "game = "+Globals.TutorialGame+"\nkbd = 2\nautosave = 1\nowntheme = 0\nhl = 0\nclick = 1\nmusic = 1\nfscale = 12\njustufy = 0\n"
				+ locale + theme + "\n";
		return s;
	}


	private float getResRatio() {
		Display display = getWindowManager().getDefaultDisplay();
		float x = display.getWidth();
		float y = display.getHeight();
		if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
			return y/x;
		} else {
			return x/y;
		}
	}

	private float getResX() {
		Display display = getWindowManager().getDefaultDisplay();
		return display.getWidth();
		
	}
	
	private void CreateRC() {
		String path = Globals.getOutFilePath(Globals.Options);
		if (!(new File(path)).exists()) {
			OutputStream out = null;
			byte buf[] = getConf().getBytes();
			try {
				out = new FileOutputStream(path);
				out.write(buf);
				out.close();
			} catch (FileNotFoundException e) {
			} catch (SecurityException e) {
			} catch (java.io.IOException e) {
				Log.e("Instead ERROR", "Error writing file " + path);
				return;
			};
		}

		
	}

	private void copyXml(String p){
		String path = this.getFilesDir()+"/"+p;
		File f = new File(path);
		if(!f.exists()){
			try{
				AssetManager am = this.getAssets();
				InputStream in = am.open(p, AssetManager.ACCESS_BUFFER);
				OutputStream out = new FileOutputStream(path);
				  byte[] buf = new byte[1024];
				  int len;
				  while ((len = in.read(buf)) > 0){
					  out.write(buf, 0, len);
				  }
				  in.close();
				  out.close();
				
			} catch (Exception e) {
				Log.e("Error", e.toString());
			}
			Globals.FlagSync = true;
			lastGame.setFlagSync(Globals.FlagSync);			
		}
		
	}
	
	
	private void showAboutInstead() {
		DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_POSITIVE:
					break;

				}
			}
		};

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.icon);
		builder.setTitle(getString(R.string.app_name) + " - " + Globals.AppVer(this));
		builder.setMessage(getString(R.string.about_instead))
				.setPositiveButton(getString(R.string.ok), dialogClickListener)
				.show();
	}


	
	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {
		super.onCreateContextMenu(menu, v, menuInfo);
		if (ff){

			}
			ff =false;	
			
	}


	
	
	@Override
	public boolean onContextItemSelected(MenuItem item) {

		return true;
	}
	


	
	
	private void IdfCopy(){
	
  
  /*
	  if((new File(out)).isFile()){
		   startAppIdf();
		  return;
	  }
	*/
	  
	DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_NEGATIVE:
					Globals.idf=null;
					break;
				case DialogInterface.BUTTON_POSITIVE:
					doCopy();
					break;
				case DialogInterface.BUTTON_NEUTRAL:
					startAppIdf();
					break;
				
				}
			}				
		};
		
		DialogInterface.OnCancelListener dialogCancelListener = new DialogInterface.OnCancelListener() {
			@Override
			public void onCancel(DialogInterface dialog) {
				  startAppIdf();
			}
		};
    	AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.warning);
		builder.setTitle(getString(R.string.cpidf));
		builder.setMessage(getString(R.string.cpidfwarn))
				.setPositiveButton(R.string.sand, dialogClickListener)
                .setNeutralButton(R.string.launch, dialogClickListener)		
                .setNegativeButton(R.string.cancel, dialogClickListener)
                .setOnCancelListener(dialogCancelListener)
				.show();
		
		
			}

	private void doCopy() {
		ShowDialog(getString(R.string.copy));				
				final Runnable d = new Runnable() {
					@Override
					public void run(){
					   String g = Globals.matchUrl(Globals.idf, ".*\\/(.*\\.idf)");
					   String	out  = Globals.getOutFilePath(Globals.GameDir + g);
						try {
							copyFile(Globals.idf, out);
						} catch (Exception e) {
							Log.e("Idf copy error", e.toString());
						}
						//Globals.idf = out;
						startApp(g);
					}};

					
					Thread t = new Thread(){
					@Override
					public void run(){
					h.postDelayed(d, 100);					
					}
					};
					t.start();
	}
	
	private void copyFile(String fa, String fb) throws Exception{

		File f1 = new File(fa);
		File f2 = new File(fb);
		
		  InputStream in = new FileInputStream(f1);
		  OutputStream out = new FileOutputStream(f2);

		  byte[] buf = new byte[1024];
		  int len;
		  while ((len = in.read(buf)) > 0){
		  out.write(buf, 0, len);
		  }
		  in.close();
		  out.close();
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
	}
	
}
