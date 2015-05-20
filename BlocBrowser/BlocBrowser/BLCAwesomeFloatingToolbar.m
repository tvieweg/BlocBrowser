//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Trevor Vieweg on 5/18/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UIButton *currentButton;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture; 

@end

@implementation BLCAwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    
    self = [super init];
    
    if (self) {
        
        
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            button.backgroundColor = colorForThisButton;
            button.titleLabel.textColor = [UIColor whiteColor];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer: self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer: self.longPressGesture];
    }
    
    return self;
}



- (void) layoutSubviews {
    //set the frames for the 4 buttons
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        //set locations based on index
        if (currentButtonIndex < 2) {
            //0 and 1, so on top.
            buttonY = 0;
        } else {
            
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        //same dividing for x
        if (currentButtonIndex % 2 == 0) {
            buttonX = 0;
        } else {
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);

    }
}

#pragma mark - Touch Handling

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView: self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self]; 
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = [recognizer scale];
    
        NSLog(@"New scale: %f", scale);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithSizeChange:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithSizeChange:scale];
        }
        
    }
}

- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        NSUInteger numberOfColors = self.colors.count;
        NSMutableArray *newColorArray = [self.colors mutableCopy];
        
        //Rotate colors on each click.
        //last item in colors becomes first item in new color array
        newColorArray[0] = self.colors[numberOfColors - 1];
        
        //iterate through newColorArray from second item to end to rotate colors
        for (NSUInteger i = 1; i < newColorArray.count; i++) {
            newColorArray[i] = self.colors[i-1];
        }
        self.colors = newColorArray;

        for (UIView *thisButton in self.buttons) {
            NSUInteger currentTitleIndex = [self.buttons indexOfObject:thisButton];
            thisButton.backgroundColor = self.colors[currentTitleIndex];
        }
    }
}


#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        self.userInteractionEnabled = enabled; 
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}
@end
