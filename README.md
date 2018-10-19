Divoom Timebix/Aurabox command reference

Switch Screen: 45
  -> Clock: 00
    -> Format 12/24h (optional): 00 - 01
    -> Color as rgb (optional): 000000 - FFFFFF
    
  -> Temperature: 01
    -> Format Celsius/Fahrenheit (optional): 00 - 01
    -> Color as rgb (optional): 000000 - FFFFFF
  
  -> Switchoff Screen: 02
  
  -> Animation (hardcoded): 03
    -> Type: 00 - 06
    
  -> Equalizer: 04
    -> Type: 00 - 06
      -> Type 0 lines as rgb (optional): 000000 - FFFFFF
      -> Type 0 spikes as rgb (optional): 000000 - FFFFFF
  
  -> Image/Animation (preloaded within the app): 05
  
  -> Stopwatch: 06
    -> Control Halt/Reset (optional): 00 (Halt), 02 (Reset)
    
  -> Scoreboard: 07
    -> Control lower (optional): 0000 - 00FF
    -> Control upper (optional): 0000 - 00FF
    (needs further investigation because higher values than 255 are not possible at the moment)
    
Set Brightness: 32 or 74
  -> Level (0 = off, 01 - FF = brightness level): 00 - FF
  
Set Time: 18
  -> Year (XX = year % 100, YY = year / 100): XXYY
  -> Month: XX
  -> Day: XX
  -> Hours: XX
  -> Minutes: XX
  -> Seconds: XX
  
Set Volume: 08
  -> Level: 01 - 64
  
Get Volume: 09
  -> Level
  
Set FM Radio (untested!): 05
  -> State (on = 01, off = 00): 00 - 01
  -> Frequency (100.3 Mhz = YYX.X = 030A): XXYY
  
Get FM Radio Frequency: 60
  -> Frequency (100.3 Mhz = YYX.X = 030A): XXYY
  
Set FM Radio Frequency: 61
  -> Frequency (100.3 Mhz = YYX.X = 030A): XXYY
  
Set Mute: 0A
  -> State (on = 00, off = 01): 00 - 01
  
Get Mute: 0B
  -> State (on = 00, off = 01)
  
Set Image: 44000A0A04
  -> Data (Timebox): RGB (R = 4bit, G = 4bit, B = 4bit) => RGBRGB 2 pixels encoded into 2 bytes of data
  -> Data (Aurabox): Color Index (4bit per pixel) => 2 pixels encoded into 1 byte of data

Set Animation: 49000A0A04
  -> Frame Number: 00 - FF
  -> Time Delay: 00 - FF
  -> Data (Timebox): RGB (R = 4bit, G = 4bit, B = 4bit) => RGBRGB 2 pixels encoded into 2 bytes of data
  -> Data (Aurabox): Color Index (4bit per pixel) => 2 pixels encoded into 1 byte of data

Set Wakeup Call: 43
  -> Number: 00 - 02
  -> State (on = 01, off = 00): 00 - 01
  -> Hour: XX
  -> Minute: XX
  -> Day (bitcoded in the following order (highest bit always 0): Sat, Fri, Thu, Wed, Tue, Mon, Sun): XX
  -> Scene: XX
  -> Unknown: 010000
  -> Volume Level: 01 - 64
  
Set Notification: 50
  -> Type: 00 - FF
  
Set Calendar or Appointment Planer: 54
  -> needs further investigation
  
Screen Off: 41XX or 62XX
  
Show/Set Stopwatch/Scoreboard: 71
  -> Type (00 = Stopwatch, 01 = Scoreboard): 00 - 01
  -> strange behaviour (needs further investigation)
  
Set Game: A0
  -> State (on = 01, off = 00): 00 - 01
  -> Type: XX
  -> Control???
  
Set Talking Faces: A1
  -> State (on = 01, off = 00): 00 - 01
  -> Type (optional): XX

Set Calendar: 54
  -> Index: 00 - FF
  -> State (on = 01, off = 00): 00 - 01
  -> Month: XX
  -> Day: XX
  -> Hour: XX
  -> Minute: XX
  -> Unknown: 01
  -> Titel (max 15 Chars (unicode UTF-16BE), XX = high byte, YY = low byte): XXYYXXYYXXYYXXYYXXYYXXYYXXYYXXYYXXYYXXYYXXYYXXYYXXYYXXYYXXYY0000
  
Set Calendar Picture: 55
  -> Index: 00 - FF
  -> State (on = 01, off = 00): 00 - 01
  -> Static data: 000A
  -> Data (Timebox): RGB (R = 4bit, G = 4bit, B = 4bit) => RGBRGB 2 pixels encoded into 2 bytes of data
  -> Data (Aurabox): Color Index (4bit per pixel) => 2 pixels encoded into 1 byte of data
  
Clear Calendar: 54
  -> Index: 00 - FF
  -> Unknown: 0002010C00000000000000000000000000000000000000000000000000000000000000000000
  
Get Calendar: 53

Set Weather: 5F
  -> Temperature: 00 - FF
  -> Animation (00, >=13 = special demo mode?): 00 - FF