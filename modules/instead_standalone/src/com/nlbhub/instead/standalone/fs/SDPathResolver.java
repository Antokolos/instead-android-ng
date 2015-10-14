package com.nlbhub.instead.standalone.fs;

import com.nlbhub.instead.standalone.StorageResolver;

import java.io.IOException;

/**
 * Created by Antokolos on 03.09.15.
 */
public class SDPathResolver implements PathResolver {
    private String dirName;

    public SDPathResolver(String dirName) {
        this.dirName = dirName;
    }

    @Override
    public String resolvePath(String fileName) throws IOException {
        return StorageResolver.getOutFilePath(dirName, fileName) ;
    }
}

