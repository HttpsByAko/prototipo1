local Player = {}
Player.__index = Player

function Player.new(x, y, sprite, swordSprite)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.size = 32
    self.speed = 220
    self.maxLives = 2
    self.lives = 2
    
    self.sprite = sprite
    self.swordSprite = swordSprite
    
    -- Ataque
    self.attackCooldown = 0.65
    self.attackDuration = 0.20
    self.cooldownTimer = 0
    self.attackTimer = 0
    self.isAttacking = false
    self.attackAngle = 0
    
    -- Hitbox de la espada aumentada
    self.swordHitbox = {x = 0, y = 0, size = 48}
    
    -- I-Frames
    self.invulnerableDuration = 0.75
    self.invulnerableTimer = 0
    
    return self
end

function Player:takeDamage()
    if self.invulnerableTimer <= 0 then
        self.lives = self.lives - 1
        self.invulnerableTimer = self.invulnerableDuration
        return true
    end
    return false
end

function Player:update(dt)
    if self.invulnerableTimer > 0 then
        self.invulnerableTimer = self.invulnerableTimer - dt
    end

    if self.cooldownTimer > 0 then
        self.cooldownTimer = self.cooldownTimer - dt
    end
    
    if self.isAttacking then
        self.attackTimer = self.attackTimer - dt
        if self.attackTimer <= 0 then
            self.isAttacking = false
        end
    end

    -- Movimiento WASD
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") then dy = dy - 1 end
    if love.keyboard.isDown("s") then dy = dy + 1 end
    if love.keyboard.isDown("a") then dx = dx - 1 end
    if love.keyboard.isDown("d") then dx = dx + 1 end

    if dx ~= 0 or dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        self.x = self.x + (dx / len) * self.speed * dt
        self.y = self.y + (dy / len) * self.speed * dt
    end

    -- Posición de la hitbox de la espada centrada hacia el frente del ataque
    if self.isAttacking then
        local offset = 42
        self.swordHitbox.x = (self.x + self.size / 2) + math.cos(self.attackAngle) * offset - (self.swordHitbox.size / 2)
        self.swordHitbox.y = (self.y + self.size / 2) + math.sin(self.attackAngle) * offset - (self.swordHitbox.size / 2)
    end
end

function Player:attack(targetX, targetY)
    if self.cooldownTimer <= 0 then
        self.isAttacking = true
        self.attackTimer = self.attackDuration
        self.cooldownTimer = self.attackCooldown
        
        local cx = self.x + self.size / 2
        local cy = self.y + self.size / 2
        self.attackAngle = math.atan2(targetY - cy, targetX - cx)
        return true
    end
    return false
end

function Player:draw()
    local cx = self.x + self.size / 2
    local cy = self.y + self.size / 2

    -- Parpadeo por I-Frames
    local alpha = 1.0
    if self.invulnerableTimer > 0 then
        if math.floor(self.invulnerableTimer * 20) % 2 == 0 then
            alpha = 0.35
        end
    end

    love.graphics.setColor(1, 1, 1, alpha)
    local pScaleX = self.size / self.sprite:getWidth()
    local pScaleY = self.size / self.sprite:getHeight()
    local ox = self.sprite:getWidth() / 2
    local oy = self.sprite:getHeight() / 2
    love.graphics.draw(self.sprite, cx, cy, 0, pScaleX, pScaleY, ox, oy)

    -- Renderizado y escala ampliada de la espada
    if self.isAttacking then
        love.graphics.setColor(1, 1, 1, 1)
        local swordLength = 52
        local maxDim = math.max(self.swordSprite:getWidth(), self.swordSprite:getHeight())
        local sScale = swordLength / maxDim
        local soy = self.swordSprite:getHeight() / 2
        love.graphics.draw(self.swordSprite, cx, cy, self.attackAngle, sScale, sScale, 0, soy)
    end

    -- Barra de vidas
    love.graphics.setColor(0.9, 0.1, 0.1, 1)
    local lifeBoxSize = 8
    local gap = 4
    local startX = cx - ((self.maxLives * lifeBoxSize + (self.maxLives - 1) * gap) / 2)
    local posY = self.y + self.size + 6

    for i = 1, self.lives do
        love.graphics.rectangle("fill", startX + (i - 1) * (lifeBoxSize + gap), posY, lifeBoxSize, lifeBoxSize)
    end
end

return Player