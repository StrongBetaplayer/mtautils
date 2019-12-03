

Vips = {}

    local Elements = false
    local VipData  = 'vip'
    local VipRank  = 1



    function GetVIPTable(table, resource)


        for i,P in ipairs(table) do 
            

            if (P:getData(VipData) == VipRank) then 
                

                if not Vips[P] then 
                
                Vips[P] = {P:getName(), P} -- {Oyuncu ismi, Oyuncu datası (thePlayer gibi..)} 
                end
                
            end


            if (next(table,i) == nil) and #Vips == 0 then 
                

                outputServerLog('\n VIPLOTTERY      Sunucuda vip bulunamadı. \n\n')
                resource:stop()
            
            elseif next(table,i) == nil then 


            return true
            end
        end
    end



        --[[ 
            
            fonksiyon addVIP()
            
            Bu fonksiyonu bir admin manuel olarak vip tablosunu yinelemek isterse kullanırsın; addCommandHandler'a ekleyip exportlaman yeterli.

        ]]--

        function refreshTable()

            Elements = getElementsByType('player')

                if (GetVIPTable(Elements, getThisResource()))

                return true
                end

        end


        --[[  
            
            fonksiyon addVIP()

            Bunu her sunucuya vip eklendiğinde; (kullanıcı vipse diyelim ve bu script başlatıldıktan 10 saat sonra giriş yaptı sunucuya; o zaman giriş paneline-
            exportlayarak eklersin böylelikle fazladan cpu yemeden (tekrar for çalıştırmadan Vips tablosunda ki yerini alır.)
            aynı zamanda bir oyuncuya vip verdiğinde de tetiklenmesi gerek;

        ]]--

        function addVIP(Player)
            
            if not Vips[Player] then 
            
            Vips[Player] = {Player:getName(), Player} -- {Oyuncu ismi, Oyuncu datası (thePlayer gibi..)} 
            return true
            end
        end


        --[[ 
            
            fonksiyon removeVIP()
            
            Kısaca addVIP'ın tersi, bir oyuncudan VIP alındığında, VIP süresi bittiğinde tetiklenmesi gereken fonksiyon;

        ]]--

        function removeVIP(Player)
            
            if Vips[Player] then 
            
            Vips[Player] = nil 
            return true
            end
        end


        --[[ 
            
            fonksiyon returnRandomVIP()
            
            Bu Fonksiyon da istediğin rastgele seviye 1 bir vip'in verisini sana döndürür exportlayıp kullanabilirsin;

        ]]--

        function returnRandomVIP()
        
            if #Vips > 1 then 
                
            return Vips[math.floor(math.random(1,#Vips))]
            end

        return false 
        end



    addEventHandler('onResourceStart', resourceRoot, function(res) 

        if res.name == 'viplottery' then 
            
            
            Elements = getElementsByType('player')

                GetVIPTable(Elements, res)

        end
    end)
