#import "OBHViewControllerObjectRef.h"

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
    return _object;
}

- (UIViewController *)viewController {
    return _object.viewController;
}

@end
