#import "OBHUIPredicate.h"
#import "OBHViewControllerObject.h"

@interface OBHUIPredicate ()

@property (nonatomic, weak) OBHViewControllerObject *object;
@property (nonatomic, strong) BOOL (^test)();

@end

@implementation OBHUIPredicate

- (instancetype)initWithObject:(OBHViewControllerObject *)object test:(BOOL (^)())test {
    self = [self init];
    
    self.object = object;
    self.test = test;
    
    return self;
}

- (BOOL)holds {
    return [self.object eventually:self.test];
}

- (BOOL)doesntHold {
    return [self.object eventuallyNot:self.test];
}

- (OBHUIPredicate *)negation {
    return [[self.class alloc] initWithObject:self.object test:^BOOL{
        return !self.test();
    }];
}

@end
