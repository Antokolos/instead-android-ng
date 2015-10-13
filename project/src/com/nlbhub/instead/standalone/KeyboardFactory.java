package com.nlbhub.instead.standalone;

import android.app.Activity;
import android.util.Log;

/**
 * Created by Antokolos on 10.10.15.
 */
public class KeyboardFactory {
    private static final String KEYBOARD_FACTORY_ERROR = "KeyboardFactory problem";
    public static KeyboardAdapter create(Activity activity, boolean keyboardEnabled) {
        KeyboardAdapter result = null;
        if (keyboardEnabled) {
            try {
                result = (KeyboardAdapter) Class.forName("com.nlbhub.instead.input.NativeKeyboardAdapter").newInstance();
            } catch (ClassNotFoundException e) {
                Log.i(InsteadApplication.ApplicationName, KEYBOARD_FACTORY_ERROR, e);
            } catch (InstantiationException e) {
                Log.i(InsteadApplication.ApplicationName, KEYBOARD_FACTORY_ERROR, e);
            } catch (IllegalAccessException e) {
                Log.i(InsteadApplication.ApplicationName, KEYBOARD_FACTORY_ERROR, e);
            }
        }
        if (result == null) {
            result = new DummyKeyboardAdapter();
        }
        result.init(activity);
        return result;
    }
}
