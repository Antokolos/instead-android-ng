package com.nlbhub.instead;

/**
 * @author Anton P. Kolosov
 * @version 1.0
 */
public class PropertiesBean {
    private boolean standalone;
    private String gameListDownloadUrl;
    private String gameListAltDownloadUrl;
    private String gameListNLBProjectDownloadUrl;
    private String gameListCommunityDownloadUrl;

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

    public String getGameListNLBProjectDownloadUrl() {
        return gameListNLBProjectDownloadUrl;
    }

    public void setGameListNLBProjectDownloadUrl(String gameListNLBProjectDownloadUrl) {
        this.gameListNLBProjectDownloadUrl = gameListNLBProjectDownloadUrl;
    }

    public String getGameListCommunityDownloadUrl() {
        return gameListCommunityDownloadUrl;
    }

    public void setGameListCommunityDownloadUrl(String gameListCommunityDownloadUrl) {
        this.gameListCommunityDownloadUrl = gameListCommunityDownloadUrl;
    }
}
