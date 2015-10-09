package com.nlbhub.instead;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Environment;
import android.os.storage.StorageManager;

import java.io.File;

/**
 * Created by Antokolos on 09.10.15.
 */
public class StorageResolver {
    public static ExpansionMounter expansionMounterMain = null;
    public static StorageManager storageManager = null;
    public static final String MainObb = "main.101000.com.nlbhub.instead.obb";
    public static final String PatchObb = "patch.101000.com.nlbhub.instead.obb";
    public static final String GameDir = "appdata/games/";
    public static final String SaveDir = "appdata/saves/";
    public static final String Options = "appdata/insteadrc";
    public static final String MainLua = "/main.lua";
    public static final String DataFlag = ".version";
    public static final String BundledGame = "bundled";

    public static String getStorage(){
        final Context context = InsteadApplication.getAppContext();
        String result = context.getExternalFilesDir(null) + "/";

        String extStorageState = Environment.getExternalStorageState();
        boolean canRead;
        boolean canWrite;
        if ("mounted".equals(extStorageState)) {
            canWrite = true;
            canRead = true;
        } else if ("mounted_ro".equals(extStorageState)) {
            canRead = true;
            canWrite = false;
        } else {
            canWrite = false;
            canRead = false;
        }
        if(result.contains("emulated") || !canRead || !canWrite)
        {
            PackageManager packageManager = context.getPackageManager();
            String packageName = context.getPackageName();
            try {
                PackageInfo packageInfo = packageManager.getPackageInfo(packageName, 0);
                result = packageInfo.applicationInfo.dataDir + "/files/";
                File dir = new File(result);
                if (!dir.exists()) {
                    dir.mkdir();
                }
            } catch(PackageManager.NameNotFoundException e) {
                throw new RuntimeException(e);
            }
        }
        return result;
    }

    public static String getObbFilePath(final String filename, Context context) {
        return context.getObbDir() + "/" + filename;
    };

    public static String getOutFilePath(final String filename) {
        return getStorage() + InsteadApplication.ApplicationName + "/" + filename;
    };

    public static boolean isWorking(String f){
        String path = getOutFilePath(GameDir) + "/" + f + MainLua;
        return (new File(path)).isFile();
    }
}
