#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <math.h>

static const void *H4NGlassViewAssociationKey = &H4NGlassViewAssociationKey;
static const NSInteger H4NGlassViewTag = 0x34484E;

static BOOL H4NContains(NSString *value, NSString *part) {
    if (value.length == 0 || part.length == 0) return NO;
    return [value rangeOfString:part options:NSCaseInsensitiveSearch].location != NSNotFound;
}

static BOOL H4NIsStoryAddControl(UIView *view) {
    if (!view || !view.window) return NO;

    CGSize size = view.bounds.size;
    CGFloat shorter = MIN(size.width, size.height);
    CGFloat longer = MAX(size.width, size.height);
    if (shorter < 24.0 || longer > 68.0 || longer / shorter > 1.45) return NO;

    NSString *className = NSStringFromClass(object_getClass(view)).lowercaseString;
    NSString *label = (view.accessibilityLabel ?: @"").lowercaseString;
    NSString *identifier = (view.accessibilityIdentifier ?: @"").lowercaseString;
    NSString *signature = [NSString stringWithFormat:@"%@ %@ %@", className, label, identifier];

    BOOL mentionsStory = H4NContains(signature, @"story") || H4NContains(signature, @"stories");
    BOOL mentionsAdd = H4NContains(signature, @"add") || H4NContains(signature, @"create") || H4NContains(signature, @"plus");
    BOOL buttonLike = [view isKindOfClass:UIButton.class] ||
        ((view.accessibilityTraits & UIAccessibilityTraitButton) != 0) ||
        H4NContains(className, @"button");

    return mentionsStory && (mentionsAdd || buttonLike);
}

static void H4NApplyBlueGlass(UIView *view) {
    if (!H4NIsStoryAddControl(view) || objc_getAssociatedObject(view, H4NGlassViewAssociationKey)) return;

    CGFloat radius = view.layer.cornerRadius > 0.0 ? view.layer.cornerRadius : MIN(view.bounds.size.width, view.bounds.size.height) * 0.31;
    UIColor *blueTint = [UIColor colorWithRed:0.035 green:0.56 blue:0.88 alpha:0.42];
    UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithFrame:view.bounds];
    glassView.tag = H4NGlassViewTag;
    glassView.userInteractionEnabled = NO;
    glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glassView.clipsToBounds = YES;
    glassView.layer.cornerRadius = radius;
    glassView.layer.cornerCurve = kCACornerCurveContinuous;
    glassView.layer.borderWidth = 0.5;
    glassView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.22].CGColor;

    if (@available(iOS 26.0, *)) {
        UIGlassEffect *effect = [UIGlassEffect effectWithStyle:UIGlassEffectStyleRegular];
        effect.tintColor = blueTint;
        effect.interactive = YES;
        glassView.effect = effect;
        glassView.cornerConfiguration = [UICornerConfiguration configurationWithRadius:[UICornerRadius fixedRadius:radius]];
    } else {
        glassView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
        glassView.contentView.backgroundColor = [blueTint colorWithAlphaComponent:0.28];
    }

    [view insertSubview:glassView atIndex:0];
    view.backgroundColor = UIColor.clearColor;
    view.layer.cornerRadius = radius;
    view.layer.cornerCurve = kCACornerCurveContinuous;
    view.layer.shadowColor = blueTint.CGColor;
    view.layer.shadowOpacity = 0.22;
    view.layer.shadowRadius = 7.0;
    view.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    objc_setAssociatedObject(view, H4NGlassViewAssociationKey, glassView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void H4NScanStoryControls(UIView *view, NSUInteger depth) {
    if (!view || depth > 28) return;
    H4NApplyBlueGlass(view);
    for (UIView *child in view.subviews) {
        H4NScanStoryControls(child, depth + 1);
    }
}

%hook UIView
- (void)didMoveToWindow {
    %orig;
    H4NApplyBlueGlass(self);
}
%end

%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    __weak UIView *rootView = self.view;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (rootView.window) H4NScanStoryControls(rootView, 0);
    });
}
%end
