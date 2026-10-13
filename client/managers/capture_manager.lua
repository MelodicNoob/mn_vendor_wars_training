local vendorConfig <const> = require 'client.configs.vendor'
local TeamManager <const> = require 'client.managers.team_manager'
local Team <const> = require 'shared.enums.team'

local CAPTURE_BLIP_SPRITE_ID <const> = 310
local CAPTURE_VENDOR_MARKER_TYPE <const> = 1
local CAPTURE_VENDOR_MARKER_COLOUR <const> = { r = 0, g = 255, b = 0, a = 200 }

local CaptureManager <const> = {
  vendorCoords = nil,
  vendorBlip = nil,
  vendorMarker = nil,
  vendorControllingTeam = nil,
}

---@param coords vector3
function CaptureManager:createBlip(coords)
  self.vendorBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
  SetBlipSprite(self.vendorBlip, CAPTURE_BLIP_SPRITE_ID)
end

function CaptureManager:removeBlip()
  if not self.vendorBlip then return end
  RemoveBlip(self.vendorBlip)
  self.vendorBlip = nil
end

---@param captureData CaptureDto 
function CaptureManager:sync(captureData)
  if type(captureData.vendorCoords) == 'vector3' and captureData.vendorCoords ~= self.vendorCoords then
    self.vendorCoords = captureData.vendorCoords

    if self.vendorBlip then
      self:removeBlip()
    end

    if not self.vendorBlip then
      self:createBlip(captureData.vendorCoords)
    end

    if not self.vendorMarker then
      self:createMarker(captureData.vendorCoords)
      CreateThread(function()
        while self.vendorMarker do
          self.vendorMarker:draw()
          Wait(0)
        end
      end)
    end
  end

  if type(captureData.vendorControllingTeam) == 'number' and captureData.vendorControllingTeam ~= self.vendorControllingTeam then
    self.vendorControllingTeam = captureData.vendorControllingTeam
  end
end

function CaptureManager:attemptCapture()
  if not self.vendorCoords then
    error('Cannot capture: vendor coordinates are missing')
  end

  local playerTeam <const> = TeamManager:getPlayerTeam()
  if playerTeam == Team.NONE then
    -- lib.notify({
    --   title = 'Capture Failed',
    --   description = 'You must be on a team to capture.',
    --   type = 'error'
    -- })
    return
  end

  if playerTeam == self.vendorControllingTeam then
    -- lib.notify({
    --   title = 'Capture Failed',
    --   description = 'This vendor is already controlled by your team.',
    --   type = 'error'
    -- })
    return
  end

  local playerCoords <const> = GetEntityCoords(cache.ped)
  if #(playerCoords.xyz - self.vendorCoords.xyz) > vendorConfig.captureDistance then
    -- lib.notify({
    --   title = 'Capture Failed',
    --   description = 'You must be within capture range.',
    --   type = 'error'
    -- })
    return
  end

  if not lib.progressBar({
    duration = vendorConfig.captureDuration * 1000,
    label = 'Capturing',
    useWhileDead = false,
    canCancel = true,
    disable = {
      car = true,
    },
    anim = {
      dict = 'amb@world_human_gardener_plant@male@enter',
      clip = 'enter'
    },
  }) then return end

  self:capture()
end

function CaptureManager:capture()
  TriggerServerEvent('mn_vendor_wars_training:server:captured')
end

---@param coords vector3
function CaptureManager:createMarker(coords)
  self.vendorMarker = lib.marker.new({
    type = CAPTURE_VENDOR_MARKER_TYPE,
    coords = coords,
    color = CAPTURE_VENDOR_MARKER_COLOUR,
  })
end

return CaptureManager
