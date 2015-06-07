package com.nlbhub.instead.nlb;

import com.nlbhub.instead.standalone.Globals;
import com.nlbhub.instead.universal.GameManager;

/**
 * @author Anton P. Kolosov
 */
public class NLBGameManager extends GameManager {
    @Override
    protected int getBasicListNo() {
        return Globals.NLBFREE;
    }

    @Override
    protected int getAlterListNo() {
        return Globals.NLBPAID;
    }

    @Override
    protected String getGameListFileName() {
        return Globals.GameListNLBFileName;
    }

    @Override
    protected String getGameListAltFileName() {
        return Globals.GameListNLBPaidFileName;
    }
}
