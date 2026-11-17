package com.nlbhub.instead.standalone;

import android.content.Context;

import com.nlbhub.instead.R;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Ставит runtime-данные движка (stead/themes/lang) из res/raw в app-private
 * каталог getDir("data"). Нужно и лаунчеру, и самостоятельным играм: у каждого
 * приложения свой app_data.
 */
public final class EngineDataInstaller {
    private static final String VERSION_MARKER = ".version";

    private EngineDataInstaller() {
    }

    public static void installIfNeeded(Context context, int versionCode) throws IOException {
        File dataDir = context.getDir("data", Context.MODE_PRIVATE);
        File marker = new File(dataDir, VERSION_MARKER);
        if (marker.isFile() && String.valueOf(versionCode).equals(readText(marker))) {
            return;
        }
        StorageResolver.delete(new File(dataDir, "stead"));
        StorageResolver.delete(new File(dataDir, "themes"));
        StorageResolver.delete(new File(dataDir, "lang"));
        StorageResolver.delete(new File(dataDir, "languages"));
        StorageResolver.delete(marker);

        extract(context.getResources().openRawResource(R.raw.data), dataDir);
        extract(context.getResources().openRawResource(R.raw.themes), dataDir);

        try (FileOutputStream out = new FileOutputStream(marker)) {
            out.write(String.valueOf(versionCode).getBytes("UTF-8"));
        }
    }

    private static void extract(InputStream stream, File root) throws IOException {
        File rootDir = root.getCanonicalFile();
        try (ZipInputStream zip = new ZipInputStream(stream)) {
            ZipEntry entry;
            byte[] buffer = new byte[16 * 1024];
            while ((entry = zip.getNextEntry()) != null) {
                File target = new File(rootDir, entry.getName()).getCanonicalFile();
                if (!target.equals(rootDir)
                        && !target.getPath().startsWith(rootDir.getPath() + File.separator)) {
                    throw new IOException("Unsafe zip entry: " + entry.getName());
                }
                if (entry.isDirectory()) {
                    target.mkdirs();
                    continue;
                }
                target.getParentFile().mkdirs();
                try (FileOutputStream out = new FileOutputStream(target)) {
                    int read;
                    while ((read = zip.read(buffer)) > 0) {
                        out.write(buffer, 0, read);
                    }
                }
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
            return "";
        }
    }
}
