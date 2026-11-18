instead_version "2.1.1"
require "xact"
require "hideinv"
--require "para"
require "dash"
require "quotes" 
require "theme" 
require "timer" 
game.codepage="UTF-8";
stead.scene_delim = '^';

game.act = 'Nothing happens.';
game.inv = 'Hm.. This is strange thing..';
game.use = 'Does not work...';
game.forcedsc = true;

global {
    _lists = {};
    _clones = {};
    _filter = {};
    _curloc = nil;
    push = function(listname, v)
        local list = _lists[listname];
        _lists[listname] = {next = list, value = v};
    end;
    pop = function(listname)
        local list = _lists[listname];
        if list == nil then
            return nil;
        else
            _lists[listname] = list.next;
            return list.value;
        end;
    end;
    size = function(listname)
        local list = _lists[listname];
        local result = 0;
        if list == nil then
            return 0;
        else
            repeat
                list = list.next;
                result = result + 1;
            until list == nil;
        end;
        return result;
    end;
    shuffle = function(listname)
        local arr = toArray(_lists[listname]);
        _lists[listname] = nil;
        addArr(listname, shuffled(arr));
    end;
    addAll = function(destination, destinationList, listName)
        local loclist = _lists[listName];
        if loclist == nil then
            return;
        else
            repeat
                if destination ~= nil then
                    addf(destination, loclist.value);
                elseif destinationList ~= nil then
                    push(destinationList, loclist.value);
                else
                    addf(nil, loclist.value);
                end;
                loclist = loclist.next;
            until loclist == nil;
        end;
    end;
    shuffled = function(tab)
        local n, order, res = #tab, {}, {};
        for i=1,n do order[i] = { rand = rnd(n), idx = i } end;
        table.sort(order, function(a,b) return a.rand < b.rand end);
        for i=1,n do res[i] = tab[order[i].idx] end;
        return res;
    end;
    toArray = function(list)
        local res = {}
        local loclist = list;
        local i = 1;
        if loclist == nil then
            return nil;
        else
            repeat
                res[i] = loclist.value;
                loclist = loclist.next;
                i = i + 1;
            until loclist == nil;
        end;
        return res;
    end;
    addArr = function(listname, arr)
        local n = #arr
        for i=1,n do push(listname, arr[i]) end;
    end;
    usea = function(actionObject, targetObject)
        if actionObject ~= nil and targetObject ~= nil then
            if actionObject.usea ~= nil then
                actionObject.usea(actionObject, targetObject);
            end;
        end;
    end;
    acta = function(object)
        if object ~= nil then
            if object.acta ~= nil then
                object.acta(object);
            end;
        end;
    end;
    clear = function(object)
        if object ~= nil then
            if object.clear ~= nil then
                object.clear(object);
            end;
        end;
    end;
    addf = function(target, object)
        if target == nil then
            if have(object) then
                take(clone(object));
            else
                take(object);
            end;
        else
            if exist(object, target) then
                objs(target):add(clone(object));
            else
                objs(target):add(object);
            end;
        end;
    end;
    revive = function()
        for k,v in pairs(_filter) do
            if v then
                local o = stead.ref(k);
                o.revive(o);
            end;
        end;
    end;
    deepcopy = function(t)
        local k; local v;
        if type(t) ~= "table" then return t end;
        local mt = getmetatable(t);
        local res = {};
        for k,v in pairs(t) do
            if type(v) == "table" then
                v = deepcopy(v)
            end;
            res[k] = v;
        end;
        setmetatable(res,mt);
        return res;
    end;
    clone = function(s)
        local ret = deepcopy(s);
        local r = _clones[s.nam];
        if r == nil then
            r = 1;
        else
            r = r + 1;
        end;
        _clones[s.nam] = r;
        ret.nam = s.nam..r;
        return ret;
    end;
    curloc = function()
        if _curloc == nil then
            return here();
        else
            return _curloc;
        end;
    end;
    nlbwalk = function(loc)
        _curloc = loc;
        walk(loc);
    end;
}
listobj = obj {
    nam = "listobj",
    listnam = "",
    clear = function(s)
        _lists[s.listnam] = nil;
    end,
    act = function(s)
        s.acta(s)
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s)
    end,
    actf = function(s)
        local list = _lists[s.listnam];
        if list ~= nil then
            repeat
                list.value.acta(list.value);
                list = list.next;
            until list == nil;
        end;
    end,
    use = function(s, w)
        s.usea(s, w);
        curloc().autos();
    end,
    usea = function(s, w)
        s.usef(s, w);
    end,
    usef = function(s, w)
        local list = _lists[s.listnam];
        if list ~= nil then
            repeat
                list.value.usea(list.value, w);
                list = list.next;
            until list == nil;
        end;
    end,
    used = function(s, w)
        s.useda(s, w);
        curloc().autos();
    end,
    useda = function(s, w)
        s.usedf(s, w);
    end,
    usedf = function(s, w)
        local list = _lists[s.listnam];
        if list ~= nil then
            repeat
                w.usea(w, list.value);
                list = list.next;
            until list == nil;
        end;
    end;
}
-- containerObj
v_905a1602_ce40_46f0_a57f_61cc9f7e346e = menu {
    nam = "containerObj",
    disp = function(s) end,
    dsc = function(s) p("Achievements:"); end,
    life = function(s)
        if not ((_achievementsCount ~= nil) and (_achievementsCount > 0)) then
            _filter[stead.deref(s)] = true;
            s:disable();
        end;
    end,
    revive = function(s)
        if (_achievementsCount ~= nil) and (_achievementsCount > 0) then
            _filter[stead.deref(s)] = false;
            s:enable();
        end;
    end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

lifeon('v_905a1602_ce40_46f0_a57f_61cc9f7e346e');
-- end33obj
v_51467b9f_3405_465d_8216_d36b24d99366 = menu {
    nam = "end33obj",
    disp = function(s) end,
    dsc = function(s) p("Granny and a pile of pasties^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end12obj
v_e7b736e4_0465_4bcc_a1cb_cd6aee2d3fb4 = menu {
    nam = "end12obj",
    disp = function(s) end,
    dsc = function(s) p("Proper upbringing^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end13obj
v_73c938af_ddd4_474e_823d_9eeefb02c657 = menu {
    nam = "end13obj",
    disp = function(s) end,
    dsc = function(s) p("Holy simplicity^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end31obj
v_92d89ed9_2e25_4bcc_89ee_2a98b2667f0d = menu {
    nam = "end31obj",
    disp = function(s) end,
    dsc = function(s) p("You don\'t get rid of good stuff^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end25obj
v_6361abe3_714b_4ec7_b866_9fca662e32dc = menu {
    nam = "end25obj",
    disp = function(s) end,
    dsc = function(s) p("Woodcutters rescuers^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end2obj
v_a7054201_999c_4e04_97ca_b394f2b91180 = menu {
    nam = "end2obj",
    disp = function(s) end,
    dsc = function(s) p("Prisoner^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end38obj
v_aea5cdb0_3765_4621_ad32_b21ec458c788 = menu {
    nam = "end38obj",
    disp = function(s) end,
    dsc = function(s) p("Long-awaited find^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end23obj
v_7b3b988d_52e0_4719_b297_a9bee3e674df = menu {
    nam = "end23obj",
    disp = function(s) end,
    dsc = function(s) p("Art of moderate eating^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end30obj
v_93d59afb_c4fa_413c_9e2b_e74477c051df = menu {
    nam = "end30obj",
    disp = function(s) end,
    dsc = function(s) p("Advantageous investment^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end34obj
v_2a6b9f56_2b76_43c2_b9df_21c29932e0b5 = menu {
    nam = "end34obj",
    disp = function(s) end,
    dsc = function(s) p("Lucky coincidence^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end32obj
v_73988af5_ae18_4fdc_9a62_d2f3368dec05 = menu {
    nam = "end32obj",
    disp = function(s) end,
    dsc = function(s) p("Good deed^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end7obj
v_a7514b63_788d_4041_8883_b26456439ab2 = menu {
    nam = "end7obj",
    disp = function(s) end,
    dsc = function(s) p("Retarded ignition^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end28obj
v_24c04782_6e96_4f13_a00e_9487be05bdcf = menu {
    nam = "end28obj",
    disp = function(s) end,
    dsc = function(s) p("Ingratitude^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end5obj
v_fcdc0f27_8dff_46f8_a43f_76e3ddd3e19f = menu {
    nam = "end5obj",
    disp = function(s) end,
    dsc = function(s) p("Stay alerted^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end39obj
v_fce84888_652a_4fc4_8ce8_a760619a8a08 = menu {
    nam = "end39obj",
    disp = function(s) end,
    dsc = function(s) p("Woodcutter saviour^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end3obj
v_8e58d530_8ff3_48d9_aa92_b7fe2d772bdb = menu {
    nam = "end3obj",
    disp = function(s) end,
    dsc = function(s) p("Lucky accident^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj6
v_1fe3f2e9_0312_4159_8664_9ad8c89ca879 = menu {
    nam = "achievementObj6",
    disp = function(s) end,
    dsc = function(s) p("{6};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"No way! You are making it up! Tell it the right way!\"");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj3
v_15f76f53_5a7b_4ab1_8576_ed73d62e7fff = menu {
    nam = "achievementObj3",
    disp = function(s) end,
    dsc = function(s) p("{3};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"This isn\'t possible,\" sister laughed.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end1obj
v_5e992f11_270f_4264_b59d_b625a68255b0 = menu {
    nam = "end1obj",
    disp = function(s) end,
    dsc = function(s) p("Deserved rest^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end22obj
v_f1ddc5ac_ea5e_40f8_8451_02f4a4b8963c = menu {
    nam = "end22obj",
    disp = function(s) end,
    dsc = function(s) p("Gluttony^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj7
v_5b379821_cc37_4973_bcd1_03e5f530a8b1 = menu {
    nam = "achievementObj7",
    disp = function(s) end,
    dsc = function(s) p("{7};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"The girl was silent. When brother noticed that she is about to cry, he hurried to start the story anew.\"");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end18obj
v_744763fb_dae3_401b_92b9_a42bf705c43e = menu {
    nam = "end18obj",
    disp = function(s) end,
    dsc = function(s) p("Wicked freeload^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end35obj
v_48c1030c_4782_4668_a8f3_726b85e25c0d = menu {
    nam = "end35obj",
    disp = function(s) end,
    dsc = function(s) p("Classic ending^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end41obj
v_94aa5e87_1ee6_492c_8cc0_430e0b42978c = menu {
    nam = "end41obj",
    disp = function(s) end,
    dsc = function(s) p("Attentiveness in detail^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end17obj
v_b720d443_51dd_4963_93d3_680d1fb53e90 = menu {
    nam = "end17obj",
    disp = function(s) end,
    dsc = function(s) p("Peacemaker pasties^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end16obj
v_dc8c679b_ea76_4c55_a987_3cc212268c0c = menu {
    nam = "end16obj",
    disp = function(s) end,
    dsc = function(s) p("Fear has big eyes^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj11
v_e4b8edea_f237_49a1_8aeb_393d044ddae4 = menu {
    nam = "achievementObj11",
    disp = function(s) end,
    dsc = function(s) p("{11};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"Is that the right tale? Red Hood?\"^"..
"\"Of course! Mother just read a shortened version to you.\"^"..
"\"I see. Maybe you\'ll tell it to me one more time, so I could remember it.\"");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end24obj
v_19fa365d_a16e_436e_bf6c_d3e31fdcf264 = menu {
    nam = "end24obj",
    disp = function(s) end,
    dsc = function(s) p("Telltale evidence^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end20obj
v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1 = menu {
    nam = "end20obj",
    disp = function(s) end,
    dsc = function(s) p("Poor cook^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj5
v_77bcefba_cdaa_4e3d_945f_b314280eddb6 = menu {
    nam = "achievementObj5",
    disp = function(s) end,
    dsc = function(s) p("{5};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"You must be wrong, there has to be another ending,\" said little girl with confidence.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- allEndingsContainer
v_dbd4c0f7_1988_4983_ac34_e21e290df0d8 = menu {
    nam = "allEndingsContainer",
    disp = function(s) end,
    dsc = function(s) p("^Endings:^"); end,
    life = function(s)
        if not ((_endingsCount ~= nil) and (_maxEndings ~= nil) and (_endingsCount < _maxEndings)) then
            _filter[stead.deref(s)] = true;
            s:disable();
        end;
    end,
    revive = function(s)
        if (_endingsCount ~= nil) and (_maxEndings ~= nil) and (_endingsCount < _maxEndings) then
            _filter[stead.deref(s)] = false;
            s:enable();
        end;
    end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

lifeon('v_dbd4c0f7_1988_4983_ac34_e21e290df0d8');
-- end4obj
v_51c497fb_5307_45a6_af11_cef8035c2b47 = menu {
    nam = "end4obj",
    disp = function(s) end,
    dsc = function(s) p("Reward for the efforts^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end21obj
v_7b494c88_f59f_41a6_8b14_339e0917d36e = menu {
    nam = "end21obj",
    disp = function(s) end,
    dsc = function(s) p("Retribution for politeness^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end42obj
v_e1ecbe83_5eda_49ee_b813_8eb513dd22b1 = menu {
    nam = "end42obj",
    disp = function(s) end,
    dsc = function(s) p("Miraculous outcome^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- foundEndingsContainer
v_fa64f44d_2a75_444c_9f2d_9eee18bdded0 = menu {
    nam = "foundEndingsContainer",
    disp = function(s) end,
    dsc = function(s) p("^Found endings:^"); end,
    life = function(s)
        if not ((_endingsCount ~= nil) and (_endingsCount > 0)) then
            _filter[stead.deref(s)] = true;
            s:disable();
        end;
    end,
    revive = function(s)
        if (_endingsCount ~= nil) and (_endingsCount > 0) then
            _filter[stead.deref(s)] = false;
            s:enable();
        end;
    end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

lifeon('v_fa64f44d_2a75_444c_9f2d_9eee18bdded0');
-- achievementObj4
v_c3251622_b561_42a6_9781_3f584c3a644e = menu {
    nam = "achievementObj4",
    disp = function(s) end,
    dsc = function(s) p("{4};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"Is that it? Why so little?\"");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end15obj
v_e125ae56_b7e6_4fbe_8a26_021db59ba477 = menu {
    nam = "end15obj",
    disp = function(s) end,
    dsc = function(s) p("Wolf nature^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end43obj
v_281d18c5_70d1_4edc_812c_0c46cd7fa945 = menu {
    nam = "end43obj",
    disp = function(s) end,
    dsc = function(s) p("Awful dream^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end8obj
v_66f71c19_0a70_4f58_8437_b45eaa625d3a = menu {
    nam = "end8obj",
    disp = function(s) end,
    dsc = function(s) p("Happy end^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end29obj
v_07ef90a9_298a_4fe4_971b_e791e38952f8 = menu {
    nam = "end29obj",
    disp = function(s) end,
    dsc = function(s) p("Be prepared^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end14obj
v_6891d2b3_b473_4032_bbeb_ae7c3f6cf1c8 = menu {
    nam = "end14obj",
    disp = function(s) end,
    dsc = function(s) p("Busy wolf^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end27obj
v_73e61329_4e57_4b12_9f4a_8f2b686ed165 = menu {
    nam = "end27obj",
    disp = function(s) end,
    dsc = function(s) p("Everybody is alive and kicking^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end10obj
v_4648ae92_f1a8_4250_a53b_cb5259fcb592 = menu {
    nam = "end10obj",
    disp = function(s) end,
    dsc = function(s) p("If only...^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end19obj
v_d6672938_2983_4032_a25c_a6d497f15f1e = menu {
    nam = "end19obj",
    disp = function(s) end,
    dsc = function(s) p("Nasty lunch^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj1
v_2030e267_6e30_4f2c_acf5_99f47fe4db29 = menu {
    nam = "achievementObj1",
    disp = function(s) end,
    dsc = function(s) p("{1};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"No-o-o, it\'s not how it was,\" said surprised girl.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end45obj
v_e6095f38_6e10_420d_a50b_8113e19b5c02 = menu {
    nam = "end45obj",
    disp = function(s) end,
    dsc = function(s) p("Tame wolf^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj8
v_234cc112_0046_49f3_97b3_9d49bfa13665 = menu {
    nam = "achievementObj8",
    disp = function(s) end,
    dsc = function(s) p("{8};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"I like this story,\" the girl yawned.^"..
"\"Finally,\" her brother thought. \'\'A little bit more, and she falls asleep!\".");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end6obj
v_656e179e_fb53_487c_8d4a_114206c96516 = menu {
    nam = "end6obj",
    disp = function(s) end,
    dsc = function(s) p("Lack of fastidiousness^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end11obj
v_3c69590d_317c_40d9_b284_298e6fa49a35 = menu {
    nam = "end11obj",
    disp = function(s) end,
    dsc = function(s) p("Don\'t open to strangers^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end36obj
v_68f087d8_2044_4abc_abbd_06053db5903d = menu {
    nam = "end36obj",
    disp = function(s) end,
    dsc = function(s) p("Patience^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj2
v_6071b501_4cdb_4b6c_bc08_3f89911e8d1c = menu {
    nam = "achievementObj2",
    disp = function(s) end,
    dsc = function(s) p("{2};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"You are telling it wrong.\"");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end40obj
v_3ae758b8_ba5f_4d84_8e5f_d2b2b29d54ad = menu {
    nam = "end40obj",
    disp = function(s) end,
    dsc = function(s) p("Colourless existence^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj9
v_8de3bf80_279b_45af_bed4_2edf8477b3cb = menu {
    nam = "achievementObj9",
    disp = function(s) end,
    dsc = function(s) p("{9};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("\"What a frightful story,\" the girl whispered, \"mother never told me that one, now I won\'t sleep for sure.\"");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end9obj
v_fabcc368_e24c_4e1e_ae70_e877d7304e6d = menu {
    nam = "end9obj",
    disp = function(s) end,
    dsc = function(s) p("Architect of own fortune^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end26obj
v_3426fafe_bb1e_4994_a692_f0d27eb12266 = menu {
    nam = "end26obj",
    disp = function(s) end,
    dsc = function(s) p("Wolf\'s day^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end44obj
v_ea12df2a_7448_4006_86c3_0544739b6e72 = menu {
    nam = "end44obj",
    disp = function(s) end,
    dsc = function(s) p("Unpredictable people^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- achievementObj10
v_8f5949c3_1b2c_40c0_9913_6ded19a81fee = menu {
    nam = "achievementObj10",
    disp = function(s) end,
    dsc = function(s) p("{10};"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        p("The girl laughed, \"you\'re telling it even more interesting!\"^"..
"\"I\'m glad. Sleep now.\"^"..
"\"Please, please, one more story!\"");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end37obj
v_e9267ae3_2715_408c_958e_254cb50b8907 = menu {
    nam = "end37obj",
    disp = function(s) end,
    dsc = function(s) p("Happily ever after^"); end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- meatPies
v_aabdd986_9e61_417d_805e_8751b4d6182c = menu {
    nam = "meatPies",
    disp = function(s) return "Pasties with meat" end,
    dsc = function(s) p("Mother baked {pasties with meat}"); end,
    tak = function(s)
        p("meatPies");
        s.act(s);
    end,
    menu = function(s)
        s.act(s);
    end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
    use = function(s, w)
        s.usea(s, w);
        curloc().autos();
    end,
    usea = function(s, w)
        s.usep(s, w);
        s.usef(s, w);
    end,
    usef = function(s, w)
    end,
    usep = function(s, w)
    end,
};

-- applePies
v_361a45f2_2b55_4692_937d_871274eda0a6 = menu {
    nam = "applePies",
    disp = function(s) return "Pasties with apples" end,
    dsc = function(s) p("Mother baked {pasties with apples}"); end,
    tak = function(s)
        p("applePies");
        s.act(s);
    end,
    menu = function(s)
        s.act(s);
    end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
    use = function(s, w)
        s.usea(s, w);
        curloc().autos();
    end,
    usea = function(s, w)
        s.usep(s, w);
        s.usef(s, w);
    end,
    usef = function(s, w)
    end,
    usep = function(s, w)
    end,
};

-- mushroomPies
v_8d44d129_e7ac_410d_871b_4af67d0390bd = menu {
    nam = "mushroomPies",
    disp = function(s) return "Pasties with mushrooms" end,
    dsc = function(s) p("Mother baked {pasties with mushrooms}"); end,
    tak = function(s)
        p("mushroomPies");
        s.act(s);
    end,
    menu = function(s)
        s.act(s);
    end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
    use = function(s, w)
        s.usea(s, w);
        curloc().autos();
    end,
    usea = function(s, w)
        s.usep(s, w);
        s.usef(s, w);
    end,
    usef = function(s, w)
    end,
    usep = function(s, w)
    end,
};

-- cabbagePies
v_e6e4c889_c068_46b8_9926_0aed4449e46b = menu {
    nam = "cabbagePies",
    disp = function(s) return "Pasties with cabbage" end,
    dsc = function(s) p("Mother baked {pasties with cabbage}"); end,
    tak = function(s)
        p("cabbagePies");
        s.act(s);
    end,
    menu = function(s)
        s.act(s);
    end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
    use = function(s, w)
        s.usea(s, w);
        curloc().autos();
    end,
    usea = function(s, w)
        s.usep(s, w);
        s.usef(s, w);
    end,
    usef = function(s, w)
    end,
    usep = function(s, w)
    end,
};

-- rifle
v_1bda9991_9d17_4ca8_ba52_d3f509ef6ecf = menu {
    nam = "rifle",
    disp = function(s) return "Shotgun" end,
    dsc = function(s) p("On the wall {shotgun}"); end,
    tak = function(s)
        p("rifle");
        s.act(s);
    end,
    menu = function(s)
        s.act(s);
    end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
    use = function(s, w)
        s.usea(s, w);
        curloc().autos();
    end,
    usea = function(s, w)
        s.usep(s, w);
        s.usef(s, w);
    end,
    usef = function(s, w)
    end,
    usep = function(s, w)
    end,
};

-- fishPies
v_53390a81_6d97_4c39_9148_029d558a91d5 = menu {
    nam = "fishPies",
    disp = function(s) return "Pasties with fish" end,
    dsc = function(s) p("Mother baked {pasties with fish}"); end,
    tak = function(s)
        p("fishPies");
        s.act(s);
    end,
    menu = function(s)
        s.act(s);
    end,
    act = function(s)
        s.acta(s);
        curloc().autos();
    end,
    acta = function(s)
        s.actf(s);
    end,
    actf = function(s)
    end,
    use = function(s, w)
        s.usea(s, w);
        curloc().autos();
    end,
    usea = function(s, w)
        s.usep(s, w);
        s.usef(s, w);
    end,
    usef = function(s, w)
    end,
    usep = function(s, w)
    end,
};

-- Return of Red Hood
v_1, main = room { nam = "main", enter = function(s) nlbwalk(main); end }, room {
    nam = "Return of Red Hood",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"So, I covered you with a blanket, put the lamp on. Now sleep!\"^"..
"\"Mother always tells me tales before sleeping.\"^"..
"\"One evening you can do without a tale. Tomorrow you will get mother and tales.\"^"..
"\"No, I won\'t sleep that way,\" the girl began to whimper, \"please, read it to me!\"^"..
"\"Ok,\" grumbled her elder brother, sitting on the edge of her bed, \"just don\'t cry. Which tale do you want?\"^"..
"\"Red Hood!\"^"..
"\"Fine, here we go.\"^"..
"\"Won\'t you take the book? It\'s in the bookcase, on the lower shelf.\"^"..
"\"What for? I remember that story. Listen!\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a4c12c9e_7168_4490_8d3a_bd358cfe9793|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
_endingsCount = 0;
_achievementsCount = 0;
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_a4c12c9e_7168_4490_8d3a_bd358cfe9793',
            function(s) 
                --Next
    _maxEndings = 45;
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_5e992f11_270f_4264_b59d_b625a68255b0);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_a7054201_999c_4e04_97ca_b394f2b91180);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_8e58d530_8ff3_48d9_aa92_b7fe2d772bdb);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_51c497fb_5307_45a6_af11_cef8035c2b47);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_fcdc0f27_8dff_46f8_a43f_76e3ddd3e19f);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_656e179e_fb53_487c_8d4a_114206c96516);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_a7514b63_788d_4041_8883_b26456439ab2);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_66f71c19_0a70_4f58_8437_b45eaa625d3a);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_fabcc368_e24c_4e1e_ae70_e877d7304e6d);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_4648ae92_f1a8_4250_a53b_cb5259fcb592);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_3c69590d_317c_40d9_b284_298e6fa49a35);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_e7b736e4_0465_4bcc_a1cb_cd6aee2d3fb4);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_73c938af_ddd4_474e_823d_9eeefb02c657);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_6891d2b3_b473_4032_bbeb_ae7c3f6cf1c8);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_e125ae56_b7e6_4fbe_8a26_021db59ba477);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_dc8c679b_ea76_4c55_a987_3cc212268c0c);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_b720d443_51dd_4963_93d3_680d1fb53e90);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_744763fb_dae3_401b_92b9_a42bf705c43e);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_d6672938_2983_4032_a25c_a6d497f15f1e);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_7b494c88_f59f_41a6_8b14_339e0917d36e);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_f1ddc5ac_ea5e_40f8_8451_02f4a4b8963c);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_7b3b988d_52e0_4719_b297_a9bee3e674df);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_19fa365d_a16e_436e_bf6c_d3e31fdcf264);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_6361abe3_714b_4ec7_b866_9fca662e32dc);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_3426fafe_bb1e_4994_a692_f0d27eb12266);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_73e61329_4e57_4b12_9f4a_8f2b686ed165);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_24c04782_6e96_4f13_a00e_9487be05bdcf);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_07ef90a9_298a_4fe4_971b_e791e38952f8);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_93d59afb_c4fa_413c_9e2b_e74477c051df);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_92d89ed9_2e25_4bcc_89ee_2a98b2667f0d);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_73988af5_ae18_4fdc_9a62_d2f3368dec05);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_51467b9f_3405_465d_8216_d36b24d99366);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_2a6b9f56_2b76_43c2_b9df_21c29932e0b5);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_48c1030c_4782_4668_a8f3_726b85e25c0d);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_68f087d8_2044_4abc_abbd_06053db5903d);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_e9267ae3_2715_408c_958e_254cb50b8907);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_aea5cdb0_3765_4621_ad32_b21ec458c788);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_fce84888_652a_4fc4_8ce8_a760619a8a08);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_3ae758b8_ba5f_4d84_8e5f_d2b2b29d54ad);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_94aa5e87_1ee6_492c_8cc0_430e0b42978c);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_e1ecbe83_5eda_49ee_b813_8eb513dd22b1);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_281d18c5_70d1_4edc_812c_0c46cd7fa945);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_ea12df2a_7448_4006_86c3_0544739b6e72);
                addf(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8, v_e6095f38_6e10_420d_a50b_8113e19b5c02);
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 
v_2 = room {
    nam = "...",
    bgimg = function() theme.gfx.bg('images/win.png'); end,
    dsc = function(s)
    end,
    xdsc = function(s)
        p "^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/studies_on_chopins_etudes.ogg', 0);
    end,
};

-- 11
v_3 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Is that the right tale? Red Hood?\"^"..
"\"Of course! Mother just read a shortened version to you.\"^"..
"\"I see. Maybe you\'ll tell it to me one more time, so I could remember it.\"");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end11)) and "{v_ad7e0fec_c364_4714_80a5_4c652c03b32d|Next}^" or "");
        p (((_end11)) and "{v_636abb43_cf08_4bcc_a502_c19493011cf1|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_ad7e0fec_c364_4714_80a5_4c652c03b32d',
            function(s) 
                --Next
_end11 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_e4b8edea_f237_49a1_8aeb_393d044ddae4);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_636abb43_cf08_4bcc_a502_c19493011cf1',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 4
v_4 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Is that it? Why so little?\"");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end4)) and "{v_7c09659a_679d_4d16_847c_8d6299580ff6|Next}^" or "");
        p (((_end4)) and "{v_220a015e_b1ed_487d_be18_d51993b8ef5b|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_7c09659a_679d_4d16_847c_8d6299580ff6',
            function(s) 
                --Next
_end4 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_c3251622_b561_42a6_9781_3f584c3a644e);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_220a015e_b1ed_487d_be18_d51993b8ef5b',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 2
v_5 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"You are telling it wrong.\"");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end2)) and "{v_aa8be6e3_7e99_4714_b071_bad36a30f178|Next}^" or "");
        p (((_end2)) and "{v_22ed8365_aef3_4af2_a504_23e900fdd638|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_aa8be6e3_7e99_4714_b071_bad36a30f178',
            function(s) 
                --Next
_end2 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_6071b501_4cdb_4b6c_bc08_3f89911e8d1c);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_22ed8365_aef3_4af2_a504_23e900fdd638',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 1
v_6 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"No-o-o, it\'s not how it was,\" said surprised girl.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end1)) and "{v_e7a4c596_1b4c_4be4_9884_22262852cbe9|Next}^" or "");
        p (((_end1)) and "{v_170b36c5_ac8d_4c18_a2da_e49eeb76891e|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_e7a4c596_1b4c_4be4_9884_22262852cbe9',
            function(s) 
                --Next
_end1 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_2030e267_6e30_4f2c_acf5_99f47fe4db29);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_170b36c5_ac8d_4c18_a2da_e49eeb76891e',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 10
v_7 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("The girl laughed, \"you\'re telling it even more interesting!\"^"..
"\"I\'m glad. Sleep now.\"^"..
"\"Please, please, one more story!\"");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end10)) and "{v_fb0fe502_c466_48bb_a6a7_f7972d101ae9|Next}^" or "");
        p (((_end10)) and "{v_0ceb4c0e_4625_4d27_828f_88842b2ba68c|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_fb0fe502_c466_48bb_a6a7_f7972d101ae9',
            function(s) 
                --Next
_end10 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_8f5949c3_1b2c_40c0_9913_6ded19a81fee);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_0ceb4c0e_4625_4d27_828f_88842b2ba68c',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 5
v_8 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"You must be wrong, there has to be another ending,\" said little girl with confidence.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end5)) and "{v_6d55ba6f_0b11_48fe_9be6_b4c0c8502c9f|Next}^" or "");
        p (((_end5)) and "{v_3c5a8ed5_e4a0_4d4d_88df_0666677c8ce0|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_6d55ba6f_0b11_48fe_9be6_b4c0c8502c9f',
            function(s) 
                --Next
_end5 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_77bcefba_cdaa_4e3d_945f_b314280eddb6);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_3c5a8ed5_e4a0_4d4d_88df_0666677c8ce0',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 
v_9 = room {
    nam = "...",
    bgimg = function() end,
    dsc = function(s)
    end,
    xdsc = function(s)
        p "^";
        p "{v_bdc9de0d_353c_4432_82b8_eaf10fbfdb7c|Back}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        'v_dbd4c0f7_1988_4983_ac34_e21e290df0d8',
        'v_fa64f44d_2a75_444c_9f2d_9eee18bdded0',
        xdsc(),
        xact(
            'v_bdc9de0d_353c_4432_82b8_eaf10fbfdb7c',
            function(s) 
                --Back
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 3
v_10 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"This isn\'t possible,\" sister laughed.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end3)) and "{v_e2735e63_059c_4953_afe3_875396eea342|Next}^" or "");
        p (((_end3)) and "{v_cbf9ea49_be4d_43ae_871b_ce2517802c50|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_e2735e63_059c_4953_afe3_875396eea342',
            function(s) 
                --Next
_end3 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_15f76f53_5a7b_4ab1_8576_ed73d62e7fff);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_cbf9ea49_be4d_43ae_871b_ce2517802c50',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 6
v_11 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"No way! You are making it up! Tell it the right way!\"");
    end,
    xdsc = function(s)
        p "^";
        p (((_end6)) and "{v_78837a29_d74e_4e69_8180_dfd1e074a323|Next}^" or "");
        p ((( not _end6)) and "{v_674ae87f_6084_4516_aed2_62c4169b034c|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_78837a29_d74e_4e69_8180_dfd1e074a323',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_674ae87f_6084_4516_aed2_62c4169b034c',
            function(s) 
                --Next
_end6 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_1fe3f2e9_0312_4159_8664_9ad8c89ca879);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 7
v_12 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"The girl was silent. When brother noticed that she is about to cry, he hurried to start the story anew.\"");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end7)) and "{v_5ec5c6fa_6d62_4649_b705_139e02f65c34|Next}^" or "");
        p (((_end7)) and "{v_99e5bae2_4ad3_4d9d_a9ad_5470e1a3fd35|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_5ec5c6fa_6d62_4649_b705_139e02f65c34',
            function(s) 
                --Next
_end7 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_5b379821_cc37_4973_bcd1_03e5f530a8b1);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_99e5bae2_4ad3_4d9d_a9ad_5470e1a3fd35',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 9
v_13 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"What a frightful story,\" the girl whispered, \"mother never told me that one, now I won\'t sleep for sure.\"");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end9)) and "{v_39a3572c_2436_4470_8b5f_aea949a9049b|Next}^" or "");
        p (((_end9)) and "{v_bbf7d1bc_b216_4033_ac00_9bbfc538a03a|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_39a3572c_2436_4470_8b5f_aea949a9049b',
            function(s) 
                --Next
_end9 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_8de3bf80_279b_45af_bed4_2edf8477b3cb);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_bbf7d1bc_b216_4033_ac00_9bbfc538a03a',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- 8
v_14 = room {
    nam = "...",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("\"I like this story,\" the girl yawned.^"..
"\"Finally,\" her brother thought. \'\'A little bit more, and she falls asleep!\".");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end8)) and "{v_0394629e_05e9_41e0_867e_8de735d158dd|Next}^" or "");
        p (((_end8)) and "{v_e38dfed8_fa35_427f_ba5c_94e6052119aa|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
inv():zap();
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/homeambient.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_0394629e_05e9_41e0_867e_8de735d158dd',
            function(s) 
                --Next
_end8 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_234cc112_0046_49f3_97b3_9d49bfa13665);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_e38dfed8_fa35_427f_ba5c_94e6052119aa',
            function(s) 
                --Next
                nlbwalk(v_15); 
            end
        ),

    },
};

-- Start
v_15 = room {
    nam = "...",
    pic = 'images/cover5.png',
    bgimg = function() end,
    dsc = function(s)
p("Found endings: ".._endingsCount.."/45");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6655127b_69cc_4b22_93e7_377c6c565a65|List of endings}^";
        p "{v_0a19cdb2_6b51_499c_9996_e2dc3406bba1_7603a6c8_5d35_4bec_8f50_1b59ad600fec_Traverse|Next}^";
    end,
    autos = function()
        revive();
        if ((_endingsCount ~= nil) and (_endingsCount >= 45)) then                 nlbwalk(v_2); 
        return;
 end;
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_6655127b_69cc_4b22_93e7_377c6c565a65',
            function(s) 
                --List of endings
                nlbwalk(v_9); 
            end
        ),
        xact(
            'v_0a19cdb2_6b51_499c_9996_e2dc3406bba1_7603a6c8_5d35_4bec_8f50_1b59ad600fec_Traverse',
            function(s) 
                --Next
                nlbwalk(v_16); 
            end
        ),

    },
};

-- Beginning
v_16 = room {
    nam = "...",
    pic = 'images/chaperon_face.png',
    bgimg = function() end,
    dsc = function(s)
p("In one village there was a little girl, so lovely, that no other girl could equal her.^"..
"Mother loved her to distraction and Grandmother even more.^"..
"For birthday Grandmother presented her a red hood.^"..
"Since then the girl always wore her new, smart hood.^"..
"So neighbors did say, \"Here goes Red Hood!\"^"..
"^"..
"Once Mother decided to bake some pasties, but wasn\'t sure what filling to choose.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_48718486_32e3_4236_b6f4_41873a0e2419|With fish}^";
        p "{v_0a93e7bd_6c58_4d95_8107_6b57a3643ddf|With meat}^";
        p "{v_46d5d402_a6d9_48cd_84d2_ed27fa2cf679|With apples}^";
        p "{v_f5438e24_39e2_49c1_9650_bfe1c66691a7|With cabbage}^";
        p "{v_2adcb87e_4696_4101_b2c1_49379695abbb|With mushrooms}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
_fish =  false ;
_meat =  false ;
_cabbage =  false ;
_apple =  false ;
_mushroom =  false ;
_mother =  false ;
_chaperon =  false ;
_butterfly =  false ;
_chap_got_fish_pie =  false ;
_chaperon_dead =  false ;
_eat_pie =  false ;
_enough =  false ;
_heavy =  false ;
_no_eat_pie =  false ;
_tell_about_wolf =  false ;
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_48718486_32e3_4236_b6f4_41873a0e2419',
            function(s) 
                --With fish
_fish = true;
                addf(nil, v_53390a81_6d97_4c39_9148_029d558a91d5);
                nlbwalk(v_20); 
            end
        ),
        xact(
            'v_0a93e7bd_6c58_4d95_8107_6b57a3643ddf',
            function(s) 
                --With meat
_meat = true;
                nlbwalk(v_55); 
            end
        ),
        xact(
            'v_46d5d402_a6d9_48cd_84d2_ed27fa2cf679',
            function(s) 
                --With apples
_apple = true;
                addf(nil, v_361a45f2_2b55_4692_937d_871274eda0a6);
                nlbwalk(v_58); 
            end
        ),
        xact(
            'v_f5438e24_39e2_49c1_9650_bfe1c66691a7',
            function(s) 
                --With cabbage
_cabbage = true;
                addf(nil, v_e6e4c889_c068_46b8_9926_0aed4449e46b);
                nlbwalk(v_60); 
            end
        ),
        xact(
            'v_2adcb87e_4696_4101_b2c1_49379695abbb',
            function(s) 
                --With mushrooms
_mushroom = true;
                addf(nil, v_8d44d129_e7ac_410d_871b_4af67d0390bd);
                nlbwalk(v_81); 
            end
        ),

    },
};

-- Wolf  tracked Mother down granny\'s house
v_17 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Not far from there, as always, hungry Wolf was scouring for food. Crossing the road he found a pasty, that Mother dropped. For a long time he had not had a bite of food, so he ate it without thinking. Of course, it was not enough for complete  saturation, and Wolf continued scouring for prey.^"..
"Meanwhile, Mother reached granny, gave her pasties, the pot of butter, and hurried back home. Wolf was roaming in the thickets, and didn\'t notice how he found himself by the forest edge. He never visited this part of wood before. There was a small wooden house on the hillock and Wolf decided to find out who lived there. Predator jumped on the porch and knocked on the door.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin43)) and "{v_3a519726_841a_4818_9ef7_88ce65d1533b|Next}^" or "");
        p ((( not _fin43)) and "{v_0129c5c3_c445_469f_a191_0e2deb9b18d6|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_3a519726_841a_4818_9ef7_88ce65d1533b',
            function(s) 
                --Next
                nlbwalk(v_128); 
            end
        ),
        xact(
            'v_0129c5c3_c445_469f_a191_0e2deb9b18d6',
            function(s) 
                --Next
_fin43 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_b720d443_51dd_4963_93d3_680d1fb53e90);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_b720d443_51dd_4963_93d3_680d1fb53e90);
                nlbwalk(v_128); 
            end
        ),

    },
};

-- Red Hood took turn into the wood to eat some wild strawberries
v_18 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood took turn into the wood to eat some wild strawberries. There was plenty of it. She picked it by handfuls and put into her mouth. Meanwhile, Mother and granny ran at top speed along the path yelling^"..
"\"Red Hood!\"^"..
"When Red Hood heard yelling, she automatically inhaled to respond loudly, but choked over berries. Although she failed to respond, but saw where they were heading. After girl cleared her throat, she ran along the path to catch up with Mother.^"..
"And, suddenly, she ran into a Wolf.^"..
"\"Eh-h-h!\" said Wolf.^"..
"\"It\'s not the right time!\" said girl in her annoyance.^"..
"She wouldn\'t wait for continuation of conversation, gave him a punch in the muzzle and ran further. She was sick and tired of being alone in this forest and had no time for local fauna. Wolf was so shocked, he didn\'t even try to chase her. Truly there was a mad girl, and it might be dangerous to eat.^"..
"The girl caught up with her parents, and they lived happily ever after.^"..
"^"..
"Ending:^"..
"”Happily ever after”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ee11155e_c54c_4516_8886_a3289f7fca6b_7daf90de_cc43_429a_88ed_21011df2f00e_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_ee11155e_c54c_4516_8886_a3289f7fca6b_7daf90de_cc43_429a_88ed_21011df2f00e_Return',
            function(s) 
                --Next
                nlbwalk(v_11); 
            end
        ),

    },
};

-- He meets her in the evening Soon they got married
v_19 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("The woodcutter escorted Mother to her home, where he made acquaintance with her daughter Red Hood. Soon they got married.^"..
"^"..
"Ending:^"..
"”Happy end”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_267cc9ce_de21_47b9_b241_f2ec38becd17_0402f0cb_db2e_4a41_9d64_0ba827478cc4_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/studies_on_chopins_etudes.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_267cc9ce_de21_47b9_b241_f2ec38becd17_0402f0cb_db2e_4a41_9d64_0ba827478cc4_Return',
            function(s) 
                --Next
                nlbwalk(v_14); 
            end
        ),

    },
};

-- Pasties with fish
v_20 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother checked the boxroom, went down the cellar and found the last salt hunchback salmon from the last year stock. \"It lies here for a long time,\"  she thought,  \"in my cellar it can stay preserved for years.\" She grabbed it and climbed up.^"..
"She thoroughly extracted all bones from the fish and began shaping pasties, because pastry had already risen.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_691777b7_7e19_4ba5_8cf1_e723e0b32c7a|Mother baked pasties and says to her daughter...}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bumblebee.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_691777b7_7e19_4ba5_8cf1_e723e0b32c7a',
            function(s) 
                --Mother baked pasties and says to her daughter...
                nlbwalk(v_122); 
            end
        ),

    },
};

-- Wolf was struck by generosity and kindness
v_21 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Being a common woman, besides living in deep forest, Mother didn\'t get used to such sophisticated phrases. But, she listened Wolf very carefully and after a few seconds pondering said, \"Ah, You want a pasty?\"^"..
"Wolf nodded.^"..
"\"You got me absolutely right Mad..\"^"..
"Woman already was not listening. She just extracted a couple of pasties, put them on the ground and kept walking.^"..
"Wolf was struck by generosity and kindness. He munched his fare, although it didn\'t give him full saturation, and decided not to eat anyone today. Despite a slight movement in his bowels, he falls asleep under the bush.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin37)) and "{v_52cea8d5_b9fc_4771_83e5_c44236dd6f6d|Next}^" or "");
        p ((( not _fin37)) and "{v_96c744a7_8512_495f_abd4_efa9502f1ba7|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_52cea8d5_b9fc_4771_83e5_c44236dd6f6d',
            function(s) 
                --Next
                nlbwalk(v_119); 
            end
        ),
        xact(
            'v_96c744a7_8512_495f_abd4_efa9502f1ba7',
            function(s) 
                --Next
_fin37 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_7b494c88_f59f_41a6_8b14_339e0917d36e);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_7b494c88_f59f_41a6_8b14_339e0917d36e);
                nlbwalk(v_119); 
            end
        ),

    },
};

-- Mother carries with fish
v_22 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Soon Mother appeared in the room, already dressed up for a trip. She took pasties, kissed her daughter and left the house.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_2c202c7d_7873_4864_9fd8_ce4fb7d08072|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_2c202c7d_7873_4864_9fd8_ce4fb7d08072',
            function(s) 
                --Next
                nlbwalk(v_66); 
            end
        ),

    },
};

-- Wolf ate everyone including all pasties
v_23 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood was briskly following the path without noticing, that grey predator pursued her with silent steps. When they reached the edge of the forest, Wolf patiently waited when the door is opened, and broke into the Grandmother\'s house after the girl entered. After that he ate Red Hood, Grandmother and all pasties, then satisfied and satiated went to sleep into the forest.^"..
"^"..
"Ending:^"..
"”Wolf\'s day”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_26b5cd69_81a0_4361_8bf8_6e1c5c4be51e_69cd655a_1111_42b7_9bbe_057df356d037_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_26b5cd69_81a0_4361_8bf8_6e1c5c4be51e_69cd655a_1111_42b7_9bbe_057df356d037_Return',
            function(s) 
                --Next
                nlbwalk(v_12); 
            end
        ),

    },
};

-- Red Hood makes anew
v_24 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("In spite of the fact that girl was young, she was very responsible and honest. She poured the stuff out, washed the bowl clean, and this time measured every component dosage extra carefully. Wolf lapped everything up and licked the bowl.^"..
"The beast thanked Red Hood, led her to the path and even escorted her to the house. In the end he asked her name and ran away. Red Hood changed her mind about visiting granny, because she had no pasties, and was too tired because of everything she had been through.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin20)) and "{v_e24a737c_66c0_4956_bd76_aea1ab469d32|Next}^" or "");
        p ((( not _fin20)) and "{v_9ebc0930_ed2c_4dfe_8fff_9b81d3f293dd|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_e24a737c_66c0_4956_bd76_aea1ab469d32',
            function(s) 
                --Next
                nlbwalk(v_145); 
            end
        ),
        xact(
            'v_9ebc0930_ed2c_4dfe_8fff_9b81d3f293dd',
            function(s) 
                --Next
_fin20 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_e1ecbe83_5eda_49ee_b813_8eb513dd22b1);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_e1ecbe83_5eda_49ee_b813_8eb513dd22b1);
                nlbwalk(v_145); 
            end
        ),

    },
};

-- Wolf got angry and caught hold of the basket willing to take it away
v_25 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood glanced at Wolf - water was dripping down from his wet hair, paws and leanness belly were covered in mud.^"..
"\"Filthy wild beast!\" thought Red Hood wrinkling her nose with disgust.^"..
"\"I can\'t give you any, it is all for my granny.\"^"..
"After these words she tried to pass by, but starving Wolf, who was displeased with such disdain, suddenly caught hold of the basked and pulled back.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin35)) and "{v_1309de8a_c97c_45f1_a1c2_db69c127b825|Release the basket!}^" or "");
        p "{v_87521591_d9dd_4a1d_9098_baec6aad437b|Hold the basket tight!}^";
        p ((( not _fin35)) and "{v_536c7669_a88e_4bd5_88b9_5eef8de5b987|Release the basket!}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_1309de8a_c97c_45f1_a1c2_db69c127b825',
            function(s) 
                --Release the basket!
                nlbwalk(v_118); 
            end
        ),
        xact(
            'v_87521591_d9dd_4a1d_9098_baec6aad437b',
            function(s) 
                --Hold the basket tight!
                nlbwalk(v_49); 
            end
        ),
        xact(
            'v_536c7669_a88e_4bd5_88b9_5eef8de5b987',
            function(s) 
                --Release the basket!
_fin35 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_73e61329_4e57_4b12_9f4a_8f2b686ed165);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_73e61329_4e57_4b12_9f4a_8f2b686ed165);
                nlbwalk(v_118); 
            end
        ),

    },
};

-- Mother ate one pasty and soon felt stomach ache
v_26 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Soon she felt stomach ache. As far as she didn\'t eat anything that day, pasties were under suspicion. She shook them out of the basket under the bush, and rushed to Grandmother, whose hut was already not far. Making a few forced stops on her way, she finally reached the forest edge.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _chap_got_fish_pie and _fin21)) and "{v_02cb3f46_0c2e_45c4_8c08_1edba247d41b|Next}^" or "");
        p (((_chap_got_fish_pie and _fin18)) and "{v_0201060d_593a_4d29_a271_c4d82b787508|Next}^" or "");
        p (((_chap_got_fish_pie and not _fin18)) and "{v_5e61ae0f_59f7_4e76_b3c3_064deb28e1c7|Next}^" or "");
        p ((( not _chap_got_fish_pie and not _fin21)) and "{v_432f94c1_6d2c_4bad_a230_402b60b5f7af|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/flight_of_the_bumblebee.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_02cb3f46_0c2e_45c4_8c08_1edba247d41b',
            function(s) 
                --Next
                nlbwalk(v_110); 
            end
        ),
        xact(
            'v_0201060d_593a_4d29_a271_c4d82b787508',
            function(s) 
                --Next
                nlbwalk(v_144); 
            end
        ),
        xact(
            'v_5e61ae0f_59f7_4e76_b3c3_064deb28e1c7',
            function(s) 
                --Next
_fin18 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_744763fb_dae3_401b_92b9_a42bf705c43e);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_744763fb_dae3_401b_92b9_a42bf705c43e);
                nlbwalk(v_144); 
            end
        ),
        xact(
            'v_432f94c1_6d2c_4bad_a230_402b60b5f7af',
            function(s) 
                --Next
_fin21 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_d6672938_2983_4032_a25c_a6d497f15f1e);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_d6672938_2983_4032_a25c_a6d497f15f1e);
                nlbwalk(v_110); 
            end
        ),

    },
};

-- Dialog of granny and Wolf
v_27 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf forgot to ask Red Hood, where her granny lived, so he had to spoor her. He finally saw the hut. Sniffing the air, he smelled that the girl was still there, and pondered whether to spare her or not.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6605c653_5a64_4169_8f68_0730ebac3e82|Eat them both}^";
        p (((_fin36)) and "{v_00adc905_f901_4771_be2c_dcc6071718b3|Do not eat Red Hood}^" or "");
        p ((( not _fin36)) and "{v_16fe9921_7f12_44e2_b732_ed3f8ba2e133|Do not eat Red Hood}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodrain.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_6605c653_5a64_4169_8f68_0730ebac3e82',
            function(s) 
                --Eat them both
                nlbwalk(v_113); 
            end
        ),
        xact(
            'v_00adc905_f901_4771_be2c_dcc6071718b3',
            function(s) 
                --Do not eat Red Hood
                nlbwalk(v_159); 
            end
        ),
        xact(
            'v_16fe9921_7f12_44e2_b732_ed3f8ba2e133',
            function(s) 
                --Do not eat Red Hood
_fin36 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_93d59afb_c4fa_413c_9e2b_e74477c051df);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_93d59afb_c4fa_413c_9e2b_e74477c051df);
                nlbwalk(v_159); 
            end
        ),

    },
};

-- After eating he suffers from diarrhea and disappointment
v_28 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf could not moderate himself any longer. By a single jump he overcame the distance between him and the woman, grabbed her basket and galloped into the forest. Mother was still standing on the road, holding a pot of butter.^"..
"It took Wolf a few seconds to empty the basket, but retribution was imminent. Sitting under the bush, suffering from diarrhea and disappointment, Wolf was cursing muddle-headed housewives. Today he won\'t harm anyone.^"..
"^"..
"Ending:^"..
"”Poor cook”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_47c5068e_d896_451e_a0b2_2cdbb98527aa_7e35525f_46ee_4774_a39a_5b794054b395_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony_fast.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_47c5068e_d896_451e_a0b2_2cdbb98527aa_7e35525f_46ee_4774_a39a_5b794054b395_Return',
            function(s) 
                --Next
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Soon sounded knocking on the door
v_29 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("Soon sounded knocking on the door.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It is me, Red Hood, your granddaughter!\" whispered Wolf, making his voice as tender as he could.^"..
"\"Ah, pull the string my dear and the door will open!\"^"..
"Like a whirlwind, predator broke into the house, and fell down the cellar. Granny lost consciousness.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f66370b5_e73c_4548_ad2b_ea88fbc3488d|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_f66370b5_e73c_4548_ad2b_ea88fbc3488d',
            function(s) 
                --Next
                nlbwalk(v_117); 
            end
        ),

    },
};

-- Wolf tracked them down and ate
v_30 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("Sophisticated predator took his courage in both paws, and decided to track woman down, anticipating more lavish prey. His intuition served him well, as they soon approached hut on the forest edge. He waited, until Mother entered the hut, Wolf rushed ahead and after he slipped his muzzle through the closing door, broke into the premises.^"..
"Peaceful twitting of forest birds was interrupted by two harrowing women cries, but after a few seconds everything was quiet. Only insatiable champing was resounding from behind slightly opened door.^"..
"After swallowing his prey, Wolf noticed pasties, scattered all over the floor.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin29)) and "{v_b854fb69_d0f5_423e_9147_eeff797ecae8|Eat pasties too!}^" or "");
        p "{v_1092f2d9_753e_4bf5_924f_cffe8e851baa|Stop gorging!}^";
        p ((( not _fin29)) and "{v_0db22a64_158a_43cc_9b41_6ca438072fb0|Eat pasties too!}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/symphony5.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_b854fb69_d0f5_423e_9147_eeff797ecae8',
            function(s) 
                --Eat pasties too!
                nlbwalk(v_32); 
            end
        ),
        xact(
            'v_1092f2d9_753e_4bf5_924f_cffe8e851baa',
            function(s) 
                --Stop gorging!
                nlbwalk(v_162); 
            end
        ),
        xact(
            'v_0db22a64_158a_43cc_9b41_6ca438072fb0',
            function(s) 
                --Eat pasties too!
_fin29 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_f1ddc5ac_ea5e_40f8_8451_02f4a4b8963c);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_f1ddc5ac_ea5e_40f8_8451_02f4a4b8963c);
                nlbwalk(v_32); 
            end
        ),

    },
};

-- She met Wolf on her way
v_31 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("Suddenly, Wolf came out of the bushes on the trail. He wanted to eat the girl immediately, but first, slyboots decided to find out who she was, and where she was going.^"..
"\"Hello, girl!\" started Wolf, feeling his full supremacy.^"..
"\"How do You do, sir\" said Red Hood, looking at her interlocutor with curiosity.^"..
"\"What is your name and where are you going all alone\" continued Wolf making stress on word \"alone\".^"..
"\"My name is Red Hood, I\'m going to visit my granny and bring her some pasties, and a pot of butter.\"^"..
"\"And my name is Wolf. Where does your granny live?\"^"..
"\"You should go straight down this path till the edge of the forest, there will be my granny\'s house.\"^"..
"Wolf also wanted to know what stuffing was inside the pasties, but wind altered its direction, and he smelled fish. He swallowed saliva and pronounced, \"Red Hood, please, let my taste one pasty.\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_d5ec6d7f_2c48_4f86_8a9c_91e1166ce228|Treat Wolf with no pasty}^";
        p "{v_556ab87b_400a_4383_a98b_7bb3ea20b859|Treat Wolf with one pasty}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_d5ec6d7f_2c48_4f86_8a9c_91e1166ce228',
            function(s) 
                --Treat Wolf with no pasty
                nlbwalk(v_135); 
            end
        ),
        xact(
            'v_556ab87b_400a_4383_a98b_7bb3ea20b859',
            function(s) 
                --Treat Wolf with one pasty
                nlbwalk(v_38); 
            end
        ),

    },
};

-- Mother, old hag and fish pasties - are a thermonuclear mix
v_32 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother, old hag and fish pasties - are a thermonuclear mix. Will Wolf outlive this night - no one knows...^"..
"^"..
"Ending:^"..
"”Gluttony”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_4f0678ba_1e58_4dea_a248_3d3085a03dc2_01a4c786_f042_4fcd_8333_afac265f0328_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_4f0678ba_1e58_4dea_a248_3d3085a03dc2_01a4c786_f042_4fcd_8333_afac265f0328_Return',
            function(s) 
                --Next
                nlbwalk(v_8); 
            end
        ),

    },
};

-- 
v_33 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("This whole time Wolf kept them in his sight, and hoped that luck would let him have someone for dinner or supper. Woodcutter was making him nervous, but when he left, Wolf felt himself more confident, and began to wait for his prey to come out.^"..
"A few hours of waiting made predator irritated, but at sunset he was furious. All of a sudden sounded crackle nearby. Wolf became alerted. There was that morning woodcutter, coming out of bushes. How grey hunter could know, that Mother and woodcutter agreed to meet in the evening.^"..
"Wolf couldn\'t hold back his tears, while he was returning to the wood to look for another meal.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin6)) and "{v_f9198213_778f_48ce_838a_b547cd0444c5|Next}^" or "");
        p ((( not _fin6)) and "{v_a397e731_c967_4463_9151_33b913788a01|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_f9198213_778f_48ce_838a_b547cd0444c5',
            function(s) 
                --Next
                nlbwalk(v_19); 
            end
        ),
        xact(
            'v_a397e731_c967_4463_9151_33b913788a01',
            function(s) 
                --Next
_fin6 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_66f71c19_0a70_4f58_8437_b45eaa625d3a);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_66f71c19_0a70_4f58_8437_b45eaa625d3a);
                nlbwalk(v_19); 
            end
        ),

    },
};

-- Red Hood carries with apples
v_34 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother says, \"Why don’t you my little Red Hood go visit your granny. Bring her pasties, a pot of butter and find out how is she?\"^"..
"\"Ok, mom!\" replies Red Hood. They took a large basket and filled it with a pile of pasties. Red Hood grabbed weighty presents and dragged herself towards the exit. Mother looked that the load was too heavy for her daughter and said,^"..
"\"It looks like the basket is too heavy. Maybe we should lessen weight?\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_37a100d4_ee96_46e4_926a_5b79a292a3ad|- I can do this!}^";
        p "{v_7a1dd147_9c62_41c1_a841_42d36a3b6c48|-Ok, let\'s lessen weight!}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_37a100d4_ee96_46e4_926a_5b79a292a3ad',
            function(s) 
                --- I can do this!
_heavy = true;
                nlbwalk(v_166); 
            end
        ),
        xact(
            'v_7a1dd147_9c62_41c1_a841_42d36a3b6c48',
            function(s) 
                ---Ok, let\'s lessen weight!
                nlbwalk(v_77); 
            end
        ),

    },
};

-- Meanwhile Wolf comes to granny\'s house
v_35 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf came to granny\'s house and knocked. Chewing fifth pasty, old lady came up to the door and looked into the keyhole. There was wolf.^"..
"Old lady got a fright and leaped back, nearly choked with a pasty.^"..
"Beast went around the hut hoping to find another entrance. At the same time tracks led woodcutters to the forest edge. One of men stepped on the porch and started hammering with a fist on the door. Old woman shuddered and looked inside the keyhole once again. A wolf just stood there and now there is a robust redneck.^"..
"\"My God!\" she whispered.^"..
"Old woman finally got frightened. Wolf on the other side of the hut, heard rough mens\' voices and made the right decision to avoid problems and returned to the forest, while he was in one piece.^"..
"Fright made old lady demonstrate quickness that was unusual for a person of her age - she jumped to the cupboard and took the shotgun, that remained after her husband died.^"..
"She opened the window, stuck out the shotgun barrel and screamed, \"Beat it, you lousy warewolf!\"^"..
"Woodcutters were supposed to get angry, but burst into laughter.^"..
"\"Let\'s get out of here, there is some crazy old hag\" said one of them.^"..
"So they turned around and left.^"..
"^"..
"Ending:^"..
"”Unpredictable people”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_4151629d_f98e_4d1c_a25b_862bfbbf3711_7e35525f_46ee_4774_a39a_5b794054b395_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/granny.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_4151629d_f98e_4d1c_a25b_862bfbbf3711_7e35525f_46ee_4774_a39a_5b794054b395_Return',
            function(s) 
                --Next
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Mother didn\'t understand
v_36 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Being a common woman, besides living in deep forest, Mother didn\'t get used to such sophisticated phrases and couldn\'t understand what Wolf wanted. Giving  predator astonished and alerted look at the same time, Mother carefully passed him by and continued marching, cautiously turning around.^"..
"Wolf, shocked by such a disparaging attitude, dropped his jaw, but another hunger attack brought him back to reality and forced him to act in an old fashioned way.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin27)) and "{v_3ac36aad_5dec_4103_a078_5eb00c1bafed|Next}^" or "");
        p ((( not _fin27)) and "{v_5f0e878c_a630_4e80_a310_71591cadf95c|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_3ac36aad_5dec_4103_a078_5eb00c1bafed',
            function(s) 
                --Next
                nlbwalk(v_28); 
            end
        ),
        xact(
            'v_5f0e878c_a630_4e80_a310_71591cadf95c',
            function(s) 
                --Next
_fin27 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1);
                nlbwalk(v_28); 
            end
        ),

    },
};

-- Split
v_37 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood had no strength left. She tumbled into bed unconscious. Mother and granny decided to split to have better chances for success. Old lady headed to Mother\'s house as it was closer to her, and Mother rushed through the forest to the edge, hoping to meet daughter.^"..
"\"Hallo!\" she called and listened, but it was useless.^"..
"Rushing past granny\'s hut, women peeked in the window, just in case. A sigh of relief burst out of her chest. There was her daughter Red Hood, peacefully sleeping in bed.^"..
"^"..
"Ending:^"..
"”Long-awaited find”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c6579557_aae1_432f_99d8_164b0a90f47d_95861bf1_f46d_4b05_9673_01e48857a8e9_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_c6579557_aae1_432f_99d8_164b0a90f47d_95861bf1_f46d_4b05_9673_01e48857a8e9_Return',
            function(s) 
                --Next
                nlbwalk(v_4); 
            end
        ),

    },
};

-- Wolf made off
v_38 = room {
    nam = "...",
    pic = 'images/wolf_running.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood drew one pasty from the basket, and put it right into Wolf\'s open mouth. After Wolf chewed it with pleasure, he expressed his thanks and made off.");
    end,
    xdsc = function(s)
        p "^";
        p (((_eat_pie)) and "{v_628b1001_9438_4c54_a220_d3fe7b9a03f3|Next}^" or "");
        p (((_no_eat_pie and _fin45)) and "{v_d434990c_1fff_48eb_b94f_5a7c91e44574|Next}^" or "");
        p (((_no_eat_pie and not _fin45)) and "{v_971ee17b_6777_4943_bf79_f617fcb3ac61|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_628b1001_9438_4c54_a220_d3fe7b9a03f3',
            function(s) 
                --Next
                nlbwalk(v_115); 
            end
        ),
        xact(
            'v_d434990c_1fff_48eb_b94f_5a7c91e44574',
            function(s) 
                --Next
                nlbwalk(v_42); 
            end
        ),
        xact(
            'v_971ee17b_6777_4943_bf79_f617fcb3ac61',
            function(s) 
                --Next
_fin45 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_51467b9f_3405_465d_8216_d36b24d99366);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_51467b9f_3405_465d_8216_d36b24d99366);
                nlbwalk(v_42); 
            end
        ),

    },
};

-- Hag goes down the cellar and get stuck by accident
v_39 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Old lady remembered, that ate milk mushrooms from the bowl yesterday... Or the day before yesterday... In a nutshell, she didn\'t take risk, and went down the cellar to take a new can of mushrooms. Suddenly, a wooden stick that backed up cellar cover broke, and the cover tumbled down with a clatter.^"..
"Being locked up in the dark, old lady didn\'t know what to do. In that moment, somebody knocked on the door. But no sound could penetrate through the cellar. And Wolf (because it was him) was already hammering on the door.^"..
"He thought that nobody was at home, but didn\'t go away and walked the premises around. And not in vain, from the rear he found opened window, that was easy to climb through.^"..
"Inside the house grey predator found old lady\'s clothing, then dressed up and went to bed.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _heavy and _fin42)) and "{v_22a776f9_0bcd_4afd_9383_f86233d379e0|Next}^" or "");
        p (((_heavy and _fin19)) and "{v_2f448ad0_f796_4ca9_b912_41de2e3cad28|Next}^" or "");
        p (((_heavy and not _fin19)) and "{v_5fd4b5ff_6010_4507_87a5_390db2ff5754|Next}^" or "");
        p ((( not _heavy and not _fin42)) and "{v_f8507356_7742_4250_900f_948cfbdd89d1|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/in_the_halls_of_the_frost_giant_jarl.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_22a776f9_0bcd_4afd_9383_f86233d379e0',
            function(s) 
                --Next
                nlbwalk(v_127); 
            end
        ),
        xact(
            'v_2f448ad0_f796_4ca9_b912_41de2e3cad28',
            function(s) 
                --Next
                nlbwalk(v_108); 
            end
        ),
        xact(
            'v_5fd4b5ff_6010_4507_87a5_390db2ff5754',
            function(s) 
                --Next
_fin19 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_51c497fb_5307_45a6_af11_cef8035c2b47);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_51c497fb_5307_45a6_af11_cef8035c2b47);
                nlbwalk(v_108); 
            end
        ),
        xact(
            'v_f8507356_7742_4250_900f_948cfbdd89d1',
            function(s) 
                --Next
_fin42 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_8e58d530_8ff3_48d9_aa92_b7fe2d772bdb);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_8e58d530_8ff3_48d9_aa92_b7fe2d772bdb);
                nlbwalk(v_127); 
            end
        ),

    },
};

-- Red Hood crries with meat 
v_40 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood strolls sluggishly along the wet, slippery trail, grinding grey mud with her wooden shoes. Rain makes her dress wet. Suddenly, a wolf appears in front of her. Red hood stopped dead, waiting what is going to happen next.^"..
"The predator, being deep inside his thoughts, also was taken aback, but after a brief looking around and sniffing the air, figured out that girl most likely was there alone.^"..
"\"Hello little girl!\" said Wolf, growing bolder, \"What is your name and where are you going?\"^"..
"\"My name is Red Hood, I`m going to visit my granny. I bring her pasties with meat and a pot of butter.\"^"..
"\"When Wolf heard the word \"meat\" he livened up.\"^"..
"\"My sweetheart girl, would you let me taste one?\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_084a1855_8651_492f_a6e9_71cb0cd6f02f|Give Wolf one pasty}^";
        p "{v_f1501b1d_c0e9_40ca_85e8_a604589cc701|Give Wolf no pasty}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodrain.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_084a1855_8651_492f_a6e9_71cb0cd6f02f',
            function(s) 
                --Give Wolf one pasty
                nlbwalk(v_148); 
            end
        ),
        xact(
            'v_f1501b1d_c0e9_40ca_85e8_a604589cc701',
            function(s) 
                --Give Wolf no pasty
                nlbwalk(v_25); 
            end
        ),

    },
};

-- Wolf ate
v_41 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("It is self understood, Wolf forestalled Red Hood and reached forest edge sooner. He jumped on the porch and knocked.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It is me, Red Hood, your granddaughter!\" whispered Wolf making his voice as tender as he could.^"..
"\"Oh, pull the string my dear and the door will open!\"^"..
"Once predator found himself inside the house, he promptly swallowed Grandmother, dressed up in her night gown, cap, put on glasses and tumbled into bed.^"..
"Soon after Red Hood reached granny\'s hut. She hammered on the door with her little fist.^"..
"\"Who is it...\" Wolf tried to make his voice sound suffering.^"..
"\"It\'s me, your granddaughter, Red Hood! I brought you some pasties and a pot of butter.\"^"..
"\"A-r-g-h,\" coughed Wolf, \"pull the string my dear and the door will open!\"^"..
"The girl entered, put her basket and pot on the table and sat on the bed edge to look at the old lady.^"..
"\"Grandmother, why your ears are so big?\"^"..
"\"It is so I could hear you better...\"^"..
"\"And why your eyes are so big?\"^"..
"\"It is so I could see you better...\"^"..
"\"Aha, and why your teeth are so big?\"^"..
"\"It\'s for eating you!\"^"..
"And swallowed Red Hood before she got the sense of his last words.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin5)) and "{v_d41aa0e5_5550_4eae_b62d_111a356d1e0d|Next}^" or "");
        p ((( not _fin5)) and "{v_2a0f8b88_07f4_4ef2_bdb2_ec678e2970c9|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_d41aa0e5_5550_4eae_b62d_111a356d1e0d',
            function(s) 
                --Next
                nlbwalk(v_90); 
            end
        ),
        xact(
            'v_2a0f8b88_07f4_4ef2_bdb2_ec678e2970c9',
            function(s) 
                --Next
_fin5 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_281d18c5_70d1_4edc_812c_0c46cd7fa945);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_281d18c5_70d1_4edc_812c_0c46cd7fa945);
                nlbwalk(v_90); 
            end
        ),

    },
};

-- Red Hood came to granny, left her the whole basket with pasties and went away
v_42 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood came to granny, left her the whole basket with pasties and went away. And Wolf was sitting in the bushes, and granny was the last person he cared about.^"..
"^"..
"Ending:^"..
"”Granny and a pile of pasties”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6c4a8a4f_be12_48ed_b240_7a800e1ca44d_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_6c4a8a4f_be12_48ed_b240_7a800e1ca44d_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return',
            function(s) 
                --Next
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Go
v_43 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf fetched Red Hood into his den. She was astonished to find it was a wicker hut. Inside was a massive table, cupboard with books and lots of shelves with bottles and boxes on. Of course, everything was covered with a thick layer of dust.^"..
"Being puzzled and intrigued, girl asked how she could help. Somehow she wasn\'t afraid of this wild beast any more.^"..
"\"There is a big brown book on the lower shelf in the cupboard, take it,\" started Wolf, \"now open the last page, there is a recipe. Please, make the potion according to it. All the ingredients you can find on these shelves.\"^"..
"Recipe seemed strange to Red Hood - 25 drops of hair growth inhibitor lotion, 10 drops of valerian, 11 drops of flea killer, 9 elder-berries, 1 tablet of aspirin, 50 grams of wine, 7 drops of mouthwash, 1 drop of young girl\'s blood. Also there was a postscript, \"Be strict about the dosage!\".^"..
"After studying the recipe she got down to business. She found all required components and began to measure out necessary amount of it. But after counting out 25 drops of lotion, girl lost her count.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin8)) and "{v_579a7a2f_550c_4ac1_b40d_84aeb8cfe43f|Give as it is}^" or "");
        p "{v_0bb4a812_4a93_4223_8ae4_de2d4e29fe2b|Make anew}^";
        p ((( not _fin8)) and "{v_e7851734_583f_4d86_a9a1_fbb2404517d0|Give as it is}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/beethoven_silence_echodrops.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_579a7a2f_550c_4ac1_b40d_84aeb8cfe43f',
            function(s) 
                --Give as it is
                nlbwalk(v_93); 
            end
        ),
        xact(
            'v_0bb4a812_4a93_4223_8ae4_de2d4e29fe2b',
            function(s) 
                --Make anew
                nlbwalk(v_24); 
            end
        ),
        xact(
            'v_e7851734_583f_4d86_a9a1_fbb2404517d0',
            function(s) 
                --Give as it is
_fin8 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_94aa5e87_1ee6_492c_8cc0_430e0b42978c);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_94aa5e87_1ee6_492c_8cc0_430e0b42978c);
                nlbwalk(v_93); 
            end
        ),

    },
};

-- Follow the butterfly
v_44 = room {
    nam = "...",
    pic = 'images/night.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood wouldn\'t learn by her own mistakes. She chased after the butterfly that gradually, lure-like flitted from one flower to another. Then the girl saw another butterfly, that was even more colourful and pretty than previous one and chased after it too. When Red Hood chased butterflies enough to her heart\'s content, she decided to return to the trail. She walked on and on, but the trail would not appear.^"..
"\"Maybe I\'m going the wrong way\" thought little girl, and turned in another direction.^"..
"Later she shifted direction a few more times, dashed around the forest like a brought to bay animal. She certainly was lost, but could not admit it. When it was getting darker, she stopped and began to cry. Of course it was useless to panic, and Red Hood managed to pull herself together, and decided to struggle to the end.^"..
"A few next days she followed the strategy - during the day she marched trying to find any trail that could lead her to people, and spent nights at trees. She drank dew and ate berries, thank God the forest was full of it this time of year. But by the end of the third day Red Hood hardly could shuffle her feet. She ran out of strength, and it was extremely difficult to climb a tree by the end of the day. For a long time little girl gazed through branches with thick needles at full Moon, listening to sounds of night forest until she fell into a deep doze.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin25)) and "{v_7fbbc4bb_b3ae_4297_8a13_2691fbcf2e21|Next}^" or "");
        p ((( not _fin25)) and "{v_2cba5b05_179a_4281_bd38_2572cf5a55bb|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodday2.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_7fbbc4bb_b3ae_4297_8a13_2691fbcf2e21',
            function(s) 
                --Next
                nlbwalk(v_62); 
            end
        ),
        xact(
            'v_2cba5b05_179a_4281_bd38_2572cf5a55bb',
            function(s) 
                --Next
_fin25 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_fce84888_652a_4fc4_8ce8_a760619a8a08);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_fce84888_652a_4fc4_8ce8_a760619a8a08);
                nlbwalk(v_62); 
            end
        ),

    },
};

-- But Red Hood pulled herself together fast, lifted the shotgun and shot Wolf
v_45 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Being startled, Red Hood lingered for a second, but pulled herself together, aimed the shotgun at Wolf and pulled the trigger. She missed the target, but the beast didn\'t expect such a repulse, and leaped out of the doorway with yelp of a beaten puppy, and fled into the thicket of the forest.^"..
"^"..
"Ending:^"..
"”Be prepared”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_7f783a77_5c38_49d6_850b_ab77aa280cc6_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bourne_vivaldi_orchestral_score.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_7f783a77_5c38_49d6_850b_ab77aa280cc6_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return',
            function(s) 
                --Next
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Wolf snatches the basket runs away
v_46 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Wet and hungry Wolf was scouring around not far. He already smelled the scent of  prey, that led him to the trail. When Wolf saw an adult human, he chickened out a little, but hunger forced him to talk to the traveler.^"..
"\"Hello, Madam!\" said Wolf chattering, \"What is Your...\"^"..
"\"I don\'t talk to strangers!\" snapped out woman, cause she was very tired, got wet and wanted to get home as soon as possible.^"..
"Wolf began to tremble with malice, he even got hot. He wished to rush forward and swallow his prey, but was afraid, that after prolonged hunger wouldn\'t have enough strength. So he made another decision. He stepped aside, like for letting woman go, and when she passed him, snatched out the basket and disappeared in the forest.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _enough)) and "{v_2c6ab50d_a08c_4fd2_9620_9055d62e5a61|Next}^" or "");
        p (((_enough)) and "{v_b5351ef9_25d9_4a30_9293_74321e8fa97b|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_2c6ab50d_a08c_4fd2_9620_9055d62e5a61',
            function(s) 
                --Next
                nlbwalk(v_131); 
            end
        ),
        xact(
            'v_b5351ef9_25d9_4a30_9293_74321e8fa97b',
            function(s) 
                --Next
                nlbwalk(v_134); 
            end
        ),

    },
};

-- In the interim Red Hood comes to Grandmother
v_47 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("After some time past, Red Hood approached Grandmother\'s house and knocked on the door.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It\'s me, Red Hood, your granddaughter!\"^"..
"\"Oh, pull the string my dear and the door will open!\"^"..
"Grandmother was glad to her visitor, they hugged each other, and then sat down to have tea with pasties and butter. Then old lady asks, \"Did you have trouble on the road, granddaughter? Is everything alright?\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ff90fa0c_4dd0_41a8_b46a_6f3e2260909d|Tell about Wolf on the road}^";
        p "{v_c4d16e5d_ebea_446a_a054_6036306e18cb|Do not tell about meeting Wolf}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/chanson_triste.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_ff90fa0c_4dd0_41a8_b46a_6f3e2260909d',
            function(s) 
                --Tell about Wolf on the road
                nlbwalk(v_105); 
            end
        ),
        xact(
            'v_c4d16e5d_ebea_446a_a054_6036306e18cb',
            function(s) 
                --Do not tell about meeting Wolf
                nlbwalk(v_57); 
            end
        ),

    },
};

-- Mother carries with cabbage. Wolf came to Red Hood
v_48 = room {
    nam = "...",
    pic = 'images/mother_road2.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother took presents and set out. She was walking slowly down the road, inhaled fresh forest air enjoying warm sunlight, without noticing that Wolf was following her tracks. It was the very caution that hindered Wolf not only to attack, but even to speak to an adult person, all the more a group of woodcutters was working nearby. Then the beast resorted to cunning - distinctly discerning smell of a traveler on the road, he followed the opposite direction hoping that there might be left someone weaker.^"..
"Soon Wolf found Mother\'s house and knocked on the door.^"..
"\"Who is it?\" asked Red Hood.^"..
"\"It\'s your neighbor.\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_81c50c75_f4af_4ec2_ac7b_4822ed513fe1|-Take a hike!}^";
        p "{v_bcedb668_8ee2_4ea4_93bf_1f657560c339|-Come in!}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/flight_of_the_bumblebee_a.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_81c50c75_f4af_4ec2_ac7b_4822ed513fe1',
            function(s) 
                ---Take a hike!
                nlbwalk(v_63); 
            end
        ),
        xact(
            'v_bcedb668_8ee2_4ea4_93bf_1f657560c339',
            function(s) 
                ---Come in!
                nlbwalk(v_130); 
            end
        ),

    },
};

-- Red Hood seized the basket by a death grip screaming as loud as she could
v_49 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood startled from suddenness, but seized the basket by a death grip, dropping butter pot on the ground and screaming as loud as she could. The predator growled and grinned trying to pull out baggage from the girl\'s hands, when suddenly heard, that sound of axes in the vicinity of the trail subsided. Wolf found it reasonable to retreat, and as soon as possible.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a8f679e2_1430_4608_ae9c_4f90908b80f5|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bourne_vivaldi_orchestral_score.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_a8f679e2_1430_4608_ae9c_4f90908b80f5',
            function(s) 
                --Next
                nlbwalk(v_83); 
            end
        ),

    },
};

-- Wolf ate RED HOOD
v_50 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("The beast patiently awaited for Red Hood to come, and after a while sounded cherished tone.^"..
"\"Who is it...Wolf tried to imitate voice of an ill person.\"^"..
"\"It is me, Red Hood, your granddaughter! I brought you pasties and a pot of butter.\"^"..
"\"A-r-g-h,\" Wolf coughed,  \"pull the string my dear and the door will open!\"^"..
"The girl entered, put the basket and the pot on the table, and sat on the bed edge to take a closer look at the old lady.^"..
"\"Oh, Grandmother, why you\'ve got so big ears!\"^"..
"\"It is so I could hear you better...\"^"..
"\"And why you\'ve got so big eyes!\"^"..
"\"It is so I could see you better...\"^"..
"\"And why your you\'ve got hoarse, bass voice?\"^"..
"For that question Wolf was not ready.^"..
"\"Well...\" Wolf began to roll his eyes, \"I\'m sick!\" he finally thought up.^"..
"\"Aha, and why you\'ve got so big teeth? Hypercalcemia?\"^"..
"\"What?\" Wolf didn\'t catch that. But thought, \"What\'s the difference,\" and said, \"It\'s for eating you!\"^"..
"And swallowed Red Hood, before she got the meaning of his words.^"..
"^"..
"Ending:^"..
"”Retarded ignition”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_cb5b7235_b99e_45cd_8d5e_8f20a1ac75b3_8f127e94_d289_456e_896a_dd397aa32341_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_cb5b7235_b99e_45cd_8d5e_8f20a1ac75b3_8f127e94_d289_456e_896a_dd397aa32341_Return',
            function(s) 
                --Next
                nlbwalk(v_13); 
            end
        ),

    },
};

-- He realized that it was useless 
v_51 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("\"How does she look like?\" asked Mother winking at granny.^"..
"\"I couldn\'t scrutinize, I have impaired vision\" answered slyboots.^"..
"\"Talk through the door, or go to hell! We don\'t open to strangers\" said Mother being pretty sure that stranger was lying, and her daughter would never let an unknown person in.^"..
"\"It\'s probably a family tradition,\" thought Wolf. He realized that it was useless and returned to the forest to take a nap in his lair.^"..
"^"..
"Ending:^"..
"”Proper upbringing”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a20cf59a_13cf_47a2_ad6a_eee2a53eed71_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_a20cf59a_13cf_47a2_ad6a_eee2a53eed71_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return',
            function(s) 
                --Next
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Sun arose
v_52 = room {
    nam = "...",
    pic = 'images/butterfly.png',
    bgimg = function() end,
    dsc = function(s)
p("The night passed in quiet, and when the Sun arose, she saw her trail. When climbed down, she cheerfully ran along the trail.^"..
"Joy was filling her heart, once again she stayed alive and unharmed. In addition left the forest without getting lost. She walked along the path admiring every flower and every butterfly. One of them was especially large and bright coloured. Red Hood wanted to look closely at it, but little thing took wings off the camomile and flew into the forest.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_3636f0fe_0c33_4134_8c66_fd2132d952e5|Do not follow the butterfly}^";
        p "{v_06dbe6da_fe43_46f6_b9cc_e47c7137aa79|Follow the butterfly}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/a_la_mozart.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_3636f0fe_0c33_4134_8c66_fd2132d952e5',
            function(s) 
                --Do not follow the butterfly
                nlbwalk(v_139); 
            end
        ),
        xact(
            'v_06dbe6da_fe43_46f6_b9cc_e47c7137aa79',
            function(s) 
                --Follow the butterfly
                nlbwalk(v_44); 
            end
        ),

    },
};

-- Red Hood easily carries the basket
v_53 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("She suddenly met Wolf.^"..
"\"Hello, girl!\" started Wolf, feeling his full supremacy.^"..
"\"How do You do, sir.\" said Red Hood, looking at her interlocutor with curiosity.^"..
"\"What is your name and where are you going all alone.\" continued Wolf making stress on word \"alone\".^"..
"\"My name is Red Hood, I\'m going to visit my granny and bring her some pasties, and a pot of butter.\"^"..
"\"And my name is Wolf. Where does your grandma live?\"^"..
"\"You should go straight down this road, and when you get to the crossroads, turn right, then make 20 steps and walk south-eastwards. Then make 30 steps more and turn right by the large anthill. But make sure that ants are red, not black. As soon as You get to three pines, but not spruces on the hill, turn left. Then go straight to the forest edge and You\'ll see the house.^"..
"Silence came. Wolf was processing information. To break prolonged pause Red Hood made a suggestion, \"Actually you can take a short road directly through the forest, but I\'m scared to go this way, because there are no landmarks and trails.\"^"..
"\"Good bye girl!\" said Wolf.^"..
"After obtaining all required information, he immediately decided to go to the old lady.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_37e69a9e_2ca4_471d_b1f6_866637a2e57c|Wolf ran the short road to granny\'s house}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_37e69a9e_2ca4_471d_b1f6_866637a2e57c',
            function(s) 
                --Wolf ran the short road to granny\'s house
                nlbwalk(v_80); 
            end
        ),

    },
};

-- Red Hood ate a pasty with mushrooms
v_54 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Soon afterwards, she felt that the Sun was not just making air warm, but incandescent. \"No wonder,\" thought little girl, \"it is so large, covering half the sky.\"^"..
"She inclined her head to wipe sweat off her forehead, but unintentionally screamed and stood still. A precipice yawned to her left and right. Deep down, trees showed green and seemed toy at that distance. Red Hood herself stood on the narrow path, and could fall into the abyss at any moment. She hanged the basket on the shoulder, stretched her arms apart, and carefully started to move forward, like she was balancing on a rope.^"..
"For a few minutes now, Wolf was watching her from the bushes. Meanwhile, Red Hood found herself in front of a large lake. She was a good swimmer, so she jumped into water to cross it without delay. By-turn, Wolf observed the way little girl was wallowing on the road, in dust, with a basket on her back. Wolf  had never seen anything like that. He was about to leave this place, but his stomach began its loud rumbling, and beast plucked up heart to act. He stepped on the trail in front of Red Hood. Right at that moment she reached the opposite shore, and tried to wring out her wet clothing. Wolf was about to open his chap to start conversation, when girl spotted him.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_2594c901_4f72_4738_9886_d86f7480cf66|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/a_la_mozart_bird.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_2594c901_4f72_4738_9886_d86f7480cf66',
            function(s) 
                --Next
                nlbwalk(v_150); 
            end
        ),

    },
};

-- Pasties with meat
v_55 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother checked the boxroom, went down the cellar and found the last salt hunchback salmon from the last year stock.^"..
"\"It lies here for a long time,\" thought the woman, \"I\'d better take a piece of meat, its looks much better\".^"..
"But meat was frozen and she had to thaw it out first. Later it was finely cut, and fried with onion on a pan. When filling was cool enough, she got down to pasties shaping.^"..
"While pasties were in the stove, it was already late, and Mother decided to visit granny tomorrow.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e51b120e_d7b5_4123_be3b_84cd859ef68f|In early morning Mother woke Red Hood and says to her...}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
            addf(nil, v_aabdd986_9e61_417d_805e_8751b4d6182c);
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bumblebee.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_e51b120e_d7b5_4123_be3b_84cd859ef68f',
            function(s) 
                --In early morning Mother woke Red Hood and says to her...
                nlbwalk(v_122); 
            end
        ),

    },
};

-- Red Hood carries with fish
v_56 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood was an obedient child. She took pasties with fish and went away. Bright and warm sun rays, finding its way through the foliage, were giving birth to hundreds of sunlight spots, birdies were twitting, butterflies flitting. Red Hood was running  skippingly along the path, she was in a cheerful mood. But for bad luck she had not had breakfast that day, and because of fresh air she felt hunger.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_31be88db_321f_4480_96cd_4e6e7b974a18|Eat one pasty}^";
        p "{v_2175a217_4421_483f_9de0_f72b1853d5cc|Eat a few pasties}^";
        p "{v_5d38c185_303b_4837_9f8f_92307cd11331|Eat no pasties}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/a_la_mozart.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_31be88db_321f_4480_96cd_4e6e7b974a18',
            function(s) 
                --Eat one pasty
_eat_pie = true;
                nlbwalk(v_68); 
            end
        ),
        xact(
            'v_2175a217_4421_483f_9de0_f72b1853d5cc',
            function(s) 
                --Eat a few pasties
                nlbwalk(v_126); 
            end
        ),
        xact(
            'v_5d38c185_303b_4837_9f8f_92307cd11331',
            function(s) 
                --Eat no pasties
_no_eat_pie = true;
                nlbwalk(v_94); 
            end
        ),

    },
};

-- They continued to drink tea and chatter
v_57 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood did not want to bother old lady for no reason and replied, \"Fine, as usual, just got chilled a bit.\"^"..
"\"That\'s ok, take my shawl, muffle up and get warm.\"^"..
"The girl wrapped herself in shawl and Grandmother added some hot water into girl\'s cup. They serenely continued to drink tea and chatter.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_903b91a4_83f2_4efe_a7ce_112cc726fddb|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_903b91a4_83f2_4efe_a7ce_112cc726fddb',
            function(s) 
                --Next
                nlbwalk(v_27); 
            end
        ),

    },
};

-- Pasties with apples
v_58 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("This year\'s apple harvest was immense! So decision of what filling to choose was easy to make. Mother took the largest container she had, and made pastry in it.^"..
"Then, together with Red Hood peeled and chopped a pile of apples. They shaped lots of pastes and had to bake them for two days. When finally everything was ready, it was time to decide who would carry them.");
    end,
    xdsc = function(s)
        p "^";
        p (((_apple)) and "{v_fcbf434c_04f5_4db6_84ac_4589771e87b4|Red Hood would carry them}^" or "");
        p (((_apple)) and "{v_0fa4dc2d_f021_42fb_a8ac_572fdf705565|Mother would carry them}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bumblebee.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_fcbf434c_04f5_4db6_84ac_4589771e87b4',
            function(s) 
                --Red Hood would carry them
_chaperon = true;
                nlbwalk(v_34); 
            end
        ),
        xact(
            'v_0fa4dc2d_f021_42fb_a8ac_572fdf705565',
            function(s) 
                --Mother would carry them
_mother = true;
                nlbwalk(v_65); 
            end
        ),

    },
};

-- Wolf ate granny and wait for Red Hood
v_59 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("A few hours later, Red Hood was hardly moving her feet approaching granny\'s house. Pulling all remaining strength together, she climbed the porch and almost hung upon the door.^"..
"\"Who is it?\" asked old lady in a weak voice.^"..
"\"It\'s granddaughter!\" answered emaciated Red Hood! \"Open up!\" she breathed out, hoping that granny would let her in, and together they could pull the basket into the house.^"..
"But old lady said, \"Pull the string my dear and the door will open.\"^"..
"Nobody knows what Red Hood thought at that moment, because she was too young.^"..
"After leaving the basket and the pot of butter, and listening to three-hour health report, the girl finally went home to sleep.^"..
"Granny was eating pasties with butter, and Wolf after stress fell into a doze.^"..
"^"..
"Ending:^"..
"\"Deserved rest\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c0ec5bc9_eeb1_482e_9f96_b04cb4eda75b_62442425_2015_4757_88c4_0ec58edf555e_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/chanson_triste.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_c0ec5bc9_eeb1_482e_9f96_b04cb4eda75b_62442425_2015_4757_88c4_0ec58edf555e_Return',
            function(s) 
                --Next
                nlbwalk(v_5); 
            end
        ),

    },
};

-- Cooks with cabbage
v_60 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother went down the cellar and found the last salt hunchback salmon: \"It lies here for a long time,\" thought the woman,  \"I\'ll take some meat. Perhaps not, remaining piece is too small. There are dozens of apples... Nah, I\'m already sick of them. Is there cabbage left?\"^"..
"Mother came up to a large crate and lifted bagging. Still there were a couple cabbage heads. The matter with filling was solved, and woman got down to business: made pastry, chopped cabbage; in two hours browned and flavoured pasties were ready to be put in the basket.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_3075fcde_df97_4eb1_8542_74b03d0dda50|...and says:}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bumblebee.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_3075fcde_df97_4eb1_8542_74b03d0dda50',
            function(s) 
                --...and says:
                nlbwalk(v_122); 
            end
        ),

    },
};

-- Girl was not easy to scare
v_61 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("But the girl was not easy to scare. In a moment she jumped out of the window, rushed in a wooden toilet, and locked herself up. Expecting no resistance Wolf ran after her, but was one second late, and the door closed in front of his nose.^"..
"Wolf made lots of circles around, gnashing. And Red Hood watched him with a sinking heart through cracks of her ramshackle sanctuary.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_d8e4c43d_8792_4916_931c_a43110b54c1f|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bourne_vivaldi_orchestral_score.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_d8e4c43d_8792_4916_931c_a43110b54c1f',
            function(s) 
                --Next
                nlbwalk(v_147); 
            end
        ),

    },
};

-- Woodcutter savior
v_62 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("She woke up in early morning. The Sun had just appeared in the horizon. Some extraneous shrilly sounds were bringing about confusion into usual, monotonous forest life. Half-awake girl tried to figure out who or what was making so familiar noise.^"..
"\"That\'s it, axe hammering!\" she almost screamed. And somewhere close, not too far. She began to rotate her head left and right, trying to get off the tree, but after a night her whole body became numb, muscles stiffened and wouldn\'t obey. But Red Hood paid no attention to it and kept trying to get down. \"Be quick, be quick!\" Red Hood mentally hurried herself, worrying that magical sound would disappear or turn out to be a dream. Her breath became more frequent, hands shivered. After a few seconds, noise really subsided. Believing not to her ears the girl was ready to burst into tears, but slowly began to bend to the right. She seized branches even tighter but it didn\'t save her from falling, that was accelerating.^"..
"\"A-a-a!\"^"..
"A desperate cry, mixed with crackle of broken branches and leaf rustle filled the forest. Scared by the cry woodcutter ran up to the tree, he just cut, and spotted a small girl among the branches. She turned out to be alive and almost unharmed, despite a few scratches. The kind woodcutter asked Red Hood where she lived, and brought her back to the house, that was easy for him to find. As a person of his trade, he knew the forest like the palm of his hand.^"..
"^"..
"Ending:^"..
"”Woodcutter saviour”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_5d1f2b60_363e_4d6d_9e1c_880abf5b94fb_0893e545_e122_46db_9b79_e253c763ca51_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_5d1f2b60_363e_4d6d_9e1c_880abf5b94fb_0893e545_e122_46db_9b79_e253c763ca51_Return',
            function(s) 
                --Next
                nlbwalk(v_3); 
            end
        ),

    },
};

-- Wolf didn\'t eat Red Hood
v_63 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("\"We have no neighbors!\" confidently said Red Hood.^"..
"\"We just moved in.\"^"..
"\"I don\'t care! I never heard of you! And I never open doors to strangers!\"^"..
"Red Hood was alone at home, but no one knew about this, and she wasn\'t going to let anybody in.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_04c42b1f_beec_432d_b057_855d5381c12d|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_04c42b1f_beec_432d_b057_855d5381c12d',
            function(s) 
                --Next
                nlbwalk(v_147); 
            end
        ),

    },
};

-- Eats one pasty
v_64 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother decided that she ought to refresh herself and ate one pasty.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6956fd4d_6512_44b5_875f_8f36e4dda0a1|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_6956fd4d_6512_44b5_875f_8f36e4dda0a1',
            function(s) 
                --Next
_enough = true;
                nlbwalk(v_46); 
            end
        ),

    },
};

-- Mother carries with apples
v_65 = room {
    nam = "...",
    pic = 'images/mother_road2.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother says, \"Red Hood, why don\'t you go to your Grandmother, bring her pasties, a pot of butter, and find out how is she.\"^"..
"But Red Hood didn\'t respond, she was sleeping like a dog among the pasties, so no one could wake her up.^"..
"Mother lifted a wicker basket with pasties and went by herself. The day was warm and quiet, the Sun sometimes hid behind floating clouds. In spite of her burden, Mother was moving pretty fast. She wanted to bring presents as soon as possible, and return home for rest.^"..
"The woman didn\'t realize, that Wolf already found her tracks and was following it, assessing his chances and planning strategy.^"..
"Mother\'s attention was drawn by hammering of axes. The basket was heavy and the distance long, so she got an idea to treat workers with pasties, and make her load lighter.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_edfdbfd7_0e41_4bfd_9650_7c5b1ddd43a1|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bumblebee.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_edfdbfd7_0e41_4bfd_9650_7c5b1ddd43a1',
            function(s) 
                --Next
                nlbwalk(v_151); 
            end
        ),

    },
};

-- In the forest
v_66 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("The weather was marvelous, spring Sun was warming up the air, birds were twitting. Snow still remained somewhere in the forest, but the path was already free from the winter cover, and woman slowly marched over soft, but no boggy ground.^"..
"The walk was long, and after a few hours on fresh air woman felt much clearer, that smells of the forest were mixing with smell of still warm pasties with hunchback salmon.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c9353d8b_2711_4be5_b714_ba6fa06f6c30|Eat one pasty}^";
        p "{v_d23c8001_db04_46b5_813e_5aee4c20fa8a|Don\'t eat a pasty}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodday4.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_c9353d8b_2711_4be5_b714_ba6fa06f6c30',
            function(s) 
                --Eat one pasty
                nlbwalk(v_137); 
            end
        ),
        xact(
            'v_d23c8001_db04_46b5_813e_5aee4c20fa8a',
            function(s) 
                --Don\'t eat a pasty
                nlbwalk(v_142); 
            end
        ),

    },
};

-- Wolf caught up with Mother and ate her
v_67 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf sneaked up to unsuspecting woman from behind, and then attacked and ate.^"..
"^"..
"Ending:^"..
"”Wolf nature”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a16c48e3_f375_4112_bcd6_fa9ced63aa81_62442425_2015_4757_88c4_0ec58edf555e_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_a16c48e3_f375_4112_bcd6_fa9ced63aa81_62442425_2015_4757_88c4_0ec58edf555e_Return',
            function(s) 
                --Next
                nlbwalk(v_5); 
            end
        ),

    },
};

-- Red Hood ate a pasty, it was delicious
v_68 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("\"I\'ve got the whole basket of pasties, if I take one, no one will notice\".^"..
"Red Hood ate a pasty, it was delicious.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_95b41a2d_27f0_4a1f_b245_ffa2dd6d10a5|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_95b41a2d_27f0_4a1f_b245_ffa2dd6d10a5',
            function(s) 
                --Next
                nlbwalk(v_31); 
            end
        ),

    },
};

-- Wood cutters saw opened door
v_69 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Woodcutters were passing by. They saw opened door but nobody was inside, pasties were lying on the floor. They took a couple of pasties and put the rest on the table, as they were shy to take everything. Later they were glad that they did so, because got off with a light indisposition.^"..
"^"..
"Ending:^"..
"”Art of moderate eating”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_bf462224_17a1_4dfc_b2f9_838ca3be35e7_01a4c786_f042_4fcd_8333_afac265f0328_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_bf462224_17a1_4dfc_b2f9_838ca3be35e7_01a4c786_f042_4fcd_8333_afac265f0328_Return',
            function(s) 
                --Next
                nlbwalk(v_8); 
            end
        ),

    },
};

-- Wolf ran home to defecate
v_70 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("In the same interim Wolf found the basket under the bush and, of course, ate everything what remained. Now the same fate was in store for him as for Red Hood.^"..
"^"..
"Ending:^"..
"”You don\'t get rid of good stuff”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_3e49d28f_b01e_4254_bc41_b73333e7d0d1_95861bf1_f46d_4b05_9673_01e48857a8e9_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony_fast.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_3e49d28f_b01e_4254_bc41_b73333e7d0d1_95861bf1_f46d_4b05_9673_01e48857a8e9_Return',
            function(s) 
                --Next
                nlbwalk(v_4); 
            end
        ),

    },
};

-- Everybody feast upon pasties except for Wolf
v_71 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("When Red Hood heard sound of axes, somewhere to the left from the trail, she ran towards it. The girl was very glad to see woodcutters, and in a confused manner explained them what happened, asking for help. Of course stout men could not deny assistance to a child.^"..
"\"Show us the way!\" sternly said one of them.^"..
"Once falling into sleep in the house on the forest edge Wolf did never wake up. No doubt woodcutters facilitated him in it. Grandmother was taken out alive and unharmed, and afterwards sat down to have tea with pasties.^"..
"^"..
"Ending:^"..
"”Stay alerted”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_9339d69b_f2ff_4a3f_95ec_a5c049a3a330_7e35525f_46ee_4774_a39a_5b794054b395_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_9339d69b_f2ff_4a3f_95ec_a5c049a3a330_7e35525f_46ee_4774_a39a_5b794054b395_Return',
            function(s) 
                --Next
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Woodcutters chased
v_72 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf didn\'t want to pass them around. He hoped to slip fast through, but failed. One of men sighted him.^"..
"\"Guys look, Wolf!\" he cried.^"..
"Everybody looked the way speaker pointed.^"..
"\"Indeed!\" answered another one, \"Take him lads!\"^"..
"After those words the woodcutters began go chase grey predator.^"..
"Wolf realized, that he was spotted and ran with all his strength. Suddenly, Wolf noticed that an axe pierced the tree beside him with a clanging sound. It were pursuers, seeing that their prey was getting away, began to throw axes like tomahawks, but everyone missed the target.^"..
"If Wolf were a man, he\'d probably thank God mentally for his escape. But because he was a beast, he just lied under the bush, with wildly beating heart and panting.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin16)) and "{v_7855d12a_ed21_4a40_ac0e_1fe070be502a|Next}^" or "");
        p ((( not _fin16)) and "{v_257c9f78_3e22_492c_bec3_23c352a3dcda|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/etude_timpani.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_7855d12a_ed21_4a40_ac0e_1fe070be502a',
            function(s) 
                --Next
                nlbwalk(v_59); 
            end
        ),
        xact(
            'v_257c9f78_3e22_492c_bec3_23c352a3dcda',
            function(s) 
                --Next
_fin16 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_5e992f11_270f_4264_b59d_b625a68255b0);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_5e992f11_270f_4264_b59d_b625a68255b0);
                nlbwalk(v_59); 
            end
        ),

    },
};

-- Basket was heavy, Hood was moving slowly. Wolf fell asleep.
v_73 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("At that time the girl persistently kept going. The basket was very heavy, so Red Hood walked slowly. Satiated Wolf was already lying in warm bed for long time. Behind the window was heard twitting of birds, some little animals rustled in the grass. All this peaceful fuss exerted lulling effect on Wolf, and he fell asleep.^"..
"By that time Red Hood approached granny\'s house, hardly dragging her feet. Pulling all remaining strength together, she climbed the porch and almost hung upon the door. She was surprised to find that it was unlocked! Puffing and panting Red Hood entered the house, hoisted the basket on the table, and breathed out with relief.^"..
"As she came up to bed, she saw that granny was sleeping. But girl\'s attention was drawn by the fact, that large ears protruded from under the old lady\'s cap. \"I wonder,\" thought Red Hood, \"why granny has got so large ears?\" Then her attention was drawn to the teeth. \"And why she\'s got so large teeth?\" Here grey tail fell from under the blanket. \"It\'s Wolf!!!\"^"..
"Hardly holding back the scream of horror, Red Hood did her best to leave the house without a sound, and rushed to the forest.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin33)) and "{v_72c80be4_da9d_41e9_8614_8135a66475d6|Next}^" or "");
        p ((( not _fin33)) and "{v_5462989d_d2ad_48eb_ab1f_3a88a6ef617e|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodday5.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_72c80be4_da9d_41e9_8614_8135a66475d6',
            function(s) 
                --Next
                nlbwalk(v_71); 
            end
        ),
        xact(
            'v_5462989d_d2ad_48eb_ab1f_3a88a6ef617e',
            function(s) 
                --Next
_fin33 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_fcdc0f27_8dff_46f8_a43f_76e3ddd3e19f);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_fcdc0f27_8dff_46f8_a43f_76e3ddd3e19f);
                nlbwalk(v_71); 
            end
        ),

    },
};

-- Wolf ate hag
v_74 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf approached the hut and knocked on the door.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It is me, Red Hood, your granddaughter!\" whispered Wolf making his voice as tender as he could.^"..
"\"Ah, pull the string my dear and the door will open!\"^"..
"Once predator got inside, he promptly swallowed granny, dressed up in her night gown, glasses, cap and lied to bed.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin9)) and "{v_83e3280c_2a8b_4d38_812d_ba44e3600cc0|Next}^" or "");
        p ((( not _fin9)) and "{v_2f10fb96_ac53_43a5_a693_ba4bd91a3bd6|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_83e3280c_2a8b_4d38_812d_ba44e3600cc0',
            function(s) 
                --Next
                nlbwalk(v_50); 
            end
        ),
        xact(
            'v_2f10fb96_ac53_43a5_a693_ba4bd91a3bd6',
            function(s) 
                --Next
_fin9 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_a7514b63_788d_4041_8883_b26456439ab2);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_a7514b63_788d_4041_8883_b26456439ab2);
                nlbwalk(v_50); 
            end
        ),

    },
};

-- Mother sees hallucinations
v_75 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Why don\'t I eat one pasty\" she thought, \"I need to degust it anyway.\"^"..
"After eating it with pleasure, woman pointed out to herself, that baked goods were a great success.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ad6e0dc2_4d84_4bfe_936b_9fead122d604|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_ad6e0dc2_4d84_4bfe_936b_9fead122d604',
            function(s) 
                --Next
                nlbwalk(v_154); 
            end
        ),

    },
};

-- Wolf to granny
v_76 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Meanwhile, hungry Wolf was approaching old lady\'s house. He silently jumped on the porch and listened. Two women voices could be heard behind the door. It appeared, that no one else was at home. Predator knocked.^"..
"\"Who is it?\" asked old lady.^"..
"\"Your little girl sent me. Open the door!\"");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin10)) and "{v_6567c26c_4b1a_47ef_85e6_ff769c1167ba|-Get lost!}^" or "");
        p (((_fin24)) and "{v_b5fb0118_d132_4efd_be6c_8a40584e3f97|- Pull the string and the door will open! - said old lady.}^" or "");
        p ((( not _fin10)) and "{v_0c9f7637_d9fd_4d11_b3bb_752fddbc9f49|-Get lost!}^" or "");
        p ((( not _fin24)) and "{v_43fe6360_bb32_43a6_86b5_2b81ffb5fab4|- Pull the string and the door will open! - said old lady.}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_6567c26c_4b1a_47ef_85e6_ff769c1167ba',
            function(s) 
                ---Get lost!
                nlbwalk(v_51); 
            end
        ),
        xact(
            'v_b5fb0118_d132_4efd_be6c_8a40584e3f97',
            function(s) 
                --- Pull the string and the door will open! - said old lady.
                nlbwalk(v_152); 
            end
        ),
        xact(
            'v_0c9f7637_d9fd_4d11_b3bb_752fddbc9f49',
            function(s) 
                ---Get lost!
_fin10 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_e7b736e4_0465_4bcc_a1cb_cd6aee2d3fb4);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_e7b736e4_0465_4bcc_a1cb_cd6aee2d3fb4);
                nlbwalk(v_51); 
            end
        ),
        xact(
            'v_43fe6360_bb32_43a6_86b5_2b81ffb5fab4',
            function(s) 
                --- Pull the string and the door will open! - said old lady.
_fin24 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_73c938af_ddd4_474e_823d_9eeefb02c657);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_73c938af_ddd4_474e_823d_9eeefb02c657);
                nlbwalk(v_152); 
            end
        ),

    },
};

-- Red Hood set off to grandma
v_77 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("They removed some portion of pasties and girl finally set off to Grandmother. Middle-weight basket was easier to carry. The Sun was shining, birds singing, squirrels moving to and fro. Everything was as usual, her mood was good, despite tiredness after two days baking. She saw a beautiful butterfly sitting on the road.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_fad820ba_8a04_46d6_88b9_5dbceedd456a|Keep going}^";
        p "{v_c93f83ca_97f5_4731_9550_3e8698779f29|Come closer to butterfly}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/a_la_mozart.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_fad820ba_8a04_46d6_88b9_5dbceedd456a',
            function(s) 
                --Keep going
                nlbwalk(v_53); 
            end
        ),
        xact(
            'v_c93f83ca_97f5_4731_9550_3e8698779f29',
            function(s) 
                --Come closer to butterfly
                nlbwalk(v_116); 
            end
        ),

    },
};

-- Wolf politely says hello and asks to entertain him with a pasty
v_78 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Finally caution prevailed, and it cost predator all he knew to restrain momentary impulse. After Wolf outran Mother, he slowly stepped on the trail right in front of her. Caught by surprise woman stopped as if rooted to the ground.^"..
"Wolf slowly stepped forward, and demonstrating a kind smile said:^"..
"\"Hello, dear Madam! I apologize for unceremoniousness, but smell coming out of Your basket made me break decorum and address You directly with a modest request. Would You be so kind to entertain me with the contents of this marvelous basket?\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_49cac30b_03e3_49d9_bf7e_68a33d4ff5af|Entertain Wolf}^";
        p "{v_94f9f9ce_cd84_4969_9084_a2fcbb4e85a0|Do not entertain Wolf}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_49cac30b_03e3_49d9_bf7e_68a33d4ff5af',
            function(s) 
                --Entertain Wolf
                nlbwalk(v_21); 
            end
        ),
        xact(
            'v_94f9f9ce_cd84_4969_9084_a2fcbb4e85a0',
            function(s) 
                --Do not entertain Wolf
                nlbwalk(v_36); 
            end
        ),

    },
};

-- Woodcutter follows her undetected
v_79 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Knowing that to find this woman later would be a harder task, he decided to go after.^"..
"The man took his axe and cautiously followed the woman. He moved unnoticeably on the right side of the road, hiding behind trees and making his steps silent. Suddenly, his eyesight caught a wolf. Wolf was creeping on the left side of the road, a few paces ahead of the woodcutter. The beast was so excited with a pursuit, so he didn\'t notice another player. Plus, woodcutter was moving from the leeward side.^"..
"Shortly Mother reached granny\'s house.  As soon as she opened the door and stepped across the threshold, Wolf rushed after her. Bud woodcutter was prepared. Having an effect of surprise, he attacked Wolf from behind and killed him. The predator couldn\'t even realize what happened; so he died with a happy expression on his muzzle, anticipating nourishing meal.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin44)) and "{v_5d132ba3_92be_467f_9eb0_4f0721352baa|Next}^" or "");
        p ((( not _fin44)) and "{v_7e5653d0_70af_48b6_be1b_b844d44924f5|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/etude_overdrive_guitar.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_5d132ba3_92be_467f_9eb0_4f0721352baa',
            function(s) 
                --Next
                nlbwalk(v_84); 
            end
        ),
        xact(
            'v_7e5653d0_70af_48b6_be1b_b844d44924f5',
            function(s) 
                --Next
_fin44 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_fabcc368_e24c_4e1e_ae70_e877d7304e6d);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_fabcc368_e24c_4e1e_ae70_e877d7304e6d);
                nlbwalk(v_84); 
            end
        ),

    },
};

-- Wolf spotted woodcutters
v_80 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf ran the short road. While running through the forest, predator spotted woodcutters.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _heavy)) and "{v_b3165eb4_e711_4e31_ade2_6164e73f2aaf|Take risk and run past}^" or "");
        p "{v_fbb27ff1_c7ec_41b6_b96f_9adc3b39ce6c|Do not take risk and go around}^";
        p (((_heavy)) and "{v_0d479c15_555e_4590_9ee1_31bbf3719c10|Take risk and run past}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_b3165eb4_e711_4e31_ade2_6164e73f2aaf',
            function(s) 
                --Take risk and run past
                nlbwalk(v_95); 
            end
        ),
        xact(
            'v_fbb27ff1_c7ec_41b6_b96f_9adc3b39ce6c',
            function(s) 
                --Do not take risk and go around
                nlbwalk(v_114); 
            end
        ),
        xact(
            'v_0d479c15_555e_4590_9ee1_31bbf3719c10',
            function(s) 
                --Take risk and run past
                nlbwalk(v_72); 
            end
        ),

    },
};

-- Cooks with mushrooms
v_81 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("This year\'s apple harvest was immense! Boxroom and cellar were filled with dried and soaked fruits together with jam, compote and even syrup. \"Maybe I should use it for filling?\" the woman thought. \" But after the very thought about apples, she shuddered, cause everybody was fed up with it. Instantly Mother remembered, that granny was fond of mushrooms. So she chose it.^"..
"She swiftly made pastry, fried mushrooms with onion, and baked browned, flavoured pasties. When it got cold, she put them in a basket...");
    end,
    xdsc = function(s)
        p "^";
        p "{v_eaefcb53_3b24_40f8_9ae8_a30da4faf2e8|...and says:}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bumblebee.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_eaefcb53_3b24_40f8_9ae8_a30da4faf2e8',
            function(s) 
                --...and says:
                nlbwalk(v_122); 
            end
        ),

    },
};

-- Red Hood carries pasties with mushrooms
v_82 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood was an obedient child. She took pasties with mushrooms and went away. Bright and warm sun rays, finding its way through the foliage, were giving birth to hundreds of sunlight spots, birdies were twitting, butterflies flitting. Red Hood was running  skippingly along the path, she was in a cheerful mood. But for bad luck she had not had breakfast that day, and because of fresh air she felt hunger.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f46ccb31_cdb5_42ef_96ea_0c063a7138b6|Do not eat a pasty}^";
        p "{v_116ff373_916f_4199_9e1f_c892ce1ab17e|Eat one pasty}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodday4.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_f46ccb31_cdb5_42ef_96ea_0c063a7138b6',
            function(s) 
                --Do not eat a pasty
                nlbwalk(v_102); 
            end
        ),
        xact(
            'v_116ff373_916f_4199_9e1f_c892ce1ab17e',
            function(s) 
                --Eat one pasty
                nlbwalk(v_89); 
            end
        ),

    },
};

-- Woodcutters to the rescue
v_83 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Woodcutters really worked not far from there. When they heard child screaming they rushed towards the trail. As they found a dishevelled girl on the road, they come up to her and asked her what happened.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e5375bf7_81b2_4d0e_851c_40f5acde54bc|Mother taught Red Hood not to talk to strangers}^";
        p "{v_680e22ac_66fd_4f89_8d9b_1a0141f37159|Tell woodcutters everything}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_e5375bf7_81b2_4d0e_851c_40f5acde54bc',
            function(s) 
                --Mother taught Red Hood not to talk to strangers
                nlbwalk(v_133); 
            end
        ),
        xact(
            'v_680e22ac_66fd_4f89_8d9b_1a0141f37159',
            function(s) 
                --Tell woodcutters everything
                nlbwalk(v_88); 
            end
        ),

    },
};

-- Mother and granny vied with each other in expressing their thanks to the man
v_84 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("When power of speech returned back to Mother and granny, they vied with each other in expressing their thanks to the man. Red Hood\'s Mother gladly agreed for a date, being admired by the woodcutter\'s bravery.^"..
"They met in the evening and went back looking at the sunset. The woman offered the woodcutter to stay for supper, what made him glad.^"..
"He also made acquaintance with the woman\'s daughter. Since then they often had dinner together. Soon they got married and lived happily ever after.^"..
"^"..
"Ending:^"..
"”Architect of own fortune”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e81035ba_4010_445a_9bd3_b40dfbb19746_0893e545_e122_46db_9b79_e253c763ca51_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/studies_on_chopins_etudes.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_e81035ba_4010_445a_9bd3_b40dfbb19746_0893e545_e122_46db_9b79_e253c763ca51_Return',
            function(s) 
                --Next
                nlbwalk(v_3); 
            end
        ),

    },
};

-- 
v_85 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Woman extracted one pasty from the basket, smelled it, but suppressed her temptation. She threw it back, but missed, and it plopped upon the ground. Mother swore and continued her journey.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_cd1bf510_7f73_44d0_a134_96ae2dae94b1|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_cd1bf510_7f73_44d0_a134_96ae2dae94b1',
            function(s) 
                --Next
                nlbwalk(v_17); 
            end
        ),

    },
};

-- 
v_86 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Soon afterwards Red Hood and woodcutters reached the hut.^"..
"Rat-tat - she hammered with a fist on the door.^"..
"\"Who is it?\"^"..
"\"It\'s me, Red Hood, your granddaughter!\"^"..
"\"Oh, pull the string my dear and the door will open!\"");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin22)) and "{v_9506b3ee_9c9b_42a9_b22b_afd7dc42c684|Next}^" or "");
        p ((( not _fin22)) and "{v_f683863e_2548_4395_ad5d_34571ee8def5|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_9506b3ee_9c9b_42a9_b22b_afd7dc42c684',
            function(s) 
                --Next
                nlbwalk(v_111); 
            end
        ),
        xact(
            'v_f683863e_2548_4395_ad5d_34571ee8def5',
            function(s) 
                --Next
_fin22 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_6361abe3_714b_4ec7_b866_9fca662e32dc);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_6361abe3_714b_4ec7_b866_9fca662e32dc);
                nlbwalk(v_111); 
            end
        ),

    },
};

-- Red Hood and granny obtained a long, wide board
v_87 = room {
    nam = "...",
    pic = 'images/wolf_running.png',
    bgimg = function() end,
    dsc = function(s)
p("One day Red Hood and granny obtained a long, wide board and carefully lifted it down the cellar. At first the beast shrank into a corner, but then understood what was going on. And the girl with granny easily slapped on the board to encourage him.^"..
"\"Don\'t be afraid, get out of there!\"^"..
"The predator carefully got out on all fours. He saw opened door right in front of him. Caution prevailed and Wolf set off the house at a trot. Red Hood and granny sadly followed him with their eyes. Before disappearing in the forest, Wolf turned around and vanished in the thicket. Later he often dropped by to get his belly scratched.^"..
"^"..
"Ending:^"..
"\"Prisoner”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_72d9f91e_2027_454f_b524_88f2f4fb35d7_0402f0cb_db2e_4a41_9d64_0ba827478cc4_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/flohwalzer_dog1.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_72d9f91e_2027_454f_b524_88f2f4fb35d7_0402f0cb_db2e_4a41_9d64_0ba827478cc4_Return',
            function(s) 
                --Next
                nlbwalk(v_14); 
            end
        ),

    },
};

-- Red Hood cried and told woodcutters about Wolf
v_88 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood cried and complained  about Wolf. Woodcutters decided to escort her to the house of granny, and she treated them with pasties as a token of her gratitude.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_4671c6d4_97d4_4397_b9de_6ccf313b0d19|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_4671c6d4_97d4_4397_b9de_6ccf313b0d19',
            function(s) 
                --Next
                nlbwalk(v_158); 
            end
        ),

    },
};

-- RH eats one pasty
v_89 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("\"I\'ve got plenty of it, if I take one, no one will know\".^"..
"Red Hood ate one pasty, it was delicious.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1bcb5676_1aeb_4134_b640_d8d65bd57ca4|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_1bcb5676_1aeb_4134_b640_d8d65bd57ca4',
            function(s) 
                --Next
                nlbwalk(v_54); 
            end
        ),

    },
};

-- Red hood opened her eyes panting
v_90 = room {
    nam = "...",
    pic = 'images/night.png',
    bgimg = function() end,
    dsc = function(s)
p("Red hood opened her eyes panting. And for a long time looked around, trying to figure out what happened and where she was. Full Moon was shining in the sky, pines and spruces rose around, and close to the stump she sat on, was lying empty basket.^"..
"^"..
"Ending:^"..
"”Awful dream”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1d6a9e8d_04cb_41bf_a0c2_c0b89dcd7591_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/mix2.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_1d6a9e8d_04cb_41bf_a0c2_c0b89dcd7591_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return',
            function(s) 
                --Next
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Wolf had stomach spasms
v_91 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf was heading towards the hut on the forest edge, but eaten pasty exerted aggressive effect upon Wolf\'s organism, wherewith changed his plans. Granny was left hungry, but everyone stayed alive and almost healthy.^"..
"^"..
"Ending:^"..
"”Good deed”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6a154df5_e281_4267_a061_65ca6af53ffe_7e35525f_46ee_4774_a39a_5b794054b395_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony_fast.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_6a154df5_e281_4267_a061_65ca6af53ffe_7e35525f_46ee_4774_a39a_5b794054b395_Return',
            function(s) 
                --Next
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Wolf ran in and ate hag. Got poisoned by mushrooms
v_92 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Old lady kept in mind, that ate milk mushroom from the bowl yesterday...Or the day before yesterday. She didn\'t want to take risk, because mushrooms could get spoiled, but she had absolutely no desire to get into the cellar. Meanwhile, sounded loud rumbling in her stomach, and old lady began to eat remains from the bowl.^"..
"Wolf in his turn came up to the house on the forest edge and knocked on the door.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It is me, Red Hood, your granddaughter!\" whispered Wolf, making his voice as tender as he could.^"..
"\"Ah, pull the string my dear and the door will open!\"^"..
"Once predator got inside, he promptly swallowed granny, dressed up in her night gown, glasses, cap and lied to bed.^"..
"After a long or short while, Red Hood got to the forest edge. When she stepped on the porch she was about to knock, but to her astonishment found, that the door wasn\'t locked. Inside the house Red Hood found dressed as a woman dead Wolf in bed, and a bowl with awful smell of rotten mushrooms on the table.^"..
"^"..
"Ending:^"..
"”Lack of fastidiousness”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c08d573e_83de_4256_a947_fe559701ffad_62442425_2015_4757_88c4_0ec58edf555e_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/granny.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_c08d573e_83de_4256_a947_fe559701ffad_62442425_2015_4757_88c4_0ec58edf555e_Return',
            function(s) 
                --Next
                nlbwalk(v_5); 
            end
        ),

    },
};

-- Give as it is
v_93 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother, Red Hood and Grandmother kept living in the forest. Wolf, after he drank the potion, turned into a badger. It was clearly written to follow the dosage strictly! We have to admit it served him right, because meeting such a nice animal, girls didn\'t ran away in horror as it used to be, but gladly spoke to him. Soon former wolf recommenced attempts with an antidote, and asked one pretty traveler for help. This time he personally watched the process of mixing, and when he made sure there was no mistake, drank the potion.^"..
"Now, instead of fluffy animal, there was a young handsome man in front of the girl, he was a prince by the way. Without thinking twice, youngsters got married and lived happily ever after.^"..
"^"..
"Ending:^"..
"”Attentiveness in detail”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_452ff4c2_a203_43ff_a069_5c0cfb4e63f5_7daf90de_cc43_429a_88ed_21011df2f00e_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/studies_on_chopins_etudes.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_452ff4c2_a203_43ff_a069_5c0cfb4e63f5_7daf90de_cc43_429a_88ed_21011df2f00e_Return',
            function(s) 
                --Next
                nlbwalk(v_11); 
            end
        ),

    },
};

-- Red Hood was ashamed of eating pasties and moved along
v_94 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood was ashamed of eating Grandmother\'s pasties and moved along");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e5d82ee5_0682_4a0f_b535_d1bdd08f2682|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_e5d82ee5_0682_4a0f_b535_d1bdd08f2682',
            function(s) 
                --Next
                nlbwalk(v_31); 
            end
        ),

    },
};

-- Wolf successfully reached the house 
v_95 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Hungry Wolf decided not to change trajectory, but to take risk to be spotted, and rushed past in dangerous closeness to working men. For the predator everything was successful, and soon he reached granny\'s house. Red Hood, of course, still wasn\'t here.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_58daf7a9_95dd_4209_9195_6fe54dd12b76|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_58daf7a9_95dd_4209_9195_6fe54dd12b76',
            function(s) 
                --Next
                nlbwalk(v_74); 
            end
        ),

    },
};

-- Mother reached Grandmother, they have tea with pasties
v_96 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("By that time woman reached Grandmother. They sat down to have tea with pasties, making a chit-chat.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _chaperon_dead)) and "{v_7229405d_0925_4a31_b6f2_559d52e59891|Next}^" or "");
        p (((_chaperon_dead and _fin23)) and "{v_625dd67f_30d4_4f9d_8c1a_d7040c963ca0|Next}^" or "");
        p (((_chaperon_dead and not _fin23)) and "{v_cb32fa96_d92a_4a7c_bf75_3737877b24e1|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/flight_of_the_bumblebee_a.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_7229405d_0925_4a31_b6f2_559d52e59891',
            function(s) 
                --Next
                nlbwalk(v_76); 
            end
        ),
        xact(
            'v_625dd67f_30d4_4f9d_8c1a_d7040c963ca0',
            function(s) 
                --Next
                nlbwalk(v_112); 
            end
        ),
        xact(
            'v_cb32fa96_d92a_4a7c_bf75_3737877b24e1',
            function(s) 
                --Next
_fin23 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3c69590d_317c_40d9_b284_298e6fa49a35);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3c69590d_317c_40d9_b284_298e6fa49a35);
                nlbwalk(v_112); 
            end
        ),

    },
};

-- Slumbering granny wakes up from strange noise
v_97 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Meanwhile, an old lady woke up in her house by the forest edge, trying to collect her thought, lying in bed. Suddenly, strange noise reached her ears. It was frightening for her to find, that it was gritting of claws on the door.^"..
"\"Who is it?\" she asked in a trembling voice.^"..
"\"U-u-u-u-u-u-u-u-u-u-u!!!\" she heard in response.^"..
"For a moment everything was silent, and then creature pulled the string. When old woman saw opening door, she dug in deep under the blanket, being half-conscious.^"..
"Doorway revealed Mother.^"..
"\"R-r-r-r-r-r-r-r-r-r-h-h-h!!!\" she pronounced, left pasties and butter, giggled a bit, went down on all fours and went away.^"..
"It\'s unknown how much time did granny hide under the blanket, but when she screwed up her courage to look out, there was nobody in the room. Only the basket with pasties and a pot of butter were standing on the floor. It was exactly what she needed, because after disturbing experience she was very hungry.^"..
"^"..
"Ending:^"..
"”Fear has big eyes”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_b97578b6_9f3a_4ea0_906c_b2eee1824506_7daf90de_cc43_429a_88ed_21011df2f00e_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_b97578b6_9f3a_4ea0_906c_b2eee1824506_7daf90de_cc43_429a_88ed_21011df2f00e_Return',
            function(s) 
                --Next
                nlbwalk(v_11); 
            end
        ),

    },
};

-- Wait
v_98 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood pondered correctly, if she moved not far off the path, it\'ll be easy to find when the Sun rise. The girl clambered the spruce and felt herself in safety. She waited for morning eating pasties.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_386420ac_74ec_40f0_b169_d8f14a50cbd6|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_386420ac_74ec_40f0_b169_d8f14a50cbd6',
            function(s) 
                --Next
                nlbwalk(v_52); 
            end
        ),

    },
};

-- Eats a few pasties
v_99 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother ate one pasty but she got so chilled and tired, so she ate more. The basket became three or four pasties lighter.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ed033bdf_7aaa_4adb_b5f4_498914c2ccef|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_ed033bdf_7aaa_4adb_b5f4_498914c2ccef',
            function(s) 
                --Next
                nlbwalk(v_46); 
            end
        ),

    },
};

-- Granny and Red Hood couldn\'t protect themselves and Wolf ate them
v_100 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Predator acted fast and confidently. Old lady could only struggle for breath, and the girl screwed up her eyes with fear. They couldn\'t protect themselves, and soon it was over. Wolf ate them.^"..
"^"..
"Ending:^"..
"”Ingratitude”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_02032f25_ad5b_4a12_b60a_6d337b54ef80_8f127e94_d289_456e_896a_dd397aa32341_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_02032f25_ad5b_4a12_b60a_6d337b54ef80_8f127e94_d289_456e_896a_dd397aa32341_Return',
            function(s) 
                --Next
                nlbwalk(v_13); 
            end
        ),

    },
};

-- Wolf secretly tracked Mother down and ate everyone
v_101 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Being astonished and upset, woodcutter seized the axe and continued to chop trees with double-strength, paying no attention to laughs of his colleagues.^"..
"Mother swiftly walked down the road, and soon reached granny\'s house. Undetected Wolf followed the woman that whole time. Now he hid behind bushes like a pressed spring, ready to attack at any second. When Mother opened the door and stepped across the threshold, the predator covered the distance between him and his prey in two jumps, and almost flied through the closing door. The woman fate was determined.^"..
"^"..
"Ending:^"..
"”If only...”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_093897a8_7e82_481b_9a72_4a555d8eeead_8f127e94_d289_456e_896a_dd397aa32341_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/taf.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_093897a8_7e82_481b_9a72_4a555d8eeead_8f127e94_d289_456e_896a_dd397aa32341_Return',
            function(s) 
                --Next
                nlbwalk(v_13); 
            end
        ),

    },
};

-- Red Hood do not eat a pasty
v_102 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Responsibilities and honesty protected little girl from making even a single bite. She had to deliver all pasties intact. But she could afford herself to have a little rest. Red Hood sat on a stump, that was in the shade of a branchy tree. It was much cooler there, than on the Sun burning path. It was caressing warmth and a slight wind blowing that made Red Hood grow languid,  and filled her body with pleasant languor. The girl even closed her eyes.^"..
"Suddenly, Wolf came out of nowhere. When Red Hood heard the noise, she flash-like jumped up.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_19a74b6f_409d_4704_9e2d_8cca4723212c|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/a_la_mozart.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_19a74b6f_409d_4704_9e2d_8cca4723212c',
            function(s) 
                --Next
                nlbwalk(v_143); 
            end
        ),

    },
};

-- Standard ending
v_103 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf rapidly reached granny\'s house and knocked on the door.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It is me, Red Hood, your granddaughter!\" whispered Wolf, making his voice as tender as he could.^"..
"\"Oh, pull the string my dear and the door will open!\"^"..
"Once predator found himself inside the house, he promptly swallowed Grandmother, dressed up in her night gown, cap, put on glasses and tumbled into bed.^"..
"Lying in warm bed, Wolf fell into a doze, when suddenly someone knocked on the door.^"..
"\"Who is it?\" asked predator trying to imitate voice of an old, sick woman.^"..
"\"It\'s me your granddaughter, Red Hood!\"^"..
"\"Pull the string my dear and the door will open!^"..
"^"..
"So the little girl did. Wolf pulled the blanket right up his eyes, only his ears protruded from under the cap. This is what burst upon the eye in the first place.^"..
"\"Oh, Grandmother, you\'ve got so big ears!\" Red Hood exclaimed.^"..
"\"It is so I could hear you better, my child.\"^"..
"\"And you\'ve got so big eyes too!\"^"..
"\"It is so I could see you better, my child.\"^"..
"^"..
"Wolf got carried away by conversation, without noticing that the blanket slipped down.^"..
"\"Oh, granny, why you\'ve got so big teeth?\" Red Hood exclaimed.^"..
"It\'s for eating you!^"..
"After these words Wolf attacked Red Hood and swallowed her.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin30)) and "{v_b42ee627_238a_46cb_b765_154e0ac6f55b|Next}^" or "");
        p ((( not _fin30)) and "{v_9c6650dd_7aa2_4d36_86d5_d56e4a854596|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_b42ee627_238a_46cb_b765_154e0ac6f55b',
            function(s) 
                --Next
                nlbwalk(v_156); 
            end
        ),
        xact(
            'v_9c6650dd_7aa2_4d36_86d5_d56e4a854596',
            function(s) 
                --Next
_fin30 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_48c1030c_4782_4668_a8f3_726b85e25c0d);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_48c1030c_4782_4668_a8f3_726b85e25c0d);
                nlbwalk(v_156); 
            end
        ),

    },
};

-- Laziness prevailed
v_104 = room {
    nam = "...",
    pic = 'images/granny_home.png',
    bgimg = function() end,
    dsc = function(s)
p("Old Lady thought, that it would be much safer to fetch new can of mushrooms from the cellar. But after a few seconds, changed her mind, because laziness prevailed, and she was about to eat remaining milk mushrooms from the bowl. Old lady headed to the table but her old brain glitched, because of such intensive mind work. She stopped halfway with her stretched out arms, that were going to take the bowl. Sclerosis made fruitless all attempts to recollect where she was going, and after a few curses, old lady returned to bed.^"..
"Meanwhile, Wolf came up to the house on the forest edge and knocked.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It is me, Red Hood, your granddaughter!\" whispered Wolf, making his voice as tender as he could.^"..
"\"Ah, pull the string my dear and the door will open!\"^"..
"Once predator got inside, he promptly swallowed granny, dressed up in her night gown, glasses, cap and lied to bed.");
    end,
    xdsc = function(s)
        p "^";
        p (((_heavy)) and "{v_7869db0b_18f9_4c35_a84e_bc39ed09417e|Next}^" or "");
        p ((( not _heavy and _fin9)) and "{v_c86c2e29_48a2_476f_8b97_aa2d1a6fa7d6|Next}^" or "");
        p ((( not _heavy and not _fin9)) and "{v_65f95566_d4dc_44bb_bc20_32d848f49221|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/granny.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_7869db0b_18f9_4c35_a84e_bc39ed09417e',
            function(s) 
                --Next
                nlbwalk(v_73); 
            end
        ),
        xact(
            'v_c86c2e29_48a2_476f_8b97_aa2d1a6fa7d6',
            function(s) 
                --Next
                nlbwalk(v_50); 
            end
        ),
        xact(
            'v_65f95566_d4dc_44bb_bc20_32d848f49221',
            function(s) 
                --Next
_fin9 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_a7514b63_788d_4041_8883_b26456439ab2);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_a7514b63_788d_4041_8883_b26456439ab2);
                nlbwalk(v_50); 
            end
        ),

    },
};

-- Tell about Wolf on the road
v_105 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood told about meeting Wolf. Then Grandmother said, \"You are still young, but appears that it\'s time to grow up. There are too many threats around you!\"^"..
"After granny said that, she took shotgun out of the closet.^"..
"\"It belonged to your Grandfather. Take it!\"^"..
"Then granny explained how to load and fire. Fortunately, this information was still intact in her senescent brain.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0a4cc38f_7e0e_44d7_b6a9_e7ed8657df2c|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
_tell_about_wolf = true;
            addf(nil, v_1bda9991_9d17_4ca8_ba52_d3f509ef6ecf);
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_0a4cc38f_7e0e_44d7_b6a9_e7ed8657df2c',
            function(s) 
                --Next
                nlbwalk(v_27); 
            end
        ),

    },
};

-- Don\'t go
v_106 = room {
    nam = "...",
    pic = 'images/night.png',
    bgimg = function() end,
    dsc = function(s)
p("Caution prevailed, and Red Hood refused to follow Wolf. Beast gave a deep sigh, \"Like a human being\" thought the girl with shudder,  there was something creepy about this. Wolf said with sadness, \"Well, let\'s go, I\'ll lead you to the trail and escort to the house.\"^"..
"If she knew the way, she\'d prefer to refuse. In given circumstances she had to accept Wolf\'s proposal.^"..
"They were silent the whole route. When Red Hood\'s house appeared, Wolf thanked her for food once again and ran back to forest.^"..
"As the girl approached the porch, she stopped for a moment and turned around, looking for long at the motionless wall of trees and mysterious night sky. She had a strange dual sense of relief and regret at the same time.^"..
"^"..
"Ending:^"..
"”Colourless existence”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_9a272b2e_57c3_49f1_832e_fd41e4d02822_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/sonata_no14_3fantasia.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_9a272b2e_57c3_49f1_832e_fd41e4d02822_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return',
            function(s) 
                --Next
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Hungry Wolf smelled fish
v_107 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("As always, hungry Wolf was roaming around. For the whole week he had nothing for dinner. Suddenly, wind brought him smell of fish from the trail. Wolf liked meat much more, but now he was even ready to graze, if grass would grow already. Taking in the air, Wolf cautiously prowled to the trail and his heart joyfully began to beat, expecting double prey. His first intention was to attack poor woman  immediately but life in the forest made him cautious, so the beast didn\'t hurry, sliding slowly after his victim. Moreover, she could lead him to even larger prey. Saliva was dripping off his fangs and stomach was monotonously whining.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin27)) and "{v_4b307aa2_10e6_42bf_a6a4_aa69bc4f657b|Snatch out pasties immediately!}^" or "");
        p "{v_bb5bf295_d2bb_4a8b_b27e_4e84e7f5c624|Ask for pasties}^";
        p "{v_14d05255_eb11_4e22_91c1_95d62da166f3|Keep waiting to eat everything and everyone}^";
        p ((( not _fin27)) and "{v_a3522262_f767_4821_a2c2_b5fcb89a3b9b|Snatch out pasties immediately!}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_4b307aa2_10e6_42bf_a6a4_aa69bc4f657b',
            function(s) 
                --Snatch out pasties immediately!
                nlbwalk(v_28); 
            end
        ),
        xact(
            'v_bb5bf295_d2bb_4a8b_b27e_4e84e7f5c624',
            function(s) 
                --Ask for pasties
                nlbwalk(v_78); 
            end
        ),
        xact(
            'v_14d05255_eb11_4e22_91c1_95d62da166f3',
            function(s) 
                --Keep waiting to eat everything and everyone
                nlbwalk(v_30); 
            end
        ),
        xact(
            'v_a3522262_f767_4821_a2c2_b5fcb89a3b9b',
            function(s) 
                --Snatch out pasties immediately!
_fin27 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1);
                nlbwalk(v_28); 
            end
        ),

    },
};

-- Hood asked woodcutters for help
v_108 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("The basket was very heavy and Red Hood was walking slowly. Wolf fell asleep in bed. When the girl came inside the house, she saw sleeping Wolf. She left the basket and ran to the woodcutters for help. They came and drove Wolf away, and took out the old lady from the cellar. Then everybody sat down to have feast with pasties, except for Wolf.^"..
"^"..
"Ending:^"..
"”Reward for the efforts”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0380f78b_8bf6_4024_85e5_551d19cce6b9_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_0380f78b_8bf6_4024_85e5_551d19cce6b9_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return',
            function(s) 
                --Next
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Red Hood takes fish
v_109 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("\"I shall take one pasty\" decided Red Hood, \"no one will notice.\"^"..
"After this thought she rushed up to table, like black kite attacking his prey, grabbed a pasty and returned to the stove.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_2b59668a_42bf_4662_9bb4_816428b13344|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_2b59668a_42bf_4662_9bb4_816428b13344',
            function(s) 
                --Next
                nlbwalk(v_22); 
            end
        ),

    },
};

-- Toilets 2
v_110 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Meanwhile, Wolf as always, was prowling in the forest for something to eat, found pasties and ate everything without second thoughts. He also sniffed a bigger prey, and had intentions to go after it, because pasties only let him refresh his inner man. But, insidious home-made stuff took its effect and frustrated all Wolf\'s plans.^"..
"To cut the story short, everybody occupied toilets. Only granny and Red Hood were lucky not to taste \"magic\" cuisine.^"..
"^"..
"Ending:^"..
"”Nasty lunch\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0e9196e9_fddb_4922_bed6_63635b4e228f_9c9415fd_615e_463f_aafb_d84df08388a0_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony_fast.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_0e9196e9_fddb_4922_bed6_63635b4e228f_9c9415fd_615e_463f_aafb_d84df08388a0_Return',
            function(s) 
                --Next
                nlbwalk(v_10); 
            end
        ),

    },
};

-- Woodcutters killed wolf and retrieved the old lady
v_111 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("When Wolf saw Red Hood, he grinned, but enormous men with axes followed her. Wolf broke into a sweat, he could not move, there was nowhere to run. Woodcutters killed Wolf, retrieved grandmother, but she had deceased from heart attack - it is not a trick to get into Wolf\'s belly.^"..
"^"..
"Ending:^"..
"”Woodcutters rescuers”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_46358225_d765_41e3_aef8_7cc3a16bfc1c_8f127e94_d289_456e_896a_dd397aa32341_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/symphony5.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_46358225_d765_41e3_aef8_7cc3a16bfc1c_8f127e94_d289_456e_896a_dd397aa32341_Return',
            function(s) 
                --Next
                nlbwalk(v_13); 
            end
        ),

    },
};

-- They finished tea
v_112 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("After they finished with tea, Mother replaced remaining pasties from the basket into a bowl. Butter pot was lifted down the cellar. Then she went home to be ahead of the dark.^"..
"^"..
"Ending:^"..
"”Don\'t open to strangers”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f3bb8831_9d3d_4ba7_91b7_4ce0e5b4f2b6_69cd655a_1111_42b7_9bbe_057df356d037_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_f3bb8831_9d3d_4ba7_91b7_4ce0e5b4f2b6_69cd655a_1111_42b7_9bbe_057df356d037_Return',
            function(s) 
                --Next
                nlbwalk(v_12); 
            end
        ),

    },
};

-- Eat everyone
v_113 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("Predator knocked on the door.^"..
"\"Who is it?\"^"..
"\"It\'s your granddaughter, Red Hood.\"^"..
"\"But Red Hood is already here!\" says the old lady.^"..
"\"Then I\'m Red Hood\'s mother!\"^"..
"\"Ah, you should have said so! Pull the string and the door will open!\"^"..
"Red Hood just opened her mouth with astonishment, as Wolf broke into the house.");
    end,
    xdsc = function(s)
        p "^";
        p (((_tell_about_wolf and not _fin3)) and "{v_fc6daecb_1e6d_4805_8d07_4d79adddae40|Next}^" or "");
        p ((( not _tell_about_wolf and _fin14)) and "{v_87112e63_dd2f_4997_a291_64176b29fc1b|Next}^" or "");
        p (((_tell_about_wolf and _fin3)) and "{v_f25809b3_2163_4956_b39b_c3b9f9003989|Next}^" or "");
        p ((( not _tell_about_wolf and not _fin14)) and "{v_219a06d5_9124_42a3_acda_78549fe345ed|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/la_marmotte_overdrive.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_fc6daecb_1e6d_4805_8d07_4d79adddae40',
            function(s) 
                --Next
_fin3 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_07ef90a9_298a_4fe4_971b_e791e38952f8);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_07ef90a9_298a_4fe4_971b_e791e38952f8);
                nlbwalk(v_45); 
            end
        ),
        xact(
            'v_87112e63_dd2f_4997_a291_64176b29fc1b',
            function(s) 
                --Next
                nlbwalk(v_100); 
            end
        ),
        xact(
            'v_f25809b3_2163_4956_b39b_c3b9f9003989',
            function(s) 
                --Next
                nlbwalk(v_45); 
            end
        ),
        xact(
            'v_219a06d5_9124_42a3_acda_78549fe345ed',
            function(s) 
                --Next
_fin14 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_24c04782_6e96_4f13_a00e_9487be05bdcf);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_24c04782_6e96_4f13_a00e_9487be05bdcf);
                nlbwalk(v_100); 
            end
        ),

    },
};

-- Granny got hungry and decided to eat  some pickled mushrooms
v_114 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf made up his mind not to push his luck and go around.^"..
"At the same time old lady was ravenous in her home on the forest edge. She was eager to eat pickled mushrooms. Actually, cans with milk mushroom were stored in the cellar, but on the table was a bowl with a few pieces in it.");
    end,
    xdsc = function(s)
        p "^";
        p (((_butterfly)) and "{v_62b21db6_af68_4bb0_86d5_b07d1b6f4895|Take fresh mushrooms}^" or "");
        p ((( not _butterfly)) and "{v_9d3cb3f3_02da_4a9c_b600_c1802e8989ca|Go down the cellar for mushrooms}^" or "");
        p (((_fin7)) and "{v_773e0cc4_24ea_4338_a9eb_f4d2736846ce|Hag was lazy to lift fresh mushrooms from the cellar, and ate the ones from the table lifted the day before yesterday. }^" or "");
        p "{v_acfad543_4433_4f50_92dd_161656dc1048|Eat nothing for now}^";
        p ((( not _fin7)) and "{v_ec14bc96_e51a_4239_897e_cd1ada5a5eaf|Hag was lazy to lift fresh mushrooms from the cellar, and ate the ones from the table lifted the day before yesterday. }^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_62b21db6_af68_4bb0_86d5_b07d1b6f4895',
            function(s) 
                --Take fresh mushrooms
                nlbwalk(v_164); 
            end
        ),
        xact(
            'v_9d3cb3f3_02da_4a9c_b600_c1802e8989ca',
            function(s) 
                --Go down the cellar for mushrooms
                nlbwalk(v_39); 
            end
        ),
        xact(
            'v_773e0cc4_24ea_4338_a9eb_f4d2736846ce',
            function(s) 
                --Hag was lazy to lift fresh mushrooms from the cellar, and ate the ones from the table lifted the day before yesterday. 
                nlbwalk(v_92); 
            end
        ),
        xact(
            'v_acfad543_4433_4f50_92dd_161656dc1048',
            function(s) 
                --Eat nothing for now
                nlbwalk(v_104); 
            end
        ),
        xact(
            'v_ec14bc96_e51a_4239_897e_cd1ada5a5eaf',
            function(s) 
                --Hag was lazy to lift fresh mushrooms from the cellar, and ate the ones from the table lifted the day before yesterday. 
_fin7 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_656e179e_fb53_487c_8d4a_114206c96516);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_656e179e_fb53_487c_8d4a_114206c96516);
                nlbwalk(v_92); 
            end
        ),

    },
};

-- Red Hood rushes back home
v_115 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood continued her journey, but soon felt sick, and a few minutes later there was rumbling in her stomach. Dropping her presents the girl rushed back home.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_977bf0c0_66f2_48ef_9d9c_bf2c8fcacb50|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/a_la_mozartfast.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_977bf0c0_66f2_48ef_9d9c_bf2c8fcacb50',
            function(s) 
                --Next
                nlbwalk(v_125); 
            end
        ),

    },
};

-- Butterfly
v_116 = room {
    nam = "...",
    pic = 'images/butterfly.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood admired the butterfly and kept going.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1eadbf7b_9934_4f6b_b8a9_f14f2f3428b4|Keep going}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
_butterfly = true;
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_1eadbf7b_9934_4f6b_b8a9_f14f2f3428b4',
            function(s) 
                --Keep going
                nlbwalk(v_53); 
            end
        ),

    },
};

-- Meanwhile Red Hood who was hardly dragging her feet approached granny\'s house
v_117 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Meanwhile, Red Hood who was hardly dragging her feet, approached granny\'s house. She pulled remaining strength together, climbed the porch, and almost fell by the door.^"..
"\"Who is it?\" shouted old lady in a frightened voice.^"..
"\"It\'s me, your grandd...\"^"..
"\"Pull the string and get in!\"^"..
"Being intrigued by granny\'s unusual voice tone, Red Hood almost ran into the house, and nearly fell down the opened hatch.^"..
"\"Granny, why do you keep cellar open?!\"^"..
"\"Look what is down there\" said old lady half-whisperingly.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f461785b_6bd7_4a3b_99c2_9fdc8586aab0|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_f461785b_6bd7_4a3b_99c2_9fdc8586aab0',
            function(s) 
                --Next
                nlbwalk(v_163); 
            end
        ),

    },
};

-- Red Hood in horror released the basket
v_118 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood grew cold with terror and released her burden. Wolf disappears in the forest with his loot. After he made himself comfortable by the nearest bush, he ate everything. Pasties were nutritious and delicious. Satisfied beast settled in for rest, right on the spot.^"..
"The old lady, of course, got nothing but the pot of butter, that granddaughter still managed to save. But for all that everyone was safe and sound.^"..
"^"..
"Ending:^"..
"”Everybody is alive and kicking”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1d1a797c_5d57_4db3_ba64_be2ab06080c8_95861bf1_f46d_4b05_9673_01e48857a8e9_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_1d1a797c_5d57_4db3_ba64_be2ab06080c8_95861bf1_f46d_4b05_9673_01e48857a8e9_Return',
            function(s) 
                --Next
                nlbwalk(v_4); 
            end
        ),

    },
};

-- They both occupied toilet
v_119 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Meanwhile, Mother reached granny, who offered her to share a meal. Being powerless to refuse to an old woman, she stayed, and they both ate pasties. Hag felt a strange smack, but was shy to ask, not to offend daughter who was trying especially for her.^"..
"Mother, in her turn, also felt strange taste and smell, but didn\'t show it, being ashamed to admit that fish for stuffing was tainted.^"..
"The result was predictable - they both occupied toilet.^"..
"^"..
"Ending:^"..
"”Retribution for politeness”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0e51bd75_4b34_4753_99f5_86b9d3ef1598_62442425_2015_4757_88c4_0ec58edf555e_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/bumblebee.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_0e51bd75_4b34_4753_99f5_86b9d3ef1598_62442425_2015_4757_88c4_0ec58edf555e_Return',
            function(s) 
                --Next
                nlbwalk(v_5); 
            end
        ),

    },
};

-- Hard not to take turn
v_120 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Wishing not to waste time, Red Hood forced herself to keep walking. The Sun seemed to scorch stronger with every minute. Girl\'s face turned red, mouth turned dry, her hair adhered to sweaty forehead. Pasties at such heat weren\'t safe too. As a result, rest in the shade was of vital necessity.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e99526ac_9b42_48f3_956d_5667c7db0f2d|Turn off the trail}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_e99526ac_9b42_48f3_956d_5667c7db0f2d',
            function(s) 
                --Turn off the trail
                nlbwalk(v_167); 
            end
        ),

    },
};

-- Woodcutters ate a pasty
v_121 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf sniffed a pasty. Fie, mushrooms. He kept on trotting and vanished after the turn. And later two woodcutters appeared on the path, walking out of the bushes. They see a nice good smelling pasty on the grass. They split it in two parts and ate.^"..
"\"Look, it seems, Wolf tracks!\" exclaimed the first one.^"..
"\"Yeah, right! Let\'s catch him\" offered the other one.^"..
"So it was decided.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin40)) and "{v_f1d83fe8_c5f4_46a5_8806_9ac73deeb08c|Next}^" or "");
        p ((( not _fin40)) and "{v_b20e2c35_4210_4420_983d_a03b4ef137c4|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_f1d83fe8_c5f4_46a5_8806_9ac73deeb08c',
            function(s) 
                --Next
                nlbwalk(v_35); 
            end
        ),
        xact(
            'v_b20e2c35_4210_4420_983d_a03b4ef137c4',
            function(s) 
                --Next
_fin40 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_ea12df2a_7448_4006_86c3_0544739b6e72);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_ea12df2a_7448_4006_86c3_0544739b6e72);
                nlbwalk(v_35); 
            end
        ),

    },
};

-- Mother baked some pasties 
v_122 = room {
    nam = "...",
    pic = 'images/mother_home.png',
    bgimg = function() end,
    dsc = function(s)
p("Why don’t you my little Red Hood go visit your granny. Bring her a pot of butter, and find out if she is fine?^"..
"And Red Hood replies");
    end,
    xdsc = function(s)
        p "^";
        p (((_cabbage)) and "{v_0188e0c3_f698_4081_bbbe_3034f3c1a405|-You better bring it yourself!}^" or "");
        p (((_mushroom)) and "{v_29cca1c5_a802_4516_9bde_ab39454380f5|-You better bring it yourself!}^" or "");
        p (((_meat)) and "{v_e804aa3c_c788_4c66_bcfe_7dc07a04c0e2|You better bring it yourself because I don\'t feel myself well.}^" or "");
        p (((_fish)) and "{v_252dba7e_2524_4e95_9d6c_f1b51f75bfee|-Ok, Mom!}^" or "");
        p (((_meat)) and "{v_1854cda3_38b0_4494_b29d_17f496630f5c|Ok, mom!}^" or "");
        p (((_cabbage)) and "{v_fbdc3c8e_127c_491a_b373_cf0aee1a213e|-Ok, Mom!}^" or "");
        p (((_mushroom)) and "{v_18e80db4_ec49_4d23_a1c2_c1ab75e1fef5|-Ok, Mom!}^" or "");
        p (((_fish)) and "{v_78f3292c_a69b_4ed5_969f_0b9185191d4c|You better bring it yourself because I don\'t feel myself well.}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_0188e0c3_f698_4081_bbbe_3034f3c1a405',
            function(s) 
                ---You better bring it yourself!
_mother = true;
                nlbwalk(v_48); 
            end
        ),
        xact(
            'v_29cca1c5_a802_4516_9bde_ab39454380f5',
            function(s) 
                ---You better bring it yourself!
_mother = true;
                nlbwalk(v_132); 
            end
        ),
        xact(
            'v_e804aa3c_c788_4c66_bcfe_7dc07a04c0e2',
            function(s) 
                --You better bring it yourself because I don\'t feel myself well.
_mother = true;
                nlbwalk(v_129); 
            end
        ),
        xact(
            'v_252dba7e_2524_4e95_9d6c_f1b51f75bfee',
            function(s) 
                ---Ok, Mom!
_chaperon = true;
                nlbwalk(v_56); 
            end
        ),
        xact(
            'v_1854cda3_38b0_4494_b29d_17f496630f5c',
            function(s) 
                --Ok, mom!
_chaperon = true;
                nlbwalk(v_40); 
            end
        ),
        xact(
            'v_fbdc3c8e_127c_491a_b373_cf0aee1a213e',
            function(s) 
                ---Ok, Mom!
_chaperon = true;
                nlbwalk(v_149); 
            end
        ),
        xact(
            'v_18e80db4_ec49_4d23_a1c2_c1ab75e1fef5',
            function(s) 
                ---Ok, Mom!
_chaperon = true;
                nlbwalk(v_82); 
            end
        ),
        xact(
            'v_78f3292c_a69b_4ed5_969f_0b9185191d4c',
            function(s) 
                --You better bring it yourself because I don\'t feel myself well.
_mother = true;
                nlbwalk(v_165); 
            end
        ),

    },
};

-- Mother decided to visit Grandmother and bring her some butter
v_123 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother was standing on the road holding her pot of butter. She didn\'t try to pursue a grey brigand, but her tongue was giving birth to multiple obscene expressions.^"..
"There were no more pasties, but woman decided to continue her journey to visit Grandmother and bring her some butter.^"..
"^"..
"Ending:^"..
"”Busy wolf”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_edfa188e_abcb_4a3b_8185_da8ffd3807c4_95861bf1_f46d_4b05_9673_01e48857a8e9_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodrain.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_edfa188e_abcb_4a3b_8185_da8ffd3807c4_95861bf1_f46d_4b05_9673_01e48857a8e9_Return',
            function(s) 
                --Next
                nlbwalk(v_4); 
            end
        ),

    },
};

-- Eats. Wolf has hallucinations
v_124 = room {
    nam = "...",
    pic = 'images/wolf_face2.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf was so hungry, so he ate pasties in spite of lack of meat in it. After refreshing the inner man, the beast jog-trotted further. Of course he met Red Hood, who was going home!^"..
"She spotted Wolf and exclaimed, \"Hello, doggie! Please don\'t run away, give me a lift home!\"^"..
"\"Get on my back!\" gladly answered Wolf, \"Just hold tight!\"^"..
"Meanwhile, Mother went out on the porch to see if daughter was going home. At that moment Red Hood was approaching home riding Wolf. After the sight, Mother fainted. Wolf came up to the woman, sniffed her around and licked her nose. Mother opened her eyes, and piercing screamed, seeing bended Wolf\'s muzzle. Escaping from unpleasant sound, Wolf fled into the wood.^"..
"Red Hood was about to run after the doggie, but Mother timely grabbed her hand and dragged inside the house.^"..
"^"..
"Ending:^"..
"”Tame wolf”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c5038a84_3279_4538_b080_be304f25c51e_9c9415fd_615e_463f_aafb_d84df08388a0_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/flohwalzer_dog1.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_c5038a84_3279_4538_b080_be304f25c51e_9c9415fd_615e_463f_aafb_d84df08388a0_Return',
            function(s) 
                --Next
                nlbwalk(v_10); 
            end
        ),

    },
};

-- The abandoned basket was soon found by the woodcutters
v_125 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("The abandoned basket was soon found by the woodcutters. They were starving after a hard day\'s work, and ate everything and drank warm butter without care about origin or expiration date of the products. It was child\'s play for them. Try yourself to eat with dirty hands in the forest for so many years, without soap and wipes.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin4)) and "{v_15472ea2_d032_4f37_89c8_7a11a814229f|Next}^" or "");
        p ((( not _fin4)) and "{v_a544461b_20d3_4099_8eec_4f5eea615ad8|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_15472ea2_d032_4f37_89c8_7a11a814229f',
            function(s) 
                --Next
                nlbwalk(v_91); 
            end
        ),
        xact(
            'v_a544461b_20d3_4099_8eec_4f5eea615ad8',
            function(s) 
                --Next
_fin4 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_73988af5_ae18_4fdc_9a62_d2f3368dec05);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_73988af5_ae18_4fdc_9a62_d2f3368dec05);
                nlbwalk(v_91); 
            end
        ),

    },
};

-- Red Hood ate a few pasties
v_126 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood was walking along the path without noticing, that she ate a few pasties one by one. Soon she felt worse. She felt giddy and sick, spasms started in her stomach. Red Hood dumped her belongings and by pell-mell short rushes reached home.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin34)) and "{v_db7330df_36dc_462e_9bb2_701e82fd7d01|Next}^" or "");
        p ((( not _fin34)) and "{v_63962bd9_2f8e_488f_9c63_bdbc558ec065|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/a_la_mozartfast.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_db7330df_36dc_462e_9bb2_701e82fd7d01',
            function(s) 
                --Next
                nlbwalk(v_70); 
            end
        ),
        xact(
            'v_63962bd9_2f8e_488f_9c63_bdbc558ec065',
            function(s) 
                --Next
_fin34 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_92d89ed9_2e25_4bcc_89ee_2a98b2667f0d);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_92d89ed9_2e25_4bcc_89ee_2a98b2667f0d);
                nlbwalk(v_70); 
            end
        ),

    },
};

-- Wolf ate HOOD. Hag stayed in the cellar.
v_127 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Soon Red Hood reached the hut.^"..
"Knock-knock.^"..
"\"Who is it?\" asked Wolf imitating weakness in voice.^"..
"\"It\'s me, your granddaughter. I brought you some pasties and butter.\"^"..
"\"Wait, I\'ll open!\"^"..
"While Red Hood was entering, Wolf returned to bed and pulled the blanket up to his nose.^"..
"Red Hood came closer and asked, \"Grandmother, why your ears are so big?\"^"..
"\"It is so I could hear you better...\"^"..
"\"And why your eyes are so big?\"^"..
"\"It is so I could see you better...\"^"..
"\"And why your teeth are so big?\"^"..
"\"It\'s for eating you!\"^"..
"And he swallowed Red Hood, before she got the meaning of the last words.^"..
"This whole time old lady was sitting down the cellar, and didn\'t hear a thing. Wolf got away, and granny was eating supplies, until Mother came and rescued her.^"..
"^"..
"Ending:^"..
"”Lucky accident”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_fee25b7b_5014_48a2_8a0f_f0f0ad9e0244_01a4c786_f042_4fcd_8333_afac265f0328_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/symphony5.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_fee25b7b_5014_48a2_8a0f_f0f0ad9e0244_01a4c786_f042_4fcd_8333_afac265f0328_Return',
            function(s) 
                --Next
                nlbwalk(v_8); 
            end
        ),

    },
};

-- He gets the old lady
v_128 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Who is it?\" asked old lady.^"..
"\"It\'s Wolf!\" honestly answered Wolf.^"..
"\"Pull the string and come in!\" said old lady.^"..
"Wolf and granny sat down to table to have tea.^"..
"^"..
"Ending:^"..
"”Peacemaker pasties”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ae992734_24cc_41a4_b644_85ead3944e0c_9c9415fd_615e_463f_aafb_d84df08388a0_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_ae992734_24cc_41a4_b644_85ead3944e0c_9c9415fd_615e_463f_aafb_d84df08388a0_Return',
            function(s) 
                --Next
                nlbwalk(v_10); 
            end
        ),

    },
};

-- Mother carries with meat
v_129 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother took pasties and left. It was cool in the forest that day. It was drizzling, the trail had gotten muddy and hard to walk. Her feet were sliding apart on the slush. Soon she got chilled and tired, but weight of a basket reminded her of appetizing contents.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_93d87d80_c74e_4ed4_ab2c_48a7d9813471|Eat one pasty}^";
        p "{v_f9127a81_2322_403b_ae20_ba43f176550d|Eat a few pasties}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodrain.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_93d87d80_c74e_4ed4_ab2c_48a7d9813471',
            function(s) 
                --Eat one pasty
                nlbwalk(v_64); 
            end
        ),
        xact(
            'v_f9127a81_2322_403b_ae20_ba43f176550d',
            function(s) 
                --Eat a few pasties
                nlbwalk(v_99); 
            end
        ),

    },
};

-- Wolf ate Red Hood and went into the forest
v_130 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Come in!\" after these words Red Hood unbolted the door without even asking, neither the name of a visitor, nor his purpose. That was what Wolf wanted. He flash-like broke into the house frightening the daylight out of Red Hood.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_41da2467_9404_47ce_84e4_66a4b686336e|Kiss life goodby}^";
        p "{v_8957e2c4_1206_417b_873b_03d8b75fb113|Try to survive}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_41da2467_9404_47ce_84e4_66a4b686336e',
            function(s) 
                --Kiss life goodby
                nlbwalk(v_136); 
            end
        ),
        xact(
            'v_8957e2c4_1206_417b_873b_03d8b75fb113',
            function(s) 
                --Try to survive
                nlbwalk(v_61); 
            end
        ),

    },
};

-- Wolf was very hungry
v_131 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf was very hungry, but pasties were so few, so it just excited his appetite. It was decided to have rude wayfarer for lunch. Plus, it was easy to track her down.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin28)) and "{v_267d6c2a_df85_410f_a9d9_8901b1948b4e|Next}^" or "");
        p ((( not _fin28)) and "{v_b10cb8b8_d1ff_4347_b1d6_e30f952a36c6|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_267d6c2a_df85_410f_a9d9_8901b1948b4e',
            function(s) 
                --Next
                nlbwalk(v_67); 
            end
        ),
        xact(
            'v_b10cb8b8_d1ff_4347_b1d6_e30f952a36c6',
            function(s) 
                --Next
_fin28 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_e125ae56_b7e6_4fbe_8a26_021db59ba477);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_e125ae56_b7e6_4fbe_8a26_021db59ba477);
                nlbwalk(v_67); 
            end
        ),

    },
};

-- Mother carries with mushrooms
v_132 = room {
    nam = "...",
    pic = 'images/mother_road2.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother took mushroom pasties and left. After a few hours on fresh air Mother remembered, that she hadn\'t had anything for breakfast that day.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_94094b17_3528_45a5_bbca_21f98ee26507|Eat one pasty}^";
        p "{v_94dee053_1640_4a57_a35c_13884356a62c|Do not eat pasties}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_94094b17_3528_45a5_bbca_21f98ee26507',
            function(s) 
                --Eat one pasty
                nlbwalk(v_75); 
            end
        ),
        xact(
            'v_94dee053_1640_4a57_a35c_13884356a62c',
            function(s) 
                --Do not eat pasties
                nlbwalk(v_85); 
            end
        ),

    },
};

-- Red Hood did not talk to the woodcutters
v_133 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Being angry with the incident, that just happened, Red Hood did not want to talk to anybody, willing to proceed to her Grandmother.^"..
"\"Mother told me not to talk to strangers!\" she blurted out and turned around. Woodcutters were offended with such a bad-mannered attitude, and returned to the forest. Soon harmonious axes hammering recommenced.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin13)) and "{v_1de661ae_0493_4b34_8507_0a151fc8674e|Next}^" or "");
        p ((( not _fin13)) and "{v_7a5b5f4d_6ad1_4e66_b904_ae0a9a77238f|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/symphony5.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_1de661ae_0493_4b34_8507_0a151fc8674e',
            function(s) 
                --Next
                nlbwalk(v_23); 
            end
        ),
        xact(
            'v_7a5b5f4d_6ad1_4e66_b904_ae0a9a77238f',
            function(s) 
                --Next
_fin13 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3426fafe_bb1e_4994_a692_f0d27eb12266);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3426fafe_bb1e_4994_a692_f0d27eb12266);
                nlbwalk(v_23); 
            end
        ),

    },
};

-- Wolf ate and fell asleep
v_134 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf made himself comfortable under the bush and greedily swallowed pasties. After eating he snuggled down and slept well.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin38)) and "{v_87c44fa7_44a2_4e63_a5c6_c6d6371824b6|Next}^" or "");
        p ((( not _fin38)) and "{v_9c2ab2d6_4579_4199_8f7f_c738b28553bd|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_87c44fa7_44a2_4e63_a5c6_c6d6371824b6',
            function(s) 
                --Next
                nlbwalk(v_123); 
            end
        ),
        xact(
            'v_9c2ab2d6_4579_4199_8f7f_c738b28553bd',
            function(s) 
                --Next
_fin38 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_6891d2b3_b473_4032_bbeb_ae7c3f6cf1c8);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_6891d2b3_b473_4032_bbeb_ae7c3f6cf1c8);
                nlbwalk(v_123); 
            end
        ),

    },
};

-- Wolf became mad, but didn\'t attack her
v_135 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("\"No,\" said Red Hood, \"If I give pasties to every Tom, Dick and Harry, there will be none for my granny.\"^"..
"Wolf became mad and wanted to eat Red Hood together with pasties, but was scared because woodcutters working not far.^"..
"Wolf\'s eyes twinkled, and he ran away to take granny.");
    end,
    xdsc = function(s)
        p "^";
        p (((_no_eat_pie)) and "{v_0cfd81fd_d06f_4d85_b1e0_aab2f7ec9c0d|Next}^" or "");
        p (((_eat_pie and _fin26)) and "{v_f3569aeb_3555_456a_b397_88fea5e8bc31|Next}^" or "");
        p (((_eat_pie and not _fin26)) and "{v_31b1587e_5eb5_470f_ba28_db52a3ca8bcd|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_0cfd81fd_d06f_4d85_b1e0_aab2f7ec9c0d',
            function(s) 
                --Next
                nlbwalk(v_103); 
            end
        ),
        xact(
            'v_f3569aeb_3555_456a_b397_88fea5e8bc31',
            function(s) 
                --Next
                nlbwalk(v_153); 
            end
        ),
        xact(
            'v_31b1587e_5eb5_470f_ba28_db52a3ca8bcd',
            function(s) 
                --Next
_fin26 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_2a6b9f56_2b76_43c2_b9df_21c29932e0b5);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_2a6b9f56_2b76_43c2_b9df_21c29932e0b5);
                nlbwalk(v_153); 
            end
        ),

    },
};

-- Wolf attacked her and swallowed
v_136 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Predator was coming towards her. The girl closed her eyes tight. Wolf attacked her and swallowed. After satiating himself, beast returned to the forest to take a nap.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_573ea6ee_28a9_4385_8e0c_e4302541b892|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
_chaperon_dead = true;
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/symphony5.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_573ea6ee_28a9_4385_8e0c_e4302541b892',
            function(s) 
                --Next
                nlbwalk(v_96); 
            end
        ),

    },
};

-- Mother eats pie
v_137 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother lifted an edge of a tea towel that pasties were covered with, took one pasty and slowly started to chew. It seemed to her, that stuffing had a strange smack. She stopped to chew for a second, but pasty was delicious and well baked through, so she finished it.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_aec23b04_28b8_4ed3_915b_2a7eb2070766|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_aec23b04_28b8_4ed3_915b_2a7eb2070766',
            function(s) 
                --Next
                nlbwalk(v_26); 
            end
        ),

    },
};

-- They entered the hut, but the was nobody inside
v_138 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf decided not to be greedy, especially because the girl was small and skinny. Without a haste he went into the forest.^"..
"Soon afterwards, Red Hood and woodcutters reached the hut.^"..
"Rat-tat - she hammered with a fist on the door.^"..
"Silence.^"..
"\"Step aside girl\" one of men slightly pushed her aside, and hit the door with his giant fist.^"..
"Silence.^"..
"Then woodcutter hit the door with his strong shoulder and broke in. Red Hood and her followers entered the hut, but nobody was inside. Only a cap, glasses and a torn chemise were lying on the floor.^"..
"^"..
"....and remaining pasties were eaten by the woodcutters.^"..
"^"..
"Ending:^"..
"”Telltale evidence”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_51059e9b_953a_454e_bd3d_e48c697cf442_69cd655a_1111_42b7_9bbe_057df356d037_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_51059e9b_953a_454e_bd3d_e48c697cf442_69cd655a_1111_42b7_9bbe_057df356d037_Return',
            function(s) 
                --Next
                nlbwalk(v_12); 
            end
        ),

    },
};

-- Cyclical search
v_139 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood didn\'t follow the butterfly, because she was outdoor more than a day, and was very tired. She was also hungry again.^"..
"The girl looked inside the basket, and found only one pasty. There was nothing else to do, so she ate it and thought to herself, \"Why should I go to my granny? There are no pasties anymore.\" So she decided to return home for a new batch of baked goods.^"..
"Step-by-step Red Hood reached home, but nobody was inside. It is self understood, the girl was missing the whole night, while she was supposed to return until dark, and Mother went to look for her.^"..
"Meanwhile, Mother was in Grandmother\'s house. She found out that daughter didn\'t even show up there. Together with granny they came to the right conclusion, that Red Hood got lost and decided to undertake a searching party. At this exact moment Red Hood thought that Mother was probably looking for her. She didn\'t want to stay home, especially because there was no sign of pasties. Apparently Mother carried them away. That\'s why girl ran at top speed to granny\'s hut to meet relatives. When she came to granny\'s, nobody was there. Meanwhile, Mother and granny were combing the forest.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin41)) and "{v_30867611_91d9_4e60_b4da_2178b4cc0f7c|Split}^" or "");
        p "{v_ef1c0fac_4229_4725_b633_3eb1fa5580fa|Stay together}^";
        p ((( not _fin41)) and "{v_82766880_b4d0_4384_a6c4_f2b30272f861|Split}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/mozart.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_30867611_91d9_4e60_b4da_2178b4cc0f7c',
            function(s) 
                --Split
                nlbwalk(v_37); 
            end
        ),
        xact(
            'v_ef1c0fac_4229_4725_b633_3eb1fa5580fa',
            function(s) 
                --Stay together
                nlbwalk(v_168); 
            end
        ),
        xact(
            'v_82766880_b4d0_4384_a6c4_f2b30272f861',
            function(s) 
                --Split
_fin41 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_aea5cdb0_3765_4621_ad32_b21ec458c788);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_aea5cdb0_3765_4621_ad32_b21ec458c788);
                nlbwalk(v_37); 
            end
        ),

    },
};

-- At first time Wolf growled or whined 
v_140 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("At first time Wolf growled or whined like a puppy. Probably stroke himself after falling down, and lost power of speech. And when food was lifted down, he tried to jump and snap at the feeder. In this case grandmother usually would say^"..
"\"Why you so bad? Don\'t be angry, eat!\"^"..
"And Red Hood repeated,  \"Eat, grey one!\"^"..
"They often talked to Wolf. Sometimes just told him about their lives, or asked him questions and answered by themselves. In short, everything was fine, but there was one drawback - Wolf often howled at night. And after a while he surprised everyone, beginning to wag by his tail, when he was brought some food. On the one hand, it made them glad, but on the other hand, they were upset. Because now there was a chance to let Wolf go without apprehensions, which necessity granny and Red Hood realized good enough.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin2)) and "{v_0d166553_8c69_4894_9e6f_1f4270e520b9|Next}^" or "");
        p ((( not _fin2)) and "{v_ad474dce_c78a_4aa5_bb7e_40a214e58652|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/flohwalzer_dog1.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_0d166553_8c69_4894_9e6f_1f4270e520b9',
            function(s) 
                --Next
                nlbwalk(v_87); 
            end
        ),
        xact(
            'v_ad474dce_c78a_4aa5_bb7e_40a214e58652',
            function(s) 
                --Next
_fin2 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_a7054201_999c_4e04_97ca_b394f2b91180);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_a7054201_999c_4e04_97ca_b394f2b91180);
                nlbwalk(v_87); 
            end
        ),

    },
};

-- He likes her
v_141 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("\"No-no, it\'s not necessary, I\'m in a hurry and you\'ve got lots of work here!\"^"..
"After those words woman grabbed her basket and attempted to leave as soon as possible. She was too tired for hanky-panky.^"..
"Behind her back she heard a few laughs, addressed to unlucky \"Don Juan\" from his colleagues, but the woodcutter, who offered help, wouldn\'t pay attention and followed woman with his eyes. She really charmed him, but he was a man of decision and couldn\'t quit so easily, \"Maybe I should follow her to find out where she lives?\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_44ff2e99_c00e_489a_a49f_54b8e1cebe77|Yes}^";
        p (((_fin15)) and "{v_8388fbb5_3aaf_4207_bbcc_44be3113f479|No}^" or "");
        p ((( not _fin15)) and "{v_6355009e_b99b_465c_8bb9_0a1196bdc43c|No}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_44ff2e99_c00e_489a_a49f_54b8e1cebe77',
            function(s) 
                --Yes
                nlbwalk(v_79); 
            end
        ),
        xact(
            'v_8388fbb5_3aaf_4207_bbcc_44be3113f479',
            function(s) 
                --No
                nlbwalk(v_101); 
            end
        ),
        xact(
            'v_6355009e_b99b_465c_8bb9_0a1196bdc43c',
            function(s) 
                --No
_fin15 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_4648ae92_f1a8_4250_a53b_cb5259fcb592);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_4648ae92_f1a8_4250_a53b_cb5259fcb592);
                nlbwalk(v_101); 
            end
        ),

    },
};

-- Do not eat pie
v_142 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("There was loud rumbling in the stomach, but woman firmly decided - all the contents are for granny only, and kept on going.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_66f6ab3b_1d9d_4d1b_b85b_822fba819adf|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_66f6ab3b_1d9d_4d1b_b85b_822fba819adf',
            function(s) 
                --Next
                nlbwalk(v_107); 
            end
        ),

    },
};

-- -Hello, girl...
v_143 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Hello, girl!\" started Wolf.^"..
"\"How do you do Mr.,\" said Red Hood, looking at her interlocutor with curiosity.^"..
"\"What is your name and where are you going alone\" continued Wolf making stress on word \"alone\".^"..
"\"My name is Red Hood, and I\'m going to visit my Grandmother and bring her pasties with a pot of butter.\"^"..
"\"And my name is Wolf. Where does your granny live?\"^"..
"\"One should go along this path till the forest edge, there will be her hut.\"^"..
"After collecting all required information, the beast departed to the mentioned address to get there before girl does. And she, set her hood straight, took presents and slowly strolled to granny.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_d9d72ed8_35f8_407b_b491_a25a3b388039|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_d9d72ed8_35f8_407b_b491_a25a3b388039',
            function(s) 
                --Next
                nlbwalk(v_41); 
            end
        ),

    },
};

-- Toilets 1
v_144 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Meanwhile, Wolf as always, was prowling in the forest for something to eat, found pasties and ate everything without second thoughts. He also sniffed a bigger prey and had intentions to go after it, because pasties only let him refresh his inner man. But, insidious home-made stuff took its effect, and frustrated all Wolf\'s plans.^"..
"To cut the story short, everybody occupied toilets. Only granny was lucky enough not to taste \"magic\" cuisine.^"..
"^"..
"Ending:^"..
"”Wicked freeload”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f1b2e052_6b31_4d6c_adf1_8c694be0548e_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony_fast.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_f1b2e052_6b31_4d6c_adf1_8c694be0548e_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return',
            function(s) 
                --Next
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Seven years have passed
v_145 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Seven years have passed. One fine day, an overseas stallion stopped by the house of Red Hood and her mother. A divinely handsome price dismounted, who was enchanted Wolf. He asked Red Hood something to eat to break the ice. A meal was offered to him and his stallion.^"..
"By this time Red Hood turned into a beautiful lass. While Prince was drinking tea, Red Hood looked at him with curiosity. Something seemed very familiar about him.^"..
"All of a sudden Prince said, \"Marry me!\"^"..
"And looked right into her eyes. Eyes of Prince were bright blue. Now Red Hood remembered where she saw those eyes. Soon they married and were happy.^"..
"^"..
"Ending:^"..
"”Miraculous outcome”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_76910cb3_98aa_452f_87c2_c6b6aba042f9_0402f0cb_db2e_4a41_9d64_0ba827478cc4_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/studies_on_chopins_etudes.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_76910cb3_98aa_452f_87c2_c6b6aba042f9_0402f0cb_db2e_4a41_9d64_0ba827478cc4_Return',
            function(s) 
                --Next
                nlbwalk(v_14); 
            end
        ),

    },
};

-- Red Hood ate a pasty with mushrooms 2
v_146 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Feeling regrets that the doggy got away, Red Hood kept walking. Now it seemed to her, that the road like a swing was swaying from one side to another. That\'s why she moved in a zigzag manner, brandishing with her basket and didn\'t notice a few fallen pasties. In spite of difficulties, that were constantly arising on her way, Red Hood reached Grandmother\'s.^"..
"\"Who is it?\" asked old lady by a weak voice.^"..
"\"It\'s me, Hood, Red Hood.\"^"..
"\"Pull the string my dear and the door will open.\"^"..
"\"Which one exactly?\" specified girl seeing a bunch of strings.^"..
"This question made old lady hang up. Red Hood, however, kept her head and tried every string until she found the right one.^"..
"Once Red Hood entered the house, she put butter pot on the table, and gave the basket to granny. For some reason, she took it with her teeth. This sight made little girl giggle, and after that she withdrew, keeping sniggering. Old woman was surprised by such granddaughter\'s behaviour, but taste of pasties, that appeared to be with her favourite filling, made her forget about everything.^"..
"Meanwhile, Wolf was suffering from hunger and reproaching himself that he gave way to emotions and lost an easy prey. He made up his mind to return to the spot he met Red Hood and try to smell her out. Following the trail, predator soon stumbled upon fallen pasties.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin39)) and "{v_19ef678b_f2ee_4e57_8746_057c0050b5db|Eat a pasty}^" or "");
        p "{v_a8dd4763_27b8_415f_a644_d4e6f5f290dd|Don\'t eat a pasty}^";
        p ((( not _fin39)) and "{v_9f53a56b_5d27_4b8a_93f1_97ff9819f812|Eat a pasty}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/a_la_mozart_bird.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_19ef678b_f2ee_4e57_8746_057c0050b5db',
            function(s) 
                --Eat a pasty
                nlbwalk(v_124); 
            end
        ),
        xact(
            'v_a8dd4763_27b8_415f_a644_d4e6f5f290dd',
            function(s) 
                --Don\'t eat a pasty
                nlbwalk(v_121); 
            end
        ),
        xact(
            'v_9f53a56b_5d27_4b8a_93f1_97ff9819f812',
            function(s) 
                --Eat a pasty
_fin39 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_e6095f38_6e10_420d_a50b_8113e19b5c02);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_e6095f38_6e10_420d_a50b_8113e19b5c02);
                nlbwalk(v_124); 
            end
        ),

    },
};

-- Hungry Wolf decided to catch up with Mother 
v_147 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf had to withdraw with nothing. Strong hunger compelled him to take risk and pursuit Mother.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_5b298f3a_92c7_45bc_9559_0500a6867964|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_5b298f3a_92c7_45bc_9559_0500a6867964',
            function(s) 
                --Next
                nlbwalk(v_96); 
            end
        ),

    },
};

-- Red Hood treats Wolf with a couple of pasties
v_148 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood glanced at Wolf - water was dripping down from his wet hair, paws and leanness belly were covered in mud. She felt sorry for him, and took out a couple of pasties and put them on the rock by the trail, and continued her way.^"..
"\"Thank you little girl!\" Wolf thanked her and began to eat food with delight.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0a7511c4_c728_430e_9dba_fcbaa35796e4|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/la_marmotte_nylon.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_0a7511c4_c728_430e_9dba_fcbaa35796e4',
            function(s) 
                --Next
                nlbwalk(v_47); 
            end
        ),

    },
};

-- Red Hood carries with cabbage
v_149 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood slowly strolled along the trail. The weather was great, or even better. Sun rays made air burning hot, and all birds and animals hid somewhere. The girl also wanted to take rest in the shade, as she was walking for long time through the sweltering forest.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0c7296db_6eea_4244_a3af_dfa03df51421|Do not turn off the trail}^";
        p "{v_b75ac5dd_968b_4b28_a48d_1a1825d56aef|Turn off the trail}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodday1heat.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_0c7296db_6eea_4244_a3af_dfa03df51421',
            function(s) 
                --Do not turn off the trail
                nlbwalk(v_120); 
            end
        ),
        xact(
            'v_b75ac5dd_968b_4b28_a48d_1a1825d56aef',
            function(s) 
                --Turn off the trail
                nlbwalk(v_167); 
            end
        ),

    },
};

-- Oh, what a doggie
v_150 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Oh, what a doggie!\" she exclaimed, and after she ran up to predator, tousled his ears and afterwards tried to mount him saying, \"Give me a lift to my granny, will you?\"^"..
"That was too much for him! Shocked Wolf broke away from girl\'s hands, and while he was running into the forest, thought how crazy children were nowadays.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a1026387_f735_4fdb_b666_04ff4a3f1a9f|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/flohwalzer_dog2_roar.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_a1026387_f735_4fdb_b666_04ff4a3f1a9f',
            function(s) 
                --Next
                nlbwalk(v_146); 
            end
        ),

    },
};

-- Woodcutters
v_151 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("She turned off the road, and went where sound came from.^"..
"Soon she could see silhouettes of men among the trees. When they saw approaching woman, they stopped chopping, and one of them went to meet her. He took her basket and offered to take rest on a large stump from freshly cut oak.^"..
"After recovering her breath, she said, \"Good evening woodcutters! You\'ve got a hard job taking lots of strength. Here, refresh yourselves with pasties.\"^"..
"After those words, woman removed tea towel off the basket, and said in more loud voice, showing that there was nothing to be shy, \"please, help yourself! Pasties are fresh!\"^"..
"Mother was a good cook, plus not old, attractive woman, that wasn\'t omitted by one of men. Chewing a tasty pasty, he was looking at her with interest. When the woman was preparing to go, he gently but resolutely applied to her,^"..
"\"Let me accompany You, I can carry heavy basket. And wolfs are found in this forest...\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ed2bca85_a57c_4bda_be09_024a6eef4583|Accept}^";
        p "{v_57264032_2028_4c72_9c3d_cf13677501e8|Refuse}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_ed2bca85_a57c_4bda_be09_024a6eef4583',
            function(s) 
                --Accept
                nlbwalk(v_161); 
            end
        ),
        xact(
            'v_57264032_2028_4c72_9c3d_cf13677501e8',
            function(s) 
                --Refuse
                nlbwalk(v_141); 
            end
        ),

    },
};

-- Wolf broke in and ate them both
v_152 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Pull the string and the doo...\" started the old lady.^"..
"\"No-o-o-o-o-o-o!\" was the last thing Mother was able to scream.^"..
"Wolf already snapped the string and pulled it down. After he broke in, Mother and granny were eaten.^"..
"^"..
"Ending:^"..
"”Holy simplicity”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f7ea20e4_37c4_4aeb_8671_aeeafa32f5ed_01a4c786_f042_4fcd_8333_afac265f0328_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/symphony5.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_f7ea20e4_37c4_4aeb_8671_aeeafa32f5ed_01a4c786_f042_4fcd_8333_afac265f0328_Return',
            function(s) 
                --Next
                nlbwalk(v_8); 
            end
        ),

    },
};

-- Red Hood felt stomach ache
v_153 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Soon Red Hood felt stomach ache. She perversely tried to continue her way, but shortly realized that it\'s useless, and double-quick moved back.^"..
"A few minutes later, Wolf approached granny\'s house and knocked on the door.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It is me, Red Hood, your granddaughter!\" whispered Wolf, making his voice as tender as he could.^"..
"\"Oh, pull the string my dear and the door will open!\"^"..
"Once predator found himself inside the house, he promptly swallowed Grandmother, dressed up in her night gown, cap, put on glasses and tumbled into bed. He lied like a fool, waiting for Red Hood, while she was at home with all symptoms of food poisoning.^"..
"^"..
"Ending:^"..
"”Lucky coincidence”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_be00baba_d8e4_498f_a8f8_221a906e552c_01a4c786_f042_4fcd_8333_afac265f0328_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_be00baba_d8e4_498f_a8f8_221a906e552c_01a4c786_f042_4fcd_8333_afac265f0328_Return',
            function(s) 
                --Next
                nlbwalk(v_8); 
            end
        ),

    },
};

-- Mother reached old lady\'s house
v_154 = room {
    nam = "...",
    pic = 'images/woodcut_mushroom.png',
    bgimg = function() end,
    dsc = function(s)
p("Leisurely continuing her way, Mother enjoyed the bright Sun, warm wind, green foliage. At the same time one peculiar detail attracted her attention. She started to see more and more mushrooms along the road. With every step she saw even more. Some of them were growing larger before her eyes. Its stems were getting thicker, like trunks of trees and caps were covering half the sky. Mother drew herself together from horror, but kept on walking.^"..
"Suddenly a group of woodcutters came out of the forest, somehow without clothing. They surrounded gigantic mushroom like ants, and began chopping it. For some time she bashfully cast glances at them, but when chopped gigantic mushroom began to fall right on the road, Mother uttered a loud scream and showed a clean pair of heels.^"..
"Mushrooms were left behind, but by side vision Mother spotted something grey and hairy, moving in the bushes to her left and right. Icy terror locked her heart, her lead-like legs were hard to command. Fighting fatigue woman kept speed, until she threw pursuers off.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin12)) and "{v_e99eda17_9964_48cb_8d76_1d68af17c1c5|Next}^" or "");
        p ((( not _fin12)) and "{v_93871d3b_1222_47e9_802d_ce37bd833910|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/flight_of_the_bumblebeehummelflug_update_1.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_e99eda17_9964_48cb_8d76_1d68af17c1c5',
            function(s) 
                --Next
                nlbwalk(v_97); 
            end
        ),
        xact(
            'v_93871d3b_1222_47e9_802d_ce37bd833910',
            function(s) 
                --Next
_fin12 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_dc8c679b_ea76_4c55_a987_3cc212268c0c);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_dc8c679b_ea76_4c55_a987_3cc212268c0c);
                nlbwalk(v_97); 
            end
        ),

    },
};

-- Resist
v_155 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Having bitter experience, Red Hood resisted hunger and kept on walking along the path. All three soon met each other.^"..
"^"..
"Ending:^"..
"”Patience”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_3b027cf4_6e30_4177_a110_ba81c6d4d3b9_0893e545_e122_46db_9b79_e253c763ca51_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_3b027cf4_6e30_4177_a110_ba81c6d4d3b9_0893e545_e122_46db_9b79_e253c763ca51_Return',
            function(s) 
                --Next
                nlbwalk(v_3); 
            end
        ),

    },
};

-- Woodcutters came and rescued everyone
v_156 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Meanwhile, woodcutters passed by. They heard noise inside the house, and decided to find out what was going on.^"..
"When they saw Wolf with enormous belly, everything became clear. They slaughtered Wolf, rescued Red Hood and her granny.^"..
"Pasties were given to woodcutters as a reward.^"..
"^"..
"Ending:^"..
"”Classic ending”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_70aacf8a_78f1_4923_b886_821f74fd921a_7e35525f_46ee_4774_a39a_5b794054b395_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/woodcutters.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_70aacf8a_78f1_4923_b886_821f74fd921a_7e35525f_46ee_4774_a39a_5b794054b395_Return',
            function(s) 
                --Next
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Red Hood decided to go at random
v_157 = room {
    nam = "...",
    pic = 'images/wolf_night.png',
    bgimg = function() end,
    dsc = function(s)
p("The thought itself, that she\'ll have to go at night alone through the forest, made her inside grow cold. But staying under the tree was even scarier, and she decided to go at random. She walked on and on but the trail would not appear. Red Hood intently looked into the darkness, and when she heard even a slight rustle, rapidly looked around but kept walking.^"..
"Soon she had to admit, that she finally got lost. Fright tortured her heart. She looked at sky. It was coal-black, not a single star. All of a sudden a branch crackled behind her back. She flash like turned round and turned pale of horror. Two blue lights glowed inside the bushes. Her heart beat like mad, palms perspired, and knees treacherously shivered. She felt like someone screamed inside her head, \"run-run\" but legs refused to obey. She stiffened, waiting what happens next. A creature came out of the bushes with no haste. Red Hood could only discriminate a large dark silhouette, but suddenly Moon showed up from behind the clouds, and its light revealed an enormous black wolf. She mentally said goodbye to her life.^"..
"Unexpectedly, Wolf softly pronounced, \"Hello, girl. Don\'t be afraid, I\'m not gonna hurt you. You better tell me why you are alone in the forest, at night?\"^"..
"Pulling herself together Red Hood said, \"I got lost.\"^"..
"\"This can be helped\" said Wolf looking at Red Hood.^"..
"His look stopped at the basket.^"..
"\"Do you have something to eat?\" asked Wolf bending his head on one side, and looking right into girl\'s eyes. After these words Red Hood nearly fainted, because she knew, wolfs don\'t eat cabbage. But nevertheless, being king and generous, she automatically put the basket on the ground, stepped aside and whispered, \"Only this...\"^"..
"To her astonishment, Wolf ate everything with gusto. After he thanked her for food, and asked to follow him to help with some business.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e7b1a6b7_a143_4a30_ae95_74988409b10a|Follow him}^";
        p (((_fin17)) and "{v_fb4b84d6_6ac8_4353_a48e_a5905094130b|Don\'t follow him}^" or "");
        p ((( not _fin17)) and "{v_9c06069c_9e6b_4ec0_89a8_3da95810a556|Don\'t follow him}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/night3.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_e7b1a6b7_a143_4a30_ae95_74988409b10a',
            function(s) 
                --Follow him
                nlbwalk(v_43); 
            end
        ),
        xact(
            'v_fb4b84d6_6ac8_4353_a48e_a5905094130b',
            function(s) 
                --Don\'t follow him
                nlbwalk(v_106); 
            end
        ),
        xact(
            'v_9c06069c_9e6b_4ec0_89a8_3da95810a556',
            function(s) 
                --Don\'t follow him
_fin17 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3ae758b8_ba5f_4d84_8e5f_d2b2b29d54ad);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3ae758b8_ba5f_4d84_8e5f_d2b2b29d54ad);
                nlbwalk(v_106); 
            end
        ),

    },
};

-- Almost standard ending
v_158 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("At the same time Wolf was making his way through the forest, but didn\'t notice when he hit forest border. Some hut was vaguely seen at the distance.^"..
"\"Probably this is the place where Red Hood\'s grandmother lives\" grey predator made his mind.^"..
"He came up to the door and hearkened. There was no sound. After a few seconds pondering, he finally decided to knock.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It is me Red Hood, your granddaughter!\" whispered Wolf, making his voice as tender as he could.^"..
"\"Oh, pull the string my dear and the door will open!\"^"..
"When Wolf found himself inside, he went for the old lady and swallowed her.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin11)) and "{v_8aa7f88f_8cad_452f_9866_c75cdab53fa7|Go to sleep into the forest after fine meal}^" or "");
        p ((( not _fin11)) and "{v_d6d5ed03_49b4_4bf2_abfe_21bb26cfbd63|Go to sleep into the forest after fine meal}^" or "");
        p "{v_141787e2_433a_45f3_8d32_280a35a72bf7|Stay and wait for Red Hood}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/excerpt_from_movement_1_of_tchaikovsky_symphony.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_8aa7f88f_8cad_452f_9866_c75cdab53fa7',
            function(s) 
                --Go to sleep into the forest after fine meal
                nlbwalk(v_138); 
            end
        ),
        xact(
            'v_d6d5ed03_49b4_4bf2_abfe_21bb26cfbd63',
            function(s) 
                --Go to sleep into the forest after fine meal
_fin11 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_19fa365d_a16e_436e_bf6c_d3e31fdcf264);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_19fa365d_a16e_436e_bf6c_d3e31fdcf264);
                nlbwalk(v_138); 
            end
        ),
        xact(
            'v_141787e2_433a_45f3_8d32_280a35a72bf7',
            function(s) 
                --Stay and wait for Red Hood
                nlbwalk(v_86); 
            end
        ),

    },
};

-- Wolf ate granny
v_159 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf remembered food and sympathetic look of Red Hood, and decided to wait until she leave the hut, and only then eat the hag. He could not help it, one cannot be replete with pasties for long.^"..
"Hiding behind the trees, predator was waiting with patience. When Red Hood finally left this shelter, and was already far, Wolf knocked on the door.^"..
"\"Who is it?\" sounded weak voice.^"..
"\"It\'s me Red Hood, your granddaughter!\"^"..
"Old lady was pretty sure that somebody visited her not long ago, but because of progressing sclerosis, couldn\'t tell when exactly.^"..
"\"Pull the string my dear and the door will open!\" she finally said.^"..
"Wolf acted with lightning speed. The old lady didn\'t even have time to realize what was going on, as predator swallowed her.^"..
"^"..
"Ending:^"..
"”Advantageous investment”.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_2ae29898_d43f_4e89_af49_7ea1362be11e_69cd655a_1111_42b7_9bbe_057df356d037_Return|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/la_marmotte_nylon.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_2ae29898_d43f_4e89_af49_7ea1362be11e_69cd655a_1111_42b7_9bbe_057df356d037_Return',
            function(s) 
                --Next
                nlbwalk(v_12); 
            end
        ),

    },
};

-- Night
v_160 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("She woke up at night, because her entire body became numb. Being half-awake, girl could not immediately orientate herself, where she was and what was going on, but little by little reconstructed in memory last events, and it became clear, that she lied under the tree till darkness. She looked around, trying to find the trail, when suddenly felt her heart missed a beat. In thickening shadows one could hardly discern anything. The girl had no idea where to go.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_23efc4ff_de8b_401e_b23a_47711a04b863|Go at random}^";
        p "{v_694d770c_b5d4_44b5_93c3_f36c9a67c635|Wait until dawn}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/night2.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_23efc4ff_de8b_401e_b23a_47711a04b863',
            function(s) 
                --Go at random
                nlbwalk(v_157); 
            end
        ),
        xact(
            'v_694d770c_b5d4_44b5_93c3_f36c9a67c635',
            function(s) 
                --Wait until dawn
                nlbwalk(v_98); 
            end
        ),

    },
};

-- Mother and woodcutter came to granny
v_161 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Oh, really!\" exclaimed tired woman. \"Thank you very much!\"^"..
"Other woodcutters looked at one another, then smiled and went back to work. Mother and woodcutter marched on together.^"..
"On the way they talked about different things, and liked each other. While talking, they didn\'t notice how they reached Grandmother\'s house.^"..
"After the man made sure that woman entered the house and shut the door, he strolled back to forest.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1482ed83_243e_45c1_9a05_8d8faeab10ae|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/redhoodday2.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_1482ed83_243e_45c1_9a05_8d8faeab10ae',
            function(s) 
                --Next
                nlbwalk(v_33); 
            end
        ),

    },
};

-- Stop gorging!
v_162 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Wolf decided not to be greedy. He is a wolf, not a pig.^"..
"He waddled away.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin32)) and "{v_c94108a0_6437_4e37_ba18_a163db0be9f6|Next}^" or "");
        p ((( not _fin32)) and "{v_9f4afff2_7364_4ae3_9c76_fda4f2ab3fa2|Next}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_c94108a0_6437_4e37_ba18_a163db0be9f6',
            function(s) 
                --Next
                nlbwalk(v_69); 
            end
        ),
        xact(
            'v_9f4afff2_7364_4ae3_9c76_fda4f2ab3fa2',
            function(s) 
                --Next
_fin32 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_7b3b988d_52e0_4719_b297_a9bee3e674df);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_7b3b988d_52e0_4719_b297_a9bee3e674df);
                nlbwalk(v_69); 
            end
        ),

    },
};

-- Wolf in the cellar
v_163 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("The girl carefully came up the edge of the hatch, and looked down. There, in semidarkness, two green lights were shining.^"..
"\"They move!\" exclaimed Red Hood, \"what is it?\"^"..
"\"W-o-l-f!\" old lady made her eyes round and narrated what happened.^"..
"They started to think what to do. At first they wanted to call for woodcutters, but then felt sorry for Wolf and decided to keep him. They would lift him down buckets with food and water.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_5907027d_83de_415b_80a4_f3c659e45b45|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/flohwalzer_dog2_roar.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_5907027d_83de_415b_80a4_f3c659e45b45',
            function(s) 
                --Next
                nlbwalk(v_140); 
            end
        ),

    },
};

-- Old lady decided to go down the cellar to get a new portion of mushrooms
v_164 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Old lady decided to go down the cellar to get a new portion of mushrooms. She lifted the cellar cover and remembered, that she didn\'t take a bowl. Granny returned to the cupboard, took the vessel, and forgot where and what for she was going, and why she held the bowl in her hands. Old lady scratched her head, put the bowl back to cupboard and returned to bed.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_9b1e7ebf_1539_46f6_be07_7d0d3fb84b35|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/granny.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_9b1e7ebf_1539_46f6_be07_7d0d3fb84b35',
            function(s) 
                --Next
                nlbwalk(v_29); 
            end
        ),

    },
};

-- Fish attracts Red Hood
v_165 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother laid daughter upon the warm stove and started to prepare to set out her journey. Pasties itself lured Red Hood very much.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_7c682894_aa83_4f78_ac98_c9fde71bff8e|Take a pasty from the basket}^";
        p "{v_8b6a32d9_2f0e_4f8c_9c98_cc1e3e17cd3e|Do not take}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_7c682894_aa83_4f78_ac98_c9fde71bff8e',
            function(s) 
                --Take a pasty from the basket
_chap_got_fish_pie = true;
                nlbwalk(v_109); 
            end
        ),
        xact(
            'v_8b6a32d9_2f0e_4f8c_9c98_cc1e3e17cd3e',
            function(s) 
                --Do not take
                nlbwalk(v_22); 
            end
        ),

    },
};

-- Red Hood slowly drags heavy basket
v_166 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood was slowly dragging herself with heavy basket down the road, without seeing birds, bees, clouds or the Sun. And she didn\'t care what the weather was. Tension made her break into a sweat. And suddenly, she met Wolf.^"..
"Concentrated on her load, she almost bumped into him. When she stopped, she immediately released the basket. Bang! Basket fell on the road like a boulder. Wolf gazed with astonishment at sweaty, puffing girl, who was red like a beetroot.^"..
"\"Hello, child! What is your name and where are you going?\"^"..
"After recovering her breath she replied,^"..
"\"My name is Red Hood. I\'m going to my Grandmother to bring her presents.\"^"..
"\"Why did you take so much you can hardly walk?\", Wolf could not help ask.^"..
"\"I guess I miscalculated my strength. Maybe you can eat a few pasties\" asked Red Hood with hope in her voice.^"..
"\"No\" Wolf screw up his muzzle, after he sniffed pasties, \"I can\'t eat that.\"^"..
"\"Too bad,\"  sighed little girl.^"..
"\"By the way, where does your grandma live?\" Wolf nearly forgot to ask.^"..
"\"Here, by the forest edge. It would seem not so far.\"^"..
"By an abrupt spurt she lifted basket off the ground and dragged herself further, grumbling something. And Wolf ran to the granny\'s house.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_4d2c1bb7_1142_4ffe_ba97_358db8909a84|Wolf chose the short road to granny\'s house}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() 
        set_music('sound/a_la_mozart_slow.ogg', 0);
    end,
    obj = { 
        xdsc(),
        xact(
            'v_4d2c1bb7_1142_4ffe_ba97_358db8909a84',
            function(s) 
                --Wolf chose the short road to granny\'s house
                nlbwalk(v_80); 
            end
        ),

    },
};

-- Red Hood turned off the trail, sat under the bush
v_167 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Red Hood turned off the trail, and when she spotted a branchy spruce, headed right to it. She made herself comfortable under the thick crown, ate a pasty with cabbage, and then leaned against a wide trunk. Red Hood enjoyed quiet and coolness of her shelter, and didn\'t notice how she fell into a doze. She never had such a wonderful sleep.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a5a88578_1d43_42a8_b8ed_4a491659c0dc|Next}^";
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_a5a88578_1d43_42a8_b8ed_4a491659c0dc',
            function(s) 
                --Next
                nlbwalk(v_160); 
            end
        ),

    },
};

-- Stay together
v_168 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Mother thought, \"Maybe we should split?\" but immediately rejected this idea, \"I can\'t lose Grandmother too. I\'ve got enough problems!\"^"..
"They reached Mother\'s house, but girl wasn\'t there. Then women rushed back along the path yelling, \"Red Hood, Red Hood!\"^"..
"Meanwhile, Red Hood left Grandmother\'s hut, as there was nobody there and no food also. The girl headed back home. She was starving after all the running about. Her stomach was rumbling so loud she couldn\'t hear much else.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _fin1)) and "{v_46453339_cf61_4aa7_b53b_edc9272ec286|Go in the forest to eat some berries}^" or "");
        p ((( not _fin31)) and "{v_749da51b_022a_4a08_8a41_2c1d31d306a3|Put up with hunger but do not turn}^" or "");
        p (((_fin1)) and "{v_886d28fb_8754_4fd0_a159_fe9722ce9a76|Go in the forest to eat some berries}^" or "");
        p (((_fin31)) and "{v_6e11a2eb_145c_4ebc_a8a7_750c4815c669|Put up with hunger but do not turn}^" or "");
    end,
    autos = function()
        revive();
    end,
    enter = function(s)
        s.snd();
        s.autos();
        s.bgimg();
    end,
    snd = function() end,
    obj = { 
        xdsc(),
        xact(
            'v_46453339_cf61_4aa7_b53b_edc9272ec286',
            function(s) 
                --Go in the forest to eat some berries
_fin1 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_e9267ae3_2715_408c_958e_254cb50b8907);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_e9267ae3_2715_408c_958e_254cb50b8907);
                nlbwalk(v_18); 
            end
        ),
        xact(
            'v_749da51b_022a_4a08_8a41_2c1d31d306a3',
            function(s) 
                --Put up with hunger but do not turn
_fin31 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_68f087d8_2044_4abc_abbd_06053db5903d);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_68f087d8_2044_4abc_abbd_06053db5903d);
                nlbwalk(v_155); 
            end
        ),
        xact(
            'v_886d28fb_8754_4fd0_a159_fe9722ce9a76',
            function(s) 
                --Go in the forest to eat some berries
                nlbwalk(v_18); 
            end
        ),
        xact(
            'v_6e11a2eb_145c_4ebc_a8a7_750c4815c669',
            function(s) 
                --Put up with hunger but do not turn
                nlbwalk(v_155); 
            end
        ),

    },
};

