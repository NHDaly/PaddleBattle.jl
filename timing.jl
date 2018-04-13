mutable struct Timer
    starttime_ns::typeof(Base.time_ns())
    paused_elapsed_ns::typeof(Base.time_ns())
    Timer() = new(0,0)
end

function start!(timer::Timer)
    timer.starttime_ns = (Base.time_ns)()
    return nothing
end
started(timer::Timer) = (timer.starttime_ns ≠ 0)

""" Return seconds since timer was started or 0 if not yet started. """
function elapsed(timer::Timer)
    local elapsedtime_ns = (Base.time_ns)() - timer.starttime_ns
    return started(timer) * float(elapsedtime_ns) / 1000000000
end

function pause!(timer::Timer)
    timer.paused_elapsed_ns = (Base.time_ns)() - timer.starttime_ns
    return nothing
end
function unpause!(timer::Timer)
    timer.starttime_ns = (Base.time_ns)()
    timer.starttime_ns -= timer.paused_elapsed_ns;
    return nothing
end

t = Timer()
start!(t)
elapsed(t)
pause!(t)
unpause!(t)
elapsed(t)
