package com.silentlexx.instead;

import java.io.File;

import javax.microedition.khronos.egl.*;
import android.app.*;
import android.content.*;
import android.content.pm.ActivityInfo;
import android.view.*;
import android.widget.Toast;
import android.os.*;
import android.util.Log;
import android.graphics.*;
import android.media.*;

/**
 * SDL Activity
 */
public class SDLActivity extends Activity {
	final static int WAIT = 100;
	final static int KOLL = 10;
	private boolean first_run = true;
	
	// Main components
	private static SDLActivity mSingleton;
	private static SDLSurface mSurface;
	private static Display display;
	private static BroadcastReceiver mReceiver;
	
	// Audio
	private static Thread mAudioThread;
	private static AudioTrack mAudioTrack;
    private static boolean overrVol = false;
	private static String game = null;
	private static String idf = null;
	private static int i_s = KOLL;
	private static boolean keyb = true;
	private static Handler h;
	private  LastGame lastGame;
	private static InputDialog input;
	private static AudioManager audioManager;
	private static Context Ctx; 
	
	// Load the .so
	static {
		System.loadLibrary("smpeg2");
		System.loadLibrary("SDL2");
		System.loadLibrary("SDL2_image");
		System.loadLibrary("SDL2_mixer");
		System.loadLibrary("SDL2_ttf");
		System.loadLibrary("main");
	}

	public static void showKeyboard(Context c){
		if(keyb){
			input.show();
	//		input.focus();
	//		InputMethodManager imm = (InputMethodManager) c.getSystemService(Context.INPUT_METHOD_SERVICE);
	//		imm.showSoftInput(mSurface, InputMethodManager.SHOW_FORCED);
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

	
	public static boolean getOvVol(){
		return overrVol;
	}
	
	public static void inputText(String s){
		//Log.d("Input ",s);
		//nativeInput(s);
		int len = s.length();
		if(len>Globals.IN_MAX){
			s = s.substring(0, Globals.IN_MAX);
			len = s.length();
		}
		
		for(int i=0; i < len; i++){
			char c = s.charAt(i);
			Keys.key(c);
		}
		Keys.Enter();
	}
	
	// Setup
	protected void onCreate(Bundle savedInstanceState) {
		// Log.v("SDL", "onCreate()");
		super.onCreate(savedInstanceState);
		Ctx = this;
		Intent intent = getIntent(); 
		if (intent.getAction()!=null){
			game = intent.getAction();
			  if(Globals.isWorking(game)==false && (game.endsWith(".idf")==false || 
					  (new File(Globals.getOutFilePath(Globals.GameDir
			    				+ game)).exists())==false)){	
				  
					Toast.makeText(this, getString(R.string.game)+" \""+game+"\" "+getString(R.string.ag_new), 
							Toast.LENGTH_SHORT).show();		
					finish();
			  			}
			  
		} else {		
		Bundle b = intent.getExtras();
		if(b!=null){
			game = b.getString("game");
			idf = b.getString("idf");
		}
		}
		
		
		
		lastGame = new LastGame(this);
		overrVol = lastGame.getOvVol();
		keyb = lastGame.getKeyboard();
		if(keyb){
			input = new InputDialog(this, getString(R.string.in_text));
		}

		if(!overrVol){
			audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
		}
		
		
		// if (lastGame.getOreintation()==Globals.PORTRAIT) {
		if(Options.isPortrait()){
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        }
		
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);

		PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
		wakeLock = pm.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK,
				Globals.ApplicationName);


		
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
		
		
		// So we can call stuff from static callbacks
		mSingleton = this;

		// Set up the surface
		mSurface = new SDLSurface(getApplication());
		setContentView(mSurface);
		SurfaceHolder holder = mSurface.getHolder();
		holder.setType(SurfaceHolder.SURFACE_TYPE_GPU);
		//}
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
			refreshHack();
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
		if(lastGame.getScreenOff())wakeLock.release();
		 Log.v("SDL", "onPause()");
		//if(!first_run) mSurface.suspend();
	    //mSurface = null;
		super.onPause();
	}

	@Override
	protected void onResume() {
		super.onResume();
		if(lastGame.getScreenOff())wakeLock.acquire();
		 Log.v("SDL", "onResume()");
		// if(!first_run) mSurface.resume();
	}
	
	public static void refreshOff(){
		i_s=0;
	}


//	public static native void nativeRefresh();
	
	private Runnable keySend = new Runnable(){
		public void run(){

			//FIXME Заменить на нативный метод из самого инстеда	
			//	nativeRefresh();
			//onNativeKeyDown(KeyEvent.KEYCODE_SHIFT_LEFT);
			onNativeTouch(0, 0, 0, 0);
			onNativeTouch(1, 0, 0, 0);
			//mSurface.flipEGL();
			
			//Log.d("REFRESH", "send key "+Integer.toString(i_s));
			
			i_s-- ;
			if(i_s > 0) refreshHack();
		}
	};
	
	private void refreshHack() {
		h.removeCallbacks(keySend);
		h.postDelayed(keySend,WAIT);
	}
	

	
	
	// Messages from the SDLMain thread
	static int COMMAND_CHANGE_TITLE = 1;

	// Handler for the messages
	Handler commandHandler = new Handler() {
		public void handleMessage(Message msg) {
			if (msg.arg1 == COMMAND_CHANGE_TITLE) {
				setTitle((String) msg.obj);
			}
		}
	};
	
	// Send a message from the SDLMain thread
	void sendCommand(int command, Object data) {
		Message msg = commandHandler.obtainMessage();
		msg.arg1 = command;
		msg.obj = data;
		commandHandler.sendMessage(msg);
	}

	// C functions we call
	public static native void nativeInit(String jpath, String jres, String jgame, String jidf);
	public static native void nativeQuit();
	public static native void onNativeResize(int x, int y, int format);
	public static native void onNativeKeyDown(int keycode);
	public static native void onNativeKeyUp(int keycode);
	public static native void onNativeTouch(int action, float x, float y,
			float p);
	public static native void onNativeAccel(float x, float y, float z);
	public static native void nativeRunAudioThread();
	public static native void nativeSave();
	public static native void nativeStop();


	private PowerManager.WakeLock wakeLock = null;

	// Java functions called from C

	public static void createGLContext() {
		mSurface.initEGL();
	}

	public static void flipBuffers() {
		mSurface.flipEGL();
	}

	public static int getResY() {
		int y = display.getHeight();
		return y;
	}
	
	public static String getRes() {
		int x = display.getWidth();
		int y = display.getHeight();
		return x + "x" + y;
	}

	public static String getGame() {
		return game;
	}

	public static String getIdf() {
		return idf;
	}
	
	
	public static void setActivityTitle(String title) {
		// Called from SDLMain() thread and can't directly affect the view
		mSingleton.sendCommand(COMMAND_CHANGE_TITLE, title);
	}

	// Audio
	private static Object buf;

	public static Object audioInit(int sampleRate, boolean is16Bit,
			boolean isStereo, int desiredFrames) {
		int channelConfig = isStereo ? AudioFormat.CHANNEL_CONFIGURATION_STEREO
				: AudioFormat.CHANNEL_CONFIGURATION_MONO;
		int audioFormat = is16Bit ? AudioFormat.ENCODING_PCM_16BIT
				: AudioFormat.ENCODING_PCM_8BIT;
		int frameSize = (isStereo ? 2 : 1) * (is16Bit ? 2 : 1);

		Log.v("SDL", "SDL audio: wanted " + (isStereo ? "stereo" : "mono")
				+ " " + (is16Bit ? "16-bit" : "8-bit") + " "
				+ ((float) sampleRate / 1000f) + "kHz, " + desiredFrames
				+ " frames buffer");

		// Let the user pick a larger buffer if they really want -- but ye
		// gods they probably shouldn't, the minimums are horrifyingly high
		// latency already
		desiredFrames = Math.max(
				desiredFrames,
				(AudioTrack.getMinBufferSize(sampleRate, channelConfig,
						audioFormat) + frameSize - 1)
						/ frameSize);

		mAudioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, sampleRate,
				channelConfig, audioFormat, desiredFrames * frameSize,
				AudioTrack.MODE_STREAM);

		audioStartThread();

		Log.v("SDL",
				"SDL audio: got "
						+ ((mAudioTrack.getChannelCount() >= 2) ? "stereo"
								: "mono")
						+ " "
						+ ((mAudioTrack.getAudioFormat() == AudioFormat.ENCODING_PCM_16BIT) ? "16-bit"
								: "8-bit") + " "
						+ ((float) mAudioTrack.getSampleRate() / 1000f)
						+ "kHz, " + desiredFrames + " frames buffer");

		if (is16Bit) {
			buf = new short[desiredFrames * (isStereo ? 2 : 1)];
		} else {
			buf = new byte[desiredFrames * (isStereo ? 2 : 1)];
		}
		return buf;
	}

	public static void audioStartThread() {
		mAudioThread = new Thread(new Runnable() {
			public void run() {
				mAudioTrack.play();
				nativeRunAudioThread();
			}
		});

		// I'd take REALTIME if I could get it!
		mAudioThread.setPriority(Thread.MAX_PRIORITY);
		mAudioThread.start();
	}

	public static void audioWriteShortBuffer(short[] buffer) {
		for (int i = 0; i < buffer.length;) {
			int result = mAudioTrack.write(buffer, i, buffer.length - i);
			if (result > 0) {
				i += result;
			} else if (result == 0) {
				try {
					Thread.sleep(1);
				} catch (InterruptedException e) {
					// Nom nom
				}
			} else {
				Log.w("SDL", "SDL audio: error return from write(short)");
				return;
			}
		}
	}

	public static void audioWriteByteBuffer(byte[] buffer) {
		for (int i = 0; i < buffer.length;) {
			int result = mAudioTrack.write(buffer, i, buffer.length - i);
			if (result > 0) {
				i += result;
			} else if (result == 0) {
				try {
					Thread.sleep(1);
				} catch (InterruptedException e) {
					// Nom nom
				}
			} else {
				Log.w("SDL", "SDL audio: error return from write(short)");
				return;
			}
		}
	}

	public static void audioQuit() {
		if (mAudioThread != null) {
			try {
				mAudioThread.join();
			} catch (Exception e) {
				Log.v("SDL", "Problem stopping audio thread: " + e);
			}
			mAudioThread = null;

			// Log.v("SDL", "Finished waiting for audio thread");
		}

		if (mAudioTrack != null) {
			mAudioTrack.stop();
			mAudioTrack = null;
		}
	}
	
	
}

/**
 * Simple nativeInit() runnable
 */
class SDLMain implements Runnable {
	public void run() {
		SDLActivity.nativeInit(Globals.getStorage() + Globals.ApplicationName, SDLActivity.getRes(),SDLActivity.getGame(), SDLActivity.getIdf());
	}
	
}

/**
 * SDLSurface. This is what we draw on, so we need to know when it's created in
 * order to do anything useful.
 * 
 * Because of this, that's where we set up the SDL thread
 */
class SDLSurface extends SurfaceView implements SurfaceHolder.Callback,
		View.OnKeyListener, View.OnTouchListener {

	// This is what SDL runs in. It invokes SDL_main(), eventually
	private Thread mSDLThread;

	// EGL private objects
	@SuppressWarnings("unused")
	private EGLContext mEGLContext;
	private EGLSurface mEGLSurface;
	private EGLDisplay mEGLDisplay;

/*
	public void suspend() {
		mSDLThread.suspend();
	}
	
	public void resume(){
		mSDLThread.resume();
	}
*/
	
	// Startup
	public SDLSurface(Context context) {
		super(context);
		getHolder().addCallback(this);

		setFocusable(true);
		setFocusableInTouchMode(true);
		requestFocus();
		setOnKeyListener(this);
		setOnTouchListener(this);

	}

	// Called when we have a valid drawing surface
	public void surfaceCreated(SurfaceHolder holder) {
	}

	// Called when we lose the surface
	public void surfaceDestroyed(SurfaceHolder holder) {
		SDLActivity.nativeQuit();

		// Now wait for the SDL thread to quit
		if (mSDLThread != null) {
			try {
				mSDLThread.join();
			} catch (Exception e) {
				Log.v("SDL", "Problem stopping thread: " + e);
			}
			mSDLThread = null;
		}
	}

	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {
		// Log.v("SDL", "surfaceChanged()");

		int sdlFormat = 0x85151002; // SDL_PIXELFORMAT_RGB565 by default
		switch (format) {
		case PixelFormat.A_8:
			Log.v("SDL", "pixel format A_8");
			break;
		case PixelFormat.LA_88:
			Log.v("SDL", "pixel format LA_88");
			break;
		case PixelFormat.L_8:
			Log.v("SDL", "pixel format L_8");
			break;
		case PixelFormat.RGBA_4444:
			Log.v("SDL", "pixel format RGBA_4444");
			sdlFormat = 0x85421002; // SDL_PIXELFORMAT_RGBA4444
			break;
		case PixelFormat.RGBA_5551:
			Log.v("SDL", "pixel format RGBA_5551");
			sdlFormat = 0x85441002; // SDL_PIXELFORMAT_RGBA5551
			break;
		case PixelFormat.RGBA_8888:
			Log.v("SDL", "pixel format RGBA_8888");
			sdlFormat = 0x86462004; // SDL_PIXELFORMAT_RGBA8888
			break;
		case PixelFormat.RGBX_8888:
			Log.v("SDL", "pixel format RGBX_8888");
			sdlFormat = 0x86262004; // SDL_PIXELFORMAT_RGBX8888
			break;
		case PixelFormat.RGB_332:
			Log.v("SDL", "pixel format RGB_332");
			sdlFormat = 0x84110801; // SDL_PIXELFORMAT_RGB332
			break;
		case PixelFormat.RGB_565:
			Log.v("SDL", "pixel format RGB_565");
			sdlFormat = 0x85151002; // SDL_PIXELFORMAT_RGB565
			break;
		case PixelFormat.RGB_888:
			Log.v("SDL", "pixel format RGB_888");
			// Not sure this is right, maybe SDL_PIXELFORMAT_RGB24 instead?
			sdlFormat = 0x86161804; // SDL_PIXELFORMAT_RGB888
			break;
		default:
			Log.v("SDL", "pixel format unknown " + format);
			break;
		}
		SDLActivity.onNativeResize(width, height, sdlFormat);

		// Now start up the C app thread
		if (mSDLThread == null) {
			mSDLThread = new Thread(new SDLMain(), "SDLThread");
			mSDLThread.start();
		}
	}

	// unused
	public void onDraw(Canvas canvas) {
	}


	
	// EGL functions
	public boolean initEGL() {
		Log.v("SDL", "Starting up");

		try {

			EGL10 egl = (EGL10) EGLContext.getEGL();

			EGLDisplay dpy = egl.eglGetDisplay(EGL10.EGL_DEFAULT_DISPLAY);

			int[] version = new int[2];
			egl.eglInitialize(dpy, version);

			int[] configSpec = {
			//EGL10.EGL_DEPTH_SIZE, 8,
			EGL10.EGL_NONE };
			EGLConfig[] configs = new EGLConfig[1];
			int[] num_config = new int[1];
			egl.eglChooseConfig(dpy, configSpec, configs, 1, num_config);
			EGLConfig config = configs[0];

			EGLContext ctx = egl.eglCreateContext(dpy, config,
					EGL10.EGL_NO_CONTEXT, null);

			EGLSurface surface = egl.eglCreateWindowSurface(dpy, config, this,
					null);

			egl.eglMakeCurrent(dpy, surface, surface, ctx);

			mEGLContext = ctx;
			mEGLDisplay = dpy;
			mEGLSurface = surface;

		} catch (Exception e) {
			Log.v("SDL", e + "");
			for (StackTraceElement s : e.getStackTrace()) {
				Log.v("SDL", s.toString());
			}
		}

		return true;
	}

	// EGL buffer flip
	public void flipEGL() {
		try {
			EGL10 egl = (EGL10) EGLContext.getEGL();
			egl.eglWaitNative(EGL10.EGL_NATIVE_RENDERABLE, null);

			// drawing here
			egl.eglWaitGL();
			egl.eglSwapBuffers(mEGLDisplay, mEGLSurface);

		} catch (Exception e) {
			Log.v("SDL", "flipEGL(): " + e);
			for (StackTraceElement s : e.getStackTrace()) {
				Log.v("SDL", s.toString());
			}
		}
	}

	// Key events
	public boolean onKey(View v, int keyCode, KeyEvent event) {
		SDLActivity.refreshOff();
		int key = keyCode ;
		
		if(SDLActivity.getOvVol()){
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

		
		if (event.getAction() == KeyEvent.ACTION_DOWN) {
		//	Log.v("SDL", "key down: " + keyCode);
			
			SDLActivity.onNativeKeyDown(key);
			return true;
		} else if (event.getAction() == KeyEvent.ACTION_UP) {
		//	 Log.v("SDL", "key up: " + keyCode);
			 
			SDLActivity.onNativeKeyUp(key);
			return true;
		}

		return false;
	}

	public void showKeybord(){
		SDLActivity.showKeyboard(this.getContext());
	//	SDLActivity.onNativeKeyUp(67);
	}

	private float pX =0;
	private float pY =0;
	private long pA = 0;
	// Touch events
	public boolean onTouch(View v, MotionEvent event) {
		final int WAIT_TOUCH = 1000;
		final int SQUAR_TOUCH = 10;
	//	final int Y = SDLActivity.getResY() - (SDLActivity.getResY()/3);
		SDLActivity.refreshOff();
		int action = event.getAction();
		float x = event.getX();
		float y = event.getY();
		float p = event.getPressure();
		long s = event.getEventTime();
		
		
		if(action==0) {
			pA = s;
			pX = x;
			pY = y;
		} else 	if(action==1) {
			pA = s - pA;
			pX = Math.abs(x - pX);
			pY = Math.abs(y - pY);
			if (pA > WAIT_TOUCH && pX < SQUAR_TOUCH && pY < SQUAR_TOUCH){
					showKeybord();
			}
		}
		
		//Log.d("touch", Integer.toString(Y)+"  "+Float.toString(y));
		// TODO: Anything else we need to pass?
		SDLActivity.onNativeTouch(action, x, y, p);
		return true;
	}
	
 


	
}
