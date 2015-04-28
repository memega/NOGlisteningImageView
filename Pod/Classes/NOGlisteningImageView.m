/*
 The MIT License (MIT)
 Copyright © 2015 Yuriy Panfyorov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "NOGlisteningImageView.h"

#import <QuartzCore/QuartzCore.h>

NSInteger const NOGlisteningRepeatForever = -1;

// defaults
static CGFloat const            _NOGlisteningDefaultAngle = M_PI / 6.0;
static NSTimeInterval const     _NOGlisteningDefaultTimerInterval = 3.;
static NSTimeInterval const     _NOGlisteningDefaultDuration = .5;

// keys
static NSString * const         _NOGlisteningLayerAnimationKey = @"NOGlisteningLayerAnimationKey";

@interface NOGlisteningImageView ()
{
    BOOL _needsUpdateLayers;
}

@property (nonatomic) CALayer *containerLayer;
@property (nonatomic) CAGradientLayer *highlightLayer;
@property (nonatomic) CALayer *maskLayer;

// highlight layer support
@property (nonatomic) UIColor *edgeHighlightColor;

// animation support
@property (nonatomic) NSTimer *initialDelayTimer;
@property (nonatomic) NSTimer *highlightTimer;
@property (nonatomic) BOOL initialDelayTimerPlayed;
@property (nonatomic) NSInteger repeatCountInternal;

@end

@implementation NOGlisteningImageView

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self)
    {
        [self setupDefaultProperties];
        [self setNeedsUpdateLayers];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self)
    {
        [self setupDefaultProperties];
        [self setNeedsUpdateLayers];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupDefaultProperties];
        [self setNeedsUpdateLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupDefaultProperties];
        [self setNeedsUpdateLayers];
    }
    return self;
}

- (void)dealloc
{
    self.highlightAnimationCompletion = nil;
    [self stopHighlight];
}

#pragma mark - Initialization

- (void)setupDefaultProperties
{
    self.initialHighlightDelay =    0.;
    self.highlightRepeatCount =     NOGlisteningRepeatForever;
    self.highlightColor =           [UIColor whiteColor];

    self.highlightAngle =           _NOGlisteningDefaultAngle;
    self.highlightInterval =        _NOGlisteningDefaultTimerInterval;
    self.highlightDuration =        _NOGlisteningDefaultDuration;
}

- (void)didMoveToWindow
{
    if (self.window)
    {
        [self startHighlight];
    }
    else
    {
        [self stopHighlight];
    }
}

- (void)setNeedsUpdateLayers
{
    _needsUpdateLayers = YES;
}

- (void)updateLayersIfNeeded
{
    if (_needsUpdateLayers)
    {
        _needsUpdateLayers = NO;
        
        // no animations here
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        if (self.containerLayer == nil)
        {
            CALayer *containerLayer = [CALayer layer];
            [self.layer addSublayer:containerLayer];
            self.containerLayer = containerLayer;
        }
        
        self.containerLayer.frame = self.bounds;
        
        if (self.highlightLayer == nil)
        {
            CAGradientLayer *highlightLayer = [CAGradientLayer layer];
            
            highlightLayer.startPoint = CGPointMake(0, 0.5);
            highlightLayer.endPoint = CGPointMake(1, 0.5);

            highlightLayer.hidden = YES;
            
            [self.containerLayer addSublayer:highlightLayer];
            
            self.highlightLayer = highlightLayer;
        }
        
        // color
        self.highlightLayer.colors = @[
                                       (id)self.edgeHighlightColor.CGColor,
                                       (id)self.highlightColor.CGColor,
                                       (id)self.edgeHighlightColor.CGColor,
                                       ];
        
        UIImage *maskImage = self.image;
        CGFloat rotatedWidth = maskImage.size.width * ABS(cos(self.highlightAngle)) + maskImage.size.height * ABS(sin(self.highlightAngle));
        CGFloat rotatedHeight = maskImage.size.width * ABS(sin(self.highlightAngle)) + maskImage.size.height * ABS(cos(self.highlightAngle));
        
        // sizes
        self.highlightLayer.contentsScale = self.layer.contentsScale;
        self.highlightLayer.bounds = CGRectMake(0, 0, rotatedWidth, rotatedHeight);
        [self.highlightLayer setValue:@(self.highlightAngle) forKeyPath:@"transform.rotation"];
        self.highlightLayer.shouldRasterize = YES;
        
        if (self.maskLayer == nil)
        {
            CALayer *maskLayer = [CALayer layer];
            self.maskLayer = maskLayer;
            self.maskLayer.contentsScale = self.layer.contentsScale;
            self.containerLayer.mask = maskLayer;
        }
        
        self.maskLayer.contents = (id)maskImage.CGImage;
        self.maskLayer.frame = self.bounds;
        self.maskLayer.shouldRasterize = YES;
        
        [CATransaction commit];
    }
}

#pragma mark - Dirtying properties and validation

- (void)setHighlightColor:(UIColor *)highlightColor
{
    if ([_highlightColor isEqual:highlightColor]) return;
    
    _highlightColor = highlightColor;
    
    // get edge colors
    CGFloat components[4];
    [_highlightColor getRed:components green:components+1 blue:components+2 alpha:components+3];
    self.edgeHighlightColor = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:0.];
    
    [self setNeedsUpdateLayers];
}

- (void)setHighlightAngle:(CGFloat)angle
{
    if (_highlightAngle == angle) return;
    
    _highlightAngle = angle;

    [self setNeedsUpdateLayers];
}

- (void)setHighlightAngleInDegrees:(CGFloat)highlightAngleInDegrees
{
    [self setHighlightAngle:highlightAngleInDegrees * M_PI / 180.0];
}

- (CGFloat)highlightAngleInDegrees
{
    return self.highlightAngle * 180.0 / M_PI;
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    
    [self setNeedsUpdateLayers];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    [self setNeedsUpdateLayers];
}

- (BOOL)isHighlighting
{
    return self.initialDelayTimer.isValid || self.highlightTimer.isValid;
}

#pragma mark - Animation

- (void)startHighlight
{
    if (self.initialHighlightDelay > 0.)
    {
        if (!self.initialDelayTimerPlayed)
        {
            if (self.initialDelayTimer == nil)
            {
                self.initialDelayTimer = [NSTimer scheduledTimerWithTimeInterval:self.initialHighlightDelay
                                                                          target:self
                                                                        selector:@selector(handleInitialTimer:)
                                                                        userInfo:nil
                                                                         repeats:NO];
                self.initialDelayTimerPlayed = YES;
            }
        }
        else
        {
            if (self.initialDelayTimer)
            {
                [self.initialDelayTimer invalidate];
                self.initialDelayTimer = nil;
            }
            
            [self beginHighlightTimer];
        }
    }
    else
    {
        [self beginHighlightTimer];
    }
}

- (void)handleInitialTimer:(NSTimer *)timer
{
    [timer invalidate];
    self.initialDelayTimer = nil;
    
    [self beginHighlightTimer];
}

- (void)beginHighlightTimer
{
    if (self.highlightTimer == nil)
    {
        self.highlightTimer = [NSTimer scheduledTimerWithTimeInterval:self.highlightInterval
                                                               target:self
                                                             selector:@selector(handleTimer:)
                                                             userInfo:nil
                                                              repeats:YES];
    }
    
    self.repeatCountInternal = self.highlightRepeatCount;
    
    [self playHighlight];
}

- (void)handleTimer:(NSTimer *)timer
{
    [self playHighlight];
}

- (void)stopHighlight
{
    self.initialDelayTimerPlayed = NO;

    if (self.initialDelayTimer)
    {
        [self.initialDelayTimer invalidate];
        self.initialDelayTimer = nil;
    }
    
    if (self.highlightTimer)
    {
        [self.highlightTimer invalidate];
        self.highlightTimer = nil;
    }
}

- (void)playHighlight
{
    if (self.alpha == 0)
        return;
    
    if (self.hidden)
        return;
    
    if (self.window == nil)
        return;
    
    [self updateLayersIfNeeded];

    [self.highlightLayer removeAnimationForKey:_NOGlisteningLayerAnimationKey];

    CGPoint startLayerPoint = CGPointMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.highlightLayer.bounds) * cos(self.highlightAngle),
                                          CGRectGetMidY(self.bounds) - CGRectGetWidth(self.highlightLayer.bounds) * sin(self.highlightAngle));
    
    CGPoint endLayerPoint = CGPointMake(CGRectGetMidX(self.bounds) + CGRectGetWidth(self.highlightLayer.bounds) * cos(self.highlightAngle),
                                        CGRectGetMidY(self.bounds) + CGRectGetWidth(self.highlightLayer.bounds) * sin(self.highlightAngle));
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.highlightLayer.hidden = NO;
    self.highlightLayer.position = startLayerPoint;
    [CATransaction commit];
    
    CABasicAnimation *movementAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    movementAnimation.fromValue = [NSValue valueWithCGPoint:startLayerPoint];
    movementAnimation.toValue = [NSValue valueWithCGPoint:endLayerPoint];
    movementAnimation.duration = self.highlightDuration;
    movementAnimation.fillMode = kCAFillModeRemoved;
    
    movementAnimation.delegate = self;
    
    self.highlightLayer.position = endLayerPoint;
    [self.highlightLayer addAnimation:movementAnimation forKey:_NOGlisteningLayerAnimationKey];
    
    if (self.repeatCountInternal > NOGlisteningRepeatForever)
    {
        self.repeatCountInternal--;
        if (self.repeatCountInternal == 0)
        {
            [self stopHighlight];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.highlightLayer.hidden = YES;
    [CATransaction commit];
    
    if (self.highlightAnimationCompletion)
    {
        self.highlightAnimationCompletion(self);
    }
}

@end
