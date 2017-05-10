package com.nlbhub.instead.standalone;

import android.content.Context;
import android.util.Log;

/**
 * Created by Antokolos on 09.10.15.
 */
public class SettingsFactory {
    private static final String SETTINGS_FACTORY_ERROR = "SettingsFactory problem";
    public static Settings create(Context context) {
        Settings result = null;
        try {
            result = (Settings) Class.forName("com.nlbhub.instead.launcher.simple.LastGame").newInstance();
        } catch (ClassNotFoundException e) {
            //Log.i(InsteadApplication.ApplicationName, SETTINGS_FACTORY_ERROR, e);
            Log.i(InsteadApplication.ApplicationName, "LastGame class not found, standalone mode is assumed");
        } catch (InstantiationException e) {
            Log.i(InsteadApplication.ApplicationName, SETTINGS_FACTORY_ERROR, e);
        } catch (IllegalAccessException e) {
            Log.i(InsteadApplication.ApplicationName, SETTINGS_FACTORY_ERROR, e);
        }
        if (result == null) {
            result = new Settings();
        }
        result.init(context);
        return result;
    }
}
