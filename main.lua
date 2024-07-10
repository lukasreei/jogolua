function love.load()
    love.window.setTitle('Kill Zombies')

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.player = love.graphics.newImage('sprites/survivor.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')
    sprites.titulo = love.graphics.newImage('sprites/titulo.png')

    sounds = {}
    sounds.bullet = love.audio.newSource('sounds/laser.wav', 'static')
    sounds.killZombie = love.audio.newSource('sounds/death.wav', 'static')
    sounds.background = love.audio.newSource('sounds/background.ogg', 'static')
    
    player = {}
    player.x = love.graphics.getWidth()/2
    player.y = love.graphics.getHeight()-sprites.player:getHeight()-10
    player.speed = 180

    bullets = {}
    zombies = {}

    timeBullet = 0
    maxTimeBullet = 0.2

    timeZombie = 0
    maxTimeZombie = 0.7

    deadZombies = 0

    gameState = 1
end

function love.update(dt)
    if gameState == 1 then
        if love.keyboard.isDown('space') then
            gameState = 2
        end
    end
    if gameState == 2 then
        if not sounds.background:isPlaying() then
            sounds.background:play()
        end
    
        if love.keyboard.isDown('d') then
            player.x = player.x + player.speed * dt
        end
        if love.keyboard.isDown('a') then
            player.x = player.x - player.speed * dt
        end
        timeBullet = timeBullet + dt
        if love.mouse.isDown(1) then
            if timeBullet >= maxTimeBullet then
                if sounds.bullet:isPlaying() then
                    sounds.bullet:stop()
                end
                sounds.bullet:play()
                spawnBullet()
                timeBullet = 0
            end
        end
    
        if player.x + sprites.player:getWidth() >= love.graphics.getWidth() then
            player.x = love.graphics.getWidth() - sprites.player:getWidth()
        end
    
        if player.x <= 0 then
            player.x = 0
        end
    
        for i,b in ipairs(bullets) do
            b.y = b.y - b.speed * dt
        end
    
        timeZombie = timeZombie + dt
        if timeZombie >= maxTimeZombie then
            spawnZombie()
            timeZombie = 0
        end
    
        for i,z in ipairs(zombies) do
            z.y = z.y + z.speed * dt
        end
    
        for i,b in ipairs(bullets) do
            for j,z in ipairs(zombies) do
                if distanceBetween(b.x, b.y, z.x, z.y) <= 30 then
                    deadZombies = deadZombies + 1
                    if sounds.killZombie:isPlaying() then
                        sounds.killZombie:stop()
                    end
                    sounds.killZombie:play()
                    table.remove(bullets, i)
                    table.remove(zombies, j)
                end
            end
        end

        for i,z in ipairs(zombies) do
            if distanceBetween(z.x,z.y,player.x,player.y) <= 30 then
                for i, z in ipairs(zombies) do zombies[i] = nil end
                sounds.background:stop()
                deadZombies = 0
                player.x = love.graphics.getWidth()/2
                player.y = love.graphics.getHeight()-sprites.player:getHeight()-10
                timeZombie = 0
                timeBullet = 0
                gameState = 1
            end
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background)
    if gameState == 1 then
        love.graphics.draw(sprites.titulo, love.graphics.getWidth()/2, love.graphics.getHeight()/2, nil, nil, nil, sprites.titulo:getWidth()/2, sprites.titulo:getHeight()/2)
    end
    if gameState == 2 then
        love.graphics.draw(sprites.player, player.x, player.y)
        for i,b in ipairs(bullets) do 
            love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5)
        end
        for i,z in ipairs(zombies) do
            love.graphics.draw(sprites.zombie, z.x, z.y)
        end

        love.graphics.draw(sprites.zombie, 10, 10)
        love.graphics.print(deadZombies, 60, 10, nil, 1.5)
    end
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y-45
    bullet.speed = 720
    table.insert(bullets, bullet)
end

function spawnZombie()
    local zombie = {}
    zombie.x = math.random(0, love.graphics.getWidth()-sprites.zombie:getWidth())
    zombie.y = 0
    zombie.speed = math.random(100,180)
    table.insert(zombies, zombie)
end

function distanceBetween(x1,y1,x2,y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end