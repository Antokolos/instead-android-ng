package com.nlbhub.instead;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.hardware.Sensor;
import android.media.AudioManager;
import android.os.*;
import android.os.storage.StorageManager;
import android.util.Log;
import android.view.*;
import android.widget.Toast;
import com.google.android.vending.expansion.downloader.*;
import com.nlbhub.instead.standalone.*;
import com.nlbhub.instead.standalone.expansion.APKHelper;

import java.io.File;
import java.io.IOException;

/**
 * SDL Activity
 */
public class SDLActivity extends SDLActivityBase implements IDownloaderClient {
	final static int WAIT = 100;
	final static int KOLL = 10;
	private boolean first_run = true;
	
	private static Display display;
	private static BroadcastReceiver mReceiver;

	private static boolean portrait = false;
	private static String game = null;
	private static String idf = null;
	private static int i_s = KOLL;
	private static Handler h;
	private static Settings settings;
	private static KeyboardAdapter keyboardAdapter;
	private static AudioManager audioManager;
	private static Context Ctx;

	private IStub mDownloaderClientStub;
	private IDownloaderService mRemoteService;

	// Load the .so
	/*
	Now this is done in loadLibs()
	static {
		System.loadLibrary("SDL2");
		System.loadLibrary("SDL2_image");
		System.loadLibrary("smpeg2");
		System.loadLibrary("SDL2_mixer");
		System.loadLibrary("SDL2_ttf");
		System.loadLibrary("main");
	}
	*/

	public void loadLibs() {
		try {
			// I'm using /data/data/myPackage/app_libs (using Ctx.getDir("libs",Context.MODE_PRIVATE); returns that path).
			String libsDirPath = Ctx.getDir("libs",Context.MODE_PRIVATE).getCanonicalPath() + "/";
			System.load(libsDirPath + "libSDL2.so");
			System.load(libsDirPath + "libSDL2_image.so");
			System.load(libsDirPath + "libsmpeg2.so");
			System.load(libsDirPath + "libSDL2_mixer.so");
			System.load(libsDirPath + "libSDL2_ttf.so");
			System.load(libsDirPath + "libmain.so");
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private void initDownloaderClientStub(Context context) {
		try {
			mDownloaderClientStub = new APKHelper(context).createDownloaderStubIfNeeded(this);
		} catch (PackageManager.NameNotFoundException e) {
			Log.e(InsteadApplication.ApplicationName, "Error creating downloader stub", e);
		}
	}

	private synchronized void initExpansionManager(Context context) {
		// initDownloaderClientStub(context);
		if (StorageResolver.expansionMounterMain == null) {
			if (StorageResolver.storageManager == null) {
				StorageResolver.storageManager = (StorageManager) getSystemService(STORAGE_SERVICE);
			}
			context.getObbDir().mkdir();
			StorageResolver.expansionMounterMain = new ExpansionMounter(StorageResolver.storageManager, StorageResolver.getObbFilePath(StorageResolver.MainObb, context));
			StorageResolver.expansionMounterMain.mountExpansion();
		}
	}

	public static KeyboardAdapter getKeyboardAdapter(){
		return keyboardAdapter;
	}

	/**
	 * See http://android-developers.blogspot.ru/2009_12_01_archive.html
	 * @param event
	 * @return
	 */
    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
            if (event.getAction() == KeyEvent.ACTION_DOWN
                    && event.getRepeatCount() == 0) {

                // Tell the framework to start tracking this event.
                mSurface.getKeyDispatcherState().startTracking(event, this);
                return true;

            } else if (event.getAction() == KeyEvent.ACTION_UP) {
                mSurface.getKeyDispatcherState().handleUpEvent(event);
                if (event.isTracking() && !event.isCanceled()) {
                    toggleMenu();
                    return true;

                }
            }
            return super.dispatchKeyEvent(event);
        } else {
            return super.dispatchKeyEvent(event);
        }
    }

	public static void setVol(int dvol){

		int minvol = 0;
		int maxvol = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
		int curvol = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
		curvol += dvol;
		if(curvol<minvol) {
			curvol = minvol;
		} else if (curvol>maxvol){
			curvol = maxvol;
		}
		 audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, curvol, 0);
	}

	public static Settings getSettings() {
		return settings;
	}

	// Setup
	protected void onCreate(Bundle savedInstanceState) {
        Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));
		// The following line is to workaround AndroidRuntimeException: requestFeature() must be called before adding content
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		super.onCreate(savedInstanceState);
		settings = SettingsFactory.create(this);
		keyboardAdapter = KeyboardFactory.create(this, settings.getKeyboard());
		Ctx = this;
		loadLibs();
        initExpansionManager(this);

        Intent intent = getIntent();
		if (intent.getAction()!=null) {
			game = intent.getAction();
			final boolean notWorking = !StorageResolver.isWorking(game);
			final boolean notIdf = !game.endsWith(".idf");
			final boolean notExist = !(new File(StorageResolver.getOutFilePath(StorageResolver.GameDir + game)).exists());
			if (notWorking && (notIdf || notExist)) {
				// Toast.makeText(this, getString(R.string.game)+" \""+game+"\" "+getString(R.string.ag_new), Toast.LENGTH_SHORT).show();
				// Removed i18n in order to not use the R class
				Toast.makeText(this, "Game \""+game+"\" not installed!", Toast.LENGTH_SHORT).show();
				finish();
			}
		} else {		
		Bundle b = intent.getExtras();
		if(b!=null){
			game = b.getString("game");
			idf = b.getString("idf");
		}
		}

		if(!settings.getOvVol()) {
			audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
		}

		portrait = ThemeHelper.isPortrait(this, settings, game, idf);
		if (settings.isEnforceresolution()) {
			if (portrait) {
				setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
			} else {
				setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
			}
		}

		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);

		PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
		wakeLock = pm.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, InsteadApplication.ApplicationName);

		h = new Handler();
		
		IntentFilter filter = new IntentFilter(Intent.ACTION_USER_PRESENT);
		//filter.addAction(Intent.ACTION_SCREEN_OFF);
		//filter.addAction(Intent. ACTION_SCREEN_ON);
		mReceiver= new ScreenReceiver();
		registerReceiver(mReceiver, filter);
		display = getWindowManager().getDefaultDisplay();
		
		//if(first_run){
		first_run=false;

		//Log.d("Game", intent.getStringExtra("game"));
		//if(idf!=null) Log.d("idf", idf);
		//if(game!=null){Log.v("SDL", "Start game: "+game); }else{Log.v("SDL", "Start default game");};
		//finish();
	}

	protected SDLSurfaceBase initSurface() {
		return new SDLSurface(getApplication());
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
	//	MenuInflater inflater = getMenuInflater();
	//	inflater.inflate(R.menu.dummy, menu);
		return true;
	}
	
	@Override
	public void onSaveInstanceState(Bundle savedInstanceState) {
		savedInstanceState.putBoolean("first_run", first_run);
		super.onSaveInstanceState(savedInstanceState);
	}

	@Override
	public void onRestoreInstanceState(Bundle savedInstanceState) {
		super.onRestoreInstanceState(savedInstanceState);
		first_run = savedInstanceState.getBoolean("first_run");
	}

	@Override
	public void onServiceConnected(Messenger m) {
		mRemoteService = DownloaderServiceMarshaller.CreateProxy(m);
		mRemoteService.onClientUpdated(mDownloaderClientStub.getMessenger());
		mRemoteService.setDownloadFlags(IDownloaderService.FLAGS_DOWNLOAD_OVER_CELLULAR);
	}

	@Override
	public void onDownloadStateChanged(int newState) {

	}

	@Override
	public void onDownloadProgress(DownloadProgressInfo progress) {

	}

	public class ScreenReceiver extends	BroadcastReceiver {
		
	@Override
	public void onReceive(Context context, Intent intent){
	/*	
		if (intent.getAction().equals(Intent.ACTION_SCREEN_OFF)){
			Log.d("DUBUG", "InMethod: ACTION_SCREEN_OFF"); 
	    }			 
		if (intent.getAction().equals(Intent.ACTION_SCREEN_ON)){
			Log.d("DUBUG","In Method: ACTION_SCREEN_ON");
		}
	*/ 
		if(intent.getAction().equals(Intent.ACTION_USER_PRESENT)){
			i_s = KOLL;
			/*
			Anton P. Kolosov removed
			refreshHack();
			*/
		}
	}

	}
	
	@Override
	public	void onDestroy(){ 
	super.onDestroy();
	//Log.d("DUBUG","In Method: onDestroy()"); 
	if(mReceiver!=null){
		unregisterReceiver(mReceiver);
		mReceiver=null;
		}
	}

	@Override
	protected void onPause() {
		nativeSave();
		if(settings.getScreenOff())wakeLock.release();
		 Log.v("SDL", "onPause()");
		//if(!first_run) mSurface.suspend();
	    //mSurface = null;
		super.onPause();
	}

	@Override
	protected void onResume() {
		if (null != mDownloaderClientStub) {
			mDownloaderClientStub.connect(this);
		}
		super.onResume();
		if(settings.getScreenOff())wakeLock.acquire();
		 Log.v("SDL", "onResume()");
		// if(!first_run) mSurface.resume();
	}

	@Override
	protected void onStop() {
		if (null != mDownloaderClientStub) {
			mDownloaderClientStub.disconnect(this);
		}
		super.onStop();
	}

	public static void refreshOff(){
		i_s=0;
	}


//	public static native void nativeRefresh();

	/*
	Anton P. Kolosov removed
	private Runnable keySend = new Runnable(){
		public void run(){
			int touchDevId = 0;
			int pointerFingerId = 0;
			//FIXME Заменить на нативный метод из самого инстеда	
			//	nativeRefresh();
			//onNativeKeyDown(KeyEvent.KEYCODE_SHIFT_LEFT);
			onNativeTouch(touchDevId, pointerFingerId, 0, 0, 0, 0);
			onNativeTouch(touchDevId, pointerFingerId, 1, 0, 0, 0);
			//mSurface.flipEGL();
			
			//Log.d("REFRESH", "send key "+Integer.toString(i_s));
			
			i_s-- ;
			if(i_s > 0) refreshHack();
		}
	};
	*/

	/*
	Anton P. Kolosov removed
	private void refreshHack() {
		h.removeCallbacks(keySend);
		h.postDelayed(keySend,WAIT);
	}
	*/

	// C functions we call
	public static native void nativeInit(
			String jnativelog,
			String jpath,
			String jappdata,
			String jgamespath,
			String jres,
			String jgame,
			String jidf,
			String music,
			String owntheme,
			String theme
	);
	public static native void toggleMenu();
	public static native void nativeLowMemory();
	public static native void nativeQuit();
	public static native void nativePause();
	public static native void nativeResume();
	public static native void onNativeResize(int x, int y, int format);
	public static native int onNativePadDown(int device_id, int keycode);
	public static native int onNativePadUp(int device_id, int keycode);
	public static native void onNativeJoy(int device_id, int axis,
										  float value);
	public static native void onNativeHat(int device_id, int hat_id,
										  int x, int y);
	public static native void onNativeKeyDown(int keycode);
	public static native void onNativeKeyUp(int keycode);
	public static native void onNativeKeyboardFocusLost();
	public static native void onNativeTouch(int touchDevId, int pointerFingerId,
											int action, float x,
											float y, float p);
	public static native void onNativeAccel(float x, float y, float z);
	public static native void onNativeSurfaceChanged();
	public static native void onNativeSurfaceDestroyed();
	public static native void nativeFlipBuffers();
	public static native int nativeAddJoystick(int device_id, String name,
											   int is_accelerometer, int nbuttons,
											   int naxes, int nhats, int nballs);
	public static native int nativeRemoveJoystick(int device_id);

	public static native void nativeSave();
	public static native void nativeStop();

    // Java functions called from C

	public static void flipBuffers() {
		SDLActivity.nativeFlipBuffers();
	}

	public static boolean setActivityTitle(String title) {
		// Called from SDLMain() thread and can't directly affect the view
		return getSingleton().sendCommand(COMMAND_CHANGE_TITLE, title);
	}


	private PowerManager.WakeLock wakeLock = null;

	public static int getResY() {
		int y = display.getHeight();
		return y;
	}
	
	public static String getRes() {
		int x = display.getWidth();
		int y = display.getHeight();
		if (portrait) {
			return y + "x" + x;
		} else {
			return x + "x" + y;
		}
	}

	public static String getGame() {
		return game;
	}

	public static String getIdf() {
		return idf;
	}
}

/**
 * Simple nativeInit() runnable
 */
class SDLMain implements Runnable {
	private String dataDir;

	public SDLMain(String dataDir) {
		this.dataDir = dataDir;
	}

	public void run() {
        final String appdata = StorageResolver.getAppDataPath();
        final String gamespath = StorageResolver.getGamesPath();
		Settings settings = SDLActivity.getSettings();
		boolean nativeLogEnabled = settings.isNativelog();
		boolean enforceResolution = settings.isEnforceresolution();
        String nativeLogPath = nativeLogEnabled ? StorageResolver.getStorage() + InsteadApplication.ApplicationName + "/native.log" : null;
		SDLActivity.nativeInit(
				nativeLogPath,
				dataDir,
                appdata,
                gamespath,
				(enforceResolution) ? SDLActivity.getRes() : "-1x-1",
                SDLActivity.getGame(),
                SDLActivity.getIdf(),
				settings.isMusic() ? "Y" : null,  // The exact value is unimportant, if null, then -nosound will be added
				settings.isOwntheme() ? "Y" : null,  // The exact value is unimportant, if NOT null, then -owntheme will be added
				settings.isOwntheme() ? null : settings.getTheme()
        );
	}
}

class SDLSurface extends SDLSurfaceBase {
	private Context context;

	public SDLSurface(Context context) {
		super(context);
		this.context = context;
	}

	// Key events
	public boolean onKey(View v, int keyCode, KeyEvent event) {
		SDLActivity.refreshOff();
		int key = keyCode;

		if (SDLActivity.getSettings().getOvVol()) {
			switch (keyCode) {
				case KeyEvent.KEYCODE_VOLUME_UP:
					key = KeyEvent.KEYCODE_DPAD_UP;
					//key = KeyEvent.KEYCODE_PAGE_UP;
					break;
				case KeyEvent.KEYCODE_VOLUME_DOWN:
					key = KeyEvent.KEYCODE_DPAD_DOWN;
					//key = KeyEvent.KEYCODE_PAGE_DOWN;
					break;
			}
		} else {
			switch (keyCode) {
				case KeyEvent.KEYCODE_VOLUME_UP:
					SDLActivity.setVol(1);
					break;
				case KeyEvent.KEYCODE_VOLUME_DOWN:
					SDLActivity.setVol(-1);
					break;
			}
		}

		return super.onKey(v, keyCode, event);
	}

	@Override
	public void enableSensor(int sensortype, boolean enabled) {
		// super.enableSensor(sensortype, enabled); -- disabled for performance, INSTEAD does not need sensor support
		// see http://en.wildservices.net/2013/10/making-libsdl-2-apps-on-android.html
	}

	private float pX = 0;
	private float pY = 0;
	private long pA = 0;

	// Touch events
	@TargetApi(Build.VERSION_CODES.FROYO)
	public boolean onTouch(View v, MotionEvent event) {
		final int WAIT_TOUCH = 1000;
		final int SQUAR_TOUCH = 10;
		//	final int Y = SDLActivity.getResY() - (SDLActivity.getResY()/3);
		SDLActivity.refreshOff();
		int action = event.getAction();
		float x = event.getX();
		float y = event.getY();
		long s = event.getEventTime();

		if (action == 0) {
			pA = s;
			pX = x;
			pY = y;
		} else if (action == 1) {
			pA = s - pA;
			pX = Math.abs(x - pX);
			pY = Math.abs(y - pY);
			if (pA > WAIT_TOUCH && pX < SQUAR_TOUCH && pY < SQUAR_TOUCH) {
				SDLActivity.getKeyboardAdapter().showKeyboard();
			}
		}

		//Log.d("touch", Integer.toString(Y)+"  "+Float.toString(y));
		// TODO: Anything else we need to pass?
		final int touchDevId = event.getDeviceId();
		final int pointerCount = event.getPointerCount();
		int actionMasked = event.getActionMasked();
		int pointerFingerId;
		int i = -1;
		float p;
		switch (actionMasked) {
			case MotionEvent.ACTION_MOVE:
				for (i = 0; i < pointerCount; i++) {
					pointerFingerId = event.getPointerId(i);
					x = event.getX(i) / mWidth;
					y = event.getY(i) / mHeight;
					p = event.getPressure(i);
					// NB: Pass actionMasked, not action!
					SDLActivity.onNativeTouch(touchDevId, pointerFingerId, actionMasked, x, y, p);
				}
				break;
			case MotionEvent.ACTION_UP:
			case MotionEvent.ACTION_DOWN:
				// Primary pointer up/down, the index is always zero
				i = 0;
			case MotionEvent.ACTION_POINTER_UP:
			case MotionEvent.ACTION_POINTER_DOWN:
				// Non primary pointer up/down
				if (i == -1) {
					i = event.getActionIndex();
				}
				pointerFingerId = event.getPointerId(i);
				x = event.getX(i) / mWidth;
				y = event.getY(i) / mHeight;
				p = event.getPressure(i);
				// NB: Pass actionMasked, not action!
				SDLActivity.onNativeTouch(touchDevId, pointerFingerId, actionMasked, x, y, p);
				break;
			default:
				break;
		}
		return true;
	}

	private String getDataDir() {
		try {
			return context.getDir("data",Context.MODE_PRIVATE).getCanonicalPath() + "/";
		} catch (IOException e) {
			Log.e("SDL", "Cannot retrieve data dir", e);
			throw new RuntimeException(e);
		}
	}
	/**
	 * Added by Anton P. Kolosov
	 * @return
	 */
	protected Thread initThread() {
		final Thread thread = new Thread(new SDLMain(getDataDir()), "SDLThread");
		enableSensor(Sensor.TYPE_ACCELEROMETER, true);
		thread.start();

		// Set up a listener thread to catch when the native thread ends
		new Thread(new Runnable(){
			@Override
			public void run(){
				try {
					thread.join();
				}
				catch(Exception e){}
				finally{
					// Native thread has finished
					if (! SDLActivity.mExitCalledFromJava) {
						SDLActivity.handleNativeExit();
					}
				}
			}
		}).start();
		return thread;
	}
}
