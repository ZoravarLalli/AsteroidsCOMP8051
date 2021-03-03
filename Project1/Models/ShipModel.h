//
//  CubeModel.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "Model.h"

@interface ShipModel : Model

@property GLKVector3 forward;
@property bool thrust;
@property float xBound;
@property float yBound;

- (instancetype) initWithShader :(BaseEffect *)shader;
- (void) thrustToggle;
- (void) rotate : (float) angle;

@end
