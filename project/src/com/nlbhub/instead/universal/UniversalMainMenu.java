package com.nlbhub.instead.universal;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.*;
import android.widget.ListView;
import android.widget.Toast;
import com.nlbhub.instead.R;
import com.nlbhub.instead.nlb.NLBGameManager;
import com.nlbhub.instead.standalone.Globals;
import com.nlbhub.instead.standalone.MainMenu;
import com.nlbhub.instead.SDLActivity;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * @author Anton P. Kolosov
 */
public class UniversalMainMenu extends MainMenu {

    private final Handler h = new Handler();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        doCommands();
    }

    private void doCommands() {
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

    protected void showMenu(){
        List<Map<String, ListItem>> listData = new ArrayList<Map<String, ListItem>>();
        listData.add(
                addListItem(getHtmlTagForName(getString(R.string.gmlist)) + BR + getHtmlTagForSmall(getString(R.string.gmwhat)),
                R.drawable.gamelist)
        );

        listData.add(
                addListItem(getHtmlTagForName(getString(R.string.nlbgmlist)) + BR + getHtmlTagForSmall(getString(R.string.nlbgmwhat)),
                        R.drawable.nlbgames)
        );

        listData.add(
                addListItem(getHtmlTagForName(getString(R.string.favorits)) + BR + getHtmlTagForSmall(getString(R.string.favfolder)),
                R.drawable.folder_star)
        );

        listData.add(
                addListItem(getHtmlTagForName(getString(R.string.dirlist)) + BR + getHtmlTagForSmall(getString(R.string.folderop)),
                R.drawable.folder)
        );
        super.showMenu(listData);
    }

    @Override
    protected void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        switch (position) {
            case 2:
                startGM();
                break;
            case 3:
                startNLBGM();
                break;
            case 4:
                startFav();
                break;
            case 5:
                startGD();
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

    public void showRun() {
        super.showRun();
        doCommands();
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

    private void startGM() {
        if (checkInstall()) {
            Intent myIntent = new Intent(this, GameManager.class);
            startActivity(myIntent);
        } else {
            checkRC();
        }
    }

    private void startNLBGM() {
        if (checkInstall()) {
            Intent myIntent = new Intent(this, NLBGameManager.class);
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
