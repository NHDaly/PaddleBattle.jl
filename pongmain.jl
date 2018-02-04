#module PongMain

#using SDL2
include("/Users/daly/.julia/v0.6/SDL2/src/SDL2.jl")

include("timing.jl")
include("objects.jl")
include("display.jl")

const kGAME_NAME = "Power Pong!"

winWidth, winHeight = Int32(800), Int32(600)
function makeWinRenderer()
    win = SDL_CreateWindow("Hello World!", Int32(100), Int32(100), winWidth, winHeight, UInt32(SDL_WINDOW_SHOWN))
    SDL_SetWindowResizable(win,true)
    SDL_AddEventWatch(cfunction(resizingEventWatcher, Cint, Tuple{Ptr{Void}, Ptr{SDL_Event}}), win);

    renderer = SDL_CreateRenderer(win, Int32(-1), UInt32(SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC))
    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)
    #renderer = SDL_CreateRenderer(win, Int32(-1), Int32(0))
    return win,renderer
end

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
                w,h = Int32[0],Int32[0]
                SDL_GetWindowSize(eventWin, w, h)
                winWidth, winHeight = w[1], h[1]
                cam.w, cam.h = w[1], h[1]
                # Restart timer so it doesn't have a HUGE frame.
                start!(timer)
            end
        end
    end
    return 0
end


paddleSpeed = 1000
ballSpeed = 250
paddleA = Paddle(WorldPos(0,200),200)
paddleB = Paddle(WorldPos(0,-200),200)
ball = Ball(WorldPos(0,0), Vector2D(0,-ballSpeed))
cam = Camera(WorldPos(0,0), winWidth, winHeight)
scoreA = 0
scoreB = 0
paused = true # start paused to show the initial menu.
playing = true
debugText = false
last_10_frame_times = [1.]
timer = Timer()
function runApp(win, renderer, iters = nothing)
    global ball,scoreA,scoreB,last_10_frame_times,paused,playing
    SDL_PumpEvents()
    start!(timer)
    i = 1
    while playing && (iters == nothing || i < iters)
        # Handle Events
        hadEvents = true
        while hadEvents
            e,hadEvents = pollEvent!()
            t = getEventType(e)
            if (t == SDL_KEYDOWN || t == SDL_KEYUP);  handleKeyPress(e,t);
            elseif (t == SDL_QUIT);  SDL_Quit(); playing = false;
            end

            if (paused)
                 pause!(timer)
                 enterPauseGameLoop()
                 unpause!(timer)
                 buttons[1].text = "Continue" # After starting game
            end
        end

        # Render
        SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255)
        SDL_RenderClear(renderer)

        render(ball, cam, renderer)
        render(paddleA, cam, renderer)
        render(paddleB, cam, renderer)
        renderScore()
        if (debugText) renderFPS(last_10_frame_times) end

        SDL_RenderPresent(renderer)

        # Update
        dt = elapsed(timer)
        start!(timer)
        last_10_frame_times = push!(last_10_frame_times, dt)
        if length(last_10_frame_times) > 10; shift!(last_10_frame_times) ; end

        performUpdates!(dt)

        i += 1
        #sleep(0.01)
    end
    if (playing == false)
        SDL_Quit()
        quit()
    end
end

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

function performUpdates!(dt)
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
    if ball.pos.y > winHeight/2.
        scoreB += 1
        ball = Ball(WorldPos(0,0), Vector2D(rand(-ballSpeed:ballSpeed), rand([ballSpeed,-ballSpeed])))
    elseif ball.pos.y < -winHeight/2.
        scoreA += 1
        ball = Ball(WorldPos(0,0), Vector2D(rand(-ballSpeed:ballSpeed), rand([ballSpeed,-ballSpeed])))
    end
    if ball.pos.x > winWidth/2.
        ball.vel = Vector2D(-abs(ball.vel.x), ball.vel.y)
    elseif ball.pos.x < -winWidth/2.
        ball.vel = Vector2D(abs(ball.vel.x), ball.vel.y)
    end
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
            paused = !paused
        end
        gameControls.escapeDown = keyDown
    elseif (keySym == SDLK_BACKQUOTE)
        keyDown && (debugText = !debugText)
    end
end

function getScreenshot(renderer)
    sshot_ptr = SDL_CreateRGBSurface(UInt32(0), convert.(Int32, (winWidth,
                     winHeight, 32))..., 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    sshot = unsafe_load(sshot_ptr, 1)
    SDL_RenderReadPixels(renderer, C_NULL, SDL_PIXELFORMAT_ARGB8888, sshot.pixels, sshot.pitch);
    return SDL_CreateTextureFromSurface(renderer, sshot_ptr)
end

buttons = [
         # Note that the text changes to "Continue" after first press.
         Button(WorldPos(0, -56), 200, 30, "New Game", 20,
                  ()->(global paused; paused = false;)),
         Button(WorldPos(0, -90), 200, 30, "Quit", 20,
                  ()->(global paused, playing; paused = playing = false;))
     ]
function enterPauseGameLoop()
    sshot = getScreenshot(renderer)
    global paused,playing
    while (paused)
        # Handle Events
        hadEvents = true
        while hadEvents
            e,hadEvents = pollEvent!()
            t = getEventType(e)
            if (t == SDL_KEYDOWN || t == SDL_KEYUP);  handleKeyPress(e,t);
            elseif (t == SDL_MOUSEBUTTONUP || t == SDL_MOUSEBUTTONDOWN)
                 b = handleMouseClickButton!(e,t);
                 if (b != nothing); b.callBack(); end
            elseif (t == SDL_QUIT);
                  playing=false; paused=false;
            end
        end

        # Render
        screenRect = SDL_Rect(0,0, winWidth, winHeight)
        SDL_RenderCopy(renderer, sshot, Ref(screenRect), Ref(screenRect))
        SDL_SetRenderDrawColor(renderer, 200, 200, 200, 200) # transparent
        SDL_RenderFillRect(renderer, Ref(screenRect))
        renderText(renderer, "$kGAME_NAME", ScreenPixelPos(winWidth/2, winHeight/2 - 40); fontSize=40)
        renderText(renderer, "Main Menu", ScreenPixelPos(winWidth/2, winHeight/2); fontSize = 26)
        for b in buttons
            render(renderer, b)
        end
        SDL_RenderPresent(renderer)

        # Update
        #sleep(0.01)
    end
    SDL_FreeSurface(sshot)
end

fonts = Dict()
#font = TTF_OpenFont("../assets/fonts/Bitstream-Vera-Sans-Mono/VeraMono.ttf", 23)
function renderScore()
   txt = "Player 1: $scoreA     Player 2: $scoreB"
    renderText(renderer, txt, ScreenPixelPos(winWidth/2, 20))
end
function renderFPS(last_10_frame_times)
    fps = Int(floor(1./mean(last_10_frame_times)))
    txt = "FPS: $fps"
    renderText(renderer, txt, ScreenPixelPos(winWidth*1/5, 200))
end
function renderText(renderer, txt, pos
                     ; fontName = "../assets/fonts/FiraCode/ttf/FiraCode-Regular.ttf", fontSize=26)
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

   SDL_RenderCopy(renderer, tex, C_NULL, pointer_from_objref(SDL_Rect(Int(floor(pos.x-fx/2.)), Int(floor(pos.y-fy/2.)),fx,fy)))
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
    #println(NTuple{56, UInt8}(e))
    println("$mx, $my")
    didClickButton = false
    for b in buttons
        topLeft = WorldPos(b.pos.x - b.w/2., b.pos.y + b.h/2.)
        screenPos = worldToScreen(topLeft, cam)
        if mx > screenPos.x && mx <= screenPos.x + b.w &&
           my > screenPos.y && my <= screenPos.y + b.h
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

win,renderer = makeWinRenderer()
Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    global paused
    paused=true
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
    runApp(win, renderer)
    return 0
end

#end # module
