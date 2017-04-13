package com.nlbhub.instead.launcher.universal.nlb;

import android.app.ProgressDialog;
import com.nlbhub.instead.PropertiesBean;
import com.nlbhub.instead.PropertyManager;
import com.nlbhub.instead.launcher.simple.Globals;
import com.nlbhub.instead.launcher.universal.GameManager;
import com.nlbhub.instead.launcher.universal.XmlDownloader;

/**
 * Created by apkolosov on 6/8/15.
 */
public class NLBXmlDownloader extends XmlDownloader {
    public NLBXmlDownloader(GameManager GameManager, ProgressDialog _Status, int src) {
        super(GameManager, _Status, src);
    }

    protected String getGameListDownloadUrl(PropertiesBean properties) {
        return properties.getGameListNLBDemoDownloadUrl();
    }

    protected String getGameListAltDownloadUrl(PropertiesBean properties) {
        return properties.getGameListNLBFullDownloadUrl();
    }

    protected String getGameListFileName() {
        return Globals.GameListNLBDemosFileName;
    }

    protected String getGameListAltFileName() {
        return Globals.GameListNLBFullFileName;
    }

}
