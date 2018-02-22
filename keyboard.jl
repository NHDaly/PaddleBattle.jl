keySettings = Dict([
    :paddleBLeft   => SDLK_LEFT
    :paddleBRight  => SDLK_RIGHT
    :paddleALeft   => SDLK_a
    :paddleARight  => SDLK_d
  ])

keyDisplayNames = Dict([
    SDLK_RIGHT => "Right Arrow"
    SDLK_LEFT => "Left Arrow"
    SDLK_UP => "Up Arrow"
    SDLK_DOWN => "Down Arrow"

    SDLK_a => "A"
    SDLK_b => "B"
    SDLK_c => "C"
    SDLK_d => "D"
    SDLK_e => "E"
    SDLK_f => "F"
    SDLK_g => "G"
    SDLK_h => "H"
    SDLK_i => "I"
    SDLK_j => "J"
    SDLK_k => "K"
    SDLK_l => "L"
    SDLK_m => "M"
    SDLK_n => "N"
    SDLK_o => "O"
    SDLK_p => "P"
    SDLK_q => "Q"
    SDLK_r => "R"
    SDLK_s => "S"
    SDLK_t => "T"
    SDLK_u => "U"
    SDLK_v => "V"
    SDLK_w => "W"
    SDLK_x => "X"
    SDLK_y => "Y"
    SDLK_z => "Z"

    SDLK_0 => "0"
    SDLK_1 => "1"
    SDLK_2 => "2"
    SDLK_3 => "3"
    SDLK_4 => "4"
    SDLK_5 => "5"
    SDLK_6 => "6"
    SDLK_7 => "7"
    SDLK_8 => "8"
    SDLK_9 => "9"

    SDLK_MINUS => "-"
    SDLK_PLUS => "+"
    SDLK_DELETE => "Delete"

    SDLK_TAB => "Tab"
    SDLK_LEFTBRACKET => "["
    SDLK_RIGHTBRACKET => "]"
    SDLK_BACKSLASH => "\\"
    SDLK_RETURN => "Return"
    SDLK_LSHIFT => "Left Shift"
    SDLK_COMMA => ","
    SDLK_PERIOD => "."
    SDLK_SLASH => "/"
    SDLK_RSHIFT => "Right Shift"

    SDLK_SPACE => "Space"
  ])

badKeySound = nothing
function tryChangingKeySettingButton(keyButton::Button, keySetting::Symbol)
    println("keySetting: $keySetting")
    println("keySetting ptr: $(pointer_from_objref(keySetting))")
    e,eventType = nothing,nothing
    while eventType != SDL_KEYDOWN
        e, _ = pollEvent!()
        eventType = getEventType(e)
    end
    keySym = getKeySym(e)
    if !haskey(keyDisplayNames, keySym)
        audioEnabled && Mix_PlayChannel( Int32(-1), badKeySound, Int32(0) )
    else
        keySettings[keySetting] = keySym
        keyButton.text = keyDisplayNames[keySym]
        println("keySetting: $keySetting")
        println("keySetting ptr: $(pointer_from_objref(keySetting))")
    end
end
