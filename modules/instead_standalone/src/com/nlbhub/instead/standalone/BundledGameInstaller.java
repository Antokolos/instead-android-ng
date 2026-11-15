package com.nlbhub.instead.standalone;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Ставит контент самостоятельной игры из assets в appdata/games/&lt;gameId&gt;.
 * Маркер версии в appdata переустанавливает контент после обновления приложения.
 */
public final class BundledGameInstaller {
    private static final String TAG = "Instead-NG";
    private static final String ASSET_ROOT = "game";

    private BundledGameInstaller() {
    }

    public static File gameDir(String gameId) {
        return new File(StorageResolver.getGamesPath(), gameId);
    }

    public static boolean isInstalled(Context context, String gameId, int versionCode) {
        File marker = markerFile(gameId);
        return marker.isFile()
                && String.valueOf(versionCode).equals(readText(marker))
                && gameDir(gameId).isDirectory();
    }

    public static void install(Context context, String gameId, int versionCode) throws IOException {
        File appdata = new File(StorageResolver.getAppDataPath());
        appdata.mkdirs();
        File target = gameDir(gameId);
        StorageResolver.delete(target);
        target.mkdirs();
        copyAssetTree(context.getAssets(), ASSET_ROOT, target);
        writeText(markerFile(gameId), String.valueOf(versionCode));
    }

    private static File markerFile(String gameId) {
        return new File(StorageResolver.getAppDataPath(), ".bundle." + gameId);
    }

    private static void copyAssetTree(AssetManager assets, String src, File dst) throws IOException {
        String[] children = assets.list(src);
        if (children != null && children.length > 0) {
            dst.mkdirs();
            for (String child : children) {
                copyAssetTree(assets, src + "/" + child, new File(dst, child));
            }
            return;
        }
        try (InputStream in = assets.open(src);
             FileOutputStream out = new FileOutputStream(dst)) {
            byte[] buffer = new byte[16 * 1024];
            int read;
            while ((read = in.read(buffer)) > 0) {
                out.write(buffer, 0, read);
            }
        }
    }

    private static String readText(File file) {
        try (InputStream in = new java.io.FileInputStream(file)) {
            byte[] data = new byte[(int) file.length()];
            int offset = 0;
            int read;
            while (offset < data.length && (read = in.read(data, offset, data.length - offset)) > 0) {
                offset += read;
            }
            return new String(data, 0, offset, "UTF-8").trim();
        } catch (IOException e) {
            Log.w(TAG, "Cannot read " + file, e);
            return "";
        }
    }

    private static void writeText(File file, String value) throws IOException {
        try (FileOutputStream out = new FileOutputStream(file)) {
            out.write(value.getBytes("UTF-8"));
        }
    }
}
