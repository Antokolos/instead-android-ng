package com.nlbhub.instead.standalone.expansion;

import com.google.android.vending.expansion.downloader.impl.DownloaderService;
import com.nlbhub.instead.standalone.InsteadApplication;

/**
 * Created by Antokolos on 13.10.15.
 */
public class InsteadDownloaderService extends DownloaderService {

    @Override
    public String getPublicKey() {
        return ((InsteadApplication) getApplication()).getPublicKey();
    }

    @Override
    public byte[] getSALT() {
        return ((InsteadApplication) getApplication()).getSALT();
    }

    @Override
    public String getAlarmReceiverClassName() {
        return InsteadAlarmReceiver.class.getName();
    }
}