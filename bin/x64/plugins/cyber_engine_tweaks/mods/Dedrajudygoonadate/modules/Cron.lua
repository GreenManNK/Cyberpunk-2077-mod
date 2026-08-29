local Cron = { tasks = {}, nextId = 0 }

local function addTask(delay, interval, cb)
  Cron.nextId = Cron.nextId + 1
  local t = { id = Cron.nextId, delay = delay or 0, interval = interval, cb = cb, halted = false }
  function t:Halt() self.halted = true end
  table.insert(Cron.tasks, t)
  return t
end

function Cron.After(delay, cb)
  return addTask(delay or 0, nil, cb)
end

function Cron.Every(interval, cb)
  return addTask(interval or 0, interval or 0, cb)
end

function Cron.Update(dt)
  dt = dt or 0
  local keep = {}
  for _, t in ipairs(Cron.tasks) do
    if not t.halted then
      t.delay = (t.delay or 0) - dt
      if t.delay <= 0 then
        local ok, err = pcall(function() t.cb(t) end)
        if not ok then print("[JudyDateSMS] Cron error: " .. tostring(err)) end
        if t.interval and not t.halted then
          t.delay = t.interval
          table.insert(keep, t)
        end
      else
        table.insert(keep, t)
      end
    end
  end
  Cron.tasks = keep
end

function Cron.StopAll()
  Cron.tasks = {}
end

return Cron
