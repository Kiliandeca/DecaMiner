while true do
    if not turtle.detect() then
        if turtle.getItemCount() >= 1 or turtle.suckUp() then
            turtle.place()
            peripheral.wrap("front").turnOn()
        end
    end
    sleep(1)
end