package com.nlbhub.instead;

import java.util.HashMap;
import java.util.Map;

/**
 * @author Anton P. Kolosov
 * @version 1.0
 */
public class PropertiesBean {
    public static final boolean STANDALONE = false;
    public static final String GAME_LIST_DOWNLOAD_URL = "http://instead.syscall.ru/pool/game_list.xml";
    public static final String GAME_LIST_ALT_DOWNLOAD_URL = "http://instead-games.ru/xml.php";
    public static final String GAME_LIST_NLBPROJECT_DOWNLOAD_URL = "https://nlbproject.com/hub/services/nlbproject_games";
    public static final String GAME_LIST_COMMUNITY_DOWNLOAD_URL = "https://nlbproject.com/hub/services/community_games";

    private boolean standalone = STANDALONE;
    private String gameListDownloadUrl = GAME_LIST_DOWNLOAD_URL;
    private String gameListAltDownloadUrl = GAME_LIST_ALT_DOWNLOAD_URL;
    private String gameListNLBProjectDownloadUrl = GAME_LIST_NLBPROJECT_DOWNLOAD_URL;
    private String gameListCommunityDownloadUrl = GAME_LIST_COMMUNITY_DOWNLOAD_URL;

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
