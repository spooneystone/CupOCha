---@diagnostic disable: undefined-global
-- title:   The Collector
-- author:  spooneystone
-- desc:    Game about making a cup of tea inbetween housework
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

--#region SCENE MANAGER


------------------------- scene manager -------------------------------------------------
function SceneManager()
	local s = {}
	s.scenes = {}
	s.current_scenes = ""

	function s:add(scene, name)
		s.scenes[name] = scene
	end

	function s:active(name)
		s.current_scene = name
		s.scenes[s.current_scene]:onActive() -- optional
	end

	function s:update()
		s.scenes[s.current_scene]:update()
	end

	function s:draw()
		s.scenes[s.current_scene]:draw()
	end

	return s
end

--#endregion
-- sets the scene manager
local mgr = SceneManager()
--#region START VARIABLES AND SET UP
--game set up values
local t = 0
local timer = 0
local x = 96
local y = 24
local bordersize = 4
local topindex = 7
local bottomindex = -7
local borderBox = {
	top = topindex + bordersize,
	left = bordersize,
	right = 240 - bordersize,
	bottom = bottomindex + 136 - bordersize
}
local brewingStage = 0
local houseworkcost = 3
local isPickUpScene = false
local isBrewScene = false
local BrewTablebeenInteracted = false
local cutSceneSpr = 320
local brewCompleted = false
local drinkTea = false
-- Skill meter
local skillBarPos = { centre = { x = 240 // 2 + 30, y = 136 // 2 } }
local skillBar = {
	vec = {
		x = { skillBarPos.centre.x, skillBarPos.centre.x + 5, skillBarPos.centre.x + 8,
			skillBarPos.centre.x + 5, skillBarPos.centre.x, skillBarPos.centre.x - 5,
			skillBarPos.centre.x - 8, skillBarPos.centre.x - 5 },
		y = { skillBarPos.centre.y - 8, skillBarPos.centre.y - 5, skillBarPos.centre.y, skillBarPos.centre.y + 5,
			skillBarPos.centre.y + 8, skillBarPos.centre.y + 5, skillBarPos.centre.y, skillBarPos.centre.y - 5 }
	},
	successCheckstep = 0
}
local skillSlider = {
	vec = {
		x = { skillBarPos.centre.x - 11, skillBarPos.centre.x - 9, skillBarPos.centre.x - 6,
			skillBarPos.centre.x - 3, skillBarPos.centre.x, skillBarPos.centre.x + 3,
			skillBarPos.centre.x + 6, skillBarPos.centre.x + 9, skillBarPos.centre.x + 11 },
		y = skillBarPos.centre.y
	},
	successCheckstep = 0,
	isReverse = false
}
local SkillBarStep = 1
local SkillBarhasStepped = false
local skillBoxesPos = {
	vec = {
		x = { skillBarPos.centre.x - 1, skillBarPos.centre.x + 4, skillBarPos.centre.x + 8 - 1,
			skillBarPos.centre.x + 4, skillBarPos.centre.x - 1, skillBarPos.centre.x - 4 - 2,
			skillBarPos.centre.x - 8 - 1,
			skillBarPos.centre.x - 4 - 2 },
		y = { skillBarPos.centre.y - 8 - 1, skillBarPos.centre.y - 4 - 2, skillBarPos.centre.y - 1,
			skillBarPos.centre.y + 4,
			skillBarPos.centre.y + 8 - 1, skillBarPos.centre.y + 4, skillBarPos.centre.y - 1,
			skillBarPos.centre.y - 4 - 2 }
	},
	posbeenSelected = false,
	selecXpos = nil,
	selecYpos = nil
}
local skillSliderBoxesPos = {
	vec = skillSlider.vec,
	posbeenSelected = false,
	selecXpos = nil,
	selecYpos = nil
}
-- Skill check bar
local skillCheckBar = { barWidth = 32, fillThickness = 4, currentFillValue = 0, maxValue = 30, isfull = false }
-- tea bar
local teaBar = { barWidth = 32, fillThickness = 4, currentFillValue = 0, maxValue = 30, isfull = false }
--house work bar
local hWBar = { barWidth = 32, fillThickness = 4, currentFillValue = 0, maxValue = 30, isfull = false }
local player = { sprite = 1, x = 240 // 2, y = 139 // 2, s = 1, objHolding = nil }
--tea items

local teabag = { sprite = 17, x = 240 // 3, y = 140 // 2, collected = false, iswork = false, cutscenespr = 320 }
local kettle = { sprite = 18, x = 240 // 4, y = 140 // 4, collected = false, iswork = false, cutscenespr = 328 }
local cup = { sprite = 19, x = 240 // 8, y = 140 // 8, collected = false, iswork = false, cutscenespr = 324 }

--root houswork items
local wMachine = {
	sprite = 33,
	x = 180,
	y = 80,
	s = 0.5,
	mDown = false,
	mLeft = false,
	spittime = 8,
	hasSpit = true,
	iswork = false
}
local postDoor = {
	sprite = 81,
	x = 225,
	y = 100,
	s = 0.5,
	mDown = false,
	mLeft = false,
	spittime = 13,
	hasSpit = true,
	iswork = false,
	pixsizeX = 11,
	pixsizeY = 16
}
local sink = {
	sprite = 49,
	x = 4,
	y = 30,
	s = 0.5,
	mDown = false,
	mLeft = false,
	spittime = 18,
	hasSpit = true,
	iswork = false,
	pixsizeX = 11,
	pixsizeY = 16
}

---- Items
local workTop = {
	sprite = 113,
	x = 240 // 2 - 16,
	y = topindex + bordersize,
	iswork = false,
	pixsizeX = 32,
	pixsizeY = 16
}

--- insert tables
-- collecteable house items
local washingUp = {}
for i = 1, 8 do
	local wUp = { sprite = math.random(51, 52), x = 240 // 2, y = 140, collected = false, dropped = false, iswork = true }
	table.insert(washingUp, wUp)
end
local laundrys = {}
for i = 1, 8 do
	local laundry = {
		sprite = math.random(34, 35),
		x = 240 // 2,
		y = 140,
		collected = false,
		dropped = false,
		iswork = true
	}
	table.insert(laundrys, laundry)
end
local posts = {}
for i = 1, 8 do
	local post = {
		sprite = 83,
		x = 240 // 2,
		y = 140,
		collected = false,
		dropped = false,
		iswork = true,
		moveSteps = 0,
		postDistance = math.random(5, 20)
	}
	table.insert(posts, post)
end

local staticObjs = {}
table.insert(staticObjs, postDoor)
table.insert(staticObjs, sink)
table.insert(staticObjs, workTop)
--#endregion
--#region BASIC GAME FUNCTIONS
-- Draws the game bounds
function Border(th, c)
	--rectb(x,y,width,height,color)

	rect(0, topindex, th, 136 - topindex + bottomindex, c)
	rect(240 - th, topindex, th, 136 - topindex + bottomindex, c)
	rect(th, topindex, 240 - (th * 2), th, c)
	rect(th, bottomindex + 136 - th, 240 - (th * 2), th, c)
end

function Timer()
	timer = t // 60
	print("Time = " .. timer, 0, 0, 2)
end

--- makes the window delay when skill checks have been successful
local windowDelayTimer = 0
function WindowDelay()
	windowDelayTimer = windowDelayTimer + 1

	if windowDelayTimer // 60 > 1 then
		isPickUpScene = false
		isBrewScene = false
		BrewTablebeenInteracted = false
		windowDelayTimer = 0
		skillBar.successCheckstep = 0
		skillSlider.successCheckstep = 0
		return true
	end
	return false
end

function ResetGame()
	brewingStage = 0
	houseworkcost = 3
	isPickUpScene = false
	isBrewScene = false
	BrewTablebeenInteracted = false
	brewCompleted = false
	drinkTea = false
	t = 0
	timer = 0
	teabag.collected = false
	kettle.collected = false
	cup.collected = false
	teabag.x = 240 // 3
	teabag.y = 140 // 2
	kettle.x = 240 // 4
	kettle.y = 140 // 4
	cup.x = 240 // 8
	cup.y = 140 // 8
	player.x = 240 // 2
	player.y = 139 // 2
end

--#endregion
--#region SKILLCHECK DRAWING FUNCTIONS

function DrawSkillBar()
	-- color changed on font when in the check window
	if skillBoxesPos.selecXpos == SkillBarStep then
		rectb(skillBarPos.centre.x - 4, skillBarPos.centre.y + 12, 9, 9, 6)
		print("Z", skillBarPos.centre.x - 2, skillBarPos.centre.y + 14, 6)
	else
		rectb(skillBarPos.centre.x - 4, skillBarPos.centre.y + 12, 9, 9, 12)
		print("Z", skillBarPos.centre.x - 2, skillBarPos.centre.y + 14, 12)
	end


	circb(skillBarPos.centre.x, skillBarPos.centre.y, 8, 2)
	circb(skillBarPos.centre.x, skillBarPos.centre.y, 7, 2)

	if skillBar.successCheckstep < 5 then
		---tick actions for skill bar
		if t % 10.0 == 0.0 and SkillBarhasStepped == false then
			SkillBarhasStepped = true
			SkillBarStep = SkillBarStep + 1
			if SkillBarStep > 8 then
				SkillBarStep = 1
			end
		elseif t % 20.0 ~= 0.0 and SkillBarhasStepped == true then
			SkillBarhasStepped = false
		end
	end
	-- draws the indicater line
	line(skillBarPos.centre.x, skillBarPos.centre.y, skillBar.vec.x[SkillBarStep], skillBar.vec.y[SkillBarStep], 3)
end

function DrawSkillSlider()
	-- color changed on font when in the check window
	if skillSliderBoxesPos.selecXpos == SkillBarStep then
		rectb(skillBarPos.centre.x - 4, skillBarPos.centre.y + 12, 9, 9, 6)
		print("Z", skillBarPos.centre.x - 2, skillBarPos.centre.y + 14, 6)
	else
		rectb(skillBarPos.centre.x - 4, skillBarPos.centre.y + 12, 9, 9, 12)
		print("Z", skillBarPos.centre.x - 2, skillBarPos.centre.y + 14, 12)
	end

	rectb(skillBarPos.centre.x - 13, skillBarPos.centre.y, 27, 6, 2)
	local steps = #skillSlider.vec.x
	if skillSlider.successCheckstep < 5 then
		---tick actions for skill bar
		if t % 10.0 == 0.0 and SkillBarhasStepped == false then
			SkillBarhasStepped = true
			if SkillBarStep == steps then
				skillSlider.isReverse = true
			elseif SkillBarStep == 1 then
				skillSlider.isReverse = false
			end
			if skillSlider.isReverse then
				SkillBarStep = SkillBarStep - 1
			else
				SkillBarStep = SkillBarStep + 1
			end
		elseif t % 20.0 ~= 0.0 and SkillBarhasStepped == true then
			SkillBarhasStepped = false
		end
	end
	line(skillSlider.vec.x[SkillBarStep], skillBarPos.centre.y + 1, skillSlider.vec.x[SkillBarStep],
		skillBarPos.centre.y + 5 - 1, 3)
end

function SkillSliderBox()
	if skillSliderBoxesPos.posbeenSelected == false then
		local xRan = math.random(#skillSliderBoxesPos.vec.x)

		skillSliderBoxesPos.selecXpos = xRan

		skillSliderBoxesPos.posbeenSelected = true
	else
		DrawSliderSkillBox(skillSliderBoxesPos.selecXpos, skillSliderBoxesPos.vec.y, 3, 4, -1, 1)
	end
end

function SkillBox()
	--Make Skill check box
	if skillBoxesPos.posbeenSelected == false then
		local xRan = math.random(#skillBoxesPos.vec.x)
		local yRan = xRan

		skillBoxesPos.selecXpos = xRan
		skillBoxesPos.selecYpos = yRan

		skillBoxesPos.posbeenSelected = true
	else
		DrawSkillBox(skillBoxesPos.selecXpos, skillBoxesPos.selecYpos, 3, 3, 0, 0)
	end
end

function DrawSkillBox(_xPos, _yPos, _sizeX, _sizeY, _offsetX, _offsetY)
	rect(skillBoxesPos.vec.x[_xPos] + _offsetX, skillBoxesPos.vec.y[_yPos] + _offsetY, _sizeX, _sizeY, 5)
end

function DrawSliderSkillBox(_xPos, _yPos, _sizeX, _sizeY, _offsetX, _offsetY)
	rect(skillSliderBoxesPos.vec.x[_xPos] + _offsetX, skillSliderBoxesPos.vec.y + _offsetY, _sizeX, _sizeY, 5)
end

--#endregion
--#region SKILLCHECK FUNCTIONS

function SuccessStep()
	-- counts the successful skill checks and moves the sprites and adds to the skill check bar
	if skillBar.successCheckstep <= 0 then
		DrawHand(256, 240 // 2 - 40, 136 // 2 - 25, cutSceneSpr, 240 // 2 - 40, 136 // 2 + 6)
		SetBarValue(skillCheckBar, 0)
	elseif skillBar.successCheckstep == 1 then
		DrawHand(256, 240 // 2 - 40, 136 // 2 - 12, cutSceneSpr, 240 // 2 - 40, 136 // 2 + 6)
		SetBarValue(skillCheckBar, 6)
	elseif skillBar.successCheckstep == 2 then
		DrawHand(256, 240 // 2 - 40, 136 // 2, cutSceneSpr, 240 // 2 - 40, 136 // 2 + 6)
		SetBarValue(skillCheckBar, 12)
	elseif skillBar.successCheckstep == 3 then
		DrawHand(260, 240 // 2 - 40, 136 // 2, cutSceneSpr, 240 // 2 - 40, 136 // 2 + 6)
		SetBarValue(skillCheckBar, 18)
	elseif skillBar.successCheckstep == 4 then
		DrawHand(260, 240 // 2 - 40, 136 // 2 - 12, cutSceneSpr, 240 // 2 - 40, 136 // 2 + 6 - 12)
		SetBarValue(skillCheckBar, 24)
	elseif skillBar.successCheckstep >= 5 then
		DrawHand(260, 240 // 2 - 40, 136 // 2 - 25, cutSceneSpr, 240 // 2 - 40, 136 // 2 + 6 - 25)
		local p = print("Collected", 240, 136)
		print("Collected", ((p // 2) + 240 // 2) - 75, 136 // 2 + 20, 6)
		SetBarValue(skillCheckBar, 30)
		if player.objHolding ~= nil then
			Collect(player.objHolding)
		end
		WindowDelay()
	end
end

function SuccessStepSlider()
	-- counts the successful skill checks and moves the sprites and adds to the skill check bar
	if skillSlider.successCheckstep <= 0 then
		SetBarValue(skillCheckBar, 0)
	elseif skillSlider.successCheckstep == 1 then
		SetBarValue(skillCheckBar, 6)
	elseif skillSlider.successCheckstep == 2 then
		SetBarValue(skillCheckBar, 12)
	elseif skillSlider.successCheckstep == 3 then
		SetBarValue(skillCheckBar, 18)
	elseif skillSlider.successCheckstep == 4 then
		SetBarValue(skillCheckBar, 24)
	elseif skillSlider.successCheckstep >= 5 then
		SetBarValue(skillCheckBar, 30)
		--if player.objHolding ~= nil then
		--	Collect(player.objHolding)
		WindowDelay()
	end

	--end
end

function SuccessCheck()
	-- check if skill check is in box area for success check

	if skillBar.successCheckstep < 5 then
		if skillBoxesPos.selecXpos == SkillBarStep then
			-- button press here for win check
			if btnp(4) then
				skillBoxesPos.posbeenSelected = false;
				skillBar.successCheckstep = skillBar.successCheckstep + 1
				if skillBar.successCheckstep > 5 then skillBar.successCheckstep = 5 end
			end
			--print("YES", 240 // 2, 136 // 2, 4, 0, 3)
		else
			if btnp(4) then
				skillBoxesPos.posbeenSelected = false;
				skillBar.successCheckstep = skillBar.successCheckstep - 1
				if skillBar.successCheckstep < 0 then skillBar.successCheckstep = 0 end
			end
			--print("NO", 240 // 2, 136 // 2, 4, 0, 1)
		end
	end
end

function SuccessCheckSlider()
	-- check if skill check is in box area for success check

	if skillSlider.successCheckstep < 5 then
		if skillSliderBoxesPos.selecXpos == SkillBarStep then
			-- button press here for win check
			if btnp(4) then
				skillSliderBoxesPos.posbeenSelected = false;
				skillSlider.successCheckstep = skillSlider.successCheckstep + 1
				if skillSlider.successCheckstep > 5 then skillSlider.successCheckstep = 5 end
			end
			--print("YES", 240 // 2, 136 // 2, 4, 0, 3)
		else
			if btnp(4) then
				skillSliderBoxesPos.posbeenSelected = false;
				skillSlider.successCheckstep = skillSlider.successCheckstep - 1
				if skillSlider.successCheckstep < 0 then skillSlider.successCheckstep = 0 end
			end
			--print("NO", 240 // 2, 136 // 2, 4, 0, 1)
		end
	end
end

--#endregion
--#region BAR FUNCTIONS
---Skill fill bar ---------------------------------------------------------
function SkillBar()
	rectb(skillBarPos.centre.x - skillCheckBar.barWidth // 2, skillBarPos.centre.y - 20, skillCheckBar.barWidth, 6, 12)
	DrawBarFill(skillCheckBar, 6, skillBarPos.centre.x - skillCheckBar.barWidth // 2 + 1, skillBarPos.centre.y - 20 + 1)
end

-- tea bar-----------------------------------------------------------------
function TeaBar()
	local p = print("Tea = ", 0, 140)
	print("Tea = ", 0, borderBox.bottom + bordersize + 1, 12)
	rectb(p, borderBox.bottom + bordersize + 1, teaBar.barWidth, 6, 12)
	DrawBarFill(teaBar, 6, skillBar.successCheckstep, borderBox.bottom + bordersize + 2)
end

---- housework bar ------------------------------------------------------
function HouseWorkBar()
	local p = print("HouseWork = ", 0, 140)
	print("HouseWork = ", 240 - hWBar.barWidth - p, 0, 12)
	rectb(240 - hWBar.barWidth, 0, hWBar.barWidth, 6, 12)
	DrawBarFill(hWBar, 2, 240 - hWBar.barWidth + 1, 1)
end

function SetBarValue(_bar, value)
	_bar.currentFillValue = value
	if value >= _bar.maxValue then _bar.currentFillValue = _bar.maxValue end
	if value <= 0 then _bar.currentFillValue = 0 end
end

function AddToBar(_bar, value)
	_bar.currentFillValue = _bar.currentFillValue + value
	if _bar.currentFillValue >= _bar.maxValue then
		_bar.currentFillValue = _bar.maxValue
		if _bar.isfull == false then
			_bar.isfull = true
		end
	end
end

function MinusBar(_bar, value)
	_bar.currentFillValue = _bar.currentFillValue - value
	if _bar.currentFillValue < 0 then _bar.currentFillValue = 0 end
	if _bar.isfull == true then
		_bar.isfull = false
	end
end

function DrawBarFill(_Bar, _color, _xloc, _yloc)
	rect(_xloc, _yloc, _Bar.currentFillValue, _Bar.fillThickness, _color)
end

--#endregion
--#region PLAYER FUNCTIONS

--- Player Functions-----------------------------------------------------
function DrawPlayer()
	if btn(2) then
		spr(player.sprite, player.x, player.y, 0, 1, 1)
	elseif btn(3) then
		spr(player.sprite, player.x, player.y, 0)
	elseif btn(0) then
		spr(player.sprite + 2, player.x, player.y, 0)
	else
		spr(player.sprite + 1, player.x, player.y, 0)
	end
end

function PlayerMove()
	if isPickUpScene == true or isBrewScene == true then return end
	--up and down movement
	if btn(0) and BorderHit(borderBox.top, player.y) == false then
		player.y = player.y - player.s
	elseif btn(1) and BorderHit(borderBox.bottom, player.y + 8) == false then
		player.y = player.y + player.s
	end
	-- left and right movement
	if btn(2) and BorderHit(borderBox.left, player.x) == false then
		player.x = player.x - player.s
	elseif btn(3) and BorderHit(borderBox.right, player.x + 8) == false then
		player.x = player.x + player.s
	end
end

function AttemptPickUp(obj)
	if Collision(player.x, player.y, 8, obj.x, obj.y, 8, 8) then
		InteractPrompt()
		if btnp(4) then
			if obj.iswork ~= true and player.objHolding == nil then
				player.objHolding = obj
				cutSceneSpr = obj.cutscenespr
				isPickUpScene = true
			end
		else
			if player.objHolding == obj then player.objHolding = nil end
		end
	end
end

function InteractPrompt()
	rectb(player.x - 1, player.y + 15, 9, 9, 6)
	print("Z", player.x + 1, player.y + 17, 6)
end

function Collect(obj)
	if Collision(player.x, player.y, 8, obj.x, obj.y, 8, 8) then
		obj.collected = true
		if obj.iswork == true then MinusBar(hWBar, houseworkcost) end
	end
end

-- checks to see is you have approched the brewing table so you dont interact with it every frame
function IsAtTable()
	if Collision(player.x, player.y, 8, workTop.x, workTop.y, workTop.pixsizeX, workTop.pixsizeY) then
		InteractPrompt()
		if btnp(4) then
			if BrewTablebeenInteracted == false then
				isBrewScene = true
				BrewTablebeenInteracted = true
			end
		end
	end
end

----------------------------------------------------------
--#endregion
--#region OBJECT FUNCTIONS AND COLLISIONS
function ObjMove(obj)
	--if hit top border then moves obj down
	if BorderHit(borderBox.top, obj.y) == true then
		obj.mDown = true
		--if hit bottom border then moves obj up
	elseif BorderHit(borderBox.bottom, obj.y + 8) == true then
		obj.mDown = false
	end
	--if hit right border then moves obj left
	if BorderHit(borderBox.right, obj.x + 8) == true then
		obj.mLeft = true
		----if hit left border then moves obj right
	elseif BorderHit(borderBox.left, obj.x) == true then
		obj.mLeft = false
	end

	--if hits an static obj
	for i = 1, #staticObjs do
		if HitItemWhileMoving(obj, staticObjs[i], staticObjs[i].pixsizeX, staticObjs[i].pixsizeY) then
			if obj.mDown == true then
				obj.mDown = false
			else
				obj.mDown = true
				break
			end
			if obj.mLeft == true then
				obj.mLeft = false
			else
				obj.mLeft = true
				break
			end
		end
	end
	-- this does the actual movement
	if obj.mDown == true then
		obj.y = obj.y + obj.s
	elseif obj.mDown == false then
		obj.y = obj.y - obj.s
	end
	if obj.mLeft == false then
		obj.x = obj.x + obj.s / 2
	elseif obj.mLeft == true then
		obj.x = obj.x - obj.s / 2
	end
end

-- sets the object offscreen when called so it cant be seen
function ResetObj(_obj)
	_obj.x = 240 // 2
	_obj.y = 140
end

------ collisions---------------------------------------------
function BorderHit(_mo, _so)
	if _mo == _so then
		return true
	else
		return false
	end
end

-- collision between px&py and ox&oy with oSize for the pixel width and length for col detection
function Collision(px, py, pSize, ox, oy, oSizeX, oSizeY)
	local hitX = false;
	local hitY = false;
	-- left or right side collided?
	if (px >= ox and px < ox + oSizeX)
		or (px + pSize > ox and px + pSize < ox + oSizeX) then
		hitX = true;
	end
	-- top and bottom collided?
	if (py >= oy and py < oy + oSizeY)
		or (py + pSize > oy and py + pSize < oy + oSizeY) then
		hitY = true;
	end
	--check collision
	if hitX and hitY then
		return true
	else
		return false
	end
end

function HitItemWhileMoving(_mo, _so, _soSizeX, _soSizeY)
	if Collision(_mo.x, _mo.y, 8, _so.x, _so.y, _soSizeX, _soSizeY) then
		return true
	else
		return false
	end
end

--#endregion
--#region GAMEOBJECT DRAW FUNCTIONS
--- Draw functions----------------------------------------------------------------
function DrawObj(sprite, posX, posY, w, h)
	spr(sprite, posX, posY, 0, 1, 0, 0, w, h)
end

function DrawTeaBag()
	DrawObj(teabag.sprite, teabag.x, teabag.y, 1, 1)
end

function DrawKettle()
	DrawObj(kettle.sprite, kettle.x, kettle.y, 1, 1)
end

function DrawCup()
	DrawObj(cup.sprite, cup.x, cup.y, 1, 1)
end

function DrawWMachine()
	DrawObj(wMachine.sprite, wMachine.x, wMachine.y, 1, 1)
end

function DrawLaundry(index)
	DrawObj(laundrys[index].sprite, laundrys[index].x, laundrys[index].y, 1, 1)
end

function DrawPost(index)
	DrawObj(posts[index].sprite, posts[index].x, posts[index].y, 1, 1)
end

function DrawWashingUp(index)
	DrawObj(washingUp[index].sprite, washingUp[index].x, washingUp[index].y, 1, 1)
end

function DrawDoor()
	DrawObj(postDoor.sprite, postDoor.x, postDoor.y, 2, 2)
end

function DrawSink()
	DrawObj(sink.sprite, sink.x, sink.y, 2, 2)
end

function DrawWorkTop()
	DrawObj(workTop.sprite, workTop.x, workTop.y, 4, 2)
end

--#endregion
--#region WASHING MACHINE FUNCTIONS
---Washing machine functions------------------------------------------------------
function WMachineFire()
	-- fires out laundry at every spittime
	if hWBar.isfull == false then
		if timer % wMachine.spittime == 0 then
			SpitLaundry(wMachine)
		else
			wMachine.hasSpit = false
		end
	end
	-- checks at specified time to reset laundry
	if timer % 20 == 0 then
		for i = 1, #laundrys do
			if laundrys[i].collected == true then
				laundrys[i].collected = false
				laundrys[i].dropped = false
				laundrys[i].x = 240 // 2
				laundrys[i].y = 140
			end
		end
	end
end

function SpitLaundry(_wMachine)
	local a = 0
	while (a < #laundrys) do
		a = a + 1
		if _wMachine.hasSpit == false and laundrys[a].y == 140 then
			_wMachine.hasSpit = true
			laundrys[a].x = _wMachine.x
			laundrys[a].y = _wMachine.y
			laundrys[a].dropped = true
			laundrys[a].collected = false
			AddToBar(hWBar, houseworkcost)
			break
		end
	end
end

--#endregion
--#region POST FUNCTIONS
--Post functions ----------------------------------------------------------------------
function PostFire()
	if hWBar.isfull == false then
		if timer % postDoor.spittime == 0 then
			SpitPost()
		else
			postDoor.hasSpit = false
		end
	end
	-- checks at specified time to reset post
	if timer % 20 == 0 then
		for i = 1, #posts do
			if posts[i].collected == true then
				posts[i].collected = false
				posts[i].dropped = false
				posts[i].x = 240 // 2
				posts[i].y = 140
				posts[i].moveSteps = 0
			end
		end
	end
end

function PostMove()
	for i = 1, #posts do
		if posts[i].moveSteps <= posts[i].postDistance and posts[i].dropped == true then
			posts[i].moveSteps = posts[i].moveSteps + 1
			posts[i].x = posts[i].x - 5
		end
	end
end

function SpitPost()
	local a = 0
	while (a < #posts) do
		a = a + 1
		if postDoor.hasSpit == false and posts[a].y == 140 then
			postDoor.hasSpit = true
			posts[a].x = postDoor.x + 2
			posts[a].y = postDoor.y + 6
			posts[a].dropped = true
			posts[a].collected = false
			posts[a].postDistance = math.random(5, 30)
			AddToBar(hWBar, houseworkcost)
			break
		end
	end
end

--#endregion
--#region SINK FUNCTIONS
------------Sink functions -----------------------------------------------------------------------------
function CreateWashingUp()
	if hWBar.isfull == false then
		if timer % sink.spittime == 0 then
			SpitWashingUp()
		else
			sink.hasSpit = false
		end
	end
end

function SpitWashingUp()
	local a = 0
	while (a < #washingUp) do
		a = a + 1
		if sink.hasSpit == false and washingUp[a].y == 140 then
			sink.hasSpit = true
			washingUp[a].x = sink.x + 3 + math.random(3)
			washingUp[a].y = sink.y + 2 + math.random(8)
			washingUp[a].dropped = true
			washingUp[a].collected = false
			AddToBar(hWBar, houseworkcost)
			break
		end
	end
end

--#endregion
--#region POPUP WINDOW FUNCTIONS
---------------------------cut Scene------------------------------------------------------

function DrawCutWindow()
	local xindent = 239 // 4
	local yindent = 136 // 4

	rect(0 + xindent, 136 // 2 - yindent, 239 - xindent * 2, 136 - yindent * 2, 0)
	line(0 + xindent, 136 // 2 - yindent, 239 - xindent, 136 // 2 - yindent, 1)
	line(0 + xindent, 136 - yindent, 239 - xindent, 136 - yindent, 1)
	line(0 + xindent, 136 // 2 - yindent, 0 + xindent, 136 - yindent, 1)
	line(239 - xindent, 136 // 2 - yindent, 239 - xindent, 136 - yindent, 1)

	rect(239 - xindent * 2, 136 - yindent + 1, xindent, 10, 0)
	line(239 - xindent * 2, 136 - yindent + 1, 239 - xindent * 2, 136 - yindent + 10, 1)
	line(239 - xindent * 2, 136 - yindent + 10, 239 - xindent * 2 + xindent, 136 - yindent + 10, 1)
	line(239 - xindent * 2 + xindent, 136 - yindent + 10, 239 - xindent * 2 + xindent, 136 - yindent, 1)

	-- text print
	local p = print("Progress Check", 0, 140)
	print("Progress Check", 239 // 2 - p // 2, 136 // 2 - 136 // 4 + 3, 12)
	local x = print("X to exit", 0, 140)
	print("X to exit", skillBarPos.centre.x - x // 2, 136 // 2 + 37, 14)
	rectb(skillBarPos.centre.x - x // 2 - 2, 136 // 2 + 35, 9, 9, 14)
end

function DrawHand(_handspr, _hxPos, _hyPos, _itemspr, _ixPos, _iyPos)
	spr(_itemspr, _ixPos, _iyPos, 0, 1, 0, 0, 4, 4)
	spr(_handspr, _hxPos, _hyPos, 0, 1, 0, 0, 4, 4)
end

function SkillCheckSequanceCircle()
	DrawCutWindow()
	DrawSkillBar()
	SkillBox()
	SuccessCheck()
	SuccessStep()
	SkillBar()
end

function SkillCheckSequanceSlider()
	DrawSkillSlider()
	SkillSliderBox()
	SuccessCheckSlider()
	SuccessStepSlider()
	SkillBar()
end

function BrewProgress(_timer)
	if brewingStage == 1 then
		SkillCheckSequanceSlider()
		spr(384, 240 // 2 - 12, 136 // 2 + 3, 0, 1, 0, 0, 4, 4)
		if skillSlider.successCheckstep >= 5 then
			spr(328, 240 // 2 - 45, 136 // 2 - 10, 0, 1, 0, 0, 4, 4)
			local p = print("Poured", 240, 136)
			print("Poured", ((p // 2) + 240 // 2) - 70, 136 // 2 + 20, 6)

			if WindowDelay() == true then
				brewingStage = 2
			end
		else
			if _timer // 60 % 2 == 0 then
				tri(240 // 2 - 1, 136 // 2 + 4, 240 // 2 - 3, 136 // 2 + 12, 240 // 2 + 3, 136 // 2 + 12, 11)
			else
				tri(240 // 2 - 1, 136 // 2 + 4, 240 // 2 + 1, 136 // 2 + 12, 240 // 2 - 5, 136 // 2 + 12, 11)
			end
			spr(328, 240 // 2 - 22, 136 // 2 - 24, 0, 1, 0, 1, 4, 4)
		end
		return
	end
	if brewingStage == 2 then
		SkillCheckSequanceSlider()
		spr(384, 240 // 2 - 12, 136 // 2 + 3, 0, 1, 0, 0, 4, 4)
		if skillSlider.successCheckstep >= 5 then
			rect(240 // 2, 136 // 2 - 5, 3, 8, 11)
			spr(261, 240 // 2 - 5, 136 // 2 - 24, 0, 1, 0, 0, 4, 4)
			circ(240 // 2 + 1, 136 // 2 + 4, 3, 11)
			local p = print("Stirred", 240, 136)
			print("Stirred", ((p // 2) + 240 // 2) - 70, 136 // 2 + 20, 6)

			if WindowDelay() == true then
				brewingStage = 3
			end
		else
			if _timer // 60 % 2 == 0 then
				rect(240 // 2 - 5, 136 // 2 + 4, 3, 8, 11)
				spr(261, 240 // 2 - 10, 136 // 2 - 15, 0, 1, 0, 0, 4, 4)
			else
				rect(240 // 2 + 5, 136 // 2 + 4, 3, 8, 11)
				spr(261, 240 // 2, 136 // 2 - 15, 0, 1, 0, 0, 4, 4)
			end
		end
		return
	end
	if brewingStage == 3 then
		-- stops all housework developing for player to finish whats left ---
		brewCompleted = true



		spr(384, 240 // 2 - 12, 136 // 2, 0, 1, 0, 0, 4, 4)
		if _timer // 60 % 2 == 0 then
			-- this draws the heat haze aboove the cup
			spr(388, 240 // 2 - 12, 136 // 2 - 5, 0, 1, 0, 0)
			spr(388, 240 // 2 - 6, 136 // 2 - 5, 0, 1, 1, 0)
			spr(388, 240 // 2, 136 // 2 - 5, 0, 1, 0, 0)
			spr(388, 240 // 2 + 6, 136 // 2 - 5, 0, 1, 1, 0)
		else
			spr(388, 240 // 2 - 12, 136 // 2 - 5, 0, 1, 1, 0)
			spr(388, 240 // 2 - 6, 136 // 2 - 5, 0, 1, 0, 0)
			spr(388, 240 // 2, 136 // 2 - 5, 0, 1, 1, 0)
			spr(388, 240 // 2 + 6, 136 // 2 - 5, 0, 1, 0, 0)
		end

		if hWBar.currentFillValue > 0 then
			local p = print("Finish The housework", 240, 136)
			print("Finish The housework", (240 // 2 - p // 2), 136 // 2 - 20, 6)
		else
			local p = print("You Have Won", 240, 136)
			print("You Have Won", (240 // 2 - p // 2), 136 // 2 - 20, 6)
			if _timer / 60 % 4 == 0 then
				drinkTea = true
			end
		end
		return
	end
	--- shows whats been collected ----
	if cup.collected == true and teabag.collected == false and kettle.collected == false then
		spr(324, 240 // 2 - 12, 136 // 2, 0, 1, 0, 0, 4, 4)
	elseif teabag.collected == true and cup.collected == false and kettle.collected == false then
		spr(320, 240 // 2 - 12, 136 // 2, 0, 1, 0, 0, 4, 4)
	elseif kettle.collected == true and teabag.collected == false and cup.collected == false then
		spr(328, 240 // 2 - 12, 136 // 2, 0, 1, 0, 0, 4, 4)
	elseif cup.collected == true and kettle.collected == true and teabag.collected == false then
		spr(328, 240 // 2 + 12, 136 // 2, 0, 1, 0, 0, 4, 4)
		spr(324, 240 // 2 - 42, 136 // 2, 0, 1, 0, 0, 4, 4)
	elseif cup.collected == true and teabag.collected == true and kettle.collected == false then
		spr(320, 240 // 2 + 12, 136 // 2, 0, 1, 0, 0, 4, 4)
		spr(324, 240 // 2 - 42, 136 // 2, 0, 1, 0, 0, 4, 4)
	elseif kettle.collected == true and teabag.collected == true and cup.collected == false then
		spr(320, 240 // 2 + 12, 136 // 2, 0, 1, 0, 0, 4, 4)
		spr(328, 240 // 2 - 42, 136 // 2, 0, 1, 0, 0, 4, 4)
	elseif cup.collected == true and teabag.collected == true and kettle.collected == true then
		brewingStage = 1
	end

	--SkillSliderBox()
	--DrawSkillSlider()
end

function DrawBrewingSequance()
	DrawCutWindow()
	BrewProgress(t)
end

function CancelPickUpScene()
	isPickUpScene = false
	skillBar.successCheckstep = 0
end

function CancelBrewingScene()
	isBrewScene = false
	BrewTablebeenInteracted = false
	skillBar.successCheckstep = 0
end

--#endregion
--#region GAME LOOP
------The Games Game Loop ----------------------------------------------------------------------------
function MainGameLoop()
	cls(0)
	Border(bordersize, 9)
	HouseWorkBar()
	TeaBar()
	t = t + 1
	PlayerMove()
	Timer()
	AttemptPickUp(teabag)
	AttemptPickUp(kettle)
	AttemptPickUp(cup)
	for i = 1, #laundrys do
		Collect(laundrys[i])
	end
	for i = 1, #posts do
		Collect(posts[i])
	end
	for i = 1, #washingUp do
		Collect(washingUp[i])
	end

	ObjMove(wMachine)
	DrawWorkTop()
	IsAtTable()
	if teabag.collected == false then
		DrawTeaBag()
	elseif teabag.collected == true then
		ResetObj(teabag)
	end
	if kettle.collected == false then
		DrawKettle()
	elseif kettle.collected == true then
		ResetObj(kettle)
	end
	if cup.collected == false then
		DrawCup()
	elseif cup.collected == true then
		ResetObj(cup)
	end

	DrawSink()
	DrawDoor()
	DrawWMachine()
	PostMove()

	for i = 1, #laundrys do
		if laundrys[i].collected == false then
			DrawLaundry(i)
		elseif laundrys[i].collected == true then
			ResetObj(laundrys[i])
		end
	end
	for i = 1, #posts do
		if posts[i].collected == false then
			DrawPost(i)
		elseif posts[i].collected == true then
			ResetObj(posts[i])
		end
	end
	for i = 1, #washingUp do
		if washingUp[i].collected == false then
			DrawWashingUp(i)
		elseif washingUp[i].collected == true then
			ResetObj(washingUp[i])
		end
	end
	--- item actions
	if brewCompleted == false then
		WMachineFire()
		PostFire()
		CreateWashingUp()
	end
	DrawPlayer()

	--- cut scene skill checks ------
	if isPickUpScene == true then
		SkillCheckSequanceCircle()
		if btnp(5) then
			CancelPickUpScene()
		end
	end
	if isBrewScene == true then
		DrawBrewingSequance()
		if btnp(5) then
			CancelBrewingScene()
		end
	end
	--- if game is won ------
	if drinkTea == true then
		mgr:active("end")
	end
end

--#endregio
--#region SCENES

--------Scenes -----------------------------------------------------------------------------
function Title()
	local s = {}
	local ti = 0
	function s:onActive() -- optional
		sync(1, 1)
		ti = 0
	end

	function s:update()

	end

	function s:draw()
		cls()
		ti = ti + 1
		spr(0, 240 // 2 - 64, 136 // 3 - 40 + math.sin(ti // 5 - 10) * 2, 0, 1, 0, 0, 16, 4)
		--BrewProgress(ti)
		spr(66, 240 // 2 - 20, 136 // 3, 0, 1, 0, 0, 5, 8)
		local p = print("Press z to start", 0, 136)
		print("Press z to start", 240 // 2 - p // 2, 136 - 20, 12, 0, 1)
		if btnp(4) then
			mgr:active("game")
		end
	end

	return s
end

function Game()
	local s = {}
	function s:onActive() -- optional
		sync(1, 0)
		ResetGame()
	end

	function s:update()

	end

	function s:draw()
		MainGameLoop()
		if btnp(6) then
			mgr:active("title")
		end
	end

	return s
end

------ testing scene ---------
function Test()
	local s = {}
	function s:onActive() -- optional
		sync(1, 0)
	end

	function s:update()

	end

	function s:draw()
		cls()

		DrawCutWindow()
		local p = print("Finish The housework", 240, 136)
		print("Finish The housework", (240 // 2 - p // 2), 136 // 2 - 20, 6)
		spr(384, 240 // 2 - 12, 136 // 2, 0, 1, 0, 0, 4, 4)
	end

	return s
end

---- end scene ------------
function End()
	local s = {}
	local ti = 0
	function s:onActive() -- optional
		sync(1, 2)
		ti = 0
	end

	function s:update()

	end

	function s:draw()
		cls()
		spr(0, 56, 5, -1, 1, 0, 0, 16, 16)
		ti = ti + 1
		local p = print("Enjoy your tea", 240, 136)
		print("Enjoy your tea", (240 // 2 - p // 2), 136 // 2 - 20 + math.sin(ti // 5 - 10) * 2, 1)
		if ti // 60 >= 10 then
			mgr:active("title")
		end
	end

	return s
end

--#endregion
-----------------------------------------------------------------------------------------
--********************* MAIN ************************************************************

mgr:add(Title(), "title")
mgr:add(Game(), "game")
mgr:add(Test(), "test")
mgr:add(End(), "end")
mgr:active("title")

-- TIC is called at 60fps-----
function TIC()
	mgr:draw()
end

--*********************MAIN END **********************************************************
------------------------------------------------------------------------------------------

--#region TILES, SPRITES, MAP AND SOUND DATA USED BY TIC-80
-- <TILES>
-- 001:00eeee000e4444000e4c4c0004444400034443004033304000eee00000e0e000
-- 002:0eeeee000444440004c4c40004444400034443004033304000eee00000e0e000
-- 003:00eee0000eeeee000eeeee0004eee400033333004033304000eee00000e0e000
-- 017:0cc00000c00c0000c000ccc0c00c111ccc0c111ccc0c111c000ccccc00000000
-- 018:0000cc00c00c00c0cc0cccc00cc8888c00c8888c00c8888c000cccc000000000
-- 019:00000000cccccc00cddddccccddddc0ccddddcc0ccddcc000cccc00000000000
-- 033:cccccccccffff2fccffffffccffccffccfc00cfccfc00cfccffccffccccccccc
-- 034:0044400004404000040444000044444004444440044404400040440000004000
-- 035:0000000000055555000555550005505500550055005500500550055005500550
-- 049:cccccccccfffffffcffccccccfdd0000cffc0000cffc0000cfdd0000cffccccc
-- 050:ccc00000ffc00000cfc00000cfc00000cfc00000cfc00000cfc00000cfc00000
-- 051:0404040004040400004440000004000000330000003300000033000000330000
-- 052:0000000000000000000000000000000044449999444099990000000000000000
-- 065:cfffffffcfff7f7fcfff7f7fcfff7f7fcfff7f7fcfff7f7fcfffffffcccccccc
-- 066:ffc000007fc000007fc000007fc000007fc000007fc00000ffc00000ccc00000
-- 081:ccccccccc2222222c2222222c22cccccc22c777cc22c777cc22c777cc22ccccc
-- 082:ccc0000022c0000022c0000022c0000022c0000022c0000022c0000022c00000
-- 083:000b000000b9b0000bb9bb00bbb9bbb00bb9999b00bbbbb0000bbb000000b000
-- 097:c2222222c2222222c22eeeeec2222222c2222222c2222222c2222222cccccccc
-- 098:2ec0000022c0000022c0000022c0000022c0000022c0000022c00000ccc00000
-- 113:ccccccccc3333333c3333333c3333333c3333333c3333333c3333333c3333333
-- 114:cccccccc33333333333333333333333333333333333333333333333333333333
-- 115:cccccccc33333333333333333333333333333333333333333333333333333333
-- 116:cccccccc3333333c3333333c3333333c3333333c3333333c3333333c3333333c
-- 129:c3333333c3333333c3333333c3333333c3333333c3333333c3333333cccccccc
-- 130:33333333333333333333333333333333333333333333333333333333cccccccc
-- 131:33333333333333333333333333333333333333333333333333333333cccccccc
-- 132:3333333c3333333c3333333c3333333c3333333c3333333c3333333ccccccccc
-- </TILES>

-- <TILES1>
-- 000:0000000000000000000000000000000000000000000999990009cccc0099cccc
-- 001:000000000000000000000000000000000000000099999999cccccccccccccccc
-- 002:00000000000000000000000000000000000000009999999999ccccc999ccccc9
-- 003:000000000000000000000000000000000000000000999999009ccccc009ccccc
-- 004:0000000000000000000000000000000000000000999999999ccccccc9ccccccc
-- 005:000000000000000000000000000000000000000099999990cccccc90cccccc99
-- 007:00000000000000000000000000000000000000000999999909cccccc99cccccc
-- 008:000000000000000000000000000000000000000099999990cccccc90cccccc99
-- 010:00000000000000000000000000000000000000000999999909cccccc99cccccc
-- 011:000000000000000000000000000000000000000099999999cccccc99cccccc99
-- 012:000000000000000000000000000000000000000099999900ccccc900ccccc900
-- 013:0000000000000000000000000000000000000000999999999ccccc999ccccc99
-- 014:000000000000000000000000000000000000000099999999cccccccccccccccc
-- 015:000000000000000000000000000000000000000099999000cccc9000cccc9900
-- 016:009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc
-- 017:cccccccccccccccc9999cccc9009cccc9009cccc9009cccc9009999990000000
-- 018:c9ccccc9c9ccccc9c9ccccc9c9ccccc9c9ccccc9c9ccccc999ccccc909ccccc9
-- 019:009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc
-- 020:9ccccccc9ccccccc9ccccc999ccccc909ccccc909ccccc999ccccccc9ccccccc
-- 021:ccccccc9ccccccc999ccccc909ccccc909ccccc999ccccc9ccccccc9ccccccc9
-- 023:9ccccccc9ccccccc9ccccc999ccccc909ccccc909ccccc999ccccccc9ccccccc
-- 024:ccccccc9ccccccc999ccccc909ccccc909ccccc999ccccc9ccccccc9ccccccc9
-- 026:9ccccccc9ccccccc9ccccc999ccccc909ccccc909ccccc909ccccc909ccccc90
-- 027:ccccccc9ccccccc999ccccc909ccccc909ccccc909ccccc90999999900000009
-- 028:ccccc900ccccc900ccccc900ccccc900ccccc900ccccc999cccccccccccccccc
-- 029:9ccccc9c9ccccc9c9ccccc9c9ccccc9c9ccccc9c9ccccc9ccccccc9ccccccc9c
-- 030:cccccccccccccccccccc9999cccc9009cccc9009cccc9999cccccccccccccccc
-- 031:ccccc900ccccc900ccccc900ccccc900ccccc900ccccc900ccccc900ccccc900
-- 032:009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc
-- 033:90000000900999999009cccc9009cccc9009cccc9009cccc9999cccccccccccc
-- 034:09ccccc999ccccc9c9ccccc9c9ccccc9c9ccccc9c9ccccc9c9ccccc9c9cccccc
-- 035:009ccccc009ccccc009ccccc009ccccc009ccccc009ccccc999ccccccccccccc
-- 036:9ccccccc9ccccccc9ccccc999ccccc909ccccc909ccccc909ccccc909ccccc90
-- 037:cccccc99cccccc90999999900000000000000000000000000000000000000000
-- 039:9ccccccc9ccccccc9ccccc999ccccc909ccccc909ccccc909ccccc909ccccc90
-- 040:ccccccc9ccccccc999ccccc909ccccc909ccccc909ccccc909ccccc909ccccc9
-- 042:9ccccc909ccccc909ccccc909ccccc909ccccc909ccccc909ccccc999ccccccc
-- 043:000000090999999909ccccc909ccccc909ccccc909ccccc999ccccc9ccccccc9
-- 044:ccccccccccccccccccccc999ccccc900ccccc900ccccc900ccccc900ccccc900
-- 045:cccccc9ccccccc9c9ccccc9c9ccccc9c9ccccc9c9ccccc9c9ccccc9c9ccccc9c
-- 046:cccccccccccccccccccc9999cccc9009cccc9009cccc9009cccc9009cccc9009
-- 047:ccccc900ccccc900ccccc900ccccc900ccccc900ccccc900ccccc900ccccc900
-- 048:009ccccc0099cccc0009cccc0009999900000000000000000000000000000000
-- 049:cccccccccccccccccccccccc9999999900000000000000000000000000000000
-- 050:c9cccccc999ccccc909ccccc9099999900000000000000000000000000000000
-- 051:ccccccccccccccc9ccccccc99999999900000000000000000000000000000000
-- 052:9ccccc909ccccc909ccccc909999999000000000000000000000000000000000
-- 055:9ccccc909ccccc909ccccc909999999000000000000000000000000000000000
-- 056:09ccccc909ccccc909ccccc90999999900000000000000000000000000000000
-- 058:9ccccccc99cccccc09cccccc0999999900000000000000000000000000000000
-- 059:ccccccc9cccccc99cccccc999999999900000000000000000000000000000000
-- 060:ccccc900ccccc900ccccc9009999990000000000000000000000000000000000
-- 061:9ccccc9c9ccccc9c9ccccc9c9999999900000000000000000000000000000000
-- 062:cccc9009cccc9009cccc90099999900900000000000000000000000000000000
-- 063:ccccc900ccccc900ccccc9009999990000000000000000000000000000000000
-- 066:0000000000000000000000000088888808ffffff08ffffff08ffffffffff1f88
-- 067:000000000000000000000000888888881fffffff1ffffffffffff88888888444
-- 068:00000000000000000000000088888880fffffff8fffffff8888ffff84448fff8
-- 081:0000000000000000000000000000000000000000000000000000000400000004
-- 082:ffff8844ffff8844f1ff8444ffff8444ffff8444ffff84444488444444884444
-- 083:4444444444444444444444444444444444444444884444444444444444444444
-- 084:4444888844448888444448884444488844444888444888884444444844444448
-- 085:0000000000000000000000000000e00000000e0000000e000000e00000000e00
-- 086:0000000000000000000000000e00e000e0000e00e0000e000e00e000e0000e00
-- 097:0000000400000004000000040000000400000000000000000000000000000000
-- 098:4488448844884444448844444488444408114444001144440001444400008444
-- 099:8844444448444444444444444444444448444444488444444488888844444444
-- 100:4448888844484448444444484444444844444448444444488888444844441ff2
-- 101:0000000000088883888edddd888edddd228edddd228edddd228edddddd82dddd
-- 102:00000000333dd800dddddd80dddddd80ddddd380dddddd80dddddd80ddddd380
-- 114:0000888800000000000000000000000000008888000088880088332208333333
-- 115:344444449444488894444800f122280038888800388888882333333333333333
-- 116:4449999288800008000000080000000800000000222000003338000033338880
-- 117:dd82dddd2282dddd2282dddd888ddddd888ddddd008ddddd0002993300802288
-- 118:ddddd380ddddd380ddddd380ddddd380ddd33380ddd333803333390088888000
-- 130:0833333308333333083333330833333308333333083333880833338808333388
-- 131:3333333333333333333333333333333333333333333333333333333303333333
-- 132:3333333833333338333833333338233333382333333888833338000333380008
-- 133:0033222288332222333333283333332833333328333333803333338088888800
-- 134:8000000080000000000000000000000000000000000000000000000000000000
-- 146:0833338808333388083322880833228808332288082222880822338808223388
-- 147:0333333322222333223333332233333322333333223333338222288882222888
-- 148:3338000033380000333800003338000033380000333800008880000088800000
-- 162:0822338800223333002233330088222200008822000088220000882200008888
-- 163:8888881138888111388881112288811122888001228880012288800188888001
-- 164:1180000011800000118000001180000011800000118000001180000011800000
-- 178:0000881100008811000088110000888800008888000000000000000000000000
-- 179:1118800111188001111888888888888888888888000000000000000000000000
-- 180:1180000011800000888888808888888088888880000000000000000000000000
-- </TILES1>

-- <TILES2>
-- 000:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa700aaaaa700aaaaa700
-- 001:aaaaaaaaaa777777aa000000aa000000aa000000000000660000006600000066
-- 002:aaa70000777f0000000f6666000f666600066666666666666666666666666666
-- 003:6666666660ff776700000000000000000000000066666aaa66666aaa66666aaa
-- 004:66666666fff000f6000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaa
-- 005:666666666006660f000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaa
-- 006:660000006f000000006666660066666600666666aaaaaaf0aaaaaa80aaaaaa80
-- 007:0000000000000000666660006666600066600000000000000000000000000000
-- 008:0000000000000000006666660066666600666666000000000000000000000000
-- 009:000000000000000066666600666666006f066000000000000000000000000000
-- 010:7aaaaaaa07777777000000000000000000000000000110000001100000022000
-- 011:aaaaaaaa7aaaaaaa0aaaaaaa0aaaaaaa0aaaaaaa0aaaaaaa0aaaaaaa0aaaaaaa
-- 012:a7000666a7000666a7000666a7000666a7000666aaaaa000aaaaa000aaaaa000
-- 013:f0000000600000006666600666666006666667767aaaaaaa7aaaaaaa7aaaaaaa
-- 014:0066600000666000666666666666666666666000aa700000aa700000aa700000
-- 015:0666000000000000000000000000000000000000000066660000666600006666
-- 016:aaaaaa00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 017:00000766aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 018:66666666aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 019:6666aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 020:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa77aaaaa700aaaaa700aa777700
-- 021:aaaaaaaa700000007000000070000000f000f00f000666660006666600066666
-- 022:aaaaaaf0000000f6000000f6000000f6ff0fff66666666666666666666666666
-- 023:0000000066666666666666666666666666666666666666666666666666666666
-- 024:000000006666666666666666566666666666666666666aaa66666aaa66666aaa
-- 025:0000000066666666666666666666666666666666a66666aaa66666aaa6666aaa
-- 026:0000000066000000660000006600000066677777aaaaaaaaaaaaaaaaa7777777
-- 027:07aaaaaa00000000000000000000000077770000aaaa7001aaaa700177770000
-- 028:aaaaa00000000000000000000000000000000000221000002100022200000221
-- 029:0777aaaa00007aa700007aa700007aa700007aa700007aa700007aa700007777
-- 030:aaf0000000000000000000000000000000000f77000007aa000007aa00000f77
-- 031:000066600666000006660000066600007666777fa000aaa7a000aaa776667777
-- 032:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 033:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 034:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 035:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 036:aa000066aa000066aa000f66aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 037:666666666666666666666666aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 038:6666606a66666f6a66666f6aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 039:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 040:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 041:aaaaaaaaaaaaaaaaaaaaaaaaa7000000a7000000a7000000a7000000a7000066
-- 042:7000000070000000700000000666666606666666066666660666666066000000
-- 043:0000000000000000000000006666666666666666666666666666666600000000
-- 044:0000000000000000000000006000000060000000600000006000000000666666
-- 045:122200001222000012220000000000000000000100000111000002116aaa7000
-- 046:0000000000000000000000001100000022000000220000001100000000000000
-- 047:0aaaf0000aaaf0000aaaf0000000000000000000000000000000000002220000
-- 048:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 049:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 050:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 051:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 052:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 053:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 054:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 055:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 056:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 057:a7000066a7000066a7000066aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 058:660000006600000066700000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 059:000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 060:006666660066666607666666aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 061:6aaa70006aaa7000677a70007000666670006666700066667000f66670000000
-- 062:0000000000000000000000006666666666666666666666666666666600000000
-- 063:0222000002220000001200006000222260002222600022226000011100000000
-- 064:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 065:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 066:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 067:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 068:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 069:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 070:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 071:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 072:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 073:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 074:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 075:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 076:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 077:70000000700000007000000070000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 078:00000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 079:00000000000000000000000000000000aaaa7000aaaa7000aaaa7000aaaa7000
-- 080:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 081:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 082:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 083:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 084:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 085:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 086:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 087:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 088:aaaadd33aaad4444aad44444ad444444a4444444d44444444444444444444444
-- 089:33aaaaaa4433aaaa44443aaa444443aa4444433a4444443a4444443344444433
-- 090:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 091:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 092:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 093:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 094:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 095:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 096:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00aaaaaa00
-- 097:aaaaaaaaaaaaaaaaaa777777aa000000aa000000aa00000000fff00000111000
-- 098:aaaaaaaaaaaaaaaa777777770000000000000000000000000000000000000000
-- 099:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaa0000aaaa
-- 100:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 101:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 102:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 103:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 104:44444444d4444444a4444444ad444444aaa34444aaaa3333aaaaaa33aaaaaaaa
-- 105:444444334444433a4444333a444333aa43333aaa3333aaaa33aaaaaaaaaaaaaa
-- 106:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 107:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 108:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 109:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 110:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 111:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 112:aaaaaa00aaf00000aa000000aa000000aa000000aa000000aa000000aa000000
-- 113:0011100000000000000000000000000000000000000000000000000000000000
-- 114:00000000000000000000000000000000000000000000ffff000e4444000e4444
-- 115:00007aaa000000fa0000000a0000000a0000000affff000a4444000a4444000a
-- 116:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 117:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 118:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 119:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 120:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 121:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 122:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 123:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 124:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 125:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 126:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 127:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaacccc70ffccccf000ccccf000
-- 128:aa000000aa000000aa000000aa000000aa000000aa000000aa000000aa000000
-- 129:000000000000000000000000000000000011100000444f0000444f0000444f00
-- 130:000e444414444f00ec444f0014444f0014444d21144444441444444414444444
-- 131:444400fa0000daaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa00004aaa
-- 132:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 133:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 134:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 135:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 136:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 137:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 138:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 139:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 140:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 141:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 142:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadddaaaaae00aaaaae00aaaaae00
-- 143:ccccf000d000dccce000dcccd000dcccefffdcccfcccddddfcccddddfcccdddd
-- 144:aaeeef00aaaaad00aaaaad00aaaaad00aaaaad00aaaaad00aaaaad00aaaaad00
-- 145:00e22e1100000d4400000d4400000d4400444444004444440044444400333444
-- 146:344444444444444444444444444444444444444444444444444444444444dddd
-- 147:e111eeea4444000a4444000a4444000a1000dddaf000daaaf000daaaf000daaa
-- 148:aaaaaaaaaaaddaaaaaaddaaaaaaddaaaaadddaaaaadddaaaaadddaaaaaaddaaa
-- 149:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaddaaaaadedaaaaadedaaaaadddaaaaa
-- 150:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 151:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 152:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 153:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 154:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 155:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 156:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadddddd
-- 157:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaad0000000d0000000d0000000e0000000
-- 158:aadeefffaaf00feeaaf00feeaaf00fee00feeedd00eddddd00eddddd00eddddd
-- 159:ecddeeeedddd0000dddd0000dcdd0000dddd0000dddd0000dddd0000dddd0000
-- 160:aaaaad00aaaaae00aaaaae00aaf00000aa000000aa000000aa000000aa000000
-- 161:00000d4400000d4400000d4400dddf00003330000033300000eddfff00000e33
-- 162:444100004441000044410000000edddd000eaaaa000eaaaaffffeeee333e000f
-- 163:daadaaaadaaaaaaadaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 164:aaaaaaefaaaaaaefaaaaaaefaaadddedaaaddedaaaaadedaaaaaddedaaaaaaee
-- 165:daaaaaaadaaaaaaadaaaaaaaaaadddaaaaaeedaaaaaeedaaaaaeedaadaaeedaa
-- 166:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 167:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 168:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 169:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 170:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 171:aaaaaaaaaaaaaaaaaaaaaaaaaaaae000aaaaf000aaaaf000adeeffffa000eccc
-- 172:ae000000ae000000ae0000000edddddd0ecccccc0eccccccfeccceeecccc4000
-- 173:0cccdeddfcccddddfcccdddddccce000ccccf000ccccf000eeee000000000000
-- 174:dddddddddddddddddddddddd0000000000000000000000000000000055666666
-- 175:e0000000e0000000e00000000666000605566006055560060666666666666666
-- 176:aa000000dd00000000d333330033333300d33333dd0000003300000033000000
-- 177:00000e3d00000edd33333f0033333f0033333e0000000edd00000e3d00000e33
-- 178:d33e000fdddf000f0000000f0000000f0000000fdddf0000dddf0000dddf0000
-- 179:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 180:aaaaaaeeaaaaaaeeaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaeeaaaaaaeeaaaaaaee
-- 181:daaeedaadadeedaadedaaaaadedaaaaadddaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 182:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 183:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 184:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 185:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 186:aaaaaaaaaaaaaaddaaaaad00aaaaaa00aaaaad00700000ee700000ee700000ee
-- 187:a000dcccef00dccc0ccccccc0ccccccc0dcccccce0000000e0000000e0000000
-- 188:cccc4000cd55d000ce000666ce000655ce000655006666660055666600566666
-- 189:000000000000000f666666666555555565555556666666666566666665566666
-- 190:5555566656666666566666555566665556666655566006665560066656666666
-- 191:66666666666666666000000660000006666f6006655560066555600665556006
-- 192:33deeeee33dddddd33dddddd33ddddddddddd333ddddd333ddddd33300d33333
-- 193:eeeeefffddddd000ddddd000ddddd00033333f00333330003333300033333ddd
-- 194:dddf0000d3df0000d3df0000d33effffd333ddddd333ddddd333dddde00edddd
-- 195:aaaaaaaa9aaaaaaa9aaaaaaaaaaa7777aaaa0000aaaa0000aaaa0000f000ede0
-- 196:aaaaaaaaaaaaaaaaaaaaaaaa7777777700000000000000000000000000fddddd
-- 197:aaaaaaaaaaaaaaaaaaaaaaaa77777777000000000000000000000000d5ddde00
-- 198:aaaaaaaaaaaaaaaaaaaaaaaa77aaaaaa00eeeeee00eeeeee00eeeeee00eeeeee
-- 199:aaaaaaeeaaaaaaeeaaaaaaeeaaaaaaeeeeeeedddeddeeeddeddeeeeeeeeee9aa
-- 200:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeeeeeedeeeeeeedeeeeeeeaaaaa000
-- 201:eaaaa666eaaaa666eaaaa665e7777f00ef000000ef000000ef0000000000006f
-- 202:00000000000000000000000000000000000000650000006500000065ffffff66
-- 203:00000666000065550000f5550000656656655665566666655555565566666666
-- 204:666666ff66666600666556006666666656000655560006555600065566666666
-- 205:656665566556655665565556666666666000000f600600006066000066666666
-- 206:666666660006600666006f0666666666666556f0666556006665560066666606
-- 207:6666f0006666600066666000666660066566666666666666666666666666fff6
-- 208:00d3333300d3333300d3333300d3333300d3333300d3333300edd33300edd333
-- 209:3333333333333333333333333333333333333333333333333333333333333333
-- 210:f00eddddf00eddddf00eddddf00eddddf00eddddf00eddddf00eddddf00edddd
-- 211:0000dcc000002440000024400000244000002420000022200000000000000000
-- 212:00fccccc00fccccc00fccccc00fcccc400fccccc00fccccc00f4cccc00fccc44
-- 213:cccccc00cccccd00cccccd00cccccd00cc4cc400cc4cc400ccc445004cc44500
-- 214:00eeedee00eeeeee00eeeeee00eeeeee00eeeeee00eeeeee00aaaaaa00aaaaaa
-- 215:eeeee9aaeeeee9aaeeeee9aaeeeee800eeeee800eeeee800aaaaa766aaaaaa66
-- 216:aaaaa000aaaaa000aaaaa000000006660000065500000555ffff666666666666
-- 217:0000005500000056000000666666666655666566556555665666566666666666
-- 218:5555665565556655655666656666665555666655666665556666665566666666
-- 219:660006606f000666600066666000666660006565600066666666655566556665
-- 220:0666666606666666f66666666666666666656666666666666665666666666666
-- 221:6556666665566666666666666666600666556006655560066666666666666666
-- 222:566f666656666000666f60005566660055655600556556006666666666000656
-- 223:6000ff066000f6f6ff0ff6666666f0066566600666666f066666666666666665
-- 224:00edd33300eddd3300eddd3300eddd3300eddd3300eddd3300eddd3300eddd33
-- 225:3333333333333333333333333333333333333333333333333333333333333333
-- 226:f00eddddf00eddddf00eddddf00eddddf0000000f0000000f0000000f0000000
-- 227:00000000000077700000aaa00000aaa0000089a7000089aa0000000000000000
-- 228:00fccc4400fccc4c00fccccc00fc4ccc77f00000aa7000000000000000000000
-- 229:4cc445004ccccd00cccccd00444ccd0000000faa000000aa000000aa000000aa
-- 230:00aaaaaa00aaaa6600aaaa6500aaaa65aaa66665aa666666aa666666aa655566
-- 231:aaaaaa6666666665565555655665566666666665666666656666666566666666
-- 232:6666666666556566655565656655656656666666666666666666666666656666
-- 233:6666666656666666566666665566666655566666666666666666666666655566
-- 234:6666666666666666665555556665655655666656556666665566666666666666
-- 235:6666666566666666656666656556566666555566665556666665566666665555
-- 236:5566666666555666555556665655566666656566666665666666655655566566
-- 237:6666666666666666555565565555655660000000f00000006000000060000000
-- 238:6600066660666655666555550065555500000000000000000000000000000000
-- 239:666666666000000060000000600000000666dddd0555cccc0555cccc0555cccc
-- 240:00eddd3300eddd3300eddd3300eddd3300eddd3300eddd3300eddd3300eddd33
-- 241:3333333333333333333333333333333333333333333333dd333333dd33333ddd
-- 242:f0000000f00fddddf00eddddf00fddddeffeddddddd33333ddd33333ddd33333
-- 243:00000000dddddddedddddddddddddddddddddddd3333333d3333333d333333de
-- 244:000ff000eed33d00dd333d00dd333d00dd333d00ddd33e00ddd33e00eeddde00
-- 245:0f000f6605555566056666660556666606666666000000000000000000000000
-- 246:666666666666656666655666665566666666666500000065000000f5000000f5
-- 247:6666666666555666665666666666666655666666556666656566666655566666
-- 248:6665666666666555666665556666665566656655666666556666666566666665
-- 249:6665556655666666556666666566665656666666566666665566666655666665
-- 250:6666666666666556666665666665655666666655655566556666665566665555
-- 251:6666666665550000655500006655000066660000600000006000000060000000
-- 252:6666666f00000000000000000000000000000000000006550000066600000555
-- 253:6efef000fccc5555fccc5665fccc5655f5555555666654cc666655cc666655cc
-- 254:00000fee555555cc656665cc666665cc555665cccc5665cccc5665cccc555ccc
-- 255:f6665555d0006566d0006566d0006555deeef666ccccf000cccc0000ccccf000
-- </TILES2>

-- <SPRITES>
-- 001:0004444400044444000044440000444400004444000444440004444400444444
-- 002:4444440044444440444444404444444044444444444444444444444444444444
-- 003:0000000000000000000000000000000000000000400000004000000040000000
-- 005:0004444400044444000044440000444400004444000444440004444400444444
-- 006:4444440044444440444444404444444044444444444444444444444444444444
-- 007:0000000000000000000000000000000000000000400000004000000040000000
-- 016:0000000000000000000000040000000400000044000000440000004400000044
-- 017:0444444444444444444444444444444444444444444444444444444444444444
-- 018:4444444444444444444444444444444444444444444444444444444444444444
-- 019:4400000044000000444000004440000044440000444400004444000044440000
-- 021:0044444400444444004444440444444404444444044440040444400404444404
-- 022:4444444444444444444444444444444444444444444444444444444444444444
-- 023:4400000044000000444000004440000044400000444000004400000040000000
-- 032:0000004400000044000000440000004400000004000000040000000000000000
-- 033:4440044444000044440000444440000444400004444000004400000000000004
-- 034:444444444444444444444444444444444444f4444444f4444444f44044440000
-- 035:44440000444400004440000044400000f4000000f00000000000000000000000
-- 037:0044440400444404000044040000004400000000000000000000000000000000
-- 038:4444444044444000444400004400000000000000000000000000000000000000
-- 049:0000000400000044000004440000044400000044000000000000000000000000
-- 050:4444000044400000440000004000000000000000000000000000000000000000
-- 064:000000000000000c000000cc000000c0000000c0000000c000000c0000000c00
-- 065:0ccc0000cc0ccc000000ccc00000c1cc0000c1110000c1110000c111000cc119
-- 066:000000000000000000000000c0000000ccc00000111cc0001111cc0011111cc0
-- 068:00000000000000000000000000000000000000000000000c0000ccce000ceeee
-- 069:0000000000000000000000000000000000000000cccccccceeeeeeeeeeeeeeee
-- 070:0000000000000000000000000000000000000000cccc0000eeeeccc0eeeeeeec
-- 072:000000000000000c000000c800000c880000c8880000c88c0000c88c0000c88c
-- 073:00000000ccccccccffffffff8fffffffcccccccc000000000000000000000000
-- 074:00000000cc00000088c00000888c0000c888c0000c88c0000c88c0000c88c000
-- 080:00000c0000000c000000cc000000c00000cc00000cc000000c0000000c000000
-- 081:000c1111000c1119000c1191000c111100c1111100c1111100c111110cc11111
-- 082:911111cc1911111c111111111119111111919111191111111191111111111999
-- 083:00000000c0000000cc0000001cc0000011cc0000111cccc0111111c011111c00
-- 084:000cccce000cdddc000cdddd000cdddd000cdddd000cdddd000cdddd000cdddd
-- 085:eeeeeeeeccccccccdddddddddddddddddddddddddddddddddddddddddddddddd
-- 086:eeeeccccccccdddcdddddddcdddddddddddddddddddddddddddddddcdddddddc
-- 087:0000000000000000ccc00000dddcc000dddddc00cccddc0000cddc000cdddc00
-- 088:00cc88880c8888880c888888cc888888c8888888c8888888c8888888c8888888
-- 089:cc00000c88ccccc8888888888888888888888888888888888888888888888888
-- 090:c888c00088888c00888888c0888888c0888888cc8888888c8888888c88888888
-- 091:0000000c000000cc00000c8c0000c88c000c888c00c888c0cc888c008888c000
-- 096:0c0000000cc0000000c00000000c0000000c00000ccccc0000c222c0000c222c
-- 097:0c111111cc1111110cc11111000c1111000cc11100000c11000000c10000000c
-- 098:11119199111111191111119111111111111111111111111c111111ccc1111cc0
-- 099:111cc000111c000011c000001c000000c0000000000000000000000000000000
-- 100:0000cddd0000cddd0000cddd0000cddd00000cdd00000cdd000000cd0000000c
-- 101:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 102:dddddddcddddddddddddddddddddddccdddddc00dddddc00ddddc000dddc0000
-- 103:cdddc000dddc0000dcc00000c000000000000000000000000000000000000000
-- 104:c8888888c8888888c8888888c8888888c8888888c8888888c88888880cc88888
-- 105:8888888888888888888888888888888888888888888888888888888888888888
-- 106:88888888888888888888888888888888888888888888888c8888888c88888cc0
-- 107:888c000088c000008c0000008c000000c0000000c00000000000000000000000
-- 112:0000cccc00000000000000000000000000000000000000000000000000000000
-- 113:c000000000000000000000000000000000000000000000000000000000000000
-- 114:cc111c0000ccc000000c00000000000000000000000000000000000000000000
-- 117:ccdddddd0ccccccc000000000000000000000000000000000000000000000000
-- 118:dcc00000c0000000000000000000000000000000000000000000000000000000
-- 120:000ccccc00000000000000000000000000000000000000000000000000000000
-- 121:88888888cccccccc000000000000000000000000000000000000000000000000
-- 122:8cccc000c0000000000000000000000000000000000000000000000000000000
-- 128:00000000000000000000000000000000000000000000000c0000ccce000ceeee
-- 129:0000000000000000000000000000000000000000cccccccceeeeeeeeeeeeeeee
-- 130:0000000000000000000000000000000000000000cccc0000eeeeccc0eeeeeeec
-- 132:000e00000000e00000000e0000000e000000e000000e0000000e00000000e000
-- 144:000cccce00ccdddc00ccdddd0cccdddd0c0cddddcc0cddddc00cddddc00cdddd
-- 145:eeeeeeeeccccccccdddddddddddddddddddddddddddddddddddddddddddddddd
-- 146:eeeeccccccccdddcdddddddcdddddddddddddddddddddddddddddddcdddddddc
-- 147:0000000000000000ccc00000dddcc000dddddc00cccddc0000cddc000cdddc00
-- 160:cc00cddd0c00cddd0cc0cddd00c0cddd00c00cdd00c00cdd00c000cd000c000c
-- 161:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 162:dddddddcddddddddddddddddddddddccdddddc00dddddc00ddddc000dddc0000
-- 163:cdddc000dddc0000dcc00000c000000000000000000000000000000000000000
-- 176:000cc0000000cc0000000c000000cccc00000c22000000c20000000c00000000
-- 177:ccdddddd0ccccccc0000000000000000c00000002c000000ccc0000000000000
-- 178:dcc00000c0000000000000000000000000000000000000000000000000000000
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

-- <PALETTE1>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE1>

-- <PALETTE2>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE2>
--#endregion
