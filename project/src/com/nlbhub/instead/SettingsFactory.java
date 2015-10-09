package com.nlbhub.instead;

import android.content.Context;
import android.util.Log;

/**
 * Created by Antokolos on 09.10.15.
 */
public class SettingsFactory {
    private static final String SETTINGS_FACTORY_ERROR = "SettingsFactory error";
    public static Settings create(Context context) {
        Settings result = null;
        try {
            result = (Settings) Class.forName("com.nlbhub.standalone.LastGame").newInstance();
        } catch (ClassNotFoundException e) {
            Log.i(InsteadApplication.ApplicationName, SETTINGS_FACTORY_ERROR, e);
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
