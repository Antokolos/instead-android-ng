package com.nlbhub.instead.universal;


import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.Intent.ShortcutIconResource;
import android.os.Bundle;
import android.text.Html;
import android.view.ContextMenu;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.SimpleAdapter.ViewBinder;
import com.nlbhub.instead.R;
import com.nlbhub.instead.standalone.Globals;
import com.nlbhub.instead.SDLActivity;

public class FavoritList extends ListActivity  implements ViewBinder  {
	private static final String LIST_TEXT = "list_text";
	private ListView listView;
	protected int item_index;
    private boolean lwhack = false;
	private int listpos;
	private int toppos;
    private Favorites favGame; 
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        setContentView(R.layout.fvhead);
        listView = getListView();
		registerForContextMenu(listView);
		
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
		
		
		listUpdate();
	}
	

	private void listUpdate(){
		listPosSave();
		List<Map<String, ListItem>> listData = new ArrayList<Map<String, ListItem>>();
		
		int n = favGame.size();
		
		for(int i = 0; i < n ; i++){
		listData.add(addListItem(GameManager.getHtmlTagForName(favGame.getTitle(i)),
				R.drawable.star));
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

			menu.setHeaderTitle(favGame.getTitle(item_index));
			
		  if(Globals.isWorking(favGame.getGame(item_index))
				  || (favGame.getGame(item_index).endsWith(".idf") && 
						  (new File(Globals.getOutFilePath(Globals.GameDir
				    				+ favGame.getGame(item_index))).exists()))){	
			menu.add(0, v.getId(), 0, getString(R.string.menustart));
			if ((new File(Globals.getAutoSavePath(favGame.getGame(item_index)))).exists()) {
				menu.add(0, v.getId(), 0, getString(R.string.menunewstart));
			}
		  }
		  	menu.add(0, v.getId(), 0, getString(R.string.addtodesc));
			menu.add(0, v.getId(), 0, getString(R.string.delfromfav));


     	}
		lwhack = false;
	}

	@Override
	public boolean onContextItemSelected(MenuItem item) {
		if (item.getTitle() == getString(R.string.menustart)) {
			startApp();
		} else if (item.getTitle() == getString(R.string.menunewstart)) {
			saveDelete();
		} else if (item.getTitle() == getString(R.string.delfromfav)) {
			delFavorites();
		} else
			if (item.getTitle() == getString(R.string.addtodesc)) {
				addShortcut();
			}
		return true;
	}
	
	
	private void saveDelete() {

		DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_POSITIVE:
					(new File(Globals.getAutoSavePath(favGame.getGame(item_index)))).delete();
					startApp();
					break;

				case DialogInterface.BUTTON_NEGATIVE:

					break;
				}
			}
		};

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.warning);
		builder.setTitle(favGame.getTitle(item_index));
		builder.setMessage(getString(R.string.delsaves))
				.setPositiveButton(getString(R.string.yes), dialogClickListener)
				.setNegativeButton(getString(R.string.no), dialogClickListener)
				.show();

	}

	
	private void openCtxMenu() {
		openContextMenu(listView);				
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

	
	private void startApp() {
			String game = favGame.getGame(item_index);
			String title = favGame.getTitle(item_index);
			
		  if(Globals.isWorking(game) || (game.endsWith(".idf") && 
				  (new File(Globals.getOutFilePath(Globals.GameDir
		    				+ game)).exists()))){	
			Intent myIntent = new Intent(this, SDLActivity.class);
			Bundle b = new Bundle();
			b.putString("game", game);
			myIntent.putExtras(b);
			startActivity(myIntent);
		  } else {
				Toast.makeText(this, getString(R.string.game)+" \""+title+"\" "+getString(R.string.ag_new), 
						Toast.LENGTH_SHORT).show();			  
		  }
	}


	private void addShortcut(){  
    	String game = favGame.getGame(item_index);
		String title = favGame.getTitle(item_index);
		
	    Intent shortcut = new Intent("com.android.launcher.action.INSTALL_SHORTCUT");

	    shortcut.putExtra(Intent.EXTRA_SHORTCUT_NAME, title);  

        Intent shortcutIntent = new Intent(Intent.ACTION_MAIN);
        shortcutIntent.putExtra(Globals.ApplicationName, game);
        
	    ComponentName comp = new ComponentName(this.getPackageName(), ".Shortcut");  
	    shortcutIntent.setComponent(comp);
	    shortcut.putExtra(Intent.EXTRA_SHORTCUT_INTENT, shortcutIntent); 
	    
	    ShortcutIconResource iconRes = Intent.ShortcutIconResource.fromContext(this,
	    		Globals.getIcon(game));  
	    shortcut.putExtra(Intent.EXTRA_SHORTCUT_ICON_RESOURCE, iconRes);  

	    sendBroadcast(shortcut);  
	}
	

	private void delFavorites(){
    	String game = favGame.getGame(item_index);
		String title = favGame.getTitle(item_index);
		
		favGame.remove(game);
		Toast.makeText(this, getString(R.string.game)+" \""+title+"\" "+getString(R.string.deletedfav), 
				Toast.LENGTH_SHORT).show();
		listUpdate();
	}
	
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.fvmenu1, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		switch (item.getItemId()) {
		case R.id.clean:
			cleanFav();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}


	private void cleanFav() {
		DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_POSITIVE:
					favGame.clear();
					listUpdate();
					break;

				case DialogInterface.BUTTON_NEGATIVE:

					break;
				}
			}
		};

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.warning);
		builder.setTitle(getString(R.string.app_name));
		builder.setMessage(getString(R.string.clearfav)+"?")
				.setPositiveButton(getString(R.string.yes), dialogClickListener)
				.setNegativeButton(getString(R.string.no), dialogClickListener)
				.show();

		
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

