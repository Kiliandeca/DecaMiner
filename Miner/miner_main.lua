shell.run("clear")

xMax = 10

if peripheral.getType("right") == "modem" then
		rednet.open("right")
	elseif peripheral.getType("left") == "modem" then
		rednet.open("left")
	else
		error("Error: no modem detected")
	end

-------------------
function save()
	print("[save]")
	local h = fs.open("DecaMiner", "w")
	h.writeLine(tostring(x))
	h.writeLine(tostring(y))
	h.writeLine(network)
	h.writeLine(tostring(xMax))

	j=1

	while turtles[j] ~= nil do
		i=1
		while j<xMax and turtles[j][i] ~= nil do
			h.writeLine(tostring(turtles[j][i]))
			i = i +1
		end
		j = j + 1
	end

	h.close()
end

--------------------
function init()
	
	state = 0
	print("Waiting instructions")
	rednet.broadcast("","DecaMiner")
	senderID, message, protocol = rednet.receive("DecaMiner")
	network = tostring(message[1])
	print("Network: ", network)

	
	if message[2] == "New Miner" then
		isMaster = false
		x = message[3]
		y = message[4]
		

		parallel.waitForAny(placement, background)

	elseif message[2] == "New Master" then
		x = 0
		y = 0


		isMaster = true
		parallel.waitForAny(master, background)
	end
end


--------------------
function master()
	state = 1
	if not turtle.getItemDetail(1) or turtle.getItemDetail(1).name ~= "EnderStorage:enderChest" then
		print("Insert Turtles's enderchest in slot 1")
	end
	while not turtle.getItemDetail(1) or turtle.getItemDetail(1).name ~= "EnderStorage:enderChest" do
		sleep(1)
	end

	if turtle.getItemCount(1) ~= 1 then
		print("Error, only 1 enderchest is needed")
	end
	while turtle.getItemCount(1) ~= 1 do
		sleep(1)
	end

	if not turtle.getItemDetail(2) or turtle.getItemDetail(2).name ~= "EnderStorage:enderChest" then
		print("Insert Loot's enderchests in slot 2 (at least 1)")
	end
	while not turtle.getItemDetail(2) or turtle.getItemDetail(2).name ~= "EnderStorage:enderChest" do
		sleep(1)
	end

	local nombreEnderChestLoot = turtle.getItemCount(2)
	intervaleEnderChestLoot = math.ceil(xMax/nombreEnderChestLoot)

	turtle.select(1)
	turtle.digUp()
	turtle.dig()
	turtle.placeUp()

	xPlacement = 0
	yPlacement = 0

	turtles = {{os.getComputerID()}}


	while turtle.suckUp() do
		data = turtle.getItemDetail(1)
		if data and (data.name == "ComputerCraft:CC-Turtle" or data.name == "ComputerCraft:CC-TurtleExpanded") then
            while not turtle.place() do
				sleep(0.2)
			end

			peripheral.wrap("front").turnOn()
			senderID, message, protocol = rednet.receive("DecaMiner", 20)
			if not message then
				print("Error: turtle not responding")
			else
				xPlacement = xPlacement+1
				if xPlacement >= xMax then
					xPlacement = 0
					yPlacement = yPlacement + 1
					table.insert(turtles, {})
				end
				if yPlacement == 0 and xPlacement/intervaleEnderChestLoot == math.floor(xPlacement/intervaleEnderChestLoot) then
					turtle.select(2)
					turtle.drop(1)
					turtle.select(1)
				end
				print("Sending instructions")

				table.insert(turtles[yPlacement+1], senderID)

				rednet.send(senderID, {network, "New Miner", xPlacement, yPlacement}, "DecaMiner")
			end	
			while turtle.detect() do
				sleep(0.2)
			end
		else
			turtle.select(1)
			for i=3, 16 do
				if turtle.transferTo(i) then
					break
				end
				if i == 16 then
					error("Turtle is full and no space left")
				end
			end
		end
	end

	turtle.digUp()

	position = {0,0}
	for _=1, 2 do
		while not turtle.forward() do
            	success, data = turtle.inspect()
            	if data and data.name ~= "ComputerCraft:CC-Turtle" and data.name ~= "ComputerCraft:CC-TurtleExpanded" then
                	turtle.dig()
            	elseif not success then
               		turtle.attack()
            	end
            	sleep(0.2)     
    	end
	end

	continue = true
	while continue do
		continue = false
		for _, j in pairs(turtles) do
			for _, i in pairs(j) do
				if 2 == turtleSend(i, {"state"}) then
					continue = true
				end
			end
		end
		sleep(2)
	end

	print("[M] Sending turtles list")
	rednet.broadcast(turtles, tostring(network).."tl")
	save()

end


--------------------
function placement()
	state = 2
	print("network:", network, " x:", x, " y:", y)
	
	local success, data = turtle.inspect()
	if data and (data.name == "ComputerCraft:CC-Turtle" or data.name == "ComputerCraft:CC-TurtleExpanded") and not turtle.inspectDown() then
		turtle.turnLeft()
		if x == 0 then turtle.turnLeft() end
	elseif x ~= 0 then
		turtle.turnRight()
	end

    for _=1, y*3 do
        while not turtle.up() do
            success, data = turtle.inspectUp()
            if data and data.name ~= "ComputerCraft:CC-Turtle" and data.name ~= "ComputerCraft:CC-TurtleExpanded" then
                turtle.digUp()
            elseif not success then
                turtle.attackUp()
            end
            sleep(0.2)
        end
    end
 
    if x ~= 0 then
    	for _=1, x do
        	while not turtle.forward() do
            	success, data = turtle.inspect()
            	if data and data.name ~= "ComputerCraft:CC-Turtle" and data.name ~= "ComputerCraft:CC-TurtleExpanded" then
                	turtle.dig()
           		elseif not success then
                	turtle.attack()
            	end
            	sleep(0.2)
        	end
		end
        turtle.turnLeft()
    end
 
    while not turtle.forward() do
            success, data = turtle.inspect()
            if data and data.name ~= "ComputerCraft:CC-Turtle" and data.name ~= "ComputerCraft:CC-TurtleExpanded" then
                turtle.dig()
            elseif not success then
                turtle.attack()
            end
            sleep(0.2)     
    end

	print("[P] Waiting turtles list...")
	state = 3
	senderID = nil
	senderID, turtles, protocol = rednet.receive(network.."tl")
	print("[P] Done.")
	save()

end


--------------------
function mining(distance)
	state = 4
	i = 0
	turtle.digDown()
	turtle.digUp()
	
	while i<distance do
		while turtle.detect() do
			turtle.dig()
		end
		if turtle.forward() then
			i = i + 1
			turtle.digDown()
			turtle.digUp()
		else
			turtle.attack()
		end
		
		if turtle.getFuelLevel()<=200 and turtle.getFuelLevel()%50 == 0 then
			print("[Mining] Low fuel, insert fuel !")
			for slot=1, 16 do
				turtle.select(slot)
				if turtle.refuel() then
					turtle.select(1)
					break
				end
			end
			turtle.select(1)
			

		end
	end
end

--------------------
function looting()
	turtle.turnLeft()

    for i=1, y*2 do
        while not turtle.down() do
            success, data = turtle.inspectDown()
            if success and data.name ~= "ComputerCraft:CC-Turtle" and data.name ~= "ComputerCraft:CC-TurtleExpanded" then
                turtle.digDown()
            else
                sleep(0.2)              
            end
        end
    end

	startingLootingSlot = 1

	if turtle.getItemDetail(1) and turtle.getItemDetail(1).name == "EnderStorage:enderChest" then
		isEc = true
		if isMaster then
			startingLootingSlot = 2
		end
	else
		isEc = false
	end

	if isEc or y~= 0 then
		sideToDrop = turtle.dropDown
	else
		sideToDrop = turtle.drop
	end

		
	if isEc then
		turtle.select(startingLootingSlot)
		while not turtle.placeDown() do turtle.digDown() end
	end

	if y~= 0 then
		turtleExistBack = false
		redstoneSide = "bottom"
	else
		turtleExistBack = turtleExist(x+1, y)
		redstoneSide = "front"
	end

	turtleExistTop = turtleExist(x, y+1)

	empty = false
	while not empty or (turtleExistTop and not redstone.getInput("top")) or (turtleExistBack and not redstone.getInput("back")) do
		empty = true
		for i=startingLootingSlot, 16 do
            turtle.select(i)
			if turtle.getItemCount() ~= 0 then
				empty = false
            	while not sideToDrop() do sleep(0.2) end
			end
       	end
	end


	turtle.select(1)
	redstone.setOutput("left", true) ------
	redstone.setOutput(redstoneSide, true)
		
	if isMaster then
		rednet.broadcast("", network.."endloot")
	else
		rednet.receive(network.."endloot")
	end

	redstone.setOutput("left", false) ------
	redstone.setOutput(redstoneSide, false)
			
	if isEc then
		turtle.select(startingLootingSlot)
		turtle.digDown()
	end

	if recup then
		recuperation()
	end

	print("Positionning...")	
	
	turtle.turnRight()

	for i=1, y*2 do
        while not turtle.up() do
            success, data = turtle.inspectUp()
            if success and (data.name ~= "ComputerCraft:CC-Turtle" and data.name ~= "ComputerCraft:CC-TurtleExpanded") then
                turtle.digUp()
            else
                sleep(0.2)              
            end
        end
    end
end


-------------------
function recuperation()
	print("recup")
	
	fs.delete("DecaMiner")

	turtle.turnRight()
	turtle.turnRight()

	if isMaster then 
		turtle.select(1)
		while not turtle.placeDown() do sleep(1) end
	end

	while (turtleExistTop and not redstone.getInput("top")) or (turtleExistBack and not redstone.getInput("front")) do
		if turtleExistTop and not redstone.getInput("top") then
			turtle.suckUp()
			if isMaster then
				turtle.dropDown()
			end
		end
		if turtleExistBack and not redstone.getInput("front") then
			turtle.suck()
			if isMaster then
				if turtle.getItemDetail(1) and turtle.getItemDetail(1).name == "EnderStorage:enderChest" then
					turtle.transferTo(2)
				else
				turtle.dropDown()
				end
			end
		end
	end
	
	if turtleExistTop then 
		turtle.digUp()
		if isMaster then
			turtle.dropDown()
		end
	end
	if turtleExistBack then 
		turtle.dig() 
		if isMaster then
			turtle.dropDown()
		end
	end

	if not isMaster then
		while not isEmpty() do sleep(0.2) end
	
		if redstoneSide == "front" then redstoneSide = "back" end
		redstone.setOutput(redstoneSide, true)
		
		while true do sleep(10) end

	else
		turtle.digDown()
		turtle.turnLeft()
		turtle.back()
		os.reboot()
	end

end

--------------------
function isEmpty()
	for i=1, 16 do
    	turtle.select(i)
    	if turtle.getItemCount() ~= 0 and turtle.getItemDetail().name ~= "EnderStorage:enderChest" then
      	  return false
    	end
    end

    turtle.select(1)
    return true
end

--------------------
function turtleExist(turtleX, turtleY)
	if turtles[turtleY+1] and turtles[turtleY+1][turtleX+1] and turtleSend(turtles[turtleY+1][turtleX+1], {"ping"}) == "pong" then
			return true
	else
		return false
	end
end

function turtleSend(id, instruction)
	rednet.send(id, instruction, network.."s")
	message = nil
	local senderId, message = rednet.receive(tostring(os.getComputerID()).."r", 2)
	return message
end

--------------------
function background()
	while true do
		messageToSend = nil
		senderId, messageReceived= rednet.receive(network.."s")

		if type(messageReceived) == "table" then
			if messageReceived[1] == "count" then
				messageToSend = "count"
			-----
			elseif messageReceived[1] == "empty" then
				if turtle.getItemDetail(1) and turtle.getItemDetail(1).name == "EnderStorage:enderChest" then
					isEc = true
				else
					isEc = false
				end

				if isEmpty() and (not turtleExist(x, y+1) or turtleSend(turtles[y+1+1][x+1], {"empty"}, network.."s")) then
					messageToSend = true
				else
					messageToSend = false
				end
			-----
			elseif messageReceived[1] == "state" then
				if messageReceived[2] ~= nil then
					if state == messageReceived[2] then
						messageToSend = true
					end
				else
					messageToSend = state
				end
			-----
			elseif messageReceived[1] == "endLoot" then
				isLooting = false
			-----
			elseif messageReceived[1] == "ping" then
				messageToSend = "pong"
			end
		end

		if messageToSend ~= nil then
			rednet.send(senderId, messageToSend, tostring(senderId).."r")
			print("[Background] Sent: \"", messageToSend, "\" to ", senderId)
		else
			print("[Background] Failed to respond to ", senderId)
		end
	end
end

--------------------
function boot()

	if not fs.exists("DecaMiner") then 
		init() 
	else
		local h = fs.open("DecaMiner", "r")
		x = tonumber(h.readLine())
		y = tonumber(h.readLine())
		network = h.readLine()
		xMax = tonumber(h.readLine())

		print("Restauration...")
		print("x :", x, " y: ", y, " network: ", network)
		if x == 0 and y == 0 then isMaster = true else isMaster = false end

		turtles = {{}}
		
		i = 1
		j = 1
		line = -1
   		while line ~= nil do
            line = h.readLine()
			table.insert(turtles[j], tonumber(line))
			if i%xMax == 0 then
				table.insert(turtles, {})
				j= j+1
			end
			i = i+1
    	end

		h.close()
	end
	parallel.waitForAll(main, background)
end

--------------------
function main()
	while true do
		state = 5
		senderID, message = rednet.receive(network)
	
		print(message)
	
		if tostring(senderID) == network then
			-- Mining

			print(message[1])

			if message[1] == "m" then
				mining(message[2])
			-- Looting
			elseif message[1] == "l" then
				recup = false
				looting()
			elseif message[1] == "r" then
				recup = true
				looting()
			elseif message[1] == "reboot" then
				os.reboot()
			elseif message[1] == "s" then
				os.shutdown()
			elseif message[1] == "f" then
				turtle.forward()
			elseif message[1] == "b" then
				turtle.back()
			elseif message[1] == "u" then
				turtle.up()
			elseif message[1] == "d" then
				turtle.down()
			elseif message[1] == "tr" then
				turtle.turnRight()
			elseif message[1] == "tl" then
				turtle.turnLeft()
			elseif message[1] == "del" then
				fs.delete("DecaMiner")
			end
		end
	end
end

boot()

print("eof")