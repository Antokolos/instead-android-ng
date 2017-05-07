package com.nlbhub.instead.launcher.simple;


import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.*;
import android.widget.*;
import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.standalone.ExceptionHandler;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.standalone.StorageResolver;
import com.nlbhub.instead.standalone.fs.SystemPathResolver;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import static com.nlbhub.instead.standalone.StorageResolver.getThemesDirectory;

public class Options extends Activity {
    private Button reset;
    private Button sdtosys;
    private Button systosd;
    private CheckBox music;
    private CheckBox ourtheme;
    private CheckBox nativelog;
    private CheckBox enforceresolution;
    private CheckBox scroff;
    private CheckBox keyb;
    private CheckBox keyvol;
    private TextView textViewPaths;
    private CheckBox enforceSystemStorage;
    private Spinner spinner;
    private LastGame lastGame;
    private int theme;
    private String arr[];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));
        super.onCreate(savedInstanceState);
        lastGame = new LastGame(this);

        setContentView(R.layout.options);

        textViewPaths = (TextView) findViewById(R.id.textViewPaths);
        setPathsText();
        reset = (Button) findViewById(R.id.reset);

        reset.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View arg0) {
                resetCfgDialog();
            }
        });

        sdtosys = (Button) findViewById(R.id.sdtosys);
        sdtosys.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                moveFilesFromSDToSystemMemory();
            }
        });

        systosd = (Button) findViewById(R.id.systosd);
        systosd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                moveFilesFromSystemMemoryToSD();
            }
        });

        music = (CheckBox) findViewById(R.id.music);
        ourtheme = (CheckBox) findViewById(R.id.ourtheme);
        nativelog = (CheckBox) findViewById(R.id.nativelog);
        enforceresolution = (CheckBox) findViewById(R.id.enforceresolution);
        scroff = (CheckBox) findViewById(R.id.scroff);
        keyb = (CheckBox) findViewById(R.id.virtkey);
        enforceSystemStorage = (CheckBox) findViewById(R.id.enforceSystemStorage);
        keyvol = (CheckBox) findViewById(R.id.volkey);
        spinner = (Spinner) findViewById(R.id.spinner);
        readDir();
        ArrayAdapter adapter = new ArrayAdapter(this, android.R.layout.simple_spinner_item, arr);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View v, int position, long id) {
                theme = position;
            }

            @Override
            public void onNothingSelected(AdapterView<?> arg0) {

            }

        });

    }

    private void setPathsText() {
        try {
            File programDirInSystemMemory = new File(StorageResolver.getProgramDirInSystemMemory());
            File programDirOnSDCard = new File(StorageResolver.getProgramDirOnSDCard());
            textViewPaths.setText(String.format("System path\t: %s\nSD-card path\t: %s", programDirInSystemMemory.getCanonicalPath(), programDirOnSDCard.getCanonicalPath()));
        } catch (IOException e) {
            textViewPaths.setText("Error when retrieving paths!");
        }
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

    private void resetCfgDialog() {
        showDialog(getString(R.string.resetsd), new Task() {
            @Override
            public void run() {
                deleteCfg();
            }
        });
    }

    private void moveFilesFromSDToSystemMemory() {
        showDialog(getString(R.string.sdtosys_msg), new Task() {
            @Override
            public void run() {
                try {
                    File programDirInSystemMemory = new File(StorageResolver.getProgramDirInSystemMemory());
                    File programDirOnSDCard = new File(StorageResolver.getProgramDirOnSDCard());
                    if (!programDirOnSDCard.exists()) {
                        return;
                    }
                    if (programDirInSystemMemory.exists()) {
                        if (programDirInSystemMemory.getCanonicalPath().equalsIgnoreCase(programDirOnSDCard.getCanonicalPath())) {
                            return;
                        }
                        FileUtils.deleteDirectory(programDirInSystemMemory);
                    } else {
                        new File(StorageResolver.getSystemStorage()).mkdirs();
                    }

                    FileUtils.moveDirectory(programDirOnSDCard, programDirInSystemMemory);
                } catch (IOException e) {
                    Log.e(InsteadApplication.ApplicationName, "I/O Error", e);
                }
            }
        });
    }

    private void moveFilesFromSystemMemoryToSD() {
        showDialog(getString(R.string.systosd_msg), new Task() {
            @Override
            public void run() {
                try {
                    File programDirInSystemMemory = new File(StorageResolver.getProgramDirInSystemMemory());
                    File programDirOnSDCard = new File(StorageResolver.getProgramDirOnSDCard());
                    if (!programDirInSystemMemory.exists()) {
                        return;
                    }
                    if (programDirOnSDCard.exists()) {
                        if (programDirInSystemMemory.getCanonicalPath().equalsIgnoreCase(programDirOnSDCard.getCanonicalPath())) {
                            return;
                        }
                        FileUtils.deleteDirectory(programDirOnSDCard);
                    } else {
                        new File(StorageResolver.getExternalStorage()).mkdirs();
                    }

                    FileUtils.moveDirectory(programDirInSystemMemory, programDirOnSDCard);
                } catch (IOException e) {
                    Log.e(InsteadApplication.ApplicationName, "I/O Error", e);
                }
            }
        });
    }

    private void showDialog(final String message, final Task task) {
        DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case DialogInterface.BUTTON_POSITIVE:
                        task.run();
                        break;

                    case DialogInterface.BUTTON_NEGATIVE:
                        break;
                }
            }
        };

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setIcon(R.drawable.warning);
        builder.setTitle(getString(R.string.atention));
        builder.setMessage(message)
                .setPositiveButton(getString(R.string.yes), dialogClickListener)
                .setNegativeButton(getString(R.string.no), dialogClickListener)
                .show();
    }

    private void deleteCfg() {
        SystemPathResolver dataResolver = new SystemPathResolver("data", this);
        (new File(this.getFilesDir() + "/" + Globals.GameListFileName)).delete();
        (new File(this.getFilesDir() + "/" + Globals.GameListAltFileName)).delete();
        (new File(this.getFilesDir() + "/" + Globals.GameListNLBDemosFileName)).delete();
        (new File(this.getFilesDir() + "/" + Globals.GameListNLBFullFileName)).delete();
        lastGame.clearAll(this);
        try {
            StorageResolver.delete(dataResolver.getPath() + StorageResolver.DataFlag);
        } catch (IOException e) {
            Log.e(InsteadApplication.ApplicationName, "Error while deleting " + StorageResolver.DataFlag, e);
        }
        (new File(Globals.getOutFilePath(StorageResolver.Options))).delete();
        finish();
    }

    private void readDir() {
        List<String> ls = getThemesList();
        arr = ls.toArray(new String[ls.size()]);
    }

    private List<String> getThemesList() {
        List<String> ls = new ArrayList<String>();
        try {
            File f = getThemesDirectory();
            if (f.isDirectory()) {
                if (f.list().length > 0) {
                    String files[] = f.list();
                    for (String temp : files) {
                        File file = new File(f, temp);
                        if (file.isDirectory()) {
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
        enforceSystemStorage.setChecked(lastGame.isEnforceSystemStorage());
        findTheme(lastGame.getTheme());
    }


    private void findTheme(String s) {
        for (int i = 0; i < arr.length; i++) {
            if (s.toLowerCase().equals(arr[i].toLowerCase())) {
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
        lastGame.setEnforceSystemStorage(enforceSystemStorage.isChecked());
        if (arr.length > 0) {
            lastGame.setTheme(arr[theme]);
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            saveOptions();
        }
        return super.onKeyDown(keyCode, event);
    }
}
