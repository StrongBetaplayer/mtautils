

local PINGLIMIT = 350
local SHADER    = DxShader(GradientFX)
local PINGED    = false


    if SHADER then 


            Timer(


                    function()
                        

                        if localPlayer.ping > PINGLIMIT then 
                            
                            
                            t('awaitscreen.open', root)
                            
                            PINGED = true;

                        else 

                            if PINGED then 
                                

                                t('awaitscreen.close', root)
                                PINGED = false;

                            end

                        end
                    
                    end

            ,0,0)

    end

    addEventHandler("onClientPlayerQuit", root, 
    

        function()
            
            t('awaitscreen.close', root)
    
        end
    
    )
