
#import "Model.h"
#import "ShipModel.h"

@interface PowerupModel : Model

@property GLKVector3 forward;
@property float xBound;
@property float yBound;
@property bool destroy;
@property ShipModel *_ship;

- (instancetype) initWithShader :(ShaderController *)shader ship : (ShipModel *) ship;

@end
