local MainAPP = class("MainAPP", cc.load("mvc").ViewBase)

function MainAPP:onCreate()
    local num --用来判断触摸精灵的确切位置

    local picUnits = {{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}}   --64个精灵的二维数组，是图片的外观和动作对象
    local trueUnits = {{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}}  --64个数字的二维数组，是图片的实质内容

    for i = 1, 8 do
        for j = 1, 8 do
            trueUnits[i][j] = math.random(1, 4)                 --初始化方块内容，1到4随机
        end
    end

    for i = 1, 8 do
        for j = 1, 8 do
            picUnits[i][j] = cc.Sprite:create("Chrome.png")  --图片初始化为一个80*80的图片
            picUnits[i][j]:setPosition(display.cx - 400 + i * 80, display.cy - 360 + j * 80)
            self:addChild(picUnits[i][j],10)
            if trueUnits[i][j] == 2 then    --根据图片实质内容数组，设定精灵对应的图片
                local texture = CCDirector:getInstance():getTextureCache():addImage("Edge.png")
                picUnits[i][j]:setTexture(texture)
            elseif trueUnits[i][j] == 3 then
                local texture = CCDirector:getInstance():getTextureCache():addImage("FireFox.png")                
                picUnits[i][j]:setTexture(texture)
            elseif trueUnits[i][j] == 4 then
                local texture = CCDirector:getInstance():getTextureCache():addImage("Safari.png")                
                picUnits[i][j]:setTexture(texture)
            end
        end
    end

    local xO, yO = picUnits[1][1]:getPosition()      --获取坐下方块坐标

    local function reDraw()
        for i = 1, 8 do
            for j = 1, 8 do
                if trueUnits[i][j] % 10 == 1 then    --根据图片实质内容数组，设定精灵对应的图片
                    local texture = CCDirector:getInstance():getTextureCache():addImage("Chrome.png")
                    picUnits[i][j]:setTexture(texture)
                elseif trueUnits[i][j] % 10 == 2 then
                    local texture = CCDirector:getInstance():getTextureCache():addImage("Edge.png")                
                    picUnits[i][j]:setTexture(texture)                
                elseif trueUnits[i][j] % 10 == 3 then
                    local texture = CCDirector:getInstance():getTextureCache():addImage("FireFox.png")            
                    picUnits[i][j]:setTexture(texture)
                elseif trueUnits[i][j] % 10 == 4 then
                    local texture = CCDirector:getInstance():getTextureCache():addImage("Safari.png")
                    picUnits[i][j]:setTexture(texture)
                end
            end
        end
    end

    local function picDown()            --方块掉落
        for i = 1, 8 do           --从左下角，向上，一列完了以后向右推
            local spaceStart = 0  --一列从下往上看第一个空格的位置
            for j = 1, 8 do
                if trueUnits[i][j] > 10 and spaceStart == 0 then  --如果没找到第一个空格而且发现了一个空格，就设置当前位置为第一个空格
                    spaceStart = j
                elseif trueUnits[i][j] < 10 and spaceStart ~= 0 then   --如果已经找到了第一个空格而且发现了一个非空格，就把第一个空格和这个非空格内容互换
                    trueUnits[i][j], trueUnits[i][spaceStart] = trueUnits[i][spaceStart], trueUnits[i][j]
                    spaceStart = spaceStart + 1        --空格标记点向上移一位
                end
            end
            if spaceStart ~= 0 then
                for j = spaceStart, 8 do                   --把剩下的空格位随即填满
                    trueUnits[i][j] = math.random(1, 4)
                end
            end
        end
    end

    local function picSlay()            --三消核心函数，用于判断哪些块应该被消除
        local sameFirstX, sameFirstY = 1, 8
        local slayOrNot = false            --判断本次是否有消除掉方块
        for i = 1, 8 do    --首先从左上角，向下查看，一列看完后向右一列
            local sameNumbers = 1  --记录有多少个相同块了
            for j = 8, 2, -1 do
                if trueUnits[i][j] % 10 == trueUnits[i][j - 1] % 10 then   --如果相邻两个块相同，就将记录数+1
                    if sameNumbers == 1 then
                        sameFirstX = i
                        sameFirstY = j      --记录初始相同块位置
                    end
                    sameNumbers = sameNumbers + 1
                else
                    if sameNumbers >= 3 then     --连续相同块结束，判断是否够3个并进行消除
                        for y = sameFirstY, j, -1 do
                            trueUnits[i][y] = trueUnits[i][y] + 10  --将实质数组内容数值+10标记为消除
                            slayOrNot = true
                        end
                    end
                    sameNumbers = 1  --归1
                end
            end
            if sameNumbers >= 3 then --一整列结束以后判断相同块数目是否够3
                for y = sameFirstY, 1, -1 do
                    trueUnits[i][y] = trueUnits[i][y] + 10
                    slayOrNot = true
                end
            end
            sameNumbers = 1
        end

        for j = 8, 1, -1 do    --此部分为先向右查看，一行结束后再向下推进一行
            local sameNumbers = 1
            for i = 1, 7 do
                if trueUnits[i][j] % 10 == trueUnits[i + 1][j] % 10 then
                    if sameNumbers == 1 then
                        sameFirstX = i
                        sameFirstY = j
                    end
                    sameNumbers = sameNumbers + 1
                else
                    if sameNumbers >= 3 then
                        for x = sameFirstX, i do
                            trueUnits[x][j] = trueUnits[x][j] + 10
                            slayOrNot = true
                        end
                    end
                    sameNumbers = 1
                end
            end
            if sameNumbers >= 3 then
                for x = sameFirstX, 8 do
                    trueUnits[x][j] = trueUnits[x][j] + 10
                    slayOrNot = true
                end
            end
            sameNumbers = 1
        end
        return slayOrNot
    end
    local slayTimes = 0
    local picTableTimes = 1

    repeat
        local continueSlay = picSlay()
        picDown()
        slayTimes = slayTimes + 1
            reDraw()
    until (continueSlay == false)

    local canOrNotTouch = true

    local function whitchTouch(touch, event)    --用于判断触摸的是哪一个方块的函数
        for i = 1, 8 do
            for j = 1, 8 do
                if cc.rectContainsPoint(picUnits[i][j]:getBoundingBox(), touch:getLocation()) then
                    return i * 10 + j    --返回的数值返回到num上，十位数是i，个位数是j
                end
            end
        end
        return 0
    end
    local oldPosX, oldPosY    --保存被触摸的块原本的位置坐标

    local function onTouchBegan(touch, event)   --开始触摸
        num = whitchTouch(touch, event) --获取触摸位置
        if num ~= 0 and canOrNotTouch then             --判断是否触摸到方块
            local j = num % 10
            local i = (num - j) / 10 --获取触摸方块坐标
            oldPosY = display.cy - 360 + j * 80
            oldPosX = display.cx - 400 + i * 80   --记录方块原始坐标
            picUnits[i][j]:runAction(cc.ScaleBy:create(0.05, 1.25))  --特效，方块被触摸会放大
            return true              --触摸到了方块
        end
        return false
    end
    local moveDirection = 11         --移动方向。十位数代表X轴，个位数代表Y轴。11为原点
    
    local function moveReturn(i, j, sec)  --移动返回函数
        if moveDirection == 21 then  --如果之前是向右移动
            moveDirection = 11       --移动方向记录复原
            picUnits[i][j]:runAction(cc.MoveBy:create(sec, cc.p(-80, 0)))     --被触摸的方块向左移动一格（返回，复原）
            picUnits[i + 1][j]:runAction(cc.MoveBy:create(sec, cc.p(80, 0)))  --到达位置方块向右移动一格
            if sec ~= 0 then
                trueUnits[i][j], trueUnits[i + 1][j] = trueUnits[i + 1][j], trueUnits[i][j]
            end
        elseif moveDirection == 01 then   --之前是向左移动情况
            moveDirection = 11
            picUnits[i][j]:runAction(cc.MoveBy:create(sec, cc.p(80, 0)))
            picUnits[i - 1][j]:runAction(cc.MoveBy:create(sec, cc.p(-80, 0)))
            if sec ~= 0 then
                trueUnits[i][j], trueUnits[i - 1][j] = trueUnits[i - 1][j], trueUnits[i][j]                            
            end
        elseif moveDirection == 12 then   --之前是向上移动情况
            moveDirection = 11
            picUnits[i][j]:runAction(cc.MoveBy:create(sec, cc.p(0, -80)))
            picUnits[i][j + 1]:runAction(cc.MoveBy:create(sec, cc.p(0, 80)))
            if sec ~= 0 then
                trueUnits[i][j], trueUnits[i][j + 1] = trueUnits[i][j + 1], trueUnits[i][j]
            end
        elseif moveDirection == 10 then   --之前是向下移动情况
            moveDirection = 11
            picUnits[i][j]:runAction(cc.MoveBy:create(sec, cc.p(0, 80)))
            picUnits[i][j - 1]:runAction(cc.MoveBy:create(sec, cc.p(0, -80)))
            if sec ~= 0 then
                trueUnits[i][j], trueUnits[i][j - 1] = trueUnits[i][j - 1], trueUnits[i][j]                            
            end
        end
    end

    local function onTouchMoved(touch, event) --正在移动
        if num ~= 0 and canOrNotTouch then      --之前确实触摸到了方块
            local j = num % 10
            local i = (num - j) / 10
            local movedX = touch:getLocation().x - oldPosX
            local movedY = touch:getLocation().y - oldPosY    --获取移动方向

            if i == 1 and movedX < 0 then   --防止超出边界
                movedX = 0
            elseif i == 8 and movedX > 0 then
                movedX = 0
            end
            if j == 1 and movedY < 0 then
                movedY = 0
            elseif j == 8 and movedY > 0 then
                movedY = 0
            end
            if moveDirection == 11 then    --如果之前并没有移动，在原位
                if movedX ^ 2 > movedY ^ 2 then   --横向移动趋势更大
                    if movedX > 40 then    --向右移动
                        moveDirection = 21                
                        picUnits[i][j]:runAction(cc.MoveBy:create(0.2, cc.p(80, 0)))        --被触摸方块向右移动
                        picUnits[i + 1][j]:runAction(cc.MoveBy:create(0.2, cc.p(-80, 0)))   --到达位置方块向左移动
                        trueUnits[i][j], trueUnits[i + 1][j] = trueUnits[i + 1][j], trueUnits[i][j]                        
                    elseif movedX < -40 then  --向左移动
                        moveDirection = 01
                        picUnits[i][j]:runAction(cc.MoveBy:create(0.2, cc.p(-80, 0)))
                        picUnits[i - 1][j]:runAction(cc.MoveBy:create(0.2, cc.p(80, 0)))                
                        trueUnits[i][j], trueUnits[i - 1][j] = trueUnits[i - 1][j], trueUnits[i][j]                        
                    end
                else                              --纵向移动趋势更大
                    if movedY > 40 then    --向上移动
                        moveDirection = 12                
                        picUnits[i][j]:runAction(cc.MoveBy:create(0.2, cc.p(0, 80)))
                        picUnits[i][j + 1]:runAction(cc.MoveBy:create(0.2, cc.p(0, -80)))
                        trueUnits[i][j], trueUnits[i][j + 1] = trueUnits[i][j + 1], trueUnits[i][j]                        
                    elseif movedY < -40 then  --向下移动
                        moveDirection = 10
                        picUnits[i][j]:runAction(cc.MoveBy:create(0.2, cc.p(0, -80)))
                        picUnits[i][j - 1]:runAction(cc.MoveBy:create(0.2, cc.p(0, 80)))
                        trueUnits[i][j], trueUnits[i][j - 1] = trueUnits[i][j - 1], trueUnits[i][j]                
                    end
                end
            else        --如果移动过程中返回原位
                if movedX < 40 and movedX > -40 and movedY < 40 and movedY > -40 then  --如果触摸位置处于原来位置范围内
                    moveReturn(i, j, 0.2)
                end
            end
        end
    end
    local trueOldUnits = {{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}}
    local function onTouchEnded(touch, event)    --触摸放开
        if num ~= 0 and canOrNotTouch then           --之前确实触摸到了方块
            local j = num % 10
            local i = (num - j) / 10
            local didSlay = picSlay()
            if not didSlay then             --表示这次移动没有造成消除
                picUnits[i][j]:runAction(cc.ScaleTo:create(0.2, 1))  --触摸开始时的放大操作还原到原本大小
                moveReturn(i, j, 0.2)       --之前的移动动作复原
            else                            --造成了消除
                canOrNotTouch = false

                picUnits[i][j]:runAction(cc.ScaleTo:create(0, 1))  --触摸开始时的放大操作还原到原本大小
                moveReturn(i, j, 0)
                reDraw()                    --此时需要将两个位置内容互换

                for x = 1, 8 do             --方块消除
                    for y = 1, 8 do
                        trueOldUnits[x][y] = trueUnits[x][y]
                        if trueUnits[x][y] > 10 then
                            picUnits[x][y]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4, 0), cc.ScaleTo:create(0, 1)))
                        end
                    end
                end

                picDown()

                performWithDelay(self,function()  
                    reDraw()
                end,0.4)  

                for x = 1, 8 do             --把方块上移，准备掉落
                    local yUpNum = 0
                    for y = 1, 8 do
                        if y + yUpNum <= 8 then
                            while trueOldUnits[x][y + yUpNum] >= 10 do
                                yUpNum = yUpNum + 1
                                for yUp = y, 8 do
                                    picUnits[x][yUp]:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.MoveBy:create(0, cc.p(0, 80))))
                                end
                                if y + yUpNum > 8 then
                                    break
                                end
                            end
                        end
                    end
                end

                for x = 1, 8 do           --方块下落
                    for y = 1, 8 do
                        local xAt = xO + (x - 1) * 80
                        local yAt = yO + (y - 1) * 80
                        picUnits[x][y]:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.MoveTo:create(0.4, cc.p(xAt, yAt))))
                    end
                end


            


                local scheduler = cc.Director:getInstance():getScheduler()  
                local schedulerID = nil  
                schedulerID = scheduler:scheduleScriptFunc(function()  
                    canOrNotTouch = false
                    didSlay = picSlay()    
                    if not didSlay then
                        performWithDelay(self,function()  
                            canOrNotTouch = true
                        end,0.1)                    --动画过程中禁止输入操作
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)   
                    else
                        for x = 1, 8 do             --方块消除
                            for y = 1, 8 do
                                trueOldUnits[x][y] = trueUnits[x][y]
                                if trueUnits[x][y] > 10 then
                                    picUnits[x][y]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4, 0), cc.ScaleTo:create(0, 1)))
                                end
                            end
                        end

                        picDown()
                        performWithDelay(self,function()  
                            reDraw()
                        end,0.4)  

                        for x = 1, 8 do             --把方块上移，准备掉落
                            local yUpNum = 0
                            for y = 1, 8 do
                                if y + yUpNum <= 8 then
                                    while trueOldUnits[x][y + yUpNum] >= 10 do
                                        yUpNum = yUpNum + 1
                                        for yUp = y, 8 do
                                            picUnits[x][yUp]:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.MoveBy:create(0, cc.p(0, 80))))
                                        end
                                        if y + yUpNum > 8 then
                                            break
                                        end
                                    end
                                end
                            end
                        end

                        for x = 1, 8 do           --方块下落
                            for y = 1, 8 do
                                local xAt = xO + (x - 1) * 80
                                local yAt = yO + (y - 1) * 80
                                picUnits[x][y]:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.MoveTo:create(0.4, cc.p(xAt, yAt))))
                            end
                        end
                    end
                end,0.8,false)   
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher() -- 得到事件派发器
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, picUnits[1][1]) -- 将监听器注册到派发器中

end

return MainAPP
