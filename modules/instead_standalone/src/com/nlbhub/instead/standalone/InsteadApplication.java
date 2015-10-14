package com.nlbhub.instead.standalone;

import android.app.Application;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

/**
 * This should be TEMPORARY workaround! I mean it! :)
 * This class provides method to statically obtain application context.
 * Instead of using this class, Globals class should be fully rewritten (and probably obliterated for greater good)
 */
public class InsteadApplication extends Application {
    public static final String ApplicationName = "Instead-NG";
    private static final String MainObb = "main.110000.com.nlbhub.instead.obb";
    private static final String PatchObb = "patch.110000.com.nlbhub.instead.obb";
    private static Context context;

    public void onCreate(){
        super.onCreate();
        InsteadApplication.context = getApplicationContext();
    }

    public String getMainObb() {
        return MainObb;
    }

    public String getPatchObb() {
        return PatchObb;
    }

    public static Context getAppContext() {
        return context;
    }

    public static String AppVer(Context c) {
        PackageInfo pi;
        try {
            pi = c.getPackageManager().getPackageInfo(c.getPackageName(), 0);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return "Not Found";
        }
        return pi.versionName;
    }
}
