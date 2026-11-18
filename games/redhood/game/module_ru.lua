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
    dsc = function(s) p("Достижения:"); end,
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
    dsc = function(s) p("Бабка и целая корзина пирожков^"); end,
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
    dsc = function(s) p("Правильное воспитание^"); end,
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
    dsc = function(s) p("Святая простота^"); end,
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
    dsc = function(s) p("Хорошую вещь не выбросят^"); end,
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
    dsc = function(s) p("Дровосеки спешат на помощь^"); end,
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
    dsc = function(s) p("Узник^"); end,
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
    dsc = function(s) p("Долгожданная находка^"); end,
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
    dsc = function(s) p("Умение вовремя остановиться^"); end,
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
    dsc = function(s) p("Выгодное вложение^"); end,
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
    dsc = function(s) p("Счастливое совпадение^"); end,
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
    dsc = function(s) p("Доброе дело^"); end,
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
    dsc = function(s) p("Позднее зажигание^"); end,
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
    dsc = function(s) p("Чёрная неблагодарность^"); end,
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
    dsc = function(s) p("Умение ждать^"); end,
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
    dsc = function(s) p("Дровосек-спаситель^"); end,
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
    dsc = function(s) p("Счастливый несчастный случай^"); end,
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
        p("-- Так не бывает! Ты выдумываешь! Рассказывай нормально!");
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
        p("-- Не может быть! -- рассмеялась сестрёнка.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end1obj
v_5e992f11_270f_4264_b59d_b625a68255b0 = menu {
    nam = "end1obj",
    disp = function(s) end,
    dsc = function(s) p("Заслуженный отдых^"); end,
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
    dsc = function(s) p("Чревоугодие^"); end,
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
        p("Девочка молчала. Заметив, что она вот-вот расплачется, её брат поспешил начать сказку заново.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end18obj
v_744763fb_dae3_401b_92b9_a42bf705c43e = menu {
    nam = "end18obj",
    disp = function(s) end,
    dsc = function(s) p("Бесплатный сыр^"); end,
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
    dsc = function(s) p("Классическое завершение^"); end,
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
    dsc = function(s) p("Внимание к деталям^"); end,
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
    dsc = function(s) p("Мировые пирожки^"); end,
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
    dsc = function(s) p("У страха глаза велики^"); end,
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
        p("-- А это точно та сказка? Красная Шапочка?^"..
"-- Конечно! Просто мама тебе сокращённую версию читала.^"..
"-- Понятно. А расскажи ешё раз, чтобы я лучше её запомнила.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end24obj
v_19fa365d_a16e_436e_bf6c_d3e31fdcf264 = menu {
    nam = "end24obj",
    disp = function(s) end,
    dsc = function(s) p("Красноречивое свидетельство^"); end,
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
    dsc = function(s) p("Бестолковая домохозяйка^"); end,
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
        p("-- Ты где-то ошибся, должен быть другой конец, -- уверенно заявила девочка.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- allEndingsContainer
v_dbd4c0f7_1988_4983_ac34_e21e290df0d8 = menu {
    nam = "allEndingsContainer",
    disp = function(s) end,
    dsc = function(s) p("^Концовки:^"); end,
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
    dsc = function(s) p("Награда за труд^"); end,
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
    dsc = function(s) p("Мать и бабка^"); end,
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
    dsc = function(s) p("Счастливый конец 2^"); end,
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
    dsc = function(s) p("^Найденные концовки:^"); end,
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
        p("-- Это всё? Что-то мало.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end15obj
v_e125ae56_b7e6_4fbe_8a26_021db59ba477 = menu {
    nam = "end15obj",
    disp = function(s) end,
    dsc = function(s) p("Волк есть волк^"); end,
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
    dsc = function(s) p("Страшный сон^"); end,
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
    dsc = function(s) p("Счастливый конец^"); end,
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
    dsc = function(s) p("Рассчитывай только на себя^"); end,
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
    dsc = function(s) p("Волка ноги кормят^"); end,
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
    dsc = function(s) p("Все живы и здоровы^"); end,
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
    dsc = function(s) p("Если бы да кабы^"); end,
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
    dsc = function(s) p("Бесплатный сыр 2^"); end,
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
        p("-- Не-е-ет, там не так было, -- удивлённо сказала девочка.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end45obj
v_e6095f38_6e10_420d_a50b_8113e19b5c02 = menu {
    nam = "end45obj",
    disp = function(s) end,
    dsc = function(s) p("Почти домашнее животное^"); end,
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
        p("-- Эта сказка мне нравится. Девочка зевнула.^"..
"\"Наконец-то\", -- подумал её брат, -- \"ещё немного и она заснёт!\"");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end6obj
v_656e179e_fb53_487c_8d4a_114206c96516 = menu {
    nam = "end6obj",
    disp = function(s) end,
    dsc = function(s) p("Неразборчивость в еде^"); end,
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
    dsc = function(s) p("Не открывать чужакам^"); end,
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
    dsc = function(s) p("Терпение^"); end,
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
        p("-- Неправильно ты рассказываешь.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end40obj
v_3ae758b8_ba5f_4d84_8e5f_d2b2b29d54ad = menu {
    nam = "end40obj",
    disp = function(s) end,
    dsc = function(s) p("Серые будни^"); end,
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
        p("-- Какая страшная история, -- прошептала девочка, -- мама мне такую не рассказывала, теперь я точно не усну.");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end9obj
v_fabcc368_e24c_4e1e_ae70_e877d7304e6d = menu {
    nam = "end9obj",
    disp = function(s) end,
    dsc = function(s) p("Кузнец своего счастья^"); end,
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
    dsc = function(s) p("День волка^"); end,
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
    dsc = function(s) p("Дикие люди^"); end,
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
        p("Девочка рассмеялась: -- А ты рассказываешь даже интереснее!^"..
"-- Я рад. Теперь спи.^"..
"-- Пожалуйста, пожалуйста, ещё одну сказочку!");
        s.actf(s);
    end,
    actf = function(s)
    end,
};

-- end37obj
v_e9267ae3_2715_408c_958e_254cb50b8907 = menu {
    nam = "end37obj",
    disp = function(s) end,
    dsc = function(s) p("Долго и счастливо^"); end,
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
    disp = function(s) return "Пирожки с мясом" end,
    dsc = function(s) p("Испекла мать {пирожки с мясом}"); end,
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
    disp = function(s) return "Пирожки с яблоками" end,
    dsc = function(s) p("Испекла мать {пирожки с яблоками}"); end,
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
    disp = function(s) return "Пирожки с грибами" end,
    dsc = function(s) p("Испекла мать {пирожки с грибами}"); end,
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
    disp = function(s) return "Пирожки с капустой" end,
    dsc = function(s) p("Испекла мать {пирожки с капустой}"); end,
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
    disp = function(s) return "Ружьё" end,
    dsc = function(s) p("На стене висит {ружьё}"); end,
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
    disp = function(s) return "Пирожки с рыбой" end,
    dsc = function(s) p("Испекла мать {пирожки с рыбой}"); end,
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

-- Красная Шапочка: Возвращение.
v_1, main = room { nam = "main", enter = function(s) nlbwalk(main); end }, room {
    nam = "Красная Шапочка: Возвращение.",
    pic = 'images/bedroom.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Так, одеялом я тебя укрыл, светильник включил. Теперь спи.^"..
"-- А мама всегда рассказывает сказку на ночь.^"..
"-- Один вечер можно и без историй обойтись. Вот завтра будет тебе и мама и сказка.^"..
"-- Нет, я так не засну, -- захныкала девочка, -- пожалуйста, почитай мне.^"..
"-- Ладно, -- проворчал её старший брат, присаживаясь на край кровати, -- только не плачь. Какую сказку ты хочешь?^"..
"-- Красную Шапочку!^"..
"-- Хорошо, слушай.^"..
"-- А ты разве не возьмёшь книжку? Она там в шкафу на нижней полке.^"..
"-- Зачем? Я и так помню. Слушай!");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a4c12c9e_7168_4490_8d3a_bd358cfe9793|Далее}^";
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
                --Далее
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

-- The End
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
p("-- А это точно та сказка? Красная Шапочка?^"..
"-- Конечно! Просто мама тебе сокращённую версию читала.^"..
"-- Понятно. А расскажи ешё раз, чтобы я лучше её запомнила.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end11)) and "{v_ad7e0fec_c364_4714_80a5_4c652c03b32d|Далее}^" or "");
        p (((_end11)) and "{v_636abb43_cf08_4bcc_a502_c19493011cf1|Далее}^" or "");
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
                --Далее
_end11 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_e4b8edea_f237_49a1_8aeb_393d044ddae4);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_636abb43_cf08_4bcc_a502_c19493011cf1',
            function(s) 
                --Далее
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
p("-- Это всё? Что-то мало.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end4)) and "{v_7c09659a_679d_4d16_847c_8d6299580ff6|Далее}^" or "");
        p (((_end4)) and "{v_220a015e_b1ed_487d_be18_d51993b8ef5b|Далее}^" or "");
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
                --Далее
_end4 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_c3251622_b561_42a6_9781_3f584c3a644e);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_220a015e_b1ed_487d_be18_d51993b8ef5b',
            function(s) 
                --Далее
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
p("-- Неправильно ты рассказываешь.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end2)) and "{v_aa8be6e3_7e99_4714_b071_bad36a30f178|Далее}^" or "");
        p (((_end2)) and "{v_22ed8365_aef3_4af2_a504_23e900fdd638|Далее}^" or "");
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
                --Далее
_end2 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_6071b501_4cdb_4b6c_bc08_3f89911e8d1c);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_22ed8365_aef3_4af2_a504_23e900fdd638',
            function(s) 
                --Далее
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
p("-- Не-е-ет, там не так было, -- удивлённо сказала девочка.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end1)) and "{v_e7a4c596_1b4c_4be4_9884_22262852cbe9|Далее}^" or "");
        p (((_end1)) and "{v_170b36c5_ac8d_4c18_a2da_e49eeb76891e|Далее}^" or "");
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
                --Далее
_end1 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_2030e267_6e30_4f2c_acf5_99f47fe4db29);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_170b36c5_ac8d_4c18_a2da_e49eeb76891e',
            function(s) 
                --Далее
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
p("Девочка рассмеялась: -- А ты рассказываешь даже интереснее!^"..
"-- Я рад. Теперь спи.^"..
"-- Пожалуйста, пожалуйста, ещё одну сказочку!");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end10)) and "{v_fb0fe502_c466_48bb_a6a7_f7972d101ae9|Далее}^" or "");
        p (((_end10)) and "{v_0ceb4c0e_4625_4d27_828f_88842b2ba68c|Далее}^" or "");
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
                --Далее
_end10 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_8f5949c3_1b2c_40c0_9913_6ded19a81fee);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_0ceb4c0e_4625_4d27_828f_88842b2ba68c',
            function(s) 
                --Далее
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
p("-- Ты где-то ошибся, должен быть другой конец, -- уверенно заявила девочка.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end5)) and "{v_6d55ba6f_0b11_48fe_9be6_b4c0c8502c9f|Далее}^" or "");
        p (((_end5)) and "{v_3c5a8ed5_e4a0_4d4d_88df_0666677c8ce0|Далее}^" or "");
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
                --Далее
_end5 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_77bcefba_cdaa_4e3d_945f_b314280eddb6);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_3c5a8ed5_e4a0_4d4d_88df_0666677c8ce0',
            function(s) 
                --Далее
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
        p "{v_bdc9de0d_353c_4432_82b8_eaf10fbfdb7c|Назад}^";
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
                --Назад
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
p("-- Не может быть! -- рассмеялась сестрёнка.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end3)) and "{v_e2735e63_059c_4953_afe3_875396eea342|Далее}^" or "");
        p (((_end3)) and "{v_cbf9ea49_be4d_43ae_871b_ce2517802c50|Далее}^" or "");
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
                --Далее
_end3 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_15f76f53_5a7b_4ab1_8576_ed73d62e7fff);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_cbf9ea49_be4d_43ae_871b_ce2517802c50',
            function(s) 
                --Далее
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
p("-- Так не бывает! Ты выдумываешь! Рассказывай нормально!");
    end,
    xdsc = function(s)
        p "^";
        p (((_end6)) and "{v_78837a29_d74e_4e69_8180_dfd1e074a323|Далее}^" or "");
        p ((( not _end6)) and "{v_674ae87f_6084_4516_aed2_62c4169b034c|Далее}^" or "");
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
                --Далее
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_674ae87f_6084_4516_aed2_62c4169b034c',
            function(s) 
                --Далее
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
p("Девочка молчала. Заметив, что она вот-вот расплачется, её брат поспешил начать сказку заново.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end7)) and "{v_5ec5c6fa_6d62_4649_b705_139e02f65c34|Далее}^" or "");
        p (((_end7)) and "{v_99e5bae2_4ad3_4d9d_a9ad_5470e1a3fd35|Далее}^" or "");
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
                --Далее
_end7 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_5b379821_cc37_4973_bcd1_03e5f530a8b1);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_99e5bae2_4ad3_4d9d_a9ad_5470e1a3fd35',
            function(s) 
                --Далее
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
p("-- Какая страшная история, -- прошептала девочка, -- мама мне такую не рассказывала, теперь я точно не усну.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end9)) and "{v_39a3572c_2436_4470_8b5f_aea949a9049b|Далее}^" or "");
        p (((_end9)) and "{v_bbf7d1bc_b216_4033_ac00_9bbfc538a03a|Далее}^" or "");
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
                --Далее
_end9 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_8de3bf80_279b_45af_bed4_2edf8477b3cb);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_bbf7d1bc_b216_4033_ac00_9bbfc538a03a',
            function(s) 
                --Далее
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
p("-- Эта сказка мне нравится. Девочка зевнула.^"..
"\"Наконец-то\", -- подумал её брат, -- \"ещё немного и она заснёт!\"");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _end8)) and "{v_0394629e_05e9_41e0_867e_8de735d158dd|Далее}^" or "");
        p (((_end8)) and "{v_e38dfed8_fa35_427f_ba5c_94e6052119aa|Далее}^" or "");
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
                --Далее
_end8 = true;
                addf(v_905a1602_ce40_46f0_a57f_61cc9f7e346e, v_234cc112_0046_49f3_97b3_9d49bfa13665);
    _achievementsCount = _achievementsCount + 1;
                nlbwalk(v_15); 
            end
        ),
        xact(
            'v_e38dfed8_fa35_427f_ba5c_94e6052119aa',
            function(s) 
                --Далее
                nlbwalk(v_15); 
            end
        ),

    },
};

-- Старт
v_15 = room {
    nam = "...",
    pic = 'images/cover5.png',
    bgimg = function() end,
    dsc = function(s)
p("Найденных концовок: ".._endingsCount.."/45");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6655127b_69cc_4b22_93e7_377c6c565a65|Список концовок}^";
        p "{v_0a19cdb2_6b51_499c_9996_e2dc3406bba1_7603a6c8_5d35_4bec_8f50_1b59ad600fec_Traverse|Далее}^";
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
                --Список концовок
                nlbwalk(v_9); 
            end
        ),
        xact(
            'v_0a19cdb2_6b51_499c_9996_e2dc3406bba1_7603a6c8_5d35_4bec_8f50_1b59ad600fec_Traverse',
            function(s) 
                --Далее
                nlbwalk(v_16); 
            end
        ),

    },
};

-- Начало
v_16 = room {
    nam = "...",
    pic = 'images/chaperon_face.png',
    bgimg = function() end,
    dsc = function(s)
p("Жила-была в одной деревне маленькая девочка, такая хорошенькая, что лучше ее и на свете не было.^"..
"Мать любила ее без памяти, а бабушка еще больше.^"..
"^"..
"Ко дню рождения подарила ей бабушка красную шапочку.^"..
"С тех пор девочка всюду ходила в своей новой, нарядной красной шапочке.^"..
"Соседи так про нее и говорили:^"..
"^"..
"-- Вот Красная Шапочка идет!^"..
"^"..
"Собралась как-то раз мама испечь пирожков. И призадумалась: а с какой начинкой бы их испечь?");
    end,
    xdsc = function(s)
        p "^";
        p "{v_48718486_32e3_4236_b6f4_41873a0e2419|С рыбой}^";
        p "{v_0a93e7bd_6c58_4d95_8107_6b57a3643ddf|С мясом}^";
        p "{v_46d5d402_a6d9_48cd_84d2_ed27fa2cf679|С яблоками}^";
        p "{v_f5438e24_39e2_49c1_9650_bfe1c66691a7|С капустой}^";
        p "{v_2adcb87e_4696_4101_b2c1_49379695abbb|С грибами}^";
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
                --С рыбой
_fish = true;
                addf(nil, v_53390a81_6d97_4c39_9148_029d558a91d5);
                nlbwalk(v_20); 
            end
        ),
        xact(
            'v_0a93e7bd_6c58_4d95_8107_6b57a3643ddf',
            function(s) 
                --С мясом
_meat = true;
                nlbwalk(v_55); 
            end
        ),
        xact(
            'v_46d5d402_a6d9_48cd_84d2_ed27fa2cf679',
            function(s) 
                --С яблоками
_apple = true;
                addf(nil, v_361a45f2_2b55_4692_937d_871274eda0a6);
                nlbwalk(v_58); 
            end
        ),
        xact(
            'v_f5438e24_39e2_49c1_9650_bfe1c66691a7',
            function(s) 
                --С капустой
_cabbage = true;
                addf(nil, v_e6e4c889_c068_46b8_9926_0aed4449e46b);
                nlbwalk(v_60); 
            end
        ),
        xact(
            'v_2adcb87e_4696_4101_b2c1_49379695abbb',
            function(s) 
                --С грибами
_mushroom = true;
                addf(nil, v_8d44d129_e7ac_410d_871b_4af67d0390bd);
                nlbwalk(v_81); 
            end
        ),

    },
};

-- Волк проследил за матерью до домика бабки
v_17 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("В этот момент неподалёку рыскал Волк, как всегда голодный. Пересекая тропинку, зверь обнаружил обронённый матерью пирожок. Уже очень давно у Волка в пасти даже маковой росинки не было, поэтому, съел он пирожок не раздумывая. Естественно для насыщения этого оказалось недостаточно, и Волк продолжил рыскать по лесу в поисках добычи.^"..
"^"..
"Тем временем, мать добралась до бабки, отдала ей пирожки, горшочек масла и поспешила обратно домой. А Волк бродил, бродил в чаще и не заметил, как очутился на опушке. Раньше он никогда не заходил в эту часть леса. Здесь на пригорке стоял небольшой деревянный домик, и Волк решил узнать, кто там живёт. Запрыгнув на крыльцо, хищник постучал в дверь.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin43)) and "{v_3a519726_841a_4818_9ef7_88ce65d1533b|Далее}^" or "");
        p ((( not _fin43)) and "{v_0129c5c3_c445_469f_a191_0e2deb9b18d6|Далее}^" or "");
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
                --Далее
                nlbwalk(v_128); 
            end
        ),
        xact(
            'v_0129c5c3_c445_469f_a191_0e2deb9b18d6',
            function(s) 
                --Далее
_fin43 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_b720d443_51dd_4963_93d3_680d1fb53e90);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_b720d443_51dd_4963_93d3_680d1fb53e90);
                nlbwalk(v_128); 
            end
        ),

    },
};

-- Свернула КШ в лес поесть земляники.
v_18 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("Свернула Красная Шапочка в лес поесть земляники. Ягод было много. Горстями рвала их Красная Шапочка и клала в рот. В это время по тропинке с криками:^"..
"-- Красная Шапочка!^"..
"пробегали с бешеной скоростью мать с бабкой.^"..
"Услышав их крики, Красная Шапочка автоматически вдохнула, чтобы отозваться как можно громче. Но поперхнулась ягодами. Потому не удалось ей крикнуть, но зато удалось увидеть, куда мать с бабкой побежали. Прокашлялась она кое-как и рванула по тропинке в ту сторону, куда они побежали.^"..
"А навстречу Волк.^"..
"-- ЭЭЭ... -- сказал Волк.^"..
"-- Как ты не вовремя! -- с досадой сказала девочка.^"..
"Не стала она ждать продолжения, дала Волку по морде и побежала дальше. Сильно надоело ей быть в лесу одной, не до волков всяких. Волк так офигел, что даже догонять её не стал. Действительно, какая-то бешеная девочка, есть такое опасно.^"..
"^"..
"А она вот догнала маму с бабкой. И жили они долго и счастливо.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Долго и счастливо\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ee11155e_c54c_4516_8886_a3289f7fca6b_7daf90de_cc43_429a_88ed_21011df2f00e_Return|Далее}^";
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
                --Далее
                nlbwalk(v_11); 
            end
        ),

    },
};

-- Вечером он встречает её, вскоре они поженились
v_19 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("А дровосек проводил мать до дома, там он познакомился с её дочкой, Красной Шапочкой. Через некоторое время мужчина и женщина поженились.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Счастливый конец\".^"..
"^"..
"^"..
"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_267cc9ce_de21_47b9_b241_f2ec38becd17_0402f0cb_db2e_4a41_9d64_0ba827478cc4_Return|Далее}^";
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
                --Далее
                nlbwalk(v_14); 
            end
        ),

    },
};

-- Пирожки с рыбой
v_20 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Посмотрела мать в кладовке, спустилась в погреб и обнаружила там последнюю солёную горбушу из прошлогодних запасов.^"..
"\"Давно уже здесь лежит, -- подумала хозяйка, -- да что ей сделается в погребе\". Взяла рыбу под мышку и полезла наверх.^"..
"^"..
"Тщательно выбрав все косточки, мать принялась лепить пирожки, благо тесто давно поднялось.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_691777b7_7e19_4ba5_8cf1_e723e0b32c7a|Испекла мама пирожки и говорит дочке...}^";
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
                --Испекла мама пирожки и говорит дочке...
                nlbwalk(v_122); 
            end
        ),

    },
};

-- Волк поражён щедростью и добротой
v_21 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Простая крестьянка, к тому же, жившая в лесной глуши, женщина не привыкла к столь витиеватым фразам. Но она очень внимательно слушала обращавшегося к ней Волка и после нескольких секунд раздумий воскликнула:^"..
"^"..
"-- А, пирожок хотите?^"..
"^"..
"Волк кивнул:^"..
"^"..
"-- Вы совершенно правильно меня поняли, мад...^"..
"^"..
"Но женщина его уже не слушала, а просто достала пару пирожков и, положив на землю, отправилась дальше.^"..
"^"..
"Волк поражён щедростью и добротой. Он съедает угощение и, хотя для полного насыщения этого явно не достаточно, решает сегодня никого не есть. Несмотря на лёгкое бурление в животе, он засыпает под кустом.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin37)) and "{v_52cea8d5_b9fc_4771_83e5_c44236dd6f6d|Далее}^" or "");
        p ((( not _fin37)) and "{v_96c744a7_8512_495f_abd4_efa9502f1ba7|Далее}^" or "");
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
                --Далее
                nlbwalk(v_119); 
            end
        ),
        xact(
            'v_96c744a7_8512_495f_abd4_efa9502f1ba7',
            function(s) 
                --Далее
_fin37 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_7b494c88_f59f_41a6_8b14_339e0917d36e);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_7b494c88_f59f_41a6_8b14_339e0917d36e);
                nlbwalk(v_119); 
            end
        ),

    },
};

-- Мать несёт с рыбой
v_22 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Вскоре в комнату вошла мать, уже одетая в дорогу. Взяла она пирожки с рыбой, поцеловала дочь и вышла из дома.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_2c202c7d_7873_4864_9fd8_ce4fb7d08072|Далее}^";
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
                --Далее
                nlbwalk(v_66); 
            end
        ),

    },
};

-- Волк всех съел, в том числе и все пирожки
v_23 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка быстро шагала по тропинке, даже не подозревая, что за ней неслышно следует серый хищник. Пройдя за ней до самой опушки и терпеливо дождавшись, когда дверь откроется, Волк следом за девочкой прорвался в дом. Там он съел и бабку, и Красную Шапку и пирожки, а потом, сытый и довольный, пошёл в лес спать.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"День волка\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_26b5cd69_81a0_4361_8bf8_6e1c5c4be51e_69cd655a_1111_42b7_9bbe_057df356d037_Return|Далее}^";
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
                --Далее
                nlbwalk(v_12); 
            end
        ),

    },
};

-- КШ переделывает
v_24 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Несмотря на юный возраст, девочка была очень ответственной и привыкла всё делать на совесть. Вылила она бурду, тщательно протёрла миску и, в этот раз, уже самым внимательнейшим образом отмерила необходимую дозу каждого компонента. Волк всё слакал и облизал чашку.^"..
"^"..
"Поблагодарил зверь Красную Шапочку, вывел к тропинке и даже проводил до дома и, спросив напоследок, как её зовут, Волк убежал. Идти к бабушке Шапочка передумала, ведь пирожков уже не было, да и шибко устала она за день от всего пережитого.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin20)) and "{v_e24a737c_66c0_4956_bd76_aea1ab469d32|Далее}^" or "");
        p ((( not _fin20)) and "{v_9ebc0930_ed2c_4dfe_8fff_9b81d3f293dd|Далее}^" or "");
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
                --Далее
                nlbwalk(v_145); 
            end
        ),
        xact(
            'v_9ebc0930_ed2c_4dfe_8fff_9b81d3f293dd',
            function(s) 
                --Далее
_fin20 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_e1ecbe83_5eda_49ee_b813_8eb513dd22b1);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_e1ecbe83_5eda_49ee_b813_8eb513dd22b1);
                nlbwalk(v_145); 
            end
        ),

    },
};

-- Рассердился Волк и схватился за корзинку, хочет отобрать
v_25 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка взглянула на Волка: с промокшей шерсти капает вода, лапы и пузо, почти прилипшее к спине, в грязи.^"..
"\"Грязное лесное животное! -- брезгливо поморщившись, подумала Красная Шапочка\".^"..
"^"..
"-- Не могу я раздавать пирожки, они все для бабушки.^"..
"^"..
"С этими словами она поспешила пройти мимо, но Волк, мучимый голодом и недовольный пренебрежительным отношением, внезапно вцепился зубами в корзинку и рванул на себя.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin35)) and "{v_1309de8a_c97c_45f1_a1c2_db69c127b825|Отпустить корзинку}^" or "");
        p "{v_87521591_d9dd_4a1d_9098_baec6aad437b|Не отпускать ни за что!}^";
        p ((( not _fin35)) and "{v_536c7669_a88e_4bd5_88b9_5eef8de5b987|Отпустить корзинку}^" or "");
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
                --Отпустить корзинку
                nlbwalk(v_118); 
            end
        ),
        xact(
            'v_87521591_d9dd_4a1d_9098_baec6aad437b',
            function(s) 
                --Не отпускать ни за что!
                nlbwalk(v_49); 
            end
        ),
        xact(
            'v_536c7669_a88e_4bd5_88b9_5eef8de5b987',
            function(s) 
                --Отпустить корзинку
_fin35 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_73e61329_4e57_4b12_9f4a_8f2b686ed165);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_73e61329_4e57_4b12_9f4a_8f2b686ed165);
                nlbwalk(v_118); 
            end
        ),

    },
};

-- Съела мать пирожок и вскоре у неё закрутило живот
v_26 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Вскоре у неё закрутило живот. Так как сегодня она ничего не ела, то подозрение пало на пирожки. Вытряхнула она их из корзинки под куст и бегом побежала к бабке, до домика которой оставалось совсем немного. Сделав по пути ещё несколько вынужденных остановок, она наконец-то добралась до опушки леса.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _chap_got_fish_pie and _fin21)) and "{v_02cb3f46_0c2e_45c4_8c08_1edba247d41b|Далее}^" or "");
        p (((_chap_got_fish_pie and _fin18)) and "{v_0201060d_593a_4d29_a271_c4d82b787508|Далее}^" or "");
        p (((_chap_got_fish_pie and not _fin18)) and "{v_5e61ae0f_59f7_4e76_b3c3_064deb28e1c7|Далее}^" or "");
        p ((( not _chap_got_fish_pie and not _fin21)) and "{v_432f94c1_6d2c_4bad_a230_402b60b5f7af|Далее}^" or "");
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
                --Далее
                nlbwalk(v_110); 
            end
        ),
        xact(
            'v_0201060d_593a_4d29_a271_c4d82b787508',
            function(s) 
                --Далее
                nlbwalk(v_144); 
            end
        ),
        xact(
            'v_5e61ae0f_59f7_4e76_b3c3_064deb28e1c7',
            function(s) 
                --Далее
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
                --Далее
_fin21 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_d6672938_2983_4032_a25c_a6d497f15f1e);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_d6672938_2983_4032_a25c_a6d497f15f1e);
                nlbwalk(v_110); 
            end
        ),

    },
};

-- Диалог бабушки и Волка
v_27 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Так как Волк забыл спросить, где же домик бабушки, то ему пришлось идти по следу Красной Шапочки, который привёл его к цели.^"..
"^"..
"По запаху чуя, что девочка ещё здесь, Волк задумался, пощадить её или нет.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6605c653_5a64_4169_8f68_0730ebac3e82|Съесть обеих}^";
        p (((_fin36)) and "{v_00adc905_f901_4771_be2c_dcc6071718b3|Не есть Красную Шапочку}^" or "");
        p ((( not _fin36)) and "{v_16fe9921_7f12_44e2_b732_ed3f8ba2e133|Не есть Красную Шапочку}^" or "");
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
                --Съесть обеих
                nlbwalk(v_113); 
            end
        ),
        xact(
            'v_00adc905_f901_4771_be2c_dcc6071718b3',
            function(s) 
                --Не есть Красную Шапочку
                nlbwalk(v_159); 
            end
        ),
        xact(
            'v_16fe9921_7f12_44e2_b732_ed3f8ba2e133',
            function(s) 
                --Не есть Красную Шапочку
_fin36 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_93d59afb_c4fa_413c_9e2b_e74477c051df);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_93d59afb_c4fa_413c_9e2b_e74477c051df);
                nlbwalk(v_159); 
            end
        ),

    },
};

-- Наевшись, он страдает от поноса и разочарования
v_28 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Волк, больше не в силах сдерживаться, одним прыжком преодолел расстояние, отделявшее его от путницы, выхватил корзинку и скачками унёсся в лес. А мать так и осталась стоять на тропинке с горшочком масла в руке.^"..
"^"..
"За несколько секунд Волк уничтожил содержимое корзинки, но расплата не заставила себя долго ждать. Сидя под кустом и страдая от поноса и разочарования, Волк проклинал бестолковых домохозяек. Сегодня он уже никому не навредит.^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Бестолковая домохозяйка\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_47c5068e_d896_451e_a0b2_2cdbb98527aa_7e35525f_46ee_4774_a39a_5b794054b395_Return|Далее}^";
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
                --Далее
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Вскоре раздался стук в дверь
v_29 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("Вскоре раздался стук в дверь.^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка! -- пропел Волк как можно более высоким голосом.^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Хищник, словно вихрь, ворвался в дом и провалился в подпол. Бабка потеряла сознание.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f66370b5_e73c_4548_ad2b_ea88fbc3488d|Далее}^";
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
                --Далее
                nlbwalk(v_117); 
            end
        ),

    },
};

-- Волк проследил до домика, съел мать, бабку
v_30 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("Но матёрый хищник, собрав волю в лапу, решил проследить за женщиной, предвкушая более крупную и обильную добычу. Чутьё его не обмануло, вскоре они приблизились к домику на опушке. Дождавшись, когда мать войдёт в дом, Волк ринулся вперёд и, сунув морду в закрывающуюся дверь, ворвался в помещение.^"..
"^"..
"Мирное щебетание лесных птиц прервали два душераздирающих женских крика, но уже через несколько секунд всё стихло. Только из-за приоткрытой двери раздавалось жадное чавканье.^"..
"^"..
"Проглотив свою добычу, Волк заметил рассыпавшиеся по полу пирожки.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin29)) and "{v_b854fb69_d0f5_423e_9147_eeff797ecae8|Съесть ещё и пирожки?}^" or "");
        p "{v_1092f2d9_753e_4bf5_924f_cffe8e851baa|Хватит жрать!}^";
        p ((( not _fin29)) and "{v_0db22a64_158a_43cc_9b41_6ca438072fb0|Съесть ещё и пирожки?}^" or "");
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
                --Съесть ещё и пирожки?
                nlbwalk(v_32); 
            end
        ),
        xact(
            'v_1092f2d9_753e_4bf5_924f_cffe8e851baa',
            function(s) 
                --Хватит жрать!
                nlbwalk(v_162); 
            end
        ),
        xact(
            'v_0db22a64_158a_43cc_9b41_6ca438072fb0',
            function(s) 
                --Съесть ещё и пирожки?
_fin29 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_f1ddc5ac_ea5e_40f8_8451_02f4a4b8963c);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_f1ddc5ac_ea5e_40f8_8451_02f4a4b8963c);
                nlbwalk(v_32); 
            end
        ),

    },
};

-- Встретила она на пути Волка
v_31 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("Вдруг из кустов на тропинку вышел Волк. Ему хотелось немедленно съесть девчонку, но хитрец решил сначала выведать, кто она и куда направляется.^"..
"^"..
"-- Здравствуй, девочка! -- ощущая своё полное превосходство, начал Волк.^"..
"-- Здравствуйте, месье, -- сказала Красная Шапочка, с любопытством разглядывая собеседника.^"..
"-- Как тебя зовут и куда ты идёшь одна, -- продолжал Волк, сделав акцент на слове \"одна\".^"..
"-- Меня зовут Красная Шапочка, и я иду к бабушке, несу ей пирожки и горшочек масла.^"..
"-- А меня Волк. А где живёт твоя бабушка?^"..
"-- Надо идти прямо по этой тропинке до опушки, там и будет домик моей бабушки.^"..
"^"..
"Волк хотел ещё узнать, чем начинены пироги, но в этом уже не было необходимости, так как ветер переменился и хищник почуял рыбу. Проглотив слюну, он произнёс:^"..
"-- Красная Шапочка, дай мне, пожалуйста, попробовать пирожок.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_d5ec6d7f_2c48_4f86_8a9c_91e1166ce228|Не угощать Волка пирожком}^";
        p "{v_556ab87b_400a_4383_a98b_7bb3ea20b859|Угостить Волка пирожком}^";
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
                --Не угощать Волка пирожком
                nlbwalk(v_135); 
            end
        ),
        xact(
            'v_556ab87b_400a_4383_a98b_7bb3ea20b859',
            function(s) 
                --Угостить Волка пирожком
                nlbwalk(v_38); 
            end
        ),

    },
};

-- Мать, бабка и пирожки с рыбой -- термоядерная смесь
v_32 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Мать, бабка и пирожки с рыбой -- термоядерная смесь. Переживёт ли волк эту ночь -- неизвестно...^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Чревоугодие\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_4f0678ba_1e58_4dea_a248_3d3085a03dc2_01a4c786_f042_4fcd_8333_afac265f0328_Return|Далее}^";
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
                --Далее
                nlbwalk(v_8); 
            end
        ),

    },
};

-- Волк в засаде
v_33 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Всё это время Волк не упускал людей из вида, надеясь, что обстоятельства сложатся в его пользу и ему удастся кем-нибудь пообедать или поужинать. При виде дровосека Волк сильно нервничал, но теперь, когда тот ушёл, зверь немного успокоился и остался караулить около домика.^"..
"^"..
"Несколько часов ожидания сделали хищника раздражённым, а когда солнце начало клонится к закату, Волк окончательно озверел. Вдруг поблизости хрустнула ветка. Волк насторожился. Но тут из кустов вышел утренний дровосек. Откуда же серому охотнику было знать, что мать с дровосеком договорились снова встретиться вечером.^"..
"^"..
"Не выдержал Волк, заплакал и поплёлся в лес искать другую добычу.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin6)) and "{v_f9198213_778f_48ce_838a_b547cd0444c5|Далее}^" or "");
        p ((( not _fin6)) and "{v_a397e731_c967_4463_9151_33b913788a01|Далее}^" or "");
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
                --Далее
                nlbwalk(v_19); 
            end
        ),
        xact(
            'v_a397e731_c967_4463_9151_33b913788a01',
            function(s) 
                --Далее
_fin6 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_66f71c19_0a70_4f58_8437_b45eaa625d3a);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_66f71c19_0a70_4f58_8437_b45eaa625d3a);
                nlbwalk(v_19); 
            end
        ),

    },
};

-- КШ несёт с яблоками
v_34 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Мама говорит:^"..
"-- Сходи ка ты, Красная Шапочка, к бабушке, отнеси ей пирожки и горшочек масла да узнай, как её здоровье.^"..
"-- Хорошо, мама! -- отвечает та.^"..
"^"..
"Взяли они большую корзину и положили туда пирожков с горой. Набрала Красная Шапочка гостинцев полные руки и потащилась к выходу. Поглядела мать, как тяжело идёт её дочь, и говорит:^"..
"-- Что-то корзина получилась тяжёлая. Может, отбавим немного?");
    end,
    xdsc = function(s)
        p "^";
        p "{v_37a100d4_ee96_46e4_926a_5b79a292a3ad|-- Так донесу!}^";
        p "{v_7a1dd147_9c62_41c1_a841_42d36a3b6c48|-- Давай отбавим!}^";
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
                ---- Так донесу!
_heavy = true;
                nlbwalk(v_166); 
            end
        ),
        xact(
            'v_7a1dd147_9c62_41c1_a841_42d36a3b6c48',
            function(s) 
                ---- Давай отбавим!
                nlbwalk(v_77); 
            end
        ),

    },
};

-- Прибегает тем временем волк к дому бабушки.
v_35 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("В это время Волк прибежал к дому бабки и постучал. Старушка, дожёвывая пятый пирожок, подошла к двери и смотрит в щёлку. А там Волк!^"..
"^"..
"Бабка испугалась и, чуть не подавившись пирожком, отскочила от двери.^"..
"^"..
"В надежде обнаружить другой вход, зверь решает обойти избушку. Тем временем, следы привели дровосеков к домику на опушке. Один из мужчин поднялся на крыльцо и забарабанил кулаком в дверь. Бабка, которая ещё не успела отойти от неё, вздрогнула и снова глянула в щель. Только что здесь стоял Волк, а теперь здоровый мужик.^"..
"-- Боже мой! -- прошептала она.^"..
"Вконец испуглась бабка. Волк, находившийся с другой стороны избушки, услышав грубые мужские голоса, предпочёл убраться подальше в лес подобру-поздорову.^"..
"^"..
"Со страха бабка проявила невиданную для её возраста прыть: подскочила к шкафу и достала оттуда оставшееся от деда ружьё. Открыв окошко, старушка выставила дуло ружья и закричала:^"..
"-- Убирайся, оборотень поганый!^"..
"Дровосеки хотели рассердиться, но почему-то рассмеялись.^"..
"-- Пойдём отсюда. Тут какая-то дикая бабка! -- сказал один.^"..
"И они, развернувшись, отправились прочь.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Дикие люди\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_4151629d_f98e_4d1c_a25b_862bfbbf3711_7e35525f_46ee_4774_a39a_5b794054b395_Return|Далее}^";
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
                --Далее
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Мать не поняла
v_36 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Будучи незнатного происхождения, к тому же, жившая в лесной глуши, женщина не привыкла к столь витиеватым фразам, поэтому не поняла, чего хотел Волк. Удивлённо и одновременно настороженно поглядывая на хищника, мать аккуратно обошла его сбоку и, тревожно оглядываясь, продолжила путь.^"..
"^"..
"Волк, шокированный столь пренебрежительным отношением, захлопал глазами, но очередной приступ голода вернул его к реальности и заставил дейстовать по старинке.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin27)) and "{v_3ac36aad_5dec_4103_a078_5eb00c1bafed|Далее}^" or "");
        p ((( not _fin27)) and "{v_5f0e878c_a630_4e80_a310_71591cadf95c|Далее}^" or "");
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
                --Далее
                nlbwalk(v_28); 
            end
        ),
        xact(
            'v_5f0e878c_a630_4e80_a310_71591cadf95c',
            function(s) 
                --Далее
_fin27 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1);
                nlbwalk(v_28); 
            end
        ),

    },
};

-- Разделиться
v_37 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Обессиленная Шапочка рухнула на кровать и отключилась. А мать с бабкой решили разделиться, чтобы увеличить шансы на успех. Cтарушка направилась к дому матери и Шапочки, так как до него было ближе идти, а мать помчалась через лес на опушку, всё же надеясь по дороге встретить дочь.^"..
"-- А-у-у! -- звала она и прислушивалась, но всё без толку.^"..
"^"..
"Пробегая мимо бабкиной избушки, женщина на всякий случай глянула в окошко. Вздох облегчения вырвался из её груди. На постели мирно спала её дочь Красная Шапочка.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Долгожданная находка\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c6579557_aae1_432f_99d8_164b0a90f47d_95861bf1_f46d_4b05_9673_01e48857a8e9_Return|Далее}^";
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
                --Далее
                nlbwalk(v_4); 
            end
        ),

    },
};

-- Волк убежал.
v_38 = room {
    nam = "...",
    pic = 'images/wolf_running.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка извлекла пирожок и положила его прямо в открытую пасть Волка. С удовольствием прожевав пирог и не забыв поблагодарить, Волк убежал.");
    end,
    xdsc = function(s)
        p "^";
        p (((_eat_pie)) and "{v_628b1001_9438_4c54_a220_d3fe7b9a03f3|Далее}^" or "");
        p (((_no_eat_pie and _fin45)) and "{v_d434990c_1fff_48eb_b94f_5a7c91e44574|Далее}^" or "");
        p (((_no_eat_pie and not _fin45)) and "{v_971ee17b_6777_4943_bf79_f617fcb3ac61|Далее}^" or "");
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
                --Далее
                nlbwalk(v_115); 
            end
        ),
        xact(
            'v_d434990c_1fff_48eb_b94f_5a7c91e44574',
            function(s) 
                --Далее
                nlbwalk(v_42); 
            end
        ),
        xact(
            'v_971ee17b_6777_4943_bf79_f617fcb3ac61',
            function(s) 
                --Далее
_fin45 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_51467b9f_3405_465d_8216_d36b24d99366);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_51467b9f_3405_465d_8216_d36b24d99366);
                nlbwalk(v_42); 
            end
        ),

    },
};

-- Бабка лезет в погреб и там случайно закрывается
v_39 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Бабка помнила, что ела грузди из миски вчера... Или позавчера... Короче, не стала она рисковать, а полезла в погреб за новой порцией грибов. Вдруг палочка, подпирающая крышку подпола, сломалась и та рухнула с грохотом.^"..
"^"..
"Оказавшись взаперти в полной темноте, старушка растерялась. В этот момент раздался стук в дверь. Но в подполье ничего не было слышно. А Волк (так как это был он) уже вовсю тарабанил в дверь.^"..
"^"..
"Подумав, что никого нет, Волк, тем не менее, сразу не ушёл, а принялся вокруг обходить строение. И не зря, сзади он заметил открытое окно, влезть в которое ему не составило труда.^"..
"^"..
"В доме серый хищник нашёл кое-какую одежду старушки и, напялив её на себя, лёг в кровать.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _heavy and _fin42)) and "{v_22a776f9_0bcd_4afd_9383_f86233d379e0|Далее}^" or "");
        p (((_heavy and _fin19)) and "{v_2f448ad0_f796_4ca9_b912_41de2e3cad28|Далее}^" or "");
        p (((_heavy and not _fin19)) and "{v_5fd4b5ff_6010_4507_87a5_390db2ff5754|Далее}^" or "");
        p ((( not _heavy and not _fin42)) and "{v_f8507356_7742_4250_900f_948cfbdd89d1|Далее}^" or "");
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
                --Далее
                nlbwalk(v_127); 
            end
        ),
        xact(
            'v_2f448ad0_f796_4ca9_b912_41de2e3cad28',
            function(s) 
                --Далее
                nlbwalk(v_108); 
            end
        ),
        xact(
            'v_5fd4b5ff_6010_4507_87a5_390db2ff5754',
            function(s) 
                --Далее
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
                --Далее
_fin42 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_8e58d530_8ff3_48d9_aa92_b7fe2d772bdb);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_8e58d530_8ff3_48d9_aa92_b7fe2d772bdb);
                nlbwalk(v_127); 
            end
        ),

    },
};

-- КШ несёт с мясом
v_40 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка не спеша бредёт по скользкой мокрой тропинке. Грязь чавкает под деревянными башмаками, шапочка мокнет под дождём. Вдруг навстречу Волк. Замерла Красная Шапочка на месте и ждёт, что будет.^"..
"^"..
"Хищник, погружённый в свои мысли, тоже на мгновение растерялся, но, быстро осмотревшись по сторонам и понюхав воздух, понял, что девочка, скорее всего, в лесу одна.^"..
"^"..
"-- Здравствуй, девочка! -- осмелев, сказал Волк. -- Как тебя зовут и куда ты идёшь?^"..
"-- Меня зовут Красная Шапочка, я иду к бабушке, несу ей пирожки с мясом и горшочек масла.^"..
"При слове \"мясо\" Волк оживился и даже забыл спросить, где живёт бабушка.^"..
"-- Милая девочка, а не угостишь ли ты меня пирожком?");
    end,
    xdsc = function(s)
        p "^";
        p "{v_084a1855_8651_492f_a6e9_71cb0cd6f02f|Дать пирожок Волку}^";
        p "{v_f1501b1d_c0e9_40ca_85e8_a604589cc701|Не давать пирожок Волку}^";
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
                --Дать пирожок Волку
                nlbwalk(v_148); 
            end
        ),
        xact(
            'v_f1501b1d_c0e9_40ca_85e8_a604589cc701',
            function(s) 
                --Не давать пирожок Волку
                nlbwalk(v_25); 
            end
        ),

    },
};

-- Волк типа съел
v_41 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Естественно, Волк прибежал на опушку первым. Запрыгнув на крыльцо, он постучал.^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка! -- пропел Волк как можно более высоким голосом.^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Оказавшись в доме, хищник без лишних разговоров проглотил бабку, а затем надел её ночную рубашку, очки, чепец и завалился в кровать.^"..
"^"..
"Вскоре до бабушкиной избушки добралась и Красная Шапочка. Своим маленьким кулачком она забарабанила в дверь.^"..
"^"..
"-- Кто там... -- Волк постарался придать голосу страдальческое выражение.^"..
"-- Это я, твоя внучка, Красная Шапочка! Принесла пирожки и горшочек масла.^"..
"-- А,  -- Волк покашлял. -- Дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Зашла девочка, поставила корзину и горшочек на стол, а сама присела на край кровати и внимательно посмотрела на старушку.^"..
"^"..
"-- Бабушка, а почему у тебя такие большие уши?^"..
"-- Чтоб лучше тебя слышать...^"..
"-- А почему у тебя такие большие глаза?^"..
"-- Чтоб лучше тебя видеть...^"..
"-- Ага, а зубы отчего такие большие?^"..
"-- Это чтобы тебя съесть!^"..
"И проглотил Красную Шапочку раньше, чем до неё дошёл смысл последних слов.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin5)) and "{v_d41aa0e5_5550_4eae_b62d_111a356d1e0d|Далее}^" or "");
        p ((( not _fin5)) and "{v_2a0f8b88_07f4_4ef2_bdb2_ec678e2970c9|Далее}^" or "");
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
                --Далее
                nlbwalk(v_90); 
            end
        ),
        xact(
            'v_2a0f8b88_07f4_4ef2_bdb2_ec678e2970c9',
            function(s) 
                --Далее
_fin5 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_281d18c5_70d1_4edc_812c_0c46cd7fa945);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_281d18c5_70d1_4edc_812c_0c46cd7fa945);
                nlbwalk(v_90); 
            end
        ),

    },
};

-- Пришла КШ к бабушке, оставила ей целую корзинку пирожков с рыбой и ушла.
v_42 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Пришла КШ к бабушке, оставила ей целую корзинку пирожков с рыбой и ушла. А волк тем временем сидел под кустом и было ему не до бабки.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Бабка и целая корзина пирожков\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6c4a8a4f_be12_48ed_b240_7a800e1ca44d_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Далее}^";
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
                --Далее
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Пойти
v_43 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Привёл Волк Красную Шапочку в своё логово. К её удивлению, это оказалась какая-то ветхая избушка. Внутри находился массивный стол, шкаф с книгами и множество полок с расставленными на них бутылочками и коробочками. Всё, конечно же, покрыто толстым слоем пыли.^"..
"^"..
"Недоумевающая и заинтригованная девочка поинтересовалась, чем же она может помочь. Почему-то она больше не боялась этого лесного зверя.^"..
"^"..
"-- В шкафу на нижней полке справа есть толстая коричневая книга, достань её, -- начал Волк, -- а теперь открой на самой последней странице, там будет рецепт. Приготовь по нему, пожалуйста, напиток. Все необходимые компоненты можно найти на этих полках.^"..
"^"..
"Рецепт показался Шапочке несколько странным: 25 капель лосьона, замедляющего рост волос, 10 капель валерианы, 11 капель препарата от блох, 9 волчьих ягод, 1 таблетка аспирина, 50 грамм вина, 7 капель освежителя дыхания, 1 капля крови молодой девушки. А после следовала приписка: \"Строго соблюдайте дозировку!\"^"..
"^"..
"Завершив изучение рецепта, Красная Шапочка принялась за дело. Разыскав все требуемые компоненты, она начала тщательно отмерять нужное количество препаратов. Но, отсчитывая 25 капель лосьона, сбилась, о чём-то задумавшись");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin8)) and "{v_579a7a2f_550c_4ac1_b40d_84aeb8cfe43f|Отдать как есть}^" or "");
        p "{v_0bb4a812_4a93_4223_8ae4_de2d4e29fe2b|Переделать}^";
        p ((( not _fin8)) and "{v_e7851734_583f_4d86_a9a1_fbb2404517d0|Отдать как есть}^" or "");
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
                --Отдать как есть
                nlbwalk(v_93); 
            end
        ),
        xact(
            'v_0bb4a812_4a93_4223_8ae4_de2d4e29fe2b',
            function(s) 
                --Переделать
                nlbwalk(v_24); 
            end
        ),
        xact(
            'v_e7851734_583f_4d86_a9a1_fbb2404517d0',
            function(s) 
                --Отдать как есть
_fin8 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_94aa5e87_1ee6_492c_8cc0_430e0b42978c);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_94aa5e87_1ee6_492c_8cc0_430e0b42978c);
                nlbwalk(v_93); 
            end
        ),

    },
};

-- Ничему КШ жизнь не учит
v_44 = room {
    nam = "...",
    pic = 'images/night.png',
    bgimg = function() end,
    dsc = function(s)
p("Ничему Красную Шапочку жизнь не учит. Побежала она за бабочкой, которая не спеша порхала с цветка на цветок и будто манила за собой. Потом девочка увидела ещё одну бабочку даже ярче и красивее прежней, и погналась за ней.^"..
"^"..
"Вдоволь набегавшись за бабочками, Шапочка собралась вернуться на тропинку. Шла она, шла, но дорожка всё ещё не появлялась.^"..
"\"Может, я иду не туда? -- подумала девочка\"^"..
"И повернула в другую сторону. Затем она меняла направление ещё несколько раз, металась по лесу, словно загнанный зверь. Она определённо заблудилась, но боялась себе в этом признаться. А когда стало темнеть, она остановилась и заплакала. Конечно, паниковать не было смысла и Шапочка сумела взять себя в руки. Она решила бороться до последнего.^"..
"^"..
"Следующие несколько дней девочка придерживалась такой стратегии: днём она шла, пытаясь найти хоть какую-нибудь тропинку, которая бы вывела её к людям, а ночью забиралась на дерево. Пила она росу, а ела ягоды, благо в это время года их было полным-полно. Но к концу третьего дня Шапочка еле волочила ноги. Сил оставалось всё меньше, и забраться на дерево с наступлением ночи ей удалось с большим трудом. Красная Шапочка долго глядела сквозь частые ветви с густой хвоей на полную луну, прислушиваясь к звукам ночного леса, пока, наконец, не забылась в тяжёлой дрёме.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin25)) and "{v_7fbbc4bb_b3ae_4297_8a13_2691fbcf2e21|Далее}^" or "");
        p ((( not _fin25)) and "{v_2cba5b05_179a_4281_bd38_2572cf5a55bb|Далее}^" or "");
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
                --Далее
                nlbwalk(v_62); 
            end
        ),
        xact(
            'v_2cba5b05_179a_4281_bd38_2572cf5a55bb',
            function(s) 
                --Далее
_fin25 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_fce84888_652a_4fc4_8ce8_a760619a8a08);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_fce84888_652a_4fc4_8ce8_a760619a8a08);
                nlbwalk(v_62); 
            end
        ),

    },
};

-- Но быстро взяла себя в руки КШ, вскинула ружьё и застрелила Волка
v_45 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("От испуга Красная Шапочка на секунду замешкалась, но быстро взяла себя в руки и, направив ружьё на Волка, спустила курок. В цель она не попала, но зверь, не ожидавший подобного отпора от девочки и старушки, с визгом, словно побитый щенок, выскочил за дверь и скрылся в чаще.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Рассчитывай только на себя\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_7f783a77_5c38_49d6_850b_ab77aa280cc6_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Далее}^";
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
                --Далее
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Волк выхватывает корзинку и убегает в лес.
v_46 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("В этот момент неподалёку рыскал мокрый и голодный Волк. Он уже почувствовал запах добычи, который вскоре привёл хищника к тропинке. Увидев взрослого человека, Волк немного струхнул, но голод пересилил, и он решил заговорить с путницей.^"..
"^"..
"-- Здравствуйте, мадам! -- проговорил зверь, стуча зубами от холода. -- Как вас...^"..
"-- Я с незнакомцами не разговариваю! -- отрезала женщина, которая уже очень устала, промокла и хотела как можно скорее оказаться дома.^"..
"Волк задрожал от злости, ему даже стало жарко. Он хотел броситься и проглотить свою жертву, но побоялся, что после долгой голодовки у него недостаточно сил, поэтому он принял другое решение. Немного отойдя в сторонку, как бы для того, чтобы пропустить женщину, волк дождался, пока они поравняются, после чего резким движением зубами выхватил корзинку и скрылся в лесу.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _enough)) and "{v_2c6ab50d_a08c_4fd2_9620_9055d62e5a61|Далее}^" or "");
        p (((_enough)) and "{v_b5351ef9_25d9_4a30_9293_74321e8fa97b|Далее}^" or "");
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
                --Далее
                nlbwalk(v_131); 
            end
        ),
        xact(
            'v_b5351ef9_25d9_4a30_9293_74321e8fa97b',
            function(s) 
                --Далее
                nlbwalk(v_134); 
            end
        ),

    },
};

-- Тем временем КШ приходит к бабушке
v_47 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Некоторое время спустя Красная Шапочка добралась до домика бабушки и постучала в дверь.^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка!^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Бабушка обрадовалась посетительнице, обнялись они, а потом сели они пить чай с пирожками и маслом. Старушка и спрашивает:^"..
"-- Как же добралась ты ко мне, внучка? Нормально ли?");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ff90fa0c_4dd0_41a8_b46a_6f3e2260909d|Рассказать про Волка по дороге}^";
        p "{v_c4d16e5d_ebea_446a_a054_6036306e18cb|Не рассказывать про встречу с Волком}^";
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
                --Рассказать про Волка по дороге
                nlbwalk(v_105); 
            end
        ),
        xact(
            'v_c4d16e5d_ebea_446a_a054_6036306e18cb',
            function(s) 
                --Не рассказывать про встречу с Волком
                nlbwalk(v_57); 
            end
        ),

    },
};

-- Мать несёт с капустой, волк пришёл к КШ
v_48 = room {
    nam = "...",
    pic = 'images/mother_road2.png',
    bgimg = function() end,
    dsc = function(s)
p("Взяла мать гостинцы и отправилась в путь. Идёт она не спеша по тропинке, вдыхает свежий лесной воздух, наслаждается тёплым солнечным светом и не подозревает, что Волк вышел на её след. Не то, что напасть, а даже заговорить со взрослым человеком Волку мешала осторожность, тем более, что где-то неподалёку стучали топорами дровосеки. Тогда зверь пошёл на хитрость: отчётливо различая запах путницы на дорожке, он начал двигаться в противоположную ей сторону, надеясь, что там, откуда она пришла, остался кто-нибудь более слабый.^"..
"^"..
"Вскоре Волк добрался до домика матери и постучал в дверь.^"..
"^"..
"-- Кто там? -- спросила Красная Шапочка.^"..
"-- Это ваш сосед.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_81c50c75_f4af_4ec2_ac7b_4822ed513fe1|-- Иди лесом!}^";
        p "{v_bcedb668_8ee2_4ea4_93bf_1f657560c339|-- Заходите!}^";
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
                ---- Иди лесом!
                nlbwalk(v_63); 
            end
        ),
        xact(
            'v_bcedb668_8ee2_4ea4_93bf_1f657560c339',
            function(s) 
                ---- Заходите!
                nlbwalk(v_130); 
            end
        ),

    },
};

-- КШ вцепилась в корзинку мёртвой хваткой, издав душераздирающий визг
v_49 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка вздрогнула от неожиданности, но вцепилась в корзинку мёртвой хваткой, выронив при этом масло и издав душераздирающий визг. Хищник рычал и скалил зубы, пытаясь вырвать поклажу из рук девчонки и вдруг услышал, как неподалёку затих стук топоров. Волк счёл благоразумным удалиться, причём как можно скорее.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a8f679e2_1430_4608_ae9c_4f90908b80f5|Далее}^";
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
                --Далее
                nlbwalk(v_83); 
            end
        ),

    },
};

-- Волк съел КШ
v_50 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Зверь терпеливо дожидался прихода Шапочки. И через некоторое время раздался заветный стук.^"..
"^"..
"-- Кто там... -- Волк постарался придать голосу страдальческое выражение.^"..
"-- Это я, твоя внучка, Красная Шапочка! Принесла пирожки и горшочек масла.^"..
"-- А,  -- Волк покашлял. -- Дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Зашла девочка, поставила корзину и горшочек на стол, а сама присела на край кровати и внимательно посмотрела на старушку.^"..
"^"..
"-- Бабушка, а почему у тебя такие большие уши?^"..
"-- Чтоб лучше тебя слышать...^"..
"-- А почему у тебя такие большие глаза?^"..
"-- Чтоб лучше тебя видеть...^"..
"-- А голос почему такой хриплый и с басом?^"..
"К этому вопросу Волк не был готов.^"..
"-- Ну-у, -- завращал глазами хищник. -- это я болею! -- наконец нашёлся он.^"..
"-- Ага, а зубы отчего такие большие? Гиперкальцемия?^"..
"-- Чего? -- не понял Волк. Но тут же подумал: \"Какая разница\" и сказал:^"..
"-- Это чтобы тебя съесть!^"..
"И проглотил Красную Шапочку раньше, чем до неё дошёл смысл последних слов.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Позднее зажигание\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_cb5b7235_b99e_45cd_8d5e_8f20a1ac75b3_8f127e94_d289_456e_896a_dd397aa32341_Return|Далее}^";
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
                --Далее
                nlbwalk(v_13); 
            end
        ),

    },
};

-- Волк понял, что ловить тут нечего
v_51 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("-- А как она выглядит? -- подмигнув бабке, поинтересовалась мать.^"..
"-- Я не разглядел, у меня зрение плохое. -- ответил хитрец.^"..
"-- Говори через дверь или иди лесом! Мы незнакомым не открываем. -- сказала мать, уверенная, что говоривший врёт и её дочь ни в коем случае не впустила бы чужака.^"..
"^"..
"\"Это у них семейное, -- подумал Волк\". Он понял, что ловить тут нечего и убежал в лес, чтобы попытаться уснуть в своём логове. Ведь, как известно, кто спит, тот обедает.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Правильное воспитание\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a20cf59a_13cf_47a2_ad6a_eee2a53eed71_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Далее}^";
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
                --Далее
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Встало солнышко.
v_52 = room {
    nam = "...",
    pic = 'images/butterfly.png',
    bgimg = function() end,
    dsc = function(s)
p("Ночь прошла тихо, а когда встало солнышко, увидела Шапочка тропинку. Спустившись с дерева, девочка весело побежала по тропинке.^"..
"^"..
"Радость переполняла её сердце, ведь она осталась жива и невредима. К тому же, вышла из леса, не заблудившись. Шагала она по дорожке и любовалась каждым цветочком, каждой бабочкой. Одна оказалась особенно крупной и яркой. Захотелось девочке рассмотреть её поближе, но насекомое, вспорхнув с ромашки, полетело в лес.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_3636f0fe_0c33_4134_8c66_fd2132d952e5|Не бежать за бабочкой}^";
        p "{v_06dbe6da_fe43_46f6_b9cc_e47c7137aa79|Побежать за бабочкой}^";
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
                --Не бежать за бабочкой
                nlbwalk(v_139); 
            end
        ),
        xact(
            'v_06dbe6da_fe43_46f6_b9cc_e47c7137aa79',
            function(s) 
                --Побежать за бабочкой
                nlbwalk(v_44); 
            end
        ),

    },
};

-- КШ нормально несёт лёгкую корзинку
v_53 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("И вдруг навстречу Волк.^"..
"^"..
"-- Здравствуй, девочка! -- ощущая своё полное превосходство, начал Волк.^"..
"-- Здравствуйте, месье, -- сказала Красная Шапочка, с любопытством разглядывая собеседника.^"..
"-- Как тебя зовут и куда ты идёшь одна, -- продолжал Волк, сделав акцент на слове \"одна\".^"..
"-- Меня зовут Красная Шапочка, и я иду к бабушке, несу ей пирожки и горшочек масла.^"..
"-- А меня Волк. А где живёт твоя бабушка?^"..
"-- Надо идти прямо по этой тропинке, затем на развилке повернуть направо, у поваленного дерева налево, там пройти ровно двадцать шагов, после чего взять направление на юго-восток и ещё через тридцать шагов, у большого муравейника, направо. Только надо смотреть внимательно, чтобы были рыжие муравьи, а не чёрные. Как только доберётесь до трёх сосен, не елей, на пригорке, налево. И прямо-прямо до опушки, а там уже и домик покажется.^"..
"^"..
"Наступило молчание. Волк переваривал информацию. Чтобы прервать затянувшуюся паузу, Красная Шапочка продолжила:^"..
"-- В общем-то, можно и по короткой дороге, напрямую через лес, но я боюсь так ходить, там совсем нет ни ориентиров, ни проторённой тропы.^"..
"^"..
"-- До свидания, девочка! -- сказал Волк.^"..
"Получив всю необходимую информацию, он решил немедленно отправиться к старушке.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_37e69a9e_2ca4_471d_b1f6_866637a2e57c|Волк побежал по короткой дороге к домику бабушки}^";
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
                --Волк побежал по короткой дороге к домику бабушки
                nlbwalk(v_80); 
            end
        ),

    },
};

-- Пирожок с грибами
v_54 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Через некоторое время она почуствовала, что солнце уже не просто греет, а нещадно палит. \"Неудивительно, -- подумала девочка, -- вон оно какое огромное, в полнеба\"^"..
"^"..
"Наклонив голову, чтобы вытереть пот со лба, она невольно вскрикнула и замерла. Слева и справа зиял обрыв, далеко-далеко внизу зеленели деревья, которые с этого расстояния казались игрушечными. Сама Шапочка находилась на узенькой тропинке и могла сорваться в бездну в любую секунду. Повесив корзинку на плечо и расставив руки в стороны, она начала осторожно двигаться вперёд, словно балансируя на канате.^"..
"^"..
"Уже несколько минут Волк наблюдал за ней из кустов. А девочка, тем временем, оказалась перед широким озером. Воды она не боялась, поэтому незамедлительно пустилась вплавь. Волк же наблюдал, как девочка с корзинкой на спине барахтается на дорожке в пыли. Такого Волк ещё ни разу не видел. Он собрался уже уходить отсюда, но тут в животе сильно заурчало и зверь всё-таки решился. Вышел он на тропинку перед Красной Шапочкой. Та как раз добралась до берега и теперь прямо на себе отжимала мокрую одежду. Не успел Волк открыть пасть, чтобы начать беседу, как девочка его заметила.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_2594c901_4f72_4738_9886_d86f7480cf66|Далее}^";
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
                --Далее
                nlbwalk(v_150); 
            end
        ),

    },
};

-- Пирожки с мясом
v_55 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Посмотрела мать в кладовке, спустилась в погреб и обнаружила там последнюю солёную горбушу из прошлогодних запасов.^"..
"\"Давно уже здесь лежит, -- подумала хозяйка, -- лучше возьму кусок мяса, он посвежее\".^"..
"^"..
"Но мясо было замороженное, и пришлось вначале ждать, пока оно оттает. Только после этого женщина его мелко порубила и обжарила на сковороде с луком. Когда начинка остыла до комнатной температуры, смогла приступить к приготовлению пирожков.^"..
"^"..
"Пока пирожки пеклись, на улице уже стемнело, и было решено отправиться к бабушке завтра.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e51b120e_d7b5_4123_be3b_84cd859ef68f|Рано утром мать разбудила Красную Шапочку и говорит ей...}^";
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
                --Рано утром мать разбудила Красную Шапочку и говорит ей...
                nlbwalk(v_122); 
            end
        ),

    },
};

-- КШ несёт с рыбой
v_56 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка была послушной девочкой. Взяла она пирожки с рыбой и пошла. Яркие тёплые лучи, пробиваясь сквозь листву, рождали сотни солнечных зайчиков, щебетали пташки, порхали бабочки. Красная Шапочка вприпрыжку бежала по тропинке, настроение у неё было отличное. Только вот незадача: сегодня девочка ещё не завтракала и на свежем воздухе у неё разыгрался аппетит.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_31be88db_321f_4480_96cd_4e6e7b974a18|Съест один пирожок}^";
        p "{v_2175a217_4421_483f_9de0_f72b1853d5cc|Съест несколько пирожков}^";
        p "{v_5d38c185_303b_4837_9f8f_92307cd11331|Не будет есть пирожки}^";
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
                --Съест один пирожок
_eat_pie = true;
                nlbwalk(v_68); 
            end
        ),
        xact(
            'v_2175a217_4421_483f_9de0_f72b1853d5cc',
            function(s) 
                --Съест несколько пирожков
                nlbwalk(v_126); 
            end
        ),
        xact(
            'v_5d38c185_303b_4837_9f8f_92307cd11331',
            function(s) 
                --Не будет есть пирожки
_no_eat_pie = true;
                nlbwalk(v_94); 
            end
        ),

    },
};

-- Продолжили они пить чай и беседовать
v_57 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Не захотела Красная Шапочка лишний раз волновать старушку и ответила:^"..
"-- Хорошо дошла, как обычно, только вот немного продрогла.^"..
"-- Ну, это не страшно. Возьми мою шаль, укутайся, да и согреешься!^"..
"Завернулась девочка в шаль, а бабушка добавила ей в кружку кипятка. Продолжили они пить чай и мирно беседовать.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_903b91a4_83f2_4efe_a7ce_112cc726fddb|Далее}^";
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
                --Далее
                nlbwalk(v_27); 
            end
        ),

    },
};

-- Пирожки с яблоками
v_58 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Яблок в этом году уродилось -- тьма! Поэтому вопрос с начинкой решился очень быстро. Взяла мать самую большую ёмкость, какую только смогла найти, и замесила в ней тесто.^"..
"^"..
"Затем, вместе с Красной Шапочкой, перечистили они и перерезали гору яблок, налепили пирожков и... пекли их два дня. Когда, наконец, всё было готово, настало время решить, кому же нести гостинцы.");
    end,
    xdsc = function(s)
        p "^";
        p (((_apple)) and "{v_fcbf434c_04f5_4db6_84ac_4589771e87b4|Понесёт Красная Шапочка}^" or "");
        p (((_apple)) and "{v_0fa4dc2d_f021_42fb_a8ac_572fdf705565|Понесёт мама}^" or "");
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
                --Понесёт Красная Шапочка
_chaperon = true;
                nlbwalk(v_34); 
            end
        ),
        xact(
            'v_0fa4dc2d_f021_42fb_a8ac_572fdf705565',
            function(s) 
                --Понесёт мама
_mother = true;
                nlbwalk(v_65); 
            end
        ),

    },
};

-- Волк успел съесть старушку и лёг ждать КШ
v_59 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка, тем временем, еле волоча ноги, приблизилась к домику бабушки. Из последних сил взобравшись на крыльцо, она почти упала на дверь.^"..
"^"..
"-- Кто там? -- слабым голосом спросила бабушка.^"..
"-- Внучка! -- устало ответила Красная Шапочка. -- Открывай! -- выдохнула она, надеясь, что бабушка впустит её в дом и они вдвоём затащат корзинку внутрь.^"..
"Но старушка сказала:^"..
"-- Дёрни, деточка, за верёвочку, дверь и откроется.^"..
"Что подумала Красная Шапочка, неизвестно, так как она была ещё маленькая.^"..
"^"..
"Оставив корзинку, горшочек и выслушав трёхчасовой отчёт о состоянии здоровья, девочка, наконец-то, отправилась домой спать.^"..
"^"..
"Бабка ела пирожки с маслом, Волк от пережитого стресса задремал.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Заслуженный отдых\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c0ec5bc9_eeb1_482e_9f96_b04cb4eda75b_62442425_2015_4757_88c4_0ec58edf555e_Return|Далее}^";
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
                --Далее
                nlbwalk(v_5); 
            end
        ),

    },
};

-- Готовит с капустой
v_60 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Спустилась мать в погреб и обнаружила там последнюю солёную горбушу: \"Давно уже лежит, -- подумала хозяйка, -- возьму мяса. Хотя нет, слишком маленький кусочек остался. Так ведь яблок полно... Не пойдёт, они уже надоели. А не осталось ли у нас капусты?\"^"..
"^"..
"Подойдя к большому ящику, мать откинула мешковину. Внутри лежала ещё пара кочанов. Вопрос с начинкой решился, и женщина принялась за работу: завела тесто, нашинковала капусту, и через пару часов извлекла из печи румяные ароматные пирожки, сложила их в корзинку...");
    end,
    xdsc = function(s)
        p "^";
        p "{v_3075fcde_df97_4eb1_8542_74b03d0dda50|...и говорит:}^";
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
                --...и говорит:
                nlbwalk(v_122); 
            end
        ),

    },
};

-- Но девочка была не робкого десятка
v_61 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Но девочка была не робкого десятка. Моментально взяв себя в руки, она выскочила из дома и, впрыгнув в деревянный туалет, заперлась там. Волк кинулся следом, но на секунду замешкался, так как не ожидал сопротивления, и дверь захлопнулась перед самым его носом.^"..
"^"..
"Зверь ещё долго бродил вокруг, щёлкая зубами. А Красная Шапочка с замиранием следила за ним сквозь щели своего ветхого убежища.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_d8e4c43d_8792_4916_931c_a43110b54c1f|Далее}^";
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
                --Далее
                nlbwalk(v_147); 
            end
        ),

    },
};

-- Дровосек-спаситель
v_62 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Пробудилась она ранним утром. Солнце ещё только показалось из-за горизонта. Какие-то посторонние резкие звуки вносили сумбур в привычную однообразную жизнь леса. Спросонья девочка пыталась сообразить, кто или что издаёт такой знакомый звук.^"..
"\"Да это же стук топора! -- чуть не крикнула она\". Причём где-то совсем рядом, очень-очень близко. Она принялась вертеть головой направо и налево, одновременно пытаясь слезть с дерева, но после ночи в неудобной позе всё тело затекло, а мышцы задеревенели и отказывались повиноваться. Но Красная Шапочка, не обращая на это внимания, пыталась немедленно спуститься на землю. \"Скорее, скорее! -- мысленно подгоняла она сама себя, боясь, что волшебный звук исчезнет или окажется сном\". Дыхание её участилось, руки дрожали. А стук через несколько секунд и правда стих. Не веря своим ушам, девочка готова была разрыдаться, но вдруг начала медленно отклоняться вправо. Она ещё крепче уцепилась руками за ветки, но это не помогло остановить падение, которое всё ускорялось.^"..
"-- А-а-а!^"..
"Отчаянный крик, смешанный с треском ломающихся веток и шорохом листьев, огласил лес. Испуганный воплем дровосек подбежал к только что поваленному им дереву и заметил среди ветвей маленькую девочку. Она оказалась жива и почти невредима, если не считать нескольких царапин. Расспросил её добрый дровосек о том, где она живёт и отнёс её к дому, отыскать который ему не составило труда. Ведь по роду деятельности он отлично знал этот лес.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Дровосек-спаситель\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_5d1f2b60_363e_4d6d_9e1c_880abf5b94fb_0893e545_e122_46db_9b79_e253c763ca51_Return|Далее}^";
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
                --Далее
                nlbwalk(v_3); 
            end
        ),

    },
};

-- Волк не съел КШ
v_63 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("-- У нас нет соседей! -- уверенно заявила Красная Шапочка.^"..
"-- А мы недавно переехали.^"..
"-- Всё равно! Мы о вас раньше не слышали! А незнакомым двери не открываем!^"..
"^"..
"Красная Шапочка находилась дома одна, но никого не собиралась об этом ставить в известность, равно как и впускать незнакомцев.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_04c42b1f_beec_432d_b057_855d5381c12d|Далее}^";
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
                --Далее
                nlbwalk(v_147); 
            end
        ),

    },
};

-- Ест один пирожок
v_64 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Решив, что ей просто необходимо подкрепиться, мать съела один пирожок.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6956fd4d_6512_44b5_875f_8f36e4dda0a1|Далее}^";
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
                --Далее
_enough = true;
                nlbwalk(v_46); 
            end
        ),

    },
};

-- Мать несёт с яблоками
v_65 = room {
    nam = "...",
    pic = 'images/mother_road2.png',
    bgimg = function() end,
    dsc = function(s)
p("Мама говорит:^"..
"-- Сходи ка ты, Красная Шапочка, к бабушке, отнеси ей пирожки и горшочек масла да узнай, как её здоровье.^"..
"А Красная Шапочка ей и не отвечает, уснула она мёртвым сном среди пирожков, и разбудить её не было никакой возможности.^"..
"^"..
"Взяла мама корзину с пирожками и отправилась сама. День был тёплый и тихий, солнце то и дело скрывалось за проплывающими облаками. Несмотря на тяжёлую ношу, мать довольно быстро шла по тропинке. Ей хотелось как можно скорее отнести гостинцы и вернуться домой отдыхать.^"..
"^"..
"Женщина и не подозревала, что Волк вышел на её след и крадётся за ней, оценивая свои шансы и продумывая дальнейшие действия.^"..
"^"..
"Внимание матери привлёк стук топоров. Корзинка была тяжёлой, а путь неблизким и пришла ей в голову мысль угостить работающих людей пирожками, а заодно немного облегчить груз.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_edfdbfd7_0e41_4bfd_9650_7c5b1ddd43a1|Далее}^";
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
                --Далее
                nlbwalk(v_151); 
            end
        ),

    },
};

-- В лесу
v_66 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Погода была чудесная, весеннее солнце приятно согревало, щебетали птички, кое-где в лесу снег ещё оставался, но тропинка уже полностью освободилась от зимнего покрова и женщина неторопливо шагала по мягкой, но уже не вязкой почве.^"..
"^"..
"Путь был не близкий и после нескольких часов на свежем воздухе она всё острее ощущала, как к ароматам леса настойчиво примешивается запах ещё тёплых пирожков с горбушей.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c9353d8b_2711_4be5_b714_ba6fa06f6c30|Съесть один пирожок}^";
        p "{v_d23c8001_db04_46b5_813e_5aee4c20fa8a|Не есть пирожок}^";
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
                --Съесть один пирожок
                nlbwalk(v_137); 
            end
        ),
        xact(
            'v_d23c8001_db04_46b5_813e_5aee4c20fa8a',
            function(s) 
                --Не есть пирожок
                nlbwalk(v_142); 
            end
        ),

    },
};

-- Волк догоняет и съедает мать
v_67 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Подкравшись сзади к ничего не подозревающей женщине, Волк набросился на неё и съел.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Волк есть волк\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a16c48e3_f375_4112_bcd6_fa9ced63aa81_62442425_2015_4757_88c4_0ec58edf555e_Return|Далее}^";
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
                --Далее
                nlbwalk(v_5); 
            end
        ),

    },
};

-- Съела КШ пирожок, он был очень вкусным.
v_68 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("\"У меня ведь целая корзинка пирожков, если я возьму один, никто и не узнает\".^"..
"^"..
"Съела Красная Шапочка пирожок, он был очень вкусным.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_95b41a2d_27f0_4a1f_b245_ffa2dd6d10a5|Далее}^";
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
                --Далее
                nlbwalk(v_31); 
            end
        ),

    },
};

-- Идут дровосеки, видят -- дверь открыта
v_69 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Тем временем, мимо проходили дровосеки. Видят -- дверь открыта, внутри никого, только пирожки валяются. Съели они по пирожку, а остальные положили на стол, взять постеснялись, чему потом очень радовались. Дело ограничилось лёгким недомоганием.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Умение вовремя остановиться\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_bf462224_17a1_4dfc_b2f9_838ca3be35e7_01a4c786_f042_4fcd_8333_afac265f0328_Return|Далее}^";
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
                --Далее
                nlbwalk(v_8); 
            end
        ),

    },
};

-- Волк побежал домой гадить
v_70 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Тем временем Волк нашёл под кустом корзинку и, конечно же, съел всё, что там оставалось. Теперь ему была уготована та же участь, что и Красной Шапочке.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Хорошую вещь не выбросят\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_3e49d28f_b01e_4254_bc41_b73333e7d0d1_95861bf1_f46d_4b05_9673_01e48857a8e9_Return|Далее}^";
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
                --Далее
                nlbwalk(v_4); 
            end
        ),

    },
};

-- Все пируют пирожками, кроме Волка
v_71 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Заслышав где-то слева от тропинки стук топоров, Красная Шапочка побежала в ту сторону. Она очень обрадовалась дровосекам и, сбивчиво объяснив, что случилось, попросила их о помощи. Конечно же, здоровенные мужики не могли отказать в помощи маленькой девочке.^"..
"^"..
"-- Показывай дорогу! -- грозно сказал один из них.^"..
"^"..
"Задремав в домике на опушке, Волк так и не проснулся. В этом ему, безусловно, способствовали дровосеки. А бабку достали живой и невредимой, после чего всей компанией стали пить чай с пирожками.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Умение ждать\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_9339d69b_f2ff_4a3f_95ec_a5c049a3a330_7e35525f_46ee_4774_a39a_5b794054b395_Return|Далее}^";
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
                --Далее
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Дровосеки погнались
v_72 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Ну очень не хотелось Волку обходить дровосеков. Он надеялся быстренько проскользнуть мимо, но это ему не удалось. Один из мужчин его заметил.^"..
"^"..
"-- Ребята, смотрите, Волк! -- гаркнул он.^"..
"Все устремили взгляды в ту сторону, куда указывал говоривший.^"..
"-- И правда! -- отозвался другой. -- Хватай его, парни!^"..
"С этими словами дровосеки кинулись догонять хищника.^"..
"^"..
"Поняв, что его заметили, зверь бросился бежать что есть мочи. Вдруг в дерево рядом с Волком со звононм вонзился топор. Это преследователи, понимая, что добыча уходит, принялись бросать топоры, словно томагавки, правда, в цель никто так и не попал.^"..
"^"..
"Если бы Волк был человеком, наверное, он бы мысленно поблагодарил Бога за спасение. Но так как он был животным, то просто лежал под кустом с бешено бьющимся сердцем и частным, тяжёлым, дыханием.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin16)) and "{v_7855d12a_ed21_4a40_ac0e_1fe070be502a|Далее}^" or "");
        p ((( not _fin16)) and "{v_257c9f78_3e22_492c_bec3_23c352a3dcda|Далее}^" or "");
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
                --Далее
                nlbwalk(v_59); 
            end
        ),
        xact(
            'v_257c9f78_3e22_492c_bec3_23c352a3dcda',
            function(s) 
                --Далее
_fin16 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_5e992f11_270f_4264_b59d_b625a68255b0);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_5e992f11_270f_4264_b59d_b625a68255b0);
                nlbwalk(v_59); 
            end
        ),

    },
};

-- Корзинка тяжёлая, КШ шла медленно. Волк уснул
v_73 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("В это время девочка упорно продолжала движение. Корзинка была очень тяжёлая, Красная Шапочка шла медленно. А сытый Волк уже долго лежал в тёплой постели. За окнами щебетали пичуги, шуршали в траве какие-то мелкие зверьки. Вся эта мирная суета необычайно убаюкивала и Волк уснул.^"..
"^"..
"Красная Шапочка, тем временем, еле волоча ноги, приблизилась к домику бабушки. Из последних сил взобравшись на крыльцо, она почти упала на дверь. К её удивлению, та оказалась не заперта! Пыхтя и отдуваясь, Шапочка зашла в дом и, водрузив корзинку на стол, с облегчением выдохнула.^"..
"^"..
"Подойдя к постели, Красная Шапочка увидела, что бабушка спит. Но от внимания девочки не ускользнул тот факт, что у старушки из под чепца торчали огромные уши. \"Интересно, -- подумала Шапочка, -- почему у бабушки такие большие уши?\" Затем её внимание привлекли зубы. \"А зачем ей такие здоровенные зубы?\". Тут из-под одеяла выпал хвост. \"Это же Волк!!!\"^"..
"^"..
"С трудом подавив крик ужаса, Красная Шапочка постаралась выйти из дома как можно тише и опрометью бросилась в лес.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin33)) and "{v_72c80be4_da9d_41e9_8614_8135a66475d6|Далее}^" or "");
        p ((( not _fin33)) and "{v_5462989d_d2ad_48eb_ab1f_3a88a6ef617e|Далее}^" or "");
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
                --Далее
                nlbwalk(v_71); 
            end
        ),
        xact(
            'v_5462989d_d2ad_48eb_ab1f_3a88a6ef617e',
            function(s) 
                --Далее
_fin33 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_fcdc0f27_8dff_46f8_a43f_76e3ddd3e19f);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_fcdc0f27_8dff_46f8_a43f_76e3ddd3e19f);
                nlbwalk(v_71); 
            end
        ),

    },
};

-- Волк съел бабку
v_74 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Волк подошёл к избушке и постучал в дверь.^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка! -- пропел Волк как можно более высоким голосом.^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Оказавшись в доме, хищник без лишних разговоров проглотил бабку, а затем надел её ночную рубашку, очки, чепец и завалился в кровать.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin9)) and "{v_83e3280c_2a8b_4d38_812d_ba44e3600cc0|Далее}^" or "");
        p ((( not _fin9)) and "{v_2f10fb96_ac53_43a5_a693_ba4bd91a3bd6|Далее}^" or "");
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
                --Далее
                nlbwalk(v_50); 
            end
        ),
        xact(
            'v_2f10fb96_ac53_43a5_a693_ba4bd91a3bd6',
            function(s) 
                --Далее
_fin9 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_a7514b63_788d_4041_8883_b26456439ab2);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_a7514b63_788d_4041_8883_b26456439ab2);
                nlbwalk(v_50); 
            end
        ),

    },
};

-- У матери начинаются глюки
v_75 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Съем-ка я один пирожок, -- подумала она. -- Заодно хоть попробую, как они на вкус\"^"..
"С удовольствием перекусив, хозяйка отметила про себя, что выпечка удалась.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ad6e0dc2_4d84_4bfe_936b_9fead122d604|Далее}^";
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
                --Далее
                nlbwalk(v_154); 
            end
        ),

    },
};

-- волк к бабке
v_76 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Между тем голодный Волк подбирался к домику старушки. Бесшумно запрыгнув на крыльцо, зверь прислушался. Из-за двери до него доносились голоса двух женщин. По видимому, кроме них, в доме никого больше не было. Тогда хищник постучал.^"..
"^"..
"-- Кто там? -- спросила бабка.^"..
"-- Меня к вам послала ваша девочка. Откройте!");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin10)) and "{v_6567c26c_4b1a_47ef_85e6_ff769c1167ba|-- Иди лесом!}^" or "");
        p (((_fin24)) and "{v_b5fb0118_d132_4efd_be6c_8a40584e3f97|-- Дерни за верёвочку, дверь и откроется! -- говорит бабушка.}^" or "");
        p ((( not _fin10)) and "{v_0c9f7637_d9fd_4d11_b3bb_752fddbc9f49|-- Иди лесом!}^" or "");
        p ((( not _fin24)) and "{v_43fe6360_bb32_43a6_86b5_2b81ffb5fab4|-- Дерни за верёвочку, дверь и откроется! -- говорит бабушка.}^" or "");
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
                ---- Иди лесом!
                nlbwalk(v_51); 
            end
        ),
        xact(
            'v_b5fb0118_d132_4efd_be6c_8a40584e3f97',
            function(s) 
                ---- Дерни за верёвочку, дверь и откроется! -- говорит бабушка.
                nlbwalk(v_152); 
            end
        ),
        xact(
            'v_0c9f7637_d9fd_4d11_b3bb_752fddbc9f49',
            function(s) 
                ---- Иди лесом!
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
                ---- Дерни за верёвочку, дверь и откроется! -- говорит бабушка.
_fin24 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_73c938af_ddd4_474e_823d_9eeefb02c657);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_73c938af_ddd4_474e_823d_9eeefb02c657);
                nlbwalk(v_152); 
            end
        ),

    },
};

-- КШ отправилась к бабушке
v_77 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Выложили они часть пирожков и тогда девочка, наконец, отправилась к бабушке. Красная Шапочка нормально несёт лёгкую корзинку. Солнышко светит, птички поют, белки снуют, в общем, всё привычно, настроение у Шапки отличное, даже несмотря на усталость, связанную с выпечкой пирожков. Смотрит она -- а на дорожке сидит красивая бабочка.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_fad820ba_8a04_46d6_88b9_5dbceedd456a|Продолжить путь}^";
        p "{v_c93f83ca_97f5_4731_9550_3e8698779f29|Подойти к бабочке}^";
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
                --Продолжить путь
                nlbwalk(v_53); 
            end
        ),
        xact(
            'v_c93f83ca_97f5_4731_9550_3e8698779f29',
            function(s) 
                --Подойти к бабочке
                nlbwalk(v_116); 
            end
        ),

    },
};

-- Волк вежливо здоровается и просит угостить его пирожком.
v_78 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Осторожность всё-таки берёт верх и невероятным усилием воли хищнику удаётся сдержать сиюминутный порыв. Обогнав мать, он не спеша вышел на тропинку прямо перед ней. От неожиданности женщина застыла на месте, как вкопанная.^"..
"^"..
"Волк же, тем временем, медленно шагнув вперёд, с самой милой улыбкой крайне вежливо проговорил:^"..
"^"..
"-- Здравствуйте, уважаемая мадам! Прошу прощения за бесцеремонность, но запах, доносящийся из вашей корзинки, заставил меня пренебречь правилами приличия и напрямую обратиться к вам с нижайшей просьбой. Не будете ли вы столь любезны, чтобы угостить меня тем, что находится в этой прекрасной корзинке?");
    end,
    xdsc = function(s)
        p "^";
        p "{v_49cac30b_03e3_49d9_bf7e_68a33d4ff5af|Угостить Волка}^";
        p "{v_94f9f9ce_cd84_4969_9084_a2fcbb4e85a0|Не угощать Волка}^";
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
                --Угостить Волка
                nlbwalk(v_21); 
            end
        ),
        xact(
            'v_94f9f9ce_cd84_4969_9084_a2fcbb4e85a0',
            function(s) 
                --Не угощать Волка
                nlbwalk(v_36); 
            end
        ),

    },
};

-- Дровосек незаметно идёт за ней
v_79 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Прекрасно понимая, что потом найти человека будет очень сложно, мужчина решился.^"..
"^"..
"Прихватив топор, он осторожно последовал за путницей. Стараясь ступать как можно тише, мужчина незаметно двигался с правой стороны от тропинки, прячась за деревьями. Вдруг его внимательный взгляд заметил Волка. Тот крался по левую сторону от дорожки, немного опережая дровосека. Зверь был так увлечён преследованием, что даже не догадывался о присутствии ещё одного человека. Плюс ко всему, дровосек находился с подветренной стороны.^"..
"^"..
"Тем временем, мать добралась до домика бабушки. Только она открыла дверь и перешагнула через порог, как Волк кинулся за ней. Но дровосек был наготове. Используя эффект неожиданности, бросился он на Волка сзади и убил его. Хищник даже не успел осознать, что происходит, так и умер со счастливым выражением морды в предвкушении сытного обеда.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin44)) and "{v_5d132ba3_92be_467f_9eb0_4f0721352baa|Далее}^" or "");
        p ((( not _fin44)) and "{v_7e5653d0_70af_48b6_be1b_b844d44924f5|Далее}^" or "");
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
                --Далее
                nlbwalk(v_84); 
            end
        ),
        xact(
            'v_7e5653d0_70af_48b6_be1b_b844d44924f5',
            function(s) 
                --Далее
_fin44 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_fabcc368_e24c_4e1e_ae70_e877d7304e6d);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_fabcc368_e24c_4e1e_ae70_e877d7304e6d);
                nlbwalk(v_84); 
            end
        ),

    },
};

-- Волк видит совсем близко дровосеков.
v_80 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Волк помчался по короткой дороге. Пробегая через лес, хищник замечает неподалёку дровосеков.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _heavy)) and "{v_b3165eb4_e711_4e31_ade2_6164e73f2aaf|Рискнуть и пробежать мимо}^" or "");
        p "{v_fbb27ff1_c7ec_41b6_b96f_9adc3b39ce6c|Не рисковать, сделать крюк}^";
        p (((_heavy)) and "{v_0d479c15_555e_4590_9ee1_31bbf3719c10|Рискнуть и пробежать мимо}^" or "");
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
                --Рискнуть и пробежать мимо
                nlbwalk(v_95); 
            end
        ),
        xact(
            'v_fbb27ff1_c7ec_41b6_b96f_9adc3b39ce6c',
            function(s) 
                --Не рисковать, сделать крюк
                nlbwalk(v_114); 
            end
        ),
        xact(
            'v_0d479c15_555e_4590_9ee1_31bbf3719c10',
            function(s) 
                --Рискнуть и пробежать мимо
                nlbwalk(v_72); 
            end
        ),

    },
};

-- Готовит с грибами
v_81 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Яблок в этом году уродилось -- тьма! Погреб и кладовая заполнились сушёными, мочёными фруктами, а также вареньем, компотом и даже сидром. \"Может, их использовать для начинки? -- подумала хозяйка\". Но при мысли о яблоках её бросило в дрожь, ибо надоели они ей до чёртиков, разве что ещё снится не начали. И тут мать вспомнила, что старушка очень уважает грибы. На этом и остановилась.^"..
"^"..
"Проворно замесила тесто, обжарила грибки с луком и напекла румяных, ароматных пирожков. А когда они немного остыли, сложила их в корзинку...");
    end,
    xdsc = function(s)
        p "^";
        p "{v_eaefcb53_3b24_40f8_9ae8_a30da4faf2e8|...и говорит:}^";
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
                --...и говорит:
                nlbwalk(v_122); 
            end
        ),

    },
};

-- Несёт КШ пирожки с грибами
v_82 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка была послушой девочкой. Взяла она пирожки с грибами и пошла. Яркие тёплые лучи, пробиваясь сквозь листву, рождали сотни солнечных зайчиков, щебетали пташки, порхали бабочки. Красная Шапочка вприпрыжку бежала по тропинке, настроение у неё было отличное. Только вот незадача: сегодня девочка ещё не завтракала и на свежем воздухе у неё разыгрался аппетит.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f46ccb31_cdb5_42ef_96ea_0c063a7138b6|Не есть пирожок}^";
        p "{v_116ff373_916f_4199_9e1f_c892ce1ab17e|Съесть пирожок}^";
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
                --Не есть пирожок
                nlbwalk(v_102); 
            end
        ),
        xact(
            'v_116ff373_916f_4199_9e1f_c892ce1ab17e',
            function(s) 
                --Съесть пирожок
                nlbwalk(v_89); 
            end
        ),

    },
};

-- Дровосеки спешат на помощь.
v_83 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("А поблизости и вправду работали дровосеки. Услышав детский крик, они бросились в сторону тропинки. Обнаружив на дороге растрёпанную девочку, они подошли к ней и поинтересовались, что случилось.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e5375bf7_81b2_4d0e_851c_40f5acde54bc|Мама учила Красную Шапочку не разговаривать с незнакомыми}^";
        p "{v_680e22ac_66fd_4f89_8d9b_1a0141f37159|Рассказать всё дровосекам}^";
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
                --Мама учила Красную Шапочку не разговаривать с незнакомыми
                nlbwalk(v_133); 
            end
        ),
        xact(
            'v_680e22ac_66fd_4f89_8d9b_1a0141f37159',
            function(s) 
                --Рассказать всё дровосекам
                nlbwalk(v_88); 
            end
        ),

    },
};

-- Мать с бабкой принялись наперебой благодарить мужчину
v_84 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Когда к матери с бабкой вернулась способность говорить и двигаться, они принялись наперебой благодарить мужчину. Восхищённая храбростью дровосека, мать Красной Шапочки охотно согласилась на свидание.^"..
"^"..
"Вечером они встретились и, любуясь заходящим солнцем, отправились в обратный путь. Женщина предложила дровосеку остаться на ужин, чему последний весьма обрадовался.^"..
"^"..
"Познакомился дровосек и с дочерью хозяйки. С тех пор стали они часто ужинать все вместе, а через некоторое время мать с дровосеком поженились и стали жить-поживать, да добра наживать.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Кузнец своего счастья\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e81035ba_4010_445a_9bd3_b40dfbb19746_0893e545_e122_46db_9b79_e253c763ca51_Return|Далее}^";
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
                --Далее
                nlbwalk(v_3); 
            end
        ),

    },
};

-- Мать промахнулась пирожком.
v_85 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Достала женщина из корзинки пирожок, понюхала его, но поборола соблазн и бросила пирожок обратно, но промахнулась, он шлёпнулся на тропинку. Чертыхнувшись, мать отправилась дальше.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_cd1bf510_7f73_44d0_a134_96ae2dae94b1|Далее}^";
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
                --Далее
                nlbwalk(v_17); 
            end
        ),

    },
};

-- Дровосеки проводили КШ до домика бабки.
v_86 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Вскоре добралась до домика и Красная Шапочка с дровосеками.^"..
"^"..
"Тук-тук-тук: забарабанила она кулачком в дверь.^"..
"^"..
"-- Кто там?^"..
"-- Это я, твоя внучка, Красная Шапочка!^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin22)) and "{v_9506b3ee_9c9b_42a9_b22b_afd7dc42c684|Далее}^" or "");
        p ((( not _fin22)) and "{v_f683863e_2548_4395_ad5d_34571ee8def5|Далее}^" or "");
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
                --Далее
                nlbwalk(v_111); 
            end
        ),
        xact(
            'v_f683863e_2548_4395_ad5d_34571ee8def5',
            function(s) 
                --Далее
_fin22 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_6361abe3_714b_4ec7_b866_9fca662e32dc);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_6361abe3_714b_4ec7_b866_9fca662e32dc);
                nlbwalk(v_111); 
            end
        ),

    },
};

-- Шапка с бабкой раздобыли очень длинную и широкую доску
v_87 = room {
    nam = "...",
    pic = 'images/wolf_running.png',
    bgimg = function() end,
    dsc = function(s)
p("И вот однажды Шапка с бабкой раздобыли очень длинную и широкую доску и осторожно опустили её в подпол. Зверь сначала забился в угол, но потом всё понял. А старушка с девочкой легонько хлопали по доске, подбадривая Волка.^"..
"^"..
"-- Не бойся, вылезай оттуда!^"..
"Осторожно, ползком хищник выбрался наружу. Прямо перед собой он увидел открытую дверь, осторожность взяла верх и Волк рысцой выбежал из дома. Красная Шапочка с бабушкой с грустью смотрели ему вслед.^"..
"^"..
"Прежде чем скрыться в лесу, Волк напоследок оглянулся и исчез в чаще. Потом он ещё часто забегал в дом на опушке, почесать пузико.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Узник\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_72d9f91e_2027_454f_b524_88f2f4fb35d7_0402f0cb_db2e_4a41_9d64_0ba827478cc4_Return|Далее}^";
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
                --Далее
                nlbwalk(v_14); 
            end
        ),

    },
};

-- Заплакала КШ и рассказала дровосекам про Волка
v_88 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Тут Красная Шапочка дала волю слезам и пожаловалась на Волка. Тогда дровосеки решили проводить Красную Шапочку до домика бабушки, а она угостила их за это пирожками.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_4671c6d4_97d4_4397_b9de_6ccf313b0d19|Далее}^";
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
                --Далее
                nlbwalk(v_158); 
            end
        ),

    },
};

-- КШ съедает пирожок с грибами
v_89 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("\"У меня ведь целая корзинка пирожков, если я возьму один, никто и не узнает\".^"..
"^"..
"Съела Красная Шапочка пирожок, он был очень вкусным.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1bcb5676_1aeb_4134_b640_d8d65bd57ca4|Далее}^";
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
                --Далее
                nlbwalk(v_54); 
            end
        ),

    },
};

-- Открыла КШ глаза, тяжело дыша.
v_90 = room {
    nam = "...",
    pic = 'images/night.png',
    bgimg = function() end,
    dsc = function(s)
p("Открыла Красная Шапочка глаза, тяжело дыша. И долго соображала, вращая головой, где она и что происходит. На небе светила полная луна, вокруг возвышались сосны и ели, а рядом с пеньком, на котором она сидела, лежала пустая корзинка.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Страшный сон\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1d6a9e8d_04cb_41bf_a0c2_c0b89dcd7591_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Далее}^";
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
                --Далее
                nlbwalk(v_6); 
            end
        ),

    },
};

-- У волка закрутило живот
v_91 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Волк в данный момент направлялся к домику на опушке, но съеденный пирожок своим агрессивным воздействием на волчий организм кардинально изменил его планы. Бабка, между тем, голодает, но все живы и почти здоровы.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Доброе дело\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_6a154df5_e281_4267_a061_65ca6af53ffe_7e35525f_46ee_4774_a39a_5b794054b395_Return|Далее}^";
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
                --Далее
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Волк забегает и съедает. Он отравился грибами.
v_92 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Бабка помнила, что ела грузди из миски вчера... Или позавчера... Рисковать не хотелось, грибы могли испортиться, но и лезть в погреб не было ну совершенно никакого желания. Между тем, в животе заурчало, и старушка принялась поедать то, что осталось в миске.^"..
"^"..
"Волк, тем временем, подошёл к домику на опушке и постучал в дверь.^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка! -- пропел Волк как можно более высоким голосом.^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Оказавшись в доме, хищник без лишних разговоров проглотил бабку, а затем надел её ночную рубашку, очки, чепец и завалился в кровать.^"..
"^"..
"Долго ли, коротко ли, добралась Красная Шапочка до опушки. Поднявшись на крыльцо, уже занесла руку, чтобы постучать, но, к своему удивлению, заметила, что дверь не заперта. Войдя в дом, Красная Шапочка обнаружила в кровати мёртвого Волка в женской одежде и дурно пахнущую тухлыми грибами миску на столе. Бабки нигде не было видно.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Неразборчивость в еде\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c08d573e_83de_4256_a947_fe559701ffad_62442425_2015_4757_88c4_0ec58edf555e_Return|Далее}^";
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
                --Далее
                nlbwalk(v_5); 
            end
        ),

    },
};

-- Отдать как есть
v_93 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Мать с Красной Шапочкой и бабкой так и жили в своих домиках в лесу. Волк, после выпитого зелья, превратился в барсука. Сказано же было строго соблюдать дозировку! Но надо заметить, что это всё же пошло ему на пользу. Ведь при  виде такого милого зверька девушки не убегали в ужасе, как раньше от Волка, а охотно беседовали. И вскоре бывший Волк возобновил попытку с противоядием, попросив одну юную особо симпатичную путницу о помощи. На этот раз он сам внимательно следил за действиями девушки и, убедившись, что в процессе приготовления ошибки не произошло, выпил зелье.^"..
"^"..
"И вот вместо пушистого зверька перед девушкой предстал прекрасный юноша, который к тому же оказался принцем. Долго не раздумывая, поженились молодые люди и стали жить-поживать, да добра наживать.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Внимание к деталям\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_452ff4c2_a203_43ff_a069_5c0cfb4e63f5_7daf90de_cc43_429a_88ed_21011df2f00e_Return|Далее}^";
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
                --Далее
                nlbwalk(v_11); 
            end
        ),

    },
};

-- Постеснялась КШ съесть пирожок и пошла дальше
v_94 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Постеснялась Красная Шапочка съесть пирожок и пошла дальше.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e5d82ee5_0682_4a0f_b535_d1bdd08f2682|Далее}^";
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
                --Далее
                nlbwalk(v_31); 
            end
        ),

    },
};

-- Волк успешно добежал до домика
v_95 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Голодный Волк решает не менять траектории и, рискуя быть замеченным, проносится в опасной близости от работающих людей. Но для хищника всё складывается удачно, и вскоре он добирается до домика бабушки. Красной Шапочки, конечно же, ещё не видно.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_58daf7a9_95dd_4209_9195_6fe54dd12b76|Далее}^";
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
                --Далее
                nlbwalk(v_74); 
            end
        ),

    },
};

-- Мать пришла к бабушке, они пьют чай с пирожками
v_96 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Тем временем женщина уже добралась до бабки. Они сели пить чай с пирожками и разговаривать о жизни.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _chaperon_dead)) and "{v_7229405d_0925_4a31_b6f2_559d52e59891|Далее}^" or "");
        p (((_chaperon_dead and _fin23)) and "{v_625dd67f_30d4_4f9d_8c1a_d7040c963ca0|Далее}^" or "");
        p (((_chaperon_dead and not _fin23)) and "{v_cb32fa96_d92a_4a7c_bf75_3737877b24e1|Далее}^" or "");
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
                --Далее
                nlbwalk(v_76); 
            end
        ),
        xact(
            'v_625dd67f_30d4_4f9d_8c1a_d7040c963ca0',
            function(s) 
                --Далее
                nlbwalk(v_112); 
            end
        ),
        xact(
            'v_cb32fa96_d92a_4a7c_bf75_3737877b24e1',
            function(s) 
                --Далее
_fin23 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3c69590d_317c_40d9_b284_298e6fa49a35);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3c69590d_317c_40d9_b284_298e6fa49a35);
                nlbwalk(v_112); 
            end
        ),

    },
};

-- Дремавшая старушка просыпается от странного звука
v_97 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("В это время в своём домике на опушке дремавшая старушка проснулась и лежала  в кровати, собираясь с мыслями. Вдруг до её слуха донеслись странные звуки. С ужасом она поняла, что это скрежет когтей по двери.^"..
"-- Кто там?! -- дрожащим голосом спросила она.^"..
"-- УУУУУУУУУУУУУУУУУУУ!!! -- раздалось в ответ.^"..
"На мгновение всё стихло, а потом существо дёрнуло за верёвочку. Увидев, что дверь открывается, старушка в полуобморочном состоянии забилась под одеяло.^"..
"На пороге появилась мать.^"..
"-- РРРРРРРРРР!!! -- произесла она, оставила пирожки и масло, похихикала и, став на четвереньки, удалилась.^"..
"Неизвестно, сколько времени бабка пряталась под одеялом, но в итоге, набравшись смелости, она осторожно выглянула наружу. В помещении никого не было, только на полу стояла корзинка с пирожками и горшочек с маслом. Это пришлось кстати, так как от пережитого у нее разыгрался аппетит.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"У страха глаза велики\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_b97578b6_9f3a_4ea0_906c_b2eee1824506_7daf90de_cc43_429a_88ed_21011df2f00e_Return|Далее}^";
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
                --Далее
                nlbwalk(v_11); 
            end
        ),

    },
};

-- Ждать
v_98 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка справедливо рассудила, что раз отошла недалеко от тропинки, то, как только рассветёт, её легко можно будет отыскать. Залезла девочка на ель и стало ей немного спокойнее. Ждала она утра и ела пирожки.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_386420ac_74ec_40f0_b169_d8f14a50cbd6|Далее}^";
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
                --Далее
                nlbwalk(v_52); 
            end
        ),

    },
};

-- Ест несколько пирожков
v_99 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Мать съедает пирожок, но она так замёрзла и устала, что одной штучкой дело не ограничилось. Корзинка стала легче ещё на три или четыре пирожка.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ed033bdf_7aaa_4adb_b5f4_498914c2ccef|Далее}^";
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
                --Далее
                nlbwalk(v_46); 
            end
        ),

    },
};

-- Не смогли защититься бабушка и КШ и Волк их съел
v_100 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Хищник действовал быстро и уверенно. Старушка только успела схватиться за сердце, девочка -- зажмуриться от страха, как всё было кончено. Не смогли защититься бабушка и Красная Шапочка и Волк их съел.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Чёрная неблагодарность\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_02032f25_ad5b_4a12_b60a_6d337b54ef80_8f127e94_d289_456e_896a_dd397aa32341_Return|Далее}^";
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
                --Далее
                nlbwalk(v_13); 
            end
        ),

    },
};

-- Волк незаметно проследил за матерью до домика и всех съел
v_101 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Дровосек, удивлённый и раздосадованный, схватил топор и принялся с удвоенной силой рубить деревья, не обращая внимания на смешки своих коллег.^"..
"^"..
"Мать быстро шагала по тропинке и вскоре добралась до домика бабушки. Волк, оставаясь незамеченным, всё это время следовал за женщиной. А теперь притаился за кустами, словно сжатая пружина, готовый напасть в любую секунду. Как только мать открыла дверь и перешагнула через порог, хищник в два прыжка преодолел расстояние, отделявшее его от жертвы и буквально влетел в закрывающуюся дверь. Судьба женщин была решена.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Если бы да кабы\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_093897a8_7e82_481b_9a72_4a555d8eeead_8f127e94_d289_456e_896a_dd397aa32341_Return|Далее}^";
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
                --Далее
                nlbwalk(v_13); 
            end
        ),

    },
};

-- КШ не ест пирожок
v_102 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Ответственность и честность не позволили Красной Шапочке съесть ни одной штучки. Она должна была отнести бабке все пирожки. Но вот небольшой отдых она могла себе позволить. Присела она на пенёк, находившийся в тени высокого, раскидистого дерева. Здесь оказалось прохладнее, чем на тропинке, обжигаемой яркими солнечными лучами. От ласкового тепла и лёгкого дуновения нежного ветерка Шапочка разомлела, по всему телу разлилась приятная истома. Девочка даже прикрыла глаза.^"..
"^"..
"Вдруг, откуда ни возьмись, из кустов вышел Волк. Заслышав шорох, Красная Шапочка мгновенно подскочила.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_19a74b6f_409d_4704_9e2d_8cca4723212c|Далее}^";
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
                --Далее
                nlbwalk(v_143); 
            end
        ),

    },
};

-- Стандартный конец.
v_103 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Волк быстро добрался до домика бабки и постучал в дверь.^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка! -- пропел Волк как можно более высоким голосом.^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Оказавшись в доме, хищник без лишних разговоров проглотил бабку, а затем надел её ночную рубашку, очки, чепец и завалился в кровать.^"..
"^"..
"Лёжа в тёплой кровати, Волк уже начал дремать, как вдруг в дверь постучали.^"..
"^"..
"-- Кто там? -- спросил хищник, стараясь подражать голосу старой больной женщины.^"..
"-- Это я, твоя внучка , Красная Шапочка!^"..
"-- Дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Девочка так и сделала. Волк натянул одеяло до самых глаз, только уши торчали из-под чепца. Они-то и бросились в глаза в первую очередь.^"..
"^"..
"-- Ой, бабушка, какие у тебя большие уши! -- воскликнула Красная Шапочка.^"..
"-- А это чтобы лучше слышать тебя, дитя моё.^"..
"-- А какие у тебя большие глаза!^"..
"-- А это чтобы лучше видеть тебя, дитя моё.^"..
"^"..
"Увлёкшись беседой, Волк не заметил, как одеяло сползло.^"..
"-- Ой, бабушка, зачем  тебе такие большие зубы! -- воскликнула Красная Шапочка.^"..
"-- А это чтобы съесть тебя!^"..
"^"..
"С этими словами набросился Волк на Красную Шапочку и проглотил её.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin30)) and "{v_b42ee627_238a_46cb_b765_154e0ac6f55b|Далее}^" or "");
        p ((( not _fin30)) and "{v_9c6650dd_7aa2_4d36_86d5_d56e4a854596|Далее}^" or "");
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
                --Далее
                nlbwalk(v_156); 
            end
        ),
        xact(
            'v_9c6650dd_7aa2_4d36_86d5_d56e4a854596',
            function(s) 
                --Далее
_fin30 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_48c1030c_4782_4668_a8f3_726b85e25c0d);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_48c1030c_4782_4668_a8f3_726b85e25c0d);
                nlbwalk(v_156); 
            end
        ),

    },
};

-- Лень взяла верх
v_104 = room {
    nam = "...",
    pic = 'images/granny_home.png',
    bgimg = function() end,
    dsc = function(s)
p("Подумала бабка и решила слазить в подпол за новой порцией грибов. Но через секунду уже передумала, так как лень всё-таки взяла верх, и она собралась доесть оставшиеся в миске грузди. Старушка направилась к столу, но её видавший виды мозг, не выдержав такой бурной мыслительной деятельности, отключился. На середине пути бабка застыла на месте с вытянутыми руками, которыми уже было приготовилась взять миску. Попытки вспомнить, куда же она шла, ни к чему не привели, и пожилая женщина, чертыхаясь, легла обратно в кровать.^"..
"^"..
"Волк, тем временем, подошёл к домику на опушке и постучал в дверь.^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка! -- пропел Волк как можно более высоким голосом.^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Оказавшись в доме, хищник без лишних разговоров проглотил бабку, а затем надел её ночную рубашку, очки, чепец и завалился в кровать.");
    end,
    xdsc = function(s)
        p "^";
        p (((_heavy)) and "{v_7869db0b_18f9_4c35_a84e_bc39ed09417e|Далее}^" or "");
        p ((( not _heavy and _fin9)) and "{v_c86c2e29_48a2_476f_8b97_aa2d1a6fa7d6|Далее}^" or "");
        p ((( not _heavy and not _fin9)) and "{v_65f95566_d4dc_44bb_bc20_32d848f49221|Далее}^" or "");
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
                --Далее
                nlbwalk(v_73); 
            end
        ),
        xact(
            'v_c86c2e29_48a2_476f_8b97_aa2d1a6fa7d6',
            function(s) 
                --Далее
                nlbwalk(v_50); 
            end
        ),
        xact(
            'v_65f95566_d4dc_44bb_bc20_32d848f49221',
            function(s) 
                --Далее
_fin9 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_a7514b63_788d_4041_8883_b26456439ab2);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_a7514b63_788d_4041_8883_b26456439ab2);
                nlbwalk(v_50); 
            end
        ),

    },
};

-- Рассказать про Волка по дороге
v_105 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Рассказала Красная Шапочка о встрече с Волком. Тут бабушка и говорит:^"..
"^"..
"-- Ты ещё маленькая, да, видать, пришло время взрослеть. Слишком много вокруг опасностей!^"..
"^"..
"С этими словами достала она из шкафа ружьё.^"..
"-- От деда осталось. Возьми его!^"..
"^"..
"И объяснила бабка Красной Шапочке, как заряжать и стрелять. По счастью, эта информация в её дряхлеющем мозгу ещё сохранилась.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0a4cc38f_7e0e_44d7_b6a9_e7ed8657df2c|Далее}^";
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
                --Далее
                nlbwalk(v_27); 
            end
        ),

    },
};

-- Не пойти
v_106 = room {
    nam = "...",
    pic = 'images/night.png',
    bgimg = function() end,
    dsc = function(s)
p("Осторожность взяла верх, и Красная Шапочка отказалась следовать за Волком. Зверь тяжело вздохнул. \"Совсем как человек, -- с содроганием подумала девочка\" Было в этом что-то жутковатое. А Волк с грустью произнёс:^"..
"-- Что ж, пойдём, я выведу тебя к тропинке и провожу до дому.^"..
"Если бы Красная Шапочка знала дорогу, то предпочла бы отказаться. В сложившейся ситуации ей пришлось принять предложение Волка.^"..
"^"..
"Весь путь они шли молча. А когда показался домик Шапочки, Волк ещё раз поблагодарил за еду и убежал в лес.^"..
"^"..
"Подойдя к крыльцу, девочка на мгновение остановилась и, обернувшись, долго вглядывалась в неподвижную стену деревьев, в загадочное ночное небо. Она испытывала какое-то двойственное чувство облегчения и сожаления одновременно.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Серые будни\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_9a272b2e_57c3_49f1_832e_fd41e4d02822_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Далее}^";
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
                --Далее
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Волк голоден и чует рыбу
v_107 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("В это время неподалёку бродил голодный, как всегда, Волк. Уже неделю ему не удавалось ничего раздобыть на обед. Внезапно хищник ощутил рыбный запах, донёсшийся со стороны тропинки. Волк больше любил мясо, но сейчас он был готов даже пощипать травы, если бы она уже выросла. Постоянно втягивая носом воздух, Волк осторожно подкрался к тропинке, и его сердце радостно забилось в предвкушении двойной добычи. Первым побуждением было напасть на беззащитную женщину прямо здесь и сейчас, но жизнь в лесу научила осторожности и зверь не спешил, неслышно скользя следом за жертвой. К тому же, она могла привести его к ещё более крупной добыче. Слюна капала с клыков, а в животе протяжно заныло.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin27)) and "{v_4b307aa2_10e6_42bf_a6a4_aa69bc4f657b|Выхватить пирожки немедленно!}^" or "");
        p "{v_bb5bf295_d2bb_4a8b_b27e_4e84e7f5c624|Попросить пирожки}^";
        p "{v_14d05255_eb11_4e22_91c1_95d62da166f3|Потерпеть, чтобы съесть всё и всех}^";
        p ((( not _fin27)) and "{v_a3522262_f767_4821_a2c2_b5fcb89a3b9b|Выхватить пирожки немедленно!}^" or "");
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
                --Выхватить пирожки немедленно!
                nlbwalk(v_28); 
            end
        ),
        xact(
            'v_bb5bf295_d2bb_4a8b_b27e_4e84e7f5c624',
            function(s) 
                --Попросить пирожки
                nlbwalk(v_78); 
            end
        ),
        xact(
            'v_14d05255_eb11_4e22_91c1_95d62da166f3',
            function(s) 
                --Потерпеть, чтобы съесть всё и всех
                nlbwalk(v_30); 
            end
        ),
        xact(
            'v_a3522262_f767_4821_a2c2_b5fcb89a3b9b',
            function(s) 
                --Выхватить пирожки немедленно!
_fin27 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3a6c8cf7_a3ae_4cdb_b5e3_d179e198efd1);
                nlbwalk(v_28); 
            end
        ),

    },
};

-- КШ зовёт дровосеков на помощь
v_108 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Корзинка была очень тяжёлая, Красная Шапочка шла медленно. Волк уснул. Тем временем девочка дотащилась до домика, а там спит волк!!! Она оставила корзинку и побежала за помощью к дровосекам. Те пришли, прогнали волка, достали бабку из погреба. Все стали пить чай с пирожками, кроме волка.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Награда за труд\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0380f78b_8bf6_4024_85e5_551d19cce6b9_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Далее}^";
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
                --Далее
                nlbwalk(v_6); 
            end
        ),

    },
};

-- КШ берёт рыбу
v_109 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("\"Возьму один пирожок, -- решила Красная Шапочка, -- никто и не заметит\".^"..
"^"..
"С этой мыслью бросилась она к столу, как коршун на добычу, схватила пирожок и залезла обратно на печку.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_2b59668a_42bf_4662_9bb4_816428b13344|Далее}^";
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
                --Далее
                nlbwalk(v_22); 
            end
        ),

    },
};

-- По туалетам 2
v_110 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Тем временем волк, как всегда рыскавший по лесу в поисках добычи, нашёл пирожки и все их съел, не раздумывая. Одновременно с этим он ощущал в воздухе запах более крупной добычи и имел намерение отправиться по следу жертвы, так как пирожками только заморил червячка, как говорится, но коварные изделия домашней кулинарии быстро дали о себе знать и ему стало уже не до этого.^"..
"^"..
"Короче, все по туалетам. Только бабку и Шапку пронесло (в хорошем смысле).^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Бесплатный сыр 2\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0e9196e9_fddb_4922_bed6_63635b4e228f_9c9415fd_615e_463f_aafb_d84df08388a0_Return|Далее}^";
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
                --Далее
                nlbwalk(v_10); 
            end
        ),

    },
};

-- Убили дровосеки Волка, достали бабку
v_111 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Увидев Красную Шапочку, Волк осклабился, но следом вошли здоровенные мужики с топорами. Волка прошиб холодный пот, он не шелохнулся, бежать было поздно и некуда. Убили дровосеки Волка, достали бабку, но уже скончалась она от сердечного приступа: шуточное ли дело -- побывать в пузе у Волка.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Дровосеки спешат на помощь\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_46358225_d765_41e3_aef8_7cc3a16bfc1c_8f127e94_d289_456e_896a_dd397aa32341_Return|Далее}^";
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
                --Далее
                nlbwalk(v_13); 
            end
        ),

    },
};

-- Допили они чай
v_112 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Допили они чай, а после мать переложила оставшиеся пирожки из корзинки в миску, горшочек с маслом спустила в подпол на хранение и отправилась домой, чтобы успеть до темноты.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Не открывать чужакам\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f3bb8831_9d3d_4ba7_91b7_4ce0e5b4f2b6_69cd655a_1111_42b7_9bbe_057df356d037_Return|Далее}^";
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
                --Далее
                nlbwalk(v_12); 
            end
        ),

    },
};

-- Всех съесть
v_113 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("Хищник постучал в дверь.^"..
"-- Кто там?^"..
"-- Я твоя внучка, Красная Шапочка!^"..
"-- Но Красная Шапочка здесь уже! -- говорит бабка.^"..
"-- Ну тогда я мать Красной Шапочки!^"..
"-- А, ну так бы сразу и сказала! Дёрни за верёвочку, дверь и откроется!^"..
"Красная Шапочка только успела открыть рот от удивления, как Волк ворвался в дом.");
    end,
    xdsc = function(s)
        p "^";
        p (((_tell_about_wolf and not _fin3)) and "{v_fc6daecb_1e6d_4805_8d07_4d79adddae40|Далее}^" or "");
        p ((( not _tell_about_wolf and _fin14)) and "{v_87112e63_dd2f_4997_a291_64176b29fc1b|Далее}^" or "");
        p (((_tell_about_wolf and _fin3)) and "{v_f25809b3_2163_4956_b39b_c3b9f9003989|Далее}^" or "");
        p ((( not _tell_about_wolf and not _fin14)) and "{v_219a06d5_9124_42a3_acda_78549fe345ed|Далее}^" or "");
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
                --Далее
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
                --Далее
                nlbwalk(v_100); 
            end
        ),
        xact(
            'v_f25809b3_2163_4956_b39b_c3b9f9003989',
            function(s) 
                --Далее
                nlbwalk(v_45); 
            end
        ),
        xact(
            'v_219a06d5_9124_42a3_acda_78549fe345ed',
            function(s) 
                --Далее
_fin14 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_24c04782_6e96_4f13_a00e_9487be05bdcf);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_24c04782_6e96_4f13_a00e_9487be05bdcf);
                nlbwalk(v_100); 
            end
        ),

    },
};

-- Старушка зверски проголодалась и решает съесть солёных грибов
v_114 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Всё-таки Волк решил сделать крюк и не испытывать судьбу.^"..
"^"..
"Тем временем, в своём домике на опушке старушка зверски проголодалась.  Захотелось ей солёных грибков.^"..
"^"..
"Вообще-то, банки с груздями хранились в погребе. Но на столе стояла миска, в которой находилось несколько штук.");
    end,
    xdsc = function(s)
        p "^";
        p (((_butterfly)) and "{v_62b21db6_af68_4bb0_86d5_b07d1b6f4895|Взять свежих грибов}^" or "");
        p ((( not _butterfly)) and "{v_9d3cb3f3_02da_4a9c_b600_c1802e8989ca|Полезть за грибами в погреб}^" or "");
        p (((_fin7)) and "{v_773e0cc4_24ea_4338_a9eb_f4d2736846ce|Бабка поленилась достать грибы из погреба и съедает те, которые стоят на столе с позавчерашнего дня}^" or "");
        p "{v_acfad543_4433_4f50_92dd_161656dc1048|Не есть пока ничего}^";
        p ((( not _fin7)) and "{v_ec14bc96_e51a_4239_897e_cd1ada5a5eaf|Бабка поленилась достать грибы из погреба и съедает те, которые стоят на столе с позавчерашнего дня}^" or "");
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
                --Взять свежих грибов
                nlbwalk(v_164); 
            end
        ),
        xact(
            'v_9d3cb3f3_02da_4a9c_b600_c1802e8989ca',
            function(s) 
                --Полезть за грибами в погреб
                nlbwalk(v_39); 
            end
        ),
        xact(
            'v_773e0cc4_24ea_4338_a9eb_f4d2736846ce',
            function(s) 
                --Бабка поленилась достать грибы из погреба и съедает те, которые стоят на столе с позавчерашнего дня
                nlbwalk(v_92); 
            end
        ),
        xact(
            'v_acfad543_4433_4f50_92dd_161656dc1048',
            function(s) 
                --Не есть пока ничего
                nlbwalk(v_104); 
            end
        ),
        xact(
            'v_ec14bc96_e51a_4239_897e_cd1ada5a5eaf',
            function(s) 
                --Бабка поленилась достать грибы из погреба и съедает те, которые стоят на столе с позавчерашнего дня
_fin7 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_656e179e_fb53_487c_8d4a_114206c96516);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_656e179e_fb53_487c_8d4a_114206c96516);
                nlbwalk(v_92); 
            end
        ),

    },
};

-- Шапка убегает домой гадить
v_115 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка продолжила путь, но уже очень скоро почуствовала себя нехорошо, а ещё через пару минут внутри так всё закрутило, что, побросав свои гостинцы, девочка помчалась обратно домой.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_977bf0c0_66f2_48ef_9d9c_bf2c8fcacb50|Далее}^";
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
                --Далее
                nlbwalk(v_125); 
            end
        ),

    },
};

-- Бабочка
v_116 = room {
    nam = "...",
    pic = 'images/butterfly.png',
    bgimg = function() end,
    dsc = function(s)
p("Полюбовалась Красная Шапочка на бабочку и пошла дальше.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1eadbf7b_9934_4f6b_b8a9_f14f2f3428b4|Продолжить путь}^";
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
                --Продолжить путь
                nlbwalk(v_53); 
            end
        ),

    },
};

-- Красная Шапочка, тем временем, еле волоча ноги, приблизилась к домику бабушки
v_117 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка, тем временем, еле волоча ноги, приблизилась к домику бабушки. Из последних сил взобравшись на крыльцо, она почти упала на дверь.^"..
"^"..
"-- Кто там? -- испуганно крикнула старушка.^"..
"-- Я, твоя внуч...^"..
"-- Дёргай верёвку и входи!^"..
"Заинтригованная тоном, не свойственным бабушке, Красная Шапочка почти вбежала в дом и чуть не провалилась в открытый люк.^"..
"^"..
"-- Бабушка, ты чего погреб-то не закрываешь?!^"..
"-- А ты посмотри, что там внизу. -- полушёпотом проговорила старушка.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f461785b_6bd7_4a3b_99c2_9fdc8586aab0|Далее}^";
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
                --Далее
                nlbwalk(v_163); 
            end
        ),

    },
};

-- КШ в ужасе отпускает корзинку.
v_118 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Похолодев от ужаса, Красная Шапочка выпускает из рук свою ношу. Волк с добычей убегает в лес. Расположившись под ближайшим кустом, он всё съедает. Пирожки оказались вкусными и очень сытными. Довольный зверь тут же устраивается отдохнуть.^"..
"^"..
"Бабка, конечно, осталась без пирожков, но с горшочком масла, который внучка всё-таки донесла. Опять же, все живы и здоровы.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Все живы и здоровы\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1d1a797c_5d57_4db3_ba64_be2ab06080c8_95861bf1_f46d_4b05_9673_01e48857a8e9_Return|Далее}^";
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
                --Далее
                nlbwalk(v_4); 
            end
        ),

    },
};

-- Обеих пронесло (в плохом смысле)
v_119 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Мать, тем временем, добирается до бабки, которая предлагает разделить с ней трапезу. Не в силах отказать пожилой женщине, мать Красной Шапочки остаётся, и они вместе едят пирожки. Бабка чувствует странный привкус, но стесняется спросить об этом из боязни обидеть хозяйку, которая старалась специально для неё.^"..
"^"..
"Мать, в свою очередь, также ощущает некий посторонний запах и вкус, но тоже не подаёт виду, стыдясь признаться, что рыба в начинке не первой свежести.^"..
"^"..
"Конец был предсказуем: обеих пронесло (в плохом смысле).^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Мать и бабка\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0e51bd75_4b34_4753_99f5_86b9d3ef1598_62442425_2015_4757_88c4_0ec58edf555e_Return|Далее}^";
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
                --Далее
                nlbwalk(v_5); 
            end
        ),

    },
};

-- Не сворачивать тяжело
v_120 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Не желая терять времени, Красная Шапочка заставила себя продолжать движение. Солнце, казалось, с каждой минутой припекало всё сильнее. Лицо девочки покраснело, во рту всё пересохло, волосы прилипли к мокрому от пота лбу. Да и пирожки на такой жаре чувствовали себя не лучше. В итоге отдых в тени стал просто жизненно необходим.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e99526ac_9b42_48f3_956d_5667c7db0f2d|Свернуть с тропинки}^";
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
                --Свернуть с тропинки
                nlbwalk(v_167); 
            end
        ),

    },
};

-- Дровосеки съели пирожок.
v_121 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Понюхал волк пирожок. Фи, грибы. И, потрусив дальше, вскоре скрылся за поворотом. А на тропинку из кустов выбрались два дровосека. Видят -- лежит на траве хороший пирожок, пахнет вкусно. Разделили они его пополам да и съели.^"..
"^"..
"-- Смотри, кажись, волчьи следы! -- вдруг воскликнул один.^"..
"-- И правда! А давай его поймаем? -- предложил другой.^"..
"На том и порешили.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin40)) and "{v_f1d83fe8_c5f4_46a5_8806_9ac73deeb08c|Далее}^" or "");
        p ((( not _fin40)) and "{v_b20e2c35_4210_4420_983d_a03b4ef137c4|Далее}^" or "");
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
                --Далее
                nlbwalk(v_35); 
            end
        ),
        xact(
            'v_b20e2c35_4210_4420_983d_a03b4ef137c4',
            function(s) 
                --Далее
_fin40 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_ea12df2a_7448_4006_86c3_0544739b6e72);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_ea12df2a_7448_4006_86c3_0544739b6e72);
                nlbwalk(v_35); 
            end
        ),

    },
};

-- Испекла мама пирожки
v_122 = room {
    nam = "...",
    pic = 'images/mother_home.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Сходи-ка ты, Красная Шапочка, к бабушке, отнеси ей эти пирожки и горшочек масла да узнай, здорова ли она.^"..
"А Красная Шапочка ей и отвечает:");
    end,
    xdsc = function(s)
        p "^";
        p (((_cabbage)) and "{v_0188e0c3_f698_4081_bbbe_3034f3c1a405|-- Лучше ты отнеси!}^" or "");
        p (((_mushroom)) and "{v_29cca1c5_a802_4516_9bde_ab39454380f5|-- Лучше ты отнеси!}^" or "");
        p (((_meat)) and "{v_e804aa3c_c788_4c66_bcfe_7dc07a04c0e2|-- Лучше ты отнеси, а то что-то я себя плохо чувствую.}^" or "");
        p (((_fish)) and "{v_252dba7e_2524_4e95_9d6c_f1b51f75bfee|-- Хорошо, мама!}^" or "");
        p (((_meat)) and "{v_1854cda3_38b0_4494_b29d_17f496630f5c|-- Хорошо, мама!}^" or "");
        p (((_cabbage)) and "{v_fbdc3c8e_127c_491a_b373_cf0aee1a213e|-- Хорошо, мама!}^" or "");
        p (((_mushroom)) and "{v_18e80db4_ec49_4d23_a1c2_c1ab75e1fef5|-- Хорошо, мама!}^" or "");
        p (((_fish)) and "{v_78f3292c_a69b_4ed5_969f_0b9185191d4c|-- Лучше ты отнеси, а то что-то я себя плохо чувствую.}^" or "");
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
                ---- Лучше ты отнеси!
_mother = true;
                nlbwalk(v_48); 
            end
        ),
        xact(
            'v_29cca1c5_a802_4516_9bde_ab39454380f5',
            function(s) 
                ---- Лучше ты отнеси!
_mother = true;
                nlbwalk(v_132); 
            end
        ),
        xact(
            'v_e804aa3c_c788_4c66_bcfe_7dc07a04c0e2',
            function(s) 
                ---- Лучше ты отнеси, а то что-то я себя плохо чувствую.
_mother = true;
                nlbwalk(v_129); 
            end
        ),
        xact(
            'v_252dba7e_2524_4e95_9d6c_f1b51f75bfee',
            function(s) 
                ---- Хорошо, мама!
_chaperon = true;
                nlbwalk(v_56); 
            end
        ),
        xact(
            'v_1854cda3_38b0_4494_b29d_17f496630f5c',
            function(s) 
                ---- Хорошо, мама!
_chaperon = true;
                nlbwalk(v_40); 
            end
        ),
        xact(
            'v_fbdc3c8e_127c_491a_b373_cf0aee1a213e',
            function(s) 
                ---- Хорошо, мама!
_chaperon = true;
                nlbwalk(v_149); 
            end
        ),
        xact(
            'v_18e80db4_ec49_4d23_a1c2_c1ab75e1fef5',
            function(s) 
                ---- Хорошо, мама!
_chaperon = true;
                nlbwalk(v_82); 
            end
        ),
        xact(
            'v_78f3292c_a69b_4ed5_969f_0b9185191d4c',
            function(s) 
                ---- Лучше ты отнеси, а то что-то я себя плохо чувствую.
_mother = true;
                nlbwalk(v_165); 
            end
        ),

    },
};

-- Мать решила просто навестить старушку и отнести масло
v_123 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Мать стояла на тропинке с горшочком масла и даже не пыталась преследовать серого разбойника, а её язык рождал отнюдь не литературные выражения.^"..
"^"..
"Пирожков больше не было, но женщина всё-таки решила продолжить путь, чтобы навестить старушку и отнести ей горшочек масла.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Волка ноги кормят\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_edfa188e_abcb_4a3b_8185_da8ffd3807c4_95861bf1_f46d_4b05_9673_01e48857a8e9_Return|Далее}^";
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
                --Далее
                nlbwalk(v_4); 
            end
        ),

    },
};

-- Съедает. У волка галлюцинации.
v_124 = room {
    nam = "...",
    pic = 'images/wolf_face2.png',
    bgimg = function() end,
    dsc = function(s)
p("Волк так хотел кушать, что съел пирог, даже несмотря на отсутствие в нём мяса. Заморив червячка, зверь рысцой побежал дальше. И снова он встречает Красную Шапочку, которая возвращалась домой!^"..
"^"..
"Заметив Волка, девочка воскликнула:^"..
"-- Здравствуй, собачка! Только не убегай, прокати до дома!^"..
"-- Полезай на спину! -- весело ответил Волк. -- только держись крепче!^"..
"^"..
"Тем временем, мать вышла на крыльцо, поглядеть, не видно ли ещё её дочери. В этот момент Шапочка подъезжала к дому верхом на Волке. От такого зрелища мать упала в обморок. Волк подошёл к женщине и, обнюхав лицо, лизнул в нос. Мать открыла глаза и, увидев склонённую волчью морду, громко завизжала. Спасаясь от неприятного звука, зверь скрылся в лесу.^"..
"^"..
"Красная Шапочка собралась было бежать следом за собачкой, но мать вовремя схватила её за руку и утащила в дом.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Почти домашнее животное\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_c5038a84_3279_4538_b080_be304f25c51e_9c9415fd_615e_463f_aafb_d84df08388a0_Return|Далее}^";
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
                --Далее
                nlbwalk(v_10); 
            end
        ),

    },
};

-- Её брошенную корзинку вскоре обнаружили дровосеки
v_125 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Её брошенную корзинку вскоре обнаружили дровосеки. Страшно проголодавшись после тяжёлого трудового дня, они всё съели и маслом запили, не задумываясь о происхождении и сроке годности изделий. Но им всё это нипочём. А вы сами попробуйте столько лет есть в лесу грязными руками, без влажных салфеток и мыла.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin4)) and "{v_15472ea2_d032_4f37_89c8_7a11a814229f|Далее}^" or "");
        p ((( not _fin4)) and "{v_a544461b_20d3_4099_8eec_4f5eea615ad8|Далее}^" or "");
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
                --Далее
                nlbwalk(v_91); 
            end
        ),
        xact(
            'v_a544461b_20d3_4099_8eec_4f5eea615ad8',
            function(s) 
                --Далее
_fin4 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_73988af5_ae18_4fdc_9a62_d2f3368dec05);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_73988af5_ae18_4fdc_9a62_d2f3368dec05);
                nlbwalk(v_91); 
            end
        ),

    },
};

-- Съела КШ несколько пирожков
v_126 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Шла Красная Шапочка по тропинке и не заметила, как один за другим съела несколько пирожков. Очень скоро её самочувствие ухудшилось. Закружилась голова, затошнило и начались спазмы в животе. Побросала она свои пожитки и кое-как, короткими перебежками, добралась до дому.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin34)) and "{v_db7330df_36dc_462e_9bb2_701e82fd7d01|Далее}^" or "");
        p ((( not _fin34)) and "{v_63962bd9_2f8e_488f_9c63_bdbc558ec065|Далее}^" or "");
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
                --Далее
                nlbwalk(v_70); 
            end
        ),
        xact(
            'v_63962bd9_2f8e_488f_9c63_bdbc558ec065',
            function(s) 
                --Далее
_fin34 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_92d89ed9_2e25_4bcc_89ee_2a98b2667f0d);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_92d89ed9_2e25_4bcc_89ee_2a98b2667f0d);
                nlbwalk(v_70); 
            end
        ),

    },
};

-- Волк дожидается шапку и съедает её. Бабка остаётся жить в погребе
v_127 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Вскоре Красная Шапочка добралась до избушки.^"..
"^"..
"Тук-тук-тук.^"..
"^"..
"-- Кто там? -- имитируя слабость в голосе, спросил Волк.^"..
"-- Это я, твоя внучка, принесла тебе пирожки и масло.^"..
"-- Сейчас открою.^"..
"^"..
"Пока Красная Шапочка входила в дом, Волк забрался обратно в постель и натянул одеяло до самого носа.^"..
"Подошла Красная Шапочка поближе и спрашивает:^"..
"^"..
"-- Бабушка, а почему у тебя такие большие уши?^"..
"-- Чтоб лучше тебя слышать...^"..
"-- А почему у тебя такие большие глаза?^"..
"-- Чтоб лучше тебя видеть...^"..
"-- А зубы отчего такие большие?^"..
"-- Это чтобы тебя съесть!^"..
"И проглотил Красную Шапочку раньше, чем до неё дошёл смысл последних слов.^"..
"^"..
"А бабка всё это время сидела в погребе и ничего не слышала. Волк убежал, а старушка питалась запасами, пока не пришла мать и не освободила её.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Счастливый несчастный случай\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_fee25b7b_5014_48a2_8a0f_f0f0ad9e0244_01a4c786_f042_4fcd_8333_afac265f0328_Return|Далее}^";
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
                --Далее
                nlbwalk(v_8); 
            end
        ),

    },
};

-- Однако, до бабушки он всё же добирается
v_128 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Кто там? -- спрашивает бабушка.^"..
"-- Волк! -- честно отвечает волк.^"..
"-- Дёргай верёвочку и заходи! -- говорит бабушка.^"..
"Как только хищник оказался в доме, пожилая женщина тут же пригласила его за стол. Волк с радостью согласился и они вместе с бабкой сели пить чай.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Мировые пирожки\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ae992734_24cc_41a4_b644_85ead3944e0c_9c9415fd_615e_463f_aafb_d84df08388a0_Return|Далее}^";
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
                --Далее
                nlbwalk(v_10); 
            end
        ),

    },
};

-- Мать несёт с мясом
v_129 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Взяла мама пирожки с мясом и пошла. В лесу нынче было прохладно, моросил дождик, тропинка вскоре размокла и идти стало тяжело. Ноги скользили и разъезжались в грязи. Вскоре мать устала и продрогла, а корзинка своей тяжестью всё больше и больше напоминала об аппетитном содержимом.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_93d87d80_c74e_4ed4_ab2c_48a7d9813471|Съесть один пирожок}^";
        p "{v_f9127a81_2322_403b_ae20_ba43f176550d|Съесть несколько пирожков}^";
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
                --Съесть один пирожок
                nlbwalk(v_64); 
            end
        ),
        xact(
            'v_f9127a81_2322_403b_ae20_ba43f176550d',
            function(s) 
                --Съесть несколько пирожков
                nlbwalk(v_99); 
            end
        ),

    },
};

-- Волк съел КШ и ушёл в лес
v_130 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Заходите! -- с этими словами Красная Шапочка отодвинула засов, даже не разузнав имя пришедшего и цель его визита.^"..
"А Волк только того и ждал. Молнией он влетел в дом. Глаза Шапочки округлились, а сердце чуть не выскочило из груди.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_41da2467_9404_47ce_84e4_66a4b686336e|Попрощаться с жизнью}^";
        p "{v_8957e2c4_1206_417b_873b_03d8b75fb113|Попытаться спастись}^";
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
                --Попрощаться с жизнью
                nlbwalk(v_136); 
            end
        ),
        xact(
            'v_8957e2c4_1206_417b_873b_03d8b75fb113',
            function(s) 
                --Попытаться спастись
                nlbwalk(v_61); 
            end
        ),

    },
};

-- Волк был очень голодный
v_131 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Волк был очень голодный, а пирожков оказалось так мало, они только раздразнили его. И зверь решил пообедать невежливой путницей. Ему не стоило большого труда выследить её.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin28)) and "{v_267d6c2a_df85_410f_a9d9_8901b1948b4e|Далее}^" or "");
        p ((( not _fin28)) and "{v_b10cb8b8_d1ff_4347_b1d6_e30f952a36c6|Далее}^" or "");
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
                --Далее
                nlbwalk(v_67); 
            end
        ),
        xact(
            'v_b10cb8b8_d1ff_4347_b1d6_e30f952a36c6',
            function(s) 
                --Далее
_fin28 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_e125ae56_b7e6_4fbe_8a26_021db59ba477);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_e125ae56_b7e6_4fbe_8a26_021db59ba477);
                nlbwalk(v_67); 
            end
        ),

    },
};

-- Мать несёт с грибами
v_132 = room {
    nam = "...",
    pic = 'images/mother_road2.png',
    bgimg = function() end,
    dsc = function(s)
p("Взяла мама пирожки с грибами и пошла. Пробыв некоторое время на свежем воздухе, женщина вспомнила, что сегодня ещё не завтракала.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_94094b17_3528_45a5_bbca_21f98ee26507|Съесть один пирожок}^";
        p "{v_94dee053_1640_4a57_a35c_13884356a62c|Не есть пирожки}^";
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
                --Съесть один пирожок
                nlbwalk(v_75); 
            end
        ),
        xact(
            'v_94dee053_1640_4a57_a35c_13884356a62c',
            function(s) 
                --Не есть пирожки
                nlbwalk(v_85); 
            end
        ),

    },
};

-- Не стала КШ разговаривать с дровосеками
v_133 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Рассерженная только что произошедшим инцидентом, Красная Шапочка больше не собиралась ни с кем общаться, желая как можно скорее продолжить путь.^"..
"-- Мама велела мне не разговаривать с незнакомыми! -- выпалила она и отвернулась.^"..
"Обиделись дровосеки на невоспитанную девочку и ушли обратно в лес и вскоре дружный стук топоров там возобновился.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin13)) and "{v_1de661ae_0493_4b34_8507_0a151fc8674e|Далее}^" or "");
        p ((( not _fin13)) and "{v_7a5b5f4d_6ad1_4e66_b904_ae0a9a77238f|Далее}^" or "");
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
                --Далее
                nlbwalk(v_23); 
            end
        ),
        xact(
            'v_7a5b5f4d_6ad1_4e66_b904_ae0a9a77238f',
            function(s) 
                --Далее
_fin13 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3426fafe_bb1e_4994_a692_f0d27eb12266);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3426fafe_bb1e_4994_a692_f0d27eb12266);
                nlbwalk(v_23); 
            end
        ),

    },
};

-- Волк наелся и уснул
v_134 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Устроившись под кустом, волк жадно проглотил пирожки. Наевшись, он свернулся калачиком и сладко заснул.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin38)) and "{v_87c44fa7_44a2_4e63_a5c6_c6d6371824b6|Далее}^" or "");
        p ((( not _fin38)) and "{v_9c2ab2d6_4579_4199_8f7f_c738b28553bd|Далее}^" or "");
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
                --Далее
                nlbwalk(v_123); 
            end
        ),
        xact(
            'v_9c2ab2d6_4579_4199_8f7f_c738b28553bd',
            function(s) 
                --Далее
_fin38 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_6891d2b3_b473_4032_bbeb_ae7c3f6cf1c8);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_6891d2b3_b473_4032_bbeb_ae7c3f6cf1c8);
                nlbwalk(v_123); 
            end
        ),

    },
};

-- Волк разозлился, но не стал на неё набрасываться
v_135 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Нет! -- сказала Красная Шапочка. -- Если я каждому встречному стану раздавать пирожки, то бабуле ничего не останется.^"..
"^"..
"Разозлился Волк и тут же хотел съесть Красную Шапочку вместе с пирожками, но побоялся, так как неподалёку стучали топорами дровосеки.^"..
"^"..
"Сверкнув глазами, Волк убежал кушать бабушку.");
    end,
    xdsc = function(s)
        p "^";
        p (((_no_eat_pie)) and "{v_0cfd81fd_d06f_4d85_b1e0_aab2f7ec9c0d|Далее}^" or "");
        p (((_eat_pie and _fin26)) and "{v_f3569aeb_3555_456a_b397_88fea5e8bc31|Далее}^" or "");
        p (((_eat_pie and not _fin26)) and "{v_31b1587e_5eb5_470f_ba28_db52a3ca8bcd|Далее}^" or "");
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
                --Далее
                nlbwalk(v_103); 
            end
        ),
        xact(
            'v_f3569aeb_3555_456a_b397_88fea5e8bc31',
            function(s) 
                --Далее
                nlbwalk(v_153); 
            end
        ),
        xact(
            'v_31b1587e_5eb5_470f_ba28_db52a3ca8bcd',
            function(s) 
                --Далее
_fin26 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_2a6b9f56_2b76_43c2_b9df_21c29932e0b5);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_2a6b9f56_2b76_43c2_b9df_21c29932e0b5);
                nlbwalk(v_153); 
            end
        ),

    },
};

-- Волк набросился на неё и проглотил
v_136 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Хищник двинулся в её сторону. Девочка крепко зажмурилась. Волк набросился на неё и проглотил. Насытившись, зверь вернулся в лес вздремнуть.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_573ea6ee_28a9_4385_8e0c_e4302541b892|Далее}^";
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
                --Далее
                nlbwalk(v_96); 
            end
        ),

    },
};

-- Мать ест пирожок
v_137 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Мать откинула край полотенца, взяла пирог и начала не спеша поедать. Ей показалось, что начинка имеет странноватый привкус. На секунду она перестала жевать, но пирожок был вкусный и хорошо пропечённый и она доела его до конца.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_aec23b04_28b8_4ed3_915b_2a7eb2070766|Далее}^";
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
                --Далее
                nlbwalk(v_26); 
            end
        ),

    },
};

-- Вошли они в домик, а там никого
v_138 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Не стал Волк жадничать, тем более, что девчонка была маленькая и костлявая. Не спеша, он удалился в лес.^"..
"^"..
"Вскоре добралась до домика Красная Шапочка с дровосеками.^"..
"^"..
"Тук-тук-тук: забарабанила она кулачком в дверь.^"..
"^"..
"Тишина.^"..
"^"..
"-- Отойди-ка, девочка, -- один из мужиков слегка отодвинул её в сторону и ударил в дверь своим огромным кулаком.^"..
"^"..
"Тишина.^"..
"^"..
"Стукнул тогда дровосек плечищем и вышиб дверь. Вошли они в домик, а там никого, только на полу валяется чепец, очки и разорванная сорочка.^"..
"^"..
"...А оставшиеся пирожки доели дровосеки.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Красноречивое свидетельство\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_51059e9b_953a_454e_bd3d_e48c697cf442_69cd655a_1111_42b7_9bbe_057df356d037_Return|Далее}^";
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
                --Далее
                nlbwalk(v_12); 
            end
        ),

    },
};

-- Циклические поиски
v_139 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Не побежала Красная Шапочка за бабочкой, так как уже больше суток находилась на свежем воздухе и очень устала. К тому же, она снова проголодалась.^"..
"^"..
"Заглянула девочка в корзинку, а там остался всего один пирожок. Делать было нечего, съела она его и подумала: \"И зачем же мне идти к бабушке? Пирожков-то уже нет\". Решила она повернуть домой за новой порцией выпечки.^"..
"^"..
"Долго ли, коротко ли, добралась она до избы, но там никого не оказалось. Правильно, ведь девочка отсутствовала всю ночь, хотя должна была вернуться до темноты, и мама пошла её искать^"..
"^"..
"Тем временем, мама находилась у бабушки. Там ей удалось выяснить, что дочь здесь даже не появлялась. Небезосновательно предположив, что Красная Шапочка заблудилась, женщины решили идти в лес её искать. В этот самый момент Шапочка подумала, что мама, наверное, отправилась на её поиски. Оставаться дома ей не хотелось, тем более, что пирожков здесь не оказалось. Видимо, мать забрала их с собой. Поэтому девочка побежала к дому бабушки, чтобы поскоре встретиться с родственниками. Пришла - а там никого. Тем временем, мать с бабкой прочёсывали лес.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin41)) and "{v_30867611_91d9_4e60_b4da_2178b4cc0f7c|Разделиться}^" or "");
        p "{v_ef1c0fac_4229_4725_b633_3eb1fa5580fa|Не разделяться}^";
        p ((( not _fin41)) and "{v_82766880_b4d0_4384_a6c4_f2b30272f861|Разделиться}^" or "");
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
                --Разделиться
                nlbwalk(v_37); 
            end
        ),
        xact(
            'v_ef1c0fac_4229_4725_b633_3eb1fa5580fa',
            function(s) 
                --Не разделяться
                nlbwalk(v_168); 
            end
        ),
        xact(
            'v_82766880_b4d0_4384_a6c4_f2b30272f861',
            function(s) 
                --Разделиться
_fin41 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_aea5cdb0_3765_4621_ad32_b21ec458c788);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_aea5cdb0_3765_4621_ad32_b21ec458c788);
                nlbwalk(v_37); 
            end
        ),

    },
};

-- Первое время Волк то рычал, то скулил
v_140 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Первое время Волк то рычал, то скулил, как щенок. Видимо, ударился при падении и потерял дар речи. А когда ему спускали еду, подпрыгивал и махал лапой, пытаясь схватить кормящего. В таком случае бабка обычно говорила:^"..
"-- Ну что ты такой злой? Не сердись, лучше ешь!^"..
"А Красная Шапочка ей вторила:^"..
"-- Кушай, Серенький!^"..
"Они вообще часто разговаривали с Волком. То просто рассказывали о своей жизни, то задавали ему вопросы, а потом сами же на них отвечали. Словом, всё бы ничего, если бы не один недостаток: Волк часто выл по ночам. А через некоторое время он всех очень удивил, завилял хвостом, когда ему в очередной раз принесли еду. С одной стороны, это их порадовало, а с другой огорчило. Ведь теперь появилась реальная возможность без опасений выпустить Волка в лес, а необходимость этого и бабушка, и девочка очень хорошо понимали.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin2)) and "{v_0d166553_8c69_4894_9e6f_1f4270e520b9|Далее}^" or "");
        p ((( not _fin2)) and "{v_ad474dce_c78a_4aa5_bb7e_40a214e58652|Далее}^" or "");
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
                --Далее
                nlbwalk(v_87); 
            end
        ),
        xact(
            'v_ad474dce_c78a_4aa5_bb7e_40a214e58652',
            function(s) 
                --Далее
_fin2 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_a7054201_999c_4e04_97ca_b394f2b91180);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_a7054201_999c_4e04_97ca_b394f2b91180);
                nlbwalk(v_87); 
            end
        ),

    },
};

-- Она ему нравится
v_141 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Нет-нет, не надо, я очень тороплюсь, да тут у вас полно работы!^"..
"С этими словами женщина схватила корзинку и постаралась удалиться как можно скорее. Сейчас она чувствовала, что на шуры-муры просто нет сил.^"..
"^"..
"За её спиной раздался хохот нескольких коллег неудавшегося Дон-Жуана. Дровосек, предложивший помощь, не обращая внимания на смешки, глядел вслед уходящей женщине. Она действительно чем-то очаровала его, мужчина был не робкого десятка и не привык легко сдаваться: \"Может, проследить за ней, чтобы узнать, где она живёт?\"");
    end,
    xdsc = function(s)
        p "^";
        p "{v_44ff2e99_c00e_489a_a49f_54b8e1cebe77|Да}^";
        p (((_fin15)) and "{v_8388fbb5_3aaf_4207_bbcc_44be3113f479|Нет}^" or "");
        p ((( not _fin15)) and "{v_6355009e_b99b_465c_8bb9_0a1196bdc43c|Нет}^" or "");
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
                --Да
                nlbwalk(v_79); 
            end
        ),
        xact(
            'v_8388fbb5_3aaf_4207_bbcc_44be3113f479',
            function(s) 
                --Нет
                nlbwalk(v_101); 
            end
        ),
        xact(
            'v_6355009e_b99b_465c_8bb9_0a1196bdc43c',
            function(s) 
                --Нет
_fin15 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_4648ae92_f1a8_4250_a53b_cb5259fcb592);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_4648ae92_f1a8_4250_a53b_cb5259fcb592);
                nlbwalk(v_101); 
            end
        ),

    },
};

-- Не есть пирожок
v_142 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("В животе громко заурчало, но женщина твёрдо решила: всё содержимое корзинки -- только для старушки и уверенно продолжала путь.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_66f6ab3b_1d9d_4d1b_b85b_822fba819adf|Далее}^";
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
                --Далее
                nlbwalk(v_107); 
            end
        ),

    },
};

-- -- Здравствуй, девочка...
v_143 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Здравствуй, девочка! -- начал Волк.^"..
"-- Здравствуйте, месье, -- сказала Красная Шапочка, с любопытством разглядывая собеседника.^"..
"-- Как тебя зовут и куда ты идёшь одна, -- продолжал Волк, сделав акцент на слове \"одна\".^"..
"-- Меня зовут Красная Шапочка, и я иду к бабушке, несу ей пирожки и горшочек масла.^"..
"-- А меня Волк. А где живёт твоя бабушка?^"..
"-- Надо идти прямо по этой тропинке до опушки, там и будет домик моей бабушки.^"..
"^"..
"Получив всю необходимую информацию, зверь тут же отправился по указанному адресу, чтобы оказаться там раньше девочки. А она, поправив шапочку, взяла гостинцы и не спеша побрела к бабке.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_d9d72ed8_35f8_407b_b491_a25a3b388039|Далее}^";
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
                --Далее
                nlbwalk(v_41); 
            end
        ),

    },
};

-- По туалетам 1
v_144 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Тем временем волк, как всегда рыскавший по лесу в поисках добычи, нашёл пирожки и все их съел, не раздумывая. Одновременно с этим он ощущал в воздухе запах более крупной добычи и имел намерение отправиться по следу жертвы, так как пирожками только заморил червячка, как говорится, но коварные изделия домашней кулинарии быстро дали о себе знать и ему стало уже не до этого.^"..
"^"..
"Короче, все по туалетам. Только бабку пронесло (в хорошем смысле).^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Бесплатный сыр\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f1b2e052_6b31_4d6c_adf1_8c694be0548e_05f716c9_c5b4_48e0_9823_ec198ce37f9d_Return|Далее}^";
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
                --Далее
                nlbwalk(v_6); 
            end
        ),

    },
};

-- Прошло семь лет
v_145 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Прошло семь лет. В один прекрасный день подъехал к дому Красной Шапочки и её матери импортный жеребец. Слез оттуда принц красоты невиданной, что был волк зачарованный ранее. Попросил что-нибудь покушать для поддержания разговора.^"..
"Покормили они его и жеребца.^"..
"К этому времени Красная Шапочка превратилась в прелестную девушку. Пока принц пил чай, Красная Шапочка с любопытством его разглядывала. Что-то в нём казалось ей очень знакомым.^"..
"Внезапно принц сказал:^"..
"-- Выходи за меня замуж!^"..
"И посмотрел ей прямо в глаза. Глаза принца были ярко-голубыми. И тут Красная Шапочка вспомнила, где видела эти глаза.^"..
"Вскоре они поженились и были счастливы.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Счастливый конец 2\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_76910cb3_98aa_452f_87c2_c6b6aba042f9_0402f0cb_db2e_4a41_9d64_0ba827478cc4_Return|Далее}^";
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
                --Далее
                nlbwalk(v_14); 
            end
        ),

    },
};

-- КШ съедает пирожок с грибами 2
v_146 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("Жалея, что собачка убежала, Шапочка, тем не менее, продолжила путь. Теперь ей казалось, будто дорожка наподобие качелей болтается из стороны в сторону. Вследствие этого девочка двигалась зигзагообразно, при этом сильно махая корзинкой, и не заметила, как выронила несколько пирожков. Несмотря на сложности, постоянно возникавшие в пути, Шапочка добралась до бабки.^"..
"^"..
"-- Кто там? -- спросила старушка слабым голосом.^"..
"-- Это я Шапочка, Красная Шапочка.^"..
"-- Дёрни, деточка, за верёвочку, дверь и откроется!^"..
"-- За какую именно? -- уточнила девочка, заметив кучу свисающих верёвочек.^"..
"От этого вопроса старушка зависла. Красная Шапочка, однако не растерялась, перепробовав все, она, наконец, нашла нужную.^"..
"^"..
"Зайдя в дом, Шапочка поставила горшочек масла на стол, а корзинку подала бабке. Та почему-то взяла её зубами. От этого зрелища девочка рассмеялась, после чего удалилась, продолжая хихикать. Старушка удивилась поведению внучки, но вкус пирожков, которые, к тому же, оказались с её любимой начинкой, тут же заставил её забыть обо всём прочем.^"..
"^"..
"Тем временем, Волк, мучимый голодом, корил себя за то, что, поддавшись эмоциям, упустил лёгкую добычу. Решил он вернуться к тому месту, где встретил девочку и попытаться выследить её по запаху. Следуя по тропинке, зверь вскоре наткнулся на обронённый пирожок.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin39)) and "{v_19ef678b_f2ee_4e57_8746_057c0050b5db|Съесть пирожок}^" or "");
        p "{v_a8dd4763_27b8_415f_a644_d4e6f5f290dd|Не есть пирожок}^";
        p ((( not _fin39)) and "{v_9f53a56b_5d27_4b8a_93f1_97ff9819f812|Съесть пирожок}^" or "");
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
                --Съесть пирожок
                nlbwalk(v_124); 
            end
        ),
        xact(
            'v_a8dd4763_27b8_415f_a644_d4e6f5f290dd',
            function(s) 
                --Не есть пирожок
                nlbwalk(v_121); 
            end
        ),
        xact(
            'v_9f53a56b_5d27_4b8a_93f1_97ff9819f812',
            function(s) 
                --Съесть пирожок
_fin39 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_e6095f38_6e10_420d_a50b_8113e19b5c02);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_e6095f38_6e10_420d_a50b_8113e19b5c02);
                nlbwalk(v_124); 
            end
        ),

    },
};

-- Волк голоден и решает догнать мать
v_147 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Волк был вынужден ретироваться ни с чем. Усиливающийся голод заставил его рискнуть и броситься в погоню за матерью.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_5b298f3a_92c7_45bc_9559_0500a6867964|Далее}^";
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
                --Далее
                nlbwalk(v_96); 
            end
        ),

    },
};

-- КШ угощает Волка парой пирожков.
v_148 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка взглянула на Волка: с промокшей шерсти капает вода, лапы и пузо, почти прилипшее к спине, в грязи. Стало ей его жалко. Достала девочка несколько пирожков и положила их на камень у тропинки, а сама побрела дальше.^"..
"^"..
"-- Спасибо, девочка! -- не забыл поблагодарить Волк и принялся с наслаждением есть угощение.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0a7511c4_c728_430e_9dba_fcbaa35796e4|Далее}^";
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
                --Далее
                nlbwalk(v_47); 
            end
        ),

    },
};

-- КШ несёт с капустой
v_149 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка медленно брела по тропинке. Погода выдалась хорошая, даже слишком. Жаркие солнечные лучи раскалили воздух, и все звери и птицы куда-то попрятались. Девочке тоже захотелось отдохнуть в тени, так как она шла уже довольно долго по душному лесу.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_0c7296db_6eea_4244_a3af_dfa03df51421|Не сворачивать с тропинки}^";
        p "{v_b75ac5dd_968b_4b28_a48d_1a1825d56aef|Свернуть с тропинки}^";
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
                --Не сворачивать с тропинки
                nlbwalk(v_120); 
            end
        ),
        xact(
            'v_b75ac5dd_968b_4b28_a48d_1a1825d56aef',
            function(s) 
                --Свернуть с тропинки
                nlbwalk(v_167); 
            end
        ),

    },
};

-- Ой, какая собачка
v_150 = room {
    nam = "...",
    pic = 'images/mushrooms.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Ой, какая собачка! -- воскликнула она и, подбежав к хищнику, потрепала его за уши, после чего попыталась залезть на спину со словами:^"..
"-- Подвези до бабушки!^"..
"^"..
"Это было уже слишком! Шокированный Волк вырвался из рук Красной Шапочки и, убегая в лес, думал о том, что дети нынче пошли какие-то бешеные.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a1026387_f735_4fdb_b666_04ff4a3f1a9f|Далее}^";
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
                --Далее
                nlbwalk(v_146); 
            end
        ),

    },
};

-- Дровосеки
v_151 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Свернула она с тропинки и направилась в ту сторону, откуда раздавались звуки.^"..
"^"..
"Вскоре среди деревьев замелькали фигуры мужчин. Заметив приближающуюся к ним женщину, дровосеки перестали рубить деревья, а один из них пошёл навстречу путнице и, взяв корзинку из её рук, предложил немного отдохнуть на большом пне, который остался от только что поваленного дуба.^"..
"^"..
"Немного отдышавшись, мать произнесла:^"..
"-- Добрый день, дровосеки! Тяжёлая у вас работа, много сил отнимает. Вот, подкрепитесь пирожками.^"..
"С этими словами женщина убрала с корзинки полотенце и уже более громким голосом, как бы призывая рабочих не стесняться, сказала:^"..
"-- Угощайтесь, пожалуйста, пирожками, они свежие!^"..
"^"..
"Мать была хорошей хозяйкой, к тому же ещё не старой, вполне привлекательной женщиной, что не укрылось от глаз одного из мужчин. Жуя вкусный пирожок, он с интересом разглядывал путницу. Когда женщина засобиралась, мужчина мягко, но решительно обратился к ней:^"..
"-- Позвольте мне проводить вас, я помогу донести тяжелую корзину. А ещё в этом лесу водятся волки...");
    end,
    xdsc = function(s)
        p "^";
        p "{v_ed2bca85_a57c_4bda_be09_024a6eef4583|Согласиться}^";
        p "{v_57264032_2028_4c72_9c3d_cf13677501e8|Отказаться}^";
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
                --Согласиться
                nlbwalk(v_161); 
            end
        ),
        xact(
            'v_57264032_2028_4c72_9c3d_cf13677501e8',
            function(s) 
                --Отказаться
                nlbwalk(v_141); 
            end
        ),

    },
};

-- Волк ворвался и съел их обеих. 
v_152 = room {
    nam = "...",
    pic = 'images/wolf_inside.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Дерни за верёвочку, две... -- начала бабка.^"..
"-- НЕЕЕЕЕЕТ! -- было последнее, что успела крикнуть мать.^"..
"^"..
"А Волк уже схватил зубами верёвку, потянул её вниз и, ворвавшись в дом, съел обеих.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Святая простота\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_f7ea20e4_37c4_4aeb_8671_aeeafa32f5ed_01a4c786_f042_4fcd_8333_afac265f0328_Return|Далее}^";
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
                --Далее
                nlbwalk(v_8); 
            end
        ),

    },
};

-- У КШ закрутило живот
v_153 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Вскоре у Красной Шапочки закрутило живот. Она мужественно пыталась продолжить путь, но вскоре поняла, что это бесполезно и бегом побежала назад.^"..
"^"..
"Волк, тем временем, подошёл к домику бабки и постучал в дверь.^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка! -- пропел Волк как можно более высоким голосом.^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Оказавшись в доме, хищник без лишних разговоров проглотил бабку, а затем надел её ночную рубашку, очки, чепец и завалился в кровать. Лежал он, как дурак, ждал Красную Шапочку, а она в это время находилась дома со всеми симптомами пищевого отравления.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Счастливое совпадение\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_be00baba_d8e4_498f_a8f8_221a906e552c_01a4c786_f042_4fcd_8333_afac265f0328_Return|Далее}^";
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
                --Далее
                nlbwalk(v_8); 
            end
        ),

    },
};

-- Мать добирается до домика старушки
v_154 = room {
    nam = "...",
    pic = 'images/woodcut_mushroom.png',
    bgimg = function() end,
    dsc = function(s)
p("Неторопливо продолжая свой путь, мать наслаждалась ярким солнцем, тёплым ветром, зелёной листвой. Между тем, одна удивительная особенность привлекла её внимание. Вдоль тропинки всё чаще стали попадаться грибы. С каждым шагом их становилось всё больше. А некоторые из них прямо на глазах стали увеличиваться в размерах. Их ножки становились толстыми, как стволы деревьев, а шляпки закрывали собой почти всё небо. Мать вся сжалась от ужаса, но продолжала двигаться вперёд.^"..
"^"..
"Вдруг из леса вышли дровосеки, почему-то все без одежды и, облепив ножку гриба, словно муравьи, принялись его рубить. Некоторое время женщина стыдливо поглядывала на дровосеков, но когда подрубленный ими гигантский гриб начал падать прямо на дорожку, истошно закричала и бросилась бежать что есть мочи.^"..
"^"..
"Грибы остались позади, но теперь боковым зрением мать заметила, как что-то серое и мохнатое мелькает слева и справа среди кустов. Леденящий ужас сковал её сердце, ноги, будто отлитые из свинца, плохо повиновались. Превозмогая усталость, женщина всё же не сбавляла скорости, пока, наконец, не оторвалась от преследователей.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin12)) and "{v_e99eda17_9964_48cb_8d76_1d68af17c1c5|Далее}^" or "");
        p ((( not _fin12)) and "{v_93871d3b_1222_47e9_802d_ce37bd833910|Далее}^" or "");
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
                --Далее
                nlbwalk(v_97); 
            end
        ),
        xact(
            'v_93871d3b_1222_47e9_802d_ce37bd833910',
            function(s) 
                --Далее
_fin12 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_dc8c679b_ea76_4c55_a987_3cc212268c0c);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_dc8c679b_ea76_4c55_a987_3cc212268c0c);
                nlbwalk(v_97); 
            end
        ),

    },
};

-- Терпеть
v_155 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Но, наученная горьким опытом, Шапочка больше не поддавалось слабостям. Мужественно терпела она голод и шла по тропинке. Там все трое вскоре и встретились.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Терпение\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_3b027cf4_6e30_4177_a110_ba81c6d4d3b9_0893e545_e122_46db_9b79_e253c763ca51_Return|Далее}^";
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
                --Далее
                nlbwalk(v_3); 
            end
        ),

    },
};

-- Пришли дровосеки и всех спасли
v_156 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("В это время мимо проходили дровосеки. Услышали они шум в доме и решили посмотреть, в чём дело.^"..
"^"..
"Увидев Волка с огромным пузом, дровосеки всё поняли, зарубили Волка и спасли Красную Шапочку и её бабушку.^"..
"^"..
"Пирожки отдали дровосекам в благодарность.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Классическое завершение\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_70aacf8a_78f1_4923_b886_821f74fd921a_7e35525f_46ee_4774_a39a_5b794054b395_Return|Далее}^";
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
                --Далее
                nlbwalk(v_7); 
            end
        ),

    },
};

-- Решила она идти наугад.
v_157 = room {
    nam = "...",
    pic = 'images/wolf_night.png',
    bgimg = function() end,
    dsc = function(s)
p("От мысли, что придётся идти ночью по лесу одной, у Шапочки похолодело внутри. Но оставаться на месте было ещё страшнее и решила она двигаться наугад. Шла она, шла, а дорожка всё не появлялась. Красная Шапочка напряжённо всматривалась в темноту. А заслышав малейший шорох, резко оглядывалась, но продолжала движение.^"..
"^"..
"Вскоре девочке всё же пришлось признаться самой себе, что она окончательно заблудилась. Ей стало страшно. Она посмотрела на небо. Оно было угольно-чёрным, ни единой звёздочки. Вдруг сзади хрустнула веточка. Мгновенно обернувшись, девочка похолодела от ужаса. В кустах горели два голубых огонька. Сердце колотилось, как бешеное, ладони вспотели, а колени предательски задрожали. В голове будто кто-то орал: \"беги, беги!\", но ноги отказывались повиноваться. Застыв на месте, девочка ждала, что будет дальше. Между тем, существо не спеша появилось из-за кустов. Красная Шапочка могла различить лишь большой тёмный силуэт, но внезапно луна вышла из-за туч и в её свете Шапочка увидела огромного чёрного Волка. Она мысленно попрощалась с жизнью.^"..
"^"..
"Неожиданно Волк мягким, спокойным голосом произнёс:^"..
"-- Здравствуй, девочка. Не бойся меня, я тебя не обижу. Лучше скажи, почему ты одна в лесу, да ещё ночью?^"..
"Собрав в кулак остатки мужества, Шапочка промолвила:^"..
"-- Я заблудилась.^"..
"-- Ну, это поправимо, -- сказал Волк, разглядывая Красную Шапочку.^"..
"^"..
"Но тут его взгляд замер на корзинке.^"..
"-- А нет ли у тебя чего-нибудь покушать? -- склонив голову набок, поинтересовался Волк и посмотрел девочке прямо в глаза.^"..
"От этих слов Красная Шапочка чуть не потеряла сознание, так как прекрасно понимала, что волки не едят капусту. И, тем не менее, будучи доброй и нежадной, она автоматически поставила корзинку на землю, а затем, отойдя в сторону, прошептала:^"..
"-- Только это...^"..
"К её удивлению, Волк с аппетитом всё съел. После чего поблагодарил за угощение и попросил пойти с ним, чтобы помочь в одном деле.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_e7b1a6b7_a143_4a30_ae95_74988409b10a|Пойти с ним}^";
        p (((_fin17)) and "{v_fb4b84d6_6ac8_4353_a48e_a5905094130b|Не идти с ним}^" or "");
        p ((( not _fin17)) and "{v_9c06069c_9e6b_4ec0_89a8_3da95810a556|Не идти с ним}^" or "");
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
                --Пойти с ним
                nlbwalk(v_43); 
            end
        ),
        xact(
            'v_fb4b84d6_6ac8_4353_a48e_a5905094130b',
            function(s) 
                --Не идти с ним
                nlbwalk(v_106); 
            end
        ),
        xact(
            'v_9c06069c_9e6b_4ec0_89a8_3da95810a556',
            function(s) 
                --Не идти с ним
_fin17 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_3ae758b8_ba5f_4d84_8e5f_d2b2b29d54ad);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_3ae758b8_ba5f_4d84_8e5f_d2b2b29d54ad);
                nlbwalk(v_106); 
            end
        ),

    },
};

-- Почти стандартный конец
v_158 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Волк, тем временем, бежал, бежал по лесу и сам не заметил, как оказался на опушке. Неподалёку виднелось какое-то строение.^"..
"\"Наверное, здесь и живёт бабушка красной шапочки, -- догадался серый хищник\".^"..
"^"..
"Подошёл он к двери, прислушался. Ни звука. Поразмыслив несколько секунд, всё-таки решился и постучал.^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка! -- пропел Волк как можно более высоким голосом.^"..
"-- Ааа, дёрни, деточка, за верёвочку, дверь и откроется!^"..
"^"..
"Оказавшись внутри, Волк бросился на бабку и проглотил.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin11)) and "{v_8aa7f88f_8cad_452f_9866_c75cdab53fa7|Уйти спать в лес после сытного обеда}^" or "");
        p ((( not _fin11)) and "{v_d6d5ed03_49b4_4bf2_abfe_21bb26cfbd63|Уйти спать в лес после сытного обеда}^" or "");
        p "{v_141787e2_433a_45f3_8d32_280a35a72bf7|Остаться ждать Красную Шапочку}^";
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
                --Уйти спать в лес после сытного обеда
                nlbwalk(v_138); 
            end
        ),
        xact(
            'v_d6d5ed03_49b4_4bf2_abfe_21bb26cfbd63',
            function(s) 
                --Уйти спать в лес после сытного обеда
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
                --Остаться ждать Красную Шапочку
                nlbwalk(v_86); 
            end
        ),

    },
};

-- Волк съел бабку
v_159 = room {
    nam = "...",
    pic = 'images/pastie.png',
    bgimg = function() end,
    dsc = function(s)
p("Вспомнив сочувствующий взгяд Красной Шапочки и угощение, Волк решил подождать, пока она покинет домик, а потом съесть бабку. Что поделать, парой пирожков долго сыт не будешь.^"..
"^"..
"Прячась за деревьями, хищник терпеливо ждал. Когда Красная Шапочка, наконец, покинула сей приют и удалилась на достаточное расстояние, Волк постучал в дверь:^"..
"^"..
"-- Кто там? -- раздался слабый голос.^"..
"-- Это я, твоя внучка, Красная Шапочка!^"..
"^"..
"Бабка была уверена, что недавно её навещали, но из-за прогрессирующего склероза точно не припоминала, насколько давно это было.^"..
"^"..
"-- Дёрни, деточка, за верёвочку, дверь и откроется! -- наконец, проговорила она.^"..
"^"..
"Волк действовал молниеносно. Старушка даже толком не успела ничего осознать, как хищник её проглотил.^"..
"^"..
"^"..
"^"..
"Достигнута концовка:^"..
"\"Выгодное вложение\".");
    end,
    xdsc = function(s)
        p "^";
        p "{v_2ae29898_d43f_4e89_af49_7ea1362be11e_69cd655a_1111_42b7_9bbe_057df356d037_Return|Далее}^";
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
                --Далее
                nlbwalk(v_12); 
            end
        ),

    },
};

-- Ночь
v_160 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Проснулась она уже в ночи оттого, что всё тело затекло. Спросонья девочка не сразу сообразила, где она и что происходит, но постепенно, восстановив в памяти последние события, поняла, что пролежала под деревом до темноты. Начав оглядываться по сторонам в поисках тропинки, она ощутила, как внутри что-то ёкнуло от страха. В сгустившейся мгле сложно было что-либо различить. Девочка не представляла, в какую сторону ей двигаться дальше.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_23efc4ff_de8b_401e_b23a_47711a04b863|Идти наугад}^";
        p "{v_694d770c_b5d4_44b5_93c3_f36c9a67c635|Подождать, пока рассветёт}^";
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
                --Идти наугад
                nlbwalk(v_157); 
            end
        ),
        xact(
            'v_694d770c_b5d4_44b5_93c3_f36c9a67c635',
            function(s) 
                --Подождать, пока рассветёт
                nlbwalk(v_98); 
            end
        ),

    },
};

-- Мать с дровосеком приходят к бабке
v_161 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("-- Ой, правда! -- воскликнула усталая хозяйка. -- Спасибо большое!^"..
"Остальные дровосеки, переглянувшись и хмыкнув несколько раз, вернулись к работе. А мать с дровосеком отправились дальше вдвоём.^"..
"^"..
"По дороге они беседовали о том о сём и очень понравились друг другу. Так за разговорами не заметили они, как добрались до домика бабушки.^"..
"^"..
"Убедившись, что женщина оказалась внутри строения и заперла за собой дверь, мужчина удалился обратно в лес.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_1482ed83_243e_45c1_9a05_8d8faeab10ae|Далее}^";
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
                --Далее
                nlbwalk(v_33); 
            end
        ),

    },
};

-- Хватит жрать!
v_162 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Но Волк не стал жадничать. Он ведь Волк, а не свинья.^"..
"^"..
"Переваливаясь, Волк уходит.");
    end,
    xdsc = function(s)
        p "^";
        p (((_fin32)) and "{v_c94108a0_6437_4e37_ba18_a163db0be9f6|Далее}^" or "");
        p ((( not _fin32)) and "{v_9f4afff2_7364_4ae3_9c76_fda4f2ab3fa2|Далее}^" or "");
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
                --Далее
                nlbwalk(v_69); 
            end
        ),
        xact(
            'v_9f4afff2_7364_4ae3_9c76_fda4f2ab3fa2',
            function(s) 
                --Далее
_fin32 = true;
    _endingsCount = _endingsCount + 1;
                objs(v_dbd4c0f7_1988_4983_ac34_e21e290df0d8):del(v_7b3b988d_52e0_4719_b297_a9bee3e674df);
                addf(v_fa64f44d_2a75_444c_9f2d_9eee18bdded0, v_7b3b988d_52e0_4719_b297_a9bee3e674df);
                nlbwalk(v_69); 
            end
        ),

    },
};

-- Волк в подполе
v_163 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Девочка осторожно подошла к краю люка и глянула вниз. Там в полумраке горели два зелёных огонька.^"..
"-- Они двигаются! -- воскликнула Красная Шапочка. -- Что это?^"..
"-- В-о-л-к! -- округлив глаза, ответила бабка и рассказала, как всё произошло.^"..
"Начали они думать и гадать, как поступить. Хотели сначала позвать дровосеков, но потом пожалели они Волка и решили его оставить. Стали они спускать в подпол вёдра с водой и едой.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_5907027d_83de_415b_80a4_f3c659e45b45|Далее}^";
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
                --Далее
                nlbwalk(v_140); 
            end
        ),

    },
};

-- Решила старушка слазить в подпол за новой порцией грибов
v_164 = room {
    nam = "...",
    pic = 'images/apples.png',
    bgimg = function() end,
    dsc = function(s)
p("Решила старушка слазить в подпол за новой порцией грибов. Подняла она крышку погреба и вспомнила, что не взяла миску. Вернулась она к шкафчику, достала оттуда посудину и... забыла, зачем и куда шла и почему в руках миска. Почесав затылок, бабка вернула миску в шкаф, а сама легла обратно в кровать.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_9b1e7ebf_1539_46f6_be07_7d0d3fb84b35|Далее}^";
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
                --Далее
                nlbwalk(v_29); 
            end
        ),

    },
};

-- Рыба манит КШ
v_165 = room {
    nam = "...",
    pic = 'images/fish.png',
    bgimg = function() end,
    dsc = function(s)
p("Уложила мать дочку на тёплую печку, а сама пошла собираться в дорогу. А пирожки тем временем так и манили Красную Шапочку.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_7c682894_aa83_4f78_ac98_c9fde71bff8e|Взять пирожок из корзинки}^";
        p "{v_8b6a32d9_2f0e_4f8c_9c98_cc1e3e17cd3e|Не брать}^";
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
                --Взять пирожок из корзинки
_chap_got_fish_pie = true;
                nlbwalk(v_109); 
            end
        ),
        xact(
            'v_8b6a32d9_2f0e_4f8c_9c98_cc1e3e17cd3e',
            function(s) 
                --Не брать
                nlbwalk(v_22); 
            end
        ),

    },
};

-- КШ медленно тащит тяжёлую корзинку
v_166 = room {
    nam = "...",
    pic = 'images/chaperon_wolf.png',
    bgimg = function() end,
    dsc = function(s)
p("Красная Шапочка медленно потащила тяжёлую корзинку. Плетётся она по тропинке и ничего не замечет, ни птичек, ни пчёлок, ни солнца, ни тучек. И какая там погода -- ей тоже без разницы. Всё равно пот градом от напряжения. Вдруг навстречу Волк.^"..
"^"..
"Девочка, сосредоточенная на своей ноше, чуть в него не врезалась. Остановившись, она тут же разжала пальцы. Бум! Корзинка камнем упала на дорожку. Зверь с удивлением глядел на взмокшую красную, как свекла, пыхтящую девочку.^"..
"^"..
"-- Здравствуй, дитя! Как тебя зовут и куда ты идёшь?^"..
"Отдышавшись, Красная Шапочка произнесла:^"..
"-- Меня зовут Красная Шапочка. Я иду к бабушке, несу гостинцы.^"..
"-- Зачем же ты так нагрузилась? -- не смог удержаться от вопроса Волк.^"..
"-- Да вот, не рассчитала силы. Может, съешь хотя бы несколько штучек. -- с надеждой поинтересовалась Красная Шапочка.^"..
"-- Нет, -- понюхав пирожки, Волк поморщился. -- не могу, я такое не ем.^"..
"-- Очень жаль. -- вздохнула девочка.^"..
"-- Кстати, а где живёт твоя бабушка? -- чуть не забыл узнать Волк.^"..
"-- Да здесь, на опушке. Не так далеко, казалось бы.^"..
"Продолжая что-то ещё бурчать, она рывком отделила корзину от дороги и потащилась дальше. А Волк побежал к домику бабушки.");
    end,
    xdsc = function(s)
        p "^";
        p "{v_4d2c1bb7_1142_4ffe_ba97_358db8909a84|Волк побежал по короткой дороге к домику бабушки}^";
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
                --Волк побежал по короткой дороге к домику бабушки
                nlbwalk(v_80); 
            end
        ),

    },
};

-- Свернула КШ с тропинки, присела под кустик
v_167 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Свернула Красная Шапочка с тропинки и, заприметив раскидистую ель, направилась прямо к ней. Удобно устроившись под густой кроной, девочка съела пирожок с капустой, а затем, прислонишись к широкому стволу, наслаждалась тишиной и прохладой и не заметила, как задремала. Никогда ещё ей не спалось так сладко!");
    end,
    xdsc = function(s)
        p "^";
        p "{v_a5a88578_1d43_42a8_b8ed_4a491659c0dc|Далее}^";
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
                --Далее
                nlbwalk(v_160); 
            end
        ),

    },
};

-- Не разделяться
v_168 = room {
    nam = "...",
    pic = 'images/cabbage.png',
    bgimg = function() end,
    dsc = function(s)
p("Подумала мать: \"Может нам разделиться?\", но тут же отвергла эту идею. Не хватало, чтобы ещё бабка потерялась!^"..
"^"..
"Добрались они до домика матери. Там девочки не было. Тогда побежали женщины по тропинке обратно, по пути выкрикивая:^"..
"-- Шапочка, Шапочка!^"..
"^"..
"Красная Шапочка тем временем вышла из бабушкиной избушки, ибо не было там никого, и еды тоже не наблюдалось. И отправилась девочка к себе домой. От всей этой беготни аппетит разыгрался зверский. В животе урчало так, что аж уши закладывало.");
    end,
    xdsc = function(s)
        p "^";
        p ((( not _fin1)) and "{v_46453339_cf61_4aa7_b53b_edc9272ec286|Свернуть в лес поесть ягод}^" or "");
        p ((( not _fin31)) and "{v_749da51b_022a_4a08_8a41_2c1d31d306a3|Терпеть голод и не сворачивать}^" or "");
        p (((_fin1)) and "{v_886d28fb_8754_4fd0_a159_fe9722ce9a76|Свернуть в лес поесть ягод}^" or "");
        p (((_fin31)) and "{v_6e11a2eb_145c_4ebc_a8a7_750c4815c669|Терпеть голод и не сворачивать}^" or "");
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
                --Свернуть в лес поесть ягод
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
                --Терпеть голод и не сворачивать
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
                --Свернуть в лес поесть ягод
                nlbwalk(v_18); 
            end
        ),
        xact(
            'v_6e11a2eb_145c_4ebc_a8a7_750c4815c669',
            function(s) 
                --Терпеть голод и не сворачивать
                nlbwalk(v_155); 
            end
        ),

    },
};

