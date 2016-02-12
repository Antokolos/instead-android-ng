package com.nlbhub.instead.standalone;

import android.app.Activity;

/**
 * Created by Antokolos on 11.10.15.
 */
public class DummyKeyboardAdapter implements KeyboardAdapter {
    @Override
    public void init(Activity activity, boolean withoutControl) {
        // no op
    }

    @Override
    public void open() {
        // no op
    }

    @Override
    public void close() {
        // no op
    }

    @Override
    public boolean isActive() {
        return false;
    }
}
