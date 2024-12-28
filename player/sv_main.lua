Drunk.Player = {}
Drunk.Players = {}

Drunk.Player.Save = function(offline, source, player)
    local player = offline == true and player or Drunk.Player.GetPlayer(source)
    if not player then
        return false
    end
    --https://overextended.github.io/docs/oxmysql/Usage/insert 
    MySQL.insert("INSERT INTO players (citizenid, char, gang, jobs, accounts, position, metadata) VALUES (:citizenid, :char, :gang, :jobs, :accounts, :position, :metadata) ON DUPLICATE KEY UPDATE char = :char, gang = :gang, jobs = :jobs, accounts = :accounts, position = :position, metadata = :metadata",{
        license = player.identifier,
        citizenid = player.citizenid,
        char = json.encode(player.char),
        gang = json.encode(player.gang),
        jobs = json.encode(player.jobs),
        accounts = json.encode(player.accounts),
        position = json.encode(player.position),
        metadata = json.encode(player.metadata)
    })

    -- TODO: Logging system
end

Drunk.Player.Login = function(source, cid, data)
    if (source and source ~= "") then
        if cid then
            local license = Drunk.Utils.ExtractIdentifier(source, "license")

            -- https://overextended.dev/oxmysql/Functions/prepare
            local player = MySQL.prepare.await("SELECT * FROM players WHERE citizenid = ? AND license = ?",{
                cid,
                license
            })

            if player and license == player.license then
                player.char = json.decode(player.char)
                player.gang = json.decode(player.gang)
                player.jobs = json.decode(player.jobs)
                player.accounts = json.decode(player.accounts)
                player.position = json.decode(player.position)
                player.metadata = json.decode(player.metadata)

                Drunk.Player.LoadPlayer(source, player)
            else
                DropPlayer(source, "Character not found")
                -- TODO: anticheat handlers / logs
            end
        else
            Drunk.Player.LoadPlayer(source, data)
        end

        return true
    else
        -- TODO: logs no source
        return false
    end
end

Drunk.Player.LoadPlayer = function(source, data, offline)
    local self = {}
    offline = offline or false

    self.Functions = {}
    self.char = data.char or {}
    self.gang = data.gang or {}
    self.jobs = data.jobs or {}
    self.accounts = data.accounts or {}
    self.metadata = data.metadata or {}
    
    self.char.state = {}
    
    self.source = source
    self.position = data.position
    self.citizenid = data.citizenid
    self.name = GetPlayerName(source)
    self.identifier = data.license or Drunk.Utils.ExtractIdentifier(source, "license")

    function self.Functions.ExtractData()
        return {
            char = self.char,
            gang = self.gang,
            jobs = self.jobs,
            accounts = self.accounts,
            position = self.position,
            metadata = self.metadata
        }
    end

    function self.Functions.UpdateData()
        if not offline then
            TriggerClientEvent("Drunk:Core:Server:Client:UpdateData", self.source,self.Functions.ExtractData())
        end
    end

    function self.Functions.AddJob(job, grade)
        if self.jobs[job] ~= nil then
            return self.Functions.setJobRank(job, grade)
        end

        if not Drunk.Configs.Jobs[job] then
            return false
        end

        if not Drunk.Configs.Jobs[job].ranks[grade] then
            return false
        end
        
        self.jobs[job] = {
            grade = grade,
            onDuty = false,
            name = Drunk.Configs.Jobs[job].name,
            label = Drunk.Configs.Jobs[job].label,
        }

        self.Functions.UpdateData()

        return true
    end

    function self.Functions.RemoveJob(job)
        if self.jobs[job] ~= nil then
            self.jobs[job] = nil
            self.Functions.UpdateData()
            return true
        else
            return false
        end
    end

    function self.Functions.setJobRank(job, grade)
        if self.jobs[job] ~= nil then
            self.jobs[job].grade = grade
            self.Functions.UpdateData()
            return true
        else
            return false
        end
    end

    function self.Functions.setJobDuty(job, duty)
        if self.jobs[job] ~= nil then
            self.jobs[job].onDuty = duty
            self.Functions.UpdateData()
            if not offline then
                TriggerClientEvent("Drunk:Core:Server:Client:UpdateDuty", self.source, job, duty)
            end
            return true
        else
            return false
        end
    end

    function self.Functions.AddMoney(type, amount)
        if self.accounts[type] ~= nil then
            self.accounts[type] = self.accounts[type] + amount
            self.Functions.UpdateData()
            return true
        else
            return false
        end
    end

    function self.Functions.RemoveMoney(type, amount)
        if self.accounts[type] ~= nil then
            self.accounts[type] = self.accounts[type] - amount
            self.Functions.UpdateData()
            return true
        else
            return false
        end
    end

    function self.Functions.SetMoney(type, amount)
        if self.accounts[type] ~= nil then
            self.accounts[type] = amount
            self.Functions.UpdateData()
            return true
        else
            return false
        end
    end

    function self.Functions.SetState(state, value)
        if self.char.state[state] ~= nil then
            self.char.state[state] = value
            self.Functions.UpdateData()
            return true
        else
            return false
        end
    end


    function self.Functions.SetGang(gang, grade)
        if self.gang[gang] ~= nil then
            self.gang[gang] = {
                grade = grade,
                name = Drunk.Gangs[gang].name,
                label = Drunk.Gangs[gang].label,
            }
            self.Functions.UpdateData()
            return true
        else
            return false
        end
    end

    function self.Functions.RemoveGang(gang)
        if self.gang[gang] ~= nil then
            self.gang[gang] = nil
            self.Functions.UpdateData()
            return true
        else
            return false
        end
    end

    function self.Functions.SetPosition(x, y, z)
        self.position = {x = x, y = y, z = z}
        self.Functions.UpdateData()
        return true
    end

    function self.Functions.SetMetadata(key, value)
        self.metadata[key] = value
        self.Functions.UpdateData()
        return true
    end

    if not offline then
        Drunk.Players[source] = self
        TriggerClientEvent("Drunk:Core:Server:Client:LoadData", self.source, self.Functions.ExtractData()) 
    end

    return self
end

Drunk.Player.GetPlayer = function(source)
    return Drunk.Players[source]
end

Drunk.Player.GetPlayers = function()
    return Drunk.Players
end

Drunk.Player.GetPlayerOffline = function(citizenid)
    if not citizenid then
        return nil
    end

    local playerQuery = MySQL.prepare.await("SELECT * FROM players WHERE citizenid = ? AND license = ?",{
        citizenid
    })

    if not playerQuery then
        return nil
    end

    playerQuery.char = json.decode(playerQuery.char)
    playerQuery.gang = json.decode(playerQuery.gang)
    playerQuery.jobs = json.decode(playerQuery.jobs)
    playerQuery.accounts = json.decode(playerQuery.accounts)
    playerQuery.position = json.decode(playerQuery.position)
    playerQuery.metadata = json.decode(playerQuery.metadata)

    local player = Drunk.Player.LoadPlayer(nil, playerQuery, true)

    return player
end