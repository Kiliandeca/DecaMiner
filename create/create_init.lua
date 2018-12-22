if not turtle then
    for i, side in pairs(rs.getSides()) do
        if disk.isPresent(side) then
            disk.setLabel(side, "DecaMiner2")
            shell.run("delete disk/startup")        
            shell.run("pastebin get scCNy2gL disk/startup")
            print("Floppy ready, remove the computer")
        end
    end
 
else
 
    _, errorstr = turtle.dig()
 
    if errorstr == "No tool to dig with" then
        -- place
        shell.run("pastebin get PHrmrWwk startup")
        os.reboot()
    else
        -- recup
        shell.run("pastebin get JSyuXnAS startup")
        os.reboot()
    end
end