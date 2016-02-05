#import "OBHAlertControllerObject.h"

@implementation OBHAlertControllerObject

- (NSString *)alertTitle {
    return self.viewController.title;
}

- (NSString *)alertMessage {
    return self.viewController.message;
}

- (NSArray<NSString *> *)buttonTitles {
    NSArray<UIAlertAction *> *actions = self.viewController.actions;
    
    NSMutableArray *titles = [NSMutableArray new];
    
    for (UIAlertAction *action in actions) {
        [titles addObject:action.title];
    }
    
    return titles;
}

- (void)tapAlertButtonForTitle:(NSString *)buttonTitle {
    NSArray *titles = self.buttonTitles;
    
    NSUInteger index = [titles indexOfObject:buttonTitle];
    if (index == NSNotFound) {
        return;
    }
    
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertAction *action = self.viewController.actions[index];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    void (^handler)(UIAlertAction *) = [action performSelector:@selector(handler)];
#pragma clang diagnostic pop
    if (handler) {
        handler(action);
    }
}

@end
