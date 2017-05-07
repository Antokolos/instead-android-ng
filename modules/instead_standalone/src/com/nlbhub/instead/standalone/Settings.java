package com.nlbhub.instead.standalone;

import android.content.Context;
import com.nlbhub.instead.PropertiesBean;
import com.nlbhub.instead.PropertyManager;

/**
 * Created by Antokolos on 09.10.15.
 */
public class Settings {
    private boolean music;
    private boolean nativelog;
    private boolean enforceresolution;
    private boolean ovVol;
    private boolean keyboard;
    private boolean screenOff;
    private boolean owntheme;
    private boolean enforceSystemStorage;
    private String theme;

    protected Settings() {
    }

    public void init(Context p) {
        PropertiesBean properties = PropertyManager.getProperties(p);
        music = properties.isMusic();
        nativelog = properties.isNativeLog();
        enforceresolution = properties.isEnforceResolution();
        ovVol = properties.isOvVol();
        keyboard = properties.isKeyboard();
        screenOff = properties.isScreenOff();
        owntheme = properties.isOwnTheme();
        theme = properties.getTheme();
        enforceSystemStorage = properties.isEnforceSystemStorage();
    }

    public void clearAll(Context context) {
        PropertiesBean properties = PropertyManager.getProperties(context);
        music = properties.isMusic();
        nativelog = properties.isNativeLog();
        enforceresolution = properties.isEnforceResolution();
        ovVol = properties.isOvVol();
        keyboard = properties.isKeyboard();
        screenOff = properties.isScreenOff();
        owntheme = properties.isOwnTheme();
        theme = properties.getTheme();
        enforceSystemStorage = properties.isEnforceSystemStorage();
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

    public boolean isEnforceSystemStorage() {
        return enforceSystemStorage;
    }

    public void setEnforceSystemStorage(boolean enforceSystemStorage) {
        this.enforceSystemStorage = enforceSystemStorage;
    }
}
