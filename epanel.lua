-- Zmienna dla pięter specjalnych
local specialFloors = {10, 11, 12}  -- Przykładowe specjalne piętra

-- Funkcja rysująca przycisk
function drawButton(x, y, label)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(x, y)
    term.write("[" .. label .. "]")
end

-- Funkcja rysująca panel
function drawPanel(input, message)
    -- Czyszczenie ekranu
    term.clear()
    
    -- Wyświetlacz
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(2, 2)
    term.clearLine()
    term.setCursorPos(2, 2)
    term.write("Floor: " .. input)

    if message then
        term.setCursorPos(2, 4)
        term.write(message)
    end
    
    -- Przyciski
    local buttons = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9},
        {"*", 0, "-"}
    }
    
    for row = 1, #buttons do
        for col = 1, #buttons[row] do
            drawButton(2 + (col - 1) * 4, 5 + row * 2, tostring(buttons[row][col]))
        end
    end
end

-- Funkcja do walidacji numeru piętra
function isValidFloor(floor)
    if floor == "" or floor == "-" or floor:find("%-%-") or floor:find("%-$") or floor:find("^%-.*%-") then
        return false
    end
    
    local numFloor = tonumber(floor)
    return numFloor ~= nil
end

-- Funkcja główna
function main()
    local input = ""  -- Zmienna dla numeru piętra
    local message = nil
    local lastInteraction = os.clock()

    while true do
        drawPanel(input, message)
        
        -- Oczekiwanie na zdarzenie
        local event, side, x, y = os.pullEvent("monitor_touch")
        
        -- Aktualizacja czasu ostatniej interakcji
        lastInteraction = os.clock()
        
        -- Obsługa przycisków
        if x >= 2 and x <= 4 then
            if y == 5 then input = input .. "1"
            elseif y == 7 then input = input .. "4"
            elseif y == 9 then input = input .. "7"
            elseif y == 11 then input = input .. "*" end
        elseif x >= 6 and x <= 8 then
            if y == 5 then input = input .. "2"
            elseif y == 7 then input = input .. "5"
            elseif y == 9 then input = input .. "8"
            elseif y == 11 then input = input .. "0" end
        elseif x >= 10 and x <= 12 then
            if y == 5 then input = input .. "3"
            elseif y == 7 then input = input .. "6"
            elseif y == 9 then input = input .. "9" end
        elseif x >= 14 and x <= 16 then
            if y == 11 and input == "" then
                input = "-"
            end
        end
        
        -- Sprawdzenie poprawności numeru piętra
        if not isValidFloor(input) then
            input = ""
            message = "Invalid floor"
        end

        -- Sprawdzenie, czy minęły 3 sekundy od ostatniej interakcji
        if os.clock() - lastInteraction > 3 then
            if isValidFloor(input) then
                local numFloor = tonumber(input)
                if numFloor == nil then
                    message = "??"
                elseif specialFloors[numFloor] then
                    message = "(( ))"
                    -- Kolejne 3 sekundy na włożenie karty
                    local startWait = os.clock()
                    while os.clock() - startWait < 3 do
                        local event, side, x, y = os.pullEvent("monitor_touch")
                        lastInteraction = os.clock()  -- Aktualizacja ostatniej interakcji
                    end
                    if os.clock() - startWait >= 3 then
                        message = "??"
                    end
                else
                    -- Przykładowe działanie po wprowadzeniu numeru piętra
                    message = "Calling elevator to floor " .. input
                end
            else
                -- Losowanie litery od A do F
                local letter = string.char(math.random(65, 70))
                message = "Directing to elevator " .. letter
            end
            input = ""  -- Resetowanie wprowadzonego numeru piętra
        end
    end
end

main()
