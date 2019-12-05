

-------------------------------------
--Resource: Shader Blur Box        --
--Author: Ren712                   --
--Contact: knoblauch700@o2.pl      --
-------------------------------------

boxTable = { shaders = {}, inputBox = {} , outputBox = {} , thisBox = 0 , isInNrChanged = false,
				isInValChanged = false, isStarted = false, maxBox = 20 }
funcTable = {}

----------------------------------------------------------------------------------------------------------------------------
-- editable variables
----------------------------------------------------------------------------------------------------------------------------
local scx, scy = guiGetScreenSize()
				
shaderSettings = {
			blurFactor = 1.5,  -- Blur amount
			orderPriority = "-5.0",	-- The lower this number, the later the effect is applied
			screenSourceRes = {1.0,1.0}
				}

----------------------------------------------------------------------------------------------------------------------------
-- main functions
----------------------------------------------------------------------------------------------------------------------------
function funcTable.create(posX,posY,sizeX,sizeY,colorR,colorG,colorB,colorA,postGUI)
	local w = #boxTable.inputBox + 1
	if not boxTable.inputBox[w] then 
		boxTable.inputBox[w] = {}
	end
	boxTable.inputBox[w].enabled = true
	boxTable.inputBox[w].size = {sizeX,sizeY}
	boxTable.inputBox[w].pos = {posX,posY}
	boxTable.inputBox[w].color = {colorR,colorG,colorB,colorA}
	boxTable.inputBox[w].postGUI = postGUI
	boxTable.isInNrChanged = true
	outputDebugString('Created Box ID:'..w)
	return w
end

function funcTable.destroy(w)
	if boxTable.inputBox[w] then
		boxTable.inputBox[w].enabled = false
		boxTable.isInNrChanged = true
		outputDebugString('Destroyed Box ID: '..w)
		return true
	end
end

function funcTable.startShaders()
	if boxTable.isStarted then 
		return false 
	end
	boxTable.shaders.screenSource = dxCreateScreenSource( shaderSettings.screenSourceRes[1] * scx, shaderSettings.screenSourceRes[2] * scy )		
	boxTable.shaders.blurH = dxCreateShader( "components/shaders/fxBlurH.fx" )
	boxTable.shaders.blurV = dxCreateShader( "components/shaders/fxBlurV.fx" )
	return boxTable.shaders.screenSource and boxTable.shaders.blurH and boxTable.shaders.blurV and true
end

function funcTable.stopShaders()
	if not boxTable.isStarted then 
		return false 
	end
	RTPool.clear()
	boxTable.shaders.screenSource = not destroyElement( boxTable.shaders.screenSource )		
	boxTable.shaders.blurH = not destroyElement( boxTable.shaders.blurH ) 
	boxTable.shaders.blurV = not destroyElement( boxTable.shaders.blurV )
	return not boxTable.shaders.screenSource and not boxTable.shaders.blurH and not boxTable.shaders.blurV and true
end

----------------------------------------------------------------------------------------------------------------------------
-- creating and sorting a table of active boxes
----------------------------------------------------------------------------------------------------------------------------
local tempTable = nil
addEventHandler("onClientPreRender",root, function()
	if (#boxTable.inputBox == 0) then
		return 
	end
	if boxTable.isInNrChanged then 
		tempTable = removeEmptyEntry(boxTable.inputBox)
		boxTable.outputBox = sortedBoxOutput(tempTable)		
		boxTable.isInNrChanged = false
		return
	end
	if boxTable.isInValChanged then
		boxTable.outputBox = sortedBoxOutput(tempTable)
		boxTable.isInValChanged = false
	end
end
,true ,"low-1")

----------------------------------------------------------------------------------------------------------------------------
-- render active boxes
----------------------------------------------------------------------------------------------------------------------------
addEventHandler("onClientRender", root, function()
	if (#boxTable.outputBox == 0) or not boxTable.isStarted then
		return 
	end 
	RTPool.frameStart()	
	dxUpdateScreenSource( boxTable.shaders.screenSource, true )
	local currentBox = boxTable.shaders.screenSource
	currentBox = applyBlurH( currentBox, scx, scy, shaderSettings.blurFactor )
	currentBox = applyBlurV( currentBox, scx, scy, shaderSettings.blurFactor )
	dxSetRenderTarget()
	boxTable.thisBox = 0
	local dix, diy = shaderSettings.screenSourceRes[1], shaderSettings.screenSourceRes[2]
	for index,this in ipairs(boxTable.outputBox) do
		if this.enabled and boxTable.thisBox < boxTable.maxBox and currentBox then
			dxDrawImageSection ( this.pos[1], this.pos[2], this.size[1], this.size[2], dix * this.pos[1], 
				diy * this.pos[2], dix * this.size[1], diy * this.size[2], currentBox, 0, 0, 0, tocolor(this.color[1],this.color[2],
				this.color[3],this.color[4]), this.postGUI )
			boxTable.thisBox = boxTable.thisBox + 1	
		end
	end
end
,true ,"low" .. shaderSettings.orderPriority )

----------------------------------------------------------------------------------------------------------------------------
-- Apply the different stages
----------------------------------------------------------------------------------------------------------------------------
function applyBlurH( Src, propX, propY, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx,my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( boxTable.shaders.blurH, "TEX0", Src )
	dxSetShaderValue( boxTable.shaders.blurH, "TexSize", propX, propY )
	dxSetShaderValue( boxTable.shaders.blurH, "gBlurFac", blur )
	dxDrawImage( 0, 0, mx, my, boxTable.shaders.blurH )
	return newRT
end

function applyBlurV( Src, propX, propY, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx,my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( boxTable.shaders.blurV, "TEX0", Src )
	dxSetShaderValue( boxTable.shaders.blurV, "TexSize", propX, propY )
	dxSetShaderValue( boxTable.shaders.blurV, "gBlurFac", blur )
	dxDrawImage( 0, 0, mx, my, boxTable.shaders.blurV )
	return newRT
end

----------------------------------------------------------------------------------------------------------------------------
-- Pool of render targets
----------------------------------------------------------------------------------------------------------------------------
RTPool = {}
RTPool.list = {}

function RTPool.frameStart()
	for rt,info in pairs(RTPool.list) do
		info.bInUse = false
	end
end

function RTPool.GetUnused( sx, sy )
	-- Find unused existing
	for rt,info in pairs(RTPool.list) do
		if not info.bInUse and info.sx == sx and info.sy == sy then
			info.bInUse = true
			return rt
		end
	end
	-- Add new
	outputDebugString( "creating new RT " .. tostring(sx) .. " x " .. tostring(sy) )
	local rt = dxCreateRenderTarget( sx, sy )
	if rt then
		RTPool.list[rt] = { bInUse = true, sx = sx, sy = sy }
	end
	return rt
end

function RTPool.clear()
	for rt,info in pairs(RTPool.list) do
		destroyElement(rt)
	end
	RTPool.list = {}
end

----------------------------------------------------------------------------------------------------------------------------
-- onClientResource: Start/Stop 
----------------------------------------------------------------------------------------------------------------------------
addEventHandler("onClientResourceStart", resourceRoot, function()
	if not isMTAUpToDate() then 
		outputChatBox( 'Blur_box: The resource is not compatible with this client version!', 255, 0, 0 )
		return
	end
	boxTable.isStarted = funcTable.startShaders()
	if not boxTable.isStarted then
		funcTable.stopShaders()
		outputChatBox( 'Blur_box: Could not start the shader resources', 255, 0, 0 )
	end

	root:setData('library:blur_box',true,true)
end
)

addEventHandler("onClientResourceStop", resourceRoot, function()

	if boxTable.isStarted then
		funcTable.stopShaders()
		root:setData('library:blur_box',false,true)
	end
end
)

function createBlurBox(posX,posY,sizeX,sizeY,colorR,colorG,colorB,colorA,postGUI)
	local reqParam = {posX,posY,sizeX,sizeY,colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param~=nil and (type(param) == "number")
	end
	if not isThisValid or (#reqParam ~= 8 ) or (countParam ~= 8) then 
		return false 
	end
	if (type(postGUI) ~= "boolean") then
		postGUI = false
	end
	local SHPelementID = funcTable.create(posX,posY,sizeX,sizeY,colorR,colorG,colorB,colorA,postGUI)
	return createElement("SHBlurBox",tostring(SHPelementID))
end

function destroyBlurBox(w)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	if type(SHPelementID) == "number" then
		return destroyElement(w) and funcTable.destroy(SHPelementID)
	else
		return false
	end
end

function setBlurBoxPosition(w,posX,posY)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	local reqParam = {SHPelementID,posX,posY}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if boxTable.inputBox[SHPelementID] and isThisValid  and (countParam == 3) then
		boxTable.inputBox[SHPelementID].pos = {posX,posY}
		boxTable.isInValChanged = true
		return true
	else
		return false
	end
end

function setBlurBoxColor(w,colorR,colorG,colorB,colorA)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	local reqParam = {SHPelementID,colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if boxTable.inputBox[SHPelementID] and isThisValid  and (countParam == 5)  then
		boxTable.inputBox[SHPelementID].color = {colorR,colorG,colorB,colorA}
		boxTable.isInValChanged = true
		return true
	else
		return false
	end
end

function setBlurBoxSize(w,sizeX,sizeY)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	if boxTable.inputBox[SHPelementID] and (type(sizeX) == "number") and (type(sizeY) == "number") then 
		boxTable.inputBox[SHPelementID].size = {sizeX,sizeY}
		boxTable.isInValChanged = true
		return true
	else
		return false
	end
end

function setBlurBoxEnabled(w,isEnabled)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	if boxTable.inputBox[SHPelementID] and (type(isEnabled) == "boolean") then 
		boxTable.inputBox[SHPelementID].enabled = isEnabled
		boxTable.isInNrChanged = true
		return true
	else
		return false
	end
end

function setBlurIntensity(blurFactor)
	if boxTable.isStarted and (type(blurFactor) == "number") then 
		shaderSettings.blurFactor = blurFactor
		return true
	else
		return false
	end
end

function setScreenResolutionMultiplier(ssx,ssy)
	if boxTable.isStarted and (type(ssx) == "number") and (type(ssx) == "number") then
		if (ssx<=1 and ssx>0) and (ssy<=1 and ssy>0) then
			shaderSettings.screenSourceRes = {ssx,ssy}
			boxTable.isStarted = not funcTable.stopShaders()
			boxTable.isStarted = funcTable.startShaders()
			return boxTable.isStarted
		else
			return false
		end
	else
		return false
	end
end
