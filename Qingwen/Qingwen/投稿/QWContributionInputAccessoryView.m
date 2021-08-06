//
//  QWContributionInputAccessoryView.m
//  Qingwen
//
//  Created by Aimy on 9/24/15.
//  Copyright © 2015 iQing. All rights reserved.
//

#import "QWContributionInputAccessoryView.h"

@interface QWContributionInputAccessoryView ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btns;
@property (strong, nonatomic) IBOutlet UIButton *addImageBtn;

@end

@implementation QWContributionInputAccessoryView

- (void)setCharacterBtnHidden:(BOOL)hidden
{
    [self.btns makeObjectsPerformSelector:@selector(setHidden:) withObject:hidden ? @YES : nil];
    self.addImageBtn.hidden = hidden;
}

- (IBAction)onPressedEndEditBtn:(id)sender {
    END_EDITING;
}

- (IBAction)onPressedCharacterBtn:(UIButton *)sender {
    NSString *character = [sender titleForState:UIControlStateNormal];
    [self.delegate inputAccessoryView:self inputCharacter:character];
}

- (IBAction)onPressedAddImageBtn:(id)sender {
    [self.delegate inputAccessoryView:self onPressedAddImageBtn:sender];
}

@end
