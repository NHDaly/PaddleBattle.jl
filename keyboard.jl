keySettingsDefault() = Dict([
    :keyALeft   => SDLK_a
    :keyARight  => SDLK_d
    :keyBLeft   => SDLK_LEFT
    :keyBRight  => SDLK_RIGHT
  ])
keySettings = keySettingsDefault()

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
    tryChangingKeySettingButton(keyControl,keySym)
    # Write new key settings!
    write_prefs_backup()
end
function tryChangingKeySettingButton(keyControl::Symbol, keySym)
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

_pp = nothing
prefspath = nothing
prefsfile = nothing
function write_prefs_backup()
    if prefsfile != nothing
        write(prefsfile, serializeKeySettings()*"\n")
    end
end
function load_prefs_backup()
    if prefsfile != nothing && isfile(prefsfile)
        f = open(prefsfile)
        loadKeySettings(readline(f))
    end
end
function init_prefspath()
    global _pp, prefspath, prefsfile
      _pp = SDL_GetPrefPath("nhdaly", kSAFE_GAME_NAME)
      if _pp != Cstring(C_NULL)
          prefspath = unsafe_string(_pp)
          prefsfile = joinpath(prefspath, "settings.txt");
      end
    return prefspath
end

function loadKeySettings(prefs::String)
    p_vals = map((v)->parse(UInt32,v), split(prefs))
    tryChangingKeySettingButton(:keyALeft, p_vals[1])
    tryChangingKeySettingButton(:keyARight, p_vals[2])
    tryChangingKeySettingButton(:keyBLeft, p_vals[3])
    tryChangingKeySettingButton(:keyBRight, p_vals[4])
end
function serializeKeySettings()
    join([keySettings[:keyALeft],
          keySettings[:keyARight],
          keySettings[:keyBLeft],
          keySettings[:keyBRight],
         ], " ")
end
