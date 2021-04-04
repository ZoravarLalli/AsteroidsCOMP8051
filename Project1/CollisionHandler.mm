//
//  CollisionHandler.m
//  Project1
//
//  Created by Kris Olsson on 2021-04-03.
//

#import "CollisionHandler.h"

#include <Box2D/Box2D.h>

#pragma mark - Box2D contact listener class
class CContactListener : public b2ContactListener
{
    public :
    void BeginContact(b2Contact* contact) {};
    void EndContact(b2Contact* contact) {};
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
    {
        b2WorldManifold worldManifold;
        contact->GetWorldManifold(&worldManifold);
        b2PointState state1[2], state2[2];
        b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
        if (state2[0] == b2_addState)
        {
            // Use contact->GetFixtureA()->GetBody() to get the body
            b2Body* bodyA = contact->GetFixtureA()->GetBody();
            CollisionHandler *parentObj = (__bridge CollisionHandler *)(bodyA->GetUserData());
            // Call RegisterHit (assume CBox2D object is in user data)
            [parentObj RegisterHit];
        }
    }
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {};
};

@interface CollisionHandler ()
{
    struct b2Vec2 *gravity;
    struct b2World *world;
    struct b2BodyFeg *groundBodyDef;
    struct b2Body *groundBody;
    struct b2PolygonShape *groundBox;
    struct b2Body *ship;
    CContactListener *contactListener;
}

@end

@implementation CollisionHandler

- (instancetype) init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

- (void) RegisterHit
{
    NSLog(@"Hey, a hit!");
}

@end
