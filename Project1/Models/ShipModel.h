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

- (instancetype) initWithShader :(BaseEffect *)shader;
- (void) thrustToggle;
- (void) rotate : (float) angle;
- (void) resetPos;

@end
