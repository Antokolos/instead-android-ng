package com.nlbhub.instead.input;

import android.app.Activity;
import android.content.Context;
import android.view.inputmethod.InputMethodManager;
import com.nlbhub.instead.standalone.KeyboardAdapter;

/**
 * Created by Antokolos on 10.10.15.
 */
@SuppressWarnings("unused")
public class NativeKeyboardAdapter implements KeyboardAdapter {
    private InputLayout inputLayout;

    @SuppressWarnings("unused")
    public NativeKeyboardAdapter() {
    }

    @Override
    public void init(Activity activity, boolean withoutControl) {
        inputLayout = new InputLayout(activity);
        if (!withoutControl) {
            activity.addContentView(inputLayout, InputLayout.getParams());
        }
    }

    public void open() {
        inputLayout.open();
    }

    public void close() {
        inputLayout.close();
    }

    public boolean isActive() {
        return inputLayout.isActive();
    }
}
