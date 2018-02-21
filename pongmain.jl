#module PongMain
println("Start")

#using SDL2
include("/Users/daly/.julia/v0.6/SDL2/src/SDL2.jl")

const assets = "assets"

# Override SDL libs locations if this script is being compiled for mac .app builds
if get(ENV, "COMPILING_APPLE_BUNDLE", "false") == "true"
    #  (note that you can still change these values b/c no functions have
    #  actually been called yet, and so the original constants haven't been
    #  "compiled in".)
    const libSDL = "libSDL2.dylib"
    const SDL_ttf = "libSDL2_ttf.dylib"
    const SDL_mixer = "libSDL2_mixer.dylib"
end

include("timing.jl")
include("objects.jl")
include("display.jl")

const kGAME_NAME = "Power Pong!"

winWidth, winHeight = Int32(800), Int32(600)
winWidth_highDPI, winHeight_highDPI = Int32(800), Int32(600)
function makeWinRenderer()
    global winWidth, winHeight, winWidth_highDPI, winHeight_highDPI
    #win = SDL_CreateWindow("Hello World!", Int32(100), Int32(100), winWidth, winHeight, UInt32(SDL_WINDOW_SHOWN))

    win = SDL_CreateWindow(kGAME_NAME,
        Int32(SDL_WINDOWPOS_CENTERED), Int32(SDL_WINDOWPOS_CENTERED), winWidth, winHeight,
        SDL_WINDOW_ALLOW_HIGHDPI|SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE|SDL_WINDOW_SHOWN);
    SDL_AddEventWatch(cfunction(resizingEventWatcher, Cint, Tuple{Ptr{Void}, Ptr{SDL_Event}}), win);

    # Find out how big the created window actually was (depends on the system):
    winWidth, winHeight, winWidth_highDPI, winHeight_highDPI = getWindowSize(win)
    #cam.w, cam.h = winWidth_highDPI, winHeight_highDPI

    renderer = SDL_CreateRenderer(win, Int32(-1), UInt32(SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC))
    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)
    #renderer = SDL_CreateRenderer(win, Int32(-1), Int32(0))
    return win,renderer
end

# This huge function just handles resize events. I'm not sure why it needs to be
# a callback instead of just the regular pollEvent..
function resizingEventWatcher(data_ptr::Ptr{Void}, event_ptr::Ptr{SDL_Event})::Cint
    global winWidth, winHeight, cam
    event = unsafe_load(event_ptr, 1)
    t = getEventType(event)
    if (t == SDL_WINDOWEVENT)
        e = event._SDL_Event
        winEvent = UInt8(parse("0b"*join(map(bits,  e[13:-1:13]))))
        if (winEvent == SDL_WINDOWEVENT_RESIZED)
            winID = UInt32(parse("0b"*join(map(bits,  e[12:-1:9]))))
            eventWin = SDL_GetWindowFromID(winID);
            if (eventWin == data_ptr)
                w,h,w_highDPI,h_highDPI = getWindowSize(eventWin)
                winWidth, winHeight = w, h
                winWidth_highDPI, winHeight_highDPI = w_highDPI, h_highDPI
                cam.w, cam.h = winWidth_highDPI, winHeight_highDPI
                recenterButtons!()
                # Restart timer so it doesn't have a HUGE frame.
                start!(timer)
            end
        end
    end
    return 0
end#

function getWindowSize(win)
    w,h,w_highDPI,h_highDPI = Int32[0],Int32[0],Int32[0],Int32[0]
    SDL_GetWindowSize(win, w, h)
    SDL_GL_GetDrawableSize(win, w_highDPI, h_highDPI)
    return w[],h[],w_highDPI[],h_highDPI[]
end

paddleSpeed = 1000
ballSpeed = 250
paddleA = Paddle(WorldPos(0,200),200)
paddleB = Paddle(WorldPos(0,-200),200)
ball = Ball(WorldPos(0,0), Vector2D(0,-ballSpeed))
cam = nothing
scoreA = 0
scoreB = 0
winningScore = 11
paused_ = true # start paused to show the initial menu.
paused = Ref(paused_)
game_started_ = true # start paused to show the initial menu.
game_started = Ref(game_started_)
playing_ = true
playing = Ref(playing_)
debugText = false
audioEnabled = true
last_10_frame_times = [1.]
timer = Timer()
i = 1
function runSceneGameLoop(scene, renderer, win, inSceneVar::Ref{Bool})
    global last_10_frame_times, i
    start!(timer)
    while (inSceneVar[])
        # Handle Events
        hadEvents = true
        while hadEvents
            e,hadEvents = pollEvent!()
            t = getEventType(e)
            handleEvents!(scene,e,t)
        end

        # Render
        render(scene, renderer, win)
        SDL_RenderPresent(renderer)

        # Update
        dt = elapsed(timer)
        start!(timer)
        last_10_frame_times = push!(last_10_frame_times, dt)
        if length(last_10_frame_times) > 10; shift!(last_10_frame_times) ; end
        if (debugText) renderFPS(renderer,last_10_frame_times) end

        performUpdates!(scene, dt)
        #sleep(0.01)

        if (playing[] == false)
            SDL_QuitAll()
            quit()
        end

        i += 1
    end
end
function performUpdates!(scene, dt) end  # default


function pollEvent!()
    #SDL_Event() = [SDL_Event(NTuple{56, Uint8}(zeros(56,1)))]
    SDL_Event() = Array{UInt8}(zeros(56))
    e = SDL_Event()
    success = (SDL_PollEvent(e) != 0)
    return e,success
end
function getEventType(e::Array{UInt8})
    # HAHA This is still pretty janky, but I guess that's all you can do w/ unions.
    bitcat(UInt32, e[4:-1:1])
end
function getEventType(e::SDL_Event)
    bitcat(UInt32, e._SDL_Event[4:-1:1])
end

function bitcat(outType::Type{T}, arr)::T where T<:Number
    out = zero(outType)
    for x in arr
        out = out << sizeof(x)*8
        out |= x
    end
    out
end

type GameScene
    #ball
end

function handleEvents!(scene::GameScene, e,t)
    global playing,paused
    # Handle Events
    if (t == SDL_KEYDOWN || t == SDL_KEYUP);  handleKeyPress(e,t);
    elseif (t == SDL_QUIT);  SDL_Quit(); playing[] = false;
    end
end


function render(scene::GameScene, renderer, win)
    global ball,scoreA,scoreB,last_10_frame_times,paused,playing

    if (paused[])
         pause!(timer)
         enterPauseGameLoop(renderer,win)
         unpause!(timer)
         buttons[1].text = "Continue" # After starting game
    end

    SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255)
    SDL_RenderClear(renderer)

    renderScore(renderer)
    render(paddleA, cam, renderer)
    render(paddleB, cam, renderer)

    # Hack: check if it's a winner after rendering everything (except ball) so
    # the final score shows up on winner screen.
    if (scoreA >= winningScore)  enterWinnerGameLoop(renderer,win, "Player 1")
    elseif (scoreB >= winningScore)  enterWinnerGameLoop(renderer,win, "Player 2")
    end

    # Hack: Render the ball *after* checking if it's a winner, so that way the
    # ball doesn't show up on the winning player screen.
    render(ball, cam, renderer)
end

function performUpdates!(scene::GameScene, dt)
    global ball, paddleA, paddleB, scoreB, scoreA
    #if didCollide(ball, paddleA, dt);
    #     ball.pos = ball.pos - ball.vel  # undo update
    #     collide!(ball, paddleA);
    #end
    #if didCollide(ball, paddleB, dt);
    #     ball.pos = ball.pos - ball.vel  # undo update
    #     collide!(ball, paddleB);
    #end
    if willCollide(ball, paddleA, dt); collide!(ball, paddleA); end
    if willCollide(ball, paddleB, dt); collide!(ball, paddleB); end
    if (willCollide(ball, paddleA,dt) || willCollide(ball, paddleB,dt))
        # STUCK GOING TOO FAST
        slowed_dt = dt
        while (willCollide(ball, paddleA, slowed_dt) || willCollide(ball, paddleB, slowed_dt))
            slowed_dt *= .1
        end
        update!(ball, slowed_dt)
    else
        update!(ball, dt)
    end
    update!(paddleA, paddleAKeys, dt)
    update!(paddleB, paddleBKeys, dt)
end

function enterWinnerGameLoop(renderer,win, winnerName)
    global paused
    paused[] = true
    sshot = getScreenshot(renderer)
    buttons[1].text = "New Game"
    scene = PauseScene(sshot, "$winnerName wins!!", "")
    runSceneGameLoop(scene, renderer, win, paused)
    SDL_FreeSurface(scene.sshot)

    # --------- Reset everything
    resetGame()
end
function resetGame()
    global scoreA,scoreB
    scoreB = scoreA = 0
    ball.pos = WorldPos(0,0)
    ball.vel = Vector2D(0,-ballSpeed)
    buttons[1].text = "Continue" # After starting game
end

mutable struct KeyControls
    rightDown::Bool
    leftDown::Bool
    KeyControls() = new(false,false)
end
const paddleAKeys = KeyControls()
const paddleBKeys = KeyControls()
mutable struct GameControls
    escapeDown::Bool
    GameControls() = new(false)
end
const gameControls = GameControls()
function handleKeyPress(e,t)
    global paused,debugText
    keySym = UInt32(parse("0b"*join(map(bits,  e[24:-1:21]))))
    keyDown = (t == SDL_KEYDOWN)
    if (keySym == SDLK_LEFT)
        paddleBKeys.leftDown = keyDown
    elseif (keySym == SDLK_RIGHT)
        paddleBKeys.rightDown = keyDown
    elseif (keySym == SDLK_a)
        paddleAKeys.leftDown = keyDown
    elseif (keySym == SDLK_d)
        paddleAKeys.rightDown = keyDown
    elseif (keySym == SDLK_ESCAPE)
        if (!gameControls.escapeDown && keyDown)
            #if game_started[]  # Escape shouldn't start the game.
                paused[] = !paused[]
            #end
        end
        gameControls.escapeDown = keyDown
    elseif (keySym == SDLK_BACKQUOTE)
        keyDown && (debugText = !debugText)
    end
end

function getScreenshot(renderer)
    sshot_ptr = SDL_CreateRGBSurface(UInt32(0), convert.(Int32,
                                 (cam.w, cam.h, 32))...,
                      0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    sshot = unsafe_load(sshot_ptr, 1)
    SDL_RenderReadPixels(renderer, C_NULL, SDL_PIXELFORMAT_ARGB8888, sshot.pixels, sshot.pitch);
    return SDL_CreateTextureFromSurface(renderer, sshot_ptr)
end

buttons = [
         # Note that the text changes to "Continue" after first press.
         Button(UIPixelPos(0,0), 200, 30, "New Game", 20,
                  ()->(global paused,game_started; paused[] = false; game_started[] = true;)),
         Button(UIPixelPos(0,0), 200, 30, "Sound on/off", 20,
                  ()->(toggleAudio())),
         Button(UIPixelPos(0,0), 200, 30, "Quit", 20,
                  ()->(global paused, playing; paused[] = playing[] = false;))
     ]
function recenterButtons!()
    global buttons
    buttons[1].pos = screenOffsetFromCenter(0,56)
    buttons[2].pos = screenOffsetFromCenter(0,90)
    buttons[3].pos = screenOffsetFromCenter(0,124)
end
function toggleAudio()
    global audioEnabled;
    audioEnabled = !audioEnabled;
    if (audioEnabled) Mix_ResumeMusic()
    else  Mix_PauseMusic()
    end
end
type PauseScene
    sshot::Ptr{SDL_Texture}
    titleText::String
    subtitleText::String
end
function enterPauseGameLoop(renderer,win)
    global paused
    sshot = getScreenshot(renderer)
    scene = PauseScene(sshot, "$kGAME_NAME", "Main Menu")
    runSceneGameLoop(scene, renderer, win, paused)
    SDL_FreeSurface(scene.sshot)
end
function handleEvents!(scene::PauseScene, e,t)
    global playing,paused
    # Handle Events
    if (t == SDL_KEYDOWN || t == SDL_KEYUP);  handleKeyPress(e,t);
    elseif (t == SDL_MOUSEBUTTONUP || t == SDL_MOUSEBUTTONDOWN)
        b = handleMouseClickButton!(e,t);
        if (b != nothing); b.callBack(); end
    elseif (t == SDL_QUIT);
        playing[]=false; paused[]=false;
    end
end

function render(scene::PauseScene, renderer, win)
    screenRect = SDL_Rect(0,0, cam.w, cam.h)
    SDL_RenderCopy(renderer, scene.sshot, Ref(screenRect), Ref(screenRect))
    SDL_SetRenderDrawColor(renderer, 200, 200, 200, 200) # transparent
    SDL_RenderFillRect(renderer, Ref(screenRect))
    renderText(renderer, cam, scene.titleText, screenOffsetFromCenter(0,-40); fontSize=40)
    renderText(renderer, cam, scene.subtitleText, screenOffsetFromCenter(0,0); fontSize = 26)
    for b in buttons
        render(b, cam, renderer)
    end
    renderText(renderer, cam, "Theme music copyright http://www.freesfx.co.uk", UIPixelPos(screenCenterX(), winHeight - 10); fontSize=10)
end

fonts = Dict()
#font = TTF_OpenFont("../assets/fonts/Bitstream-Vera-Sans-Mono/VeraMono.ttf", 23)
function renderScore(renderer)
   txt = "Player 1: $scoreA     Player 2: $scoreB"
    renderText(renderer, cam, txt, UIPixelPos(screenCenterX(), 20))
end
function renderFPS(renderer,last_10_frame_times)
    fps = Int(floor(1./mean(last_10_frame_times)))
    txt = "FPS: $fps"
    renderText(renderer, cam, txt, UIPixelPos(winWidth*1/5, 200))
end
function renderText(renderer, cam::Camera, txt, pos::UIPixelPos
                     ; fontName = "$assets/fonts/FiraCode/ttf/FiraCode-Regular.ttf", fontSize=26)
   scale = worldScale(cam)
   fontSize = scale*fontSize
   fontKey = (fontName, fontSize)
   if haskey(fonts, fontKey)
       font = fonts[fontKey]
   else
       font = TTF_OpenFont(fontKey...)
       fonts[fontKey] = font
   end
   text = TTF_RenderText_Blended(font, txt, SDL_Color(20,20,20,255))
   tex = SDL_CreateTextureFromSurface(renderer,text)

   fx,fy = Cint[1], Cint[1]
   TTF_SizeText(font, txt, pointer(fx), pointer(fy))
   fx,fy = fx[1],fy[1]

   screenPos = uiToScreen(pos, cam)
   SDL_RenderCopy(renderer, tex, C_NULL, pointer_from_objref(SDL_Rect(Int(floor(screenPos.x-fx/2.)), Int(floor(screenPos.y-fy/2.)),fx,fy)))
   SDL_FreeSurface(tex)
end

clickedButton = nothing
gEvent = nothing
e = gEvent
function handleMouseClickButton!(e, clickType)
    global gEvent,clickedButton
    gEvent = e
    mx = Int64(parse("0b"*join(map(bits,  e[24:-1:21]))));
    my = Int64(parse("0b"*join(map(bits,  e[28:-1:25]))));
    didClickButton = false
    for b in buttons
        if mouseOnButton(UIPixelPos(mx,my),b,cam)
            if (clickType == SDL_MOUSEBUTTONDOWN)
                clickedButton = b
                didClickButton = true
            elseif clickedButton == b && clickType == SDL_MOUSEBUTTONUP
                clickedButton = nothing
                didClickButton = true
                return b
            end
        end
    end
    if clickedButton != nothing && clickType == SDL_MOUSEBUTTONUP && didClickButton == false
        clickedButton = nothing
    end
    return nothing
end

function mouseOnButton(m::UIPixelPos, b::Button, cam)
    println("m: $m")
    println("b: $(b.pos)")
    topLeft = UIPixelPos(b.pos.x - b.w/2., b.pos.y - b.h/2.)
    println("s: $(topLeft)")
    if m.x > topLeft.x && m.x <= topLeft.x + b.w &&
        m.y > topLeft.y && m.y <= topLeft.y + b.h
        return true
    end
    return false
end

function change_dir_if_bundle()
    # julia_cmd() shows how this julia process was invoked.
    cmd_strings = Base.shell_split(string(Base.julia_cmd()))
    # The first string is the full path to this executable.
    full_binary_name = cmd_strings[1][2:end] # (remove leading backtick)
    if is_apple()
        # On Apple devices, if this is running inside a .app bundle, it starts
        # us with pwd="$HOME". Change dir to the Resources dir instead.
        # Can tell if we're in a bundle by what the full_binary_name ends in.
        m = match(r".app/Contents/MacOS/[^/]+$", full_binary_name)
        if m != nothing
            resources_dir = full_binary_name[1:findlast("/MacOS", full_binary_name)[1]-1]*"/Resources"
            cd(resources_dir)
        end
    end
    println("new pwd: $(pwd())")
end
function load_audio_files()
    global pingSound, scoreSound
    pingSound = Mix_LoadWAV( "$assets/ping.wav" );
    scoreSound = Mix_LoadWAV( "$assets/score.wav" );
end
#displayIndex = 0
#function MySDL_GetDisplayDPI(displayIndex)
#    const kSysDefaultDpi =
#        if is_apple()
#            Cfloat(72.0)
#        elseif is_windows()
#            Cfloat(96.0)
#        else
#            error("No system default DPI set for this platform.");
#        end
#
#    dpi = Cfloat[0.0]
#    hdpi = Cfloat[0.0]
#    vdpi = Cfloat[0.0]
#    succ = SDL_GetDisplayDPI(Int32(0), dpi, hdpi, vdpi)
#    if (succ != 0)
#        # Failed to get DPI, so just return the default value.
#        dpi[] = kSysDefaultDpi;
#    end
#    dpi[]
#    hdpi[]
#    vdpi[]
#end

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    global paused,game_started, cam
    SDL_JL_Init()
    change_dir_if_bundle()
    load_audio_files()
    music = Mix_LoadMUS( "$assets/music.wav" );
    win,renderer = makeWinRenderer()
    cam = Camera(WorldPos(0,0), winWidth_highDPI, winHeight_highDPI)
    recenterButtons!()
    paused[]=true
    game_started[]=false
    ball.pos = WorldPos(0,0)
    ball.vel = Vector2D(0,-ballSpeed)
    # Warm up
    for i in 1:10
        pollEvent!()
        SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255)
        SDL_RenderClear(renderer)
        SDL_RenderPresent(renderer)
        #sleep(0.01)
    end
    audioEnabled && Mix_PlayMusic( music, Int32(-1) )
    scene = GameScene()
    runSceneGameLoop(scene, renderer, win, playing)
    return 0
end

# julia_main([""])

""
#end # module
