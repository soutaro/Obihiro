#import "OBHViewControllerObjectRef.h"

NS_ASSUME_NONNULL_BEGIN

@implementation OBHViewControllerObjectRef {
    __weak OBHViewControllerObject *_object;
}

+ (instancetype)referenceWithObject:(OBHViewControllerObject *)object {
    return [[self alloc] initWithObject:object];
}

- (instancetype)initWithObject:(OBHViewControllerObject *)object {
    self = [self init];
    
    _object = object;
    
    return self;
}

- (OBHViewControllerObject *)object {
    return (OBHViewControllerObject * _Nonnull)_object;
}

- (UIViewController *)viewController {
    return self.object.viewController;
}

@end

NS_ASSUME_NONNULL_END
