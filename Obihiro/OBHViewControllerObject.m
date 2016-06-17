#import "OBHViewControllerObject.h"
#import "UIViewController+OBH.h"
#import "OBHViewControllerObjectRef.h"
#import "OBHNavigationControllerObject.h"
#import "OBHAlertControllerObject.h"
#import "OBHTableViewControllerObject.h"
#import "OBHUIPredicate.h"
#import "OBHViewControllerObject+Private.h"

NS_ASSUME_NONNULL_BEGIN

static NSTimeInterval runLoopTimeout = 0.1;

@interface OBHViewControllerObject ()

@property (nonatomic) OBHViewControllerObject *parentObject;
@property (nonatomic) NSMutableArray<OBHViewControllerObjectRef *> *objectRefs;
@property (nonatomic) NSMutableDictionary<NSString *, Class> *classRegistory;
@property (nonatomic) BOOL isPresentedByObject;

@end

@implementation OBHViewControllerObject

+ (instancetype)objectWithViewController:(UIViewController *)viewController {
    return [[self alloc] initWithViewController:viewController parentObject:nil];
}

+ (instancetype)objectWithIdentifier:(NSString *)identifier fromStoryBoardWithName:(NSString *)name {
    UIStoryboard *storyboard =[UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    return [self objectWithViewController:viewController];
}

+ (instancetype)objectWithInitialViewControllerFromStoryBoardWithName:(NSString *)name {
    UIStoryboard *storyboard =[UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *viewController = (__kindof UIViewController * _Nonnull)[storyboard instantiateInitialViewController];
    
    return [self objectWithViewController:viewController];
}

#pragma mark - Initialize

- (instancetype)initWithViewController:(UIViewController *)viewController parentObject:(nullable OBHViewControllerObject *)parentObject {
    self = [self init];
    
    _parentObject = parentObject;
    _viewController = viewController;
    
    self.defaultTimeout = 0.4;
    if (!self.parentObject) {
        self.objectRefs = [NSMutableArray new];
    }
    self.classRegistory = [NSMutableDictionary new];
    
    [self initializeObject];
    
    return self;
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    return [self initWithViewController:viewController parentObject:nil];
}

- (void)initializeObject {
    // Do nothing
}

- (void)dealloc {
    if (self.isPresented && self.isPresentedByObject && self.viewController.parentViewController == nil) {
        [self dismissViewController];
    }
}

#pragma mark -

- (void)registerObjectClass:(Class)objectClass forViewControllerClass:(Class)viewControllerClass {
    self.classRegistory[NSStringFromClass(viewControllerClass)] = objectClass;
}

- (void)registerObjectClass:(Class)objectClass {
    NSString *objectClassName = NSStringFromClass(objectClass);
    if ([objectClassName hasSuffix:@"Object"]) {
        NSString *viewControllerClassName = [objectClassName substringToIndex:objectClassName.length - 6];
        Class viewControllerClass = NSClassFromString(viewControllerClassName);
        if (viewControllerClass) {
            [self registerObjectClass:objectClass forViewControllerClass:viewControllerClass];
        } else {
            NSLog(@"%s Object class registration failed: invalid guessed ViewController class name %@", __PRETTY_FUNCTION__, viewControllerClassName);
        }
    } else {
        NSLog(@"%s Object class registration failed: cannot guess ViewController class from %@", __PRETTY_FUNCTION__, objectClassName);
    }
}

#pragma mark - ViewController Containment

- (NSArray<OBHViewControllerObject *> *)childObjectsOfViewControllerClass:(Class)klass {
    [self ensureAllViewsDidAppear];
    
    NSMutableArray<__kindof OBHViewControllerObject *> *childObjects = [NSMutableArray new];
    
    for (UIViewController *viewController in self.viewController.childViewControllers) {
        if ([viewController isKindOfClass:klass]) {
            OBHViewControllerObject *object = [self childObjectWithViewController:viewController];
            [childObjects addObject:object];
        }
    }
    
    return childObjects;
}

- (nullable OBHViewControllerObject *)firstChildObjectOfViewControllerClass:(Class)klass {
    return [self childObjectsOfViewControllerClass:klass].firstObject;
}

- (OBHViewControllerObject *)objectWithViewController:(UIViewController *)viewController {
    return [self childObjectWithViewController:viewController];
}

#pragma mark -

- (nullable OBHViewControllerObject *)presentedObjectOfViewControllerClass:(Class)klass {
    [self ensureAllViewsDidAppear];
    
    UIViewController *presentedViewController = self.viewController.presentedViewController;
    
    if (presentedViewController) {
        if ([presentedViewController isKindOfClass:klass]) {
            return [self childObjectWithViewController:presentedViewController];
        }
    }
    
    return nil;
}

- (nullable OBHViewControllerObject *)presentedPopoverObject {
    [self ensureAllViewsDidAppear];
    
    UIViewController *presentedViewController = self.viewController.presentedViewController;
    
    if (presentedViewController) {
        if (presentedViewController.modalPresentationStyle == UIModalPresentationPopover) {
            return [self objectWithViewController:presentedViewController];
        }
    }
    
    return nil;
}

- (nullable OBHAlertControllerObject *)alertObject {
    return [self presentedObjectOfViewControllerClass:[UIAlertController class]];
}

- (OBHUIPredicate *)alertPresented {
    [self ensureAllViewsDidAppear];
    
    return [self predicateWithTest:^{
        return [self.viewController.presentedViewController isKindOfClass:[UIAlertController class]];
    }];
}

- (BOOL)hasAlert {
    return self.alertPresented.holds;
}

- (BOOL)hasNoAlert {
    return self.alertPresented.negation.holds;
}

#pragma mark - View

- (UIView *)view {
    return self.viewController.view;
}

- (NSArray<UIView *> *)descendantViewsOfClass:(Class)klass {
    NSMutableArray<UIView *> *array = [NSMutableArray new];
    [self addViews:self.view class:klass toArray:array];
    return array;
}

- (nullable UIView *)firstDescendantViewOfClass:(__unsafe_unretained Class)klass {
    return [self descendantViewsOfClass:klass].firstObject;
}

- (void)addViews:(UIView *)view class:(Class)klass toArray:(NSMutableArray<UIView *> *)array {
    if ([view isKindOfClass:klass]) {
        [array addObject:view];
    }
    
    for (UIView *subview in view.subviews) {
        [self addViews:subview class:klass toArray:array];
    }
}

#pragma mark - User Action

- (void)simulateUserAction:(void (^)())action {
    action();
    [self.class runLoopForSeconds:0.1];
}

#pragma mark - Present/Dismiss

- (void)presentViewController {
    if (self.isPresented) {
        NSLog(@"%s ViewController is already presented: presentingViewController=%@", __PRETTY_FUNCTION__, self.viewController.presentingViewController);
        return;
    }
    
    if (self.viewController.parentViewController) {
        NSLog(@"%s Cannot present ViewController because it has parentViewController: parentViewController=%@", __PRETTY_FUNCTION__, self.viewController.parentViewController);
        return;
    }
    
    self.isPresentedByObject = YES;
    
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    
    UIViewController *root = window.rootViewController;
    
    __block BOOL done = NO;
    [root presentViewController:self.viewController animated:NO completion:^{
        done = YES;
    }];
    
    [self waitFor:^{ return done; }];
}

- (void)dismissViewController {
    if (!self.isPresented) {
        NSLog(@"%s ViewController is not yet presented", __PRETTY_FUNCTION__);
        return;
    }

    if (self.viewController.parentViewController) {
        NSLog(@"%s Cannot dismiss ViewController because it has parentViewController: %@, parentViewController=%@", __PRETTY_FUNCTION__, self, self.viewController.parentViewController);
        return;
    }
    
    if (!self.isPresentedByObject) {
        NSLog(@"%s The ViewController is not presented by object, are you sure?: %@, viewController=%@", __PRETTY_FUNCTION__, self, self.viewController);
    }

    __block BOOL done = NO;
    [self.viewController.presentingViewController dismissViewControllerAnimated:NO completion:^{
        done = YES;
    }];
    
    [self waitFor:^{ return done; }];
    
    self.isPresentedByObject = NO;
}

- (BOOL)isPresented {
    return self.viewController.presentingViewController != nil;
}

#pragma mark - Predicates

- (OBHUIPredicate *)predicateWithTest:(BOOL (^)())test {
    return [[OBHUIPredicate alloc] initWithObject:self test:test];
}

#pragma mark - Utilities

- (void)ensureAllViewsDidAppear {
    [self.class ensureAllViewsDidAppear:self.defaultTimeout orRaiseError:NO];
}

- (void)ensureAllViewsDidAppear:(NSTimeInterval)timeout orRaiseError:(BOOL)raiseError {
    [self.class ensureAllViewsDidAppear:timeout orRaiseError:raiseError];
}

+ (void)ensureAllViewsDidAppear:(NSTimeInterval)timeout orRaiseError:(BOOL)raiseError
{
    [self runLoopForSeconds:0.1];
    
    if ([self allViewControllersDidAppear]) {
        return;
    }
    
    BOOL satisfied = [self.class waitFor:^{ return [self.class allViewControllersDidAppear]; } timeout:timeout];
    
    if (!satisfied && raiseError) {
        [NSException raise:@"Timeout Exceeded" format:@"Waited for all views did appear for %f seconds", timeout];
    }
}

- (BOOL)waitFor:(BOOL (^)())test {
    return [self.class waitFor:test timeout:self.defaultTimeout];
}

- (BOOL)eventually:(BOOL (^)())test {
    return [self.class eventually:test timeout:self.defaultTimeout];
}

- (BOOL)eventuallyNot:(BOOL (^)())test {
    return [self eventually:^BOOL{
        return !test();
    }];
}

- (BOOL)eventuallyNil:(id (^)())test {
    return [self eventually:^BOOL {
        return test() == nil;
    }];
}

- (BOOL)eventuallyNotNil:(id (^)())test {
    return [self eventuallyNot:^BOOL{
        return test() == nil;
    }];
}

- (BOOL)globally:(BOOL (^)())test {
    return [self.class globally:test forSeconds:self.defaultTimeout];
}

- (BOOL)globallyNotNil:(id (^)())test {
    return [self globally:^BOOL{
        return test() != nil;
    }];
}

+ (BOOL)allViewControllersDidAppear {
    return OBHAppearingViewControllerCount == 0;
}

+ (void)runLoopForAWhile {
    [self runLoopForSeconds:runLoopTimeout];
}

+ (void)runLoopForSeconds:(NSTimeInterval)seconds {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
}

+ (BOOL)waitFor:(BOOL (^)())test timeout:(NSTimeInterval)timeout {
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    while ([[NSDate date] compare:end] == NSOrderedAscending) {
        [self.class runLoopForAWhile];
        
        if (test()) {
            return YES;
        }
    }
    
    return test();
}

+ (BOOL)eventually:(BOOL (^)())test timeout:(NSTimeInterval)timeout {
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    while ([[NSDate date] compare:end] == NSOrderedAscending) {
        [self.class runLoopForAWhile];
        
        if (test()) {
            return YES;
        }
    }
    
    return test();
}

+ (BOOL)globally:(BOOL (^)())test forSeconds:(NSTimeInterval)seconds {
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow:seconds];
    
    while ([[NSDate date] compare:end] == NSOrderedAscending) {
        [self.class runLoopForAWhile];
        
        if (!test()) {
            return NO;
        }
    }
    
    return !test();
}

#pragma mark - Cache and factory

- (nullable __kindof OBHViewControllerObject *)cachedObjectForViewController:(UIViewController *)viewController {
    if (self.parentObject) {
        return [self.parentObject cachedObjectForViewController:viewController];
    }
    
    for (OBHViewControllerObjectRef *ref in self.objectRefs) {
        if ([ref.viewController isEqual:viewController] && ref.object) {
            return ref.object;
        }
    }
    
    return nil;
}

- (void)cacheObject:(OBHViewControllerObject *)object {
    if (self.parentObject) {
        [self.parentObject cacheObject:object];
    }
    
    OBHViewControllerObjectRef *ref = [OBHViewControllerObjectRef referenceWithObject:object];
    [self.objectRefs addObject:ref];
}

- (Class)objectClassForViewControllerClass:(Class)klass {
    Class objectClass = self.classRegistory[NSStringFromClass(klass)];
    
    if (objectClass) {
        return objectClass;
    } else {
        if (self.parentObject) {
            return [self.parentObject objectClassForViewControllerClass:klass];
        } else {
            if ([klass isSubclassOfClass:[UINavigationController class]]) {
                return [OBHNavigationControllerObject class];
            }
            
            if ([klass isSubclassOfClass:[UIAlertController class]]) {
                return [OBHAlertControllerObject class];
            }
            
            if ([klass isSubclassOfClass:[UITableViewController class]]) {
                return [OBHTableViewControllerObject class];
            }
            
            return [OBHViewControllerObject class];
        }
    }
}

- (__kindof OBHViewControllerObject *)childObjectWithViewController:(UIViewController *)viewController {
    OBHViewControllerObject *object = [self cachedObjectForViewController:viewController];
    if (object) {
        return object;
    }
    
    Class objectClass = [self objectClassForViewControllerClass:viewController.class];
    
    OBHViewControllerObject *newObject = [[objectClass alloc] initWithViewController:viewController parentObject:self];
    
    [self cacheObject:newObject];
    
    return newObject;
}

@end

NS_ASSUME_NONNULL_END
