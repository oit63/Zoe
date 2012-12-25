#import "GameLayer.h"
#import <AudioToolbox/AudioServices.h>

// padding for position mallet relative to finger
int finger_padding = 30;
int fat_fingers_offset = 40;

void *mainLayer;
cpVect startPoint;
cpSpace *space;
cpBody *staticBody;
cpBody *player;
cpBody *ball;
cpBody *obstacle1;
cpBody *obstacle2;
cpBody *obstacle3;
cpMouse *playerMouse;
Sprite *holeInOneBG;

// collision types
enum {
  kColl_Ball,
  kColl_Vertical,
  kColl_Horizontal,
  kColl_Player
};

#define GOAL_MARGIN 145

void resetPosition(cpBody *ball) {
	cpBodyResetForces(ball);
  ball -> v = cpvzero;
  ball -> f = cpvzero;
  ball -> t = 0;
  ball -> p = startPoint;
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

static void eachShape(void *ptr, void* unused){
  cpShape *shape = (cpShape*) ptr;
  Sprite *sprite = shape->data;
  if(sprite) {
    cpBody *body = shape->body;
    [sprite setPosition: cpv(body->p.x, body->p.y)];
  }
}
static int holeInOne(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data){
  GameLayer *gameLayer = (GameLayer *) mainLayer;
	[gameLayer holeInOne];
  return 0;
}

static int restart(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data){
  cpBody *ball = (cpBody*) data;
	resetPosition(ball);
  return 0;
}

@implementation GameLayer

-(id) init {
  [super init];
  srand([[NSDate date] timeIntervalSince1970]);
  cpInitChipmunk();
  isTouchEnabled = YES;
  mainLayer = self;

	// set up the space
  staticBody = cpBodyNew(INFINITY, INFINITY);
  space = cpSpaceNew();
  space->elasticIterations = space->iterations;
  cpSpaceResizeStaticHash(space, 20.0, 999);
  space->gravity = cpvzero;
      
  [self addBackground];
  [self createBoundingBox];
  [self addGameShapes];
  [self setupCollisionHandlers];
  [self setupPhysicalProperties];
  [self setupMouseHandler];
  [self schedule: @selector(step:)];
  [self schedule: @selector(ballOutOfRangeCheck:) interval:1];  
  
  return self;
}

- (void)addBackground
{
	Sprite *bg = [Sprite spriteFromFile:@"grass.png"];
  [bg setPosition:cpv(160,240)];
  [self add: bg z:0];
}

- (void)createBoundingBox
{
  cpShape *shape;
  
  CGRect wins = [[Director sharedDirector] winSize];
  startPoint = cpv(160,120);
  
  // make bounding box
  cpFloat top = wins.size.height;
  cpFloat WIDTH_MINUS_MARGIN = wins.size.width - GOAL_MARGIN;
  
  // bottom
  shape = cpSegmentShapeNew(staticBody, cpv(0,0), cpv(wins.size.width,0), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  // top
  shape = cpSegmentShapeNew(staticBody, cpv(0,top), cpv(GOAL_MARGIN ,top), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  shape -> collision_type = kColl_Horizontal;
  
  shape = cpSegmentShapeNew(staticBody, cpv(GOAL_MARGIN,top), cpv(GOAL_MARGIN,top+70), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  // back of top
  shape = cpSegmentShapeNew(staticBody, cpv(GOAL_MARGIN,top+70), cpv(WIDTH_MINUS_MARGIN,top+70), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  shape -> collision_type = kColl_Vertical;
  
  shape = cpSegmentShapeNew(staticBody, cpv(WIDTH_MINUS_MARGIN,top+70), cpv(WIDTH_MINUS_MARGIN,top), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  shape = cpSegmentShapeNew(staticBody, cpv(WIDTH_MINUS_MARGIN,top), cpv(wins.size.width,top), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  shape -> collision_type = kColl_Horizontal;
  
  // left
  shape = cpSegmentShapeNew(staticBody, cpv(0,0), cpv(0,wins.size.height), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  // right
  shape = cpSegmentShapeNew(staticBody, cpv(wins.size.width,0), cpv(wins.size.width,wins.size.height), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
}

- (void)addGameShapes
{
  ball = [self addSpriteNamed:@"ball.png" x:160 y:120 type:kColl_Ball];  
  obstacle1 = [self addSpriteNamed:@"obstacle.png" x:80 y:240 type:kColl_Ball];  
  obstacle2 = [self addSpriteNamed:@"obstacle.png" x:160 y:240 type:kColl_Ball];  
  obstacle3 = [self addSpriteNamed:@"obstacle.png" x:240 y:240 type:kColl_Ball];  
  player = [self addSpriteNamed:@"mallet.png" x:160 y:50 type: kColl_Player];  
}

- (void)setupCollisionHandlers
{
  cpSpaceAddCollisionPairFunc(space, kColl_Ball, kColl_Vertical, &holeInOne, ball);
  cpSpaceAddCollisionPairFunc(space, kColl_Ball, kColl_Horizontal, &holeInOne, ball);
}

- (void)setupPhysicalProperties
{
  cpBodySetMass(ball, 25);
  cpBodySetMass(obstacle1, INFINITY);
  cpBodySetMass(obstacle2, INFINITY);
  cpBodySetMass(obstacle3, INFINITY);
  cpBodySetMass(player, 2000);
}

- (void)setupMouseHandler
{
  playerMouse = cpMouseNew(space);
  playerMouse->body->p = player->p;
  playerMouse->grabbedBody = player;

  // create two joints so the body isn't rotated around the finger point
  playerMouse->joint1 = cpPivotJointNew(playerMouse->body,
                                         playerMouse->grabbedBody,
                                         cpv(playerMouse->body->p.x - 1.0f,
                                             playerMouse->body->p.y));
  cpSpaceAddJoint(playerMouse->space, playerMouse->joint1);
  
  playerMouse->joint2 = cpPivotJointNew(playerMouse->body,
                                         playerMouse->grabbedBody,
                                         cpv(playerMouse->body->p.x + 1.0f,
                                             playerMouse->body->p.y));
  cpSpaceAddJoint(playerMouse->space, playerMouse->joint2);
}

-(cpBody *) addSpriteNamed: (NSString *)name x: (float)x y:(float)y type:(unsigned int) type {
  
  UIImage *image = [UIImage imageNamed:name];  
  Sprite *sprite = [Sprite spriteFromFile:name];
  [self add: sprite z:2];
  sprite.position = cpv(x,y);

  int num_vertices = 4;
  cpVect verts[] = {
    cpv([image size].width/2 * -1, [image size].height/2 * -1),
    cpv([image size].width/2 * -1, [image size].height/2),
    cpv([image size].width/2, [image size].height/2),
    cpv([image size].width/2, [image size].height/2 * -1)
  };
  
  // all objects need a body
  cpBody *body = cpBodyNew(1.0, cpMomentForPoly(1.0, num_vertices, verts, cpvzero));
  body->p = cpv(x, y);
  cpSpaceAddBody(space, body);

  // as well as a shape to represent their collision box
  cpShape* shape = cpCircleShapeNew(body, [image size].width / 2, cpvzero);
  shape->data = sprite;
  shape -> collision_type = type;
  
  if(type == kColl_Ball) {
    shape->e = 0.5f; // elasticity
    shape->u = 1.0f; // friction
  } else {
	  shape->e = 0.5; // elasticity
	  shape->u = 0.5; // friction
	}

  cpSpaceAddShape(space, shape);
  return body;
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
  CGPoint playerTouchLocation = CGPointMake(-300, 240);

  for (UITouch *myTouch in touches) { 
    CGPoint location = [myTouch locationInView: [myTouch view]];
    location = [[Director sharedDirector] convertCoordinate: location];
    // set the finger location to be the lowest touch 
    playerTouchLocation.x = location.x;
    playerTouchLocation.y = location.y;
  }

  // into game coords...
  CGPoint location = playerTouchLocation;
  cpFloat padding = finger_padding * ((120 - location.y) / 100);
  location.y -= padding;
  location.y += fat_fingers_offset;

  // trap the location to half-field
  if(location.y > 230) location.y = 230;
  if(location.y < 0) location.y = 0;
  
  cpVect playerposition = cpv(location.x, location.y);
  cpMouseMove(playerMouse, playerposition);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesMoved:touches withEvent:event];
}

-(void) step: (ccTime) delta {
  int steps = 1;
  cpFloat dt = delta/(cpFloat)steps;
  
  for(int i=0; i<steps; i++){
    cpSpaceStep(space, dt);
  }
  
  cpSpaceHashEach(space->activeShapes, &eachShape, nil);
  cpSpaceHashEach(space->staticShapes, &eachShape, nil);
} 

-(void) ballOutOfRangeCheck: (ccTime) delta {
  if(ball -> p.x > 320 || ball -> p.x < -80 || ball -> p.y > 550 || ball -> p.y < -80) {
		resetPosition(ball);
	}
}

- (void)holeInOne
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  holeInOneBG = [Sprite spriteFromFile:@"holeinone.png"];
  [holeInOneBG setPosition:cpv(160,240)];
  [self add:holeInOneBG z:10];
	[self performSelector:@selector(resetGame:) withObject:nil afterDelay:2.0];
}

- (void)resetGame:(id)object
{
	[self remove:holeInOneBG];
	resetPosition(ball);
}

@end
