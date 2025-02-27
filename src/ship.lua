local class = class or require "middleclass"
local path = path or require "path"

--------------------------------------------------------------------------------
--[[
MAP = {
  "#q#h#h#h#h#h#h#h#h#h#w",
  "#ver  nd      wd  sl#v",
  "#vcr                #v",
  "#vjr              pl#v",
  "#r#h#h#w+h#h#d#h#h#h#l",
  "#v    #v    #vbdbdbd#v",
  "#vMr  +v    +v      #v",
  "#v    #v    #vbububu#v",
  "#r#h#h#l    #r#h#h#h#l",
  "#vfr  #v    +v    tl#v",
  "#v    +v    #r#h#h#h#l",
  "#vzr  #v    #v    Wl#v",
  "#vzr  #v    +v      #v",
  "#vzr  #v    #v    Fl#v",
  "#r#h#h#l+h#h#u#d#h#h#l",
  "#v    #v      #v  Ol#v",
  "#vRr  +v      +v  Tl#v",
  "#v    #v      #v  Sl#v",
  "#a#h#h#u#h#h#h#u#h#h#s",
}
--]]

MAP_X,MAP_Y = 19,20

MAP_WALLS = {
  "quuuuwquuuuuwquuuuw",
  "adDddsl.....raddDds",
  "quUuuwaddDddsquuUuw",
  "l.....uuuUuuu.....r",
  "addd............dds",
  "quuwl..ddDdd...rquw",
  "adDsl.rquUuwl..RL.r",
  "quUwl.radddsl..rl.r",
  "l..rl.rquuuwl..rl.r",
  "l..RL.rl...rl..rl.r",
  "l..rl.radDdsl..rl.r",
  "l..rl..uuUuu...rl.r",
  "adDsl..........RL.r",
  "quUwl..........rads",
  "addsl...........uuw",
  "quuu..............r",
  "l....ddddDdddd....r",
  "adDdsquuuUuuuwadDds",
  "quUuwl.......rquUuw",
  "adddsadddddddsaddds",
}
MAP_DEVICE = {
  "N1N2 .E1E2 . .Z1 .B1 .D1 . .S1S2 .W1W2",
  " . . . . . . . . . . . . . . . . . . .",
  " . . . . . . . . . . . . . . . . . . .",
  " . . . . . . . . . . . . . . . . . . .",
  " . . . . . . . . . . . . . . . . . . .",
  "n1n2n3n4 . . . . . . . . . . . . .C1C2",
  " . . . . . . . . . . . . . . . . . . .",
  "b1 . . . . . . .m1m2m3 . . . . . .O1O2",
  "b1 . . . . . . . . . . . . . . . . . .",
  "b1 . . . . . . .R1R2R3 . . . . . .T1T2",
  "b1 . . . . . . . . . . . . . . . . . .",
  "b1 . . . . . . . . . . . . . . . .L1L2",
  "b1 . . . . . . . . . . . . . . . . . .",
  " . . . . . . . . . . . . . . . . .F1F2",
  "t1t1t1t1 . . . . . . . . . . . . . . .",
  " . . . . . . . . . . . . . . . . . . .",
  " . . . . . . . . . . . . . . . . . . .",
  " . . . . . . . . . . . . . . . . . . .",
  " . . . . . . .J1J2 .J1J2 . . . . . . .",
  " .P1P2P3 . . .J3J4 .J3J4 . . .P1P2P3 .",
}

CODE_TO_DEVICE = {
  B=FlightConsole,
  b=Bed,
  C=Co2Scrubber,
  D=DefenceConsole,
  E=SensorSystem,
  F=FoodSynthesizer,
  J=FTLDrive,
  L=WasteReclamation,
  m=MedicalBay,
  N=NavigationSystem,
  n=NutrientDispenser,
  O=O2Reprocessor,
  P=PropulsionSystem,
  R=ReactorCore,
  S=ShieldSystem,
  T=ThermalRegulator,
  t=Toilet,
  W=WeaponsSystem,
  Z=FTLConsole,
}

-- TODO: wall images by code
-- >^<v (ruld)  (wall then door)
CODE_TO_WALLS = {
  ['.'] = {false,false,false,false, false,false,false,false},
  q={false,true ,true ,false, false,false,false,false},
  w={true ,true ,false,false, false,false,false,false},
  a={false,false,true ,true , false,false,false,false},
  s={true ,false,false,true , false,false,false,false},
  l={false,false,true ,false, false,false,false,false},
  r={true ,false,false,false, false,false,false,false},
  u={false,true ,false,false, false,false,false,false},
  d={false,false,false,true , false,false,false,false},
  L={false,false,false,false, false,false,true ,false},
  R={false,false,false,false, true ,false,false,false},
  U={false,false,false,false, false,true ,false,false},
  D={false,false,false,false, false,false,false,true },
}

--------------------------------------------------------------------------------

Cell = class("Cell")
function Cell:initialize(idx,x,y,device,char,args)
  self.device = device
  self.char = char
  self.neighbors = {}
  self.walls = {false,false,false,false}
  self.passable = true -- TODO: make some impassable?
  self.cost = 1.0
  self.idx = idx
  self.x = x
  self.y = y
  self.items = {}
  self.decorations = {}
  --[[
  -- TODO: "decorations"
  if not device then
    local r = love.math.random()
    if r < 0.01 then
      self.decorations[1] = {TILES.decoration_1, love.math.random(9)-4,love.math.random(9)-4}
    elseif r < 0.02 then
      self.decorations[1] = {TILES.decoration_2, love.math.random(9)-4,love.math.random(9)-4}
    elseif r < 0.03 then
      self.decorations[1] = {TILES.decoration_3, love.math.random(9)-4,love.math.random(9)-4}
    end
  end
  --]]
  if args then for k,v in pairs(args) do self[k]=v end end
end
function Cell:__tostring()
  return string.format("[%s:%i,%i]", self.char, self.x, self.y)
end

--------------------------------------------------------------------------------
Ship = class("Ship")

function Ship:setup_map()
  self.x_size = MAP_X
  self.y_size = MAP_Y

  -- setup cells
  self.cells = {}
  self.devices = {}
  for y=1,MAP_Y do
    local row = MAP_DEVICE[y]
    for x=1,MAP_X do
      local idx = self:idx(x,y)
      local ch = row:sub(2*x-1,2*x-1)
      local var = tonumber(row:sub(2*x,2*x))
      local c = Cell(idx,x,y,nil,ch,{})
      if ch==' ' then
        -- nop
      elseif CODE_TO_DEVICE[ch] then
         local d = CODE_TO_DEVICE[ch](self,c,var)
         self.devices[#self.devices+1] = d
         c.device = d
      else
        print("ERROR: unknown device code in map setup", ch, x, y)
      end
      self.cells[idx] = c
    end
  end

  -- setup edges
  for y=1,MAP_Y do
    local row = MAP_WALLS[y]
    for x=1,MAP_X do
      local idx = self:idx(x,y)
      local c = self.cells[idx]
      local ch = row:sub(x,x)
      local w = CODE_TO_WALLS[ch]
      local n = {}
      if not w[1] then n[#n+1] = self:idx(x+1,y  ) end
      if not w[2] then n[#n+1] = self:idx(x  ,y-1) end
      if not w[3] then n[#n+1] = self:idx(x-1,y  ) end
      if not w[4] then n[#n+1] = self:idx(x  ,y+1) end
      c.neighbors = n
      c.walls = w
    end
  end

  self.devices_by_name = {}
  for _,d in ipairs(self.devices) do
    local n = d.class.name
    if not self.devices_by_name[n] then self.devices_by_name[n] = {} end
    local a = self.devices_by_name[n]
    a[#a+1] = d
  end

  --[[
  print('----------')
  for y=1,MAP_X do
    for x=1,MAP_X do
      io.write(self:cell(x,y).char)
    end
    print()
  end
  print('----------')
  for y=1,MAP_Y do
    for x=1,MAP_X do
      local w = self:cell(x,y).walls
      local x = ((w[1] and 1) or 0)+((w[2] and 2) or 0)+((w[3] and 4) or 0)+((w[4] and 8) or 0)
      io.write(("0123456789ABCDEF"):sub(x+1,x+1))
    end
    print()
  end
  --]]
end

function Ship:initialize()
  self.jobs_list = {}

  self.level = {
    co2=Level('co2',100.0*(DIFFICULTY_LEVEL-1), 0,1000, 0),
    energy=Level('energy',200+100.0*(3-DIFFICULTY_LEVEL), 0,1000, 0),
    o2=Level('o2',100-20*DIFFICULTY_LEVEL, 0,100, 0),
    radiation=Level('radiation',1.0, 0,1e6, 0),
    food=Level('food',2000 - 500*DIFFICULTY_LEVEL, 0,10000, 0),
    slurry=Level('slurry',1000.0-200*DIFFICULTY_LEVEL, 0,1000, 0),
    temperature=Level('temperature',80.0-20*DIFFICULTY_LEVEL, 0,1000, 0),
    waste=Level('waste',500.0+500.0*DIFFICULTY_LEVEL, 0,1000, 0),

    sensor_data=Level('sensor_data',0.0, 0,1000, 0),
    navigation_data=Level('navigation_data',0.0, 0,1000, 0),

    shield_power=Level('shield_power',5*(3-DIFFICULTY_LEVEL), 0,1000, 0),
    weapons_power=Level('weapons_power',5*(3-DIFFICULTY_LEVEL), 0,1000, 0),
    propulsion_power=Level('propulsion_power',0.0, 0,1000, 0),

    defence_command=Level('defence_command',0.0, 0,1000, 0),
    flight_command=Level('flight_command',0.0, 0,1000, 0),
    ftl_command=Level('ftl_command',0.0, 0,1000, 0),

    progress_power=Level('progress_power',0.0, 0,100, 0),

    -- hull_integrity
    }

  self:setup_map()
  self.the_crew = nil
  self:setup_crew()
  self.n_idle = #self.the_crew
end

function Ship:setup_crew()
  local c = {}
  -- TODO: only 1 crew and the rest in cryopods...
  for i,n in ipairs({'Pat','Chris','Terry','Dana','Francis','Jean','Jo','Jordan','Cameron','Casey','Kelly','Ollie'}) do
    c[#c+1] = Crew(n,self)
  end
  self.the_crew = c
end

function Ship:add_job(j)
  local jl = self.jobs_list
  for i=1,#jl do
    if jl[i].priority > j.priority then
      table.insert(jl, i, j)
      return
    end
  end
  self.jobs_list[#self.jobs_list+1] = j
end

function Ship:path(c0,c1,variance)
  local function edges(e,i)
    local n = self.cells[i].neighbors
    for j=1,4 do e[j]=n[j] end
    return e
  end
  local function step_cost_fn(i)
    return self.cells[i].cost -- + love.math.random()/1024
  end
  local function estimate(i0,i1)
    local x0,y0 = self:xy(i0)
    local x1,y1 = self:xy(i1)
    return math.sqrt((x1-x0)^2+(y1-y0)^2)
  end
  local foundit,the_path,result = path.astar(c0.idx,c1.idx,step_cost_fn,edges,estimate,true)
  if foundit then
    for i,pi in ipairs(the_path) do
      local x,y = self:xy(pi)
      the_path[i] = {x+variance*(love.math.random(65)-32)/128,y+variance*(love.math.random(65)-32)/128}
    end
  end
  return foundit,the_path
end

-- TODO: should use path-distance, not metric
-- this will break if there is no path at all...
-- (should probably compute "dijkstra maps" for all devices...
function Ship:locate_device(name,x,y)
  local best_device = nil
  local best_dist = 1e10
  for i,d in ipairs(self.devices_by_name[name]) do
    local c = d.cell
    local dist = math.abs(c.x-x) + math.abs(c.y-y) + 5*(1 - d.efficiency) -- penalize broken
    if d.owner then dist = dist + 5 end -- prefer unowned
    if dist < best_dist then
      best_device = d
      best_dist = dist
    end
  end
  return best_device
end

function Ship:xy(i)
  local i = i-1
  return 1+(i%self.x_size), 1+math.floor(i/self.x_size)
end

function Ship:idx(x,y)
  x,y = math.floor(x),math.floor(y)
  return 1 + (x-1) + (y-1)*self.x_size
end

function Ship:cell(x,y)
  local x,y = math.floor(x),math.floor(y)
  if x<1 or x>self.x_size or y<1 or y>self.y_size then
    return nil
  end
  return self.cells[1 + (x-1) + (y-1)*self.x_size]
end


function Ship:update(dt)
  -- pre-device crew
  local n = #self.the_crew
  for i=1,n do
    local c = self.the_crew[i]
    c:update_pre(dt)
    if c.level.health <= 0 then
      self.the_crew[i] = nil
      c:die()
    end
  end
  compact(self.the_crew, n)

  -- devices
  for _,d in ipairs(self.devices) do
    d:update(dt)
  end

  -- ship values
  for _,l in pairs(self.level) do
    l:update(dt)
  end

  -- post-device crew
  local n = #self.the_crew
  for i=1,n do
    local c = self.the_crew[i]
    c:update_post(dt)
    if c.level.health <= 0 then
      self.the_crew[i] = nil
      c:die()
    end
  end
  compact(self.the_crew, n)
end

function Ship:slow_update(dt)
  for _,c in ipairs(self.the_crew) do
    c:slow_update(dt)
  end
  for _,d in ipairs(self.devices) do
    d:slow_update(dt)
  end
  for _,l in pairs(self.level) do
    l:slow_update(dt)
  end

  local ni = 0
  for _,c in ipairs(self.the_crew) do
    if c.idle then
      ni = ni + 1
    end
  end
  self.n_idle = ni
end

function Ship:draw_map()
  local function draw_tile(cl)
    love.graphics.setColor(0.7,0.7,0.8)
    love.graphics.rectangle('fill', 0, 0, 24, 24)
    --love.graphics.setColor(0.1,0.1,0.5,0.25)
    --love.graphics.rectangle('line', 0, 0, 24, 24)
    -- walls
    love.graphics.setLineWidth(3)
    local OFFSET=1.5
    love.graphics.setColor(0.6,0.5,0.7,1)
    if cl.walls[1] then love.graphics.line(24-OFFSET,0,24-OFFSET,24) end
    if cl.walls[4] then love.graphics.line(0,24-OFFSET,24,24-OFFSET) end
    love.graphics.setColor(0.5,0.4,0.5,1)
    if cl.walls[3] then love.graphics.line(0+OFFSET,0,0+OFFSET,24) end
    if cl.walls[2] then love.graphics.line(0,0+OFFSET,24,0+OFFSET) end
    -- doors
    love.graphics.setLineWidth(2)
    love.graphics.setColor(0.4,0.7,0.5,1)
    local OFFSET=1
    if cl.walls[5] then love.graphics.line(24-OFFSET,0,24-OFFSET,24) end
    if cl.walls[8] then love.graphics.line(0,24-OFFSET,24,24-OFFSET) end
    if cl.walls[7] then love.graphics.line(0+OFFSET,0,0+OFFSET,24) end
    if cl.walls[6] then love.graphics.line(0,0+OFFSET,24,0+OFFSET) end
    --
    love.graphics.setColor(1,1,1,1)
    love.graphics.setLineWidth(1)
  end
  local function draw_decorations(cl)
    for _,d in ipairs(cl.decorations) do
      love.graphics.draw(d[1], d[2], d[3])
    end
  end
  local function draw_device(cl)
    if cl.device and cl.device.draw then
      cl.device:draw()
    else
      local c = cl.char
      love.graphics.print(c, FONT_1, 6, 4)
    end
  end
  local function draw_items(cl)
    for _,d in ipairs(cl.items) do
      love.graphics.draw(d[1], d[2], d[3])
    end
  end

  for y=1,self.y_size do
    for x=1,self.x_size do
      love.graphics.push()
        love.graphics.translate((x-1)*24, (y-1)*24)
        draw_tile(self:cell(x,y))
      love.graphics.pop()
    end
  end
  for y=1,self.y_size do
    for x=1,self.x_size do
      love.graphics.push()
        love.graphics.translate((x-1)*24, (y-1)*24)
        draw_decorations(self:cell(x,y))
      love.graphics.pop()
    end
  end
  for y=1,self.y_size do
    for x=1,self.x_size do
      love.graphics.push()
        love.graphics.translate((x-1)*24, (y-1)*24)
        draw_device(self:cell(x,y))
      love.graphics.pop()
    end
  end
  for y=1,self.y_size do
    for x=1,self.x_size do
      love.graphics.push()
        love.graphics.translate((x-1)*24, (y-1)*24)
        draw_items(self:cell(x,y))
      love.graphics.pop()
    end
  end

  --love.graphics.setColor(0.2,0.3,0.4,0.8)
  --love.graphics.rectangle('line',0.5,0.5, 24*19-1,24*19-1)
end


