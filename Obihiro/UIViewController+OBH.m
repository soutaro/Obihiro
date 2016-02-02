#import "UIViewController+OBH.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NSUInteger OBHAppearingViewControllerCount = 0;

@implementation UIViewController (OBH)

+ (void)load {
    [self swap:@selector(viewWillAppear:) to:@selector(viewWillAppearWithNotification:)];
    [self swap:@selector(viewDidAppear:) to:@selector(viewDidAppearWithNotification:)];
    [self swap:@selector(viewWillDisappear:) to:@selector(viewWillDisappearWithNotification:)];
    [self swap:@selector(viewDidDisappear:) to:@selector(viewDidDisappearWithNotification:)];
}

+ (void)swap:(SEL)from to:(SEL)to {
    Method fromMethod = class_getInstanceMethod(self, from);
    Method toMethod = class_getInstanceMethod(self, to);
    method_exchangeImplementations(fromMethod, toMethod);
}

- (void)viewWillAppearWithNotification:(BOOL)animated {
    [self viewWillAppearWithNotification:animated];
    
    OBHAppearingViewControllerCount += 1;
}

- (void)viewDidAppearWithNotification:(BOOL)animated {
    [self viewDidAppearWithNotification:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (OBHAppearingViewControllerCount == 0) {
            NSLog(@"It seems there is a view controller receiving viewDidAppear:animated without viewWillAppear: %@", self);
        } else {
            OBHAppearingViewControllerCount -= 1;
        }
    });
}

- (void)viewWillDisappearWithNotification:(BOOL)animated {
    [self viewWillDisappearWithNotification:animated];
    
    OBHAppearingViewControllerCount += 1;
}

- (void)viewDidDisappearWithNotification:(BOOL)animated {
    [self viewDidDisappearWithNotification:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (OBHAppearingViewControllerCount == 0) {
            NSLog(@"It seems there is a view controller receiving viewDidDisappear:animated without viewWillDisappear: %@", self);
        } else {
            OBHAppearingViewControllerCount -= 1;
        }
    });
}

@end
