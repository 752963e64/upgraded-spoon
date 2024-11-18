-- shm_sqlite Session.lua
-- author: 752963e64 - 14/11/2024

local shmlock = require "Shmlock"

Session = {}

-- object:new()
-- @object
function Session:new(sqlite3, filename, session_limit, session_time)
  local o = {
    db = sqlite3.open(filename or '.session.sqlite3',
      sqlite3.OPEN_READWRITE|sqlite3.OPEN_CREATE
    ),
    lock = shmlock:new(false),
    ERROR = sqlite3.ERROR,
    BUSY = sqlite3.BUSY,
    OK = sqlite3.OK,
    DONE = sqlite3.DONE,
    SESSION_LIMIT = session_limit or 10,
    SESSION_TIME = session_time or 60
  }
  setmetatable(o, self)
  self.__index = self
  
  if not filename then
    Log(kLogInfo, '\e[01;36m- No filename provided default to "./.session.sqlite3"...\e[0m')
  end

  if not session_limit then
    Log(kLogInfo, '\e[01;36m- No session_limit provided default to 10 sessions per IP address...\e[0m')
  end

  if not session_time then
    Log(kLogInfo, '\e[01;36m- No session_time provided default to 60 seconds...\e[0m')
  end

  o:create()
  return o
end

-- object:create()
-- @object
function Session:create()
  self.lock:aquire()

  self.db:busy_timeout(1000)
  self.db:exec[=[
    CREATE TABLE IF NOT EXISTS session
    (addr INTEGER,
    useragent VARCHAR,
    os VARCHAR,
    session_t VARCHAR,
    lastseen VARCHAR,
    session VARCHAR);
  ]=]

  self.insert_session = [=[
    INSERT
    INTO
    session
    ( 
      addr,
      useragent,
      os,
      session_t,
      lastseen,
      session
    )
    VALUES
    (
      ?,
      ?,
      ?,
      Strftime('%s', 'now')+]=]..tostring(self.SESSION_TIME)..[=[,
      Datetime(Strftime('%s'),'unixepoch', 'localtime'),
      ?
    );
  ]=]
  self.insert_session = self.db:prepare(self.insert_session)

  self.update_lastseen = [=[
    UPDATE
    session
    SET
    lastseen = Datetime(Strftime('%s'),'unixepoch', 'localtime')
    WHERE
    useragent = (?)
    AND
    session = (?)
    AND
    addr = (?)
    AND
    session_t > Strftime('%s', 'now');
  ]=]
  self.update_lastseen = self.db:prepare(self.update_lastseen)

  self.update_session = [=[
    UPDATE
    session
    SET
    session = (?),
    useragent = (?),
    os = (?),
    lastseen = Datetime(Strftime('%s'),'unixepoch', 'localtime'),
    session_t = Strftime('%s', 'now')+]=]..tostring(self.SESSION_TIME)..[=[
    WHERE session = (?);
  ]=] -- this forget older sessions.
  self.update_session = self.db:prepare(self.update_session)

  self.lock:release()
end

--[[
Session:add_session(addr, useragent, os, session)
@nil - prepared query has no instance.
@bool - if query succeeded.
]]
function Session:add_session(addr, useragent, os, session)
  self.lock:aquire()
  if not self.insert_session then
    Log(kLogInfo, "sqlite prepare .insert_session failed: %s" % { self.db:errmsg() })
    self.lock:release()
    return nil
  end
  
 -- find previous entry and update them if applicable.
  local count_session_per_addr, row = 0, nil
  local query = 'SELECT rowid,* FROM session WHERE addr = '..tostring(addr)..';'
  for row in self.db:nrows(query) do
    -- look for an expirated session.
    local now = '%.0f' % { GetTime() }
    if row.session_t <= now then
      if not self.update_session then
        Log(kLogInfo, "sqlite prepare .update_session failed: %s" %
          { self.db:errmsg() }
        )
        self.lock:release()
        return nil
      end
      self.update_session:reset()
      self.update_session:bind_values(
        session,
        useragent,
        os,
        row.session
      ) 
      local status = self.update_session:step()
      if status == self.BUSY or
        status == self.ERROR then
        Log(kLogInfo, "sqlite crashed with .update_session %s" % { self.db:errmsg() })
      end
      self.lock:release()
      return row.rowid
    end
    -- go out and return nil 
    count_session_per_addr = count_session_per_addr+1
    if count_session_per_addr == self.SESSION_LIMIT then
      self.lock:release()
      return nil
    end
  end
  
  -- insert new consumer into database 
  self.insert_session:reset()
  self.insert_session:bind_values(addr, useragent, os, session)
  local status = self.insert_session:step()
  local rowid = self.insert_session:last_insert_rowid()
  if status == self.BUSY or
    status == self.ERROR then
    Log(kLogInfo, "sqlite crashed with .insert_session %s" % { self.db:errmsg() })
  end
  self.lock:release()
  return rowid
end

--[[
Session:reset_lastseen(addr,session)
@bool - if query succeeded.
]]
function Session:reset_lastseen(addr, session, useragent)
  self.lock:aquire()
  if not self.update_lastseen then
    Log(kLogInfo, "sqlite prepare .update_lastseen failed: %s" % { self.db:errmsg() })
    self.lock:release()
    return false
  end
  self.update_lastseen:reset()
  self.update_lastseen:bind_values(useragent, session, addr)
  local status = self.update_lastseen:step()
  if status == self.BUSY or
    status == self.ERROR then
    Log(kLogInfo, "sqlite crashed with .update_lastseen %s" % { self.db:errmsg() })
  end
  self.lock:release()

  if status == self.DONE then
    return true
  else
    return false
  end
end

return Session
