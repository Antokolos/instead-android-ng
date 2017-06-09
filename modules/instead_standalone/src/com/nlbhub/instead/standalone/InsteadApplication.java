package com.nlbhub.instead.standalone;

import android.app.Application;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;
import com.google.android.vending.expansion.downloader.Helpers;

/**
 * This should be TEMPORARY workaround! I mean it! :)
 * This class provides method to statically obtain application context.
 * Instead of using this class, Globals class should be fully rewritten (and probably obliterated for greater good)
 */
public class InsteadApplication extends ObbSupportedApplication {
    public static final String ApplicationName = "Instead-NG";
    // You must use the public key belonging to your publisher account
    public static final String BASE64_PUBLIC_KEY = "YourLVLKey";
    // You should also modify this salt
    public static final byte[] SALT = new byte[] { 1, 42, -12, -1, 54, 98,
            -100, -12, 43, 2, -8, -4, 9, 5, -106, -107, -33, 45, -1, 84
    };

    // You must override the following methods in your application

    @Override
    public String getApplicationMainFolderName() {
        return ApplicationName;
    }

    @Override
    public String getPublicKey() {
        return BASE64_PUBLIC_KEY;
    }

    @Override
    public byte[] getSALT() {
        return SALT;
    }

    @Override
    public String getMainObb() {
        return "main" + getObbNameTail(getAppContext());
    }

    private String getObbNameTail(Context context) {
        return "." + AppVerCode(context) + "." + context.getPackageName() + ".obb";
    }

    @Override
    public String getPatchObb() {
        return "patch" + getObbNameTail(getAppContext());
    }

    /**
     * Returned APK files array is empty here, redefine it in your application if it uses APK files.
     * @return
     */
    @Override
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
}
