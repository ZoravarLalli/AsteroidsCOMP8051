//
//  ViewController.m
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "ViewController.h"
#import "Vertex.h"
#import "BaseEffect.h"
#import "ShipModel.h"
#import "ProjectileModel.h"
#import "AsteroidModel.h"
#import "BackgroundModel.h"

@interface ViewController ()

@end


// Constants ----------------
const double MIN_SPAWN_DISTANCE = 15;

// Number of hits allowed on screen before spawning stops.
// Size 3 = 7 hits
// Size 2 = 3 hits
// Size 1 = 1 hit
const int ASTEROID_LIMIT = 25;

// ---------------------

@implementation ViewController
{
    BaseEffect *_shader; //Shader controller
    ShipModel *_ship; //Ship model
    BackgroundModel *_background;
    NSMutableArray *_projectiles; //Array for projectiles
    NSMutableArray *_asteroids; //Array for asteroids
    float timeSinceLastAsteroid;
    float xBound, yBound;
    // For sound
    AVAudioPlayer *_music;
    AVAudioPlayer *_playerShot;
    AVAudioPlayer *_asteroidImpact;
    AVAudioPlayer *_rocketThrust;

    UILabel *livesleft;
    UILabel *score;
    UILabel *ingameScore;
    UIView *gameOverContainer;
    
    // For score keeping
    int _highScores[5];
    int currentScore;
    int _hs[5];
    
    // For persisting data
    NSUserDefaults *prefs;
}

//Called when the view is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // For saving between sessions
    prefs = [NSUserDefaults standardUserDefaults];
    
    // Preload the in game sound effects
    _playerShot = [self preloadSound:@"playerShotEdited.wav"];
    _asteroidImpact = [self preloadSound:@"asteroidImpact.wav"];
    _rocketThrust = [self preloadSound:@"thrust.wav"];
    
    //Set OpenGL view
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    //Setup for Gesture listeners
    UIPanGestureRecognizer *panSingleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSinglePanGesture: )];
    panSingleGesture.maximumNumberOfTouches = 1;
    panSingleGesture.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panSingleGesture];
    
    //Setup for buttons
    UIButton *fireButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fireButton.frame = CGRectMake(10, view.frame.size.height-60,50,50);
    [fireButton setImage:[UIImage imageNamed:@"attack_icon.png"] forState:UIControlStateNormal];
    [fireButton addTarget:self action:@selector(fireHandler:) forControlEvents:UIControlEventTouchDown];
    [fireButton setEnabled:YES];
    [self.view addSubview:fireButton];
    
    UIButton *thrustButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thrustButton.frame = CGRectMake(10,view.frame.size.height-130,50,50);
    [thrustButton addTarget:self action:@selector(thrustTouch:) forControlEvents:UIControlEventTouchDown];
    [thrustButton addTarget:self action:@selector(thrustCancel:) forControlEvents:UIControlEventTouchUpInside];
    [thrustButton addTarget:self action:@selector(thrustCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [thrustButton addTarget:self action:@selector(thrustCancel:) forControlEvents:UIControlEventTouchCancel];
    [thrustButton setImage:[UIImage imageNamed:@"thrust_icon.png"] forState:UIControlStateNormal];
    [thrustButton setEnabled:YES];
    [self.view addSubview:thrustButton];
    
    UIImageView *livesBacking = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_backing.png"]];
    [livesBacking setFrame:CGRectMake(5, 25, 100, 25)];
    livesleft = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 25)];
    [livesleft setText:@"Lives: 5"];
    livesleft.font = [UIFont fontWithName:@"Copperplate" size:18];
    [livesleft setTextColor:[UIColor whiteColor]];
    [livesBacking addSubview:livesleft];
    [self.view addSubview:livesBacking];
    
    UIImageView *scoreBacking = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_backing"]];
    [scoreBacking setFrame:CGRectMake(5, 55, 100, 25)];
    ingameScore = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 25)];
    [ingameScore setText:@"Score: 0"];
    ingameScore.font = [UIFont fontWithName:@"Copperplate" size:18];

    [ingameScore setTextColor:[UIColor whiteColor]];
    [scoreBacking addSubview:ingameScore];
    [self.view addSubview:scoreBacking];
    
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width;
    
    gameOverContainer = [[UIView alloc]initWithFrame:CGRectMake(width/5, height/5, width - width/2.5, height * 0.4)];
    
    UIImageView *gameOverBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"window.png"]];
    [gameOverBG setFrame:CGRectMake(0, 0, gameOverContainer.frame.size.width, gameOverContainer.frame.size.height)];
    [gameOverContainer addSubview:gameOverBG];
    
    UILabel *gameOverHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, gameOverContainer.frame.size.width, 20)];
    [gameOverHeader setText:@"Game Over!"];
    [gameOverHeader setTextAlignment:NSTextAlignmentCenter];
    gameOverHeader.font = [UIFont fontWithName:@"Copperplate" size:26];
    [gameOverHeader setTextColor:[UIColor whiteColor]];
    [gameOverContainer addSubview:gameOverHeader];
    
    UIButton *replayButton = [[UIButton alloc]initWithFrame:CGRectMake(gameOverContainer.frame.size.width/2-25,gameOverContainer.frame.size.height-65,50,50)];
    [replayButton setImage:[UIImage imageNamed:@"replay_icon.png"] forState:UIControlStateNormal];
    [replayButton addTarget:self action:@selector(resetGame:) forControlEvents:UIControlEventTouchDown];
    [replayButton setEnabled:true];
    [gameOverContainer addSubview:replayButton];
    
    score = [[UILabel alloc] initWithFrame:CGRectMake(10, gameOverHeader.frame.size.height + 20, gameOverContainer.frame.size.width - 20, gameOverContainer.frame.size.height/2)];
    [score setText:@"High Scores:\r0\r0\r0\r0\r0"];
    [score setTextColor:[UIColor whiteColor]];
    score.font = [UIFont fontWithName:@"Copperplate" size:18];
    [score setNumberOfLines:6];
    [score setTextAlignment:NSTextAlignmentCenter];
    [gameOverContainer addSubview:score];
    
    [gameOverContainer setHidden:true];
    [self.view addSubview:gameOverContainer];
    
    [EAGLContext setCurrentContext:view.context];
    [self setupScene];
}

//Additional setup code
- (void) setupScene
{
    // Start music
    [self playBackgroundMusic:@"05_Chill.wav"];
    
    //Initiate shader
    _shader = [[BaseEffect alloc] initWithVertexShader:@"VertexShader.glsl" fragmentShader:@"FragmentShader.glsl"];
    
    //Initiate ship model
    _ship = [[ShipModel alloc] initWithShader:_shader];
    
    //Setup projection view
    _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), self.view.bounds.size.width/self.view.bounds.size.height, 1, 150);
    
    //Initialize projectile array
    _projectiles = [[NSMutableArray alloc] initWithCapacity:10];
    
    //Initialize asteroid array
    _asteroids = [[NSMutableArray alloc] initWithCapacity:10];
    
    //Initialize score array
    for(int i = 0; i < 5; i++){
        _highScores[i] = 0;
    }
    
    currentScore = 0;
    
    //Set Bounds for screen looping
    xBound = self.view.frame.size.width/20;
    yBound = self.view.frame.size.height/20;
    
    //Initialize asteroid timer
    timeSinceLastAsteroid = 0.0;
    
    _background = [[BackgroundModel alloc] initWithShader:_shader];
    _background.scale = 20;
}

//Called to draw on each frame
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //Set background color
    glClearColor(0/255.0, 180.0/255.0, 180.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //Enable some rendering options
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //Set camera perspective
    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0, 0, -30);
    
    [_background renderWithParentModelViewMatrix:viewMatrix];
    glClear(GL_DEPTH_BUFFER_BIT);
    
    // Update score label
    [ingameScore setText:[NSString stringWithFormat:@"Score: %d", currentScore]];
    
    // Update lives label and listen for gameover
    if(_ship.lives > 0)
    {
        [livesleft setText:[NSString stringWithFormat:@"Lives: %d", _ship.lives]];
        //Set view matrix for ship to be drawn
        [_ship renderWithParentModelViewMatrix:viewMatrix];
        _ship.xBound = xBound;
        _ship.yBound = yBound;
        _ship.asteroids = _asteroids;
    }
    else if(gameOverContainer.isHidden)
    {
        [livesleft setText:[NSString stringWithFormat:@"Lives: %d", _ship.lives]];
        [gameOverContainer setHidden:false];
        
        // Score adjustment
        [self addNewScore:currentScore];
        NSLog(@"%d", _highScores[0]);
        // Print to UILabel
        [score setText:[NSString stringWithFormat:@"High Scores: \r1st:%d\r2nd:%d\r3rd:%d\r4th:%d\r5th:%d", _highScores[0], _highScores[1], _highScores[2], _highScores[3], _highScores[4]]];
        // Save to device
        //[prefs setObject:_highScores forKey:@"highscores"];
    }
            
    //Iterate for projectiles and draw each.
    for(id proj in _projectiles)
    {
        [proj renderWithParentModelViewMatrix:viewMatrix];
    }
    
    //Iterate for asteroids and draw each.
    for(id ast in _asteroids)
    {
        [ast renderWithParentModelViewMatrix:viewMatrix];
    }
}

//Open GL update function
- (void) update
{
    //Call ship's update
    [_ship updateWithDelta:self.timeSinceLastUpdate];
    
    //Call each projectile's update
    for(ProjectileModel *proj in [_projectiles reverseObjectEnumerator])
    {
        [proj updateWithDelta:self.timeSinceLastUpdate];
        if(proj.destroy) [_projectiles removeObject:proj];
    }
    
    //Call each asteroid's update
    for(AsteroidModel *ast in [_asteroids reverseObjectEnumerator])
    {
        [ast updateWithDelta:self.timeSinceLastUpdate];
        if(ast.destroy){
            [self playShotImpact]; // Plays asteroid destruction sound
            currentScore += 1; // Increment score

            if (ast.size > 1) {
                AsteroidModel *newAsteroid = [[AsteroidModel alloc] initWithShader:_shader andSize:ast.size-1];
                newAsteroid.xBound = xBound;
                newAsteroid.yBound = yBound;
                newAsteroid.position = ast.position;
                newAsteroid.forward = GLKVector3MultiplyScalar(GLKVector3Make(ast.forward.y, ast.forward.x, 0), 1.2);
                
                [_asteroids addObject:newAsteroid];
                
                AsteroidModel *newAsteroid2 = [[AsteroidModel alloc] initWithShader:_shader andSize:ast.size-1];
                newAsteroid2.xBound = xBound;
                newAsteroid2.yBound = yBound;
                newAsteroid2.position = ast.position;
                newAsteroid2.forward = GLKVector3MultiplyScalar(GLKVector3Make(ast.forward.y, ast.forward.x, 0), -1.2);
                
                [_asteroids addObject:newAsteroid2];
            }
            
            
            [_asteroids removeObject:ast];
        }
        else if(ast.destroyWithChildren) {
            [_asteroids removeObject:ast];
                    }
    }
    
    //Increment asteroid timer and spawn
    timeSinceLastAsteroid += self.timeSinceLastUpdate;
    if(timeSinceLastAsteroid >= 5) [self spawnAsteroid];
    
    //NSLog(@"proj: %d", [_projectiles count]);
    //NSLog(@"ship: %f , %f", _ship.position.x, _ship.position.y);
}

//Pan handler for rotating the ship
- (void) handleSinglePanGesture:(UIPanGestureRecognizer *) sender
{
    if(sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [sender velocityInView:sender.view];
        float x = velocity.x/sender.view.frame.size.width;
        float y = velocity.y/sender.view.frame.size.height;
        [_ship rotate:(y + x)/10];
    }
}

//Handler for fire button
- (void) fireHandler : (id) sender
{
    // Play shot audio
    [self playPlayerShot];
    
    //Create new projectile model, set forward and position vectors, and add to array
    ProjectileModel *newProjectile = [[ProjectileModel alloc] initWithShader:_shader];
    newProjectile.forward = _ship.forward;
    newProjectile.position = _ship.position;
    newProjectile.asteroids = _asteroids;
    newProjectile.xBound = self.view.frame.size.width/20;
    newProjectile.yBound = self.view.frame.size.height/20;
    [_projectiles addObject:newProjectile];
}

//Handler for touching thrust button
- (void) thrustTouch : (id) sender
{
    [self playThrust]; // Start rocket sound player
    [_ship thrustToggle];
    NSLog(@"START THRUST");
}

//Handler for canceling thrust
- (void) thrustCancel : (id) sender
{
    [self pauseThrust]; // Pause rocket sound player
    _ship.thrust = false;
    NSLog(@"PAUSE THRUST");
}

- (void) resetGame : (id) sender
{
    NSLog(@"reset game");
    [_ship resetPos];
    
    for (AsteroidModel* o in _asteroids) {
        o.destroyWithChildren = true;
    }
    [gameOverContainer setHidden:true];
    
    timeSinceLastAsteroid = 0.0;
    currentScore = 0;
    _ship.lives = 5;
    
}

- (void) spawnAsteroid
{
    //Reset timer, create new asteroid, set data and add to array
    timeSinceLastAsteroid = 0.0;
    int asteroidCount = 0;
    for (AsteroidModel* o in _asteroids) {
        asteroidCount += pow(2, o.size) - 1;
    }
    
    
    if(asteroidCount >= ASTEROID_LIMIT) return;
    NSLog(@"%i",asteroidCount);
    AsteroidModel *newAsteroid = [[AsteroidModel alloc] initWithShader:_shader];
    newAsteroid.xBound = xBound;
    newAsteroid.yBound = yBound;
    
    
    double randX, randY, distX, distY, distance;
    
    // loop until distance is far enough
    do {
        //get a random position
        randX = ((double)arc4random_uniform(xBound) - xBound/2);
        randY = ((double)arc4random_uniform(yBound) - yBound/2);
        
        // get distance between ship and new position
        distX = fabs(randX - _ship.position.x);
        distY = fabs(randY - _ship.position.y);
        
        // if distance is larger than half the screen,
        // reduce the distance by the size of the entire screen to account for looping.
        // no need to convert to abs again because it's squared after.
        distX = distX < xBound ? distX : distX - (xBound * 2);
        distY = distY < yBound ? distY : distY - (yBound * 2);
    
        // square both and root the result.
        distance = sqrt(pow(distX, 2.0) + pow(distY, 2.0));
        
        //NSLog(@"distance %f", distance);

    } while (distance < MIN_SPAWN_DISTANCE);
    
    //NSLog(@"asteroid: %f , %f", randX, randY);
    
    newAsteroid.position = GLKVector3Make(randX, randY, 0);
    [_asteroids addObject:newAsteroid];
}


// SOUND
- (void)playBackgroundMusic:(NSString *)filename{
    _music = [self preloadSound:filename];
    _music.numberOfLoops = 1;
    _music.volume = 0.5;
    [_music play];
}
- (AVAudioPlayer *)preloadSound:(NSString *)filename{
    // Convert filename into NS URL
    NSURL  *URL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    // Create audio player using the url
    AVAudioPlayer *prepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:nil];
    [prepPlayer prepareToPlay]; // Prepares and loads it to play
    return prepPlayer;
}
- (void)playPlayerShot{
    [_playerShot play];
}
- (void)playShotImpact{
    [_asteroidImpact play];
}
- (void)playThrust{
    _rocketThrust.numberOfLoops = -1;
    [_rocketThrust play];
}
- (void)pauseThrust{
    [_rocketThrust pause];
}

// Adds current score to highscores
- (void)addNewScore:(int) newScore{
    // If the current score is higher than any of the existing highscores, it will replace it.
    for (int i = 0; i < 5; i++){
        if(newScore > _highScores[i]){
            _highScores[i] = newScore;
            break; // break because only want to add it once.
        }
    }
}

@end
