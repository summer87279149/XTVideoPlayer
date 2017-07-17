#import "ViewController2.h"
#import "XTCameraManager.h"
#import "XTPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import "XTFlashControl.h"
#import "XTCameraModeView.h"
#import "XTOverlayView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSTimer+Additions.h"

@interface ViewController2 () <XTPreviewViewDelegate>
@property (nonatomic) XTCameraMode cameraMode;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) XTCameraManager *cameraController;
@property (weak, nonatomic) IBOutlet XTPreviewView *previewView;
@property (weak, nonatomic) IBOutlet XTOverlayView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailButton;

@end

@implementation ViewController2

- (IBAction)flashControlChanged:(id)sender {
    NSInteger mode = [(XTFlashControl *)sender selectedMode];
    if (self.cameraMode == XTCameraModePhoto) {
        self.cameraController.flashMode = mode;
    } else {
        self.cameraController.torchMode = mode;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateThumbnail:)
                                                 name:XTThumbnailCreatedNotification
                                               object:nil];
    self.cameraMode = XTCameraModeVideo;
    self.cameraController = [[XTCameraManager alloc] init];
    
    NSError *error;
    if ([self.cameraController setupSession:&error]) {
        [self.previewView setSession:self.cameraController.captureSession];
        self.previewView.delegate = self;
        [self.cameraController startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    self.previewView.tapToFocusEnabled = self.cameraController.cameraSupportsTapToFocus;
    self.previewView.tapToExposeEnabled = self.cameraController.cameraSupportsTapToExpose;
    
}

- (void)updateThumbnail:(NSNotification *)notification {
    UIImage *image = notification.object;
    [self.thumbnailButton setBackgroundImage:image forState:UIControlStateNormal];
    self.thumbnailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailButton.layer.borderWidth = 1.0f;
}

- (IBAction)showCameraRoll:(id)sender {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:controller animated:YES completion:nil];
}

- (AVAudioPlayer *)playerWithResource:(NSString *)resourceName {
    NSURL *url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"caf"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    player.volume = 0.1f;
    return player;
}

- (IBAction)cameraModeChanged:(id)sender {
    self.cameraMode = [sender cameraMode];
}


- (IBAction)swapCameras:(id)sender {
    if ([self.cameraController switchCameras]) {
        BOOL hidden = NO;
        if (self.cameraMode == XTCameraModePhoto) {
            hidden = !self.cameraController.cameraHasFlash;
        } else {
            hidden = !self.cameraController.cameraHasTorch;
        }
        self.overlayView.flashControlHidden = hidden;
        self.previewView.tapToExposeEnabled = self.cameraController.cameraSupportsTapToExpose;
        self.previewView.tapToFocusEnabled = self.cameraController.cameraSupportsTapToFocus;
        [self.cameraController resetFocusAndExposureModes];
    }
}

- (IBAction)captureOrRecord:(UIButton *)sender {
    if (self.cameraMode == XTCameraModePhoto) {
        [self.cameraController captureStillImage];
    } else {
        if (!self.cameraController.isRecording) {
            dispatch_async(dispatch_queue_create("com.tapharmonic.kamera", NULL), ^{
                [self.cameraController startRecording];
                [self startTimer];
            });
        } else {
            [self.cameraController stopRecording];
            [self stopTimer];
        }
        sender.selected = !sender.selected;
    }
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(updateTimeDisplay)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimeDisplay {
    CMTime duration = self.cameraController.recordedDuration;
    NSUInteger time = (NSUInteger)CMTimeGetSeconds(duration);
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%02i";
    NSString *timeString = [NSString stringWithFormat:format, hours, minutes, seconds];
    self.overlayView.statusView.elapsedTimeLabel.text = timeString;
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    self.overlayView.statusView.elapsedTimeLabel.text = @"00:00:00";
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)tappedToFocusAtPoint:(CGPoint)point {
    [self.cameraController focusAtPoint:point];
}

- (void)tappedToExposeAtPoint:(CGPoint)point {
    [self.cameraController exposeAtPoint:point];
}

- (void)tappedToResetFocusAndExposure {
    [self.cameraController resetFocusAndExposureModes];
}

@end
