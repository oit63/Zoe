#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"

@interface GameLayer : Layer {
}
- (void)addBackground;
- (void)createBoundingBox;
- (void)addGameShapes;
- (void)setupCollisionHandlers;
- (void)setupPhysicalProperties;
- (void)setupMouseHandler;
- (void)holeInOne;
- (cpBody *)addSpriteNamed:(NSString *)name x:(float)x y:(float)y type:(unsigned int)type;

@end
