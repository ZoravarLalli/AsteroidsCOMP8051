
#import "ViewController.h"
#import "GameScene.h"
#import "MenuScene.h"

@interface ViewController ()

@end

typedef enum
{
    MENU,
    GAME,
} GameState;

@implementation ViewController
{
    GameScene *gameScene;
    MenuScene *menuScene;
    GameState state;
}

//Called when the view is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setExclusiveTouch:NO];
    
    menuScene = [[MenuScene alloc] loadScene:(GLKView *)self.view parentController:self];
    state = MENU;
}

//Called to draw on each frame
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if(state == MENU) [menuScene renderScene];
    else if(state == GAME) [gameScene renderScene];
}

//Open GL update function
- (void) update
{
    if(state == MENU) [menuScene updateScene:self.timeSinceLastUpdate];
    else if(state == GAME) [gameScene updateScene:self.timeSinceLastUpdate];
}

//Change the scene state, called from game scenes
- (void) loadNewScene
{
    for(UIView *subView in self.view.subviews) [subView removeFromSuperview];
    if(state == MENU)
    {
        gameScene = [[GameScene alloc] loadScene:(GLKView *)self.view parentController:self];
        state = GAME;
    }
    else if (state == GAME)
    {
        menuScene = [[MenuScene alloc] loadScene:(GLKView *)self.view parentController:self];
        state = MENU;
    }
}

@end
