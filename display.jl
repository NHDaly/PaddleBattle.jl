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
    enabled::Bool
    pos::UIPixelPos
    w::Int
    h::Int
    text::String
    fontSize::Int
    color::SDL_Color
    callBack
end

# pointwise subtraction with bounds checking (floors to 0)
-(a::SDL_Color, b::Int) = SDL_Color(a.r-min(b,a.r), a.g-min(b,a.g), a.b-min(b,a.b), a.a-min(b,a.a))
SDL_Color(1,5,1,1) - 2 == SDL_Color(0,3,0,0)

function render(b::Button, cam::Camera, renderer)
    if (!b.enabled)
         return
    end
    topLeft = UIPixelPos(b.pos.x - b.w/2., b.pos.y - b.h/2.)
    screenPos = uiToScreen(topLeft, cam)
    rect = SDL_Rect(screenPos.x, screenPos.y, screenScaleDims(b.w, b.h, cam)...)
    x,y = Int[0], Int[0]
    SDL_GetMouseState(pointer(x), pointer(y))
    color = b.color
    if clickedButton == b
        if mouseOnButton(UIPixelPos(x[],y[]),b,cam)
            color = b.color - 50
        else
            color = b.color - 30
        end
    else
        if mouseOnButton(UIPixelPos(x[],y[]),b,cam)
            color = b.color - 10
        end
    end
    SDL_SetRenderDrawColor(renderer, Int64(color.r), Int64(color.g), Int64(color.b), 255)
    SDL_RenderFillRect(renderer, Ref(rect) )
    renderText(renderer, cam, b.text, b.pos; fontSize = b.fontSize)
end
