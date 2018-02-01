#module PongMain

#using SDL2
include("/Users/daly/.julia/v0.6/SDL2/src/SDL2.jl")

include("timing.jl")
include("objects.jl")
include("display.jl")

const winWidth, winHeight = 800, 600
function makeWinRenderer()
    win = SDL_CreateWindow("Hello World!", Int32(100), Int32(100), Int32(winWidth), Int32(winHeight), UInt32(SDL_WINDOW_SHOWN))
    SDL_SetWindowResizable(win,true)

    renderer = SDL_CreateRenderer(win, Int32(-1), UInt32(SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC))
    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)
    #renderer = SDL_CreateRenderer(win, Int32(-1), Int32(0))
    return win,renderer
end

paddleSpeed = 1000
ballSpeed = 250
paddleA = Paddle(WorldPos(0,200),200)
paddleB = Paddle(WorldPos(0,-200),200)
ball = Ball(WorldPos(0,0), Vector2D(0,-ballSpeed))
cam = Camera(WorldPos(0,0), winWidth, winHeight)
scoreA = 0
scoreB = 0
paused = false
last_10_frame_times = [1.]
timer = Timer()
function runApp(win, renderer, iters = nothing)
    global ball,scoreA,scoreB,last_10_frame_times,paused
    start!(timer)
    i = 1
    while iters == nothing || i < iters
        hadEvents = true
        while hadEvents
            # Handle Events
            e,hadEvents = pollEvent!()
            t = getEventType(e)
            if (t == SDL_KEYDOWN || t == SDL_KEYUP);  handleKeyPress(e,t);
            elseif (t == SDL_QUIT);  SDL_Quit(); return;
            end

            if (paused)
                 pause!(timer)
                 enterPauseGameLoop()
                 unpause!(timer)
            end

            # Render
            SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255)
            SDL_RenderClear(renderer)

            render(ball, cam, renderer)
            render(paddleA, cam, renderer)
            render(paddleB, cam, renderer)
            renderScore()
            renderFPS(last_10_frame_times)

            SDL_RenderPresent(renderer)

            # Update
            dt = elapsed(timer)
            start!(timer)
            last_10_frame_times = push!(last_10_frame_times, dt)
            if length(last_10_frame_times) > 10; shift!(last_10_frame_times) ; end

            performUpdates!(dt)

            i += 1
        end
        sleep(0.01)
    end
end

function pollEvent!()
    #SDL_Event() = [SDL_Event(NTuple{56, Uint8}(zeros(56,1)))]
    SDL_Event() = Array{UInt8}(zeros(56))
    e = SDL_Event()
    success = (SDL_PollEvent(e) != 0)
    return e,success
end
function getEventType(e)
    # HAHA This is janky as hell. There has to be a better way to implement a Union...
    x = UInt32(parse("0b"*join(map(bits,  e[4:-1:1]))))
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
        ball = Ball(WorldPos(0,0), Vector2D(rand(-ballSpeed:ballSpeed),-ballSpeed))
    elseif ball.pos.y < -winHeight/2.
        scoreA += 1
        ball = Ball(WorldPos(0,0), Vector2D(rand(-ballSpeed:ballSpeed),-ballSpeed))
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
    global paused
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
    end
end

function getScreenshot(renderer)
    sshot_ptr = SDL_CreateRGBSurface(UInt32(0), convert.(Int32, (winWidth,
                     winHeight, 32))..., 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
    sshot = unsafe_load(sshot_ptr, 1)
    SDL_RenderReadPixels(renderer, C_NULL, SDL_PIXELFORMAT_ARGB8888, sshot.pixels, sshot.pitch);
    SDL_CreateTextureFromSurface(renderer, sshot_ptr)
end

function enterPauseGameLoop()
    sshot = getScreenshot(renderer)
    global paused
    while (paused)
        hadEvents = true
        while hadEvents
            # Handle Events
            e,hadEvents = pollEvent!()
            t = getEventType(e)
            if (t == SDL_KEYDOWN || t == SDL_KEYUP);  handleKeyPress(e,t);
            elseif (t == SDL_QUIT);  SDL_Quit(); return;
            end

            # Render
            screenRect = SDL_Rect(0,0, winWidth, winHeight)
            SDL_RenderCopy(renderer, sshot, Ref(screenRect), Ref(screenRect))
            SDL_SetRenderDrawColor(renderer, 200, 200, 200, 200) # transparent
            SDL_RenderFillRect(renderer, Ref(screenRect))
            renderText(renderer, "PAUSED", ScreenPixelPos(winWidth/2, winHeight/2))
            SDL_RenderPresent(renderer)

            # Update
        end
        sleep(0.01)
    end
end

font = TTF_OpenFont("../assets/fonts/FiraCode/ttf/FiraCode-Regular.ttf", 26)
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
function renderText(renderer, txt, pos)
   text = TTF_RenderText_Blended(font, txt, SDL_Color(20,20,20,255))
   tex = SDL_CreateTextureFromSurface(renderer,text)

   fx,fy = Int[1], Int[1]
   TTF_SizeText(font, txt, pointer(fx), pointer(fy))
   fx,fy = fx[1],fy[1]

   SDL_RenderCopy(renderer, tex, C_NULL, pointer_from_objref(SDL_Rect(Int(floor(pos.x-fx/2.)), Int(floor(pos.y-fy/2.)),fx,fy)))
   SDL_FreeSurface(tex)

end

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    win,renderer = makeWinRenderer()
    SDL_GetWindowSize(win, pointer([winWidth]), pointer([winHeight]))
    ball.pos = WorldPos(0,0)
    ball.vel = Vector2D(0,-ballSpeed)
    runApp(win, renderer)
    return 0
end

#end # module

# PongMain.julia_main(String[])
