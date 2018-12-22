if peripheral.getType("right") == "modem" then
    rednet.open("right")
elseif peripheral.getType("left") == "modem" then
    rednet.open("left")
else
    error("Error: no modem detected")
end

shell.run("label set Break")

while true do

	while turtle.getItemCount() ~= 0 do
		if turtle.inspectDown() then
			turtle.dropDown()
		else
			sleep(1)
		end
	end

	rednet.receive("break")
	turtle.dig()

end