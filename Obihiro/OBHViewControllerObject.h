#import <UIKit/UIKit.h>

@class OBHNavigationControllerObject;
@class OBHAlertControllerObject;

@interface OBHViewControllerObject<ViewController: UIViewController *> : NSObject

@property (nonatomic, readonly) ViewController viewController;

/**
 Returns new ViewController Object with given ViewController.
 */
+ (instancetype)objectWithViewController:(ViewController)viewController;

/**
 */
+ (instancetype)objectWithInitialViewControllerFromStoryBoardWithName:(NSString *)name;

/**
 Returns new ViewController Object with a ViewController loaded from StoryBoard.
 */
+ (instancetype)objectWithIdentifier:(NSString *)identifier fromStoryBoardWithName:(NSString *)name;

/**
 Initialize the object with given ViewController.
 */
- (instancetype)initWithViewController:(ViewController)viewController;

/**
 Initialize the object.
 Invoked during `init` methods.
 
 You should use this object instead of overriding `init` methods.
 */
- (void)initializeObject;

/**
 Make `objectClass` be instantiated for ViewController instances of `viewControllerClass`.
 */
- (void)registerObjectClass:(Class)objectClass forViewControllerClass:(Class)viewControllerClass;

/**
 */
- (void)registerObjectClass:(Class)objectClass;

#pragma mark - ViewController Containment

- (NSArray<__kindof OBHViewControllerObject *> *)childObjectsOfViewControllerClass:(Class)klass;
- (__kindof OBHViewControllerObject *)firstChildObjectOfViewControllerClass:(Class)klass;

- (__kindof OBHViewControllerObject *)objectWithViewController:(UIViewController *)viewController;

#pragma mark -

- (__kindof OBHViewControllerObject *)presentedObjectOfViewControllerClass:(Class)klass;
- (__kindof OBHViewControllerObject *)presentedPopoverObject;
- (OBHAlertControllerObject *)alertObject;
@property (nonatomic, readonly) BOOL hasAlert;

#pragma mark - Views

/**
 View associated with `viewController`.
 */
@property (nonatomic, readonly) __kindof UIView *view;

/**
 Returns array of descendant views which is an instance of subclass of `klass`.
 */
- (NSArray<__kindof UIView *> *)descendantViewsOfClass:(Class)klass;

/**
 Returns an instance of subclass of `klass`.
 */
- (__kindof UIView *)firstDescendantViewOfClass:(__unsafe_unretained Class)klass;

#pragma mark - User Action

- (void)simulateUserAction:(void(^)())action;

#pragma mark - Present/Dismiss

/**
 Present the ViewController under UIWindow.rootViewController.
 Returns after `viewDidAppear` call.
 */
- (void)presentViewController;

/**
 Dismiss the ViewController.
 Returns after `viewDidDisappear` call.
 */
- (void)dismissViewController;

/**
 Returns `YES` if the ViewController is already presented.
 */
@property (nonatomic, readonly) BOOL isPresented;

#pragma mark - Utilities

/**
 Blocks until `+ allViewControllersDidAppear` returns true, or timed out.
 */
- (void)ensureAllViewsDidAppear;

/**
 Blocks until `+ allViewControllersDidAppear` returns true.
 If timed out, raises an error if `raiseError` is true.
 */
- (void)ensureAllViewsDidAppear:(NSTimeInterval)timeout orRaiseError:(BOOL)raiseError;

/**
 Default timeout for `-[OBHViewControllerObject waitFor:timeout:]`.
 Should be greater than zero.
 */
@property (nonatomic) NSTimeInterval defaultTimeout;

/**
 Blocks until `test` returns true.
 Time out by `defaultTimeout`.
 */
- (BOOL)waitFor:(BOOL(^)())test;

- (BOOL)eventually:(BOOL(^)())test;
- (BOOL)eventuallyNotNil:(id(^)())test;

- (BOOL)globally:(BOOL(^)())test;
- (BOOL)globallyNotNil:(id(^)())test;

/**
 Blocks until `test` returns true.
 
 Returns true when `test` is finally satisfied.
 Returns false when timed out.
 */
+ (BOOL)waitFor:(BOOL (^)())test timeout:(NSTimeInterval)timeout;

+ (BOOL)eventually:(BOOL(^)())test timeout:(NSTimeInterval)timeout;
+ (BOOL)globally:(BOOL(^)())test forSeconds:(NSTimeInterval)seconds;

/**
 Returns true if there is no ViewController appearing/disappearing.
 Returns false one or more ViewController which has been `viewWillAppear:` and not yet `viewDidAppear`.
 Returns false one or more ViewController which has been `viewWillDisappear:` and not yet `viewDidDisappear`.
 */
+ (BOOL)allViewControllersDidAppear;

/**
 Blocks for a while.
 */
+ (void)runLoopForAWhile;

/**
 Blocks for `seconds`.
 */
+ (void)runLoopForSeconds:(NSTimeInterval)seconds;

@end
