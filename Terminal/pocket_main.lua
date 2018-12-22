rednet.open("back")
network= os.getComputerID()

function help()
	shell.run("clear")
	print("----------")
	print("Welcome")
	print("----------")
	print("h - help")
	print("p - placement")
	print("m - mining")
	print("l - looting")
	print("r - recuperation")
	print("----------")
end

help()

while true do
	input = io.read()

	if input == "h" then
		help()
	elseif input == "p" then
		rednet.broadcast({network, "New Master"}, "DecaMiner")

	elseif input == "m" then
		print("Length ?")
		rednet.broadcast({"m", tonumber(io.read())}, tostring(network))

	elseif input == "debug" then
		rednet.broadcast({network, "Debug"}, "DecaMiner")

	elseif input == "l" then
		rednet.broadcast({"l"}, tostring(network))

	elseif input == "t" then
		print("Test")
		rednet.broadcast({"count"}, tostring(network).."s")

		n = 0
		while true do
			a = rednet.receive(tostring(network).."r", 0.2)
			if a==nil then break end
			n = n+1
		end
		print(n)

	else
		print(input)
		rednet.broadcast({input}, tostring(network))
	end

end