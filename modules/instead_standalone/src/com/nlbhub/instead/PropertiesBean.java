package com.nlbhub.instead;

/**
 * @author Anton P. Kolosov
 * @version 1.0
 */
public class PropertiesBean {
    private boolean standalone = false;
    private String gameListDownloadUrl = "http://instead.syscall.ru/pool/game_list.xml";
    private String gameListAltDownloadUrl = "http://instead-games.ru/xml.php";
    private String gameListNLBDemoDownloadUrl = "http://nlbproject.com/m/services/getdemogames";
    private String gameListNLBFullDownloadUrl = "http://nlbproject.com/m/services/getfullgames";
    private boolean music = true;
    private boolean nativeLog = false;
    private boolean enforceResolution = true;
    private boolean ovVol = false;
    private boolean keyboard = false;
    private boolean screenOff = false;
    private boolean ownTheme = true;
    private boolean enforceSystemStorage = false;
    private String theme = "default";

    public boolean isStandalone() {
        return standalone;
    }

    public void setStandalone(boolean standalone) {
        this.standalone = standalone;
    }

    public String getGameListDownloadUrl() {
        return gameListDownloadUrl;
    }

    public void setGameListDownloadUrl(String gameListDownloadUrl) {
        this.gameListDownloadUrl = gameListDownloadUrl;
    }

    public String getGameListAltDownloadUrl() {
        return gameListAltDownloadUrl;
    }

    public void setGameListAltDownloadUrl(String gameListAltDownloadUrl) {
        this.gameListAltDownloadUrl = gameListAltDownloadUrl;
    }

    public String getGameListNLBDemoDownloadUrl() {
        return gameListNLBDemoDownloadUrl;
    }

    public void setGameListNLBDemoDownloadUrl(String gameListNLBDemoDownloadUrl) {
        this.gameListNLBDemoDownloadUrl = gameListNLBDemoDownloadUrl;
    }

    public String getGameListNLBFullDownloadUrl() {
        return gameListNLBFullDownloadUrl;
    }

    public void setGameListNLBFullDownloadUrl(String gameListNLBFullDownloadUrl) {
        this.gameListNLBFullDownloadUrl = gameListNLBFullDownloadUrl;
    }

    public boolean isMusic() {
        return music;
    }

    public void setMusic(boolean music) {
        this.music = music;
    }

    public boolean isNativeLog() {
        return nativeLog;
    }

    public void setNativeLog(boolean nativeLog) {
        this.nativeLog = nativeLog;
    }

    public boolean isEnforceResolution() {
        return enforceResolution;
    }

    public void setEnforceResolution(boolean enforceResolution) {
        this.enforceResolution = enforceResolution;
    }

    public boolean isOvVol() {
        return ovVol;
    }

    public void setOvVol(boolean ovVol) {
        this.ovVol = ovVol;
    }

    public boolean isKeyboard() {
        return keyboard;
    }

    public void setKeyboard(boolean keyboard) {
        this.keyboard = keyboard;
    }

    public boolean isScreenOff() {
        return screenOff;
    }

    public void setScreenOff(boolean screenOff) {
        this.screenOff = screenOff;
    }

    public boolean isOwnTheme() {
        return ownTheme;
    }

    public void setOwnTheme(boolean ownTheme) {
        this.ownTheme = ownTheme;
    }

    public boolean isEnforceSystemStorage() {
        return enforceSystemStorage;
    }

    public void setEnforceSystemStorage(boolean enforceSystemStorage) {
        this.enforceSystemStorage = enforceSystemStorage;
    }

    public String getTheme() {
        return theme;
    }

    public void setTheme(String theme) {
        this.theme = theme;
    }
}
