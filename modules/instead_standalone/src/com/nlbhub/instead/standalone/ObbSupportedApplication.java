package com.nlbhub.instead.standalone;

import android.app.Application;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;
import com.google.android.vending.expansion.downloader.Helpers;

public abstract class ObbSupportedApplication extends Application {

    private static Context context;

    public void onCreate(){
        super.onCreate();
        ObbSupportedApplication.context = getApplicationContext();
    }

    public static Context getAppContext() {
        return context;
    }

    private static PackageInfo getPackageInfo(Context c) {
        PackageInfo pi = null;
        try {
            pi = c.getPackageManager().getPackageInfo(c.getPackageName(), 0);
        } catch (PackageManager.NameNotFoundException e) {
            Log.e(InsteadApplication.ApplicationName, "Name not found", e);
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
     * Go through each of the APK Expansion files defined in the structure above
     * and determine if the files are present and match the required size. Free
     * applications should definitely consider doing this, as this allows the
     * application to be launched for the first time without having a network
     * connection present. Paid applications that use LVL should probably do at
     * least one LVL check that requires the network to be present, so this is
     * not as necessary.
     *
     * @return true if they are present.
     */
    public boolean expansionFilesDelivered() {
        for (XAPKFile xf : getAPKFiles()) {
            String fileName = Helpers.getExpansionAPKFileName(context, xf.mIsMain, xf.mFileVersion);
            if (!Helpers.doesFileExist(context, fileName, xf.mFileSize, false))
                return false;
        }
        return true;
    }

    public abstract String getApplicationMainFolderName();

    public abstract String getPublicKey();

    public abstract byte[] getSALT();

    public abstract String getMainObb();

    public abstract String getPatchObb();

    /**
     * Returned APK files array is empty here, redefine it in your application if it uses APK files.
     * @return
     */
    protected abstract XAPKFile[] getAPKFiles();

    /**
     * This is a little helper class that demonstrates simple testing of an
     * Expansion APK file delivered by Market. You may not wish to hard-code
     * things such as file lengths into your executable... and you may wish to
     * turn this code off during application development.
     */
    protected static class XAPKFile {
        public final boolean mIsMain;
        public final int mFileVersion;
        public final long mFileSize;

        public XAPKFile(boolean isMain, int fileVersion, long fileSize) {
            mIsMain = isMain;
            mFileVersion = fileVersion;
            mFileSize = fileSize;
        }
    }
}
