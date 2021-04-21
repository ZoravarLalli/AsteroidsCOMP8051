//
//  EnemyModel.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "Model.h"

@interface EnemyModel : Model

@property GLKVector3 forward;
@property float xBound;
@property float yBound;
@property bool destroy;
@property NSTimeInterval timeToChange;

- (instancetype) initWithShader :(BaseEffect *)shader;

@end
