package com.nlbhub.instead.redhood;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.os.Bundle;
import android.widget.Button;
import android.widget.Toast;

import com.nlbhub.instead.STEADActivity;
import com.nlbhub.instead.standalone.BundledGameInstaller;
import com.nlbhub.instead.standalone.InsetsHelper;
import com.nlbhub.instead.standalone.EngineDataInstaller;
import com.nlbhub.instead.standalone.InsetsHelper;

/**
 * Меню самостоятельной игры: без каталога и сети.
 * Контент ставится из assets при первом запуске или после обновления.
 */
public class StandaloneActivity extends Activity {
    private static final String GAME_ID = "redhood";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.standalone_menu);
        InsetsHelper.apply(this);

        Button play = findViewById(R.id.play);
        Button reinstall = findViewById(R.id.reinstall);
        play.setOnClickListener(v -> startGame(false));
        reinstall.setOnClickListener(v -> startGame(true));
    }

    private void startGame(boolean reinstall) {
        final ProgressDialog dialog = new ProgressDialog(this);
        dialog.setMessage(getString(R.string.preparing));
        dialog.setCancelable(false);
        dialog.show();

        final int version = versionCode();
        new Thread(() -> {
            try {
                EngineDataInstaller.installIfNeeded(this, version);
                if (reinstall || !BundledGameInstaller.isInstalled(this, GAME_ID, version)) {
                    BundledGameInstaller.install(this, GAME_ID, version);
                }
                runOnUiThread(() -> {
                    dialog.dismiss();
                    Intent intent = new Intent(this, STEADActivity.class);
                    intent.putExtra("game", GAME_ID);
                    intent.putExtra("standalone", true);
                    startActivity(intent);
                });
            } catch (Exception e) {
                runOnUiThread(() -> {
                    dialog.dismiss();
                    Toast.makeText(this, getString(R.string.install_failed) + " " + e,
                            Toast.LENGTH_LONG).show();
                });
            }
        }).start();
    }

    private int versionCode() {
        try {
            PackageInfo info = getPackageManager().getPackageInfo(getPackageName(), 0);
            return info.versionCode;
        } catch (Exception e) {
            return 0;
        }
    }
}
