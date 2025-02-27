
UI = {
  crew = {
    eat = {},
    sleep = {},
    waste = {},
    medical = {},
  },
  cell = {
    repair = {},
    man = {},
  },
}


----------------------------------------
local function draw_border(w,h)
  love.graphics.setColor(0,0,0,0.5)
  love.graphics.rectangle('fill', 1.5-3.0, 1.5-3.0, w+5, h+5)
  love.graphics.setLineWidth(3)
  love.graphics.setColor(0.7,0.7,0.9)
  love.graphics.rectangle('line',1.5-3.0,1.5-3.0, w+3,h+3)
  love.graphics.setColor(0.8,0.8,1)
  love.graphics.rectangle('line',1.5-1.0,1.5-1.0, w+3,h+3)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1,1,1,1)
end

----------------------------------------
function draw_messages_panel(the_messages)
  draw_border(503,215)
  love.graphics.setColor(0.9,0.9,0.9,1)
  for i=1,17 do
    if the_messages[i][1] then
      love.graphics.print(the_messages[i][1], 1.5, 1.5+i*12-12)
    end
  end
  for i=1,17 do
    if the_messages[i][2] then
      love.graphics.setColor(unpack(the_messages[i][3]))
      love.graphics.print(the_messages[i][2], 1.5+8*8, 1.5+i*12-12)
    end
  end
end

----------------------------------------
function draw_jobs_queue_panel(the_jobs)
  draw_border(239,287)
  for i,j in ipairs(the_jobs) do
    if i==23 and #the_jobs>23 then
      love.graphics.print(" . . . ", 1.5,1.5+12*i-12)
    else
      love.graphics.print(tostring(j), 1.5,1.5+12*i-12)
    end
    if i==23 then break end
  end
end

----------------------------------------
function draw_progress_panel(the_progress)
  draw_border(503,215)

  love.graphics.draw(TILES[NODES.dagon_fomalhaut.tile], 2.5,2.5)
  love.graphics.draw(TILES[NODES.asteroid_belt.tile], 216,216-72-2.5)
  love.graphics.draw(TILES[NODES.earth.tile], 504.5-72, 2.5)

  love.graphics.setColor(0.2,0.8,0.9,0.5)
  love.graphics.circle('fill', 
    NODES.dagon_fomalhaut.start_position[1]*24-12, NODES.dagon_fomalhaut.start_position[2]*24-12,
    5)
  love.graphics.circle('fill', 
    NODES.asteroid_belt.start_position[1]*24-12, NODES.asteroid_belt.start_position[2]*24-12,
    5)
  love.graphics.circle('fill', 
    NODES.earth.start_position[1]*24-12, NODES.earth.start_position[2]*24-12,
    5)
  love.graphics.circle('fill', 
    NODES.earth.end_position[1]*24-12, NODES.earth.end_position[2]*24-12,
    5)
  love.graphics.setLineWidth(3)
  love.graphics.line(
    NODES.dagon_fomalhaut.start_position[1]*24-12, NODES.dagon_fomalhaut.start_position[2]*24-12,
    NODES.asteroid_belt.start_position[1]*24-12, NODES.asteroid_belt.start_position[2]*24-12,
    NODES.earth.start_position[1]*24-12, NODES.earth.start_position[2]*24-12,
    NODES.earth.end_position[1]*24-12, NODES.earth.end_position[2]*24-12)
  love.graphics.setLineWidth(1)

  love.graphics.setColor(0.9,0.8,1,1)
  local cn = the_progress.current_node
  local ep = the_progress.elapsed_progress
  local x = cn.start_position[1] + ep*cn.dir[1]
  local y = cn.start_position[2] + ep*cn.dir[2]
  love.graphics.circle('fill', x*24-12, y*24-12, 5)

  love.graphics.printf(string.format("%0.01f/%0.01f", the_progress.elapsed_progress, the_progress.current_node.time),
    x*24-12-50,y*24-12+16, 100, 'center')

  love.graphics.printf(cn.name,        FONTS.torek_16, 144,  2.5, 216, 'center')
  love.graphics.printf(cn.description,                 144, 24,   216, 'center')
end

----------------------------------------
function draw_crew_panel(crew,the_ship)
  draw_border(239,287)

  love.graphics.setColor(1,0.5,1,1)
  love.graphics.print(string.format("%2i idle / %2i crew", the_ship.n_idle, #the_ship.the_crew), 2.5, 272)

  if not crew then return end

  love.graphics.setColor(crew.color[1],crew.color[2],crew.color[3],1.0)
  love.graphics.print(crew.name,2.5,1.5)

  love.graphics.setColor(1,1,1,1)
  if crew.level.health<90 then love.graphics.setColor(1,0.8,0.8) else love.graphics.setColor(1,1,1) end
  love.graphics.print(string.format("Health:%3i", crew.level.health), 2.5,23.5)
  if crew.level.food<8 then love.graphics.setColor(1,0.8,0.8) else love.graphics.setColor(1,1,1) end
  love.graphics.print(string.format("Food:%3i",   crew.level.food),   2.5,35.5)
  if crew.level.rest<10 then love.graphics.setColor(1,0.8,0.8) else love.graphics.setColor(1,1,1) end
  love.graphics.print(string.format("Rest:%3i",   crew.level.rest),   2.5,47.5)
  if crew.level.waste>32 then love.graphics.setColor(1,0.8,0.8) else love.graphics.setColor(1,1,1) end
  love.graphics.print(string.format("Waste:%3i",  crew.level.waste),  2.5,59.5)
  if crew.level.o2<10 then love.graphics.setColor(1,0.8,0.8) else love.graphics.setColor(1,1,1) end
  love.graphics.print(string.format("O2:%3i",     crew.level.o2),     2.5,83.5)
  if crew.level.stress>100 then love.graphics.setColor(1,0.8,0.8) else love.graphics.setColor(1,1,1) end
  love.graphics.print(string.format("Stress:%3i", crew.level.stress), 2.5,71.5)
  if the_ship.level.temperature.value>110 then
    love.graphics.setColor(1,0,0)
    love.graphics.print("HOT", 200.5,23.5)
  elseif the_ship.level.temperature.value<50 then
    love.graphics.setColor(0,0,1)
    love.graphics.print("COLD", 200.5,23.5)
  end


  -- TODO: display this once we can "timeout"
  --love.graphics.setColor(1,0.5,0.5)
  --love.graphics.print(crew.last_damage, 102.5,23.5)
  -- TODO: display current effects (hunger, asphyxiation, etc.)

  if crew.current_action then
    love.graphics.setColor(0,1,0.5,1)
    love.graphics.print(tostring(crew.current_action), 2.5,107.5)
    love.graphics.setColor(1,1,1,1)
  end
  local n = #crew.action_stack
  for i=1,n do
    love.graphics.print(tostring(crew.action_stack[n-i+1]), 2.5,107.5+12*i)
  end

  -- UI buttons for: eat/sleep/waste/medical
end

----------------------------------------
function draw_ship_stats_panel(ship)
  draw_border(239,287)

  love.graphics.setColor(1,1,1)
  local y = 1.5
  love.graphics.print(string.format("energy:%3i", ship.level.energy.value), 1.5,y); y=y+12
  love.graphics.print(string.format("CO2:%3i", ship.level.co2.value), 1.5,y); y=y+12
  love.graphics.print(string.format("O2:%3i", ship.level.o2.value), 1.5,y); y=y+12
  love.graphics.print(string.format("food:%3i", ship.level.food.value), 1.5,y); y=y+12
  love.graphics.print(string.format("slurry:%3i", ship.level.slurry.value), 1.5,y); y=y+12
  love.graphics.print(string.format("temperature:%3i", ship.level.temperature.value), 1.5,y); y=y+12
  love.graphics.print(string.format("waste:%3i", ship.level.waste.value), 1.5,y); y=y+12
  love.graphics.print(string.format("radiation:%3i", ship.level.radiation.value), 1.5,y); y=y+12
  y=y+12
  love.graphics.print(string.format("sensor-data:%3i", ship.level.sensor_data.value), 1.5,y); y=y+12
  love.graphics.print(string.format("navigation-data:%3i", ship.level.navigation_data.value), 1.5,y); y=y+12
  y=y+12
  love.graphics.print(string.format("propulsion-power:%3i", ship.level.propulsion_power.value), 1.5,y); y=y+12
  love.graphics.print(string.format("shield-power:%3i", ship.level.shield_power.value), 1.5,y); y=y+12
  love.graphics.print(string.format("weapons-power:%3i", ship.level.weapons_power.value), 1.5,y); y=y+12
  y=y+12
  love.graphics.print(string.format("defence-command:%3i", ship.level.defence_command.value), 1.5,y); y=y+12
  love.graphics.print(string.format("flight-command:%3i", ship.level.flight_command.value), 1.5,y); y=y+12
  love.graphics.print(string.format("ftl-command:%3i", ship.level.ftl_command.value), 1.5,y); y=y+12
  y=y+12
  love.graphics.print(string.format("progress-power:%3i", ship.level.progress_power.value), 1.5,y); y=y+12
end

----------------------------------------
function draw_ship_map_panel(ship,chosen_cell,chosen_crew)
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(IMAGES.ship_frame,0-24,0-24) -- XXX - using 0.5 here gives aliasing

  ship:draw_map()
  love.graphics.setColor(1,1,1,1)
  for i,c in ipairs(ship.the_crew) do
    c:draw()
    if c == chosen_crew then
      love.graphics.setColor(1,0,1,0.8)
      love.graphics.circle('line',(c.location.x-1)*24,(c.location.y-1)*24,12)
      love.graphics.setColor(1,1,1,1)
    end
  end
  if chosen_cell then
    love.graphics.setColor(1,0,1,0.8)
    love.graphics.rectangle('line',(chosen_cell.x-1)*24,(chosen_cell.y-1)*24,24,24)
  end
end

----------------------------------------
function draw_cell_panel(cell)
  draw_border(239,287)
  local NAME_Y = 18.5
  local DESCRIPTION_Y = 35.5
  local STATE_Y = 71.5
  local ENERGY_Y = 159.5

  local function level_color(l)
    if l<0.25 then
      love.graphics.setColor(1,0.25,0.5)
    elseif l<0.50 then
      love.graphics.setColor(1,0.75,0.5)
    elseif l<0.75 then
      love.graphics.setColor(1,1,0.5)
    else
      love.graphics.setColor(1,1,1)
    end
  end

  if not cell then return end
  love.graphics.setColor(1,1,1)
  love.graphics.print(string.format("%02i-%02i",cell.x,cell.y), 1.5,1.5)
  --love.graphics.print(cell.char, 199.5-12,1.5)

  local d = cell.device
  if not d then return end

  if not d.enabled then
    love.graphics.setColor(1,0.25,0.5)
    love.graphics.print(d.name, 1.5,NAME_Y)
  else
    love.graphics.print(d.name, 1.5,NAME_Y)
  end
  --if d.activated then love.graphics.print('a', 199.5-12*2,13.5) end
  --if d.manned    then love.graphics.print('m', 199.5-12*1,13.5) end
  if d.tile then
    love.graphics.setColor(0.7,0.7,0.8)
    love.graphics.rectangle('fill',240-24-2,3, 24,24)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(d.tile, 240-24-2+0.5, 3+0.5)
  elseif d.active_animations[1] then
    local a = d.active_animations[1]
    love.graphics.setColor(0.7,0.7,0.8)
    love.graphics.rectangle('fill',240-24-2,3, 24,24)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(a.image, a.quads[1+a.frame], 240-24-2, 3)
  end

  level_color(d.efficiency)
  love.graphics.print(string.format("Efficiency:%3i", (d.efficiency*100)), 1.5,STATE_Y)

  love.graphics.setColor(1,1,1)
  if d.owner then
    love.graphics.print(d.owner, 13.5,NAME_Y)
  end

  -- TODO: move health to "Level" and plot historical chart
  level_color(d.health.electronic)
  love.graphics.print(string.format("Electronic:%3i (-%.04f%%)",
    (d.health.electronic*100), (d.decay.electronic*100)), 13.5, STATE_Y+12)
  level_color(d.health.mechanical)
  love.graphics.print(string.format("Mechanical:%3i (-%.04f%%)",
    (d.health.mechanical*100), (d.decay.mechanical*100)), 13.5, STATE_Y+24)
  level_color(d.health.quantum)
  love.graphics.print(string.format("Quantum:%3i (-%.04f%%)",
    (d.health.quantum*100), (d.decay.quantum*100)), 13.5, STATE_Y+36)
  level_color(d.integrity)
  love.graphics.print(string.format("[Integrity:%3i]",
    (d.integrity*100)), 13.5, STATE_Y+48)

  love.graphics.setColor(1,1,1,1)
  if d.activation_elapsed>0 then
    love.graphics.print(string.format("Accrued:%0.01f/%0.01f",
      d.activation_elapsed, d.activation_time), 13.5, STATE_Y+60+4)
  end

  if d.inputs.energy then
    love.graphics.setColor(0.90,1,1)
    love.graphics.print(string.format("Requires %i energy", d.inputs.energy), 1.5, ENERGY_Y)
  elseif d.outputs.energy then
    love.graphics.setColor(0.90,1,1)
    love.graphics.print(string.format("Generates %i energy", d.outputs.energy), 1.5, ENERGY_Y)
  end

  love.graphics.setColor(1,0.9,1)
  if d.mode then love.graphics.print(string.format("Mode: %s", d.mode), 1.5, ENERGY_Y+24) end

  love.graphics.setColor(1,1,0.9)
  love.graphics.printf(d.description, 3.5,DESCRIPTION_Y, 240-7, 'left')

  -- TODO: proper UI
  if d.repair_job then
    love.graphics.setColor(0.9,1,0.9)
    love.graphics.draw(IMAGES.button_repair.down, 2, 288-48-1)
  else
    love.graphics.setColor(1,1,1)
    love.graphics.draw(IMAGES.button_repair.up, 2, 288-48-1)
  end
  if d.operate_job then
    love.graphics.setColor(0.9,1,0.9)
    love.graphics.draw(IMAGES.button_operate.down, 240-120, 288-48-1)
  elseif d.manned and d.enabled then
    love.graphics.setColor(1,1,1)
    love.graphics.draw(IMAGES.button_operate.up, 240-120, 288-48-1)
  else
    love.graphics.setColor(0.5,0.5,0.5)
    love.graphics.draw(IMAGES.button_operate.up, 240-120, 288-48-1)
  end
end


