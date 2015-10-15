package com.nlbhub.instead.redhood;

import android.view.View;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import com.nlbhub.instead.standalone.MainMenuAbstract;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class StartActivity extends MainMenuAbstract {
    @Override
    protected void showMenu(List<Map<String, ListItem>> additionalListData) {
        List<Map<String, ListItem>> listData = new ArrayList<Map<String, ListItem>>();

        listData.add(addListItem(getHtmlTagForName(getString(R.string.start)), R.drawable.start));
        listData.add(addListItem(getHtmlTagForName(getString(R.string.reinstall_libs)), R.drawable.options));

        listData.addAll(additionalListData);

        SimpleAdapter simpleAdapter = (
                new SimpleAdapter(
                        this,
                        listData,
                        R.layout.list_item, new String[] { LIST_TEXT },
                        new int[] { R.id.list_text }
                )
        );
        simpleAdapter.setViewBinder(this);
        setListAdapter(simpleAdapter);
    }

    @Override
    protected void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        switch (position) {
            case 0:
                startAppAlt();
                break;
            case 1:
                loadData();
                break;
        }
    }


    @Override
    protected void deleteAdditionalAssets() {
        // no op
    }

    @Override
    protected void copyAdditionalAssets() {
        // no op
    }
}
