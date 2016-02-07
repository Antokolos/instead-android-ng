package com.nlbhub.instead.standalone;

import android.content.Context;

/**
 * Created by Antokolos on 09.10.15.
 */
public class Settings {
    public static final boolean MUSIC_DEFAULT = true;
    public static final boolean NATIVE_LOG_DEFAULT = false;
    public static final boolean ENFORCE_RESOLUTION_DEFAULT = true;
    public static final boolean OV_VOL_DEFAULT = true;
    public static final boolean KEYBOARD_DEFAULT = false;
    public static final boolean SCREEN_OFF_DEFAULT = false;
    public static final boolean OWNTHEME_DEFAULT = true;
    public static final String THEME_DEFAULT = "default";
    private boolean music;
    private boolean nativelog;
    private boolean enforceresolution;
    private boolean ovVol;
    private boolean keyboard;
    private boolean screenOff;
    private boolean owntheme;
    private String theme;

    public Settings() {
        music = MUSIC_DEFAULT;
        nativelog = NATIVE_LOG_DEFAULT;
        enforceresolution = ENFORCE_RESOLUTION_DEFAULT;
        ovVol = OV_VOL_DEFAULT;
        keyboard = KEYBOARD_DEFAULT;
        screenOff = SCREEN_OFF_DEFAULT;
        owntheme = OWNTHEME_DEFAULT;
        theme = THEME_DEFAULT;
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
        owntheme = OWNTHEME_DEFAULT;
        theme = THEME_DEFAULT;
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
}
