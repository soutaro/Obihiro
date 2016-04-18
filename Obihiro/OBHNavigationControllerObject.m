#import "OBHNavigationControllerObject.h"
#import "OBHViewControllerObject+Private.h"
#import "OBHUIPredicate.h"

@implementation OBHNavigationControllerObject

+ (instancetype)objectWithEmptyNavigationController {
    return [self objectWithViewController:[[UINavigationController alloc] init]];
}

#pragma mark -

- (BOOL)hasTopViewControllerOfClass:(Class)klass {
    [self ensureAllViewsDidAppear];
    return [self eventually:^{
        return [self.viewController.topViewController isKindOfClass:klass];
    }];
}

- (void)pushViewControllerObject:(OBHViewControllerObject *)object {
    [self ensureAllViewsDidAppear];
    [self cacheObject:object];
    [self.viewController pushViewController:object.viewController animated:NO];
    [self ensureAllViewsDidAppear];
}

- (void)pushViewController:(UIViewController *)viewController {
    OBHViewControllerObject *object = [self childObjectWithViewController:viewController];
    [self pushViewControllerObject:object];
}

- (OBHViewControllerObject *)topObject {
    [self ensureAllViewsDidAppear];
    return [self childObjectWithViewController:self.viewController.topViewController];
}

- (OBHViewControllerObject *)topObjectOfViewControllerClass:(Class)klass {
    if ([self hasTopViewControllerOfClass:klass]) {
        return self.topObject;
    } else {
        return nil;
    }
}

#pragma mark -

- (OBHUIPredicate *)backButtonPresented {
    return [self predicateWithTest:^BOOL{
        return !self.topObject.viewController.navigationItem.hidesBackButton;
    }];
}

- (OBHUIPredicate *)leftButtonPresented {
    return [self predicateWithTest:^BOOL{
        return self.topObject.viewController.navigationItem.leftBarButtonItem != nil;
    }];
}

- (OBHUIPredicate *)rightButtonPresented {
    return [self predicateWithTest:^BOOL{
        return self.topObject.viewController.navigationItem.rightBarButtonItem != nil;
    }];
}

- (OBHUIPredicate *)leftButtonAvailable {
    return [self predicateWithTest:^{
        return self.topObject.viewController.navigationItem.leftBarButtonItem.enabled;
    }];
}

- (OBHUIPredicate *)rightButtonAvailable {
    return [self predicateWithTest:^{
        return self.topObject.viewController.navigationItem.rightBarButtonItem.enabled;
    }];
}

- (BOOL)hasBackButton {
    return self.backButtonPresented.holds;
}

- (BOOL)isBackButtonHidden {
    return self.backButtonPresented.negation.holds;
}

- (BOOL)hasLeftButton {
    return self.leftButtonPresented.holds;
}

- (BOOL)isLeftButtonHidden {
    return self.leftButtonPresented.negation.holds;
}

- (BOOL)hasRightButton {
    return self.rightButtonPresented.holds;
}

- (BOOL)isRightButtonHidden {
    return self.rightButtonPresented.negation.holds;
}

- (BOOL)isLeftButtonAvailable {
    return self.leftButtonAvailable.holds;
}

- (BOOL)isLeftButtonUnavailable {
    return self.leftButtonAvailable.negation.holds;
}

- (BOOL)isRightButtonAvailable {
    return self.rightButtonAvailable.holds;
}

- (BOOL)isRightButtonUnavailable {
    return self.rightButtonAvailable.negation.holds;
}

- (void)tapRightButton {
    if (self.rightButtonAvailable.negation.holds) {
        return;
    }
    
    UIBarButtonItem *button = self.topObject.viewController.navigationItem.rightBarButtonItem;
    [self simulateUserAction:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [button.target performSelector:button.action withObject:button];
#pragma clang diagnostic pop
    }];
}

#pragma mark - Navigation

- (void)back {
    [self ensureAllViewsDidAppear];
    [self simulateUserAction:^{
        [self.viewController popViewControllerAnimated:YES];
    }];
    [self ensureAllViewsDidAppear];
}

@end
