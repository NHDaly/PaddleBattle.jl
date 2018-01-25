workspace()
using SDL2

include("objects.jl")
include("display.jl")

#SDL_Event() = [SDL_Event(NTuple{56, Uint8}(zeros(56,1)))]
SDL_Event() = Array{UInt8}(zeros(56))
e = SDL_Event()
winWidth, winHeight = 800, 600
function makeWinRenderer()
    win = SDL_CreateWindow("Hello World!", Int32(100), Int32(100), Int32(winWidth), Int32(winHeight), Int32(SDL_WINDOW_SHOWN))
    SDL_SetWindowResizable(win,true)

    renderer = SDL_CreateRenderer(win, Int32(-1), Int32(SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC))
    return win,renderer
end

win,renderer = makeWinRenderer()
SDL_GetWindowSize(win, pointer([winWidth]), pointer([winHeight]))
paddleSpeed = 10
paddleA = Paddle(WorldPos(0,200),200)
paddleB = Paddle(WorldPos(0,-200),200)
ball = Ball(WorldPos(0,0), Vector2D(0,-5))
cam = Camera(WorldPos(0,0), winWidth, winHeight)
SDL_PumpEvents()
scoreA = 0
scoreB = 0
function runApp(iters = nothing)
    global ball,scoreA,scoreB
    i = 1
    while iters == nothing || i < iters
        x,y = Int[1], Int[1]

        SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255)
        SDL_RenderClear(renderer)

        e = pollEvent!()
        t = getEventType(e)
        if (t == SDL_KEYDOWN);  handleKeyPress(e,t);
        elseif (t == SDL_KEYUP);  handleKeyPress(e,t);
        elseif (t == SDL_QUIT);  SDL_Quit(); return;
        end

        render(ball, cam, renderer)
        render(paddleA, cam, renderer)
        render(paddleB, cam, renderer)
        renderScore()

        SDL_RenderPresent(renderer)
        update!(ball)
        update!(paddleA, paddleAKeys)
        update!(paddleB, paddleBKeys)
        if isColliding(ball, paddleA); collide(ball, paddleA); end
        if isColliding(ball, paddleB); collide(ball, paddleB); end
        if ball.pos.y > winHeight/2.
            scoreB += 1
            ball = Ball(WorldPos(0,0), Vector2D(rand(-5:5),-5))
        elseif ball.pos.y < -winHeight/2.
            scoreA += 1
            ball = Ball(WorldPos(0,0), Vector2D(rand(-5:5),-5))
        end
        if ball.pos.x > winWidth/2. || ball.pos.x < -winWidth/2.
            ball.vel = Vector2D(-ball.vel.x, ball.vel.y)
        end
        sleep(0.0001)
        i += 1
    end
end

function pollEvent!()
    SDL_Event() = Array{UInt8}(zeros(56))
    e = SDL_Event()
    SDL_PollEvent(e)
    return e
end
function getEventType(e)
    # HAHA This is janky as hell. There has to be a better way to implement a Union...
    x = UInt32(parse("0b"*join(map(bits,  e[4:-1:1]))))
end


mutable struct KeyControls
    rightDown::Bool
    leftDown::Bool
    KeyControls() = new(false,false)
end
const paddleAKeys = KeyControls()
const paddleBKeys = KeyControls()
function handleKeyPress(e,t)
    keySym = UInt32(parse("0b"*join(map(bits,  e[24:-1:21]))))
    keyDown = (t == SDL_KEYDOWN)
    if (keySym == SDLK_LEFT)
        paddleAKeys.leftDown = keyDown
    elseif (keySym == SDLK_RIGHT)
        paddleAKeys.rightDown = keyDown
    elseif (keySym == SDLK_a)
        paddleBKeys.leftDown = keyDown
    elseif (keySym == SDLK_d)
        paddleBKeys.rightDown = keyDown
    end
end

font = TTF_OpenFont("../assets/fonts/FiraCode/ttf/FiraCode-Regular.ttf", 26)
#font = TTF_OpenFont("../assets/fonts/Bitstream-Vera-Sans-Mono/VeraMono.ttf", 23)
function renderScore()
   txt = "Player1: $scoreA     Player2: $scoreB"

   text = TTF_RenderText_Blended(font, txt, SDL_Color(20,20,20,255))
   tex = SDL_CreateTextureFromSurface(renderer,text)

   fx,fy = Int[1], Int[1]
   TTF_SizeText(font, txt, pointer(fx), pointer(fy))
   fx,fy = fx[1],fy[1]

   SDL_RenderCopy(renderer, tex, C_NULL, pointer_from_objref(SDL_Rect(winWidth/2-fx/2, 20,fx,fy)))
   SDL_FreeSurface(tex)

end

renderScore()

ball.pos = WorldPos(0,0)
ball.vel = Vector2D(0,-5)
runApp()
