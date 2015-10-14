package com.nlbhub.instead.standalone.expansion;

import com.google.android.vending.expansion.downloader.impl.DownloaderService;

/**
 * Created by Antokolos on 13.10.15.
 */
public class InsteadDownloaderService extends DownloaderService {
    // You must use the public key belonging to your publisher account
    public static final String BASE64_PUBLIC_KEY = "YourLVLKey";
    // You should also modify this salt
    public static final byte[] SALT = new byte[] { 1, 42, -12, -1, 54, 98,
            -100, -12, 43, 2, -8, -4, 9, 5, -106, -107, -33, 45, -1, 84
    };

    @Override
    public String getPublicKey() {
        return BASE64_PUBLIC_KEY;
    }

    @Override
    public byte[] getSALT() {
        return SALT;
    }

    @Override
    public String getAlarmReceiverClassName() {
        return InsteadAlarmReceiver.class.getName();
    }
}