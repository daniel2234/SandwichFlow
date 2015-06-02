//
//  AppDelegate.m
//  SandwichFlow
//
//  Created by Daniel Kwiatkowski on 2015-06-01.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSArray* _sandwiches;
}

-(NSArray*)sandwiches{
    return _sandwiches;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self loadSandwiches];
    return YES;
}

-(void)loadSandwiches{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Sandwiches"
                                                    ofType:@"json"];
    
    NSString* data = [NSString stringWithContentsOfFile: path
                                               encoding: NSUTF8StringEncoding
                                                  error: nil];
    
    NSData* resultData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    _sandwiches = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:nil];
    
    NSLog(@"%@",_sandwiches);
}
@end
