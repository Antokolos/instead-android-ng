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
    public static final String NLB_MIRROR_DEFAULT = DownloadMirrors.NLB_DEFAULT;
    public static final String COMMUNITY_MIRROR_DEFAULT = DownloadMirrors.COMMUNITY_DEFAULT;
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
    private String nlbMirror;
    private String communityMirror;

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
        nlbMirror = NLB_MIRROR_DEFAULT;
        communityMirror = COMMUNITY_MIRROR_DEFAULT;
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
        nlbMirror = NLB_MIRROR_DEFAULT;
        communityMirror = COMMUNITY_MIRROR_DEFAULT;
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

    public String getNlbMirror() {
        return nlbMirror;
    }

    public void setNlbMirror(String nlbMirror) {
        this.nlbMirror = DownloadMirrors.normalize(nlbMirror, NLB_MIRROR_DEFAULT);
    }

    public String getCommunityMirror() {
        return communityMirror;
    }

    public void setCommunityMirror(String communityMirror) {
        this.communityMirror = DownloadMirrors.normalize(communityMirror, COMMUNITY_MIRROR_DEFAULT);
    }

    public boolean isEnforceSystemStorage() {
        return enforceSystemStorage;
    }

    public void setEnforceSystemStorage(boolean enforceSystemStorage) {
        this.enforceSystemStorage = enforceSystemStorage;
    }
}
