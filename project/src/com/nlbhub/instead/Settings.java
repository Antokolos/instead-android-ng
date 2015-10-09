package com.nlbhub.instead;

import android.content.Context;

/**
 * Created by Antokolos on 09.10.15.
 */
public class Settings {

    public static final boolean NATIVE_LOG_DEFAULT = false;
    public static final boolean ENFORCE_ORIENTATION_DEFAULT = false;
    public static final boolean ENFORCE_RESOLUTION_DEFAULT = false;
    public static final boolean OV_VOL_DEFAULT = false;
    public static final boolean KEYBOARD_DEFAULT = false;
    public static final boolean SCREEN_OFF_DEFAULT = false;
    private boolean nativelog;
    private boolean enforceorientation;
    private boolean enforceresolution;
    private boolean ovVol;
    private boolean keyboard;
    private boolean screenOff;

    public Settings() {
        nativelog = NATIVE_LOG_DEFAULT;
        enforceorientation = ENFORCE_ORIENTATION_DEFAULT;
        enforceresolution = ENFORCE_RESOLUTION_DEFAULT;
        ovVol = OV_VOL_DEFAULT;
        keyboard = KEYBOARD_DEFAULT;
        screenOff = SCREEN_OFF_DEFAULT;
    }

    public void init(Context p) {
    }

    public void clearAll() {
        nativelog = NATIVE_LOG_DEFAULT;
        enforceorientation = ENFORCE_ORIENTATION_DEFAULT;
        enforceresolution = ENFORCE_RESOLUTION_DEFAULT;
        ovVol = OV_VOL_DEFAULT;
        keyboard = KEYBOARD_DEFAULT;
        screenOff = SCREEN_OFF_DEFAULT;
    }

    public boolean isNativelog() {
        return nativelog;
    }

    public void setNativelog(boolean nativelog) {
        this.nativelog = nativelog;
    }

    public boolean isEnforceorientation() {
        return enforceorientation;
    }

    public void setEnforceorientation(boolean enforceorientation) {
        this.enforceorientation = enforceorientation;
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
}
