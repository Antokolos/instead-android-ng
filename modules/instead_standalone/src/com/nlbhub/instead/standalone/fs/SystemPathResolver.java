package com.nlbhub.instead.standalone.fs;

import android.content.Context;

import java.io.IOException;

/**
 * Created by Antokolos on 03.09.15.
 */
public class SystemPathResolver implements PathResolver {
    private String dirName;
    private Context context;

    public SystemPathResolver(String dirName, Context context) {
        this.dirName = dirName;
        this.context = context;
    }

    @Override
    public String resolvePath(String fileName) throws IOException {
        // I'm using /data/data/myPackage/app_libs (using Ctx.getDir("libs",Context.MODE_PRIVATE); returns that path).
        return getPath() + fileName;
    }

    public String getPath() throws IOException {
        return context.getDir(dirName, Context.MODE_PRIVATE).getCanonicalPath() + "/";
    }
}
