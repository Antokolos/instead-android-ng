package com.nlbhub.instead.redhood;

import com.nlbhub.instead.standalone.InsteadApplication;

/**
 * Created by Antokolos on 15.10.15.
 */
public class RedHoodApplication extends InsteadApplication {
    private static final String MainObb = "main.105000.com.nlbhub.instead.redhood.obb";
    private static final String PatchObb = "patch.105000.com.nlbhub.instead.redhood.obb";
    // You must use the public key belonging to your publisher account
    public static final String BASE64_PUBLIC_KEY_MY = "YourLVLKey";
    // You should also modify this salt
    public static final byte[] SALT_MY = new byte[] { -107, -33, 45, -1, 84,
            43, -12, -100, 2, -8, -4, 9, 5, -106, 1, 42, -12, -1, 54, 98
    };

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
            new XAPKFile(
                    true, // true signifies a main file
                    105000, // the version of the APK that the file was uploaded
                    // against
                    104720442L // the length of the file in bytes
            )/*,
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
