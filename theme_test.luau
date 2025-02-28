--!strict
-- Arquivo de teste para demonstrar todos os elementos de escopo em Luau

-- Importações de módulos
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Constantes
local MAX_PLAYERS = 10
local DEFAULT_SPEED = 16
local PI = math.pi
local COLORS = {
    RED = Color3.fromRGB(255, 0, 0),
    GREEN = Color3.fromRGB(0, 255, 0),
    BLUE = Color3.fromRGB(0, 0, 255)
}

-- Tipos personalizados
type Vector2D = {x: number, y: number}
type PlayerData = {
    name: string,
    score: number,
    isActive: boolean,
    inventory: {[string]: number}
}
export type ModuleConfig = {
    enabled: boolean,
    maxPlayers: number?
}

-- Variáveis locais
local playersConnected = 0
local isGameActive = false

-- Variáveis globais
_G.GameState = "Waiting"
_G.DebugMode = true

-- Função local básica
local function calculateDistance(point1: Vector2D, point2: Vector2D): number
    local dx = point2.x - point1.x
    local dy = point2.y - point1.y
    return math.sqrt(dx * dx + dy * dy)
end

-- Função com sobrecarga e valores padrão
local function createPlayer(name: string, level: number?, isPremium: boolean?): PlayerData
    level = level or 1
    isPremium = isPremium or false
    
    return {
        name = name,
        score = level * 100,
        isActive = true,
        inventory = {}
    }
end

-- Função local com closure
local function createCounter(startValue: number)
    local count = startValue
    
    return function(increment: number?)
        increment = increment or 1
        count = count + increment
        return count
    end
end

-- Tabela/Classe com métodos
local Player = {}
Player.__index = Player

function Player.new(name: string): typeof(setmetatable({}, Player))
    local self = setmetatable({}, Player)
    self.name = name
    self.health = 100
    self.mana = 50
    self.position = {x = 0, y = 0, z = 0}
    return self
end

function Player:takeDamage(amount: number)
    self.health = math.max(0, self.health - amount)
    if self.health <= 0 then
        self:die()
    end
end

function Player:die()
    print(self.name .. " has died!")
    self.isAlive = false
end

function Player:teleport(x: number, y: number, z: number)
    self.position = {x = x, y = y, z = z}
    return self.position
end

-- Herança (simulada com metatables)
local SpecialPlayer = {}
SpecialPlayer.__index = SpecialPlayer
setmetatable(SpecialPlayer, {__index = Player}) -- Herda de Player

function SpecialPlayer.new(name: string, specialPower: string): typeof(setmetatable({}, SpecialPlayer))
    local self = Player.new(name)
    setmetatable(self, SpecialPlayer)
    self.specialPower = specialPower
    self.mana = 100 -- Sobrescreve o valor da classe pai
    return self
end

function SpecialPlayer:useSpecialPower()
    if self.mana >= 30 then
        print(self.name .. " used " .. self.specialPower .. "!")
        self.mana = self.mana - 30
        return true
    else
        print("Not enough mana!")
        return false
    end
end

-- Uso de escopos condicionais
local function processInput(input: string)
    if input == "start" then
        isGameActive = true
        print("Game started")
    elseif input == "stop" then
        isGameActive = false
        print("Game stopped")
    else
        print("Unknown command")
    end
    
    -- Escopo de loop for numérico
    for i = 1, 5 do
        print("Iteration " .. i)
        
        -- Escopo aninhado
        if i % 2 == 0 then
            local evenMessage = "This is even"
            print(evenMessage)
        else
            local oddMessage = "This is odd"
            print(oddMessage)
        end
    end
    
    -- Loop for genérico
    local items = {"sword", "shield", "potion"}
    for index, item in ipairs(items) do
        print(index .. ": " .. item)
    end
    
    -- Loop while
    local counter = 0
    while counter < 3 do
        print("Counter: " .. counter)
        counter = counter + 1
    end
    
    -- Escopo do
    do
        local scopedVariable = "Only visible in this scope"
        print(scopedVariable)
    end
    -- print(scopedVariable) -- Isso geraria um erro
end

-- Funções anônimas e callbacks
local function setupEvents(object)
    object.Touched:Connect(function(hit)
        print("Object was touched by " .. hit.Name)
    end)
    
    local tween = TweenService:Create(
        object,
        TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Transparency = 1}
    )
    
    tween:Play()
end

-- Tratamento de erros
local function safeOperation(callback)
    local success, result = pcall(function()
        return callback()
    end)
    
    if success then
        return result
    else
        warn("Error occurred: " .. result)
        return nil
    end
end

-- Interface de módulo
local Module = {}

function Module.initialize(config: ModuleConfig?)
    config = config or {enabled = true, maxPlayers = MAX_PLAYERS}
    
    local playerCounter = createCounter(0)
    
    local function addPlayer()
        local count = playerCounter()
        if count <= (config.maxPlayers or MAX_PLAYERS) then
            return true
        else
            return false
        end
    end
    
    
    Module.addPlayer = addPlayer
    Module.isEnabled = config.enabled
end

-- Exportação do módulo
return Module 