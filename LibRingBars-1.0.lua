-- See README.mkd for details

--[[-------------------------------------------------------------------------
    Copyright (c) 2009, zork
    Copyright (c) 2009, Constantin Schomburg <xconstruct@gmail.com>
    All rights reserved.
  
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are
    met:
  
        * Redistributions of source code must retain the above copyright
          notice, this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above
          copyright notice, this list of conditions and the following
          disclaimer in the documentation and/or other materials provided
          with the distribution.
        * Neither the name of rRingMod nor the names of its contributors may
          be used to endorse or promote products derived from this
          software without specific prior written permission.
  
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES LOSS OF USE,
    DATA, OR PROFITS OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]

local lib, oldminor = LibStub:NewLibrary("LibRingBars-1.0", 1)
if(not lib) then return end

-- getting the path for the textures
local addonPath = debugstack():match("(.+\\).-\.lua:")

local defaults = {__index = {
	["size"] = 256,
	["start"] = 1,
	["inverted"] = false, -- inverted = counter-clockwise
	["segments"] = 4,

	["radius_inner"] = 90/128,
	["radius_outer"] = 110/128,
	["segment_texture"] = addonPath.."textures\\ring_segment",
	["slicer_texture"] = addonPath.."textures\\slicer",
	["segment_blend"] = "ADD",
}}

-- calculates the one specific ring segment 
local function updateSegment(self, value)
	local t0 = self.square1
	local t1 = self.square2
	local t2 = self.slicer
	local t3 = self.fullsegment

	local config = self.parent.config
	local INVERTED = config.inverted
	local SEGMENT_SIZE = config.size/2
	local RADIUS_INNER = config.radius_inner * SEGMENT_SIZE
	local RADIUS_OUTER = config.radius_outer * SEGMENT_SIZE

	-- if no value was found, use the last one
	value = value or self.Value
	self.Value = value or self.Value

	if value <= 0 then -- Hide all textures
		t0:Hide()
		t1:Hide()
		t2:Hide()
		t3:Hide()
		return
	elseif value >= 1 then -- Show the full texture
		t0:Hide()
		t1:Hide()
		t2:Hide()
		t3:Show()
		return
	else -- Otherwise the parts
		t0:Show()
		t1:Show()
		t2:Show()
		t3:Hide()
	end

	--remember to invert the value when direction is counter-clockwise
	if INVERTED then
		value = 1 - value
	end

	--angle
	local angle = value * 90
	local Arad = math.rad(angle)

	local Nx = 0
	local Ny = 0
	local Mx = SEGMENT_SIZE
	local My = SEGMENT_SIZE

	local MxCoord, MyCoord
	local sq1_c1_x, sq1_c1_y, sq1_c2_x, sq1_c2_y, sq1_c3_x, sq1_c3_y, sq1_c4_x, sq1_c4_y
	local sq2_c1_x, sq2_c1_y, sq2_c2_x, sq2_c2_y, sq2_c3_x, sq2_c3_y, sq2_c4_x, sq2_c4_y

	local Ix = RADIUS_INNER * math.sin(Arad)
	local Iy = (RADIUS_OUTER - (RADIUS_INNER * math.cos(Arad))) + SEGMENT_SIZE - RADIUS_OUTER
	local Ox = RADIUS_OUTER * math.sin(Arad)
	local Oy = (RADIUS_OUTER - (RADIUS_OUTER * math.cos(Arad))) + SEGMENT_SIZE - RADIUS_OUTER

	local IxCoord = Ix / SEGMENT_SIZE 
	local IyCoord = Iy / SEGMENT_SIZE
	local OxCoord = Ox / SEGMENT_SIZE
	local OyCoord = Oy / SEGMENT_SIZE	 
	local NxCoord = Nx / SEGMENT_SIZE
	local NyCoord = Ny / SEGMENT_SIZE

	if self.field == 1 then
		t2:SetPoint("TOPLEFT",Ix,-Oy)
		t2:SetWidth(Ox-Ix)
		t2:SetHeight(Iy-Oy)
	elseif self.field == 2 then
		t2:SetPoint("TOPRIGHT",-Oy,-Ix)
		t2:SetWidth(Iy-Oy)
		t2:SetHeight(Ox-Ix)
		t2:SetTexCoord(0,1, 1,1, 0,0, 1,0)
	elseif self.field == 3 then
		t2:SetPoint("BOTTOMRIGHT",-Ix,Oy)
		t2:SetWidth(Ox-Ix)
		t2:SetHeight(Iy-Oy)
		t2:SetTexCoord(1,1, 1,0, 0,1, 0,0)
	elseif self.field == 4 then
		t2:SetPoint("BOTTOMLEFT",Oy,Ix)
		t2:SetWidth(Iy-Oy)
		t2:SetHeight(Ox-Ix)
		t2:SetTexCoord(1,0, 0,0, 1,1, 0,1)
	end
	
	if not INVERTED then
		MxCoord = Nx / SEGMENT_SIZE
		MyCoord = Ny / SEGMENT_SIZE
		
		sq1_c1_x = NxCoord
		sq1_c1_y = NyCoord
		sq1_c2_x = NxCoord
		sq1_c2_y = IyCoord
		sq1_c3_x = IxCoord
		sq1_c3_y = NyCoord
		sq1_c4_x = IxCoord
		sq1_c4_y = IyCoord
					
		sq2_c1_x = IxCoord
		sq2_c1_y = NyCoord
		sq2_c2_x = IxCoord
		sq2_c2_y = OyCoord
		sq2_c3_x = OxCoord
		sq2_c3_y = NyCoord
		sq2_c4_x = OxCoord
		sq2_c4_y = OyCoord
		
		if self.field == 1 then
			t0:SetPoint("TOPLEFT",Nx,-Ny)
			t0:SetWidth(Ix)
			t0:SetHeight(Iy)
			t1:SetPoint("TOPLEFT",Ix,-Ny)
			t1:SetWidth(Ox-Ix)
			t1:SetHeight(Oy)
		elseif self.field == 2 then
			t0:SetPoint("TOPRIGHT",Nx,Ny)
			t0:SetWidth(Iy)
			t0:SetHeight(Ix)
			t1:SetPoint("TOPRIGHT",Ny,-Ix)
			t1:SetWidth(Oy)
			t1:SetHeight(Ox-Ix)
		elseif self.field == 3 then
			t0:SetPoint("BOTTOMRIGHT",Nx,Ny)
			t0:SetWidth(Ix)
			t0:SetHeight(Iy)
			t1:SetPoint("BOTTOMRIGHT",-Ix,Ny)
			t1:SetWidth(Ox-Ix)
			t1:SetHeight(Oy)
		elseif self.field == 4 then
			t0:SetPoint("BOTTOMLEFT",Nx,Ny)
			t0:SetWidth(Iy)
			t0:SetHeight(Ix)
			t1:SetPoint("BOTTOMLEFT",Ny,Ix)
			t1:SetWidth(Oy)
			t1:SetHeight(Ox-Ix)
		end
	else
		MxCoord = Mx / SEGMENT_SIZE
		MyCoord = My / SEGMENT_SIZE
		
		sq1_c1_x = IxCoord
		sq1_c1_y = IyCoord
		sq1_c2_x = IxCoord
		sq1_c2_y = MyCoord
		sq1_c3_x = MxCoord
		sq1_c3_y = IyCoord
		sq1_c4_x = MxCoord
		sq1_c4_y = MyCoord
					
		sq2_c1_x = OxCoord
		sq2_c1_y = OyCoord
		sq2_c2_x = OxCoord
		sq2_c2_y = IyCoord
		sq2_c3_x = MxCoord
		sq2_c3_y = OyCoord
		sq2_c4_x = MxCoord
		sq2_c4_y = IyCoord
		
		if self.field == 1 then
			t0:SetPoint("TOPLEFT",Ix,-Iy)
			t0:SetWidth(SEGMENT_SIZE-Ix)
			t0:SetHeight(SEGMENT_SIZE-Iy)
			t1:SetPoint("TOPLEFT",Ox,-Oy)
			t1:SetWidth(SEGMENT_SIZE-Ox)
			t1:SetHeight(Iy-Oy)
		elseif self.field == 2 then
			t0:SetPoint("TOPRIGHT",-Iy,-Ix)
			t0:SetWidth(SEGMENT_SIZE-Iy)
			t0:SetHeight(SEGMENT_SIZE-Ix)
			t1:SetPoint("TOPRIGHT",-Oy,-Ox)
			t1:SetWidth(Iy-Oy)
			t1:SetHeight(SEGMENT_SIZE-Ox)
		elseif self.field == 3 then
			t0:SetPoint("BOTTOMRIGHT",-Ix,Iy)
			t0:SetWidth(SEGMENT_SIZE-Ix)
			t0:SetHeight(SEGMENT_SIZE-Iy)
			t1:SetPoint("BOTTOMRIGHT",-Ox,Oy)
			t1:SetWidth(SEGMENT_SIZE-Ox)
			t1:SetHeight(Iy-Oy)
		elseif self.field == 4 then
			t0:SetPoint("BOTTOMLEFT",Iy,Ix)
			t0:SetWidth(SEGMENT_SIZE-Iy)
			t0:SetHeight(SEGMENT_SIZE-Ix)
			t1:SetPoint("BOTTOMLEFT",Oy,Ox)
			t1:SetWidth(Iy-Oy)
			t1:SetHeight(SEGMENT_SIZE-Ox)
		end
	end
	
	if self.field == 1 then
		--1,2,3,4
		t0:SetTexCoord(sq1_c1_x,sq1_c1_y, sq1_c2_x,sq1_c2_y, sq1_c3_x,sq1_c3_y, sq1_c4_x, sq1_c4_y)
		t1:SetTexCoord(sq2_c1_x,sq2_c1_y, sq2_c2_x,sq2_c2_y, sq2_c3_x,sq2_c3_y, sq2_c4_x, sq2_c4_y)
	elseif self.field == 2 then
		--2,4,1,3
		t0:SetTexCoord(sq1_c2_x,sq1_c2_y, sq1_c4_x, sq1_c4_y, sq1_c1_x,sq1_c1_y, sq1_c3_x,sq1_c3_y)
		t1:SetTexCoord(sq2_c2_x,sq2_c2_y, sq2_c4_x, sq2_c4_y, sq2_c1_x,sq2_c1_y, sq2_c3_x,sq2_c3_y)
	elseif self.field == 3 then
		--4,3,2,1
		t0:SetTexCoord(sq1_c4_x, sq1_c4_y, sq1_c3_x,sq1_c3_y, sq1_c2_x,sq1_c2_y, sq1_c1_x,sq1_c1_y)
		t1:SetTexCoord(sq2_c4_x, sq2_c4_y, sq2_c3_x,sq2_c3_y, sq2_c2_x,sq2_c2_y, sq2_c1_x,sq2_c1_y)
	elseif self.field == 4 then
		--3,1,4,2
		t0:SetTexCoord(sq1_c3_x,sq1_c3_y, sq1_c1_x,sq1_c1_y, sq1_c4_x, sq1_c4_y, sq1_c2_x,sq1_c2_y)
		t1:SetTexCoord(sq2_c3_x,sq2_c3_y, sq2_c1_x,sq2_c1_y, sq2_c4_x, sq2_c4_y, sq2_c2_x,sq2_c2_y)
	end
end

--function that creates the textures for each segment
local function createSegmentTextures(self)
	local config = self.parent.config

	local t0 = self:CreateTexture(nil, "BACKGROUND")
	t0:SetTexture(config.segment_texture)
	t0:SetBlendMode(config.segment_blend)
	t0:Hide()
	
	local t1 = self:CreateTexture(nil, "LOW")
	t1:SetTexture(config.segment_texture)
	t1:SetBlendMode(config.segment_blend)
	t1:Hide()

	local t2 = self:CreateTexture(nil, "BACKGROUND")
	t2:SetBlendMode(config.segment_blend)
	if self.parent.config.inverted then
		t2:SetTexture(config.slicer_texture.."0")
	else
		t2:SetTexture(config.slicer_texture.."1")
	end
	t2:Hide()

	local t3 = self:CreateTexture(nil, "BACKGROUND")
	t3:SetTexture(config.segment_texture)
	t3:SetBlendMode(config.segment_blend)
	t3:SetAllPoints(self)
	if self.field == 2 then
		t3:SetTexCoord(0,1, 1,1, 0,0, 1,0)
	elseif self.field == 3 then
		t3:SetTexCoord(1,1, 1,0, 0,1, 0,0)
	elseif self.field == 4 then
		t3:SetTexCoord(1,0, 0,0, 1,1, 0,1)
	end
	t3:Hide()
	
	self.square1 = t0
	self.square2 = t1
	self.slicer = t2
	self.fullsegment = t3
end

local function setAll(self, func, ...)
	for _, seg in ipairs(self) do
		if type(func) == "string" then
			seg.square1[func](seg.square1, ...)
			seg.square2[func](seg.square2, ...)
			seg.slicer[func](seg.slicer, ...)
			seg.fullsegment[func](seg.fullsegment, ...)
		else
			func(seg, ...)
		end
	end
end
local function get(self, name)
	return self[1].seg.square1[name](self[1].seg.square1)
end

local function setValue(self, value)
	self.value = value
	value = (value-(self.min or 0))/(self.max or 1)
	local value_per_seg = 1/#self
	for i, seg in ipairs(self) do
		local seg_value = (value-((i-1)*value_per_seg))/value_per_seg
		seg_value = max(0, min(1, seg_value))
		updateSegment(seg, seg_value)
	end
end

local function setMinMaxValues(self, min, max) self.min, self.max = min, max end
local function getValue(self) return self.value or 0 end
local function getMinMaxValues(self) return self.min or 0, self.max or 1 end
local function setStatusBarColor(self, ...) setAll(self, "SetVertexColor", ...) end
local function getStatusBarColor(self) return get(self, "GetVertexColor") end
local function setBlendMode(self, ...) setAll(seg, "SetBlendMode", ...) end
local function getBlendMode(self) return get(self, "GetBlendMode") end
local function getSize(self) return self.config.size end
local function setSize(self, value)
	self:SetWidth(value)
	self:SetHeight(value)
	self.config.size = value
	setAll(self, updateSegment)
end

local function createRing(frame, name, parent, config)
	config = setmetatable(config or {}, defaults)

	local ring = CreateFrame(frame, name, parent)
	ring.config = config
	ring:SetWidth(config.size)
	ring:SetHeight(config.size)

	ring.SetValue = setValue
	ring.SetMinMaxValues = setMinMaxValues
	ring.GetValue = getValue
	ring.GetMinMaxValues = getMinMaxValues
	ring.SetStatusBarColor = setStatusBarColor
	ring.GetStatusBarColor = getStatusBarColor
	ring.SetBlendMode = setBlendMode
	ring.GetBlendMode = getBlendMode
	ring.SetSize = setSize
	ring.getSize = getSize

	for i=1, config.segments do
		local seg = CreateFrame("Frame", nil, ring)

		local pos = config.start+(i-1) * (config.inverted and -1 or 1)
		if(pos < 1) then pos = pos+4 end
		if(pos > 4) then pos = pos-4 end
		seg.field = pos
		seg.parent = ring

		if pos == 1 then
			seg:SetPoint("TOPRIGHT")
			seg:SetPoint("BOTTOMLEFT", ring, "CENTER")
		elseif pos == 2 then
			seg:SetPoint("BOTTOMRIGHT")
			seg:SetPoint("TOPLEFT", ring, "CENTER")
		elseif pos == 3 then
			seg:SetPoint("BOTTOMLEFT")
			seg:SetPoint("TOPRIGHT", ring, "CENTER")
		elseif pos == 4 then
			seg:SetPoint("TOPLEFT")
			seg:SetPoint("BOTTOMRIGHT", ring, "CENTER")
		end

		createSegmentTextures(seg)
		ring[i] = seg
	end
	return ring
end

lib.new = createRing
lib.defaults = defaults.__index