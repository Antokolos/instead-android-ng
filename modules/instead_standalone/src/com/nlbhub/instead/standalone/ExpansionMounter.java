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
    private boolean ready = false;
    private static final Object LOCK = new Object();

    public ExpansionMounter(StorageManager storageManager, String filePath) {
        this.storageManager = storageManager;
        this.filePath = filePath;
    }

    public void mountExpansion() {
        final File mainFile = new File(filePath);
        if (mainFile.exists()) {
            if (!storageManager.isObbMounted(mainFile.getAbsolutePath())) {
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
                                    setReady();
                                }
                                else {
                                    Log.d(TAG, "Path: " + path + "; state: " + state);
                                }
                            }
                        }
                )) {
                    Log.d(TAG,"SUCCESSFULLY QUEUED");
                } else {
                    Log.d(TAG,"FAILED");
                    setReady();
                }
            }
        } else {
            Log.d(TAG, "Patch file not found");
            setReady();
        }
    }

    private void setReady() {
        synchronized(LOCK){
            //set ready flag to true (so isReady returns true)
            ready = true;
            LOCK.notifyAll();
        }
    }

    /**
     * NB: DO NOT USE THIS METHOD IN THE SAME THREAD/ACTIVITY THAT CALLED mountExpansion()!
     * @return
     */
    public String getExpansionFilePath() {
        try {
            synchronized(LOCK){
                while (!ready){
                    LOCK.wait();
                }
            }
            return storageManager.getMountedObbPath(filePath);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}
