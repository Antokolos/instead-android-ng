package com.nlbhub.instead.launcher.universal;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.Intent.ShortcutIconResource;
import android.os.Bundle;
import android.os.Handler;
import android.text.Html;
import android.view.ContextMenu;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.SimpleAdapter.ViewBinder;
import com.nlbhub.instead.STEADActivity;
import com.nlbhub.instead.standalone.ExceptionHandler;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.standalone.StorageResolver;
import com.nlbhub.instead.launcher.simple.Globals;
import com.nlbhub.instead.launcher.simple.LastGame;

public class GameDirs extends ListActivity  implements ViewBinder  {
	private final Handler h = new Handler();
	private final int LS_IDF = 0;
	private final int DELETE_IDF = 1;
	private final int RUN_IDF = 3;
	private int idf_act = LS_IDF;
	private List<String> dnames = new ArrayList<String>();
	private List<String> dtitles = new ArrayList<String>();	
	private static final String LIST_TEXT = "list_text";
	private ListView listView;
	protected int item_index;
    private boolean lwhack = false;
	private ProgressDialog dialog;
	private LastGame lastGame;
    private Favorites favGame; 
	private int listpos;
	private int toppos;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));
		super.onCreate(savedInstanceState);
		dialog = new ProgressDialog(this);
		dialog.setTitle(getString(R.string.wait));
		dialog.setMessage(getString(R.string.init));
		dialog.setIndeterminate(true);
		dialog.setCancelable(false);
        setContentView(R.layout.fghead);
        listView = getListView();
		registerForContextMenu(listView);
		
		lastGame = new LastGame(this);
		favGame = new Favorites(this);
		
		
		listView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {


			@Override
		    public boolean onItemLongClick(AdapterView<?> av, View v, int pos, long id) {

				if (!lwhack) {
					item_index = pos;
					lwhack = true;
					openCtxMenu();
				}
				return true;
		    }


		});

		
		listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
		    @Override
		    public void onItemClick(AdapterView<?> av, View v, int pos, long id) {

		    	 item_index = pos;

		         startApp();
		    	
				}



		});
		
		
		getDirs();
	}
	
	
	private void getDirs(){
	    idf_act = LS_IDF;

		readDirs();
	}
	
	
	private void readDirs(){

		dnames.clear();
		dtitles.clear();

			File f = new File(Globals.getOutFilePath(StorageResolver.GameDir));
			if(f.isDirectory()){
			if(f.list().length>0){
				String files[] = f.list();
				for (String temp : files) {
					File file = new File(f, temp);

					if(idf_act == LS_IDF) {
						if(file.isDirectory()){
						    if(StorageResolver.isWorking(temp)){
				
						    	String title = Globals.getTitle(temp);
						    	if (title==null) title = temp;
						    	dnames.add(title+temp);
						    	dtitles.add(title);
						   
						    }
						} else if(temp.endsWith(".idf")){
				
							dnames.add(temp+temp);
							dtitles.add(temp);
								
						} 
						
					} else if(idf_act == DELETE_IDF || idf_act == RUN_IDF) {
						if(file.isFile() && temp.endsWith(".idf")){

							dnames.add(temp+temp);
							dtitles.add(temp);
							
						}						   
					} 
				}
			}
			}
			
			
			if(dtitles.size()>0){ 
			/*
				if(idf_act == DELETE_IDF){
					menu.setHeaderTitle(getString(R.string.rmidf));
					} else {
					menu.setHeaderTitle(getString(R.string.run));
					}
					*/
				Collections.sort(dtitles);
				listUpdate();
				
				
			} else {
				Toast.makeText(this, getString(R.string.noidf), Toast.LENGTH_SHORT).show();
			}
	}
	
	
	private String getIndexMenu(String s){
		String n = null;
		for(int  i = 0; i < dnames.size(); i++){
			if(dnames.get(i).startsWith(s)){
				return dnames.get(i).substring(s.length(),dnames.get(i).length());			
			}
		}
		return n;
	}
	
	

	/*
	private void onSelectedItem(){
		String s = getIndexMenu(item.getTitle().toString()); 
		if(s==null) return false;
		if(s.endsWith(".idf")){
			if(idf_act == LS_IDF || idf_act == RUN_IDF ){
				startApp(s);	
			} else 
				if(idf_act == DELETE_IDF) {
			       Globals.idf = null;
			       (new File (Globals.getOutFilePath(Globals.GameDir)+s)).delete();	
			       Toast.makeText(this, getString(R.string.delgame), Toast.LENGTH_SHORT).show();				
				}	
				
		} else {
			startApp(s);
		}
	}
	*/
	

	private void listUpdate(){
		listPosSave();
		List<Map<String, ListItem>> listData = new ArrayList<Map<String, ListItem>>();
		
		for(int i=0; i < dtitles.size(); i++){


		listData.add(addListItem(GameManager.getHtmlTagForName(dtitles.get(i)),
				Globals.getIcon(getIndexMenu(dtitles.get(i)))));
				//GameManager.getHtmlTagForComment(getIndexMenu(dtitles.get(i)))
				
		
		}
		
		SimpleAdapter simpleAdapter = new SimpleAdapter(this, listData,
				R.layout.list_item, new String[] { LIST_TEXT },
				new int[] { R.id.list_text });
		simpleAdapter.setViewBinder(this);
		setListAdapter(simpleAdapter);
		listPosRestore();
	}
	
	
	
	
	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {
		super.onCreateContextMenu(menu, v, menuInfo);

		if (lwhack) {

			menu.setHeaderTitle(dtitles.get(item_index));
			menu.add(0, v.getId(), 0, getString(R.string.menustart));
			if ((new File(Globals.getAutoSavePath(getIndexMenu(dtitles.get(item_index))))).exists()) {
				menu.add(0, v.getId(), 0, getString(R.string.menunewstart));
			}			
			if(favGame.isFavorite(getIndexMenu(dtitles.get(item_index)))){
					menu.add(0, v.getId(), 0, getString(R.string.delfromfav));
				} else {
					menu.add(0, v.getId(), 0, getString(R.string.addtofav));
				}
			menu.add(0, v.getId(), 0, getString(R.string.addtodesc));
			if(!getIndexMenu(dtitles.get(item_index)).equals(StorageResolver.BundledGame)){
				menu.add(0, v.getId(), 0, getString(R.string.menudel));			
			}
     	}
		lwhack = false;
	}

	@Override
	public boolean onContextItemSelected(MenuItem item) {
		if (item.getTitle() == getString(R.string.menustart)) {
			startApp();
		} else if (item.getTitle() == getString(R.string.menunewstart)) {
			saveDelete();
		} else if (item.getTitle() == getString(R.string.menudel)) {
			gameDelete();
		} else if (item.getTitle() == getString(R.string.addtofav)) {
		    addFavorites();
		} else if (item.getTitle() == getString(R.string.delfromfav)) {
		    delFavorites();
		} else if (item.getTitle() == getString(R.string.addtodesc)) {
		    addShortcut();
		}
		return true;
	}
	
	private void openCtxMenu() {
		openContextMenu(listView);				
	}
	

	private void gameDelete() {

		DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_POSITIVE:
					Delete();
					break;

				case DialogInterface.BUTTON_NEGATIVE:

					break;
				}
			}
		};

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.warning);
		builder.setTitle(dtitles.get(item_index));
		builder.setMessage(getString(R.string.yesno))
				.setPositiveButton(getString(R.string.yes), dialogClickListener)
				.setNegativeButton(getString(R.string.no), dialogClickListener)
				.show();

	}

    private void Delete() {
	
		ShowDialog();
		dialog.setMessage(getString(R.string.deleting));
		dialog.setCancelable(false);

    	Thread t = new Thread(){
    		@Override 
    		public void run(){
    			h.postDelayed(deleteDir, 100);
    		}
    	};
    	t.start();
	}
    
	public void ShowDialog() {
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
		dialog = new ProgressDialog(this);
		dialog.setIndeterminate(true);
		dialog.setTitle(getString(R.string.wait));
		dialog.setMessage(getString(R.string.init));
		dialog.setCancelable(false);
		if (!dialog.isShowing()) {
			dialog.show();
		}
	}
	
    private Runnable deleteDir = new Runnable() {  
    	public void run(){
    		File d = new File(Globals.getOutFilePath(StorageResolver.GameDir
    				+ getIndexMenu(dtitles.get(item_index))));
    		if(d.isDirectory()){    		
    			StorageResolver.delete(d);
    		} else {
    			d.delete();
    		}
    		if(getIndexMenu(dtitles.get(item_index)).equals(lastGame.getName())){
    			lastGame.clearGame();
    		}
    		Globals.FlagSync = true;
    		lastGame.setFlagSync(Globals.FlagSync);
    		showDeleteMsgDir();
    		getDirs();
    	}
    };
    
    private void showDeleteMsgDir(){
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
		Toast.makeText(
				this,
				getString(R.string.delgame) + ": "
						+ dtitles.get(item_index),
				Toast.LENGTH_LONG).show();    	
    }
    
    
	private void saveDelete() {

		DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_POSITIVE:
					(new File(Globals.getAutoSavePath(getIndexMenu(dtitles.get(item_index))))).delete();
					startApp();
					break;

				case DialogInterface.BUTTON_NEGATIVE:

					break;
				}
			}
		};

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.warning);
		builder.setTitle(dtitles.get(item_index));
		builder.setMessage(getString(R.string.delsaves))
				.setPositiveButton(getString(R.string.yes), dialogClickListener)
				.setNegativeButton(getString(R.string.no), dialogClickListener)
				.show();

	}

	
	private Map<String, ListItem> addListItem(String s, int i) {
		Map<String, ListItem> iD = new HashMap<String, ListItem>();
		ListItem l = new ListItem();
		l.text = s;
		l.icon = i;
		iD.put(LIST_TEXT, l);
		return iD;
	}
	
	private class ListItem {
		public String text;

		public int icon;
	}

	@Override
	public boolean setViewValue(View view, Object data,
		String stringRepresetation) {
	ListItem listItem = (ListItem) data;

	TextView menuItemView = (TextView) view;
	menuItemView.setText(Html.fromHtml(listItem.text));
	menuItemView.setCompoundDrawablesWithIntrinsicBounds(this
			.getResources().getDrawable(listItem.icon), null, null, null);

	return true;
	}

	
	private void startApp(String g) {
			//Log.d("game",g);
			Intent myIntent = new Intent(this, STEADActivity.class);
			Bundle b = new Bundle();
			b.putString("game", g);
			myIntent.putExtras(b);
			startActivity(myIntent);
	}

	private void startApp() {
		startApp(getIndexMenu(dtitles.get(item_index)));
	}
	
	
	private void addShortcut(){  
    	String game = getIndexMenu(dtitles.get(item_index));
		String title = dtitles.get(item_index);
		
	    Intent shortcut = new Intent("com.android.launcher.action.INSTALL_SHORTCUT");

	    shortcut.putExtra(Intent.EXTRA_SHORTCUT_NAME, title);  

        Intent shortcutIntent = new Intent(Intent.ACTION_MAIN);
        shortcutIntent.putExtra(InsteadApplication.ApplicationName, game);
        
	    ComponentName comp = new ComponentName(this.getPackageName(), ".Shortcut");  
	    shortcutIntent.setComponent(comp);
	    shortcut.putExtra(Intent.EXTRA_SHORTCUT_INTENT, shortcutIntent); 
	    
	    ShortcutIconResource iconRes = Intent.ShortcutIconResource.fromContext(this, 
	    		Globals.getIcon(game));  
	    shortcut.putExtra(Intent.EXTRA_SHORTCUT_ICON_RESOURCE, iconRes);  

	    sendBroadcast(shortcut);  
	}

	private void addFavorites(){
    	String game = getIndexMenu(dtitles.get(item_index));
		String title = dtitles.get(item_index);
		
		favGame.add(game, title);
		Toast.makeText(this, getString(R.string.game)+" \""+title+"\" "+getString(R.string.addedfav), 
				Toast.LENGTH_SHORT).show();
	}

	private void delFavorites(){
    	String game = getIndexMenu(dtitles.get(item_index));
		String title = dtitles.get(item_index);
				
		favGame.remove(game);
		Toast.makeText(this, getString(R.string.game)+" \""+title+"\" "+getString(R.string.deletedfav), 
				Toast.LENGTH_SHORT).show();
	}
	
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.gdmenu1, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		switch (item.getItemId()) {
		case R.id.refresh:
			getDirs();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}
	

	private void listPosSave() {
		listpos = listView.getFirstVisiblePosition();
		View firstVisibleView = listView.getChildAt(0);
		toppos = (firstVisibleView == null) ? 0 : firstVisibleView.getTop();
	}

	private void listPosRestore() {
		listView.setSelectionFromTop(listpos, toppos);
	}
	
}
