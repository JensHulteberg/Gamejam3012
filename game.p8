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
c_state_menu=0
c_state_game=1

-- grid constants
c_grid_cell_size = 8
c_grid_dim = 16

-- variables
state = c_state_menu

-->8
-- game logic functions --

function _init()
  state = c_state_menu
  current_game = c_game_0
end

function _update()
  if state==c_state_game then
    update_game()
  elseif state==c_state_menu then
    update_menu()
  end
end


function update_game()
end

function update_menu()
 if btn(4) then
   state = c_state_game
 end
end
-->8
-- draw functions --

function _draw()
  cls()
  if state==c_state_menu then
    print("welcome to game", 10, 10)
  elseif state==c_state_game then
    print("now in game", 20, 20)
  end
end
__gfx__
00000000099990000999999008880000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009999909999999088555500666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070099999990999555558555555066666ff60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000995555599f55f55855666506666f1f60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000955f5509fffff00555555066fffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700002222200cccccc005555550633333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002222200cccccc005555550033333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000020002000c00c0005000050030000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
