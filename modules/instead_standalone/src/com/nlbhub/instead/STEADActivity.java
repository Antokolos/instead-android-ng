package com.nlbhub.instead;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Point;
import android.os.Build;
import android.os.Bundle;
import android.os.PowerManager;
import android.os.storage.StorageManager;
import android.util.Log;
import android.view.*;
import android.widget.Toast;
import com.nlbhub.instead.input.Keys;
import com.nlbhub.instead.standalone.*;
import org.libsdl.app.SDLActivity;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Antokolos on 29.01.16.
 */
public class STEADActivity extends org.libsdl.app.SDLActivity {
    private ExpansionMounter expansionMounterMain = null;
    private String game = null;
    private String idf = null;
    private Settings settings;
    private SDLActivity Ctx;
    private PowerManager.WakeLock wakeLock = null;
    private KeyboardAdapter keyboardAdapter;
    private List<Point> modes;

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
     * Gets arguments for launch.
     * With side effect: hides system UI if possible
     * @return
     */
    @Override
    protected String[] getArguments() {
        final String appdata = StorageResolver.getAppDataPath(expansionMounterMain);
        final String gamespath = StorageResolver.getGamesPath(expansionMounterMain);
        final PropertiesBean properties = PropertyManager.getProperties(this);
        Settings settings = getSettings();
        boolean nativeLogEnabled = settings.isNativelog();
        boolean enforceResolution = settings.isEnforceresolution();
        String nativeLogPath = nativeLogEnabled ? StorageResolver.getDefaultProgramDir() + "/native.log" : null;
        String[] args = new String[13];
        args[0] = nativeLogPath;
        args[1] = getDataDir();
        args[2] = appdata;
        args[3] = gamespath;
        args[4] = (enforceResolution) ? "Y" : null; // The exact value is unimportant, if NOT null, then -hires will be added
        args[5] = game;
        args[6] = idf;
        args[7] = settings.isMusic() ? "Y" : null;  // The exact value is unimportant, if null, then -nosound will be added
        args[8] = settings.isOwntheme() ? "Y" : null;  // The exact value is unimportant, if NOT null, then -owntheme will be added
        args[9] = settings.getTheme();
        args[10] = StorageResolver.getThemesDirectoryPath();
        args[11] = properties.isStandalone() ? "Y" : null;
        args[12] = getModesString();
        return args;
    }

    private String getModesString() {
        int lastIdx = modes.size() - 1;
        if (lastIdx < 0) {
            return "";
        }
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < lastIdx; i++) {
            Point mode = modes.get(i);
            result.append(String.format("%dx%d", mode.x, mode.y)).append(",");
        }
        Point mode = modes.get(lastIdx);
        result.append(String.format("%dx%d", mode.x, mode.y));
        return result.toString();
     }

    public SDLActivity getCtx() {
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

        return translateKeyEvent(event);
    }

    private boolean translateKeyEvent(KeyEvent keyEvent) {
        int keyCode = keyEvent.getKeyCode();
        int action = keyEvent.getAction();
        boolean isDown = (action == KeyEvent.ACTION_DOWN) || (action == KeyEvent.ACTION_MULTIPLE);

        if (settings.getOvVol()) {
            switch (keyCode) {
                case KeyEvent.KEYCODE_VOLUME_UP:
                    if (isDown) {
                        Keys.down(KeyEvent.KEYCODE_PAGE_UP, false);
                    }
                    return true;
                case KeyEvent.KEYCODE_VOLUME_DOWN:
                    if (isDown) {
                        Keys.down(KeyEvent.KEYCODE_PAGE_DOWN, false);
                    }
                    return true;
            }
        }

        return super.dispatchKeyEvent(keyEvent);
    }

    public Settings getSettings() {
        return settings;
    }

    // Setup
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    private synchronized void initExpansionManager(Context context) {
        if (expansionMounterMain == null) {
            StorageManager storageManager = (StorageManager) getSystemService(STORAGE_SERVICE);
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

    private synchronized void initExpansionManagerSafe(Context context) {
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            initExpansionManager(context);
        }
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    private void enableHWA() {
        getWindow().setFlags(
                WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
                WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED);
    }

    private void enableHWASafe() {
        enableHWA();
    }

    protected void onCreate(Bundle savedInstanceState) {
        Ctx = this;
        Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));
        // The following line is to workaround AndroidRuntimeException: requestFeature() must be called before adding content
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        enableHWASafe();
        super.onCreate(savedInstanceState);
        settings = SettingsFactory.create(this);
        keyboardAdapter = KeyboardFactory.create(this, settings.getKeyboard());
        initExpansionManagerSafe(this);

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

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
        wakeLock = pm.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, InsteadApplication.ApplicationName);
        modes = getModes();
    }

    private List<Point> getModes() {
        List<Point> result = new ArrayList<Point>();
        Display display = getWindowManager().getDefaultDisplay();
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        int width = display.getWidth();
        int height = display.getHeight();
        result.add(new Point(width, height));
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        width = display.getWidth();
        height = display.getHeight();
        result.add(new Point(width, height));
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
        return result;
    }

    @Override
    protected void onPause() {
        if (settings.getScreenOff()) {
            wakeLock.release();
        }
        // will work even if already closed... I hope :)
        keyboardAdapter.close();
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (settings.getScreenOff()) {
            wakeLock.acquire();
        }
    }

    // C functions we call
    public static native void toggleMenu();

    private interface KeyHandler {
        void handle();
    }
}
