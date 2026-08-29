local active = false

logger = {
    text = ""
}

function logger.log(title, ...)
    if not active then return end

    logger.text = logger.text .. tostring(title) .. ": "

    for _, part in pairs({...}) do
        logger.text = logger.text .. tostring(part) .. "; "
    end

    logger.text = logger.text .. "\n"
end

function logger.draw(title)
    if not active then return end

    ImGui.Begin(title, ImGuiWindowFlags.AlwaysAutoResize)
    ImGui.Text(logger.text)
    ImGui.End()

    logger.text = ""
end

return logger