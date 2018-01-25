abstract type GameObject end

struct WorldPos  # 0,0 == middle
    x::Float64
    y::Float64
end
struct Vector2D
    x::Float64
    y::Float64
end
import Base.*, Base./, Base.-, Base.+
+(a::Vector2D, b::Vector2D) = Vector2D(a.x+b.x, a.y+b.y)
-(a::Vector2D, b::Vector2D) = Vector2D(a.x+b.x, a.y+b.y)
*(a::Vector2D, x::Number) = Vector2D(a.x*x, a.y*x)
/(a::Vector2D, x::Number) = Vector2D(a.x/x, a.y/x)
*(x::Number, a::Vector2D) = a*x
+(a::WorldPos, b::Vector2D) = WorldPos(a.x+b.x, a.y+b.y)
-(a::WorldPos, b::Vector2D) = WorldPos(a.x+b.x, a.y+b.y)
+(a::Vector2D, b::WorldPos) = WorldPos(a.x+b.x, a.y+b.y)
-(a::Vector2D, b::WorldPos) = WorldPos(a.x+b.x, a.y+b.y)

const ballWidth=10
mutable struct Ball
    pos::WorldPos
    vel::Vector2D
end
mutable struct Paddle
    pos::WorldPos
    length
end

collide(a::Ball, b::Paddle) = collide(b,a)
function collide(p::Paddle, b::Ball)
    xIncr = 2
    xSign = 1
    if b.pos.x - p.pos.x > p.length/4; # In right quarter
        if b.vel.x < 0 ; xSign=-1; end
    elseif b.pos.x - p.pos.x < -p.length/4; # In left
        xIncr *=-1; if b.vel.x > 0 ; xSign=-1; end
    else xIncr = 0;
    end
    b.vel = Vector2D(b.vel.x * xSign + xIncr, -b.vel.y)
end

isColliding(a::Ball, b::Paddle) = isColliding(b,a)
isColliding(a::Paddle, b::Ball) = (abs(a.pos.x - b.pos.x) < (a.length/2.+ballWidth/2)) && a.pos.y == b.pos.y

function update!(x::Ball)
    x.pos = x.pos + x.vel
end
function update!(x::Paddle, keys)
    if (keys.leftDown)
        x.pos = WorldPos(x.pos.x - paddleSpeed, x.pos.y)
    end
    if (keys.rightDown)
        x.pos = WorldPos(x.pos.x + paddleSpeed, x.pos.y)
    end
end
