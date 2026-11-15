package com.nlbhub.instead;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Point;
import android.os.Build;
import android.os.Bundle;
import android.os.PowerManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.*;
import android.widget.Toast;
import android.window.OnBackInvokedDispatcher;
import com.nlbhub.instead.input.Keys;
import com.nlbhub.instead.standalone.*;
import org.libsdl.app.SDLActivity;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Created by Antokolos on 29.01.16.
 */
public class STEADActivity extends org.libsdl.app.SDLActivity {
    private String game = null;
    private String idf = null;
    private Settings settings;
    private SDLActivity Ctx;
    private PowerManager.WakeLock wakeLock = null;
    private KeyboardAdapter keyboardAdapter;

    // Load the .so

    @Override
    protected String[] getLibraries() {
        return new String[]{"SDL2", "SDL2_image", "SDL2_mixer", "SDL2_ttf", "main"};
    }

    public File getDataDir() {
        return new File(getDataDirString());
    }

    private String getDataDirString() {
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
        final String appdata = StorageResolver.getAppDataPath();
        final String gamespath = StorageResolver.getGamesPath();
        final PropertiesBean properties = PropertyManager.getProperties(this);
        Settings settings = getSettings();
        boolean nocursor = settings.isNoCursor();
        boolean nativeLogEnabled = settings.isNativelog();
        boolean enforceResolution = settings.isEnforceresolution();
        String nativeLogPath = nativeLogEnabled ? StorageResolver.getDefaultProgramDir() + "/native.log" : null;
        String[] args = new String[14];
        args[0] = nativeLogPath;
        args[1] = getDataDirString();
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
        args[12] = (nocursor) ? "Y" : null;
        args[13] = Locale.getDefault().getLanguage();
        return args;
    }

    public SDLActivity getCtx() {
        return Ctx;
    }

    protected KeyEvent.DispatcherState getKeyDispatcherState() {
        return mSurface != null ? mSurface.getKeyDispatcherState() : null;
    }

    public boolean processKey(KeyEvent event, int keyCode, KeyHandler keyHandler) {
        if (event.getKeyCode() == keyCode) {
            KeyEvent.DispatcherState state = getKeyDispatcherState();
            if (state == null) {
                return false;
            }
            if (event.getAction() == KeyEvent.ACTION_DOWN
                    && event.getRepeatCount() == 0) {

                // Tell the framework to start tracking this event.
                state.startTracking(event, this);
                return true;

            } else if (event.getAction() == KeyEvent.ACTION_UP) {
                state.handleUpEvent(event);
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

        enterImmersiveMode();
        registerBackCallback();
        getWindow().getDecorView().post(() -> Log.d("STEAD",
                "decor " + getWindow().getDecorView().getWidth() + "x"
                        + getWindow().getDecorView().getHeight() + ", surface "
                        + (mSurface == null ? "null"
                        : mSurface.getWidth() + "x" + mSurface.getHeight())));

        settings = SettingsFactory.create(this);
        keyboardAdapter = KeyboardFactory.create(this, settings.getKeyboard());

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
        if (mSurface != null) {
            Log.d("STEAD", "surface " + mSurface.getWidth() + "x" + mSurface.getHeight()
                    + ", decor " + getWindow().getDecorView().getWidth() + "x"
                    + getWindow().getDecorView().getHeight());
        }
        if (settings.getScreenOff()) {
            wakeLock.acquire();
        }
    }

    private void enterImmersiveMode() {
        Window window = getWindow();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false);
            WindowInsetsController controller = window.getInsetsController();
            if (controller != null) {
                controller.hide(WindowInsets.Type.systemBars());
                controller.setSystemBarsBehavior(
                        WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
            }
        } else {
            window.getDecorView().setSystemUiVisibility(
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            WindowManager.LayoutParams attrs = window.getAttributes();
            attrs.layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            window.setAttributes(attrs);
        }
    }

    private void registerBackCallback() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            getOnBackInvokedDispatcher().registerOnBackInvokedCallback(
                    OnBackInvokedDispatcher.PRIORITY_DEFAULT,
                    () -> {
                        SDLActivity.onNativeKeyDown(KeyEvent.KEYCODE_BACK);
                        SDLActivity.onNativeKeyUp(KeyEvent.KEYCODE_BACK);
                    });
        }
    }

    // Методы, которые вызывает instead_launcher.c (get_screen_size/rotate_*).
    public static String getScreenSize() {
        if (mSingleton == null) {
            return "0x0";
        }
        DisplayMetrics metrics = new DisplayMetrics();
        mSingleton.getWindowManager().getDefaultDisplay().getRealMetrics(metrics);
        return metrics.widthPixels + "x" + metrics.heightPixels;
    }

    public static void rotateLandscape() {
        if (mSingleton != null) {
            mSingleton.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        }
    }

    public static void rotatePortrait() {
        if (mSingleton != null) {
            mSingleton.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
    }

    public static void unlockRotation() {
        if (mSingleton != null) {
            mSingleton.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
        }
    }

    // C functions we call
    public static native void toggleMenu();

    private interface KeyHandler {
        void handle();
    }
}
