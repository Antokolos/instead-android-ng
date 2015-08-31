package com.nlbhub.instead.standalone;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.storage.StorageManager;
import android.text.Html;
import android.util.Log;
import android.view.*;
import android.widget.*;
import android.widget.SimpleAdapter.ViewBinder;
import com.nlbhub.instead.R;
import com.nlbhub.instead.SDLActivity;

import java.io.*;
import java.util.*;

public class MainMenu extends ListActivity implements ViewBinder {
    protected boolean onpause = false;
    protected boolean dwn = false;
    protected ProgressDialog dialog;
    protected LastGame lastGame;
    protected static final String BR = "<br>";
    private static final String LIST_TEXT = "list_text";


	protected class ListItem {
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
        TextView email = (TextView) findViewById(R.id.email);
        email.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                sendEmail();
            }
        });
        ListView listView = getListView();
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
    }

    protected void sendEmail() {
        String [] addr = new String[1];
        addr[0] = "antokolos@gmail.com";

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

    protected String getHtmlTagForName(String s) {
        return "<b>" + s + "</b>";
    }

    protected String getHtmlTagForSmall(String s) {
        return "<small><i>" + s + "</i></small>";
    }

    protected void showMenu() {
        showMenu(new ArrayList<Map<String, ListItem>>());
    }

    protected void showMenu(List<Map<String, ListItem>> additionalListData) {
        List<Map<String, ListItem>> listData = new ArrayList<Map<String, ListItem>>();
/*
		listData.add(addListItem(getHtmlTagForName(getString(R.string.app_name))+ BR
				+ getHtmlTagForSmall(getString(R.string.start)),
				R.drawable.start));
	*/
        listData.add(addListItem(getHtmlTagForName(getString(R.string.start)), R.drawable.start));

        listData.add(addListItem(
                getHtmlTagForName(getString(R.string.options))+ BR + getHtmlTagForSmall(getString(R.string.optwhat)),
                R.drawable.options)
        );

        listData.addAll(additionalListData);

        SimpleAdapter simpleAdapter = (
                new SimpleAdapter(
                        this,
                        listData,
                        R.layout.list_item, new String[] { LIST_TEXT },
                        new int[] { R.id.list_text }
                )
        );
        simpleAdapter.setViewBinder(this);
        setListAdapter(simpleAdapter);
    }

    @Override
    protected void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        // TODO: where is showAboutInstead() list item???
        switch (position) {
            case 0:
                startAppAlt();
                break;
            case 1:
                startOpt();
                break;
            /*case 2:
                showAboutInstead();
                break;*/
        }
    }

    protected Map<String, ListItem> addListItem(String s, int i) {
        Map<String, ListItem> iD = new HashMap<String, ListItem>();
        ListItem l = new ListItem();
        l.text = s;
        l.icon = i;
        iD.put(LIST_TEXT, l);
        return iD;
    }

    private void startAppAlt() {
        if (checkInstall()) {
            Intent myIntent = new Intent(this, SDLActivity.class);
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

    protected void checkRC() {
        if (checkInstall()) {
            if (!(new File(Globals.getOutFilePath(Globals.Options))).exists()) {
                CreateRC();
            }
        } else {
            //	(new File(Globals.getOutFilePath(Globals.Options))).delete();
            (new File(this.getFilesDir()+"/"+Globals.GameListFileName)).delete();
            (new File(this.getFilesDir()+"/"+Globals.GameListAltFileName)).delete();
            (new File(this.getFilesDir()+"/"+Globals.GameListNLBDemosFileName)).delete();
            (new File(this.getFilesDir()+"/"+Globals.GameListNLBFullFileName)).delete();
            //	lastGame.clearAll();
            showMenu();
            loadData();
        }
        copyXml(Globals.GameListFileName);
        copyXml(Globals.GameListAltFileName);
        copyXml(Globals.GameListNLBDemosFileName);
        copyXml(Globals.GameListNLBFullFileName);
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
                Log.e("Instead-NG ERROR", "Error writing file " + path);
                return;
            };
        }


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


        String s = "game = "+Globals.BundledGame +"\nkbd = 2\nautosave = 1\nowntheme = 1\nhl = 0\nclick = 1\nmusic = 1\nfscale = 12\njustify = 0\n"
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

    private void loadData() {
        dwn = true;
        ShowDialog(getString(R.string.init));
        new DataDownloader(this, dialog);
    }

    public void ShowDialog(String m) {
        dialog.setMessage(m);
        dialog.setCancelable(false);
        dialog.show();
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

    protected void showAboutInstead() {
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
    protected void onPause() {
        onpause = true;
        if (dialog.isShowing()) {
            dialog.dismiss();
        }
        super.onPause();
    }

    public void setDownGood() {
        dwn = false;
    }

    public void onError(String s) {
        dialog.setCancelable(true);
        dwn = false;
        Log.e("Instead-NG ERROR: ", s);
    }

    public void showRun() {
        if (dialog.isShowing()) {
            dialog.dismiss();
        }
        dwn = false;
        checkRC();
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

    public boolean isOnpause() {
        return onpause;
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

    @Override
    public void onCreateContextMenu(ContextMenu menu, View v,
                                    ContextMenu.ContextMenuInfo menuInfo) {
        super.onCreateContextMenu(menu, v, menuInfo);

    }

    @Override
    public boolean onContextItemSelected(MenuItem item) {

        return true;
    }

    private void openMarket(){
        try {
            String url = "market://details?id=com.nlbhub.instead";
            Intent i = new Intent(Intent.ACTION_VIEW);
            i.setData(Uri.parse(url));
            startActivity(i);
        } catch (ActivityNotFoundException e){
            openUrl("https://market.android.com/details?id=com.nlbhub.instead");
        }
    }

    private void openUrl(String url){
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        startActivity(browserIntent);
    }
}
