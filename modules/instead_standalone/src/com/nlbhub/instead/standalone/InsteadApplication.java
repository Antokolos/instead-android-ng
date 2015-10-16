package com.nlbhub.instead.standalone;

import android.app.Application;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import com.google.android.vending.expansion.downloader.Helpers;

import java.util.ArrayList;
import java.util.List;

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
    // You must use the public key belonging to your publisher account
    public static final String BASE64_PUBLIC_KEY = "YourLVLKey";
    // You should also modify this salt
    public static final byte[] SALT = new byte[] { 1, 42, -12, -1, 54, 98,
            -100, -12, 43, 2, -8, -4, 9, 5, -106, -107, -33, 45, -1, 84
    };

    public void onCreate(){
        super.onCreate();
        InsteadApplication.context = getApplicationContext();
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

    // You must override the following methods in your application

    public String getPublicKey() {
        return BASE64_PUBLIC_KEY;
    }

    public byte[] getSALT() {
        return SALT;
    }

    public String getMainObb() {
        return MainObb;
    }

    public String getPatchObb() {
        return PatchObb;
    }

    /**
     * Returned APK files array is empty here, redefine it in your application if it uses APK files.
     * @return
     */
    protected XAPKFile[] getAPKFiles() {
        XAPKFile[] result = {
            /*new XAPKFile(
                    true, // true signifies a main file
                    3, // the version of the APK that the file was uploaded
                    // against
                    687801613L // the length of the file in bytes
            ),
            new XAPKFile(
                    false, // false signifies a patch file
                    4, // the version of the APK that the patch file was uploaded
                    // against
                    512860L // the length of the patch file in bytes
            )*/
        };
        return result;
    }

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
