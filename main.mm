#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <substrate.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>

static bool (*orig_anti_debug_check)(void);
static bool hooked_anti_debug_check(void) {
    return false;
}

void (*orig_report_crash)(void *self, SEL _cmd, id error);
void hooked_report_crash(void *self, SEL _cmd, id error) {
    return;
}

@interface ModMenu : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, strong) UIView *menuPanel;
@property (nonatomic, assign) BOOL aimbotEnabled;
@property (nonatomic, assign) BOOL espEnabled;
@end

@implementation ModMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatingButton.frame = CGRectMake(20, 100, 50, 50);
    self.floatingButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.2 alpha:0.8];
    [self.floatingButton setTitle:@"MOD" forState:UIControlStateNormal];
    [self.floatingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.floatingButton.layer.cornerRadius = 25;
    [self.floatingButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.floatingButton];

    self.menuPanel = [[UIView alloc] initWithFrame:CGRectMake(80, 100, 220, 260)];
    self.menuPanel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    self.menuPanel.layer.cornerRadius = 12;
    self.menuPanel.layer.borderWidth = 1.5;
    self.menuPanel.layer.borderColor = [[UIColor greenColor] CGColor];
    self.menuPanel.hidden = YES;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
    titleLabel.text = @"FF iOS Menu + AntiBan";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.menuPanel addSubview:titleLabel];

    UIButton *aimButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aimButton.frame = CGRectMake(20, 50, 180, 40];
    aimButton.backgroundColor = [UIColor darkGrayColor];
    [aimButton setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
    [aimButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    aimButton.tag = 1;
    aimButton.layer.cornerRadius = 8;
    [aimButton addTarget:self action:@selector(featureTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuPanel addSubview:aimButton];

    UIButton *espButton = [UIButton buttonWithType:UIButtonTypeCustom];
    espButton.frame = CGRectMake(20, 100, 180, 40];
    espButton.backgroundColor = [UIColor darkGrayColor];
    [espButton setTitle:@"ESP Line/Box: OFF" forState:UIControlStateNormal];
    [espButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    espButton.tag = 2;
    espButton.layer.cornerRadius = 8;
    [espButton addTarget:self action:@selector(featureTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuPanel addSubview:espButton];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(20, 180, 180, 35];
    closeButton.backgroundColor = [UIColor redColor];
    [closeButton setTitle:@"Ẩn Menu" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.layer.cornerRadius = 8;
    [closeButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuPanel addSubview:closeButton];

    [self addSubview:self.menuPanel];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.floatingButton addGestureRecognizer:pan];
}

- (void)toggleMenu {
    self.menuPanel.hidden = !self.menuPanel.hidden;
}

- (void)featureTapped:(UIButton *)sender {
    if (sender.tag == 1) {
        self.aimbotEnabled = !self.aimbotEnabled;
        if (self.aimbotEnabled) {
            [sender setTitle:@"Aimbot: ON" forState:UIControlStateNormal];
            [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        } else {
            [sender setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
            [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    } else if (sender.tag == 2) {
        self.espEnabled = !self.espEnabled;
        if (self.espEnabled) {
            [sender setTitle:@"ESP Line/Box: ON" forState:UIControlStateNormal];
            [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        } else {
            [sender setTitle:@"ESP Line/Box: OFF" forState:UIControlStateNormal];
            [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self];
    CGPoint center = recognizer.view.center;
    recognizer.view.center = CGPointMake(center.x + translation.x, center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:self];
}

@end

__attribute__((constructor)) void entry() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(4);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
            if (mainWindow) {
                ModMenu *modView = [[ModMenu alloc] initWithFrame:mainWindow.bounds];
                modView.userInteractionEnabled = YES;
                [mainWindow addSubview:modView];
            }
        });
    });
}
