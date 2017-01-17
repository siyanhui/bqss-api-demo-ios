//
//  InputToolBar.m
//  bqss-demo
//
//  Created by isan on 29/12/2016.
//  Copyright © 2016 siyanhui. All rights reserved.
//

#import "BQSSInputToolBar.h"
#import "Masonry.h"

@interface BQSSInputToolBar () {
    NSTimer *searchTimer;
}

@end
@implementation BQSSInputToolBar

- (instancetype)initWithFrame:(CGRect)frame inputType:(InputType)inputType {
    self = [super initWithFrame:frame];
    if (self) {
        self.inputType = inputType;
        [self setView];
        [self registerNotification];
    }
    return self;
}

- (void)dealloc
{
    [self unRegisterNotification];
}

- (void)registerNotification
{
    [self unRegisterNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unRegisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveKeyboardWillShowNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         if ([self.delegate respondsToSelector:@selector(keyboardWillShowWithFrame:)]) {
                             [self.delegate keyboardWillShowWithFrame:keyboardEndFrame];
                         }
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)didReceiveKeyboardWillHideNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
//    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];    NSRect: {{0, 736}, {414, 271}}
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         if ([self.delegate respondsToSelector:@selector(keyboardWillShowWithFrame:)]) {
                             [self.delegate keyboardWillShowWithFrame:CGRectMake(0, 0, 0, 0)];
                         }
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)setView
{
    _inputTextViewHeight = TEXTVIEW_MIN_HEIGHT;
    _toolbarHeight = _inputTextViewHeight + ADDTION_HEIGHT + 14;
    self.backgroundColor = [UIColor whiteColor];
    _sepeLine1 = [[UIView alloc] init];
    _sepeLine1.backgroundColor =  [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [self addSubview:_sepeLine1];
    [_sepeLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@1);
    }];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.backgroundImage = [UIImage imageNamed:@"searchbar_back"];
    _searchBar.placeholder = @"搜索感兴趣的图片";
    _searchBar.tintColor = [UIColor blueColor];
    _searchBar.barTintColor = self.backgroundColor;
    
    UITextField *searchField = [_searchBar valueForKey:@"searchField"];
    if (searchField) {
        [searchField setBackgroundColor:[UIColor colorWithRed:216.0 / 255.0 green:216.0 / 255.0 blue:216.0 / 255.0 alpha:1.0]];
    }
    
    
    _searchBar.delegate = self;
    [self addSubview:_searchBar];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(15);
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.height.equalTo(@(self.inputTextViewHeight));
        make.top.equalTo(self.mas_top).with.offset(7);
    }];
    _searchBar.hidden = true;
    
    _inputTextView = [[UITextView alloc] init];
    _inputTextView.delegate = self;
    [_inputTextView setExclusiveTouch:YES];
    [_inputTextView setTextColor:[UIColor blackColor]];
    [_inputTextView setFont:[UIFont systemFontOfSize:16]];
    [_inputTextView setReturnKeyType:UIReturnKeySend];
    _inputTextView.backgroundColor = [UIColor colorWithRed:248 / 255.f green:248 / 255.f blue:248 / 255.f alpha:1];
    _inputTextView.enablesReturnKeyAutomatically = YES;
    _inputTextView.layer.cornerRadius = 4;
    _inputTextView.layer.masksToBounds = YES;
    _inputTextView.layer.borderWidth = 0.3f;
    _inputTextView.layer.borderColor = [UIColor colorWithRed:60 / 255.f green:60 / 255.f blue:60 / 255.f alpha:1].CGColor;
    
    [self addSubview:_inputTextView];
    [self layoutViews];
    
    _addtionView = [[UIView alloc] init];
    _addtionView.backgroundColor = [UIColor clearColor];
    [self addSubview:_addtionView];
    [_addtionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.top.equalTo(self.inputTextView.mas_bottom).with.offset(7);
    }];
    
    _sepeLine2 = [[UIView alloc] init];
    _sepeLine2.backgroundColor =  [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    [self addSubview:_sepeLine2];
    [_sepeLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addtionView.mas_top).with.offset(-1);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@1);
    }];
    
    _emojiButton = [[UIButton alloc] init];
    [_emojiButton setImage:[UIImage imageNamed:@"emoji_normal"] forState:UIControlStateNormal];
    [_emojiButton setImage:[UIImage imageNamed:@"emoji_selected"] forState:UIControlStateSelected];
    [_emojiButton addTarget:self action:@selector(didTouchEmojiDown:) forControlEvents:UIControlEventTouchUpInside];
    [_addtionView addSubview:_emojiButton];
    
    _imageButton = [[UIButton alloc] init];
    [_imageButton setImage:[UIImage imageNamed:@"image"] forState:UIControlStateNormal];
    [_imageButton addTarget:self action:@selector(didTouchOtherButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_addtionView addSubview:_imageButton];
    
    _cameraButton = [[UIButton alloc] init];
    [_cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_cameraButton addTarget:self action:@selector(didTouchOtherButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_addtionView addSubview:_cameraButton];
    
    _audioButton = [[UIButton alloc] init];
    [_audioButton setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
    [_audioButton addTarget:self action:@selector(didTouchOtherButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_addtionView addSubview:_audioButton];
    
    _locationButton = [[UIButton alloc] init];
    [_locationButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [_locationButton addTarget:self action:@selector(didTouchOtherButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_addtionView addSubview:_locationButton];
    
    _plusButton = _locationButton = [[UIButton alloc] init];
    [_plusButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [_plusButton addTarget:self action:@selector(didTouchOtherButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_addtionView addSubview:_plusButton];
    
    [_emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addtionView.mas_centerY);
        make.height.equalTo(@30);
        make.width.mas_equalTo(self.plusButton.mas_width);
        make.left.equalTo(self.addtionView.mas_left).with.offset(5);
        make.right.mas_equalTo(self.imageButton.mas_left).offset(-5);
        
    }];
    
    [_imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addtionView.mas_centerY);
        make.height.equalTo(@30);
        make.width.mas_equalTo(self.emojiButton.mas_width);
        make.left.equalTo(self.emojiButton.mas_right).with.offset(5);
        make.right.mas_equalTo(self.cameraButton.mas_left).offset(-5);
    }];
    
    [_cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addtionView.mas_centerY);
        make.height.equalTo(@30);
        make.width.mas_equalTo(self.emojiButton.mas_width);
        make.left.equalTo(self.imageButton.mas_right).with.offset(5);
        make.right.mas_equalTo(self.audioButton.mas_left).offset(-5);
    }];
    
    [_audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addtionView.mas_centerY);
        make.height.equalTo(@30);
        make.width.mas_equalTo(self.emojiButton.mas_width);
        make.left.equalTo(self.cameraButton.mas_right).with.offset(5);
        make.right.mas_equalTo(self.locationButton.mas_left).offset(-5);
    }];
    
    [_locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addtionView.mas_centerY);
        make.height.equalTo(@30);
        make.width.mas_equalTo(self.emojiButton.mas_width);
        make.left.equalTo(self.audioButton.mas_right).with.offset(5);
        make.right.mas_equalTo(self.plusButton.mas_left).offset(-5);
    }];
    
    [_plusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addtionView.mas_centerY);
        make.height.equalTo(@30);
        make.width.mas_equalTo(self.emojiButton.mas_width);
        make.left.equalTo(self.locationButton.mas_right).with.offset(5);
        make.right.mas_equalTo(self.addtionView.mas_right).offset(-5);
    }];
}

- (void)layoutViews {
    
    [_inputTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(15);
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.height.equalTo(@(self.inputTextViewHeight));
        make.top.equalTo(self.mas_top).with.offset(7);
    }];
}

#pragma mark user action
- (void)didTouchEmojiDown:(UIButton *)sender {
    
    switch (self.inputType) {
        case InputTypeFull:
            if ([self.delegate respondsToSelector:@selector(toggleSearchMode)]) {
                [self.delegate toggleSearchMode];
                return;
            }
            break;
        default:
            break;
    }
    
    _emojiButton.selected = !_emojiButton.selected;
    [self setInputViews];
}

- (void)didTouchOtherButtonDown:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didTouchOtherButtonDown)]) {
        [self.delegate didTouchOtherButtonDown];
        return;
    }
}

- (void)setInputViews {
    BOOL emojiButtonSelected = _emojiButton.selected;
    _searchBar.text = @"";
    _inputTextView.text = @"";
    if (emojiButtonSelected) {
        switch (self.inputType) {
            case InputTypeHalf:
                if ([self.delegate respondsToSelector:@selector(toggleSearchMode)]) {
                    [self.delegate toggleSearchMode];
                }
                break;
            default:
            [_searchBar becomeFirstResponder];
                break;
        }
        
    }else{
        [_inputTextView becomeFirstResponder];
        if ([self.delegate respondsToSelector:@selector(searchBarEndOperation)]) {
            [self.delegate searchBarEndOperation];
        }
    }
    _searchBar.hidden = !emojiButtonSelected;
    _inputTextView.hidden = emojiButtonSelected;
}

#pragma mark: UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(searchBarBeginOperation)]) {
        [self.delegate searchBarBeginOperation];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    switch (self.inputType) {
        case InputTypeHalf:
            break;
        default:
        {
            [searchTimer invalidate];
            
            searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(search)
                                                         userInfo:nil
                                                          repeats:NO];
        }
            break;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self search];
}

- (void)search {
    NSString *text = [self.searchBar.text stringByTrimmingCharactersInSet:NSMutableCharacterSet.whitespaceCharacterSet];
    if (text != nil && text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(searchEmojisWith:)]) {
            [self.delegate searchEmojisWith:text];
            [searchTimer invalidate];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchBar.text = nil;
    [_searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
    _emojiButton.selected = false;
    [self setInputViews];
}

#pragma mark <UITextViewDelegate>
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        
        NSString *content = [textView.text stringByTrimmingCharactersInSet:NSMutableCharacterSet.whitespaceCharacterSet];
        if (content.length > 0) {
            [self.delegate sendTextWith:content];
        }
        
        textView.text = @"";
        return NO;
    }
    return YES;
}

- (void)layoutTextView:(UITextView *)textView {
    CGFloat height = textView.contentSize.height;
    [_inputTextView setContentOffset:CGPointMake(0.0f, (_inputTextView.contentSize.height - self.inputTextView.frame.size.height) / 2) animated:NO];
    NSLog(@"_inputTextView contentOffset: %f", _inputTextView.contentOffset.y);
    if(height != _inputTextViewHeight) {
        
        if(height > TEXTVIEW_MIN_HEIGHT) {
            _inputTextViewHeight = height;
            if(height + textView.textContainerInset.top + textView.textContainerInset.bottom < TEXTVIEW_MAX_HEIGHT) {
            }else{
                _inputTextViewHeight = (TEXTVIEW_MAX_HEIGHT - textView.textContainerInset.top - textView.textContainerInset.bottom);
            }
        }else{
            _inputTextViewHeight = TEXTVIEW_MIN_HEIGHT;
        }
        [self relayout];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
//    [_inputTextView setContentOffset:CGPointMake(0.0f, (_inputTextView.contentSize.height - self.inputTextView.frame.size.height) / 2) animated:NO];
//    [self performSelector:@selector(layoutTextView:) withObject:textView afterDelay:0.1];
}

- (void)relayout{
    [self.delegate toolbarHeightDidChangedTo:_toolbarHeight + 14];
    [UIView animateWithDuration:0.1 animations:^{
        [self layoutViews];
    }];
    
}
@end



