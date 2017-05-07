package com.nlbhub.instead;

import android.content.Context;
import android.util.Log;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.standalone.StorageResolver;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * @author Anton P. Kolosov
 * @version 1.0
 */
public class PropertyManager {

    public static PropertiesBean getProperties(Context context) {
        File configDir = new File(StorageResolver.getDefaultProgramDir());
        try {
            return readProperties(context, configDir);
        } catch (IOException e) {
            Log.e(InsteadApplication.ApplicationName, e.getMessage());
            return new PropertiesBean();
        }
    }

    private static PropertiesBean readProperties(Context context, File configDir) throws IOException {
        PropertiesBean result = new PropertiesBean();
        Properties prop = new Properties();
        InputStream input = null;

        try {
            if (!configDir.exists()) {
                throw new IOException("Config dir " + configDir.getCanonicalPath()  + " does not exist!");
            }
            File configFile = new File(configDir, "config.properties");
            if (!configFile.exists()) {
                Log.i(InsteadApplication.ApplicationName, "Config file " + configFile.getCanonicalPath() + " does not exist! Default config file will be created.");
                FileUtils.copyInputStreamToFile(context.getResources().openRawResource(R.raw.config), configFile);
                return result;
            }

            input = new FileInputStream(configFile);

            // load a properties file
            prop.load(input);

            String standalone = getTrimmedProperty(prop, "instead-ng.parameters.standalone");
            String gameListDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-download-url");
            String gameListAltDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-alt-download-url");
            String gameListNLBDemoDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-nlb-demo-download-url");
            String gameListNLBFullDownloadUrl = getTrimmedProperty(prop, "instead-ng.parameters.game-list-nlb-full-download-url");
            String music = getTrimmedProperty(prop, "instead-ng.parameters.music.default");
            String nativeLog = getTrimmedProperty(prop, "instead-ng.parameters.native.log.default");
            String enforceResolution = getTrimmedProperty(prop, "instead-ng.parameters.enforce.resolution.default");
            String ovVol = getTrimmedProperty(prop, "instead-ng.parameters.ovvol.default");
            String keyboard = getTrimmedProperty(prop, "instead-ng.parameters.keyboard.default");
            String screenoff = getTrimmedProperty(prop, "instead-ng.parameters.screenoff.default");
            String owntheme = getTrimmedProperty(prop, "instead-ng.parameters.owntheme.default");
            String enforceSystemStorage = getTrimmedProperty(prop, "instead-ng.parameters.enforce.system.storage.default");
            String theme = getTrimmedProperty(prop, "instead-ng.parameters.theme.default");

            result.setStandalone("true".equalsIgnoreCase(standalone));
            result.setGameListDownloadUrl(gameListDownloadUrl);
            result.setGameListAltDownloadUrl(gameListAltDownloadUrl);
            result.setGameListNLBDemoDownloadUrl(gameListNLBDemoDownloadUrl);
            result.setGameListNLBFullDownloadUrl(gameListNLBFullDownloadUrl);
            result.setMusic("true".equalsIgnoreCase(music));
            result.setNativeLog("true".equalsIgnoreCase(nativeLog));
            result.setEnforceResolution("true".equalsIgnoreCase(enforceResolution));
            result.setOvVol("true".equalsIgnoreCase(ovVol));
            result.setKeyboard("true".equalsIgnoreCase(keyboard));
            result.setScreenOff("true".equalsIgnoreCase(screenoff));
            result.setOwnTheme("true".equalsIgnoreCase(owntheme));
            result.setEnforceSystemStorage("true".equalsIgnoreCase(enforceSystemStorage));
            result.setTheme(theme);

            return result;
        } finally {
            if (input != null) {
                input.close();
            }
        }
    }

    private static String getTrimmedProperty(Properties prop, String propertyName) {
        String property = prop.getProperty(propertyName);
        if (property == null) {
            return "";
        }
        return property.trim();
    }
}
