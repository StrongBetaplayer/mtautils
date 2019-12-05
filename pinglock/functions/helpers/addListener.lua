

function addListener(eName, func)

    addEvent(eName, true)
    addEventHandler(eName, root, func)
end