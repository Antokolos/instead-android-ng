package com.nlbhub.instead.nlb;

import android.app.ProgressDialog;
import com.nlbhub.instead.standalone.Globals;
import com.nlbhub.instead.universal.GameManager;
import com.nlbhub.instead.universal.XmlDownloader;

/**
 * Created by apkolosov on 6/8/15.
 */
public class NLBXmlDownloader extends XmlDownloader {
    public NLBXmlDownloader(GameManager GameManager, ProgressDialog _Status, int src) {
        super(GameManager, _Status, src);
    }

    protected String getGameListDownloadUrl() {
        return Globals.GameListNLBDemoDownloadUrl;
    }

    protected String getGameListAltDownloadUrl() {
        return Globals.GameListNLBFullDownloadUrl;
    }

    protected String getGameListFileName() {
        return Globals.GameListNLBDemosFileName;
    }

    protected String getGameListAltFileName() {
        return Globals.GameListNLBFullFileName;
    }

}
