//
//  DynamicSandwichViewController.m
//  SandwichFlow
//
//  Created by Daniel Kwiatkowski on 2015-06-01.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

#import "DynamicSandwichViewController.h"
#import "SandwichViewController.h"
#import "AppDelegate.h"

@interface DynamicSandwichViewController () <UICollisionBehaviorDelegate>

@end

@implementation DynamicSandwichViewController{
    //use this variable to keep track of views, this is easier than having to iterate over all the subviews in order to find those that you are interested in.
    //implement dynamics
    NSMutableArray* _views;
    UIGravityBehavior* _gravity;
    UIDynamicAnimator* _animator;
    CGPoint _previousTouchPoint;
    UISnapBehavior* _snap;
    BOOL _draggingView;
    BOOL _viewDocked;
}

- (void)viewDidLoad {
    [super viewDidLoad];
////add a background layer
//    UIImageView* backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background-LowerLayer.png"]];
//    backgroundImageView.frame = CGRectInset(self.view.frame, -50.0f, -50.0f);
//    [self.view addSubview:backgroundImageView];
//    [self addMotionToEffectToView:backgroundImageView magnitude:50.0f];
//    
////add the background mid layer
//    UIImageView* midLayerImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background-MidLayer.png"]];
//    [self.view addSubview:midLayerImageView];
//    
////add the foreground image
//    UIImageView* header = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Sarnie.png"]];
//    header.center = CGPointMake(220, 190);
//    [self.view addSubview:header];
//    [self addMotionToEffectToView:header magnitude:-20.0f];
    
    
    //Background image
    UIImageView* backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background-LowerLayer"]];
    [self.view addSubview:backgroundImageView];
    
    //Header Logo
    UIImageView *header = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Sarnie"]];
    header.center = CGPointMake(220, 190);
    
    [self.view addSubview:header];
    
    _views = [NSMutableArray new];
    CGFloat offset = 250.0f;
    
    for (NSDictionary* sandwich in [self sandwiches]) {
        [_views addObject:[self addRecipeAtOffset:offset forSandwich:sandwich]];
        offset -= 50.0f;
    }
}

-(void)addMotionToEffectToView:(UIView*)view magnitude:(float)magnitude{
    
    UIInterpolatingMotionEffect* xMotion = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xMotion.minimumRelativeValue = @(-magnitude);
    xMotion.maximumRelativeValue = @(magnitude);
    
    UIInterpolatingMotionEffect* yMotion = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    xMotion.minimumRelativeValue = @(-magnitude);
    yMotion.minimumRelativeValue = @(magnitude);
    
    UIMotionEffectGroup* group = [[UIMotionEffectGroup alloc]init];
    
    group.motionEffects = @[xMotion,yMotion];
    
    [view addMotionEffect:group];
}





-(NSArray*)sandwiches{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    return appDelegate.sandwiches;
}


//Create a SandwichViewController instance. Notice that this uses the SandwichVC identifier
//Set the frame of this recipe and the supply the sandwich data.
//Add the view controller as a child and to the view.
-(UIView*)addRecipeAtOffset:(CGFloat)offset forSandwich:(NSDictionary*)sandwich{
    
    CGRect frameForView = CGRectOffset(self.view.bounds, 0.0, self.view.bounds.size.height - offset);
    
    //1. create a view controller
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SandwichViewController* viewController = [mystoryboard instantiateViewControllerWithIdentifier:@"SandwichVC"];
    
    //2.set frame and provide some data
    UIView* view = viewController.view;
    view.frame = frameForView;
    viewController.sandwich = sandwich;
    
    //3. add as a child
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    //adds the dynamic behaviour and adds the gravity behaviour
    _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    _gravity = [[UIGravityBehavior alloc]init];
    [_animator addBehavior:_gravity];
    //set to 4 making things fall slower than the default value of 1.0
    _gravity.magnitude = 4.0f;
    
    //add a gesture recognizer with a view
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handlePan:)];
    [viewController.view addGestureRecognizer:pan];
    
    //create a collision behaviour so it does not go into freefall
    UICollisionBehavior* collision = [[UICollisionBehavior alloc]initWithItems:@[view]];
    [_animator addBehavior:collision];
    
    //lower boundary, where the tab rests, in which it create a boundary where this specific view controller will come to rest. It is based on the bottom edge of the current view location.
    CGFloat boundary = view.frame.origin.y + view.frame.size.height + 1;
    CGPoint boundaryStart = CGPointMake(0.0, boundary);
    CGPoint boundaryEnd = CGPointMake(self.view.bounds.size.width, boundary);
    
    [collision addBoundaryWithIdentifier:@1 fromPoint:boundaryStart toPoint:boundaryEnd];
    
    
    //upper boundary
    boundaryStart = CGPointMake(0.0, 0.0);
    boundaryEnd = CGPointMake(self.view.bounds.size.width, 0.0);
    [collision addBoundaryWithIdentifier:@2 fromPoint:boundaryStart toPoint:boundaryEnd];
    
    //apply gravity to the view
    [_gravity addItem:view];
    
    
    //adds dynamic behaviour for each of the recipe views
    UIDynamicBehavior* itemBehaviour = [[UIDynamicItemBehavior alloc]initWithItems:@[view]];
    [_animator addBehavior:itemBehaviour];
    
    return view;
}


-(void)handlePan:(UIPanGestureRecognizer*)gesture{
    CGPoint touchPoint = [gesture locationInView:self.view];
    UIView* draggedView = gesture.view;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // 1. was the pan initiated from the upper part of the recipe?
        UIView* draggedView = gesture.view;
        CGPoint dragStartLocation = [gesture locationInView:draggedView];
        if (dragStartLocation.y < 200.0f) {
            _draggingView = YES;
            _previousTouchPoint = touchPoint;
        }
        
    } else if (gesture.state == UIGestureRecognizerStateChanged && _draggingView) {
        // 2. handle dragging
        float yOffset = _previousTouchPoint.y - touchPoint.y;
        gesture.view.center = CGPointMake(draggedView.center.x,
                                          draggedView.center.y - yOffset);
        _previousTouchPoint = touchPoint;
        
    } else if (gesture.state == UIGestureRecognizerStateEnded && _draggingView) {
        // 3. the gesture has ended
        [self addVelocityToView:draggedView fromGesture:gesture];
        [self tryDockView:draggedView];
        [_animator updateItemUsingCurrentState:draggedView];
        _draggingView = NO;
    }
}
// iterates over the behaviours until it finds the one with the correct type associated with the given view
-(UIDynamicItemBehavior*) itemForBehaviourForView:(UIView*)view{
    for (UIDynamicItemBehavior* behaviour in _animator.behaviors) {
        if (behaviour.class == [UIDynamicItemBehavior class] && [behaviour.items firstObject] == view){
            return behaviour;
        }
    }
    return nil;
}
//This takes the gesture velocity, removes the X component (you don’t want those recipes flying off sideways!),
//locates the item behavior, and then adds the velocity to the behavior.
-(void)addVelocityToView:(UIView*)view fromGesture:(UIPanGestureRecognizer*)gesture{
    CGPoint vel = [gesture velocityInView:self.view];
    vel.x = 0;
    UIDynamicItemBehavior* behaviour = [self itemForBehaviourForView:view];
    [behaviour addLinearVelocity:vel forItem:view];
}

//This method checks whether the view has been dragged close to the top of the screen. If it has, and the view is not yet docked, it creates a UISnapBehaviour which snaps the view to the center of the screen
-(void)tryDockView:(UIView*)view{
    BOOL viewHasReachedDockLocation = view.frame.origin.y < 100;
    if (viewHasReachedDockLocation) {
        if (!_viewDocked) {
            _snap = [[UISnapBehavior alloc]initWithItem:view snapToPoint:self.view.center];
            [_animator addBehavior:_snap];
            [self setAlphaWhenViewDocked:view alpha:0.0];
            _viewDocked = YES;
        }
    } else{
        if (_viewDocked) {
            [_animator removeBehavior:_snap];
            [self setAlphaWhenViewDocked:view alpha:1.0];
            _viewDocked = NO;
        }
    }
}

//This is used to show and hide the non-docked views so that the docked recipe occupies the entire screen without being obscured by the recipes below.
-(void)setAlphaWhenViewDocked:(UIView*)view alpha:(CGFloat)alpha{
    for (UIView* aView in _views) {
        if (aView != view) {
            aView.alpha = alpha;
        }
    }
}

//This checks whether a boundary with the identifier “2” is involved in the collision and if so, docks the recipe item
-(void)collisionBehavior:(UICollisionBehavior *)behavior
     beganContactForItem:(id<UIDynamicItem>)item
  withBoundaryIdentifier:(id<NSCopying>)identifier
                 atPoint:(CGPoint)p{
    if ([@2 isEqual:identifier]) {
        UIView* view = (UIView*) item;
        [self tryDockView:view];
    }
}

@end
