

    local screen  = Vector2(GuiElement.getScreenSize())
    local texture = false
    local show    = false
    local alpha   = 0
    local r       = 0
    local 
    
        table = { 
            
            "fire",
            "aim_weapon",
            "next_weapon",
            "previous_weapon",
            "forwards",
            "backwards",
            "left",
            "right",
            "zoom_in",
            "zoom_out",
            "change_camera",
            "jump",
            "sprint",
            "look_behind",
            "crouch",
            "action",
            "walk",
            "conversation_yes",
            "conversation_no",
            "group_control_forwards",
            "group_control_back", 
            "enter_exit",
            "vehicle_fire",
            "vehicle_secondary_fire",
            "vehicle_left",
            "vehicle_right",
            "steer_forward",
            "steer_back",
            "accelerate",
            "brake_reverse",
            "radio_next",
            "radio_previous",
            "radio_user_track_skip",
            "horn",
            "sub_mission",
            "handbrake",
            "vehicle_look_left",
            "vehicle_look_right",
            "vehicle_look_behind",
            "vehicle_mouse_look",
            "special_control_left",
            "special_control_right",
            "special_control_down",
            "special_control_up" 
        }

    local function loader_render()
    
        r = (r or 1) + 3

        if show then

            alpha   = math.min(alpha + 5, 255)

        else

            alpha = math.max(alpha - 5, 0)
            
            if alpha == 0 then 
                
                if localPlayer:getOccupiedVehicle() then 
                    setAnalogControlState('brake_reverse', 0)
                end

                removeEventHandler('onClientRender', root, loader_render)
            end
        end


        dxDrawImage(screen.x/2 - fit(12.5),screen.y - fit(60),fit(25),fit(25),texture,r,0,0,tocolor(215,215,215,alpha))
        

        if localPlayer:getOccupiedVehicle() then 

            
            speed = localPlayer:getOccupiedVehicle():getVelocity()
                
            actualspeed = math.sqrt(speed.x^2 + speed.y^2 + speed.z^2) * 50 
            if actualspeed > 0 then 
                    

            setAnalogControlState('brake_reverse', 1)

            elseif actualspeed == 0 then 

                setAnalogControlState('brake_reverse', 0)
            end

        end
    end
    


    addListener('awaitscreen.open',function(name)
        
        
        if showChat(false) and showCursor(true) and not show then 

            texture = DxTexture("components/media/loader.texture.png","argb", false, "clamp")

            Camera.fade(false, 0.5)

           

            localPlayer:setAlpha(122.5)

            if localPlayer:getOccupiedVehicle() then 

                localPlayer:getOccupiedVehicle():setAlpha(122.5)

            end

            show = true;
        

            addEventHandler('onClientRender',root,loader_render)

        end
    end)


    addListener('awaitscreen.close', function(name)
        

        show = false;
        text = false;

        localPlayer:setAlpha(255)

        if localPlayer:getOccupiedVehicle() then 

            localPlayer:getOccupiedVehicle():setAlpha(255)

        end

        Camera.fade(true, 0.5)

        setAnalogControlState('brake_reverse', 0)

        showChat(true);
        showCursor(false);
    end)
        