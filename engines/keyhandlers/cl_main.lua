AddEventHandler('key:register', function(layout, keyname)
	if Drunk.KeysHandlers.RegisteredKeys[layout] == nil then Drunk.KeysHandlers.RegisteredKeys[layout] = {} end
	if Drunk.KeysHandlers.RegisteredKeys[layout][keyname] == nil then
		Drunk.KeysHandlers.RegisteredKeys[layout][keyname] = true
		RegisterKeyMapping(('+keypress %s %s'):format(layout, keyname), 'Binded '..keyname, layout:upper(), keyname:upper())
	end
end)

RegisterCommand('+keypress', function(s, args)
	local layout = args[1]
	local keyname = args[2]
	if layout and keyname then
		layout, keyname = layout:lower(), keyname:lower()
		if Drunk.KeysHandlers.RegisteredKeys[layout] ~= nil and Drunk.KeysHandlers.RegisteredKeys[layout][keyname] ~= nil then
			TriggerEvent(('key:press:%s:%s'):format(layout, keyname))
		end
	end
end, false)

RegisterCommand('-keypress', function(s, args)
	local layout = args[1]
	local keyname = args[2]
	if layout and keyname then
		layout, keyname = layout:lower(), keyname:lower()
		if Drunk.KeysHandlers.RegisteredKeys[layout] ~= nil and Drunk.KeysHandlers.RegisteredKeys[layout][keyname] ~= nil then
			TriggerEvent(('key:release:%s:%s'):format(layout, keyname))
		end
	end
end, false)