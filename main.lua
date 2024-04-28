function love.load() 
    love.window.setTitle("Template")
    love.window.setMode(800, 480)
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()
    
    wf = require "lib/windfield"
    world = wf.newWorld(0, 600, false)
    world:setQueryDebugDrawing(false)

    -- assets
    img = {}
    img.bg = love.graphics.newImage("assets/background.jpg")
    img.pig = love.graphics.newImage("assets/pig.png")
    img.bird = love.graphics.newImage("assets/bird.png")
    img.tapel = love.graphics.newImage("assets/hook.png")

    -- ground
    floor = world:newRectangleCollider(0, HEIGHT - 20, WIDTH, 20)
    floor:setType("static")

    bird_placeholder = {
        img = img.bird,
        x = 135,
        y = 300
    }

    -- list peluru
    bullets = {}
    -- list babi
    boxs = {}
    hold = false
    show = true

    deltaTime = 0
end

function love.update(dt)
    deltaTime = dt
    local mx, my = love.mouse.getPosition()

    world:update(dt)
end

function love.draw()
    love.graphics.draw(img.bg, 0, 0, nil, (WIDTH/img.bg:getWidth()), (HEIGHT/img.bg:getHeight()))
    
    -- world:draw()
   
    -- draw ketapel
    love.graphics.draw(img.tapel, 135, 340, nil, 0.5)

    -- draw projectile
    local dx = love.mouse.getX() - bird_placeholder.x
    local dy = love.mouse.getY() - bird_placeholder.y
    local angleProjectile = math.atan2(dy, dx)
    local velo_angle = -angleProjectile
    local gravity = 9.81
    local v = 10

    for i = 1, 60 do
        local t = i / v -- Simulate time passage
        local x = bird_placeholder.x + -v * math.cos(velo_angle) * i
        -- Assuming 'initial_velocity' is the speed at which the projectile is launched
        local y = bird_placeholder.y - (-v * math.sin(velo_angle) * i - 0.5 * gravity * t^2)
        
        if hold then
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.circle("fill", x + 15, y + 20, 2)
        end
    end

    love.graphics.setColor(1,1,1)

    if show then
        -- draw  bird
        love.graphics.draw(bird_placeholder.img, bird_placeholder.x, bird_placeholder.y, nil, 0.5)
    end


    -- draw bird
    for _, k in ipairs(bullets) do 
        love.graphics.push() -- Save the current transformation state
        love.graphics.translate(k:getX(), k:getY()) -- Translate to the body position
        love.graphics.rotate(k.body:getAngle()) -- Rotate by the body's angle
        love.graphics.draw(img.bird, -img.bird:getWidth()/2 * 0.5, -img.bird:getHeight()/2 * 0.5, 0, 0.5)
        love.graphics.pop()
    end

    -- draw pig
    for _, k in ipairs(boxs) do 
        love.graphics.push()
        love.graphics.translate(k:getX(), k:getY())
        love.graphics.rotate(k.body:getAngle())
        love.graphics.draw(img.pig, -img.pig:getWidth()/2 * 0.5, -img.pig:getHeight()/2 * 0.5, 0, 0.5)
        love.graphics.pop()
    end
    
    
    -- -- draw mouse position untuk utility
    love.graphics.print("mouse x = " .. love.mouse.getX(), 10, 10)  
    love.graphics.print("mouse y = " .. love.mouse.getY(), 10, 40)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
       love.event.quit()
    end
 end

 function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then 
        hold = true
        show = true
    elseif button == 2 then
        newBox(x, y)
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        local dx, dy = x - bird_placeholder.x, y - bird_placeholder.y
        local dirx, diry = normalizeVector(dx, dy)
        addBullet(bird_placeholder.x, bird_placeholder.y, dirx, diry) 
        hold = false
        show = false
    end
 end


function newBox(x,y)
    local b = world:newRectangleCollider(x - 50 / 2,y - 50 / 2, 50,50)
    table.insert(boxs, b)
end

function addBullet(px, py, dirx, diry)
    local bulletSpeed = 3000 -- Adjust bullet speed as needed
    local b = world:newCircleCollider(px, py, 20)
    b:setType("dynamic")
    b:applyLinearImpulse(dirx * -bulletSpeed, diry * -bulletSpeed)
    table.insert(bullets, b)
end

function normalizeVector(dx, dy)
    local length = math.sqrt(dx ^ 2 + dy ^ 2)
    if length == 0 then
        return 0,0
    else
        return dx / length, dy / length
    end
end

