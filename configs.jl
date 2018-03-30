# This file contains the game configs!
# In debug builds, this file is reloaded in real-time -- every
# `config_reload_time_s` seconds, so you test changes on the fly just by
# modifying these constants.
# In release builds, this file is only included once, during compilation, so
# these values are all defined once as globals. 

defaultFontName = "assets/fonts/FiraCode/ttf/FiraCode-Regular.ttf"
defaultFontSize = 26

# Menu constants
kPauseSceneTitleFontSize = 40
kPauseSceneSubtitleFontSize = 30

kMenuButtonFontSize = 20
kKeyButtonFontSize = 16
kMenuButtonColor = SDL2.Color(80, 80, 200, 255)
kKeySettingButtonColor = SDL2.Color(185, 55, 48, 255)

kControlsHeaderFontSize = 15

kProgrammedWithJuliaText = ["Programmed with ", " ", " using Julialang ", ""]
kCopyrightNotices = ["Copyright (c) 2018 @nhdalyMadeThis, LLC.",
                     "Theme music copyright http://www.freesfx.co.uk"]

# Game Rendering
kBackgroundColor = SDL2.Color(210,210,210,255)
kBallColor = SDL2.Color(58, 95, 204, 255)
kPaddleColor = SDL2.Color(203, 60, 51, 255)

# Game constants
paddleSpeed = 1000
paddleTimeToMaxSpeed = 0.15
paddleTimeToDecelerate = 0.05
paddleAccel = paddleSpeed/paddleTimeToMaxSpeed
paddleDeccel = paddleSpeed/paddleTimeToDecelerate
ballSpeed = 350

winningScore = 11

# meta config
config_reload_time_s = 1  # seconds
