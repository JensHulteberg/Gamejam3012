pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- cool game --
-- by fabian, jens, branne --
--    and jacob --

-- "why then the world's mine
--  oyster,
--  which i with sword will
--  open."

-- constants and variables

-- constants
c_dir_none = 0
c_dir_left = 1
c_dir_right = 2
c_dir_up = 3
c_dir_down = 4

c_state_menu = 0
c_state_game = 1

c_music_game = 00

-- indexes represent directions
c_player_sprs = {
  {spr=019, mirror=true},
  {spr=019, mirror=false},
  {spr=021, mirror=false},
  {spr=017, mirror=false}
}

-- RPS sprites
spr_scissors = 033
spr_rocks = 034
spr_paper = 035

items = {
  {
    name = "rock",
    x = 16,
    y = 16
  },
  {
    name = "paper",
    x = 32,
    y = 32
  },
  {
    name = "scissor",
    x = 40,
    y = 40
  }
}

tile_info = {
  wall_tile = 0
}

c_rock_type = 0
c_paper_type = 1
c_scissor_type = 2


c_cam_speed = 8

-- variables
state = c_state_menu
player = {
  x = 64,
  y = 64,
  dir = c_dir_left,
  rocks = 0,
  papers = 0,
  scissors = 0,
  current_weapon = c_rock_type
}
enemy = {x = 32, y = 32, type = rock_type, spr = 003}
enemies = {enemy}

-->8
-- game logic functions --

function new_cam()
  return {
    x = 0,
    y = 0,
    moving = false,
    dir = c_dir_none
  }
end

function _init()
  state = c_state_menu
  current_game = c_game_0
  cam = new_cam()
end

function _update()
  if state==c_state_game then
    update_game()
  elseif state==c_state_menu then
    update_menu()
  end
end


function update_game()
  if btnp(0) or btnp(1) or btnp(2) or btnp(3) or btnp(4) or btnp(5) then
    update_player()
    update_world()
    check_if_on_item()
  end
  update_cam()
end

function update_player()
  if btnp(0) and not pixel_is_blocked(player.x - 8, player.y) then
    player.x -= 8
    player.dir = c_dir_left
  elseif btnp(1) and not pixel_is_blocked(player.x + 8, player.y) then
    player.x += 8
    player.dir = c_dir_right
  elseif btnp(2) and not pixel_is_blocked(player.x, player.y - 8) then
    player.y -= 8
    player.dir = c_dir_up
  elseif btnp(3) and not pixel_is_blocked(player.x, player.y + 8) then
    player.y += 8
    player.dir = c_dir_down
  end
  if btn(4) then
    throw_projectile()
  end
  if btn(5) then
    player.current_weapon = (player.current_weapon + 1) % 2
  end
end

function check_if_on_item()
  for i in all(items) do
    if player.x == i.x and player.y == i.y then
      if i.name == "rock" then
        player.rocks += 1
      end
      if i.name == "paper" then
        player.papers += 1
      end
      if i.name == "scissor" then
        player.scissors += 1
      end
      del(items, i)
    end
  end
end

function update_world()
  foreach(enemies, update_enemy)
end

function update_enemy(enemy)
  x_dist = player.x - enemy.x
  y_dist = player.y - enemy.y
  tmp ={
  x = enemy.x,
  y = enemy.y
  }
  if abs(x_dist) > abs(y_dist) then
    if x_dist > 0 then tmp.x += 8 else tmp.x -= 8 end
  else
    if y_dist > 0 then tmp.y += 8 else tmp.y -= 8 end
  end
  if not pixel_is_blocked(tmp.x, tmp.y) then
     enemy.x = tmp.x
     enemy.y = tmp.y
  end
end

function update_menu()
 if btn(4) then
   init_game()
 end
end

function init_game()
  music(c_music_game)
  state = c_state_game
end

-- checks if the x, y pixel position is blocked by a wall
function pixel_is_blocked(x, y)
  cellx = flr(x / 8)
  celly = flr(y / 8)
  sprite = mget(cellx, celly)
  return fget(sprite, tile_info.wall_tile)
end

function update_cam()
  cam_transition_start()

  if cam.moving then
    move_cam()
  end

  cam_transition_stop()
end

function cam_transition_start()
  if not cam.moving then
    if player.x < cam.x then
      cam.moving = true
      cam.dir = c_dir_left
    elseif player.x >= cam.x + 128 then
      cam.moving = true
      cam.dir = c_dir_right
    elseif player.y < cam.y + 8 then
      cam.moving = true
      cam.dir = c_dir_up
    elseif player.y >= cam.y + 128 then
      cam.moving = true
      cam.dir = c_dir_down
    end
  end
end

function move_cam()
  if cam.dir == c_dir_left then
    cam.x -= c_cam_speed
  elseif cam.dir == c_dir_right then
    cam.x += c_cam_speed
  elseif cam.dir == c_dir_up then
    cam.y -= c_cam_speed
  elseif cam.dir == c_dir_down then
    cam.y += c_cam_speed
  end
end

function cam_transition_stop()
  if cam_at_grid_point() then
    cam.moving = false
  end
end

function throw_projectile()
  if player.current_weapon == 0 and player.rocks > 0 then
    -- throw rock
    player.rocks -= 1
  elseif player.current_weapon == 1 and player.papers > 0 then
    -- throw paper
    player.papers -= 1
  elseif player.current_weapon == 2 and player.scissors > 0 then
    -- throw scissor
    player.scissors -= 1
  end
end

function cam_at_grid_point()
  return cam.x % 128 == 0 and cam.y % 120== 0
end
-->8
-- draw functions --

function _draw()
  cls()
  if state==c_state_menu then
    print("welcome to game", 10, 10)
    if pixel_is_blocked(9, 9) then
       print("collision is broken", 10, 20)
    end
  elseif state==c_state_game then
    draw_game()
  end
end

function draw_game()
  camera(cam.x, cam.y)
  map(0, 0, 0, 0, 128, 128)

  print("now in game", 20, 20)
  draw_player()
  draw_menu()
  draw_items()
  spr(enemy.spr, enemy.x, enemy.y)
end

function draw_player()
  local spr_data = c_player_sprs[player.dir]
  spr(spr_data.spr, player.x, player.y, 1, 1, spr_data.mirror)
end

function draw_menu()
  rectfill(0, 0, 128, 9, 0)
  spr(spr_rocks, 0, 1)
  print(tostr(player.rocks), 10, 2, 7)
  spr(spr_paper, 16, 1)
  print(tostr(player.papers), 26, 2, 7)
  spr(spr_scissors, 31, 1)
  print(tostr(player.scissors), 41, 2, 7)
end

function draw_items()
  for i in all(items) do
    if i.name == "rock" then
      spr(spr_rocks, i.x, i.y)
    end
    if i.name == "scissor" then
      spr(spr_scissors, i.x, i.y)
    end
    if i.name == "paper" then
      spr(spr_paper, i.x, i.y)
    end
  end
end

__gfx__
00000000099990000999999008880000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009999909999999088555500666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070099999990999555558555555066666ff60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000995555599f55f55855666506666f1f60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000955f5509fffff00555655066fffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700002222200cccccc005555550633333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002222200cccccc005555550033333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000020002000c00c0005000050030000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000022220000000000002222000000000000222200000000000000cc000090909000000000000000000000000000000000000000000000000000000000
000000000eeeeee0002222000eeeeee0002222000eeeeee000222200000c5c000099999000000000000000000000000000000000000000000000000000000000
00000000e22cfc200eeeeee002e22cf00eeeeee002222e200eeeeee0000ccc9907fffff000000000000000000000000000000000000000000000000000000000
00000000e222f220e22cfc200e2222f002e22cf0022222e002222e20c0cccc00007ffff000000000000000000000000000000000000000000000000000000000
0000000002222220e222f220022222200e2222f002222220022222e0ccccccc000c7777000000000000000000000000000000000000000000000000000000000
0000000002f2222f02f2222f0222f2200222f2200222222002222220ccccccc000ccccc000000000000000000000000000000000000000000000000000000000
000000000222222002222220022222200222222002222220022222200cccccc000ccccc000000000000000000000000000000000000000000000000000000000
00000000020000200200002002000020020000200200002002000020000909000040004000000000000000000000000000000000000000000000000000000000
00000000099909990dddd00000007700999009990dddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090909090ddd6dd000777770911991190ddd6dd000077877000000000000000000000000000000000000000000000000000000000000000000000000
0000000009090909dd666ddd0777777791899819dd866d8d00777770000000000000000000000000000000000000000000000000000000000000000000000000
0000000000996990d6dddd5d7777777709999990d618d81d07877700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000516006d6dddd567777776005566006d6dddd577776000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000056600d6ddd5d50677776005500660d887888577666667000000000000000000000000000000000000000000000000000000000000000000000000
00000000000566000d6ddd5000677600550000660d78875007776670000000000000000000000000000000000000000000000000000000000000000000000000
000000000000600000dd5500000660005000000600dd550000077700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055d57d555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005555555555d67d5555d67d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000056d67d65d5ddddd55ddddd5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000056d67d6555d67d5555d67d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000056d67d6575d67d5555d67d57000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000056d67d65d5ddddd55ddddd5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005555555555d67d5555d67d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055d67d5555d67d5555d67d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa33aa95555555555d67d5555d67d55555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aaaaaa95566665555d67d5555d67d55556666550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a9aaaa9ad5dddd5dd5ddddd55ddddd5d95dddd590000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa9999aa5566665555d67d5555d67d55a566665a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa9999aa7566665775d67d5555d67d57a566665a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a9aaaa9ad5dddd5dd5ddddd55ddddd5d95dddd590000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aaaaaa95566665555d67d5555d67d55556666550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa33aa9555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000101010000000000000000000000000001010101000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
6161616161616161616161616161616161616161616161616161616161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606161616160606060606060606161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606161616060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606161616060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606161606060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606161606060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606161606060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606161606060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606161606060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606060606060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606060606060606060606060606061616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606060606060606060606060606061616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606060606060606060606060606161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606160606060606060606060606161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6160606060606060606060606060606161616060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161616161616161616161616161616161616161606060606060606060606161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161616161616161616161616161616161616161616060606060606060606061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161616160606060606060606060606060606161616160606060606060606061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161606060606060606060606060606060606061616161606060606060606061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161606060606060606060606060606060606060606161606060606060606061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161606060606060606060606060606060606060606060606060606060606061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161606060606060606060606060606060606060606060606060606060606161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161606060606060606060606060606060606060606060606060606060606161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161606060606060606060606060606060606060606060606060606060606161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161606060606060606060606060606060606060606060606060606060606161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161606060606060606060606060606060606060606060606060606060606161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161606060616161616160606060606060606060606060606060606060616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161616161616161616161616161616161616160606060606060606061616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161616161616161616161616161616161616161616060606161616161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161616161616161616161616161616161616161616161616161616161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000707000000000000000007070000000000000000070700707400000000000000000000000000000007070000000000000000070700000000000000000707007074000000000002070020740000000000
01140000131400000015140000001614000000161401613016120161150000000000000000000000000000001314000000151400000016140000001a1401a1301a1201a115181401813018120181150000000000
011400001a140000001c140000001d140000001d1401d1301d1201d1150000000000000000000000000000001a140000001c140000001d14000000211402113021120211101f1401f1301f1201f1100000000000
011400002414024144221402214421140211441f1401f1301f1201f1150000000000000000000000000000001a1401a1441c1401c1441d1401d144211402113021120211151f1401f1301f1201f1150000000000
011400002414024144221402214421140211441f1401f1301f1201f115000000000000000000000000000000221402214421140211441f1401d144211402113021120211151f1401f1301f1201f1150000000000
01140000050700000000000000000507000000000000000007070070740000000000000000000000000000000c070000000000000000090700000000000000000507005074000000000000000000000000000000
011400000507000000000000000005070000000000000000070700707400000000000000000000000000000002070000000000002070000000000005070050500504005030050200501500000000000000000000
011400000507000000000000000005070000000000000000070700707400000000000000000000000000000002070000000000002070000000000000070000500004000030000200001500000000000000000000
011400002112221132211422113221122211152112221135221222213222142221422214222132221222211528122281322612226132241222413221122211322113221132211322113221132211322112221115
011400002414024144221402214421140211441f1401f1301f1201f115000000000000000000000000000000221402214421140211441f1401d144211402113021120211151f1401f1301f1201f1152112221135
__music__
00 01024344
00 01024344
00 01034344
00 01034344
00 01044344
00 01054344
00 01044344
00 010a4344
00 06094344
00 07424344
00 06094344
02 08424344

