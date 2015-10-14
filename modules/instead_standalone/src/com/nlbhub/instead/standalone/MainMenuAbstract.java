package com.nlbhub.instead.standalone;

import android.app.ListActivity;

/**
 * Created by Antokolos on 14.10.15.
 */
public abstract class MainMenuAbstract extends ListActivity {

    public abstract boolean isOnpause();

    public abstract void onError(String s);

    public abstract void setDownGood();

    public abstract void showRun();
}
