package com.nlbhub.instead.input;

import android.app.Activity;
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
    public void init(Activity activity) {
        inputLayout = new InputLayout(activity);
        activity.addContentView(inputLayout, InputLayout.getParams());
    }

    @Override
    public void showKeyboard() {
        inputLayout.open();
    }
}
