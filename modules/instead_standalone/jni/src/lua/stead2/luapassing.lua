local initFunc = function()
end

local setAchievementFunc = function(achievementName)
end

local setAchievementProgressFunc = function(achievementName, current, max)
end

local setStatFunc = function(statName, val)
end

local storeFunc = function()
end

local clearAchievementFunc = function(achievementName)
end

function init()
    statsInitDone = false;
end

-- Native implementation of statsAPI was removed for Android
statsAPI = {
    init = function()
        print("Initializing API...\n");
        if (statsInitDone) then
            print("Already initialized!\n");
            return 0.0;
        else
            initFunc();
            statsInitDone = true;
            print("API initialized.\n");
            return 1.0;
        end
    end,
    setAchievement = function(achievementName, storeImmediately)
        print("Setting achievement '"..achievementName.."'...\n");
        setAchievementFunc(achievementName);
        if (storeImmediately) then
            storeFunc();
        end
        print("Achievement set.\n");
        return 0.0;
    end,
    setAchievementProgress = function(achievementName, current, max, storeImmediately)
        print("Setting achievement progress '"..achievementName.."', "..tostring(current).." of "..tostring(max).."...\n");
        setAchievementProgressFunc(achievementName, current, max);
        if (storeImmediately) then
            storeFunc();
        end
        print("Achievement progress set.\n");
        return 0.0;
    end,
    setStat = function(statName, val, storeImmediately)
        print("Setting stat '"..statName.."' to "..tostring(val).."...\n");
        setStatFunc(statName, val);
        if (storeImmediately) then
            storeFunc();
        end
        print("Stat set.\n");
        return 0.0;
    end,
    store = function()
        print("Storing...\n");
        storeFunc();
        print("Done.\n");
        return 0.0;
    end,
    clearAchievement = function(achievementName, storeImmediately)
        print("Clearing achievement '"..achievementName.."'...\n");
        clearAchievementFunc(achievementName);
        if (storeImmediately) then
            storeFunc();
        end
        print("Achievement cleared.\n");
        return 0.0;
    end,
    resetAll = function()
        print("Resetting all achievements...\n");
        resetAllFunc();
        print("Done.\n");
        return 0.0;
    end,
    openURL = function(url)
        if not instead.atleast(3, 2) then
            p(url);
        else
            instead_clipboard(url);
            p(url .. " [copied to clipboard]");
        end
    end
}

return statsAPI;