defaultFontName = "/Users/daly/Documents/developer/fonts/press-start-2p/PressStart2P-Regular.ttf"
defaultFontSize = 16

# Menu constants
kPauseSceneTitleFontSize = 35
kPauseSceneSubtitleFontSize = 26

kMenuButtonFontSize = 12
kKeyButtonFontSize = 10
kMenuButtonColor = SDL2.Color(80, 80, 200, 255)
kKeySettingButtonColor = SDL2.Color(185, 55, 48, 255)

kControlsHeaderFontSize = 10

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
