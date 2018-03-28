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
kCopyrightNotices = ["Copyright 2018 @nhdalyMadeThis, llc.",
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
