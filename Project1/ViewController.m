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

@interface ViewController ()

@end

@implementation ViewController
{
    BaseEffect *_shader; //Shader controller
    ShipModel *_ship; //Ship model
    NSMutableArray *_projectiles; //Array for projectiles
    NSMutableArray *_asteroids; //Array for asteroids
    float timeSinceLastAsteroid;
    
    // For sound
    AVAudioPlayer *_music;
    AVAudioPlayer *_playerShot;
    AVAudioPlayer *_asteroidImpact;
    AVAudioPlayer *_playerDeath;
    AVAudioPlayer *_rocketThrust;
}

//Called when the view is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Preload the in game sound effects
    _playerShot = [self preloadSound:@"playerShotEdited.wav"];
    _playerDeath = [self preloadSound:@"playerDeath.wav"];
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
    [fireButton setTitle:@"F" forState:UIControlStateNormal];
    [fireButton setBackgroundColor:[UIColor redColor]];
    [fireButton addTarget:self action:@selector(fireHandler:) forControlEvents:UIControlEventTouchDown];
    [fireButton setEnabled:YES];
    [self.view addSubview:fireButton];
    
    UIButton *thrustButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thrustButton.frame = CGRectMake(10,view.frame.size.height-120,50,50);
    [thrustButton setTitle:@"T" forState:UIControlStateNormal];
    [thrustButton setBackgroundColor:[UIColor greenColor]];
    [thrustButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [thrustButton addTarget:self action:@selector(thrustTouch:) forControlEvents:UIControlEventTouchDown];
    [thrustButton addTarget:self action:@selector(thrustCancel:) forControlEvents:UIControlEventTouchUpInside];
    [thrustButton addTarget:self action:@selector(thrustCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [thrustButton setEnabled:YES];
    [self.view addSubview:thrustButton];
    
    [EAGLContext setCurrentContext:view.context];
    [self setupScene];
}

//Additional setup code
- (void) setupScene
{
    // Start music
    //[self playBackgroundMusic:@"05_Chill.wav"];
    
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
    
    //Initialize asteroid timer
    timeSinceLastAsteroid = 0.0;
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
    
    //Set view matrix for ship to be drawn
    [_ship renderWithParentModelViewMatrix:viewMatrix];
    _ship.xBound = self.view.frame.size.width/20;
    _ship.yBound = self.view.frame.size.height/20;
        
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
            [_asteroids removeObject:ast];
        }
    }
    
    //Increment asteroid timer and spawn
    timeSinceLastAsteroid += self.timeSinceLastUpdate;
    if(timeSinceLastAsteroid >= 5) [self spawnAsteroid];
    
    NSLog(@"proj: %d", [_projectiles count]);
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

- (void) spawnAsteroid
{
    //Reset timer, create new asteroid, set data and add to array
    timeSinceLastAsteroid = 0.0;
    if([_asteroids count] >= 10) return;
    AsteroidModel *newAsteroid = [[AsteroidModel alloc] initWithShader:_shader];
    newAsteroid.xBound = self.view.frame.size.width/20;
    newAsteroid.yBound = self.view.frame.size.height/20;
    double randX = ((double)arc4random_uniform(newAsteroid.xBound) - newAsteroid.xBound/2);
    double randY = ((double)arc4random_uniform(newAsteroid.yBound) - newAsteroid.yBound/2);
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
- (void)playPlayerDeath{
    [_playerDeath play];
}
- (void)playThrust{
    _rocketThrust.numberOfLoops = -1;
    [_rocketThrust play];
}
- (void)pauseThrust{
    [_rocketThrust pause];
}

@end
