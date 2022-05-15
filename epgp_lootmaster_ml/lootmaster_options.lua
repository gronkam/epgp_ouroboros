local mod = LootMaster:NewModule("EPGPLootmaster_Options")

--local LootMasterML = false

function mod:OnEnable()
  local options = {
    name = "EPGPLootMaster гильдии InVaDeRs",
    type = "group",
    get = function(i) return LootMaster.db.profile[i[#i]] end,
    set = function(i, v) LootMaster.db.profile[i[#i]] = v end,
    args = {
        
        global = {
            order = 1,
            type = "group",
            hidden = function(info) return not LootMasterML end,
            name = "Общая конфигурация",
            
                args = {
                
                help = {
                    order = 0,
                    type = "description",
                    name = "EPGPLootMaster разработан для распределения лута по системе EP/GP. Данный аддон помогает быстро и без меньших ошибок распределить лут работающий в системе EP/GP.",
                },
                
                
                
                no_ml = {
                    order = 2,
                    type = "description",
                    hidden = function(info) return LootMasterML end,
                    name = "\r\n\r\n|cFFFF8080WARNING: Alot of settings have been hidden because the EPGPLootmaster 'ML' module has been disabled. Please enabled it from the addon configuration screen.|r",
                },
                
                config_group = {
                    order = 12,
                    type = "group",
                    guiInline = true,
                    hidden = function(info) return not LootMasterML end,
                    name = "General config",
                    args = {
                        
                        use_epgplootmaster = {
                            order = 2,
                            type = "select",
			                width = "double",
                            set = function(i, v) 
                                LootMaster.db.profile.use_epgplootmaster = v;
                                if v == 'enabled' then
                                    LootMasterML:EnableTracking();
                                elseif v == 'disabled' then
                                    LootMasterML:DisableTracking();
                                else
                                    LootMasterML.current_ml = nil;
                                    LootMasterML:GROUP_UPDATE();
                                end                               
                                
                            end,
                            name = "Использование EPGPLootmaster",
                            desc = "Включение EPGPLootmaster позволено или нет.",
                            values = {
                                ['enabled'] = 'Всегда использовать EPGPLootmaster',
                                ['disabled'] = 'Никогда не использовать EPGPLootmaster',
                                ['ask'] = 'Спрашивать каждый раз'
                            },
                        },
                        
                        loot_timeout = {
                            order = 14,
                            type = "select",
			                width = "double",
                            name = "Время распределения лута",
                            desc = "Устанавливает количество времени, отведенного игрокам для голосования.",
                            values = {
                                [0] = 'No timeout',
                                [10] = '10 секунд',
                                [15] = '15 секунд',
                                [20] = '20 секунд',
                                [30] = '30 секунд',
                                [40] = '40 секунд',
                                [50] = '50 секунд',
                                [60] = '1 минута',
                                [90] = '1 мин. 30 сек.',
                                [150] = '2 мин. 30 сек.',
                                [300] = '5 минут',
                            },
                        }, 
                        
                        --[[defaultMainspecGP = {
                            order = 15.1,
                            type = "input",                    
                            name = "Default mainspec GP",
                            desc = "Fill this field to override the GP value for mainspec loot.",
                            width = 'normal',
                            validate = function(data, value) if value=='' then return true end; if not strmatch(value, '^%s*%d+%s-%%?%s*$') then return false else return true end end,
                            set = function(i, v) 
                                
                                if v == '' or not v then
                                    v = ''
                                    LootMaster.db.profile.defaultMainspecGPPercentage = false;
                                    LootMaster.db.profile.defaultMainspecGPValue = nil;
                                else
                                    value, perc = strmatch(v, '^%s*(%d+)%s-(%%?)%s*$')
                                    LootMaster.db.profile.defaultMainspecGPPercentage = (perc~=nil and perc~='');
                                    LootMaster.db.profile.defaultMainspecGPValue = tonumber(value);
                                end                               
                                LootMaster.db.profile.defaultMainspecGP = v;
                            end,
                            usage = "\r\nEmpty: use normal GP value"..
                                    "\r\n50%: use 50% of normal GP value"..
                                    "\r\n25: all items are worth 25 GP"
                        },
                        
                        defaultMinorUpgradeGP = {
                            order = 15.2,
                            type = "input",                    
                            name = "Default minor upgrade GP",
                            desc = "Fill this field to override the GP value for minor upgrade mainspec loot.",
                            width = 'normal',
                            validate = function(data, value) if value=='' then return true end; if not strmatch(value, '^%s*%d+%s-%%?%s*$') then return false else return true end end,
                            set = function(i, v) 
                                
                                if v == '' or not v then
                                    v = ''
                                    LootMaster.db.profile.defaultMinorUpgradeGPPercentage = false;
                                    LootMaster.db.profile.defaultMinorUpgradeGPValue = nil;
                                else
                                    value, perc = strmatch(v, '^%s*(%d+)%s-(%%?)%s*$')
                                    LootMaster.db.profile.defaultMinorUpgradeGPPercentage = (perc~=nil and perc~='');
                                    LootMaster.db.profile.defaultMinorUpgradeGPValue = tonumber(value);
                                end                               
                                LootMaster.db.profile.defaultMinorUpgradeGP = v;
                            end,
                            usage = "\r\nEmpty: use normal GP value"..
                                    "\r\n50%: use 50% of normal GP value"..
                                    "\r\n25: all items are worth 25 GP"
                        },
                        
                        defaultOffspecGP = {
                            order = 15.3,
                            type = "input",                    
                            name = "Default offspec GP",
                            desc = "Fill this field to override the GP value for offspec loot.",
                            width = 'normal',
                            validate = function(data, value) if value=='' then return true end; if not strmatch(value, '^%s*%d+%s-%%?%s*$') then return false else return true end end,
                            set = function(i, v) 
                                
                                if v == '' or not v then
                                    v = ''
                                    LootMaster.db.profile.defaultOffspecGPPercentage = false;
                                    LootMaster.db.profile.defaultOffspecGPValue = nil;
                                else
                                    value, perc = strmatch(v, '^%s*(%d+)%s-(%%?)%s*$')
                                    LootMaster.db.profile.defaultOffspecGPPercentage = (perc~=nil and perc~='');
                                    LootMaster.db.profile.defaultOffspecGPValue = tonumber(value);
                                end                               
                                LootMaster.db.profile.defaultOffspecGP = v;
                            end,
                            usage = "\r\nEmpty: use normal GP value"..
                                    "\r\n50%: use 50% of normal GP value"..
                                    "\r\n25: all items are worth 25 GP"
                        },
                        
                        defaultGreedGP = {
                            order = 15.4,
                            type = "input",                    
                            name = "Default greed GP",
                            desc = "Fill this field to override the GP value for greed loot.",
                            width = 'normal',
                            validate = function(data, value) if value=='' then return true end; if not strmatch(value, '^%s*%d+%s-%%?%s*$') then return false else return true end end,
                            set = function(i, v) 
                                
                                if v == '' or not v then
                                    v = ''
                                    LootMaster.db.profile.defaultGreedGPPercentage = false;
                                    LootMaster.db.profile.defaultGreedGPValue = nil;
                                else
                                    value, perc = strmatch(v, '^%s*(%d+)%s-(%%?)%s*$')
                                    LootMaster.db.profile.defaultGreedGPPercentage = (perc~=nil and perc~='');
                                    LootMaster.db.profile.defaultGreedGPValue = tonumber(value);
                                end                               
                                LootMaster.db.profile.defaultGreedGP = v;
                            end,
                            usage = "\r\nEmpty: use normal GP value"..
                                    "\r\n50%: use 50% of normal GP value"..
                                    "\r\n25: all items are worth 25 GP"
                        },]]
                        
                        ignoreResponseCorrections = {
                            type = "toggle",
                            order = 17,
                            width = 'full',
                            name = "Принять только первое примечание к пункту.",
                            desc = "Обычно кандидаты могут послать многократные сообщения в пм за время лута босса, чтобы изменить выбор распределения лута. Например они сначала выбрали Первый спек, но позже решили изменить на Небольшое улучшение что бы добыча досталась более нуждающемуся. Если Вы поставите данную функцию, то только первый ответ будет посчитан.",
                        },
                        
                        allowCandidateNotes = {
                            type = "toggle",
                            order = 18,
                            width = 'full',
                            name = "Позволить кандидатам добавлять примечания к каждому пункту.",
                            desc = "Используйте данную функцию , если вы хотите, чтобы ваши кандидаты отправляли сообщения к вам. Примечание обнаруживается как символ на Вашем интерфейсе распределения добычи.Вы можете снять галочку, если это замедляет распределение лута.",
                        },
                        
                        filterEPGPLootmasterMessages = {
                            type = "toggle",
                            order = 19,
                            width = 'full',
                            name = "фильтровать пм сообщения лута игроков.",
                            desc = "У EPGPLootmaster есть хорошая система, которой могут пользоваться даже те у которых нет EPGPLootmaster. Они могут посылать пункты Основной спек/Небольшое улучшение/Второй спек. Это будет сделано, шепотом и посылает сообщение в рейд. Разрешите фильтрацию сообщений.",
                        },
                        
                        audioWarningOnSelection = {
                            type = "toggle",
                            order = 20,
                            width = 'full',
                            name = "Проигрывать аудио предупреждение о начале раздела лута.",
                            desc = "Будет играть слышимое предупреждение, когда выбор лута будет открыт и требует Вашего входа.",
                        },
                    }
                },
                
                buttons_group = {
                    order = 12.5,
                    type = "group",
                    guiInline = true,
                    hidden = function(info) return not LootMasterML end,
                    name = "Кнопки выбора",
                    args = {
                        
                        help = {
                            order = 0,
                            type = "description",
                            name = "Это позволяет Вам формировать кнопки выбора на пользовательских интерфейсах Ваших людей. Пожалуйста,убедитесь что кнопки выбора соответствуют значениям сортировки используемых ниже. Выбирайте количество кнопок,цвет, процент счисления.",
                        },
                        
                        buttonNum = {
                            type = "range",
                            width = 'full',
                            order = 1,
                            name = "Количество кнопок дележа лута:",
                            min = 1,
                            max = EPGPLM_MAX_BUTTONS,
                            step = 1,
                            desc = "Определите, сколько кнопок Вы хотите видеть при разделе лута. Вы должны будете формировать 1 минимальную кнопку и знать, что кнопка прохода будет всегда включенной.",
                        },
                        
                        
                        button1 = {
                            type = "input",
                            width = 'full',
                            hidden = function(info) return LootMaster.db.profile.buttonNum < 1 end,
                            dialogControl = "EPGPLMButtonConfigWidget",
                            order = 1.1,
                            name = "button1",
                            desc = "Configure this selection button.",
                        },
                        
                        button2 = {
                            type = "input",
                            width = 'full',
                            hidden = function(info) return LootMaster.db.profile.buttonNum < 2 end,
                            dialogControl = "EPGPLMButtonConfigWidget",
                            order = 1.2,
                            name = "button2",
                            desc = "Configure this selection button.",
                        },
                        
                        button3 = {
                            type = "input",
                            width = 'full',
                            hidden = function(info) return LootMaster.db.profile.buttonNum < 3 end,
                            dialogControl = "EPGPLMButtonConfigWidget",
                            order = 1.3,
                            name = "button3",
                            desc = "Configure this selection button.",
                        },
                        
                        button4 = {
                            type = "input",
                            width = 'full',
                            hidden = function(info) return LootMaster.db.profile.buttonNum < 4 end,
                            dialogControl = "EPGPLMButtonConfigWidget",
                            order = 1.4,
                            name = "button4",
                            desc = "Configure this selection button.",
                        },
                        
                        button5 = {
                            type = "input",
                            width = 'full',
                            hidden = function(info) return LootMaster.db.profile.buttonNum < 5 end,
                            dialogControl = "EPGPLMButtonConfigWidget",
                            order = 1.5,
                            name = "button5",
                            desc = "Configure this selection button.",
                        },
                        
                        button6 = {
                            type = "input",
                            width = 'full',
                            hidden = function(info) return LootMaster.db.profile.buttonNum < 6 end,
                            dialogControl = "EPGPLMButtonConfigWidget",
                            order = 1.6,
                            name = "button6",
                            desc = "Configure this selection button.",
                        },
                        
                        button7 = {
                            type = "input",
                            width = 'full',
                            hidden = function(info) return LootMaster.db.profile.buttonNum < 7 end,
                            dialogControl = "EPGPLMButtonConfigWidget",
                            order = 1.7,
                            name = "button7",
                            desc = "Configure this selection button.",
                        },
                        
                        btnTestPopup = {
                            order = 3,
                            type = "execute",
                            width = 'full',
                            name = "Открыть тестовое окно распределения лута",
                            desc = "Открывает тестовое окно, таким образом вы можете видеть то, на что это будет похоже на ваших клиентах. После теста нажмите кнопку закрыть окно.",
                            func = function()
                                local lootLink
                                for i=1, 20 do
                                  lootLink = GetInventoryItemLink("player", i)
                                  if lootLink then break end
                                end
                                if not lootLink then return end
                                
                                ml = LootMasterML        
                                local loot = ml:GetLoot(lootLink)
                                local added = false
                                if not loot then
                                    local lootID = ml:AddLoot(lootLink, true)
                                    loot = ml:GetLoot(lootID)
                                    loot.announced = false
                                    loot.manual = true
                                    added = true
                                end
                                if not loot then return self:Print('Unable to register loot.') end          
                                ml:AddCandidate(loot.id, UnitName('player'))
                                ml:AnnounceLoot(loot.id)
                                for i=1, LootMaster.db.profile.buttonNum do
                                  ml:AddCandidate(loot.id, 'Button ' .. i)
                                  ml:SetCandidateResponse(loot.id, 'Button ' .. i, LootMaster.RESPONSE['button'..i], true)
                                end
                                ml:ReloadMLTableForLoot(loot.link)
                            end
                        },
                    },
                },
                
                auto_hiding_group = {
                    order = 13,
                    type = "group",
                    guiInline = true,
                    hidden = function(info) return not LootMasterML end,
                    name = "Автоскрытие лута",
                    args = {
                        
                        help = {
                            order = 0,
                            type = "description",
                            name = "Это позволяет вам управлять автоматическими особенностями сокрытия EPGPLootmaster.",
                        },
                                
                        hideOnSelection = {
                            type = "toggle",
                            order = 16,
                            width = 'full',
                            name = "Скрыть окно разделения добычи, когда выбор голосование открывается.",
                            desc = "Проверьте, что это автоматически скрывает Основной Интерфейс Разделения добычи, когда вы обязаны проголосовать за лут.",
                        },
                        
                        hideMLOnCombat = {
                            type = "toggle",
                            order = 17,
                            width = 'full',
                            name = "Скрывает распределение добычи, входя в бой.",
                            desc = "Проверьте, что это автоматически скрывает окно Распределения лута, когда вы войдете в бой. Окно автоматически откроется вновь когда вы выйдете из боя.",
                        },
                        
                        hideSelectionOnCombat = {
                            type = "toggle",
                            order = 18,
                            width = 'full',
                            name = "Скрывает голосование за лут, входя в бой.",
                            desc = "Проверьте, что это автоматически скрывает окно голосования за лут, когда вы войдете в бой. Окно автоматически откроется вновь когда вы выйдете из боя. ",
                        },
                    },
                },
                
                auto_announce_group = {
                    order = 14,
                    type = "group",
                    guiInline = true,
                    hidden = function(info) return not LootMasterML end,
                    name = "Автоматическое объявление",
                    args = {
                        
                        help = {
                            order = 0,
                            type = "description",
                            name = "EPGP Lootmaster автоматически объявляет об распеделении добычи.",
                        },
                                
                        auto_announce_threshold = {
                            order = 13,
                            type = "select",
                            width = 'full',
                            hidden = function(info) return not LootMasterML end,
                            name = "Авто порог объявления",
                            desc = "Устанавливает автоматический порог объявления об распределении лута. Любое распределение, которое имеет равное или более высокое качество, объявит автоматически участникам рейда.",
                            values = {
                                [0] = 'Never auto announce',
                                [2] = ITEM_QUALITY2_DESC,
                                [3] = ITEM_QUALITY3_DESC,
                                [4] = ITEM_QUALITY4_DESC,
                                [5] = ITEM_QUALITY5_DESC,
                            },
                        },
                    },
                },
                
                
                AutoLootGroup = {
            
                            type = "group",
                            order = 16,
                            guiInline = true,
                            name = "Автоматический лут",
                            desc = "Auto looting of items",
                            hidden = function(info) return not LootMasterML end,
                            args = {
                                
                                help = {
                                    order = 0,
                                    type = "description",
                                    name = "EPGP Lootmaster автоматически позволяет вам посылать определенные пункты BoU и BoE определенному кандидату, не задавая вопросов.",
                                },
                                
                                AutoLootThreshold = {
                                    order = 1,
                                    type = "select",
                                    width = 'full',
                                    hidden = function(info) return not LootMasterML end,
                                    name = "Автоматический порог распределения (BoE и пункты BoU только)",
                                    desc = "Устанавливает автоматический порог распределения. Любое распределение BoE и BoU, которое имеет более низкое или равное качество, пошлет автоматически кандидату ниже.",
                                    values = {
                                        [0] = 'Never auto loot',
                                        [2] = ITEM_QUALITY2_DESC,
                                        [3] = ITEM_QUALITY3_DESC,
                                        [4] = ITEM_QUALITY4_DESC,
                                        [5] = ITEM_QUALITY5_DESC,
                                    },
                                },
                                
                                AutoLooter = {
                                    type = "select",
                                    style = 'dropdown',
                                    order = 2,
                                    width = 'full',
                                    name = "Имя кандидата по умолчанию (с учетом регистра):",
                                    desc = "Пожалуйста, введите имя кандидата по умолчанию, чтобы получить пункты BoE и BoU здесь.",
                                    disabled = function(info) return (LootMaster.db.profile.AutoLootThreshold or 0)==0 end,
                                    values = function()
                                        local names = {}
                                        local name;
                                        local num = GetNumRaidMembers()
                                        if num>0 then
                                            -- we're in raid
                                            for i=1, num do 
                                                name = GetRaidRosterInfo(i)
                                                names[name] = name
                                            end
                                        else
                                            num = GetNumPartyMembers()
                                            if num>0 then
                                                -- we're in party
                                                for i=1, num do 
                                                    names[UnitName('party'..i)] = UnitName('party'..i)
                                                end
                                                names[UnitName('player')] = UnitName('player')
                                            else
                                                -- Just show everyone in guild.
                                                local num = GetNumGuildMembers(true);
                                                for i=1, num do repeat
                                                    name = GetGuildRosterInfo(i)
                                                    names[name] = name
                                                until true end     
                                            end                                   
                                        end
                                        sort(names)
                                        return names;
                                    end
                                },
                            }
                },
            
        
        
                MonitorGroup = {
                            type = "group",
                            order = 17,
                            guiInline = true,
                            hidden = function(info) return not LootMasterML end,
                            name = "контроль",
                            desc = "Пошлите и получите сообщение контроля от РЛ и см. то, что выбрал другой рейдер.",
                            args = {
                                
                                help = {
                                    order = 0,
                                    type = "description",
                                    name = "EPGP Lootmaster позволяет Вам посылать сообщения другим пользователям в Вашем рейде. Это покажет им тот же самый интерфейс распределения лута как у РЛ, позволяя им помочь с распределением добычи.",
                                },
                
                                monitor = {
                                    type = "toggle",
                                    set = function(i, v)
                                        LootMaster.db.profile[i[#i]] = v;
                                        if LootMasterML and LootMasterML.UpdateUI then
                                            LootMasterML.UpdateUI( LootMasterML );
                                        end
                                    end,
                                    order = 1,
                                    width = 'full',
                                    name = "Прислушаться к поступающему распределению добычи",
                                    desc = "Проверьте, показывает ли поступающие обновления распределения лута. Эта функция позволяет Вам видеть, что мастерлут взаимодействует так, что вы можете помочь в принятии решений о распределении добычи.",
                                    disabled = false,
                                },
                                
                                monitorIncomingThreshold = {
                                    order = 2,
                                    width = 'normal',
                                    type = "select",
                                    name = "Распределять равное и выше",
                                    desc = "Видеть окно распределения лута рейду предметов соответствующие этому порогу или выше.",
                                    disabled = function(info) return not LootMaster.db.profile.monitor end,
                                    values = {
                                        [2] = ITEM_QUALITY2_DESC,
                                        [3] = ITEM_QUALITY3_DESC,
                                        [4] = ITEM_QUALITY4_DESC,
                                        [5] = ITEM_QUALITY5_DESC,
                                    },
                                },
                                
                                monitorSend = {
                                    type = "toggle",
                                    order = 3.1,
                                    width = 'full',
                                    name = "Посылать окно распределения добычи всему рейду",
                                    desc = "Хотите ли вы посылать интерактивные обновления распределения добычи. Это позволяет другому члену рейду видеть, что Распределяющий добычу взаимодействует с игроками и они могут помочь в принятии решений о распределении добычи. Вы только отошлете сообщения, если Вы будете основным Распределяющим Добычу.",
                                    disabled = false,
                                },
                                
                                monitorSendAssistantOnly = {
                                    type = "toggle",
                                    order = 3.2,
                                    disabled = function(info) return not LootMaster.db.profile.monitorSend end,
                                    width = 'full',
                                    name = "Посылать окно распределения добычи только помошникам рейд лидера",
                                    desc = "Высылает сообщения распределения лута один за другим помощникам рейд лидера. Оставте поле пустым если желаете что бы все видели распределение добычи. Снятие галочки так же ведет к ускорению открытия распределения добычи.",
                                },
                                
                                hideResponses = {
                                    type = "toggle",
                                    disabled = function(info) return not LootMaster.db.profile.monitorSend end,
                                    order = 3.3,
                                    width = 'full',
                                    name = "Маскировать ответы до полного голосования",
                                    desc = "Данная опция скроет ответы от игроков на мониторах, в то время как контролирующий игрок все еще делает свой выбор для распределения добычи. Это будет препятствовать тому, чтобы игроки делали выбор основанный на других ответах людей. Это предотвращает 'обман' и ускоряет процесс голосования, потому что люди прекратят ждать проголосовавших",
                                },
                                
                                monitorThreshold = {
                                    order = 4,
                                    width = 'normal',
                                    type = "select",
                                    name = "Посылать равный или выше",
                                    desc = "Посылать сообщения распределения лута которые соответствуют этому порогу или выше. (Пожалуйста, имейте в виду, что образцы и т.д. также соответствуют этому порогу),",
                                    disabled = function(info) return not LootMaster.db.profile.monitorSend end,
                                    values = {
                                        [2] = ITEM_QUALITY2_DESC,
                                        [3] = ITEM_QUALITY3_DESC,
                                        [4] = ITEM_QUALITY4_DESC,
                                        [5] = ITEM_QUALITY5_DESC,
                                    },
                                },
                                
                                hint = {
                                    order = 5,
                                    width = 'normal',
                                    hidden = function(info) return not LootMaster.db.profile.monitorSend end,
                                    type = "description",
                                    name = "  Только BoE и пункты BoU будут фильтрованы be\r\n. Пункты BoP будут always\r\n посылать сообщение .",
                                },
                            }
                },
                
                ExtraFunctionGroup = {
                            type = "group",
                            order = 18,
                            guiInline = true,
                            hidden = function(info) return not LootMasterML end,
                            name = "Дополнительные функции",
                            args = {
                                
                                help = {
                                    order = 0,
                                    type = "description",
                                    name = "Некоторые дополнительные функции, которые могли бы пригодиться.",
                                },
                                btnVersionCheck = {
                                  order = 1000,
                                  type = "execute",
                                  name = "Версия Checker",
                                  desc = "Открывает структуру шашки вариантов.",
                                  func = function()
                                           LootMaster:ShowVersionCheckFrame()
                                         end
                                },
                                
                                btnRaidInfoCheck = {
                                  order = 2000,
                                  type = "execute",
                                  name = "Проверка рейда",
                                  desc = "Проверка нахождения игроков в рейдовом подземелии.",
                                  func = function()
                                           LootMasterML:ShowRaidInfoLookup()
                                         end
                                }
                                
                                
                                
                
                                
                            }
                }
            },
        },
    },
  }

  local config = LibStub("AceConfig-3.0")
  local dialog = LibStub("AceConfigDialog-3.0")

  config:RegisterOptionsTable("EPGPLootMaster-Bliz", options)
  dialog:AddToBlizOptions("EPGPLootMaster-Bliz", "EPGPLootMaster", nil, 'global')
  --dialog:AddToBlizOptions("EPGPLootMaster-Bliz", "Monitor", "EPGPLootMaster", 'MonitorGroup')
  
end