
local time = require'time'
local ui = require'ui0'()
require'LuaIRC.irc'

print('startup')

local sleep = require "socket".sleep



ui:add_font_file('media/fonts/amiri-regular.ttf', 'Amiri')


local oauth = require'oauth'

local display = ui.active_display
local config = {
   windowWidth = 225,
   windowHeight = 550,
   windowX = 0,
   windowY = 0,
   windowShrinkHeight = 27,
   editBoxPadding = 10,
   windowPositionPaddingX = 20,
   windowPositionPaddingY = 40,
   selectedColor = '#be0000',
   ircHost = "irc.chat.twitch.tv",
   ircPort = 6667,
   --ircNick = "dude_man_the_fourth",
   ircChannel = '#channel_name',
   ircNick = "User_nick",
   autoExpand = true,
   autoShrink = true,
   autoShrinkTimeout = 5,
   autoShrinkTimeoutOpenBuffer = 10,
   shrinkToTop = false,
}

--start IRC services 

if oauth then
   local server = irc.new{nick = config.ircNick}
   server:connect({nick = config.ircNick, password = oauth, host = config.ircHost, port = config.ircPort})
   server:join(config.ircChannel)
end

config.windowX, config.windowY = (display.w - config.windowWidth - config.windowPositionPaddingX), (display.h - config.windowHeight - config.windowPositionPaddingY)

local win = ui:window{
   --position the window on the bottom left corner of the monitor by default
   x = config.windowX,
   y = config.windowY,

   w = config.windowWidth,
   h = config.windowHeight, 
   
   title = 'TwitchChat',    --titlebar text
   autoquit = true,     --quit the app on close
   topmost = true, --set window to stay on top
   border = false,
   frame = false,
   resizeable = false, --make resizeable?
   --transparent = true,
   --opacity
}
ui:style('window_view', {
   background_color = '#000',
})

mainLayer = ui:layer({parent=win,layer_index=1})

local shrinkState = false
local shrinkButton = ui:button{
   parent = win,
   x = config.windowWidth - 25,
   y = 1,
   text = '  ',       --sized to fit the text by default
}

function shrinkToggle()
   if shrinkState then
      shrinkState = false
      win.h = config.windowHeight
      win.y = config.windowY --win.y - config.windowHeight - config.windowPositionPaddingY
   else
      shrinkState = true
      win.h = config.windowShrinkHeight
      win.y = config.shrinkToTop and win.y or win.y + config.windowHeight - config.windowShrinkHeight
   end
end
function shrinkButton:pressed() --handle button presses
   shrinkToggle()
end


local settingsButton = ui:button{
   parent = win,         
   x = config.windowWidth - 52,
   y = 1,
   text = '  ',       --sized to fit the text by default
   tags = 'settingsButton',
}
function settingsButton:pressed() --handle button presses
   mainLayer.visible = mainLayer.visible == false
   settingsLayer.visible = settingsLayer.visible == false
   if settingsLayer.visible then
      ui:style('button settingsButton', {
         background_color = config.selectedColor,
      })
   else
      ui:style('button settingsButton', {
         background_color = "#444",
      })
   end
end

--style buttons for when mouse is over and no buttons are pressed.
ui:style('button :hot !:active', {
   background_color = config.selectedColor,
})


local chatTextTree = {{
   color = '#26a621',
   'Chat Window'
   }
}
    
    
chatBoxContent = ui:layer({
			layout = 'textbox',
			text_align_x = 'left',
			text_align_y = 'top',
            text = chatTextTree,
            line_spacing = 0.8,
            hardline_spacing = 1,
      })


local chatBox = ui:scrollbox{
      parent = mainLayer,
      x = 0,
      y = 27,
      w = config.windowWidth,
      h = config.windowHeight - 60,
      auto_w = true,
      content = chatBoxContent,
      
   }
   
   ui:style('scrollbox', {
		border_width = 0,
   })
   
   --[[
  local testNick = ui.editbox{
      parent = chatBoxContent, 
      w = 50,
      h = 20, 
      x = 0,
      y = 14,
      text = config.ircNick,
      --text_selectable = false,
      focusable = true,
      text_editable = false,
      tags = 'testNick',
   }
   testNick.w = string.len(testNick.text) * 7.8
   
   ui:style('editbox testNick', {
      background_color = '#222222',
      border_width_bottom = 0,
      border_width_top = 0,
      border_width_right = 0,
      border_width_left = 0,
      text_color = '#e31e00',
      })
   ]]
   
   
local function scroll_to_bottom()
    chatBox.vscrollbar.offset =  chatBox.vscrollbar.content_length
end

chatUpdated = false
local function updateChatbox(nick,txt)
   --chatBoxText = string.format("%s\n%s: %s",chatBoxText, nick, txt)
   --chatBox.content.text = chatBoxText
   table.insert(chatTextTree,{
      color = '#26a621',
      'test',
   })
   chatBoxContent.text = chatTextTree
   chatUpdated = true
end
   
   
if server then
   server:hook("OnChat", function(user, channel, message)
   print(("[%s] %s: %s"):format(channel, user.nick, message))
      updateChatbox(user.nick,message)
      chatUpdated = true
   end)
end






--create the edit box

local editBoxW, editBoxH = config.windowWidth - config.editBoxPadding, 40
local editBoxX, editBoxY = config.windowWidth - editBoxW - (config.editBoxPadding/2), config.windowHeight - (editBoxH - config.editBoxPadding)
local editBox = ui.editbox{
   parent = mainLayer, 
   w = editBoxW, 
   x = editBoxX,
   y = editBoxY,
   cue = ' type to chat',
   text = '',
   text_multiline = false,
   tags = 'editBoxChat',
}
--style edit box
ui:style('editbox editBoxChat', {
   background_color = '#b52525',
   border_color = '#ffffff',
	border_width_top = 1,
	border_width_right = -1,
	border_width_left = -1,
})
ui:style('editbox > cue_layer', {
	text_color = '#000000',
})

local alertBarW, alertBarH = config.windowWidth - 54, 27
local alertBarX, alertBarY = 1, 1
local alertBar = ui.editbox{
   parent = win, 
   w = alertBarW, 
   x = alertBarX,
   y = alertBarY,
   cue = '',
   text = config.ircChannel,
   text_multiline = false,
   --text_selectable = false,
   focusable = true,
   text_editable = false,
   tags = 'alert',
}

--style edit box
ui:style('editbox alert', {
   background_color = '#222222',
   border_color = '#181818',
   border_width_bottom = 0,
   border_width_top = 0,
   border_width_right = 0,
   border_width_left = 0,
   text_color = '#e31e00',
})






settingsLayer = ui:layer{
   parent=win,
   layer_index=1,
   visible=false,
}

local settingsMoveButton = ui:button{
   parent = settingsLayer,         
   x = 5,
   y = 30,
   text = 'Drag to move',       --sized to fit the text by default
}

function settingsMoveButton:mousemove(mx, my)
   if settingsMoveButton.active then
      win.x,win.y = win.x + mx, win.y + my
      config.windowX, config.windowY = win.x,win.y
   end
end





--local alertBarW, alertBarH = config.windowWidth - 54, 27
local settingsX, settingsY = 5, 90
local settingsChecks = {
   {config = "autoExpand", text = 'Auto Expand'},
   {config = "autoShrink", text = 'Auto Shrink'},
   {config = "shrinkToTop", text = 'Shrink To Top'},
}

for i,configToSet in ipairs(settingsChecks) do
   local settingsCheckBox = ui:checkbox{
      parent = settingsLayer,     
      x = settingsX,
      y = settingsY+4,
   }
   settingsCheckBox.checked = config[configToSet.config]

   function settingsCheckBox:checked_changed(v)
      config[configToSet.config] = v
   end
   local settingsCheckText = ui.editbox{
      parent = settingsLayer, 
      x = settingsX + 17,
      y = settingsY,
      cue = '',
      text = configToSet.text,
      text_multiline = false,
      --text_selectable = false,
      focusable = true,
      text_editable = false,
      tags = 'settingsText',
   }
   settingsY = settingsY + 25
end


local settingsTexts = {
   {config = "autoShrinkTimeout", text = 'Auto_Shrink_Timeout', press = function(self)
      local _,_,timeout = string.find(self._parent.text,'(%d+)')
      if timeout then
         config.autoShrinkTimeout = tonumber(timeout)
      else
         self._parent.text = tostring(config.autoShrinkTimeout)
      end
   end},
   
   {config = "autoShrinkTimeoutOpenBuffer", text = 'Timeout_Open_Buffer', press = function(self)
      local _,_,timeout = string.find(self._parent.text,'(%d+)')
      if timeout then
         config.autoShrinkTimeoutOpenBuffer = tonumber(timeout)
      else
         self._parent.text = tostring(config.autoShrinkTimeoutOpenBuffer)
      end
   end},
   
   {config = "ircChannel", cue = 'Channel name', text = 'IRC_reconnect', press = function(self) 
      local channel = self._parent.text
      if server then
         if channel and channel ~= '' then
            server:part(config.ircChannel)
            self._parent.text = string.lower(self._parent.text)--irc channel names are always lower case
            config.ircChannel = self._parent.text
            server:join(config.ircChannel)
            alertBar.text = config.ircChannel
         else
            self._parent.text = config.ircChannel
         end
      end
   end},
   
}
 settingsY = settingsY + 2
for i,configToSet in ipairs(settingsTexts) do

   settingsTexts[configToSet.config] = ui.editbox{
      parent = settingsLayer, 
      x = settingsX,
      y = settingsY,
      text = tostring(config[configToSet.config]),
      cue = configToSet.cue or configToSet.text or '',
      text_multiline = false,
      tags = 'settingsEdit',
   }
   
   settingsY = settingsY + 25
   local settingsButton = ui:button{
      parent = settingsTexts[configToSet.config],         
      x = 5,
      y = 25,
      text = configToSet.text,       --sized to fit the text by default

   }

   settingsButton.pressed = configToSet.press
   settingsTexts[configToSet.config].button = settingsButton
   
   settingsY = settingsY + 25
end










--style edit box
ui:style('editbox settingsText', {
   background_color = '#222222',
   border_color = '#181818',
   border_width_bottom = 0,
   border_width_top = 0,
   border_width_right = 0,
   border_width_left = 0,
   text_color = '#e31e00',
})






local pressedElement

function win:keydown(key)
   if key == 'enter' then
      if settingsLayer.visible then
         local activeElement = win:find('settingsEdit :focused')
         if activeElement[1] then
            activeElement[1].button:pressed()
            pressedElement = activeElement[1]
         end
         
      elseif editBox.text ~= '' then
         if server then server:sendChat(config.ircChannel,editBox.text) end
         updateChatbox(config.ircNick, editBox.text)
         editBox.text = ''
      end
   end
end
function win:keyup(key)
   if key == 'esc' then 
      self:close()
   elseif key == 'enter' then
      if settingsLayer.visible and pressedElement then
         _,_,pressedElement.text = string.find(pressedElement.text,'([^\n])')
      else
         editBox.text = ''
         chatUpdated = true      
      end
   end
end
win:on('closed', function(self) --close handler should do clean up and log close?
   print'Bye!'
end)

local shrinkTimeout = 0
local lastDelta = time.time()
local deltaTime = 0 
local startup = true
function runningLoop()
   while true do
      deltaTime = time.time() - lastDelta
      lastDelta = time.time()
      if chatUpdated then
         chatUpdated = false
         scroll_to_bottom()
         if config.autoExpand and shrinkState then
            shrinkToggle() 
            shrinkTimeout = -config.autoShrinkTimeoutOpenBuffer
         end
      end
      if startup  then 
         startup = false
         chatUpdated = true
      end
      if config.autoShrink then
         if not win.active then
            if shrinkTimeout >= config.autoShrinkTimeout then
               if not shrinkState then shrinkToggle() end
            else
               shrinkTimeout = shrinkTimeout + deltaTime
            end
         else
            shrinkTimeout = 0
         end
      end
      if server then server:think() end
      ui:sleep(0.1)
   end
end


ui:run(runningLoop)

os.exit()