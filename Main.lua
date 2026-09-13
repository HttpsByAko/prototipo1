local Player = require("player")
local Enemy = require("enemy")

local player
local enemies = {}
local maxEnemies = 3
local gameTimer = 60
local gameState = "PLAYING" -- "PLAYING", "VICTORY", "DEFEAT"

local assets = {}
local sounds = {}

local function checkCollision(a, b)
    return a.x < b.x + b.size and
           a.x + a.size > b.x and
           a.y < b.y + b.size and
           a.y + a.size > b.y
end

local function resetGame()
    gameTimer = 60
    enemies = {}
    player = Player.new(400, 400, assets.player, assets.sword)
    
    for _ = 1, maxEnemies do
        table.insert(enemies, Enemy.spawnOutside(800, 800, assets.enemy))
    end
    
    gameState = "PLAYING"
    
    -- Reiniciar música de fondo
    sounds.music:stop()
    sounds.music:play()
end

function love.load()
    math.randomseed(os.time())

    -- Carga de Sprites
    assets.player = love.graphics.newImage("assets/Personaje.png")
    assets.enemy = love.graphics.newImage("assets/enemigo.png")
    assets.sword = love.graphics.newImage("assets/espada.png")

    -- Carga de Audios
    sounds.music = love.audio.newSource("assets/musica.ogg", "stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.5)

    sounds.golpe = love.audio.newSource("assets/golpe.wav", "static")
    sounds.muerte = love.audio.newSource("assets/muerte_jugador.wav", "static")
    sounds.victoria = love.audio.newSource("assets/victoria.wav", "static")

    resetGame()
end

function love.mousepressed(x, y, button)
    if gameState == "PLAYING" and button == 1 then
        player:attack(x, y)
    end
end

function love.keypressed(key)
    if gameState == "DEFEAT" and key == "r" then
        resetGame()
    end
end

function love.update(dt)
    if gameState ~= "PLAYING" then return end

    gameTimer = gameTimer - dt
    if gameTimer <= 0 then
        gameTimer = 0
        gameState = "VICTORY"
        sounds.music:stop()
        sounds.victoria:play()
        return
    end

    player:update(dt)

    -- Mantener siempre 3 enemigos
    while #enemies < maxEnemies do
        table.insert(enemies, Enemy.spawnOutside(800, 800, assets.enemy))
    end

    for i = #enemies, 1, -1 do
        local e = enemies[i]
        e:update(dt, player.x, player.y, player.size)

        -- 1. Espada impacta enemigo (se destruye sin reproducir sonido)
        if player.isAttacking and checkCollision(player.swordHitbox, e) then
            table.remove(enemies, i)

        -- 2. Enemigo impacta jugador
        elseif checkCollision(player, e) then
            if player:takeDamage() then
                table.remove(enemies, i)
                
                if player.lives <= 0 then
                    gameState = "DEFEAT"
                    sounds.music:stop()
                    sounds.muerte:play()
                    return
                else
                    sounds.golpe:stop()
                    sounds.golpe:play()
                end
            end
        end
    end
end

local function drawGrassBackground()
    local tileSize = 40
    for x = 0, 800, tileSize do
        for y = 0, 800, tileSize do
            local isAlt = (math.floor(x / tileSize) + math.floor(y / tileSize)) % 2 == 0
            if isAlt then
                love.graphics.setColor(0.30, 0.65, 0.30, 1)
            else
                love.graphics.setColor(0.33, 0.70, 0.33, 1)
            end
            love.graphics.rectangle("fill", x, y, tileSize, tileSize)
        end
    end
end

function love.draw()
    drawGrassBackground()

    for _, e in ipairs(enemies) do
        e:draw()
    end
    player:draw()

    -- Marcador superior
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(string.format("%.1f", gameTimer), 0, 20, 800, "center")

    -- Overlays de resultado
    if gameState == "VICTORY" then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, 800, 800)
        love.graphics.setColor(0.2, 1, 0.2, 1)
        love.graphics.printf("Victoria!", 0, 380, 800, "center")
    elseif gameState == "DEFEAT" then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, 800, 800)
        love.graphics.setColor(1, 0.2, 0.2, 1)
        love.graphics.printf("Derrota", 0, 360, 800, "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Volver a intentar (R)", 0, 390, 800, "center")
    end
end