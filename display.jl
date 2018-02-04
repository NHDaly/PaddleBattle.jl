struct ScreenPixelPos  # 0,0 == top-left
    x::Int
    y::Int
end
ScreenPixelPos(x::Number, y::Number) = ScreenPixelPos(convert.(Int, floor.((x,y)))...)

mutable struct Camera
    pos::WorldPos
    w::Int
    h::Int
end
Camera() = Camera(WorldPos(0,0),100,100)

worldToScreen(p::WorldPos, c::Camera) = ScreenPixelPos(floor(c.w/2. + p.x), floor(c.h/2. - p.y))

function render(o::Ball, cam::Camera, renderer)
    const ballW = ballWidth; const ballH = ballWidth;
    topLeft = WorldPos(o.pos.x - ballW/2., o.pos.y + ballH/2.)
    screenPos = worldToScreen(topLeft, cam)
    rect = SDL_Rect(screenPos.x, screenPos.y, ballW, ballH)
    SDL_SetRenderDrawColor(renderer, 20, 50, 105, 255)
    SDL_RenderFillRect(renderer, Ref(rect) )
end
function render(o::Paddle, cam::Camera, renderer)
    const paddleW = o.length; const paddleH = 15;
    topLeft = WorldPos(o.pos.x - paddleW/2., o.pos.y + paddleH/2.)
    screenPos = worldToScreen(topLeft, cam)
    rect = SDL_Rect(screenPos.x, screenPos.y, paddleW, paddleH)
    SDL_SetRenderDrawColor(renderer, 120, 0, 0, 255)
    SDL_RenderFillRect(renderer, Ref(rect) )
end

mutable struct Button
    pos::WorldPos
    w::Int
    h::Int
    text::String
    fontSize::Int
    callBack
end

function render(renderer, b::Button)
    topLeft = WorldPos(b.pos.x - b.w/2., b.pos.y + b.h/2.)
    screenPos = worldToScreen(topLeft, cam)
    rect = SDL_Rect(screenPos.x, screenPos.y, b.w, b.h)
    if clickedButton == b
        SDL_SetRenderDrawColor(renderer, 130, 30, 30, 255)
    else
        SDL_SetRenderDrawColor(renderer, 180, 80, 80, 255)
    end
    SDL_RenderFillRect(renderer, Ref(rect) )
    renderText(renderer, b.text, worldToScreen(b.pos, cam); fontSize = b.fontSize)
end
