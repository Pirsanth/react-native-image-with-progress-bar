//
//  PIRImageWithSpinner.m
//  loadingImageIos
//
//  Created by Pirsanth on 24/03/2021.
//

#import "PIRImageWithSpinner.h"
#import <React/RCTLog.h>

@interface PIRImageWithSpinner()<NSURLSessionDownloadDelegate>
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) NSURLSession *urlSession;
//@property (nonatomic) NSString *latestUrl;
@property (nonatomic) NSURLSessionDownloadTask *latestTask;

@property (nonatomic) UIView *progressBarContainer;
@property (nonatomic) UIView *progressBar;
@property (nonatomic) NSLayoutConstraint *lastProgressBarWidthConstraint;

//this is exactly what the prop on the JS side is
@property (nonatomic) NSString *currentMode;
@property (nonatomic) BOOL noContentLength;
@property (nonatomic) BOOL isLoadingImage;
@end

@implementation PIRImageWithSpinner
- (instancetype)init {
      self = [super init];
  
    if(self != nil){
      self.noContentLength = NO;
      self.isLoadingImage = YES;
      [self setUpSpinner];
      [self setUpImageView];
      [self setUpImageDownload];
      [self setUpProgressBar];
      
      
      
      
      //default borderWidth and radius
//      [self.layer setBorderWidth:1];
      //set the default resize mode
      [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    return self;
}

-(void)updateUIBasedOnModeAndContentLength{
  if([self.currentMode isEqualToString:@"bar"]){
    //if is a bar and it does NOT HAVE content length: show spinner
    if(self.noContentLength){
      [self showSpinnerHideBar];
    }
    //if is a bar and it has content length: show progress bar
    else {
      [self showBarHideSpinner];
    }
  }
  //if its just spinner: show spinner
  else if([self.currentMode isEqualToString:@"spinner"]){
    [self showSpinnerHideBar];
  }
}

-(void)updateMode:(NSString *)mode{
  //always mirrors the current prop on the JS side
  self.currentMode = mode;
  //update the ui only if it is STILL loading an image
  //even if the url does not get set by default isLoadingImage is YES (look at the constructor)
  if(self.isLoadingImage){
    [self updateUIBasedOnModeAndContentLength];
  }
}

-(void)showSpinnerHideBar{
  self.progressBarContainer.hidden = YES;
  self.activityIndicator.hidden = NO;
}
-(void)showBarHideSpinner{
  self.progressBarContainer.hidden = NO;
  self.activityIndicator.hidden = YES;
}

-(void)updateProgressBarPercentage:(float)percentage{
  //only if there is content length && if the bar is shown is this ran
  //should use weak self i think
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.progressBarContainer removeConstraint:self.lastProgressBarWidthConstraint];
    NSLayoutConstraint *newProgressBarConstraint =[NSLayoutConstraint
                                        constraintWithItem:self.progressBar
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.progressBarContainer
                                        attribute:NSLayoutAttributeWidth
                                        multiplier:percentage
                                        constant:0];
    self.lastProgressBarWidthConstraint = newProgressBarConstraint;
    [self.progressBarContainer addConstraint:newProgressBarConstraint];
  });
}

-(void)setProgressBarColorWithUIColor:(UIColor *)color{
  [self.progressBar setBackgroundColor:color];
}
-(void)setProgressBarTrackColorWithUIColor:(UIColor *)color{
  [self.progressBarContainer setBackgroundColor:color];
}


-(void)setUpProgressBar{
  UIView *barContainer = [[UIView alloc] init];
  //bar container style
//  [barContainer setBackgroundColor:[UIColor blueColor]];
//  barContainer.layer.borderWidth = 1;
  
  UIColor *green = [UIColor colorWithRed:3 green:218 blue:197 alpha:1.0];
  UIColor *grey = [UIColor colorWithRed:219 green:219 blue:219 alpha:1.0];
  [barContainer setBackgroundColor:grey];
  [barContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
  self.progressBarContainer = barContainer;
  [self addSubview:barContainer];
  
  NSLayoutConstraint *centreHorizontallyConstraint = [NSLayoutConstraint
                                        constraintWithItem:barContainer
                                        attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                        attribute:NSLayoutAttributeCenterX
                                        multiplier:1.0
                                        constant:0];
  NSLayoutConstraint *centreVerticallyConstraint = [NSLayoutConstraint
                                        constraintWithItem:barContainer
                                        attribute:NSLayoutAttributeCenterY
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                        attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                        constant:0];
  [self addConstraints:@[centreHorizontallyConstraint, centreVerticallyConstraint]];

NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:barContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:5];
NSLayoutConstraint *width =[NSLayoutConstraint
                                    constraintWithItem:barContainer
                                    attribute:NSLayoutAttributeWidth
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                    attribute:NSLayoutAttributeWidth
                                    multiplier:0.85
                                    constant:0];
[self addConstraints:@[width]];
  [barContainer addConstraint:height];
  
  UIView *bar = [[UIView alloc] init];
//  [bar setBackgroundColor:[UIColor blackColor]];
  [bar setBackgroundColor:[UIColor greenColor]];
  [barContainer addSubview:bar];
  self.progressBar = bar;
  
  NSLayoutConstraint *barHeight = [NSLayoutConstraint constraintWithItem:bar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:barContainer attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
  NSLayoutConstraint *widthOfBar =[NSLayoutConstraint
                                      constraintWithItem:bar
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:barContainer
                                      attribute:NSLayoutAttributeWidth
                                      multiplier:0
                                      constant:0];
  
  self.lastProgressBarWidthConstraint = widthOfBar;

  NSLayoutConstraint *centreBarHorizontally = [NSLayoutConstraint
                                        constraintWithItem:bar
                                        attribute:NSLayoutAttributeLeft
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:barContainer
                                        attribute:NSLayoutAttributeLeft
                                        multiplier:1.0
                                        constant:0];
  NSLayoutConstraint *centreBarVertically = [NSLayoutConstraint
                                        constraintWithItem:bar
                                        attribute:NSLayoutAttributeCenterY
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:barContainer
                                        attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                        constant:0];
  
  [bar setTranslatesAutoresizingMaskIntoConstraints:NO];
  [bar addConstraints:@[]];
  [barContainer addConstraints:@[barHeight, centreBarVertically, centreBarHorizontally, widthOfBar]];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
        NSData *data = [NSData dataWithContentsOfURL:location];
        UIImage *img = [UIImage imageWithData:data];
        
  //the data is not an image data
        if(img == nil){
          [self sendErrorToJSWithMessage:@"Failed to decode an image from the data in the url. Are you sure the url returns an image?"];
          return;
        }
  
        //set the image on the main thread...
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.imageView setImage:img];
          self.isLoadingImage = NO;
          self.progressBarContainer.hidden = YES;
          self.activityIndicator.hidden = YES;
        });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
      //means an error occured while downloading the data..
      //if there is an error and it did NOT arise from the cancellation of the task...
      if(error != nil && ![error.localizedDescription isEqual:@"cancelled"]){
        NSString *messageToJs = error.localizedDescription;
        [self sendErrorToJSWithMessage:messageToJs];
      }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics{

}

- (void)sendErrorToJSWithMessage:(NSString *)message {
  if(self.onLoadError != nil){
    self.onLoadError(@{
      @"errorMessage": message
                     });
  }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
  
  //if its the first time it is ran...
  if(totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown && !self.noContentLength){
    [self sendErrorToJSWithMessage:@"The content-length http header for the given url is empty. This library cannot compute the progress of the image download without a content-length header"];
    self.noContentLength = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self updateUIBasedOnModeAndContentLength];
    });
    /*
     now if there is no content-length, continue the download without the progress updates
    */
//    return [downloadTask cancel];
  }
  
  //if we cannot calculate the progress from the content length, then dont
  if(totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown){
    return;
  }
  float percentageComplete = (float) totalBytesWritten/totalBytesExpectedToWrite;

  [self updateProgressBarPercentage:percentageComplete];

}


-(void)loadImageUrlString:(NSString *)imageUrlString {
  self.noContentLength = NO;
  self.isLoadingImage = YES;
  [self updateUIBasedOnModeAndContentLength];
  [self.imageView setImage:nil];
  NSURL *url = [NSURL URLWithString:imageUrlString];
//  self.latestUrl = imageUrlString;

  //this line is fine if self.latestTask is nil
  //but what if the task has already completed
  //if the previous image is still downloading, cancel...
  if(self.latestTask.state == NSURLSessionTaskStateRunning){
    [self.latestTask cancel];
  }
  
  [self updateProgressBarPercentage:0.0];
  NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithURL:url];
  self.latestTask = task;
  [task resume];
}


-(void)setUpImageDownload{
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
  self.urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

-(void)setUpImageView{
  self.imageView = [[UIImageView alloc] init];
  [self addSubview:self.imageView];
  [self centerViewInSuperview:self.imageView];
  [self makeViewTakeUpHeighAndWidthOfSuperview:self.imageView];
}

-(void)setUpSpinner{
    self.activityIndicator = [[UIActivityIndicatorView alloc] init];
    [self addSubview:self.activityIndicator];
    [self centerViewInSuperview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    //it is hidden because by default we show a progress bar
    self.activityIndicator.hidden = YES;
}

-(void)centerViewInSuperview:(UIView *)view{
  [view setTranslatesAutoresizingMaskIntoConstraints:NO];
  NSLayoutConstraint *centreHorizontallyConstraint = [NSLayoutConstraint
                                        constraintWithItem:view
                                        attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                        attribute:NSLayoutAttributeCenterX
                                        multiplier:1.0
                                        constant:0];
  NSLayoutConstraint *centreVerticallyConstraint = [NSLayoutConstraint
                                        constraintWithItem:view
                                        attribute:NSLayoutAttributeCenterY
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                        attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                        constant:0];
  [self addConstraints:@[centreHorizontallyConstraint, centreVerticallyConstraint]];
}

-(void)makeViewTakeUpHeighAndWidthOfSuperview:(UIView *)view{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];

  NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
  NSLayoutConstraint *width =[NSLayoutConstraint
                                      constraintWithItem:view
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self
                                      attribute:NSLayoutAttributeWidth
                                      multiplier:1.0
                                      constant:0];
  [self addConstraints:@[height, width]];
}

@end
