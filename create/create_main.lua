if not turtle then
	error("Floppy ready: You can remove the computer")
end

if peripheral.getType("right") == "modem" then
	rednet.open("right")
elseif peripheral.getType("left") == "modem" then
	rednet.open("left")
else
	error("Error: no modem detected")
end

shell.run("pastebin get YER0NhWe startup")
shell.run("label set DecaMinerV2")

if turtle.suckDown(4) then
	if turtle.refuel() then
		print("Refuel sucess")
		
		while true do
			rednet.broadcast("", "break")
			print("d1")
			sleep(1)
		end

	else
		error("Invalid item: check the chest, empty the turtle and reboot")
	end
else
	error("Chest empty: check the chest and reboot")
end