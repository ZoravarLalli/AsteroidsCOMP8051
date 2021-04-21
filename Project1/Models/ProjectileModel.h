//
//  CubeModel.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "Model.h"
#import "EnemyModel.h"

@interface ProjectileModel : Model

@property GLKVector3 forward;
@property NSMutableArray *asteroids;
@property EnemyModel *enemy;
@property float xBound;
@property float yBound;
@property bool destroy;
@property NSTimeInterval timeAlive;

- (instancetype) initWithShader :(BaseEffect *)shader;

@end
