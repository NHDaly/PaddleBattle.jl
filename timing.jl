mutable struct Timer
    starttime_ns::typeof(Base.time_ns())
    Timer() = new(0)
end

function start!(timer::Timer)
    timer.starttime_ns = (Base.time_ns)()
    return nothing
end
function elapsed(timer::Timer)
    local elapsedtime_ns = (Base.time_ns)() - timer.starttime_ns
    return float(elapsedtime_ns) / 1000000000
end
