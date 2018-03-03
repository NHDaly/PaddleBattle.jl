keySettings = Dict([
    :keyALeft   => SDLK_a
    :keyARight  => SDLK_d
    :keyBLeft   => SDLK_LEFT
    :keyBRight  => SDLK_RIGHT
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
    SDLK_EQUALS => "="
    SDLK_BACKSPACE => "Delete"
    SDLK_DELETE => "Delete"

    SDLK_TAB => "Tab"
    SDLK_LEFTBRACKET => "["
    SDLK_RIGHTBRACKET => "]"
    SDLK_BACKSLASH => "\\"
    SDLK_SEMICOLON => ";"
    SDLK_QUOTE => "'"
    SDLK_RETURN => "Return"
    SDLK_LSHIFT => "Left Shift"
    SDLK_COMMA => ","
    SDLK_PERIOD => "."
    SDLK_SLASH => "/"
    SDLK_RSHIFT => "Right Shift"

    SDLK_SPACE => "Space"
  ])

badKeySound = nothing
function tryChangingKeySettingButton(keyControl::Symbol)
    e,eventType = nothing,nothing
    while eventType != SDL_KEYDOWN
        e, _ = pollEvent!()
        eventType = getEventType(e)
    end
    keySym = getKeySym(e)
    # If it's the same key, we're all done.
    if keySym == keySettings[keyControl]
        return
    end
    if !haskey(keyDisplayNames, keySym)
        # If this isn't a valid key, error
        audioEnabled && Mix_PlayChannel( Int32(-1), badKeySound, Int32(0) )
    elseif keySym in values(keySettings)
        #  or if it's already being used somewhere else, swap them.
        reverse_keySettings = Dict(value => key for (key, value) in keySettings)
        prevKey = reverse_keySettings[keySym]

        prevSym = keySettings[keyControl]
        keySettings[prevKey] = prevSym
        buttons[prevKey].text = keyDisplayNames[prevSym]
        keySettings[keyControl] = keySym
        buttons[keyControl].text = keyDisplayNames[keySym]
    else
        keySettings[keyControl] = keySym
        buttons[keyControl].text = keyDisplayNames[keySym]
    end
end


"""
If the game state believes any of the keys are held down, just double
check that they actually are held down. This is a little silly, but
sometimes things can get out of sync, like if the player is holding a key
when the game is paused by the OS for some reason (such as resizing).
"""
function double_check_keys()
    println("PaddleA: $paddleAKeys")
    if paddleAKeys.leftDown
        println("get_key_state: $(get_key_state(keySettings[:keyALeft]))")
        if !get_key_state(keySettings[:keyALeft])
            paddleAKeys.leftDown = false
        end
    end
    if paddleAKeys.rightDown
        if !get_key_state(keySettings[:keyARight])
            paddleAKeys.rightDown = false
        end
    end
    if paddleBKeys.leftDown
        if !get_key_state(keySettings[:keyBLeft])
            paddleBKeys.leftDown = false
        end
    end
    if paddleBKeys.rightDown
        if !get_key_state(keySettings[:keyBRight])
            paddleBKeys.rightDown = false
        end
    end
end

_keystates = nothing
function get_key_state(keysym)
    global _keystates
    # initialize the first time
    if _keystates == nothing _keystates = SDL_GetKeyboardState(C_NULL) end
    if _keystates == C_NULL return end

    SDL_PumpEvents();  # Not strictly necessary since SDL_PollEvent calls this.
    # Note that Scancodes represent the physical keyboard layout instead of what
    # characters the keys represent.
    return Bool(unsafe_load(_keystates, 1+SDL_GetScancodeFromKey(Int32(keysym))))
end
