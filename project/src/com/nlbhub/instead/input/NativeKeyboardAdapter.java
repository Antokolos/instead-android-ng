package com.nlbhub.instead.input;

import android.app.Activity;
import com.nlbhub.instead.standalone.KeyboardAdapter;

/**
 * Created by Antokolos on 10.10.15.
 */
public class NativeKeyboardAdapter implements KeyboardAdapter {
    private InputLayout inputLayout;

    public NativeKeyboardAdapter() {
    }

    @Override
    public void init(Activity activity) {
        inputLayout = new InputLayout(activity);
        activity.addContentView(inputLayout, InputLayout.getParams());
    }

    @Override
    public void showKeyboard() {
        inputLayout.open();
    }
}
