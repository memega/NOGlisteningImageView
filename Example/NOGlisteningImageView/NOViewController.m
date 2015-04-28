//
//  NOViewController.m
//  NOGlisteningImageView
//
//  Created by Yuriy Panfyorov on 04/28/2015.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import "NOViewController.h"

#import <NOGlisteningImageView/NOGlisteningImageView.h>

@interface NOViewController ()

@property (nonatomic) IBOutlet NOGlisteningImageView *coin;
@property (nonatomic) IBOutlet NOGlisteningImageView *textH;
@property (nonatomic) IBOutlet NOGlisteningImageView *textV;

@property (nonatomic) IBOutlet UILabel *angleLabel;
@property (nonatomic) IBOutlet UISlider *angleSlider;

@end

@implementation NOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.angleSlider.value = self.coin.highlightAngleInDegrees;
    
    [self updateAngles];
}

- (IBAction)changeAngle:(id)sender
{
    [self updateAngles];
}

- (void)updateAngles
{
    self.angleLabel.text = [NSString stringWithFormat:@"%.0f", self.angleSlider.value];
    
    self.coin.highlightAngleInDegrees = self.angleSlider.value;
    self.textH.highlightAngleInDegrees = self.angleSlider.value;
    self.textV.highlightAngleInDegrees = self.angleSlider.value;
}

@end
