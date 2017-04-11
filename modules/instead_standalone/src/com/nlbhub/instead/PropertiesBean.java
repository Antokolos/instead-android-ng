package com.nlbhub.instead;

/**
 * @author Anton P. Kolosov
 * @version 1.0
 */
public class PropertiesBean {
    private boolean ffi = false;
    private String gameListDownloadUrl = "http://instead.syscall.ru/pool/game_list.xml";
    private String gameListAltDownloadUrl = "http://instead-games.ru/xml.php";
    private String gameListNLBDemoDownloadUrl = "http://nlbproject.com/m/services/getdemogames";
    private String gameListNLBFullDownloadUrl = "http://nlbproject.com/m/services/getfullgames";

    public boolean isFfi() {
        return ffi;
    }

    public void setFfi(boolean ffi) {
        this.ffi = ffi;
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
}
