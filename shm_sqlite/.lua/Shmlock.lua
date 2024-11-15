-- Shmlock.lua
-- inspired from redbean.dev
local Shmlock = {}

-- object:new()
-- @object
function Shmlock:new(debug)
  local o = {
    SHM_LOCK = 0,
    shm = unix.mapshared(8*8),
    DEBUG = debug and true or false
  }
  setmetatable(o, self)
  self.__index = self
  Log(kLogInfo, '\e[01;36m- Shmlock:new(debug=%s)...\e[0m' % { o.DEBUG })
  return o
end

-- object:aquire()
function Shmlock:aquire()
  local ok, old = self.shm:cmpxchg(self.SHM_LOCK, 0, 1)
  if self.DEBUG then
    Log(kLogInfo, 
      '\e[01;36m- Shmlock:aquire()... ok: %s , old: %s\e[0m' %
      { ok, old })
  end
  if not ok then
    if old == 1 then
      old = self.shm:xchg(self.SHM_LOCK, 2)
    end
    while old > 0 do
      _, err = self.shm:wait(self.SHM_LOCK, 2)
      old = self.shm:xchg(self.SHM_LOCK, 2)
    end
  end
end

-- object:release()
function Shmlock:release()
  local old = self.shm:fetch_add(self.SHM_LOCK, -1)
  if self.DEBUG then
    Log(kLogInfo, 
      '\e[01;36m- Shmlock:release()... old: %s\e[0m' %
      { old })
  end
  if old == 2 then
    self.shm:store(self.SHM_LOCK, 0)
    self.shm:wake(self.SHM_LOCK, 1)
  end
end

return Shmlock
