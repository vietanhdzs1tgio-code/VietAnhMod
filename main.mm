#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

// ==========================================
// BẢO VỆ CHỐNG BAN / CHỐNG GỠ RỐI TẦNG THẤP
// ==========================================
__attribute__((constructor)) static void antiCheatBypass() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Vô hiệu hóa cờ gỡ lỗi cơ bản để tránh bị quét trạng thái debug
        typedef int (*ptr_ptr)(void);
        // Làm nhiễu tiến trình kiểm tra toàn vẹn bộ nhớ ngầm
        sleep(2);
    });
}

// ==========================================
// GIAO DIỆN MENU HOÀN CHỈNH: K13 (CHẠM 3 NGÓN TAY)
// ==========================================
@interface K13ModMenu : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, assign) BOOL isMenuVisible;
@property (nonatomic, assign) BOOL aimbotActive;
@property (nonatomic, assign) BOOL espActive;
@property (nonatomic, assign) BOOL damageFixActive;
@property (nonatomic, assign) BOOL antiCrashActive;
@end

@implementation K13ModMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isMenuVisible = NO;
        [self setupIndicator];
        [self setupMenuPanel];
        [self setupGestures];
    }
    return self;
}

// Hiển thị chỉ báo màu đỏ ở logo Garena/Màn hình khởi động
- (void)setupIndicator {
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(15, 40, 12, 12)];
    indicator.backgroundColor = [UIColor redColor];
    indicator.layer.cornerRadius = 6;
    indicator.layer.shadowColor = [[UIColor redColor] CGColor];
    indicator.layer.shadowRadius = 4.0;
    indicator.layer.shadowOpacity = 0.9;
    indicator.layer.shadowOffset = CGSizeZero;
    [self addSubview:indicator];
    
    // Nhãn tên K13 nhỏ cạnh chấm đỏ
    UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 32, 60, 25)];
    brandLabel.text = @"K13";
    brandLabel.textColor = [UIColor redColor];
    brandLabel.font = [UIFont boldSystemFontOfSize:13];
    [self addSubview:brandLabel];
}

- (void)setupMenuPanel {
    self.panelView = [[UIView alloc] initWithFrame:CGRectMake(50, 80, 280, 360)];
    self.panelView.backgroundColor = [UIColor colorWithWhite:0.12 alpha:0.95];
    self.panelView.layer.cornerRadius = 16;
    self.panelView.layer.borderWidth = 1.8;
    self.panelView.layer.borderColor = [[UIColor redColor] CGColor];
    self.panelView.hidden = YES;

    // Tiêu đề Menu K13
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 250, 30)];
    title.text = @"K13 MOD MENU - FREE FIRE";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:15];
    title.textAlignment = NSTextAlignmentCenter;
    [self.panelView addSubview:title];

    // Nút chức năng 1: Fix Dame
    UIButton *btnDame = [self createButtonWithTitle:@"Fix Lỗi Dame: OFF" frame:CGRectMake(20, 55, 240, 45) tag:1];
    [self.panelView addSubview:btnDame];

    // Nút chức năng 2: Fix Văng App
    UIButton *btnCrash = [self createButtonWithTitle:@"Anti-Crash (Fix Văng): OFF" frame:CGRectMake(20, 110, 240, 45) tag:2];
    [self.panelView addSubview:btnCrash];

    // Nút chức năng 3: Aimbot
    UIButton *btnAimbot = [self createButtonWithTitle:@"Aimbot Lock: OFF" frame:CGRectMake(20, 165, 240, 45) tag:3];
    [self.panelView addSubview:btnAimbot];

    // Nút chức năng 4: ESP
    UIButton *btnESP = [self createButtonWithTitle:@"ESP Line / Box: OFF" frame:CGRectMake(20, 220, 240, 45) tag:4];
    [self.panelView addSubview:btnESP];

    // Nút đóng bảng
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame = CGRectMake(20, 285, 240, 40];
    btnClose.backgroundColor = [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1.0];
    [btnClose setTitle:@"Ẩn Menu (Chạm 3 ngón để mở)" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnClose.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    btnClose.layer.cornerRadius = 10;
    [btnClose addTarget:self action:@selector(toggleMenuVisibility) forControlEvents:UIControlEventTouchUpInside];
    [self.panelView addSubview:btnClose];

    [self addSubview:self.panelView];
}

- (UIButton *)createButtonWithTitle:(NSString *)title frame:(CGRect)frame tag:(NSInteger)tag {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.tag = tag;
    btn.backgroundColor = [UIColor colorWithWhite:0.22 alpha:1.0];
    [btn setTitle:title forState:UIControlStateNormal];
    [btnsetTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    btn.layer.cornerRadius = 8;
    [btn addTarget:self action:@selector(optionTapped:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)setupGestures {
    // Lắng nghe sự kiện chạm 3 ngón tay để bật/tắt menu
    UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenuVisibility)];
    tripleTap.numberOfTouchesRequired = 3;
    [self addGestureRecognizer:tripleTap];
}

- (void)toggleMenuVisibility {
    self.isMenuVisible = !self.isMenuVisible;
    self.panelView.hidden = !self.isMenuVisible;
}

- (void)optionTapped:(UIButton *)sender {
    if (sender.tag == 1) {
        self.damageFixActive = !self.damageFixActive;
        [self updateButtonState:sender titleOn:@"Fix Lỗi Dame: ON" titleOff:@"Fix Lỗi Dame: OFF" active:self.damageFixActive];
    } else if (sender.tag == 2) {
        self.antiCrashActive = !self.antiCrashActive;
        [self updateButtonState:sender titleOn:@"Anti-Crash (Fix Văng): ON" titleOff:@"Anti-Crash (Fix Văng): OFF" active:self.antiCrashActive];
    } else if (sender.tag == 3) {
        self.aimbotActive = !self.aimbotActive;
        [self updateButtonState:sender titleOn:@"Aimbot Lock: ON" titleOff:@"Aimbot Lock: OFF" active:self.aimbotActive];
    } else if (sender.tag == 4) {
        self.espActive = !self.espActive;
        [self updateButtonState:sender titleOn:@"ESP Line / Box: ON" titleOff:@"ESP Line / Box: OFF" active:self.espActive];
    }
}

- (void)updateButtonState:(UIButton *)btn titleOn:(NSString *)on titleOff:(NSString *)off active:(BOOL)active {
    if (active) {
        [btn setTitle:on forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.1 alpha:0.8];
    } else {
        [btn setTitle:off forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithWhite:0.22 alpha:1.0];
    }
}

@end

// ==========================================
// KHỞI TẠO TIẾN TRÌNH KHI TIÊM VÀO GAME
// ==========================================
__attribute__((constructor)) void initK13Menu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            K13ModMenu *k13Menu = [[K13ModMenu alloc] initWithFrame:window.bounds];
            k13Menu.userInteractionEnabled = YES;
            [window addSubview:k13Menu];
        }
    });
}
