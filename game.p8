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

tile_info = {
  wall_tile = 0
}

 rock_type = 0
 sissor_type = 1
 paper_type = 2

c_cam_speed = 8

-- variables
state = c_state_menu
player = {
  x = 64,
  y = 64,
  dir = c_dir_left,
  scissors = 0,
  stones = 0,
  papers = 0
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
  end
  update_cam()
end

function update_player()
  if btn(0) and not pixel_is_blocked(player.x - 8, player.y) then
    player.x -= 8
    player.dir = c_dir_left
  end
  if btn(1) and not pixel_is_blocked(player.x + 8, player.y) then
    player.x += 8
    player.dir = c_dir_right
  end
  if btn(2) and not pixel_is_blocked(player.x, player.y - 8) then
    player.y -= 8
    player.dir = c_dir_up
  end
  if btn(3) and not pixel_is_blocked(player.x, player.y + 8) then
    player.y += 8
    player.dir = c_dir_down
  end
end

function update_world()
  foreach(enemies, update_enemy)
end

function update_enemy(enemy)
  x_dist = player.x - enemy.x
  y_dist = player.y - enemy.y
  if abs(x_dist) > abs(y_dist) then
    if x_dist > 0 then enemy.x += 8 else enemy.x -= 8 end
  else
    if y_dist > 0 then enemy.y += 8 else enemy.y -= 8 end
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
   if not is_legal_pixel(x, y) then
      return false
   end
   cellx = flr(x / 8)
   celly = flr(y / 8)
   sprite = mget(cellx, celly)
   return fget(sprite, tile_info.wall_tile)
end

function is_legal_pixel(x, y)
  return not (x < 0 or y < 0 or x > 127 or y > 127)
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
    elseif player.y < cam.y then
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

function cam_at_grid_point()
  return cam.x % 128 == 0 and cam.y % 128== 0
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
  spr(enemy.spr, enemy.x, enemy.y)
end

function draw_player()
  local spr_data = c_player_sprs[player.dir]
  spr(spr_data.spr, player.x, player.y, 1, 1, spr_data.mirror)
end

function draw_menu()
  local spr_scissors = 033
  local spr_stones = 034
  local spr_paper = 035
  rectfill(0, 0, 128, 9, 0)
  spr(spr_scissors, 0, 1)
  print(tostr(player.scissors), 10, 2, 7)
  spr(spr_stones, 16, 1)
  print(tostr(player.stones), 26, 2, 7)
  spr(spr_paper, 31, 1)
  print(tostr(player.papers), 41, 2, 7)
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
3aa99aa35555555555d67d5555d67d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa99aaa5566665555d67d5555d67d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa9aa9aad5dddd5dd5ddddd55ddddd5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99aaaa995566665555d67d5555d67d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99aaaa997566665775d67d5555d67d57000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa9aa9aad5dddd5dd5ddddd55ddddd5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa99aaa5566665555d67d5555d67d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3aa99aa3555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000
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
01 06094344
00 07424344
00 06094344
02 08424344

