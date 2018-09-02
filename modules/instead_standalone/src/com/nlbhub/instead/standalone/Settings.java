package com.nlbhub.instead.standalone;

import android.content.Context;

/**
 * Created by Antokolos on 09.10.15.
 */
public class Settings {
    public static final boolean MUSIC_DEFAULT = true;
    public static final boolean NATIVE_LOG_DEFAULT = false;
    public static final boolean ENFORCE_RESOLUTION_DEFAULT = true;
    public static final boolean OV_VOL_DEFAULT = false;
    public static final boolean KEYBOARD_DEFAULT = false;
    public static final boolean SCREEN_OFF_DEFAULT = false;
    public static final boolean NO_CURSOR_DEFAULT = false;
    public static final boolean OWNTHEME_DEFAULT = true;
    public static final boolean ENFORCE_SYSTEM_STORAGE_DEFAULT = false;
    public static final String THEME_DEFAULT = "mobile";
    private boolean music;
    private boolean nativelog;
    private boolean enforceresolution;
    private boolean ovVol;
    private boolean keyboard;
    private boolean screenOff;
    private boolean nocursor;
    private boolean owntheme;
    private boolean enforceSystemStorage;
    private String theme;

    public Settings() {
        music = MUSIC_DEFAULT;
        nativelog = NATIVE_LOG_DEFAULT;
        enforceresolution = ENFORCE_RESOLUTION_DEFAULT;
        ovVol = OV_VOL_DEFAULT;
        keyboard = KEYBOARD_DEFAULT;
        screenOff = SCREEN_OFF_DEFAULT;
        nocursor = NO_CURSOR_DEFAULT;
        owntheme = OWNTHEME_DEFAULT;
        theme = THEME_DEFAULT;
        enforceSystemStorage = ENFORCE_SYSTEM_STORAGE_DEFAULT;
    }

    public void init(Context p) {
    }

    public void clearAll() {
        music = MUSIC_DEFAULT;
        nativelog = NATIVE_LOG_DEFAULT;
        enforceresolution = ENFORCE_RESOLUTION_DEFAULT;
        ovVol = OV_VOL_DEFAULT;
        keyboard = KEYBOARD_DEFAULT;
        screenOff = SCREEN_OFF_DEFAULT;
        nocursor = NO_CURSOR_DEFAULT;
        owntheme = OWNTHEME_DEFAULT;
        theme = THEME_DEFAULT;
        enforceSystemStorage = ENFORCE_SYSTEM_STORAGE_DEFAULT;
    }

    public boolean isMusic() {
        return music;
    }

    public void setMusic(boolean music) {
        this.music = music;
    }

    public boolean isNativelog() {
        return nativelog;
    }

    public void setNativelog(boolean nativelog) {
        this.nativelog = nativelog;
    }

    public boolean isEnforceresolution() {
        return enforceresolution;
    }

    public void setEnforceresolution(boolean enforceresolution) {
        this.enforceresolution = enforceresolution;
    }

    public boolean getOvVol() {
        return ovVol;
    }

    public void setOvVol(boolean ovVol) {
        this.ovVol = ovVol;
    }

    public boolean getKeyboard() {
        return keyboard;
    }

    public void setKeyboard(boolean keyboard) {
        this.keyboard = keyboard;
    }

    public boolean getScreenOff() {
        return screenOff;
    }

    public void setScreenOff(boolean screenOff) {
        this.screenOff = screenOff;
    }

    public boolean isNoCursor() {
        return nocursor;
    }

    public void setNoCursor(boolean nocursor) {
        this.nocursor = nocursor;
    }

    public boolean isOwntheme() {
        return owntheme;
    }

    public void setOwntheme(boolean owntheme) {
        this.owntheme = owntheme;
    }

    public String getTheme() {
        return theme;
    }

    public void setTheme(String theme) {
        this.theme = theme;
    }

    public boolean isEnforceSystemStorage() {
        return enforceSystemStorage;
    }

    public void setEnforceSystemStorage(boolean enforceSystemStorage) {
        this.enforceSystemStorage = enforceSystemStorage;
    }
}
