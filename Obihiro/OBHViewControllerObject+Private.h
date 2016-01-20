#import "OBHViewControllerObject.h"

@interface OBHViewControllerObject (Private)

- (__kindof OBHViewControllerObject *)childObjectWithViewController:(UIViewController *)viewController;

- (void)cacheObject:(OBHViewControllerObject *)object;

@end

