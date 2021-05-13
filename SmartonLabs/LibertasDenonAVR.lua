--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ENUM_SI = {"UNKNOWN", "PHONO", "CD", "TUNER", "DVD", "BD", "TV", "SAT/CBL", "MPLAY", "GAME", "HDRADIO", "NET", "PANDORA", "SIRIUSXM", "IRADIO", "SERVER", "FAVORITES", "AUX1", "AUX2", "AUX3", "AUX4", "AUX5", "AUX6", "AUX7", "BT", "USB/IPOD", "USB", "IPD", "IRP", "FVP"}
local ENUM_ON_AUTO_OFF = {"ON", "AUTO", "OFF"}
local AckAction = AckAction or ({})
AckAction.NA = 0
AckAction[AckAction.NA] = "NA"
AckAction.UPDATE = 1
AckAction[AckAction.UPDATE] = "UPDATE"
AckAction.FORCE = 2
AckAction[AckAction.FORCE] = "FORCE"
local TIMEOUT_ACK = 2000
local TIMEOUT_HB = 60000
local TIMEOUT_RECONN_WAIT = 10000
local function getEnumIndex(value, e, start, def)
    start = start or 0
    do
        local i = start
        while i < #e do
            if e[i + 1] == value then
                return i
            end
            i = i + 1
        end
    end
    return def
end
local function getBoolean(value)
    if value == "ON" then
        return true
    elseif value == "OFF" then
        return false
    end
end
local function virtualDeviceSendReport(device, value)
    if Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_LEVEL_CONTROL) then
        Libre_VirtualDeviceLevelReport(device, value)
    elseif Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_ON_OFF) then
        Libre_VirtualDeviceOnOffReport(device, value)
    elseif Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC) then
        local attrs = {[LibertasAttrId.IOV_BASIC_PRESENT_VALUE] = value}
        Libre_VirtualDeviceSetAttributes(device, LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC, attrs, LibertasEventSource.REPORT)
    end
end
local function DenonAVR(avr, mainZone, extraZones)
    local unsupportedCmds, suspectedUnsupportedCmd, socket, deviceValues, validDevices, pendingMessages, pendingAck, ready, validSession, reconnectTimer, commandAckTimer, heartBeatTimer, onError, enqueuePendingMessagesForce, rescheduleHeartbeat, trySendMessage
    function onError()
        local reconnectTimeout = TIMEOUT_RECONN_WAIT
        if validSession and pendingAck then
            local failureCount = suspectedUnsupportedCmd:get(pendingAck.c)
            if failureCount == nil then
                failureCount = 0
            end
            if failureCount >= 3 then
                suspectedUnsupportedCmd:delete(pendingAck.c)
                unsupportedCmds:add(pendingAck.c)
            else
                suspectedUnsupportedCmd:set(pendingAck.c, failureCount + 1)
            end
            reconnectTimeout = 100
        end
        for ____, device in __TS__Iterator(validDevices) do
            Libre_VirtualDeviceStatusDeviceDown(device)
        end
        deviceValues:clear()
        Libre_NetClose(socket)
        Libre_TimerCancel(commandAckTimer)
        Libre_TimerCancel(heartBeatTimer)
        ready = false
        Libre_TimerUpdate(reconnectTimer, reconnectTimeout)
    end
    function enqueuePendingMessagesForce(device, command, prefixLen, ack, source)
        if ready then
            if not unsupportedCmds:has(command) then
                local msg = {
                    d = device,
                    c = command,
                    n = prefixLen,
                    a = ack,
                    s = source,
                    t = os.msticks()
                }
                pendingMessages:pushright(msg)
                trySendMessage()
            end
        end
    end
    function rescheduleHeartbeat()
        if ready then
            if not pendingAck then
                Libre_TimerUpdate(heartBeatTimer, TIMEOUT_HB)
            else
                Libre_TimerCancel(heartBeatTimer)
            end
        end
    end
    function trySendMessage()
        if ready and (pendingAck == nil) then
            pendingAck = pendingMessages:popleft()
            if pendingAck then
                Libre_NetWrite(socket, pendingAck.c)
                Libre_TimerUpdate(commandAckTimer, TIMEOUT_ACK)
            end
            rescheduleHeartbeat()
        end
    end
    local curIncoming = lbuffer()
    unsupportedCmds = __TS__New(Set)
    suspectedUnsupportedCmd = __TS__New(Map)
    socket = Libre_NetNewTcp()
    deviceValues = __TS__New(Map)
    validDevices = __TS__New(Set)
    pendingMessages = list.new()
    ready = false
    validSession = false
    reconnectTimer = Libre_TimerNew(
        0,
        function()
            Libre_NetConnectDevice(socket, avr, 23)
        end
    )
    commandAckTimer = Libre_TimerNew(
        0,
        function()
            onError()
        end
    )
    heartBeatTimer = Libre_TimerNew(
        0,
        function()
            enqueuePendingMessagesForce(nil, "ZM?\r", 2, AckAction.NA, LibertasEventSource.NA)
        end
    )
    local function enqueuePendingMessages(device, command, prefixLen, ack, source)
        if device ~= nil then
            enqueuePendingMessagesForce(device, command, prefixLen, ack, source)
        end
    end
    local function cbUpdate(device, cmd, value)
        local oldValue = (((device ~= nil) and (function() return deviceValues:get(device) end)) or (function() return nil end))()
        local modified = (oldValue == nil) or (oldValue ~= value)
        local shouldNotify = false
        local source = LibertasEventSource.MANUAL_LOCAL
        local isAck = ((pendingAck ~= nil) and (pendingAck.n == #cmd)) and __TS__StringStartsWith(pendingAck.c, cmd)
        if isAck then
            local ackAction = pendingAck.a
            if ackAction == AckAction.UPDATE then
                shouldNotify = modified
            elseif ackAction == AckAction.FORCE then
                shouldNotify = true
            end
            source = pendingAck.s
            pendingAck = nil
            Libre_TimerCancel(commandAckTimer)
            validSession = true
            trySendMessage()
        else
            shouldNotify = modified
        end
        if device ~= nil then
            deviceValues:set(device, value)
            if shouldNotify then
                if oldValue == nil then
                    virtualDeviceSendReport(device, value)
                else
                    if Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_LEVEL_CONTROL) then
                        Libre_VirtualDeviceLevelSet(device, value, source)
                    elseif Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_ON_OFF) then
                        Libre_VirtualDeviceOnOffSet(device, value, source)
                    elseif Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC) then
                        local attrs = {[LibertasAttrId.IOV_BASIC_PRESENT_VALUE] = value}
                        Libre_VirtualDeviceSetAttributes(device, LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC, attrs, source)
                    end
                end
            end
        end
    end
    local function onMV(cmd, params)
        local v = tonumber(params)
        if v ~= nil then
            if #params == 2 then
                v = v * 10
            end
            v = v / 5
            cbUpdate(mainZone.volume, cmd, v)
        end
    end
    local function onMU(cmd, params)
        local v = getBoolean(params)
        if v ~= nil then
            cbUpdate(mainZone.mute, cmd, v)
        end
    end
    local function onSI(cmd, params)
        local v = getEnumIndex(params, ENUM_SI, 1, 0)
        if v ~= nil then
            cbUpdate(mainZone.input, cmd, v)
        end
    end
    local function onZM(cmd, params)
        local v = getBoolean(params)
        if v ~= nil then
            cbUpdate(mainZone.onOff, cmd, v)
        end
    end
    local function onECO(cmd, params)
        local v = getEnumIndex(params, ENUM_ON_AUTO_OFF)
        if v ~= nil then
            cbUpdate(mainZone.eco, cmd, v)
        end
    end
    local function onExtraZone(zone, cmd, params)
        if #extraZones < (zone + 1) then
            return
        end
        local d
        local v = tonumber(params)
        if v ~= nil then
            if #params == 2 then
                v = v * 10
            end
            v = v / 5
            d = extraZones[zone + 1].volume
        elseif params == "ON" then
            d = extraZones[zone + 1].onOff
            v = true
        elseif params == "OFF" then
            d = extraZones[zone + 1].onOff
            v = false
        elseif params == "MUON" then
            d = extraZones[zone + 1].mute
            cmd = tostring(cmd) .. "MU"
            v = true
        elseif params == "MUOFF" then
            d = extraZones[zone + 1].mute
            cmd = tostring(cmd) .. "MU"
            v = false
        else
            v = getEnumIndex(params, ENUM_SI, 1, 0)
            d = extraZones[zone + 1].input
        end
        if (d ~= nil) and (v ~= nil) then
            cbUpdate(d, cmd, v)
        end
    end
    local HANDLERS = {}
    HANDLERS.ZM = onZM
    if mainZone.eco ~= nil then
        HANDLERS.ECO = onECO
    end
    if mainZone.input ~= nil then
        HANDLERS.SI = onSI
    end
    if mainZone.mute ~= nil then
        HANDLERS.MU = onMU
    end
    if mainZone.volume ~= nil then
        HANDLERS.MV = onMV
    end
    local function onIncoming(c)
        if c == 13 then
            local cmd
            local params
            if curIncoming:len() > 3 then
                if curIncoming:tostring(1, 3) == "ECO" then
                    cmd = "ECO"
                    params = curIncoming:tostring(4)
                else
                    cmd = curIncoming:tostring(1, 2)
                    params = curIncoming:tostring(3)
                end
                if cmd == "Z2" then
                    onExtraZone(0, cmd, params)
                elseif cmd == "Z3" then
                    onExtraZone(1, cmd, params)
                else
                    local f = HANDLERS[cmd]
                    if f then
                        f(cmd, params)
                    end
                end
            end
            curIncoming:setlen(0)
            rescheduleHeartbeat()
        else
            local p = curIncoming:len()
            curIncoming:setlen(p + 1)
            curIncoming[__TS__index_adj(p)] = c
        end
    end
    local function getCmdParameter(event, index)
        if event.v ~= nil then
            local l = event.v
            return l[index + 1]
        end
    end
    local function genCmdVolume(cmd, v)
        if (v >= 0) and (v <= 98) then
            local whole = math.floor(v)
            local fraction = v - whole
            if fraction ~= 0 then
                return string.format("%s%02d5\r", cmd, whole)
            else
                return string.format("%s%02d\r", cmd, whole)
            end
        end
    end
    local function onControlVolume(event, cmd)
        if event.c ~= LibertasClusterId.GEN_LEVEL_CONTROL then
            return
        end
        if event.t ~= LibertasEventType.COMMAND then
            return
        end
        local outCmd
        if (cmd ~= nil) and (event.d ~= nil) then
            if (event.d == LibertasCommand.LEVEL_STEP) or (event.d == LibertasCommand.LEVEL_STEP_WITH_ON_OFF) then
                local stepMode = getCmdParameter(event, 0)
                local stepBy = getCmdParameter(event, 1)
                local curValue = deviceValues:get(event.id)
                if curValue == nil then
                    if stepMode == LibertasLevelStep.UP then
                        outCmd = string.format("%sUP\r", cmd)
                    elseif stepMode == LibertasLevelStep.DOWN then
                        outCmd = string.format("%sDOWN\r", cmd)
                    end
                else
                    local newValue = curValue
                    if stepMode == LibertasLevelStep.UP then
                        newValue = newValue + stepBy
                    elseif stepMode == LibertasLevelStep.DOWN then
                        newValue = newValue - stepBy
                    end
                    if ((newValue >= 0) and (newValue < (98 * 2))) and (newValue ~= curValue) then
                        outCmd = genCmdVolume(cmd, newValue / 2)
                    end
                end
            elseif (event.d == LibertasCommand.LEVEL_MOVE_TO_LEVEL) or (event.d == LibertasCommand.LEVEL_MOVE_TO_LEVEL_WITH_ON_OFF) then
                local level = getCmdParameter(event, 0)
                outCmd = genCmdVolume(cmd, level / 2)
            end
            return outCmd
        end
    end
    local function onControlOnOff(event, cmd)
        if event.c ~= LibertasClusterId.GEN_ON_OFF then
            return
        end
        if event.t ~= LibertasEventType.COMMAND then
            return
        end
        local outCmd
        if event.d == LibertasCommand.ON then
            outCmd = string.format("%sON\r", cmd)
        elseif event.d == LibertasCommand.OFF then
            outCmd = string.format("%sOFF\r", cmd)
        end
        return outCmd
    end
    local function onControlEnum(event, cmd, values)
        if event.c ~= LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC then
            return
        end
        if event.t ~= LibertasEventType.ATTR then
            return
        end
        if (event.s == LibertasEventSource.QUERY) or (event.s == LibertasEventSource.REPORT) then
            return
        end
        local attrs = event.v
        local v = attrs[LibertasAttrId.IOV_BASIC_PRESENT_VALUE]
        if v ~= nil then
            local val = values[v + 1]
            if val ~= nil then
                return string.format("%s%s\r", cmd, val)
            end
        end
    end
    local function initCtrlMap(d, cmd, f, depends, values)
        if d ~= nil then
            validDevices:add(d)
            Libre_SetOnVirtualDevice(
                d,
                function(_, event)
                    if d ~= depends then
                        local dependentPower = deviceValues:get(depends)
                        if (dependentPower == nil) or (not dependentPower) then
                            local value = deviceValues:get(d)
                            if value ~= nil then
                                virtualDeviceSendReport(d, value)
                            end
                            return
                        end
                    end
                    local ctrlCmd = f(event, cmd, values)
                    if ctrlCmd then
                        enqueuePendingMessages(d, ctrlCmd, #cmd, AckAction.FORCE, event.s)
                    end
                end
            )
        end
    end
    local function initSubZone(zone, cmd)
        initCtrlMap(zone.input, cmd, onControlEnum, zone.onOff, ENUM_SI)
        initCtrlMap(
            zone.mute,
            tostring(cmd) .. "MU",
            onControlOnOff,
            zone.onOff
        )
        initCtrlMap(zone.onOff, cmd, onControlOnOff, zone.onOff)
        initCtrlMap(zone.volume, cmd, onControlVolume, zone.onOff)
    end
    initCtrlMap(mainZone.eco, "ECO", onControlEnum, mainZone.onOff, ENUM_ON_AUTO_OFF)
    initCtrlMap(mainZone.input, "SI", onControlEnum, mainZone.onOff, ENUM_SI)
    initCtrlMap(mainZone.mute, "MU", onControlOnOff, mainZone.onOff)
    initCtrlMap(mainZone.onOff, "ZM", onControlOnOff, mainZone.onOff)
    initCtrlMap(mainZone.volume, "MV", onControlVolume, mainZone.onOff)
    if #extraZones > 0 then
        initSubZone(extraZones[1], "Z2")
        if #extraZones > 1 then
            initSubZone(extraZones[2], "Z3")
        end
    end
    local function initVolumeAttributes(device)
        if device ~= nil then
            Libre_VirtualDeviceSetAttributes(device, LibertasClusterId.LIBERTAS_LEVEL_CONFIG, {[LibertasAttrId.LIBERTAS_LEVEL_MIN] = 0, [LibertasAttrId.LIBERTAS_LEVEL_MAX] = 196, [LibertasAttrId.LIBERTAS_LEVEL_STEP_ONLY] = true, [LibertasAttrId.LIBERTAS_LEVEL_STEP_SINGLE] = 1, [LibertasAttrId.LIBERTAS_LEVEL_STEP_REPEAT] = 3, [LibertasAttrId.LIBERTAS_LEVEL_STEP_INTERVAL] = 5}, LibertasEventSource.REPORT)
        end
    end
    local function initMultiStateAttributes(device, nStates, minState)
        if device ~= nil then
            Libre_VirtualDeviceSetAttributes(device, LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC, {[LibertasAttrId.IOV_BASIC_NUM_OF_STATES] = nStates}, LibertasEventSource.REPORT)
            if (minState ~= nil) and (minState ~= 0) then
                Libre_VirtualDeviceSetAttributes(device, LibertasClusterId.LIBERTAS_HUB, {[LibertasAttrId.LIBERTAS_MULTISTATE_MIN] = minState}, LibertasEventSource.REPORT)
            end
        end
    end
    initVolumeAttributes(mainZone.volume)
    initMultiStateAttributes(mainZone.input, #ENUM_SI, 1)
    initMultiStateAttributes(mainZone.eco, #ENUM_ON_AUTO_OFF)
    if #extraZones > 0 then
        initVolumeAttributes(extraZones[1].volume)
        initMultiStateAttributes(extraZones[1].input, #ENUM_SI, 1)
        if #extraZones > 1 then
            initVolumeAttributes(extraZones[2].volume)
            initMultiStateAttributes(extraZones[2].input, #ENUM_SI, 1)
        end
    end
    Libre_SetOnNetReady(
        socket,
        function(tag)
            curIncoming:setlen(0)
            pendingMessages = list.new()
            pendingAck = nil
            ready = true
            validSession = false
            enqueuePendingMessagesForce(mainZone.onOff, "ZM?\r", 2, AckAction.FORCE, LibertasEventSource.REPORT)
            enqueuePendingMessages(mainZone.volume, "MV?\r", 2, AckAction.FORCE, LibertasEventSource.REPORT)
            enqueuePendingMessages(mainZone.mute, "MU?\r", 2, AckAction.FORCE, LibertasEventSource.REPORT)
            enqueuePendingMessages(mainZone.input, "SI?\r", 2, AckAction.FORCE, LibertasEventSource.REPORT)
            enqueuePendingMessages(mainZone.eco, "ECO?\r", 3, AckAction.FORCE, LibertasEventSource.REPORT)
            if #extraZones > 0 then
                enqueuePendingMessagesForce(nil, "Z2?\r", 2, AckAction.FORCE, LibertasEventSource.REPORT)
                if #extraZones > 1 then
                    enqueuePendingMessagesForce(nil, "Z3?\r", 2, AckAction.FORCE, LibertasEventSource.REPORT)
                end
            end
        end
    )
    Libre_SetOnNetDrain(
        socket,
        function()
            trySendMessage()
        end
    )
    Libre_SetOnNetError(
        socket,
        function(tag, fd, errorType, errorCode, errorText)
            onError()
        end
    )
    Libre_SetOnNetData(
        socket,
        function(tag, fd, data)
            do
                local i = 0
                while i < #data do
                    onIncoming(
                        __TS__StringCharCodeAt(data, i)
                    )
                    i = i + 1
                end
            end
        end
    )
    Libre_NetSetConnectTimeout(socket, 10)
    Libre_NetConnectDevice(socket, avr, 23)
    Libre_WaitReactive()
end
____exports.DenonAVR = DenonAVR
return ____exports
