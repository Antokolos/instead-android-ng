package com.nlbhub.instead;

import com.nlbhub.instead.standalone.Globals;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;

/**
 * Created by Antokolos on 09.10.15.
 */
public class ThemeHelper {
    public static boolean isPortrait(){
        boolean b = false;
        boolean c = true;
        String path = Globals.getOutFilePath(StorageResolver.Options);
        BufferedReader input = null;
        try {
            input = new BufferedReader(new InputStreamReader(
                    new FileInputStream(new File(path)), "UTF-8"));


            String line = null;
            while ((line = input.readLine()) != null) {

                if (line.toLowerCase().matches("owntheme\\ *=\\ *1.*")){
                    c = false;
                }

                if (line.toLowerCase().matches("theme.*"+Globals.PORTRET_KEY.toLowerCase()+".*")) {
                    b = true;
                }
            }

        } catch (Exception e) {
        }

        if(c && b){
            return true;
        } else {
            return false;
        }
    }
}
