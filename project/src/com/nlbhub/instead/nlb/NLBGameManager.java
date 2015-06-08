package com.nlbhub.instead.nlb;

import com.nlbhub.instead.R;
import com.nlbhub.instead.standalone.Globals;
import com.nlbhub.instead.universal.GameManager;
import com.nlbhub.instead.universal.XmlDownloader;

/**
 * @author Anton P. Kolosov
 */
public class NLBGameManager extends GameManager {
    @Override
    protected int getBasicListNo() {
        return Globals.NLBDEMO;
    }

    @Override
    protected int getAlterListNo() {
        return Globals.NLBFULL;
    }

    protected int getLayoutResID() {
        return R.layout.nlbgmtab;
    }

    @Override
    protected String getGameListFileName() {
        return Globals.GameListNLBDemosFileName;
    }

    @Override
    protected String getGameListAltFileName() {
        return Globals.GameListNLBFullFileName;
    }

    @Override
    protected void createAndRunXmlDownloader() {
        new NLBXmlDownloader(this, getDialog(), getListNo());
    }
}
