#import "OBHNavigationControllerObject.h"
#import "OBHViewControllerObject+Private.h"

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
    [self cacheObject:object];
    [self.viewController pushViewController:object.viewController animated:NO];
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

- (BOOL)hasBackButton {
    return [self eventuallyNot:^{
        return self.topObject.viewController.navigationItem.hidesBackButton;
    }];
}

- (BOOL)isBackButtonHidden {
    return [self eventually:^{
        return self.topObject.viewController.navigationItem.hidesBackButton;
    }];
}

- (BOOL)hasLeftButton {
    return [self eventuallyNotNil:^{
        return self.topObject.viewController.navigationItem.leftBarButtonItem;
    }];
}

- (BOOL)isLeftButtonHidden {
    return [self eventuallyNil:^{
        return self.topObject.viewController.navigationItem.leftBarButtonItem;
    }];
}

- (BOOL)hasRightButton {
    return [self eventuallyNotNil:^{
        return self.topObject.viewController.navigationItem.rightBarButtonItem;
    }];
}

- (BOOL)isRightButtonHidden {
    return [self eventuallyNil:^{
        return self.topObject.viewController.navigationItem.rightBarButtonItem;
    }];
}

- (BOOL)isLeftButtonAvailable {
    return [self eventually:^{
        return self.topObject.viewController.navigationItem.leftBarButtonItem.enabled;
    }];
}

- (BOOL)isLeftButtonUnavailable {
    return [self eventuallyNot:^{
        return self.topObject.viewController.navigationItem.leftBarButtonItem.enabled;
    }];
}

- (BOOL)isRightButtonAvailable {
    return [self eventually:^{
        return self.topObject.viewController.navigationItem.rightBarButtonItem.enabled;
    }];
}

- (BOOL)isRightButtonUnavailable {
    return [self eventuallyNot:^{
        return self.topObject.viewController.navigationItem.rightBarButtonItem.enabled;
    }];
}

- (void)tapRightButton {
    if (self.isRightButtonUnavailable) {
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
}

@end
