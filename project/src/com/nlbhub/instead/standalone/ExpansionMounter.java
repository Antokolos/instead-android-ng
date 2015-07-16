package com.nlbhub.instead.standalone;

import android.os.storage.OnObbStateChangeListener;
import android.os.storage.StorageManager;
import android.util.Log;

import java.io.File;

/**
 * @author Antokolos
 */
public class ExpansionMounter {
    private static final String TAG="Instead-NG";
    private StorageManager storageManager;
    private String filePath;
    public ExpansionMounter(StorageManager storageManager, String filePath) {
        this.storageManager = storageManager;
        this.filePath = filePath;
    }

    public void mountExpansion() {
        final File mainFile = new File(filePath);
        if (mainFile.exists()) {
            Log.d(TAG, "FILE: " + filePath + " Exists");
        } else {
            Log.d(TAG, "FILE: " + filePath + " DOESNT EXIST");
        }


        if (!storageManager.isObbMounted(mainFile.getAbsolutePath())) {
            if (mainFile.exists()) {
                if(storageManager.mountObb(mainFile.getAbsolutePath(), null,
                        new OnObbStateChangeListener() {
                            @Override
                            public void onObbStateChange(String path, int state) {
                                super.onObbStateChange(path, state);
                                Log.d("PATH = ",path);
                                Log.d("STATE = ", state+"");
                                if (state == OnObbStateChangeListener.MOUNTED) {
                                    String expansionFilePath = storageManager.getMountedObbPath(path);
                                    Log.d(TAG,expansionFilePath+"-->MOUNTED");

                                }
                                else {
                                    Log.d(TAG, "Path: " + path + "; state: " + state);
                                }
                            }
                        }))
                {
                    Log.d(TAG,"SUCCESSFULLY QUEUED");
                }
                else
                {
                    Log.d(TAG,"FAILED");
                }

            } else {
                Log.d(TAG, "Patch file not found");
            }
        }else {

        }
    }

    public String getExpansionFilePath() {
        return storageManager.getMountedObbPath(filePath);
    }
}
