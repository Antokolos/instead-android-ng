package com.nlbhub.instead.redhood;

import com.nlbhub.instead.standalone.InsteadApplication;

/**
 * Created by Antokolos on 15.10.15.
 */
public class RedHoodApplication extends InsteadApplication {
    private static final String MainObb = "main.105000.com.nlbhub.instead.redhood.obb";
    private static final String PatchObb = "patch.105000.com.nlbhub.instead.redhood.obb";

    @Override
    public String getMainObb() {
        return MainObb;
    }

    @Override
    public String getPatchObb() {
        return PatchObb;
    }
}
