keySettingsDefault() = Dict([
    :keyALeft   => SDL2.SDLK_a
    :keyARight  => SDL2.SDLK_d
    :keyBLeft   => SDL2.SDLK_LEFT
    :keyBRight  => SDL2.SDLK_RIGHT
  ])
keySettings = keySettingsDefault()

keyDisplayNames = Dict([
    SDL2.SDLK_RIGHT => "Right Arrow"
    SDL2.SDLK_LEFT => "Left Arrow"
    SDL2.SDLK_UP => "Up Arrow"
    SDL2.SDLK_DOWN => "Down Arrow"

    SDL2.SDLK_a => "A"
    SDL2.SDLK_b => "B"
    SDL2.SDLK_c => "C"
    SDL2.SDLK_d => "D"
    SDL2.SDLK_e => "E"
    SDL2.SDLK_f => "F"
    SDL2.SDLK_g => "G"
    SDL2.SDLK_h => "H"
    SDL2.SDLK_i => "I"
    SDL2.SDLK_j => "J"
    SDL2.SDLK_k => "K"
    SDL2.SDLK_l => "L"
    SDL2.SDLK_m => "M"
    SDL2.SDLK_n => "N"
    SDL2.SDLK_o => "O"
    SDL2.SDLK_p => "P"
    SDL2.SDLK_q => "Q"
    SDL2.SDLK_r => "R"
    SDL2.SDLK_s => "S"
    SDL2.SDLK_t => "T"
    SDL2.SDLK_u => "U"
    SDL2.SDLK_v => "V"
    SDL2.SDLK_w => "W"
    SDL2.SDLK_x => "X"
    SDL2.SDLK_y => "Y"
    SDL2.SDLK_z => "Z"

    SDL2.SDLK_0 => "0"
    SDL2.SDLK_1 => "1"
    SDL2.SDLK_2 => "2"
    SDL2.SDLK_3 => "3"
    SDL2.SDLK_4 => "4"
    SDL2.SDLK_5 => "5"
    SDL2.SDLK_6 => "6"
    SDL2.SDLK_7 => "7"
    SDL2.SDLK_8 => "8"
    SDL2.SDLK_9 => "9"

    SDL2.SDLK_MINUS => "-"
    SDL2.SDLK_EQUALS => "="
    SDL2.SDLK_BACKSPACE => "Delete"
    SDL2.SDLK_DELETE => "Delete"

    SDL2.SDLK_TAB => "Tab"
    SDL2.SDLK_LEFTBRACKET => "["
    SDL2.SDLK_RIGHTBRACKET => "]"
    SDL2.SDLK_BACKSLASH => "\\"
    SDL2.SDLK_SEMICOLON => ";"
    SDL2.SDLK_QUOTE => "'"
    SDL2.SDLK_RETURN => "Return"
    SDL2.SDLK_LSHIFT => "Left Shift"
    SDL2.SDLK_COMMA => ","
    SDL2.SDLK_PERIOD => "."
    SDL2.SDLK_SLASH => "/"
    SDL2.SDLK_RSHIFT => "Right Shift"

    SDL2.SDLK_SPACE => "Space"
  ])

badKeySound = nothing
function tryChangingKeySettingButton(keyControl::Symbol)
    e,eventType = nothing,nothing
    while eventType != SDL2.KEYDOWN
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

    if keySettings == keySettingsDefault()
        buttons[:bResetDefaultKeys].enabled = false
    else
        buttons[:bResetDefaultKeys].enabled = true
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
      _pp = SDL2.GetPrefPath("nhdaly", kSAFE_GAME_NAME)
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

function resetDefaultKeys()
    for (key,val) in keySettingsDefault()
        tryChangingKeySettingButton(key,val)
    end
end
