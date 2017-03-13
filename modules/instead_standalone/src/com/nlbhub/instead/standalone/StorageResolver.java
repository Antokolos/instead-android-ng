package com.nlbhub.instead.standalone;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Environment;
import com.nlbhub.instead.standalone.fs.SystemPathResolver;

import java.io.File;
import java.io.IOException;
import java.util.Map;

/**
 * Created by Antokolos on 09.10.15.
 */
public class StorageResolver {
    public static final String GameDir = "appdata/games/";
    public static final String SaveDir = "appdata/saves/";
    public static final String Options = "appdata/insteadrc";
    public static final String Themes = "themes";
    public static final String[] MainLuaFiles = {"main.lua", "main3.lua"};
    public static final String DataFlag = ".version";
    public static final String BundledGame = "bundled";

    /**
     * This method represents getStorage() code that was used in version 1.1.1
     * It should be removed after 1.1.3 and should not be used in future!
     * TODO: Remove this method after 1.1.3
     * @deprecated
     * @return
     */
    public static String getStorage111(){
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

    public static String getStorage(){
        final Context context = InsteadApplication.getAppContext();

        String result = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS) + "/";

        String extStorageState = Environment.getExternalStorageState();
        boolean canRead;
        boolean canWrite;
        if (Environment.MEDIA_MOUNTED.equals(extStorageState)) {
            canWrite = true;
            canRead = true;
        } else if (Environment.MEDIA_MOUNTED_READ_ONLY.equals(extStorageState)) {
            canRead = true;
            canWrite = false;
        } else {
            canWrite = false;
            canRead = false;
        }
        if (!canRead || !canWrite) {
            try {
                SystemPathResolver downloadResolver = new SystemPathResolver("dwn", context);
                result = downloadResolver.getPath();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
        File dir = new File(result);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return result;
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    public static String getObbFilePath(final String filename, Context context) {
        return context.getObbDir() + "/" + filename;
    };

    public static String getOutFilePath(final String filename) {
        return getStorage() + InsteadApplication.ApplicationName + "/" + filename;
    };

    public static String getOutFilePath(final String subDir, final String filename) {
        return getStorage() + InsteadApplication.ApplicationName + "/" + subDir + "/" + filename;
    };

    public static boolean isWorking(String f){
        for (String mainLuaFile : MainLuaFiles) {
            String path = getOutFilePath(GameDir + "/" + f, mainLuaFile);
            if (new File(path).isFile()) {
                return true;
            }
        }
        return false;
    }

    public static String getGamesPath(ExpansionMounter expansionMounter) {
        final String expansionFilePath = (expansionMounter != null) ? expansionMounter.getExpansionFilePath() : null;
        final String appdata = getAppDataPath(expansionMounter);
        return (expansionFilePath != null) ? expansionFilePath + "/games" : appdata + "/games";
    }

    public static String getAppDataPath(ExpansionMounter expansionMounter) {
        final String expansionFilePath = (expansionMounter != null) ? expansionMounter.getExpansionFilePath() : null;
        final File bundledGameDirParent = (expansionFilePath != null) ? new File(expansionFilePath, "games") : null;
        String resultPath = StorageResolver.getStorage() + InsteadApplication.ApplicationName + "/" + getAppDataFolderName(bundledGameDirParent);
        File resultDir = new File(resultPath);
        if (!resultDir.exists()) {
            // TODO: directories creation should be moved somewhere, this metod should only get things
            resultDir.mkdir();
        }
        return resultPath;
    }

    private static String getAppDataFolderName(File bundledGameDirParent) {
        if (bundledGameDirParent == null || !bundledGameDirParent.isDirectory()) {
            return "appdata";
        } else {
            return bundledGameDirParent.list()[0];
        }
    }

    public static void delete(String path) {
        delete(new File(path));
    }

    public static void delete(File file) {

        if (file.isDirectory()) {

            if (file.list().length == 0) {

                file.delete();

            } else {

                String files[] = file.list();

                for (String temp : files) {
                    File fileDelete = new File(file, temp);
                    delete(fileDelete);
                }
                if (file.list().length == 0) {

                    try{
                        file.delete();
                    } catch(NullPointerException e){

                    }
                }
            }

        } else {

            try{
                file.delete();
            } catch(NullPointerException e){

            }
        }
    }

}
