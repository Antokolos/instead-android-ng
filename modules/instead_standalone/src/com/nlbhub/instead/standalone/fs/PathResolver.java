package com.nlbhub.instead.standalone.fs;

import java.io.IOException;

/**
 * Created by Antokolos on 03.09.15.
 */
public interface PathResolver {
    String resolvePath(String fileName) throws IOException;
}
