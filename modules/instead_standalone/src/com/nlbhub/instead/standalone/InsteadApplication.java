package com.nlbhub.instead.standalone;

import android.app.Application;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;

public class InsteadApplication extends Application {
    public static final String ApplicationName = "Instead-NG";

    private static Context context;

    @Override
    public void onCreate() {
        super.onCreate();
        context = getApplicationContext();
    }

    public static Context getAppContext() {
        return context;
    }

    private static PackageInfo getPackageInfo(Context c) {
        PackageInfo pi = null;
        try {
            pi = c.getPackageManager().getPackageInfo(c.getPackageName(), 0);
        } catch (PackageManager.NameNotFoundException e) {
            Log.e(ApplicationName, "Name not found", e);
        }
        return pi;
    }

    public static String AppVer(Context c) {
        PackageInfo pi = getPackageInfo(c);
        return (pi != null) ? pi.versionName : "Not Found";
    }

    public static String AppVerCode(Context c) {
        PackageInfo pi = getPackageInfo(c);
        return (pi != null) ? String.valueOf(pi.versionCode) : "000000";
    }

    /**
     * Каталог приложения в общем хранилище (Instead-NG). Игры-приложения могут
     * переопределить его, чтобы жить в своей папке.
     */
    public String getApplicationMainFolderName() {
        return ApplicationName;
    }
}
