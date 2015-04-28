/*
 The MIT License (MIT)
 Copyright © 2015 Yuriy Panfyorov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

/**
 *  @abstract Default value for highlightRepeatCount, meaning that highlight will repeat forever, equals to -1.
 */
FOUNDATION_EXPORT NSInteger const NOGlisteningRepeatForever;

/**
 @abstract A drop-in replacement for UIImageView. Repeatedly plays a simple highlight animation,
 similar to a highlight on a coin when a bright light moves quickly alongside it.
 
 @discussion Originally developed to be used in storyboards or nibs when it is needed to draw user
 attention to certain graphical elements. All public properties can be configured by
 setting in the User Defined Runtime Attributes section in Xcode's Identity Inspector.
 
 Animations start playing automatically when this view is added to a UIWindow, and stops
 when it is removed form one.
 
 @warning This effect is internally implemented as a masked Quartz gradient layer, so be cautious of performance.
 */
@interface NOGlisteningImageView : UIImageView

/**
 @abstract Time in seconds before the view begins playing highlight animations after being added to a UIWindow.
 @discussion This property is honored every time startHighlight selector is called. Negative values are ignored.
  Default value is 0.
 */
@property (nonatomic) NSTimeInterval initialHighlightDelay;

/**
 @abstract How many times the highlight animation should play.
 @discussion Resets every time startHighlight selector is called. Default value is NOGlisteningRepeatForever.
 */
@property (nonatomic) NSInteger highlightRepeatCount;

/**
 @abstract Time in seconds between the consecutive highlight animations.
 @discussion When set to a value less than highlightDuration, the animations would not finish completely. Default value is 3.0.
 */
@property (nonatomic) NSTimeInterval highlightInterval;

/**
 @abstract Duration of the highlight animation in seconds.
 @discussion Default value is 0.5.
 */
@property (nonatomic) NSTimeInterval highlightDuration;

/**
 @abstract Highlight movement direction in radians.
 @discussion Default value is π/6.
 */
@property (nonatomic) CGFloat highlightAngle;

/**
 @abstract Highlight movement direction in degrees.
 @discussion Default value is 30°.
 */
@property (nonatomic) CGFloat highlightAngleInDegrees;

/**
 @abstract Color of the highlight.
 @discussion Default value is white color.
 */
@property (nonatomic) UIColor *highlightColor;

/**
 @abstract Starts highlight animations.
 @discussion The animations start after initialHighlightDelay seconds and repeat highlightRepeatCount times.
 */
- (void)startHighlight;

/**
 @abstract Stops highlight animations.
 */
- (void)stopHighlight;

/**
 @abstract Returns YES if the highlight animation is currently playing or scheduled to play soon.
 */
@property (nonatomic, readonly) BOOL isHighlighting;

/**
 @abstract If set, the block gets called each time a single highlight animation is completed.
 */
@property (nonatomic, copy) void (^highlightAnimationCompletion)(NOGlisteningImageView *glisteningView);

@end
