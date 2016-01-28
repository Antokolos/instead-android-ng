package com.nlbhub.instead;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.hardware.Sensor;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.PowerManager;
import android.os.storage.StorageManager;
import android.util.Log;
import android.view.*;
import android.widget.Toast;
import com.nlbhub.instead.standalone.*;
import org.libsdl.app.SDLActivity;

import java.io.File;
import java.io.IOException;

/**
 * Created by Antokolos on 29.01.16.
 */
public class STEADActivity extends org.libsdl.app.SDLActivity {
    private boolean first_run = true;
    private static ExpansionMounter expansionMounterMain = null;
    private static StorageManager storageManager = null;
    private static Display display;
    private static String game = null;
    private static String idf = null;
    private static Settings settings;
    private static KeyboardAdapter keyboardAdapter;
    private static AudioManager audioManager;
    private static SDLActivity Ctx;

    // Load the .so

    @Override
    public void loadLibraries() {
        try {
            // I'm using /data/data/myPackage/app_libs (using Ctx.getDir("libs",Context.MODE_PRIVATE); returns that path).
            String libsDirPath = Ctx.getDir("libs", Context.MODE_PRIVATE).getCanonicalPath() + "/";
            System.load(libsDirPath + "libSDL2.so");
            System.load(libsDirPath + "libSDL2_image.so");
            System.load(libsDirPath + "libsmpeg2.so");
            System.load(libsDirPath + "libSDL2_mixer.so");
            System.load(libsDirPath + "libSDL2_ttf.so");
            System.load(libsDirPath + "libmain.so");
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private String getDataDir() {
        try {
            return getDir("data",Context.MODE_PRIVATE).getCanonicalPath() + "/";
        } catch (IOException e) {
            Log.e("SDL", "Cannot retrieve data dir", e);
            throw new RuntimeException(e);
        }
    }

    @Override
    protected String[] getArguments() {
        final ExpansionMounter expansionMounter = getExpansionMounterMain();
        final String bundledGameName = StorageResolver.getBundledGameName(expansionMounter);
        lockOrientationIfNeeded(bundledGameName);
        final String appdata = StorageResolver.getAppDataPath(expansionMounter);
        final String gamespath = StorageResolver.getGamesPath(expansionMounter);
        Settings settings = getSettings();
        boolean nativeLogEnabled = settings.isNativelog();
        boolean enforceResolution = settings.isEnforceresolution();
        String nativeLogPath = nativeLogEnabled ? StorageResolver.getStorage() + InsteadApplication.ApplicationName + "/native.log" : null;
        String[] args = new String[10];
        args[0] = nativeLogPath;
        args[1] = getDataDir();
        args[2] = appdata;
        args[3] = gamespath;
        args[4] = (enforceResolution) ? getRes(bundledGameName) : "-1x-1";
        args[5] = getGame();
        args[6] = getIdf();
        args[7] = settings.isMusic() ? "Y" : null;  // The exact value is unimportant, if null, then -nosound will be added
        args[8] = settings.isOwntheme() ? "Y" : null;  // The exact value is unimportant, if NOT null, then -owntheme will be added
        args[9] = settings.getTheme();
        return args;
    }

    public static KeyboardAdapter getKeyboardAdapter(){
        return keyboardAdapter;
    }

    public static ExpansionMounter getExpansionMounterMain() {
        return expansionMounterMain;
    }

    public static SDLActivity getCtx() {
        return Ctx;
    }

    public void lockOrientationIfNeeded(final String bundledGameName) {
        if (settings.isEnforceresolution()) {
            if (isPortrait(bundledGameName)) {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            } else {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            }
        }
    }

    private boolean isPortrait(final String bundledGameName) {
        // bundled game game can be not so simple if using standalone game in obb file
        final String realBundledGameName = (game == null || StorageResolver.BundledGame.equals(game)) ? bundledGameName : game;
        return ThemeHelper.isPortrait(this, expansionMounterMain, settings, realBundledGameName, idf);
    }

    /*
    This method should be added to org.libsdl.app.SDLActivity
    protected KeyEvent.DispatcherState getKeyDispatcherState() {
        return mSurface.getKeyDispatcherState();
    }
    */

    /**
     * See http://android-developers.blogspot.ru/2009_12_01_archive.html
     * @param event
     * @return
     */
    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
            if (event.getAction() == KeyEvent.ACTION_DOWN
                    && event.getRepeatCount() == 0) {

                // Tell the framework to start tracking this event.
                getKeyDispatcherState().startTracking(event, this);
                return true;

            } else if (event.getAction() == KeyEvent.ACTION_UP) {
                getKeyDispatcherState().handleUpEvent(event);
                if (event.isTracking() && !event.isCanceled()) {
                    toggleMenu();
                    return true;

                }
            }
            return super.dispatchKeyEvent(event);
        } else {
            return super.dispatchKeyEvent(event);
        }
    }

    public static void setVol(int dvol){

        int minvol = 0;
        int maxvol = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        int curvol = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
        curvol += dvol;
        if(curvol<minvol) {
            curvol = minvol;
        } else if (curvol>maxvol){
            curvol = maxvol;
        }
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, curvol, 0);
    }

    public static Settings getSettings() {
        return settings;
    }

    // Setup
    private synchronized void initExpansionManager(Context context) {
        InsteadApplication app = (InsteadApplication) getApplication();
        if (expansionMounterMain == null) {
            if (storageManager == null) {
                storageManager = (StorageManager) getSystemService(STORAGE_SERVICE);
            }
            context.getObbDir().mkdir();
            expansionMounterMain = (
                    new ExpansionMounter(
                            storageManager,
                            StorageResolver.getObbFilePath(((InsteadApplication) getApplication()).getMainObb(context), context)
                    )
            );
            expansionMounterMain.mountExpansion();
        }
    }

    protected void onCreate(Bundle savedInstanceState) {
        Ctx = this;
        Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));
        // The following line is to workaround AndroidRuntimeException: requestFeature() must be called before adding content
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);
        settings = SettingsFactory.create(this);
        keyboardAdapter = KeyboardFactory.create(this, settings.getKeyboard());
        initExpansionManager(this);

        Intent intent = getIntent();
        if (intent.getAction()!=null) {
            game = intent.getAction();
            final boolean notWorking = !StorageResolver.isWorking(game);
            final boolean notIdf = !game.endsWith(".idf");
            final boolean notExist = !(new File(StorageResolver.getOutFilePath(StorageResolver.GameDir + game)).exists());
            if (notWorking && (notIdf || notExist)) {
                // Toast.makeText(this, getString(R.string.game)+" \""+game+"\" "+getString(R.string.ag_new), Toast.LENGTH_SHORT).show();
                // Removed i18n in order to not use the R class
                Toast.makeText(this, "Game \""+game+"\" not installed!", Toast.LENGTH_SHORT).show();
                finish();
            }
        } else {
            Bundle b = intent.getExtras();
            if(b!=null){
                game = b.getString("game");
                idf = b.getString("idf");
            }
        }

        if(!settings.getOvVol()) {
            audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
        }

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
        wakeLock = pm.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, InsteadApplication.ApplicationName);

        /*
        Let's try to remove this strange code...
        h = new Handler();

        IntentFilter filter = new IntentFilter(Intent.ACTION_USER_PRESENT);
        //filter.addAction(Intent.ACTION_SCREEN_OFF);
        //filter.addAction(Intent. ACTION_SCREEN_ON);
        mReceiver= new ScreenReceiver();
        registerReceiver(mReceiver, filter);
        */

        display = getWindowManager().getDefaultDisplay();

        //if(first_run){
        first_run=false;

        //Log.d("Game", intent.getStringExtra("game"));
        //if(idf!=null) Log.d("idf", idf);
        //if(game!=null){Log.v("SDL", "Start game: "+game); }else{Log.v("SDL", "Start default game");};
        //finish();
    }

    @Override
    public void onSaveInstanceState(Bundle savedInstanceState) {
        savedInstanceState.putBoolean("first_run", first_run);
        super.onSaveInstanceState(savedInstanceState);
    }

    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        first_run = savedInstanceState.getBoolean("first_run");
    }

    @Override
    protected void onPause() {
        if(settings.getScreenOff())wakeLock.release();
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(settings.getScreenOff())wakeLock.acquire();
    }

    // C functions we call
    public static native void toggleMenu();

    private PowerManager.WakeLock wakeLock = null;

    private static int getMin(int x, int y) {
        return (x < y) ? x : y;
    }

    private static int getMax(int x, int y) {
        return (x >= y) ? x : y;
    }

    public String getRes(final String bundledGameName) {
        int x = display.getWidth();
        int y = display.getHeight();
        int longside = getMax(x, y);
        int shortside = getMin(x, y);
        if (isPortrait(bundledGameName)) {
            return shortside + "x" + longside;
        } else {
            return longside + "x" + shortside;
        }
    }

    public static String getGame() {
        return game;
    }

    public static String getIdf() {
        return idf;
    }

    // Used in org.libsdl.app.SDLSurface.onKey()
    public static int translateKey(int keyCode) {
        int key = keyCode;

        if (STEADActivity.getSettings().getOvVol()) {
            switch (keyCode) {
                case KeyEvent.KEYCODE_VOLUME_UP:
                    key = KeyEvent.KEYCODE_DPAD_UP;
                    break;
                case KeyEvent.KEYCODE_VOLUME_DOWN:
                    key = KeyEvent.KEYCODE_DPAD_DOWN;
                    break;
            }
        } else {
            switch (keyCode) {
                case KeyEvent.KEYCODE_VOLUME_UP:
                    STEADActivity.setVol(1);
                    break;
                case KeyEvent.KEYCODE_VOLUME_DOWN:
                    STEADActivity.setVol(-1);
                    break;
            }
        }
        return key;
    }
}
