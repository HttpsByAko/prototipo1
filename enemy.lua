local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, sprite)
    local self = setmetatable({}, Enemy)
    self.x = x
    self.y = y
    self.size = 30
    self.speed = 110
    self.sprite = sprite
    self.isDead = false
    return self
end

function Enemy.spawnOutside(w, h, sprite)
    local side = math.random(1, 4)
    local x, y
    local margin = 40

    if side == 1 then     -- Arriba
        x = math.random(0, w)
        y = -margin
    elseif side == 2 then -- Abajo
        x = math.random(0, w)
        y = h + margin
    elseif side == 3 then -- Izquierda
        x = -margin
        y = math.random(0, h)
    else                  -- Derecha
        x = w + margin
        y = math.random(0, h)
    end

    return Enemy.new(x, y, sprite)
end

function Enemy:update(dt, playerX, playerY, playerSize)
    local pcx = playerX + playerSize / 2
    local pcy = playerY + playerSize / 2
    local ecx = self.x + self.size / 2
    local ecy = self.y + self.size / 2

    local angle = math.atan2(pcy - ecy, pcx - ecx)
    self.x = self.x + math.cos(angle) * self.speed * dt
    self.y = self.y + math.sin(angle) * self.speed * dt
end

function Enemy:draw()
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Escala proporcional según el tamaño de la hitbox (30x30)
    local scaleX = self.size / self.sprite:getWidth()
    local scaleY = self.size / self.sprite:getHeight()
    local ox = self.sprite:getWidth() / 2
    local oy = self.sprite:getHeight() / 2

    love.graphics.draw(
        self.sprite, 
        self.x + self.size / 2, 
        self.y + self.size / 2, 
        0, 
        scaleX, 
        scaleY, 
        ox, 
        oy
    )
end

return Enemy