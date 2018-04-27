package com.nlbhub.instead.launcher.universal.nlb;

import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.launcher.simple.Globals;
import com.nlbhub.instead.launcher.universal.GameManager;

/**
 * @author Anton P. Kolosov
 */
public class NLBGameManager extends GameManager {
    @Override
    protected int getBasicListNo() {
        return Globals.NLBPROJECT_GAMES;
    }

    @Override
    protected int getAlterListNo() {
        return Globals.COMMUNITY_GAMES;
    }

    protected int getLayoutResID() {
        return R.layout.nlbgmtab;
    }

    @Override
    protected String getGameListFileName() {
        return Globals.NLBProjectGamesFileName;
    }

    @Override
    protected String getGameListAltFileName() {
        return Globals.CommunityGamesFileName;
    }

    @Override
    protected void createAndRunXmlDownloader() {
        new NLBXmlDownloader(this, getDialog(), getListNo());
    }
}
