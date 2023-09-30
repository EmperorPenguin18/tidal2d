function hello(e, instance)
	print("Hello World")
end

function destruction(e, instance)
	while (true)
	do
		if (quit(e) == true)
		then
			break
		end
		print("go to link")
	end
end

function create_room(e, instance)
	action(e, instance, '{ "type": "music", "file": "background.ogg" }')
	action(e, instance, '"type": "gravity", "h": 0, "v": 50')
	action(e, instance, '{ "type": "spawn", "object": "rocket.json", "x": 50, "y": 240 }')
	action(e, instance, '{ "type": "spawn", "object": "obstacle_t.json", "x": 400, "y": 50 }')
	action(e, instance, '{ "type": "spawn", "object": "obstacle.json", "x": 400, "y": 400 }')
	action(e, instance, '{ "type": "timer", "num": 0, "time": 10 }')
	action(e, instance, '"type": "cursor", "file": "crosshair.png"')
	action(e, instance, '"type": "window", "w": 700, "h": 480')
end
