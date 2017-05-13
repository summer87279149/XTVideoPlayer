
#import "XTStatusView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+XTAdditions.h"

@implementation XTStatusView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

//- (void)awakeFromNib {
//    [self setupView];
//}

- (void)setupView {
    self.flashControl = [[XTFlashControl alloc]init];
    [self addSubview:self.flashControl];
    self.elapsedTimeLabel = [[UILabel alloc]init];
    self.elapsedTimeLabel.text = @"00:00:00";
    [self addSubview:self.elapsedTimeLabel];
    self.flashControl.delegate = self;
}

- (void)flashControlWillExpand {
    [UIView animateWithDuration:0.2f animations:^{
        self.elapsedTimeLabel.alpha = 0.0f;
    }];
}

- (void)flashControlDidCollapse {
    [UIView animateWithDuration:0.1f animations:^{
        self.elapsedTimeLabel.alpha = 1.0f;
    }];
}

@end
