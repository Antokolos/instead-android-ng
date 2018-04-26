package com.nlbhub.instead.launcher.simple;

import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.AssetManager;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;
import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.standalone.MainMenuAbstract;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class MainMenu extends MainMenuAbstract {

    protected LastGame lastGame = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // TODO: find more elegant solution to avoid null lastGame in above call then getLastGame() method
        lastGame = getLastGame();
        Globals.FlagSync = lastGame.getFlagSync();
        TextView email = (TextView) findViewById(R.id.email);
        email.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sendEmail();
            }
        });
    }

    protected LastGame getLastGame() {
        if (lastGame == null) {
            lastGame = new LastGame(this);
        }
        return lastGame;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.mmenu1, menu);
        return true;
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
        }
        return true;
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
        builder.setTitle(getString(R.string.app_name) + " - " + InsteadApplication.AppVer(this));
        builder.setMessage(getString(R.string.about_instead))
                .setPositiveButton(getString(R.string.ok), dialogClickListener)
                .show();
    }

    private void openMarket(){
        try {
            String url = "market://details?id=com.nlbhub.instead.launcher";
            Intent i = new Intent(Intent.ACTION_VIEW);
            i.setData(Uri.parse(url));
            startActivity(i);
        } catch (ActivityNotFoundException e){
            openUrl("https://market.android.com/details?id=com.nlbhub.instead.launcher");
        }
    }

    private void openUrl(String url){
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        startActivity(browserIntent);
    }

    protected void sendEmail() {
        String [] addr = new String[1];
        addr[0] = "antokolos@gmail.com";

        try{

            Intent sendIntent = new Intent(Intent.ACTION_SEND, Uri.parse("mailto:"));
            sendIntent.setClassName("com.google.android.gm","com.google.android.gm.ComposeActivityGmail");
            sendIntent.putExtra(Intent.EXTRA_EMAIL, addr);
            sendIntent.putExtra(Intent.EXTRA_SUBJECT, InsteadApplication.ApplicationName+" v."+InsteadApplication.AppVer(this));
            startActivity(sendIntent);

        } catch (Exception e){
            Toast.makeText(this, "Gmail not installed!", Toast.LENGTH_LONG).show();
        }
    }

    @Override
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

    @Override
    protected void deleteAdditionalAssets() {
        //	(new File(Globals.getOutFilePath(Globals.Options))).delete();
        (new File(this.getFilesDir()+"/"+Globals.GameListFileName)).delete();
        (new File(this.getFilesDir()+"/"+Globals.GameListAltFileName)).delete();
        (new File(this.getFilesDir()+"/"+Globals.NLBProjectGamesFileName)).delete();
        (new File(this.getFilesDir()+"/"+Globals.CommunityGamesFileName)).delete();
        //	lastGame.clearAll();
    }

    @Override
    protected void copyAdditionalAssets() {
        copyXml(Globals.GameListFileName);
        copyXml(Globals.GameListAltFileName);
        copyXml(Globals.NLBProjectGamesFileName);
        copyXml(Globals.CommunityGamesFileName);
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
            getLastGame().setFlagSync(Globals.FlagSync);
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


    public void showRunB() {
        if (dialog.isShowing()) {
            dialog.dismiss();
        }
        dwn = false;
        Globals.closeZip();
        Globals.FlagSync = true;
        getLastGame().setFlagSync(true);
    }
}
