//
//  CubeModel.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "Model.h"

@interface AsteroidModel : Model

@property GLKVector3 forward;
@property float xBound;
@property float yBound;
@property bool destroy;

- (instancetype) initWithShader :(BaseEffect *)shader;

@end
