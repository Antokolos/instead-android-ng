package com.nlbhub.instead.universal;

import android.app.PendingIntent;
import android.appwidget.AppWidgetProvider;
import android.content.Intent;
import android.content.Context;
import android.widget.RemoteViews;
import android.appwidget.AppWidgetManager;
import com.nlbhub.instead.R;
import com.nlbhub.instead.SDLActivity;

public class GameIcon extends AppWidgetProvider {
	
	public static String ACTION_WIDGET_RECEIVER = "ActionReceiverWidget";
//	private static String KEY_RECEIVER = "game";
	
	@Override
	public void onUpdate(Context context, AppWidgetManager appwidgetmanager,
			int[] appWidgetIds) {
			
			//Log.d("w","onUpdate");

	        final int N = appWidgetIds.length;
	        for (int i=0; i<N; i++) {
	           	int appWidgetId = appWidgetIds[i];
	            String game = GameChooser.loadGame(context, appWidgetId);
	            String title = GameChooser.loadTitle(context, appWidgetId);
	            updateAppWidget(context, appwidgetmanager, appWidgetId, game, title);
	        }
	}

	@Override
	public void onDeleted(Context context, int[] appWidgetIds) {
		//Log.d("w","onDeleted");
        final int N = appWidgetIds.length;
        for (int i=0; i<N; i++) {
            GameChooser.deleteTitlePref(context, appWidgetIds[i]);
        }
	}

	@Override
	public void onEnabled(Context context) {
		//Log.d("w","onEnabled");
    /*   PackageManager pm = context.getPackageManager();
        pm.setComponentEnabledSetting(
                new ComponentName("com.nlbhub.instead", ".IconReceiver"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP);
                */
	}

	@Override
	public void onDisabled(Context context) {
	//Log.d("w","onDisabled");
    /*    PackageManager pm = context.getPackageManager();
        pm.setComponentEnabledSetting(
        		new ComponentName("com.nlbhub.instead", ".IconReceiver"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP); */
	}

	
 @Override  
    public void onReceive(Context context, Intent intent) {  
         super.onReceive(context, intent);  
    }  

public static String trimTitle(String t){
 final int CHPL = 10;
 int l = t.length();
 String r = "";

 if(l>10){
  /*  for(int i = 0 ; i < l ; i=i+CHPL){
       int end = i+CHPL;
       if(end > l) end = l;
	   r = r + t.substring(i, end)+"\n";
    }
    */
	 String suf = "";
	 int end = l;
     if(end>CHPL*2) {
    	 end = (CHPL*2) - 3;
    	 suf = "...";
     }

	 r = r + t.substring(0, CHPL)+"\n"+t.substring(CHPL, end)+suf;   
	 
 } else return t;

return r;

}
 
 
static void updateAppWidget(Context context, AppWidgetManager appWidgetManager,
            int appWidgetId, String game, String title) {
    		
		
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_initial_layout);
        views.setTextViewText(R.id.widget_text, title);
/*
        if(game.endsWith(".idf")){
    		views.setImageViewResource(R.id.widget_icon, R.drawable.idf48);
    	} else {
    		views.setImageViewResource(R.id.widget_icon, R.drawable.game48);
    	}
*/
        
        Intent active = new Intent(context, SDLActivity.class);
        active.setAction(game);

        PendingIntent actionPendingIntent = PendingIntent.getActivity(context, 0, active, 0);

    	views.setOnClickPendingIntent(R.id.widget, actionPendingIntent);

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }
    
    
}
