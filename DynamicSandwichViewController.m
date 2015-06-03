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

@interface DynamicSandwichViewController ()

@end

@implementation DynamicSandwichViewController{
    //use this variable to keep track of views, this is easier than having to iterate over all the subviews in order to find those that you are interested in.
    NSMutableArray* _views;
    UIGravityBehavior* _gravity;
    UIDynamicAnimator* _animator;
    CGPoint _previousTouchPoint;
    UISnapBehavior* _snap;
    BOOL _viewDocked;
    BOOL _draggingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    _gravity = [[UIGravityBehavior alloc]init];
    [_animator addBehavior:_gravity];
    _gravity.magnitude = 4.0f;
    
    //add a gesture recognizer with a view
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]initWithTarget:self
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
    
    //apply gravity to the view
    [_gravity addItem:view];
    
    //The net result of this code is that if the view associated with this view controller is moved from its current location, it will fall under the influence of gravity, eventually coming to rest at its original location.
    
    UIDynamicBehavior* itemBehaviour = [[UIDynamicItemBehavior alloc]initWithItems:@[view]];
    [_animator addBehavior:itemBehaviour];
    
    return view;
}


-(void)handlePan:(UIPanGestureRecognizer*)gesture{
    CGPoint touchPoint = [gesture locationInView:self.view];
    UIView* draggedView = gesture.view;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint dragStartLocation = [gesture locationInView:draggedView];
        if (dragStartLocation.y < 200.0f) {
            _draggingView = YES;
            _previousTouchPoint = touchPoint;
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged && _draggingView){
        //handle dragging
        CGFloat yOffset = _previousTouchPoint.y - touchPoint.y;
        gesture.view.center = CGPointMake(draggedView.center.x, draggedView.center.y - yOffset);
        _previousTouchPoint = touchPoint;
        //
    } else if (gesture.state == UIGestureRecognizerStateEnded && _draggingView){
        [_animator updateItemUsingCurrentState:draggedView];
        _draggingView = NO;
    }
    [self tryDockView:draggedView];
    //velocity needs to be updated when the gesture ends
    [self addVelocityToView:draggedView fromGesture:gesture];
}

-(UIDynamicItemBehavior*)itemBehaviourForView:(UIView*)view{
    for (UIDynamicItemBehavior* behaviour in _animator.behaviors) {
        if (behaviour.class == [UIDynamicItemBehavior class] && [behaviour.items firstObject] == view){
            return behaviour;
        }
    }
    return nil;
}

-(void)addVelocityToView:(UIView*)view fromGesture:(UIPanGestureRecognizer*)gesture{
    CGPoint vel = [gesture velocityInView:self.view];
    vel.x = 0;
    UIDynamicItemBehavior* behaviour = [self itemBehaviourForView:view];
    [behaviour addLinearVelocity:vel forItem:view];
    //this takes the gesture velocity, removes x component, locates the item behaviour, and the adds velocity to the behaviour  , the gesture velocity is expressed in points per second , same units used in by the same dynamics
}
//This method checks whether the view has been dragged close to the top of the screen. If it has, and the view is not yet docked, it creates a UISnapBehaviour which snaps the view to the center of the screen.If the view has been dragged away from the top of the screen and was previously docked, the code removes the snap behavior.
-(void)tryDockView:(UIView*)view{
    BOOL viewHasReachedDockLocation = view.frame.origin.y < 100.0;
    if(viewHasReachedDockLocation){
        if (!_viewDocked) {
            _snap = [[UISnapBehavior alloc]initWithItem:view snapToPoint:self.view.center];
            [_animator addBehavior:_snap];
            [self setAlphaWhenViewDocked:view alpha:0.0];
            _viewDocked = YES;
        }
    } else {
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
        if (aView != view){
            aView.alpha = alpha;
        }
    }
}

@end
