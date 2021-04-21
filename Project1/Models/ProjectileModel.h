
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

- (instancetype) initWithShader :(ShaderController *)shader;

@end
