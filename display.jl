struct ScreenPixelPos  # 0,0 == top-left
    x::Int
    y::Int
end

struct Camera
    pos::WorldPos
    w::Int
    h::Int
end
Camera() = Camera(WorldPos(0,0),100,100)

worldToScreen(p::WorldPos, c::Camera) = ScreenPixelPos(floor(c.w/2. + p.x), floor(c.h/2. - p.y))

function render(o::Ball, cam::Camera, renderer)
    const ballW = ballWidth; const ballH = ballWidth;
    center = WorldPos(o.pos.x - ballW/2., o.pos.y + ballH/2.)
    screenPos = worldToScreen(center, cam)
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
