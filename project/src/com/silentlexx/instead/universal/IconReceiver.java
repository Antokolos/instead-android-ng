package com.silentlexx.instead.universal;

import java.util.ArrayList;

import android.appwidget.AppWidgetManager;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.Context;

public class IconReceiver extends BroadcastReceiver {
	/**
	 * @see android.content.BroadcastReceiver#onReceive(Context,Intent)
	 */
	@Override
	public void onReceive(Context context, Intent intent) {
	     String action = intent.getAction();
	        if (action.equals(Intent.ACTION_TIMEZONE_CHANGED)
	                || action.equals(Intent.ACTION_TIME_CHANGED)) {
	            AppWidgetManager gm = AppWidgetManager.getInstance(context);
	            ArrayList<Integer> appWidgetIds = new ArrayList<Integer>();
	            ArrayList<String> game = new ArrayList<String>();
	            ArrayList<String> title = new ArrayList<String>();

	            
	            //GameChooser.loadAllTitlePrefs(context, appWidgetIds, game, title);

	            final int N = appWidgetIds.size();
	            for (int i=0; i<N; i++) {
	                GameIcon.updateAppWidget(context, gm, appWidgetIds.get(i), game.get(i), title.get(i));
	            }
	        }
	}
}
