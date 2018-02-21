struct ScreenPixelPos  # 0,0 == top-left
    x::Int
    y::Int
end
ScreenPixelPos(x::Number, y::Number) = ScreenPixelPos(convert.(Int, floor.((x,y)))...)
struct UIPixelPos  # 0,0 == top-left (Same as ScreenPixelPos but not scaled.)
    x::Int
    y::Int
end
UIPixelPos(x::Number, y::Number) = UIPixelPos(convert.(Int, floor.((x,y)))...)

mutable struct Camera
    pos::WorldPos
    w::Int
    h::Int
end
Camera() = Camera(WorldPos(0,0),100,100)

screenCenter() = UIPixelPos(winWidth/2, winHeight/2)
screenCenterX() = winWidth/2
screenCenterY() = winHeight/2
screenOffsetFromCenter(x::Int,y::Int) = UIPixelPos(screenCenterX()+x,screenCenterY()+y)

worldScale(c::Camera) = cam.w / winWidth;
function worldToScreen(p::WorldPos, c::Camera)
    scale = worldScale(c)
    ScreenPixelPos(
        floor(c.w/2. + scale*p.x), floor(c.h/2. - scale*p.y))
end
function uiToScreen(p::UIPixelPos, c::Camera)
    scale = worldScale(c)
    ScreenPixelPos(floor(scale*p.x), floor(scale*p.y))
end
function screenToUI(p::ScreenPixelPos, c::Camera)
    scale = worldScale(c)
    ScreenPixelPos(floor(p.x/scale), floor(p.y/scale))
end
function screenScaleDims(w,h,c::Camera)
    scale = worldScale(c)
    scale*w, scale*h
end

function render(o::Ball, cam::Camera, renderer)
    const ballW = ballWidth; const ballH = ballWidth;
    topLeft = WorldPos(o.pos.x - ballW/2., o.pos.y + ballH/2.)
    screenPos = worldToScreen(topLeft, cam)
    rect = SDL_Rect(screenPos.x, screenPos.y, screenScaleDims(ballW, ballH, cam)...)
    SDL_SetRenderDrawColor(renderer, 20, 50, 105, 255)
    SDL_RenderFillRect(renderer, Ref(rect) )
end
function render(o::Paddle, cam::Camera, renderer)
    const paddleW = o.length; const paddleH = 15;
    # Move up/down so the edge matches the "center" of paddle.
    edgeShift = if o.pos.y > 0; paddleH/2.; else -paddleH/2.; end
    topLeft = WorldPos(o.pos.x - paddleW/2., o.pos.y + paddleH/2. + edgeShift)
    screenPos = worldToScreen(topLeft, cam)
    rect = SDL_Rect(screenPos.x, screenPos.y, screenScaleDims(paddleW, paddleH, cam)...)
    SDL_SetRenderDrawColor(renderer, 120, 0, 0, 255)
    SDL_RenderFillRect(renderer, Ref(rect) )
end

mutable struct Button
    pos::UIPixelPos
    w::Int
    h::Int
    text::String
    fontSize::Int
    callBack
end

function render(b::Button, cam::Camera, renderer)
    topLeft = UIPixelPos(b.pos.x - b.w/2., b.pos.y - b.h/2.)
    screenPos = uiToScreen(topLeft, cam)
    rect = SDL_Rect(screenPos.x, screenPos.y, screenScaleDims(b.w, b.h, cam)...)
    if clickedButton == b
        x,y = Int[0], Int[0]
        SDL_GetMouseState(pointer(x), pointer(y))
        if mouseOnButton(UIPixelPos(x[],y[]),b,cam)
            SDL_SetRenderDrawColor(renderer, 30, 30, 130, 255)
        else
            SDL_SetRenderDrawColor(renderer, 70, 30, 170, 255)
        end
    else
        SDL_SetRenderDrawColor(renderer, 80, 80, 180, 255)
    end
    SDL_RenderFillRect(renderer, Ref(rect) )
    renderText(renderer, cam, b.text, b.pos; fontSize = b.fontSize)
end
