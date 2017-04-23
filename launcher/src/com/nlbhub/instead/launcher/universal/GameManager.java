package com.nlbhub.instead.launcher.universal;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import android.app.AlertDialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.Intent.ShortcutIconResource;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.Html;
import android.util.Log;
import android.view.*;
import android.view.ContextMenu.ContextMenuInfo;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.SimpleAdapter.ViewBinder;
import android.widget.TextView;
import android.widget.Toast;
import com.nlbhub.instead.STEADActivity;
import com.nlbhub.instead.launcher.simple.FilterConstants;
import com.nlbhub.instead.standalone.ExceptionHandler;
import com.nlbhub.instead.standalone.InsteadApplication;
import com.nlbhub.instead.launcher.R;
import com.nlbhub.instead.standalone.MainMenuAbstract;
import com.nlbhub.instead.standalone.StorageResolver;
import com.nlbhub.instead.launcher.simple.Globals;
import com.nlbhub.instead.launcher.simple.LastGame;

public class GameManager extends ListActivity implements ViewBinder {

	private final int MENU_LIST=1;
	private final int MENU_FILTER=2;
	private int menu_mode = MENU_LIST;
	private int item_index = -1;
	private String g;
	private int filter = FilterConstants.ALL;
	private GameList gl;
	private List<Integer> index;
	private ProgressDialog dialog;
	private static final String LIST_TEXT = "list_text";
	private int listNo = Globals.BASIC;
	private boolean lwhack = false;
	private String lang_filter = Globals.Lang.ALL;
	protected boolean onpause = false;
	private boolean dwn = false;
	private boolean isdwn = false;
	private  boolean list_fresh = true;
	private GameDownloader downloader = null;
	private Button basic_btn;
	private Button alter_btn;
	private Button btn_sync;
	private Button btn_filtr;
	private ImageView img_filtr;
    private	Favorites favGame;
	//private boolean fscan = false;
	
	private int listpos;
	private int toppos;
	private ListView listView;
	private LastGame lastGame;
	private final Handler h = new Handler();

	private ArrayList<String> filesCheckList;

	protected int getBasicListNo() {
        return Globals.BASIC;
    }

    protected int getAlterListNo() {
        return Globals.ALTER;
    }

    protected String getGameListFileName() {
        return Globals.GameListFileName;
    }

    protected String getGameListAltFileName() {
        return Globals.GameListAltFileName;
    }

    protected int getLayoutResID() {
        return R.layout.gmtab;
    }

    protected void createAndRunXmlDownloader() {
        new XmlDownloader(this, dialog, listNo);
    }

    protected ProgressDialog getDialog() {
        return dialog;
    }

    protected int getListNo() {
        return listNo;
    }

    @Override
	protected void onCreate(Bundle savedInstanceState) {
		Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));
		super.onCreate(savedInstanceState);
		
		index = new ArrayList<Integer>();
		dialog = new ProgressDialog(this);
		dialog.setTitle(getString(R.string.wait));
		dialog.setMessage(getString(R.string.init));
		dialog.setIndeterminate(true);
		dialog.setCancelable(false);
        setContentView(getLayoutResID());
    	lastGame = new LastGame(this);
    	favGame = new Favorites(this);
        filter = lastGame.getFiltr();
        listNo = lastGame.getListNo();
        lang_filter = lastGame.getLang();
        listView = getListView();
		registerForContextMenu(listView);

		basic_btn = (Button) findViewById(R.id.basic_btn);
		basic_btn.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				listNo = getBasicListNo();
				lastGame.setListNo(listNo);
				list_fresh = true;
				setTabs();
				checkXml();
			}
		});

		btn_sync = (Button) findViewById(R.id.btn_sync);

		btn_sync.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {

				listDownload();	
			}
		});

		btn_filtr = (Button) findViewById(R.id.btn_filtr);

		btn_filtr.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				setFilter();
			}
		});

		
		img_filtr = (ImageView) findViewById(R.id.img_filtr);

		img_filtr.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				btn_filtr.performClick();
			}
		});
		
		setFiltrImg();
		
		alter_btn = (Button) findViewById(R.id.alter_btn);

		alter_btn.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View arg0) {
				listNo = getAlterListNo();
				lastGame.setListNo(listNo);
				list_fresh = true;
				setTabs();
				checkXml();
			}
		});

		
		listView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
		    @Override
		    public boolean onItemLongClick(AdapterView<?> av, View v, int pos, long id) {

				if (!lwhack) {
					item_index = pos;
					g = gl.getInf(GameList.TITLE, index.get(item_index));
					lwhack = true;
					menu_mode = MENU_LIST;
					openCtxMenu();
				}
				return true;
		    }
		});

		
		listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
		    @Override
		    public void onItemClick(AdapterView<?> av, View v, int pos, long id) {

		    	item_index = pos;
					g = gl.getInf(GameList.TITLE, index.get(item_index));
					openGame();
				}

		});
		filesCheckList = new ArrayList<String>();

		checkXml();
	}

	private void setFilter(){
		lwhack = true;
		menu_mode = MENU_FILTER;
		openCtxMenu();		
	}
	
	private void openGame(){
		if (gl.getFlag(index.get(item_index)) == FilterConstants.INSTALLED ||
				gl.getFlag(index.get(item_index)) == FilterConstants.UPDATE	) {
			startApp();
			} else {
			gameDownload();
			}
	}
	
	private void openCtxMenu(){
		openContextMenu(listView);		
	}
	
	private void setTabsG() {
        final int basicListNo = getBasicListNo();
        final int alterListNo = getAlterListNo();
        if (listNo == basicListNo) {
            basic_btn.setTextColor(Color.rgb(0, 0, 0));
            alter_btn.setTextColor(Color.rgb(200, 200, 200));

            basic_btn.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_a));
            alter_btn.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_g));

        } else if (listNo == alterListNo) {
			basic_btn.setTextColor(Color.rgb(200, 200, 200));
			alter_btn.setTextColor(Color.rgb(0, 0, 0));

			basic_btn.setBackgroundDrawable(getResources().getDrawable(
					R.drawable.tab_g));
			alter_btn.setBackgroundDrawable(getResources().getDrawable(
					R.drawable.tab_a));
		}

	}

	private void setTabs() {
        final int basicListNo = getBasicListNo();
        final int alterListNo = getAlterListNo();
        if (listNo == basicListNo) {
            basic_btn.setTextColor(Color.rgb(0, 0, 0));
            alter_btn.setTextColor(Color.rgb(200, 200, 200));

            basic_btn.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_c));
            alter_btn.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab));

        } else if (listNo == alterListNo) {
			basic_btn.setTextColor(Color.rgb(200, 200, 200));
			alter_btn.setTextColor(Color.rgb(0, 0, 0));

			basic_btn.setBackgroundDrawable(getResources().getDrawable(
					R.drawable.tab));
			alter_btn.setBackgroundDrawable(getResources().getDrawable(
					R.drawable.tab_c));
		}

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

	public void ShowDialogCancel() {
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
		dialog = new ProgressDialog(this);
		// dialog.setIndeterminate(true);
		dialog.setIndeterminate(false);
		dialog.setTitle(getString(R.string.waitdwn) + " \"" + g + "\"...");
		dialog.setMessage(getString(R.string.init));
		dialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		dialog.setMax(gl.getByteSize(index.get(item_index)));
		dialog.setProgress(0);
		dialog.setCancelable(true);
		dialog.setButton(getString(R.string.cancel),
				new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int whichButton) {
						dialog.dismiss();
					}
				});
		if (!dialog.isShowing()) {
			dialog.show();
		}
	}


	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {
		super.onCreateContextMenu(menu, v, menuInfo);
		if (lwhack) {
		
			if(menu_mode==MENU_LIST){
			menu.setHeaderTitle(g);

			if (gl.getFlag(index.get(item_index)) == FilterConstants.INSTALLED) {
				menu.add(0, v.getId(), 0, getString(R.string.menustart));
				if ((new File(Globals.getAutoSavePath(gl.getInf(GameList.NAME,
					index.get(item_index))))).exists()) {
					menu.add(0, v.getId(), 0, getString(R.string.menunewstart));
				}
				if(favGame.isFavorite(gl.getInf(GameList.NAME,
					index.get(item_index)))){
					menu.add(0, v.getId(), 0, getString(R.string.delfromfav));
				} else {
					menu.add(0, v.getId(), 0, getString(R.string.addtofav));
				}
				
				menu.add(0, v.getId(), 0, getString(R.string.addtodesc));
				menu.add(0, v.getId(), 0, getString(R.string.menudel));
				
			}

			if (gl.getFlag(index.get(item_index)) == FilterConstants.NEW) {
				menu.add(0, v.getId(), 0, getString(R.string.menudown));
			}

			if (gl.getFlag(index.get(item_index)) == FilterConstants.UPDATE) {
				menu.add(0, v.getId(), 0, getString(R.string.menustart));
				if ((new File(Globals.getAutoSavePath(gl.getInf(GameList.NAME,
						index.get(item_index))))).exists()) {
					menu.add(0, v.getId(), 0, getString(R.string.menunewstart));
				}
				menu.add(0, v.getId(), 0, getString(R.string.menuupd));
				if(favGame.isFavorite(gl.getInf(GameList.NAME,
						index.get(item_index)))){
						menu.add(0, v.getId(), 0, getString(R.string.delfromfav));
					} else {
						menu.add(0, v.getId(), 0, getString(R.string.addtofav));
					}
				menu.add(0, v.getId(), 0, getString(R.string.addtodesc));
				menu.add(0, v.getId(), 0, getString(R.string.menudel));
			}

			menu.add(0, v.getId(), 0, getString(R.string.agame));
			} else 
				if(menu_mode==MENU_FILTER){
				menu.setHeaderTitle(getString(R.string.filtr));
				menu.add(0, v.getId(), 0, getString(R.string.all));
				menu.add(0, v.getId(), 0, getString(R.string.installed));
				menu.add(0, v.getId(), 0, getString(R.string.isnew));
				menu.add(0, v.getId(), 0, getString(R.string.isupd));
			
			}
		}
		lwhack = false;
	}

	@Override
	public boolean onContextItemSelected(MenuItem item) {
		// Item options menu
		if (item.getTitle() == getString(R.string.menustart)) {
			startApp();
		} else if (item.getTitle() == getString(R.string.menunewstart)) {
			saveDelete();
		} else if (item.getTitle() == getString(R.string.menudel)) {
			gameDelete();
		} else if (item.getTitle() == getString(R.string.menuupd)) {
			gameUpdate();
		} else if (item.getTitle() == getString(R.string.menudown)) {
			gameDownload();
		} else if (item.getTitle() == getString(R.string.agame)) {
			startAbout();
		} else if (item.getTitle() == getString(R.string.addtodesc)) {
		    addShortcut();
		} else if (item.getTitle() == getString(R.string.addtofav)) {
		    addFavorites();
		} else if (item.getTitle() == getString(R.string.delfromfav)) {
		    delFavorites();
		} else 
		
		{
			//FILTER Menu
			 if (item.getTitle() == getString(R.string.installed)) {
				filter = FilterConstants.INSTALLED;
				lastGame.setFiltr(filter);
				list_fresh = true;
				setFiltrImg();
				listUpdate();
			} else if (item.getTitle() == getString(R.string.isnew)) {
				filter = FilterConstants.NEW;
				lastGame.setFiltr(filter);
				list_fresh = true;
				setFiltrImg();
				listUpdate();
			} else if (item.getTitle() == getString(R.string.isupd)) {
				filter = FilterConstants.UPDATE;
				lastGame.setFiltr(filter);
				list_fresh = true;
				setFiltrImg();
				listUpdate();
			} else if (item.getTitle() == getString(R.string.all)) {
				filter = FilterConstants.ALL;
				lastGame.setFiltr(filter);
				list_fresh = true;
				setFiltrImg();
				listUpdate();
			} else	return false;
		}
		return true;
	}
	
	private void setFiltrImg(){
		switch (filter){
		case FilterConstants.INSTALLED: img_filtr.setImageResource(R.drawable.installed); break;
		case FilterConstants.ALL: img_filtr.setImageResource(R.drawable.all); break;
		case FilterConstants.NEW: img_filtr.setImageResource(R.drawable.newinstall); break;
		case FilterConstants.UPDATE: img_filtr.setImageResource(R.drawable.update); break;
		default: img_filtr.setImageResource(R.drawable.all);
		}
		
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.gmmenu1, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		item_index = -1;
		switch (item.getItemId()) {
		case R.id.upd_menu_btn:
			listDownload();
			return true;
	
		case R.id.flt_menu_btn:
				setFilter();
			return true;

		case R.id.langru_menu_btn:
			lang_filter = Globals.Lang.RU;
			lastGame.setLang(lang_filter);
			list_fresh = true;
			listUpdate();
			return true;
		case R.id.langen_menu_btn:
			lang_filter = Globals.Lang.EN;
			lastGame.setLang(lang_filter);
			list_fresh = true;
			listUpdate();
			return true;
		case R.id.langall_menu_btn:
			lang_filter = Globals.Lang.ALL;
			lastGame.setLang(lang_filter);
			list_fresh = true;
			listUpdate();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	private int getFlagId(int i) {



		switch (gl.getFlag(i)) {
		case FilterConstants.NEW:
			return R.drawable.newinstall;

		case FilterConstants.INSTALLED:
			if (gl.getInf(GameList.NAME, i).equals(lastGame.getName())) {
				return R.drawable.lastgame;
			}
			return R.drawable.installed;

		case FilterConstants.UPDATE:
			return R.drawable.update;

		default:
			return R.drawable.newinstall;
		}
	}

	private String getFlagStringId(int i) {
		String s = "";
		switch (gl.getFlag(i)) {
		case FilterConstants.NEW:
			s = getString(R.string.ag_new);
			break;
		case FilterConstants.INSTALLED:
			s = getString(R.string.ag_installed);
			break;
		case FilterConstants.UPDATE:
			s = getString(R.string.ag_update);
			break;
		default:
			s = getString(R.string.ag_new);
		}
		return getHtmlTagForComment(s);
	}

	public static String getHtmlTagForComment(String s) {
		return  "<br><small><i>" + s + "</i></small>";
	}

	public void onError(String s) {

		dialog.setCancelable(true);
		dwn = false;
		downloader = null;
		Log.e("Instead-NG ERROR: ", s);

	}

	private Map<String, ListItem> addListItem(String s, int i) {
		Map<String, ListItem> iD = new HashMap<String, ListItem>();
		ListItem l = new ListItem();
		l.text = s;
		l.icon = i;
		iD.put(LIST_TEXT, l);
		return iD;
	}

	private String getGameListName(int n) {
        final int basicListNo = getBasicListNo();
        final int alterListNo = getAlterListNo();
        if (n == basicListNo) {
            return getGameListFileName();
        } else if (n == alterListNo) {
            return getGameListAltFileName();
        } else {
			return getGameListFileName();
		}
	}

	public static String getHtmlTagForName(String s) {
		return "<b>" + s + "</b>";
	}

	public void listUpdate() {

		listPosSave();

		gl = new GameList(this, getGameListName(listNo));
		lastGame.setFlagSync(Globals.FlagSync);
		List<Map<String, ListItem>> listData = new ArrayList<Map<String, ListItem>>();

		int j = 0;

		for (int i = 0; i < gl.getLength(); i++) {

			if (lang_filter.equals(gl.getInf(GameList.LANG, i))
					|| lang_filter.equals("")) {
				if (filter == FilterConstants.ALL) {

					listData.add(addListItem(
							getHtmlTagForName(gl.getInf(GameList.TITLE, i))
									+ getFlagStringId(i), getFlagId(i)));

					index.add(j, i);
					j++;
				}
				if (filter == FilterConstants.INSTALLED) {
					if (gl.getFlag(i) == FilterConstants.INSTALLED) {
						listData.add(addListItem(
								getHtmlTagForName(gl.getInf(GameList.TITLE, i))
										+ getFlagStringId(i), getFlagId(i)));

						index.add(j, i);
						j++;
					}
				}

				if (filter == FilterConstants.UPDATE) {
					if (gl.getFlag(i) == FilterConstants.UPDATE) {
						listData.add(addListItem(
								getHtmlTagForName(gl.getInf(GameList.TITLE, i))
										+ getFlagStringId(i), getFlagId(i)));

						index.add(j, i);
						j++;
					}
				}

				if (filter == FilterConstants.NEW) {
					if (gl.getFlag(i) == FilterConstants.NEW) {
						listData.add(addListItem(
								getHtmlTagForName(gl.getInf(GameList.TITLE, i))
										+ getFlagStringId(i), getFlagId(i)));

						index.add(j, i);
						j++;
					}
				}

			}
		}

		// FIXME android 1.6 refresh bug workaround
		if (Build.VERSION.SDK_INT == Build.VERSION_CODES.DONUT) {
			setTabsG();
		} else {
			setTabs();
		}
		
		SimpleAdapter simpleAdapter = new SimpleAdapter(this, listData,
				R.layout.list_item, new String[] { LIST_TEXT },
				new int[] { R.id.list_text });
		simpleAdapter.setViewBinder(this);
		setListAdapter(simpleAdapter);


		
		if(!list_fresh) {
			listPosRestore();
   		} else {
   			list_fresh = false;	
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

	private void listDownload() {
		dialog.setMessage(getString(R.string.init));
		ShowDialog();
		//fscan = true;
		Globals.FlagSync = true;
		lastGame.setFlagSync(Globals.FlagSync);
		createAndRunXmlDownloader();
	}

	private void Download() {
		dialog.setMessage(getString(R.string.init));

		ShowDialogCancel();

		dialog.setCancelable(true);

		dwn = true;
		//fscan = true;
		Globals.FlagSync = true;
		lastGame.setFlagSync(Globals.FlagSync);
		downloader = new GameDownloader(this, gl.getInf(GameList.URL,
				index.get(item_index)), gl.getInf(GameList.NAME,
				index.get(item_index)), dialog);

	}

	public void listIsDownload() {
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
	}

	public void gameIsDownload() {
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
		dwn = false;
		isdwn = false;

		downloader = null;
		try {
			Toast.makeText(
					this,
					getString(R.string.gdwncompl) + ": "
							+ gl.getInf(GameList.TITLE, index.get(item_index)),
					Toast.LENGTH_LONG).show();
		} catch (ArrayIndexOutOfBoundsException e) {
		}

			list_fresh = false;
			listUpdate();

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
		builder.setTitle(g);
		builder.setMessage(getString(R.string.yesno))
				.setPositiveButton(getString(R.string.yes), dialogClickListener)
				.setNegativeButton(getString(R.string.no), dialogClickListener)
				.show();

	}

	private void saveDelete() {

		DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_POSITIVE:
					(new File(Globals.getAutoSavePath(gl.getInf(GameList.NAME,
							index.get(item_index))))).delete();
					startApp();
					break;

				case DialogInterface.BUTTON_NEGATIVE:

					break;
				}
			}
		};

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.warning);
		builder.setTitle(g);
		builder.setMessage(getString(R.string.delsaves))
				.setPositiveButton(getString(R.string.yes), dialogClickListener)
				.setNegativeButton(getString(R.string.no), dialogClickListener)
				.show();

	}

    private Runnable deleteDir = new Runnable() {  
    	public void run(){
    		StorageResolver.delete(new File(Globals.getOutFilePath(StorageResolver.GameDir
    				+ gl.getInf(GameList.NAME, index.get(item_index)))));    		    		
    		if(gl.getInf(GameList.NAME, index.get(item_index)).equals(lastGame.getName())){
    			lastGame.clearGame();
    		}
    		Globals.FlagSync = true;
    		lastGame.setFlagSync(Globals.FlagSync);
    		showDeleteMsgDir();
    		listUpdate();
    	}
    };
	
    
    private void showDeleteMsgDir(){
		if (dialog.isShowing()) {
			dialog.dismiss();
		}
		Toast.makeText(
				this,
				getString(R.string.delgame) + ": "
						+ gl.getInf(GameList.TITLE, index.get(item_index)),
				Toast.LENGTH_LONG).show();    	
    }
    
    private void Delete() {
	//	listPosSave();
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

	private void gameDownload() {

		DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case DialogInterface.BUTTON_POSITIVE:
					Download();
					break;

				case DialogInterface.BUTTON_NEGATIVE:

					break;
				}
			}
		};

		
		
		String s = gl.getInf(GameList.SIZE, index.get(item_index));
	
		//FIXME workaround for size of URQ module
		if(listNo == getBasicListNo()){
			if(item_index==gl.getIndexOfURQ()) s = gl.getInf(GameList.SIZE, item_index);
		}
		
		
		if (s == null)
			s = getString(R.string.na);

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setIcon(R.drawable.question);
		builder.setTitle(g);
		builder.setMessage(
				getString(R.string.dwnsize) + " " + s + " " + ".\n"
						+ getString(R.string.sizeyesno))
				.setPositiveButton(getString(R.string.yes), dialogClickListener)
				.setNegativeButton(getString(R.string.no), dialogClickListener)
				.show();

	}

	private void gameUpdate() {
		// gameDelete();
		gameDownload();
	}

	private void startAbout() {
		Intent myIntent = new Intent(this, AboutGame.class);
		Bundle b = new Bundle();
		b.putString("name", gl.getInf(GameList.NAME, index.get(item_index)));
		b.putString("title", gl.getInf(GameList.TITLE, index.get(item_index)));
		b.putString("lang", gl.getInf(GameList.LANG, index.get(item_index)));
		b.putString("ver", gl.getInf(GameList.VERSION, index.get(item_index)));
		b.putString("file", gl.getInf(GameList.URL, index.get(item_index)));
		b.putString("url", gl.getInf(GameList.DESCURL, index.get(item_index)));
		b.putString("size", gl.getInf(GameList.SIZE, index.get(item_index)));
		b.putInt("flag", gl.getFlag(index.get(item_index)));
		b.putInt("INSTALLED", FilterConstants.INSTALLED);
		b.putInt("UPDATE", FilterConstants.UPDATE);
		b.putInt("NEW", FilterConstants.NEW);
		myIntent.putExtras(b);
		startActivity(myIntent);

	}

	private void startApp() {
		if (checkInstall()) {
			String game = gl.getInf(GameList.NAME, index.get(item_index));
			String title = gl.getInf(GameList.TITLE, index.get(item_index));
			if(!isURQ(title)) return;
			lastGame.setLast(title, game);
			Intent myIntent = new Intent(this, STEADActivity.class);
			Bundle b = new Bundle();
			b.putString("game", game);
			myIntent.putExtras(b);
			startActivity(myIntent);
		}
	}
	

	@Override
	protected void onPause() {
		// Log.d(Globals.TAG, "GM: Pause");

		if (dialog.isShowing()) {
			dialog.dismiss();
		}
		onpause = true;
		super.onPause();
	}

	@Override
	protected void onStop() {
		// Log.d(Globals.TAG, "GM: Pause");
		super.onStop();
	}

	@Override
	protected void onResume() {
		super.onResume();
		if (downloader != null) {
			if (downloader.DownloadComplete) {
				if (dialog.isShowing()) {
					dialog.dismiss();
				}
				gameIsDownload();
			} else {
				if (onpause && !dialog.isShowing()) {
					dialog.show();
				}
			}
		} else {
			if (dialog.isShowing()) {
				dialog.dismiss();
			}
			// FIXME hz
			if (isdwn) {
				gameIsDownload();
			}
		}
//		checkXml();
		onpause = false;
		// Log.d(Globals.TAG, "GM: Resume");
	}

	public boolean getStopDwn() {
		if (!onpause) {
			if (!dialog.isShowing() && dwn) {
				dwn = false;
				return true;
			}
		}
		return false;
	}

	public void sayCancel() {
		downloader = null;
		// listUpdate();
		Toast.makeText(
				this,
				getString(R.string.dwncancel) + ": "
						+ gl.getInf(GameList.TITLE, index.get(item_index)),
				Toast.LENGTH_LONG).show();
	}

	protected void checkXml() {
		final String gameListName = getGameListName(listNo);
		if (!(new File(getFilesDir() + "/" + gameListName).exists()) || !isGameListChecked(gameListName)) {
			listDownload();
		} else {
			listUpdate();
		}
	}

	public void checkCurrentList() {
		final String gameListName = getGameListName(listNo);
		filesCheckList.add(gameListName);
		View entry = findViewById(R.id.loadingText);
		if (entry != null) {
			((ViewManager) entry.getParent()).removeView(entry);
		}
	}

	private boolean isGameListChecked(String gameListName) {
		return filesCheckList.contains(gameListName);
	}

	@Override
	protected void onStart() {
		super.onStart();
		// Log.d(Globals.TAG, "GM: Resume");
	}

	public void setDownGood() {
		dwn = false;
		isdwn = true;
	}

	public void setXmlGood() {
		dwn = false;
	}

	public boolean checkInstall() {
		return MainMenuAbstract.checkInstall(this);
	}

	private class ListItem {
		public String text;

		public int icon;
	}

	@Override
	public void onSaveInstanceState(Bundle savedInstanceState) {
		savedInstanceState.putBoolean("onpause", onpause);
		savedInstanceState.putBoolean("dwn", dwn);
		savedInstanceState.putBoolean("isdwn", isdwn);
		savedInstanceState.putBoolean("list_fresh", list_fresh);
//		savedInstanceState.putBoolean("list_save", list_save);
		savedInstanceState.putInt("listpos", listpos);
		savedInstanceState.putInt("toppos", toppos);
		savedInstanceState.putStringArrayList("filesCheckList", filesCheckList);
		/*		savedInstanceState.putString("lang_filter", lang_filter);
		savedInstanceState.putInt("listNo", listNo);
		savedInstanceState.putInt("filter", filter); */
		super.onSaveInstanceState(savedInstanceState);
	}

	@Override
	public void onRestoreInstanceState(Bundle savedInstanceState) {
		super.onRestoreInstanceState(savedInstanceState);
		dwn = savedInstanceState.getBoolean("dwn");
		isdwn = savedInstanceState.getBoolean("isdwn");
		list_fresh =  savedInstanceState.getBoolean("list_fresh");
//		list_save =  savedInstanceState.getBoolean("list_save");
		onpause = savedInstanceState.getBoolean("onpause");
		listpos = savedInstanceState.getInt("listpos");
		toppos = savedInstanceState.getInt("toppos");
		filesCheckList = savedInstanceState.getStringArrayList("filesCheckList");
		if (filesCheckList == null) {
			filesCheckList = new ArrayList<String>();
		}
		//	lang_filter = savedInstanceState.getString("lang_filter");
	//	listNo = savedInstanceState.getInt("listNo");
	//	filter = savedInstanceState.getInt("filter");
	}

	

	private boolean isURQ(String s){
		Matcher m = Pattern.compile(Globals.StringURQ+"*").matcher(s);
		if(m.find()){
			if((new File(Globals.getGamePath(Globals.DirURQ))).isDirectory()){
				return true;
			} else {
				Toast.makeText(
						this,
						getString(R.string.nourq),
						Toast.LENGTH_LONG).show();
						int pos = gl.getIndexOfURQ();
						if(pos<0) return false;
						item_index = pos;
						g = gl.getInf(GameList.TITLE, item_index);
						gameDownload();
				return false;
				
			}
			
		}
		return true;
	}
	
	private void addShortcut(){  
    	String game = gl.getInf(GameList.NAME, index.get(item_index));
		String title = gl.getInf(GameList.TITLE, index.get(item_index));
		
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
    	String game = gl.getInf(GameList.NAME, index.get(item_index));
		String title = gl.getInf(GameList.TITLE, index.get(item_index));
		favGame.add(game, title);
		Toast.makeText(this, getString(R.string.game)+" \""+title+"\" "+getString(R.string.addedfav), 
				Toast.LENGTH_SHORT).show();
	}

	private void delFavorites(){
    	String game = gl.getInf(GameList.NAME, index.get(item_index));
		String title = gl.getInf(GameList.TITLE, index.get(item_index));
		
		favGame.remove(game);
		Toast.makeText(this, getString(R.string.game)+" \""+title+"\" "+getString(R.string.deletedfav), 
				Toast.LENGTH_SHORT).show();
	}
	
}
