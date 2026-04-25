-- benchmark.lua
local Benchmark = {}

-- Toggle this to false to return to free-roam mode!
Benchmark.active = true 

Benchmark.time = 0
Benchmark.frames = 0
Benchmark.fps_accum = 0
Benchmark.measurements = 0

function Benchmark.Tick(dt, Camera, Swarm)
    if not Benchmark.active then return end

    Benchmark.time = Benchmark.time + dt
    local t = Benchmark.time

    -- 1. WARMUP (0 to 2 seconds)
    if t < 2.0 then
        Camera.x, Camera.y, Camera.z = 0, 0, -10000
        Camera.yaw, Camera.pitch = 0, 0
    end

    -- 2. TRIGGER THE BUNDLE (At exactly 2.0s)
    if t >= 2.0 and t < 2.05 then
        Swarm.ForceState(1) -- Trigger State 1!
    end

    -- 3. THE FLIGHT PATH (Orbit and Dive)
    if t >= 2.0 then
        -- Orbit angle around the sphere
        local angle = t * 0.5 
        
        -- Dive in close to test Fill Rate/Overdraw (t=4 to t=8)
        --local radius = 10000
        --if t > 4.0 and t < 8.0 then
            -- Creates a smooth curve from 0.0 to 1.0 to 0.0
            --local dive = math.sin((t - 4.0) * (math.pi / 4.0)) 
            --radius = 10000 - (dive * 7000) -- Dives all the way down to 3000 units!
        --end
        -- Dive in close to test Fill Rate/Overdraw (t=4 to t=8)
        -- local radius = 10000
        local radius = 10
        if t > 4.0 and t < 8.0 then
            -- Creates a smooth curve from 0.0 to 1.0 to 0.0
            local dive = math.sin((t - 4.0) * (math.pi / 4.0)) 
            -- Dive from 10000 down to 2500 (Right against the surface of the bundle!)
            radius = 10000 - (dive * 7500) 
        end

        Camera.x = math.cos(angle) * radius
        Camera.z = math.sin(angle) * radius
        Camera.y = math.sin(t) * 3000 -- Gentle vertical bob

        -- Always look dead center at the sphere (0,0,0)
        Camera.yaw = -angle - (math.pi / 2)
        Camera.pitch = -math.atan2(Camera.y, radius)

        -- Force Camera to update its direction vectors immediately
        Camera.UpdateVectors() 
    end

    -- 4. MEASURE FPS (Only measure while the bundle is fully formed: 4s to 10s)
    if t >= 4.0 and t <= 10.0 then
        Benchmark.frames = Benchmark.frames + 1
        Benchmark.fps_accum = Benchmark.fps_accum + (1.0 / dt)
        Benchmark.measurements = Benchmark.measurements + 1
    end

    -- 5. REPORT AND QUIT
    if t > 10.0 then
        local avg_fps = Benchmark.fps_accum / Benchmark.measurements
        print("\n===========================================")
        print(string.format("[BENCHMARK] Quad Core Average FPS: %.2f", avg_fps))
        print("===========================================\n")
        love.event.quit()
    end
end

return Benchmark
