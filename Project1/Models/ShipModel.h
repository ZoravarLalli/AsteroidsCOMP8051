//
//  CubeModel.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "Model.h"

#import "EnemyModel.h"
@import AVFoundation;

@interface ShipModel : Model

@property GLKVector3 forward;
@property NSMutableArray *asteroids;
@property EnemyModel *enemy;
@property bool thrust;
@property float xBound;
@property float yBound;
@property int lives;
@property NSTimeInterval invincible;
@property bool turningLeft;
@property bool turningRight;
@property bool powered;

- (instancetype) initWithShader :(ShaderController *)shader;
- (void) thrustToggle;
- (void) rotate : (float) angle;
- (void) resetPos;
- (void) setRotateLeft: (bool) toggle;
- (void) setRotateRight: (bool) toggle;
@end
