﻿-- Rotation Helper Library by Timofeev Alexey
------------------------------------------------------------------------------------------------------------------
-- список команд
local Commands = {}
------------------------------------------------------------------------------------------------------------------
-- метод для задания команды, которая имеет приоритет на ротацией
-- SetCommand(string 'произвольное имя', function(...) команда, bool function(...) проверка, что все выполнилось, или выполнение невозможно)
function SetCommand(name, applyFunc, checkFunc)
    Commands[name] = {Last = 0, Timer = 0, Apply = applyFunc, Check = checkFunc, Params == null}
end

------------------------------------------------------------------------------------------------------------------
-- Используется в макросах
-- /run DoCommand('my_command', 'focus')
function DoCommand(cmd, ...)
    if not Commands[cmd] then 
        print("DoCommand: Ошибка! Нет такой комманды ".. cmd)
        return
    end 
    local d = 1.85
    local t = GetTime() + d
    local spell, _, _, _, _, endTime  = UnitCastingInfo("player")
    if not spell then spell, _, _, _, _, endTime, _, nointerrupt = UnitChannelInfo("player") end
    if spell and endTime then 
        t = endTime/1000 + d
        if Commands[cmd].Timer and Commands[cmd].Timer == t then 
            RunMacroText("/stopcasting") 
            t = GetTime() + d
        end
    end
    Commands[cmd].Timer = t
    Commands[cmd].Params = { ... }
end

------------------------------------------------------------------------------------------------------------------
-- навешиваем обработчик с максимальным приоритетом на событие OnUpdate, для обработки вызванных комманд
function UpdateCommands()
    if IsPlayerCasting() then return false end
    local ret = false
    for cmd,_ in pairs(Commands) do 
        if not ret then
            if (Commands[cmd].Timer  - GetTime() > 0) then 
                ret = true
                if Commands[cmd].Check(unpack(Commands[cmd].Params)) then 
                   Commands[cmd].Timer = 0
                else
                   if GetTime() - Commands[cmd].Last > 0.2 and Commands[cmd].Apply(unpack(Commands[cmd].Params)) then
                        Commands[cmd].Last = GetTime()
                   end
                end
            else
                Commands[cmd].Timer = 0
            end 
        end
    end
    return ret
end