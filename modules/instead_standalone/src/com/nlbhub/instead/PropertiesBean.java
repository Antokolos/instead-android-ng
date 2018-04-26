package com.nlbhub.instead;

/**
 * @author Anton P. Kolosov
 * @version 1.0
 */
public class PropertiesBean {
    private boolean standalone = false;
    private String gameListDownloadUrl = "http://instead.syscall.ru/pool/game_list.xml";
    private String gameListAltDownloadUrl = "http://instead-games.ru/xml.php";
    private String gameListNLBProjectDownloadUrl = "https://nlbproject.com/hub/services/nlbproject_games";
    private String gameListCommunityDownloadUrl = "https://nlbproject.com/hub/services/community_games";

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

    public void setGameListNLBProjectDownloadUrl(String gameListNLBDemoDownloadUrl) {
        this.gameListNLBProjectDownloadUrl = gameListNLBDemoDownloadUrl;
    }

    public String getGameListCommunityDownloadUrl() {
        return gameListCommunityDownloadUrl;
    }

    public void setGameListCommunityDownloadUrl(String gameListNLBFullDownloadUrl) {
        this.gameListCommunityDownloadUrl = gameListNLBFullDownloadUrl;
    }
}
