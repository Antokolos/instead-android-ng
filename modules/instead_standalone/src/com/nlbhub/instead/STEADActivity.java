package com.nlbhub.instead;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.os.PowerManager;
import android.os.storage.StorageManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;
import com.nlbhub.instead.standalone.*;
import org.libsdl.app.SDLActivity;

import java.io.File;
import java.io.IOException;

/**
 * Created by Antokolos on 29.01.16.
 */
public class STEADActivity extends org.libsdl.app.SDLActivity {
    private static ExpansionMounter expansionMounterMain = null;
    private static StorageManager storageManager = null;
    private static String game = null;
    private static String idf = null;
    private static Settings settings;
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

    /**
     * NB: use hideSystemUISafe in your code!
     */
    @TargetApi(Build.VERSION_CODES.KITKAT)
    private void hideSystemUI() {
        View mDecorView = getWindow().getDecorView();
        mDecorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_LOW_PROFILE
                | View.SYSTEM_UI_FLAG_IMMERSIVE);
    }

    public void hideSystemUISafe() {
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            hideSystemUI();
        }
    }

    /**
     * NB: use showSystemUISafe in your code!
     */
    @TargetApi(Build.VERSION_CODES.KITKAT)
    private void showSystemUI() {
        View mDecorView = getWindow().getDecorView();
        mDecorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
    }

    public void showSystemUISafe() {
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            showSystemUI();
        }
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    public boolean isSystemUIShown() {
        View mDecorView = getWindow().getDecorView();
        int vis = mDecorView.getWindowSystemUiVisibility();
        return (vis & (View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LOW_PROFILE)) == 0;
    }

    public boolean isSystemUIShownSafe() {
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            return isSystemUIShown();
        } else {
            return true;
        }
    }

    public void toggleSystemUISafe() {
        if (isSystemUIShownSafe()) {
            hideSystemUISafe();
        } else {
            showSystemUISafe();
        }
    }

    /**
     * Gets arguments for launch.
     * With side effect: hides system UI if possible
     * @return
     */
    @Override
    protected String[] getArguments() {
        final ExpansionMounter expansionMounter = getExpansionMounterMain();
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
        args[4] = (enforceResolution) ? "Y" : null; // The exact value is unimportant, if NOT null, then -hires will be added
        args[5] = getGame();
        args[6] = getIdf();
        args[7] = settings.isMusic() ? "Y" : null;  // The exact value is unimportant, if null, then -nosound will be added
        args[8] = settings.isOwntheme() ? "Y" : null;  // The exact value is unimportant, if NOT null, then -owntheme will be added
        args[9] = settings.getTheme();
        return args;
    }

    public static ExpansionMounter getExpansionMounterMain() {
        return expansionMounterMain;
    }

    public static SDLActivity getCtx() {
        return Ctx;
    }

    /*
    This method should be added to org.libsdl.app.SDLActivity
    protected KeyEvent.DispatcherState getKeyDispatcherState() {
        return mSurface.getKeyDispatcherState();
    }
    */

    public boolean processKey(KeyEvent event, int keyCode, KeyHandler keyHandler) {
        if (event.getKeyCode() == keyCode) {
            if (event.getAction() == KeyEvent.ACTION_DOWN
                    && event.getRepeatCount() == 0) {

                // Tell the framework to start tracking this event.
                getKeyDispatcherState().startTracking(event, this);
                return true;

            } else if (event.getAction() == KeyEvent.ACTION_UP) {
                getKeyDispatcherState().handleUpEvent(event);
                if (event.isTracking() && !event.isCanceled()) {
                    keyHandler.handle();
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * See http://android-developers.blogspot.ru/2009_12_01_archive.html
     * @param event
     * @return
     */
    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (processKey(event, KeyEvent.KEYCODE_BACK, new KeyHandler() {
            @Override
            public void handle() {
                toggleMenu();
            }
        })) {
            return true;
        }

        if (STEADActivity.getSettings().getOvVol()) {
            if (processKey(event, KeyEvent.KEYCODE_VOLUME_DOWN, new KeyHandler() {
                @Override
                public void handle() {
                    toggleMenu();
                }
            })) {
                return true;
            }

            if (processKey(event, KeyEvent.KEYCODE_VOLUME_UP, new KeyHandler() {
                @Override
                public void handle() {
                    toggleSystemUISafe();
                }
            })) {
                return true;
            }
        }

        return super.dispatchKeyEvent(event);
    }

    public static Settings getSettings() {
        return settings;
    }

    // Setup
    private synchronized void initExpansionManager(Context context) {
        if (expansionMounterMain == null) {
            if (storageManager == null) {
                storageManager = (StorageManager) getSystemService(STORAGE_SERVICE);
            }
            context.getObbDir().mkdir();
            expansionMounterMain = (
                    new ExpansionMounter(
                            storageManager,
                            StorageResolver.getObbFilePath(((ObbSupportedApplication) getApplication()).getMainObb(), context)
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
        KeyboardFactory.create(this, settings.getKeyboard());
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
        hideSystemUISafe();
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

    public static String getGame() {
        return game;
    }

    public static String getIdf() {
        return idf;
    }

    private interface KeyHandler {
        void handle();
    }
}
