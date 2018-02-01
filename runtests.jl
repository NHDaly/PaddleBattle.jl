using Base.Test
include("objects.jl")

# Objects tests
l = Line(WorldPos(-10,1), WorldPos(-10,-1))
p = Paddle(WorldPos(0,0), 20)
@test isColliding(p, l, 0)
@test isColliding(p, l, 10)

b = Ball(WorldPos(-10,-1), Vector2D(0,2))
p = Paddle(WorldPos(0,0), 30)
@test !willCollide(b, p, 0)
@test willCollide(b, p, 1)
@test willCollide(b, p, .5)
@test !willCollide(b, p, .4)
p = Paddle(WorldPos(0,0), 5)
@test !willCollide(b, p, 1)

b = Ball(WorldPos(0,0), Vector2D(0,-2))
p = Paddle(WorldPos(0,-10), 10)
@test !willCollide(b, p, 1)

b = Ball(WorldPos(-10,9), Vector2D(0,2))
p = Paddle(WorldPos(-8,10), 5)
@test willCollide(b, p, 1)
b = Ball(WorldPos(-10,11), Vector2D(0,2))
@test !willCollide(b, p, 1)

b = Ball(WorldPos(0,-195), Vector2D(0,-200))
p = Paddle(WorldPos(0,-200), 5)
@test willCollide(b, p, 1)
b = Ball(WorldPos(0,-200), Vector2D(0,-200000))
@test willCollide(b, p, 1)
@test willCollide(b, p, 0)
b = Ball(WorldPos(0,0), Vector2D(0,-200))
@test willCollide(b, p, 1)
b = Ball(WorldPos(0,0), Vector2D(0,-200))
@test willCollide(b, p, 1)
