using Base.Test
using SDL2
include("objects.jl")
include("configs.jl")

# Objects tests
kZeroVel = Vector2D(0,0)

@testset "isColliding(paddle, line)" begin
l = LineSegment(WorldPos(-10,1), WorldPos(-10,-1))
p = Paddle(WorldPos(0,0), kZeroVel, 20)
@test isColliding(p, l, 0)
@test isColliding(p, l, 10)
end

@testset "willCollide(ball, paddle, dt)" begin
@testset "dt" begin
b = Ball(WorldPos(-10,-1), Vector2D(0,2))
p = Paddle(WorldPos(0,0), kZeroVel, 30)
@test !willCollide(b, p, 0)
@test willCollide(b, p, 1)
@test willCollide(b, p, .5)
@test !willCollide(b, p, .4)
p = Paddle(WorldPos(0,0), kZeroVel, 5)  # too short
@test !willCollide(b, p, 1)

b = Ball(WorldPos(0,0), Vector2D(0,-2))
p = Paddle(WorldPos(0,-100), kZeroVel, 10)
@test !willCollide(b, p, 1)
end

@testset "collision detection" begin
b = Ball(WorldPos(-10,9), Vector2D(0,2))
p = Paddle(WorldPos(-8,10), kZeroVel, 5)
@test willCollide(b, p, 1)
b = Ball(WorldPos(-10,11), Vector2D(0,2))
@test !willCollide(b, p, 1)

b = Ball(WorldPos(0,-195), Vector2D(0,-200))
p = Paddle(WorldPos(0,-200), kZeroVel, 5)
@test willCollide(b, p, 1)
b = Ball(WorldPos(0,-200), Vector2D(0,-200000))
@test willCollide(b, p, 1)
@test willCollide(b, p, 0)
b = Ball(WorldPos(0,0), Vector2D(0,-200))
@test willCollide(b, p, 1)
b = Ball(WorldPos(0,0), Vector2D(0,-200))
@test willCollide(b, p, 1)
end

end
