--[[

Script made by: Benjannabis#2105

Feel free to change anything, if you want to share your modification you can make a pull request on github and I'll check it out :)

]]


-- _test_campfire_interact_base   -- REVISAR
--mp001_s_campfire01x_mp
-- ESTE OBJETO ESTARÍA BUENO PONERLO UN RATO CUANDO SE APAGA LA FOGATA, Y LUEGO PASA A COMPLETAMENTE APAGADA


--[[[[[ CONFIG ]]

local Config = {}
Config.Tent = {}
Config.Tent.DistanceToInteract = 9.0 -- In Units
Config.Tent.DistanceToSleepInBed = 1.5 -- In Units


local Tent={}
local Campfire={}

-- [[============| FUNCTIONS AREA |=========]] --

function play_sound_frontend(audioName, audioRef,b1,p2,b3,p4)
    PlaySound(audioName, audioRef, true,0,true,0)
end

function playAnim(dict,name)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), dict, name, 8.0, 8.0, 2000, 0, 0, true, 0, false, 0, false)  
end


function IsPlayerNearEntityWithDistance(entity,distance)
    playerPed = PlayerPedId()
    playerPedCoords = GetEntityCoords(playerPed)
    entityCoords = GetEntityCoords(entity)
    local dist = GetDistanceBetweenCoords(playerPedCoords,entityCoords,true)

    if dist < distance then
        return true
    else
        return false
    end
end

function addBlipForCoords(blipname,bliphash,coords)
    if bliphash==1754365229 then
        Campfire.Blip = Citizen.InvokeNative(0x554D9D53F696D002,1664425300, coords[1], coords[2], coords[3]) 
        SetBlipSprite(Campfire.Blip,bliphash,true)
        SetBlipScale(Campfire.Blip,0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, Campfire.Blip, blipname)
    else
        Tent.Blip = Citizen.InvokeNative(0x554D9D53F696D002,1664425300, coords[1], coords[2], coords[3]) 
        SetBlipSprite(Tent.Blip,bliphash,true)
        SetBlipScale(Tent.Blip,0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, Tent.Blip, blipname)
    end
   
end

-- Check if two tables are equals
function equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end


-- [[============| VARIABLES THAT I USE |=========]] --



-- player Handling
local playerPed = nil
local playerCoords = nil
local playerHeading = nil
local isPlayerNearTent = nil
local isPedBuildingTent = nil
local tentroll = 0

-- Tent Handling
-- Here you have all the variables I used to handle what happens with the Tent
Tent.isCreated=false
Tent.isFinished=false
Tent.isClosed=false
Tent.Blip=nil
Tent.Prop=nil
Tent.Pos = nil
Tent.PosHeading=nil
Tent.BedPos=nil
Tent.isBedCreated=false

--change it to config
Tent.RequiredItems = { ["wood"]=5, ["leather"]=3 }
Tent.ActualItems = { ["wood"]=0, ["leather"]=0 }




-- Campfire handling
-- Here you have all the variables I used to handle what happens with the campfire
Campfire.isCreated=false
Campfire.isFinished=false
Campfire.isOff=false
Campfire.Blip=nil
Campfire.Prop=nil
Campfire.Pos = nil
Campfire.PosHeading=nil


--change it to config
Campfire.RequiredItems = { ["wood"]=5, ["rock"]=5 }
Campfire.ActualItems = { ["wood"]=0, ["rock"]=0 }



--[[ ========== ]]
--[[  THE CODE  ]]
--[[ ========== ]]


-- This thread checks every ms the playerCoords, TentPos, and other stuff..
-- You can set a longer time to check these things, but i don't know if it break something
Citizen.CreateThread(function() 
	while true do
	Citizen.Wait(0)

		playerPed = PlayerPedId()
		playerCoords = GetEntityCoords(playerPed)
		playerHeading = GetEntityHeading(playerPed)

		if Tent.Prop then
			isPlayerNearTent = IsPlayerNearEntityWithDistance(Tent.Prop,Config.Tent.DistanceToInteract)

			Tent.Pos=GetEntityCoords(Tent.Prop)
			Tent.PosHeading=GetEntityHeading(Tent.Prop)
		end

		if Campfire.Prop then
			Campfire.Pos=GetEntityCoords(Campfire.Prop)
			Campfire.PosHeading=GetEntityHeading(Campfire.Prop)
		end
	end
end)





-- Handles the menu, all the interactions with the Tent
Citizen.CreateThread(function() 

WarMenu.CreateMenu('Tent', 'Tienda de Campaña')

    while true do
        Citizen.Wait(0)

      
        if isPedBuildingTent then
                playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
                Citizen.Wait(1400)
        end


        if isPlayerNearTent then
            if IsControlPressed(0, 0x760A9C6F) and not IsControlPressed(0,0x8FFC75D6) then -- Open Menu if Player hit G near the Tent, but it wont open if SHIFT+G is pressed (bc_sitchair)
                if not WarMenu.IsMenuOpened('Tent') then
                     WarMenu.OpenMenu('Tent')
                end
            end


            if WarMenu.IsMenuOpened('Tent') then -- If the TentMenu is Opened

                    if Tent.isFinished then 

                    	-- It will create the Tent Blip only if you finish the Tent Crafting.
                    	if not Tent.Blip then
			                Citizen.Wait(500)
			                addBlipForCoords("My Tent",GetHashKey("BLIP_CAMP_TENT"),vector3(Tent.Pos["x"],Tent.Pos["y"],Tent.Pos["z"]))
			            end

                            if Tent.isClosed then
                                    if WarMenu.Button('Abrir tienda ') then
                                            DeleteObject(Tent.Prop)
                                            play_sound_frontend("INFO_HIDE", "Ledger_Sounds", true,0,true,0)
                                            Tent.Prop = CreateObject(GetHashKey("S_TENT_MAROPEN01X"), Tent.Pos.x, Tent.Pos.y, Tent.Pos.z, true, false, true)    
                                            SetEntityAsMissionEntity(Tent.Prop)
                                            SetEntityHeading(Tent.Prop, Tent.PosHeading)
                                            PlaceObjectOnGroundProperly(Tent.Prop)
                                            Tent.isClosed=false
                                    end -- Open Tent Button
                            else -- Close Tent Button
                                    if WarMenu.Button('Cerrar tienda') then 
                                            DeleteObject(Tent.Prop)
                                            play_sound_frontend("INFO_HIDE", "Ledger_Sounds", true,0,true,0)
                                            Tent.Prop = CreateObject(GetHashKey("S_TENT_MARCLOSED01X"), Tent.Pos.x, Tent.Pos.y, Tent.Pos.z, true, false, true)    
                                            SetEntityAsMissionEntity(Tent.Prop)
                                            SetEntityHeading(Tent.Prop, Tent.PosHeading)
                                            PlaceObjectOnGroundProperly(Tent.Prop)
                                            Tent.isClosed=true
                                    end
                            end

                    else -- If Tent is not finished

                            if WarMenu.Button('Craftear Tienda') then

                            	--This basically populates the current items for crafting.
								-- You must edit this so it checks if you have the necessary items and remove them from your inventory

                               
                                if equals(Tent.ActualItems,Tent.RequiredItems,false) then 
                                	-- If both tables are equals, like if you have filled the actualItems with the requiredItems
                                	-- It completes the crafting
                                    playAnim("mech_pickup@saddle@putdown_saddle","putdown")
                                    Citizen.Wait(800)
                                    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0))
                                    tentroll = CreateObject(GetHashKey("S_CVAN_TENTROLL01"), x, y, z, true, false, true)    
                                    SetEntityAsMissionEntity(tentroll)
                                    SetEntityHeading(tentroll, playerHeading)
                                    PlaceObjectOnGroundProperly(tentroll)
                                    FreezeEntityPosition(tentroll,true)
                                    Citizen.Wait(2500)
                                    exports['progressBars']:startUI(7000, "Creando tienda")
                                    for i=1,5 do
                                        playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
                                        Citizen.Wait(1500)
                                    end
                                     DeleteObject(Tent.Prop)
                                     DeleteObject(tentroll)
                                   local prop = CreateObject(GetHashKey("S_TENT_MAROPEN01X"), Tent.Pos, true, false, true)  
                                   SetEntityAsMissionEntity(prop)
                                   SetEntityHeading(prop, Tent.PosHeading)
                                   PlaceObjectOnGroundProperly(prop)
                                    Tent.Prop=prop
                                    Tent.isFinished=true
                                else
                                    TriggerEvent("redemrp_notification:start", "Necesitas 5 de madera y 5 piedras" , 2, "warning")
                                end 


                                 for itemR,valorR in pairs(Tent.RequiredItems) do
                                    for itemA,valorA in pairs(Tent.ActualItems) do
                                        if itemA == itemR then
                                            Tent.ActualItems[itemA] = valorR
                                        end
                                    end
                                end



                            end--end Crafting Tent

                    end

                    -- Build the campfire is here because regardless of whether you crafted the tent, it will let you to craft the campfire.
                    -- And only appears if you dont have the campfire created.
                    -- That means if you create the campfire, the craft option will no longer appear
                    if not Campfire.isCreated then

                        if WarMenu.Button('Fabricar Fogata') then
                        	-- Here I get the front coords of the player, and I check if there is some of the TentItems nearby an specific radius.
                        	-- If there is an entity, that means that the player is trying to build the campfire inside or very near the tent
                        	-- So the idea is to block the crafting if that happens
                        	-- You can see the img to understand better what is happening (Paint is the best lmao) https://i.imgur.com/PCZ2c7T.png
                        	-- It is really necessary? I dont know. Can it be done in a better way? I think so
                            local frontPedX,frontPedY,frontPedZ = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0,2.5, 0.0,0.0))
                            local tentEntity = (GetClosestObjectOfType(frontPedX,frontPedY,frontPedZ, 2.5, GetHashKey("S_TENT_MAROPEN01X"), false, false, false))
                            local tentClosedEntity = (GetClosestObjectOfType(frontPedX,frontPedY,frontPedZ, 2.5, GetHashKey("S_TENT_MARCLOSED01X"), false, false, false))
                            local tentNotFinishedEntity = (GetClosestObjectOfType(frontPedX,frontPedY,frontPedZ, 2.5, GetHashKey("S_TENTCARAVAN01C"), false, false, false))

                                if not (GetEntityModel(tentEntity) == GetHashKey("S_TENT_MAROPEN01X"))
                                and not (GetEntityModel(tentClosedEntity) == GetHashKey("S_TENT_MARCLOSED01X"))
                                and not (GetEntityModel(tentNotFinishedEntity) == GetHashKey("S_TENTCARAVAN01C"))
                                then
                                    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.4, 0))
                                    Campfire.Prop = CreateObject(GetHashKey("P_CAMPFIRE_WIN2_01X"), x, y, z-2, true, false, true)   
                                    SetEntityAsMissionEntity(Campfire.Prop)
                                    SetEntityHeading(Campfire.Prop, playerHeading)
                                        for i=1,1 do
                                            playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
                                            Citizen.Wait(1500)
                                        end
                                    local a=GetEntityCoords(Campfire.Prop)
                                    local b=(a.z+0.9)
                                        for i=(a.z+0.7),b,0.01 do
                                            SetEntityCoords(Campfire.Prop,a.x,a.y,i,false,false,false,false)
                                            Citizen.Wait(45)
                                        end
                                    PlaceObjectOnGroundProperly(Campfire.Prop)
                                    Campfire.isCreated = true
                                    Campfire.isOff=true
                                    Citizen.Wait(4000)
                                else -- If one of those entities is found, it will warn the player
                                    TriggerEvent("redemrp_notification:start", "No puedes hacer una fogata cerca de la tienda" , 2, "warning")
                                end
                        end -- End Fabricar Fogata
                    else

                        if not Campfire.isFinished then -- If the camp is not finished it wil let you to craft the campfire

                             if WarMenu.Button('Craftear Fogata') then
                               -- Same as before, it fill the actual items so it will let you craft the campfire
                               

                                if equals(Campfire.ActualItems,Campfire.RequiredItems,false) then -- If two tables are equals
                                    -- It creates the finished campfire
                                    exports['progressBars']:startUI(7000, "Creando fogata")
                                    for i=1,5 do
                                        playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
                                        Citizen.Wait(1500)
                                    end
                                    DeleteObject(Campfire.Prop)
                                    local prop = CreateObject(GetHashKey("P_CAMPFIRE01X_NOFIRE"), Campfire.Pos, true, false, true)  
                                    SetEntityAsMissionEntity(prop)
                                    SetEntityHeading(prop, Campfire.PosHeading)
                                    PlaceObjectOnGroundProperly(prop)
                                    Campfire.Prop=prop
                                    Campfire.isFinished=true
                                end   

                                 for itemR,valorR in pairs(Campfire.RequiredItems) do
                                    for itemA,valorA in pairs(Campfire.ActualItems) do
                                        if itemA == itemR then
                                            Campfire.ActualItems[itemA] = valorR
                                        end
                                    end
                                end
                            end--End of CreateCampfire button
                           
                        else -- If the campfire is finished, it means that you can turn it on or off
                            if Campfire.isOff then
                                    if WarMenu.Button('Endender Fogata') then
                                        DeleteObject(Campfire.Prop)
                                        play_sound_frontend("INFO_HIDE", "Ledger_Sounds", true,0,true,0)
                                        Campfire.Prop = CreateObject(GetHashKey("P_CAMPFIRE01X"), Campfire.Pos.x, Campfire.Pos.y, Campfire.Pos.z+2, true, false, true)    
                                        SetEntityAsMissionEntity(Campfire.Prop)
                                        SetEntityHeading(Campfire.Prop, Campfire.PosHeading)
                                        PlaceObjectOnGroundProperly(Campfire.Prop)
                                        Campfire.isOff=false
                                        Citizen.Wait(800)
                                    end
                            else
                                    if WarMenu.Button('Apagar Fogata') then
                                        DeleteObject(Campfire.Prop)
                                        play_sound_frontend("INFO_HIDE", "Ledger_Sounds", true,0,true,0)
                                        Campfire.Prop = CreateObject(GetHashKey("P_CAMPFIRE01X_NOFIRE"), Campfire.Pos.x, Campfire.Pos.y, Campfire.Pos.z+2, true, false, true)    
                                        SetEntityAsMissionEntity(Campfire.Prop)
                                        SetEntityHeading(Campfire.Prop, Campfire.PosHeading)
                                        PlaceObjectOnGroundProperly(Campfire.Prop)
                                        Campfire.isOff=true
                                        Citizen.Wait(800)
                                    end
                            end
                        end
                    end

                

                    -- Bed Handling
                if Tent.BedProp and Tent.isBedCreated then
                    
                        if Tent.IsPedSleepingOnBed then
                            if WarMenu.Button('Levantarse') then 
                                ClearPedTasks(playerPed)
                                Tent.IsPedSleepingOnBed = false
                            end
                        else
                                if WarMenu.Button('Acostarse') then 
                                    if IsPlayerNearEntityWithDistance(Tent.BedProp,Config.Tent.DistanceToSleepInBed) then
                                        local BedX,BedY,BedZ = table.unpack(GetOffsetFromEntityInWorldCoords(Tent.BedProp, 0,0, 0.0,0.0))
                                         Citizen.InvokeNative(0x4D1F61FC34AF3CD1, playerPed, GetHashKey("WORLD_HUMAN_SLEEP_GROUND_ARM"), BedX,BedY,BedZ+0.3,Tent.BedPosHeading-180, 0, true)
                                         Citizen.Wait(1)
                                        Tent.IsPedSleepingOnBed = true
                                    else
                                        TriggerEvent("redemrp_notification:start", "Debes estar cerca de la cama" , 2, "warning")
                                    end
                                end


                        end
                        
                else -- If the bed is not created and not exists
                    if WarMenu.Button('Fabricar Cama') then 
	                    TaskGotoEntityOffset(playerPed, Tent.Prop, 4000,0.0,3.0,1.0,1500)
						local BedX,BedY,BedZ = table.unpack(GetOffsetFromEntityInWorldCoords(Tent.Prop, 0.3, 1.0, 0.0))
						playAnim("mech_pickup@saddle@putdown_saddle","putdown")
						Citizen.Wait(800)
						local bed = CreateObject(GetHashKey("P_AMBBLANKETROLL01X"), BedX,BedY,BedZ, true, false, true)  
						SetEntityAsMissionEntity(bed)
						SetEntityHeading(bed, Tent.PosHeading)
						PlaceObjectOnGroundProperly(bed)
						DeleteObject(bed)
	                    local BedX,BedY,BedZ = table.unpack(GetOffsetFromEntityInWorldCoords(Tent.Prop, --[[-0.8]]0, 0.86, 0.0))
	                    local bed = CreateObject(GetHashKey("s_bedrollfurlined01x"), BedX,BedY,BedZ, true, false, true)  
                        SetEntityAsMissionEntity(bed)
                        SetEntityHeading(bed, Tent.PosHeading+95)
                        PlaceObjectOnGroundProperly(bed)
                        Tent.BedProp=bed
                        Tent.BedPos=vector3(BedX,BedY,BedZ)
                        Tent.BedPosHeading=GetEntityHeading(Tent.BedProp)
                        Tent.isBedCreated=true
                	end

            	end

         		WarMenu.Display()
            end
        else

	        if WarMenu.IsMenuOpened('Tent') then  -- If the player is far from the tent, and the menu is opened, it will close it
	            WarMenu.CloseMenu()  
	        end

        end -- end of If player is near tent
               
       
    end-- end of while true
end)-- end of citizen thread


--[[ ======== ]]
--[[ COMMANDS ]]
--[[ ======== ]]



-- Command to instantly delete the tent and the bed inside
RegisterCommand('deltienda', function(source, args, rawCommand)
   
    if Tent.Prop~=nil then
        RemoveBlip(Tent.Blip)
        DeleteObject(Tent.Prop)
        DeleteObject(Tent.BedProp)
        Tent={}
        Citizen.Wait(500)
    end
end)




-- Command that creates the tent
RegisterCommand('tienda', function(source, args, rawCommand)

    if Tent.Prop~=nil then --  If tent already exists, it deletes it
        RemoveBlip(Tent.Blip)
        DeleteObject(Tent.Prop)
        DeleteObject(Tent.BedProp)
        Tent = {}
        Citizen.Wait(500)
    end
    
     exports['progressBars']:startUI(18000, "Armando estructura")
     isPedBuildingTent = true
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 4.4, 0))
    Tent.Prop = CreateObject(GetHashKey("S_TENTCARAVAN01C"), x, y, z, true, false, true) 
    SetEntityAsMissionEntity(Tent.Prop)
    SetEntityHeading(Tent.Prop, playerHeading)
    
    
    local a=GetEntityCoords(Tent.Prop)
    local b=(a.z-1.3)
    for i=(a.z-4.2),b,0.01 do
        SetEntityCoords(Tent.Prop,a.x,a.y,i,false,false,false,false)
        Citizen.Wait(45)
    end

    PlaceObjectOnGroundProperly(Tent.Prop)
    Tent.isCreated = true
    isPedBuildingTent=false
    Citizen.Wait(4000)

end)

--Command that deletes the camppfire
RegisterCommand('delfogata', function(source, args, rawCommand)
   
    if Campfire.Prop~=nil then
        RemoveBlip(Campfire.Blip)
        DeleteObject(Campfire.Prop)
        Campfire={}
        Citizen.Wait(500)
    end
end)



