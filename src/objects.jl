# Objects in the game and their supporting functions (update!, collide!, ...)

"""
    WorldPos(5.0,-200.0)
x,y float coordinates in the game world (not necessarily the same as pixel
coordinates on the screen).
"""
struct WorldPos  # 0,0 == middle
    x::Float64
    y::Float64
end
"""
    Vector2D(-2.5,1.0)
x,y vector representing direction in the game world. Could represent a velocity,
a distance, etc. Subtracting two `WorldPos`itions results in a `Vector2D`.
"""
struct Vector2D
    x::Float64
    y::Float64
end
import Base.*, Base./, Base.-, Base.+
+(a::Vector2D, b::Vector2D) = Vector2D(a.x+b.x, a.y+b.y)
-(a::Vector2D, b::Vector2D) = Vector2D(a.x-b.x, a.y-b.y)
*(a::Vector2D, x::Number) = Vector2D(a.x*x, a.y*x)
*(x::Number, a::Vector2D) = a*x
/(a::Vector2D, x::Number) = Vector2D(a.x/x, a.y/x)
+(a::WorldPos, b::Vector2D) = WorldPos(a.x+b.x, a.y+b.y)
-(a::WorldPos, b::Vector2D) = WorldPos(a.x-b.x, a.y-b.y)
+(a::Vector2D, b::WorldPos) = WorldPos(a.x+b.x, a.y+b.y)
-(a::Vector2D, b::WorldPos) = WorldPos(a.x-b.x, a.y-b.y)
-(a::WorldPos, b::WorldPos) = Vector2D(a.x-b.x, a.y-b.y)
-(x::WorldPos) = WorldPos(-x.x, -x.y)
-(x::Vector2D) = Vector2D(-x.x, -x.y)

mutable struct Ball
    pos::WorldPos
    vel::Vector2D
end
mutable struct Paddle
    pos::WorldPos
    vel::Vector2D
    length
end

pingSound = nothing
scoreSound = nothing

collide!(a::Ball, b::Paddle) = collide!(b,a)
function collide!(p::Paddle, b::Ball)
    xIncr = 100
    xSign = 1
    if b.pos.x - p.pos.x > p.length/4; # In right quarter
        if b.vel.x < 0 ; xSign=-1; end
    elseif b.pos.x - p.pos.x < -p.length/4; # In left
        xIncr *=-1; if b.vel.x > 0 ; xSign=-1; end
    else xIncr = 0;
    end
    b.vel = Vector2D(b.vel.x * xSign + xIncr, -b.vel.y)

    audioEnabled && SDL2.Mix_PlayChannel( Int32(-1), pingSound, Int32(0) )
end

"""
    LineSegment(WorldPos(0,0), WorldPos(1,1))
Line segment used for collision detection algorithm.
"""
struct LineSegment
     a::WorldPos
     b::WorldPos
end
""" Will they collide on the next update? """
willCollide(b::Ball, p::Paddle, dt) = willCollide(p,b,dt)
function willCollide(p::Paddle, b::Ball, dt)
     # If the ball is in the right X-axis vicinity of the paddle.
    if (abs(p.pos.x - b.pos.x) <= (p.length/2.0+ballWidth/2.0+abs(b.vel.x)*ballWidth))
        l = LineSegment(b.pos, b.pos+b.vel*dt) # If next update will bring collision.
        return isColliding(p, l, ballWidth)  # will it cross the paddle in the Y-axis
    else
        return false
    end
end
function isColliding(p::Paddle, l::LineSegment, width)
    v = l.b - l.a
    if v.y != 0
        c0 = (p.pos.y - l.a.y) / v.y
        if !(0.0 <= c0 <= 1.0) return false end
        lc0 = (c0*v + l.a)
    else
        lc0 = l.a
        if (l.a.y != p.pos.y) return false end
    end
    return abs(lc0.x - p.pos.x) <= (p.length/2.0 + width/2.0)
end

""" Perform game updates for `b` given `dt` seconds since last update. """
function update!(b::Ball, dt)
    global scoreA, scoreB
    b.pos = b.pos + (b.vel * dt)

    if b.pos.y > winHeight[]/2.0
        scoreB += 1
        audioEnabled && SDL2.Mix_PlayChannel( Int32(-1), scoreSound, Int32(0) )
        b.pos = WorldPos(0,0)
        b.vel = Vector2D(rand(-ballSpeed:ballSpeed), rand([ballSpeed,-ballSpeed]))
    elseif b.pos.y < -winHeight[]/2.0
        scoreA += 1
        audioEnabled && SDL2.Mix_PlayChannel( Int32(-1), scoreSound, Int32(0) )
        b.pos = WorldPos(0,0)
        b.vel = Vector2D(rand(-ballSpeed:ballSpeed), rand([ballSpeed,-ballSpeed]))
    end
    if b.pos.x > winWidth[]/2.0
        b.vel = Vector2D(-abs(b.vel.x), b.vel.y)
    elseif b.pos.x < -winWidth[]/2.0
        b.vel = Vector2D(abs(b.vel.x), b.vel.y)
    end
end
""" Game updates for `p` with `keys` pressed and `dt` seconds since last update. """
function update!(p::Paddle, keys, dt)
    # Apply velocity
    p.pos = p.pos + (p.vel * dt)

    # TODO: another way i could calculate this, which might give more control is
    # to set the position manually as a function of how long they've been
    # holding the button. That way, if I want, i could implement normal
    # acceleration as I've done here, but OR if i want, i could also do like t^3
    # instead of t^2 to make it more dramatic or something.

    # Calculate acceleration from user input.
    accel = 0
    decelerating = false  # keep track of whether speeding up or slowing down.
    cur_vel_sign = 0
    # If both keys are down or neither key is down, decelerate.
    if (!xor(keys.leftDown, keys.rightDown))
        if abs(p.vel.x) > 0
            cur_vel_sign = p.vel.x / abs(p.vel.x)
            accel = paddleDeccel * -1 * cur_vel_sign
            decelerating = true
        end
    elseif (keys.leftDown)
        accel = -paddleAccel
        # Boost if switching directions
        if p.vel.x > 0;
            accel += -paddleDeccel
        end
    elseif (keys.rightDown)
        accel = paddleAccel
        # Boost if switching directions
        if p.vel.x < 0;
            accel += paddleDeccel
        end
    end

    # Apply accel
    p.vel = p.vel + Vector2D(accel * dt, 0)
    if decelerating
        # If decelerating pushed it "past" 0, bring it to a stop.
        if (cur_vel_sign < 0 && p.vel.x > 0
           || cur_vel_sign > 0 && p.vel.x < 0)
            p.vel = Vector2D(0, p.vel.y)
        end
    else
        # If accelerating pushed it past max, bring it to a stop.
        if p.vel.x > paddleSpeed
            p.vel = Vector2D(paddleSpeed, p.vel.y)
        elseif p.vel.x < -paddleSpeed
            p.vel = Vector2D(-paddleSpeed, p.vel.y)
        end
    end

    # Check position bounds.
    if p.pos.x > winWidth[]/2.0
        p.pos = WorldPos(winWidth[]/2.0, p.pos.y)
    elseif p.pos.x < -winWidth[]/2.0
        p.pos = WorldPos(-winWidth[]/2.0, p.pos.y)
    end
end
