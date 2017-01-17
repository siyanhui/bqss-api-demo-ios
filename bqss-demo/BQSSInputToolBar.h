//
//  InputToolBar.h
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INPUT_TOOL_BAR_HEIGHT 50.0f
#define TEXTVIEW_MAX_HEIGHT 200.0f
#define TEXTVIEW_MIN_HEIGHT 36.0f
#define ADDTION_HEIGHT 36.0f

typedef NS_ENUM(NSUInteger, InputType) {
    
    InputTypeQuater = 1,

    InputTypeHalf = 2,
    
    InputTypeFull = 3
    
};

@protocol InputToolBarViewDelegate;
@interface BQSSInputToolBar : UIView<UITextViewDelegate, UISearchBarDelegate>

@property(weak, nonatomic) id<InputToolBarViewDelegate> delegate;
@property(strong, nonatomic) UIView *sepeLine1;
@property(strong, nonatomic) UIView *sepeLine2;
@property (nonatomic, strong) UISearchBar *searchBar;
@property(strong, nonatomic) UITextView *inputTextView;
@property(strong, nonatomic) UIButton *sendButton;
@property(strong, nonatomic) UIView *addtionView;

@property(strong, nonatomic) UIButton *emojiButton;
@property(strong, nonatomic) UIButton *imageButton;
@property(strong, nonatomic) UIButton *cameraButton;
@property(strong, nonatomic) UIButton *audioButton;
@property(strong, nonatomic) UIButton *locationButton;
@property(strong, nonatomic) UIButton *plusButton;

@property(nonatomic) InputType inputType;

/*!
 the height of inputTextView
 */
@property(assign, nonatomic) float inputTextViewHeight;

@property(assign, nonatomic) float toolbarHeight;

- (instancetype)initWithFrame:(CGRect)frame inputType:(InputType)inputType;

- (void)didTouchEmojiDown:(UIButton *)sender;

@end


@protocol InputToolBarViewDelegate <NSObject>

@optional

/*!
 keyboard will show with frame delegate method
 
 @param keyboardFrame  the Frame of keyboard
 */
- (void)keyboardWillShowWithFrame:(CGRect)keyboardFrame;

/*!
 keyboard will hide delegate method
 */
- (void)keyboardWillHide;

- (void)toggleSearchMode;
- (void)didTouchOtherButtonDown;
- (void)searchBarBeginOperation;
- (void)searchBarEndOperation;
- (void)searchEmojisWith:(NSString *)key;

- (void)sendTextWith:(NSString *)text;

/**
 *  the delegate method handles the change of toolbar height
 */
- (void)toolbarHeightDidChangedTo:(CGFloat)height;

@end
