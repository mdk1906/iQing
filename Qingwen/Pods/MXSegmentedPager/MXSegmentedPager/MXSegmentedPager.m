// MXSegmentedPager.m
//
// Copyright (c) 2016 Maxime Epain
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <objc/runtime.h>
#import <MXParallaxHeader/MXScrollView.h>
#import "MXSegmentedPager.h"

@interface MXSegmentedPager () <MXScrollViewDelegate, MXPagerViewDelegate, MXPagerViewDataSource>
@property (nonatomic, strong) MXScrollView          *contentView;
@property (nonatomic, strong) HMSegmentedControl    *segmentedControl;
@property (nonatomic, strong) MXPagerView           *pager;

@property (nonatomic, strong) MXProgressBlock progressBlock;
@end

@implementation MXSegmentedPager {
    CGFloat     _controlHeight;
    NSInteger   _count;
}

- (void)reloadData {
    
    //Gets number of pages
    _count = [self.dataSource numberOfPagesInSegmentedPager:self];
    NSAssert(_count > 0, @"Number of pages in MXSegmentedPager must be greater than 0");
    
    //Gets the segmented control height
    _controlHeight = 44.f;
    if ([self.delegate respondsToSelector:@selector(heightForSegmentedControlInSegmentedPager:)]) {
        _controlHeight = [self.delegate heightForSegmentedControlInSegmentedPager:self];
    }
    
    //Gets new data
    NSMutableArray *images          = [NSMutableArray arrayWithCapacity:_count];
    NSMutableArray *selectedImages  = [NSMutableArray arrayWithCapacity:_count];
    NSMutableArray *titles          = [NSMutableArray arrayWithCapacity:_count];
    
    for (NSInteger index = 0; index < _count; index++) {
        
        titles[index] = [NSString stringWithFormat:@"Page %ld", (long)index];
        if ([self.dataSource respondsToSelector:@selector(segmentedPager:titleForSectionAtIndex:)]) {
            titles[index] = [self.dataSource segmentedPager:self titleForSectionAtIndex:index];
        }
        
        if ([self.dataSource respondsToSelector:@selector(segmentedPager:imageForSectionAtIndex:)]) {
            images[index] = [self.dataSource segmentedPager:self imageForSectionAtIndex:index];
        }
        
        if ([self.dataSource respondsToSelector:@selector(segmentedPager:selectedImageForSectionAtIndex:)]) {
            selectedImages[index] = [self.dataSource segmentedPager:self selectedImageForSectionAtIndex:index];
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(segmentedPager:attributedTitleForSectionAtIndex:)]) {
        __weak typeof(self) segmentedPager = self;
        self.segmentedControl.titleFormatter = ^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
            return [segmentedPager.dataSource segmentedPager:segmentedPager attributedTitleForSectionAtIndex:index];
        };
    }
    
    self.segmentedControl.sectionImages = images;
    self.segmentedControl.sectionSelectedImages = selectedImages;
    self.segmentedControl.sectionTitles = titles;
    [self.segmentedControl setNeedsDisplay];
    
    [self.pager reloadData];
}

- (void)scrollToTopAnimated:(BOOL)animated {
    [_contentView setContentOffset:CGPointMake(0, -self.contentView.parallaxHeader.height)
                          animated:animated];
}

#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_count <= 0) {
        [self reloadData];
    }
    
    [self layoutContentView];
    [self layoutSegmentedControl];
    [self layoutPager];
}

- (void)layoutContentView {
    CGRect frame = self.bounds;
    
    frame.origin = CGPointZero;
    self.contentView.frame = frame;
    self.contentView.contentSize = self.contentView.frame.size;
    self.contentView.scrollEnabled = !!self.contentView.parallaxHeader.view;
    self.contentView.contentInset = UIEdgeInsetsMake(self.contentView.parallaxHeader.height, 0, 0, 0);
}

- (void)layoutSegmentedControl {
    CGRect frame = self.bounds;
    
    frame.origin.x = self.segmentedControlEdgeInsets.left;
    
    if (self.segmentedControlPosition == MXSegmentedControlPositionTop) {
        frame.origin.y = self.segmentedControlEdgeInsets.top;
    }
    else {
        frame.origin.y  = frame.size.height;
        frame.origin.y -= _controlHeight;
        frame.origin.y -= self.segmentedControlEdgeInsets.bottom;
    }

    frame.size.width -= self.segmentedControlEdgeInsets.left;
    frame.size.width -= self.segmentedControlEdgeInsets.right;
    frame.size.height = _controlHeight;
    
    self.segmentedControl.frame = frame;
}

- (void)layoutPager {
    CGRect frame = self.bounds;
    
    frame.origin = CGPointZero;
    
    if (self.segmentedControlPosition == MXSegmentedControlPositionTop) {
        frame.origin.y  = _controlHeight;
        frame.origin.y += self.segmentedControlEdgeInsets.top;
        frame.origin.y += self.segmentedControlEdgeInsets.bottom;
    }
    
    frame.size.height -= _controlHeight;
    frame.size.height -= self.segmentedControlEdgeInsets.top;
    frame.size.height -= self.segmentedControlEdgeInsets.bottom;
    frame.size.height -= self.contentView.parallaxHeader.minimumHeight;
    
    self.pager.frame = frame;
}

#pragma mark Properties

- (MXScrollView *)contentView {
    if (!_contentView) {
        
        // Create scroll-view
        _contentView = [[MXScrollView alloc] init];
        _contentView.delegate = self;
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (HMSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] init];
        [_segmentedControl addTarget:self
                              action:@selector(pageControlValueChanged:)
                    forControlEvents:UIControlEventValueChanged];
        
        [self.contentView addSubview:_segmentedControl];
    }
    return _segmentedControl;
}

- (MXPagerView *)pager {
    if (!_pager) {
        _pager = [[MXPagerView alloc] init];
        _pager.delegate = self;
        _pager.dataSource = self;
        [self.contentView addSubview:_pager];
    }
    return _pager;
}

- (UIView*)selectedPage {
    return self.pager.selectedPage;
}

- (void)setSegmentedControlPosition:(MXSegmentedControlPosition)segmentedControlPosition {
    _segmentedControlPosition = segmentedControlPosition;
    [self setNeedsLayout];
}

- (void)setSegmentedControlEdgeInsets:(UIEdgeInsets)segmentedControlEdgeInsets {
    _segmentedControlEdgeInsets = segmentedControlEdgeInsets;
    [self setNeedsLayout];
}

#pragma mark <MXScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([self.delegate respondsToSelector:@selector(segmentedPager:didScrollWithParallaxHeader:)]) {
        [self.delegate segmentedPager:self didScrollWithParallaxHeader:scrollView.parallaxHeader];
    }
    
    if (self.progressBlock) {
        self.progressBlock(self.contentView.parallaxHeader.progress);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(segmentedPager:didEndDraggingWithParallaxHeader:)]) {
        [self.delegate segmentedPager:self didEndDraggingWithParallaxHeader:scrollView.parallaxHeader];
    }
}

- (BOOL)scrollView:(MXScrollView *)scrollView shouldScrollWithSubView:(UIView *)subView {
    UIView<MXPageProtocol> *page = (id) self.pager.selectedPage;
    
    if ([page respondsToSelector:@selector(segmentedPager:shouldScrollWithView:)]) {
        return [page segmentedPager:self shouldScrollWithView:subView];
    }
    return YES;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(segmentedPagerShouldScrollToTop:)]) {
        return [self.delegate segmentedPagerShouldScrollToTop:self];
    }
    return YES;
}

#pragma mark HMSegmentedControl target

- (void)pageControlValueChanged:(HMSegmentedControl*)segmentedControl {
    [self.pager showPageAtIndex:segmentedControl.selectedSegmentIndex animated:YES];
}

#pragma mark <MXPagerViewDelegate>

- (void)pagerView:(MXPagerView *)pagerView willMoveToPageAtIndex:(NSInteger)index {
    [self.segmentedControl setSelectedSegmentIndex:index animated:YES];
}

- (void)pagerView:(MXPagerView *)pagerView didMoveToPageAtIndex:(NSInteger)index {
    [self.segmentedControl setSelectedSegmentIndex:index animated:NO];
    [self changedToIndex:index];
}

#pragma mark <MXPagerViewDataSource>

- (NSInteger)numberOfPagesInPagerView:(MXPagerView *)pagerView {
    return _count;
}

- (UIView*)pagerView:(MXPagerView *)pagerView viewForPageAtIndex:(NSInteger)index {
    return [self.dataSource segmentedPager:self viewForPageAtIndex:index];
}

#pragma mark Private methods

- (void)changedToIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(segmentedPager:didSelectViewWithIndex:)]) {
        [self.delegate segmentedPager:self didSelectViewWithIndex:index];
    }
    
    NSString* title = self.segmentedControl.sectionTitles[index];
    UIView* view = self.pager.selectedPage;
                    
    if ([self.delegate respondsToSelector:@selector(segmentedPager:didSelectViewWithTitle:)]) {
        [self.delegate segmentedPager:self didSelectViewWithTitle:title];
    }
    
    if ([self.delegate respondsToSelector:@selector(segmentedPager:didSelectView:)]) {
        [self.delegate segmentedPager:self didSelectView:view];
    }
}

@end

#pragma mark MXParallaxHeader

@implementation MXSegmentedPager (ParallaxHeader)

- (BOOL)bounces {
    return self.contentView.bounces;
}

- (void)setBounces:(BOOL)bounces {
    self.contentView.bounces = bounces;
}

- (MXParallaxHeader *)parallaxHeader {
    return self.contentView.parallaxHeader;
}

@end

#pragma mark VGParallaxHeader Backward compatibility

@implementation MXSegmentedPager (VGParallaxHeader)

- (void)setParallaxHeaderView:(UIView *)view mode:(VGParallaxHeaderMode)mode height:(CGFloat)height {
    self.parallaxHeader.view    = view;
    self.parallaxHeader.mode    = (MXParallaxHeaderMode)mode;
    self.parallaxHeader.height  = height;
}

- (void)updateParallaxHeaderViewHeight:(CGFloat)height {
    self.parallaxHeader.height = height;
}

#pragma mark Properties

- (CGFloat)minimumHeaderHeight {
    return self.parallaxHeader.minimumHeight;
}

- (void)setMinimumHeaderHeight:(CGFloat)minimumHeaderHeight {
    self.parallaxHeader.minimumHeight = minimumHeaderHeight;
}

@end

@implementation MXParallaxHeader (VGParallaxHeader)

- (VGParallaxHeaderStickyViewPosition)stickyViewPosition {
    return [objc_getAssociatedObject(self, @selector(stickyViewPosition)) integerValue];
}

- (void)setStickyViewPosition:(VGParallaxHeaderStickyViewPosition)stickyViewPosition {
    objc_setAssociatedObject(self, @selector(stickyViewPosition), [NSNumber numberWithInteger:stickyViewPosition], OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self updateStickyViewConstraints];
}

- (NSLayoutConstraint *)stickyViewHeightConstraint {
    NSLayoutConstraint *stickyViewHeightConstraint = objc_getAssociatedObject(self, @selector(stickyViewHeightConstraint));
    if (!stickyViewHeightConstraint && self.stickyView) {
        stickyViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.stickyView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:0];
        
        objc_setAssociatedObject(self, @selector(stickyViewHeightConstraint), stickyViewHeightConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return stickyViewHeightConstraint;
}

- (void)setStickyViewHeightConstraint:(NSLayoutConstraint *)stickyViewHeightConstraint {
    if (self.stickyViewHeightConstraint != stickyViewHeightConstraint && self.stickyView.superview == self.contentView) {
        [self.contentView removeConstraint:self.stickyViewHeightConstraint];
        [self.contentView addConstraint:stickyViewHeightConstraint];
        objc_setAssociatedObject(self, @selector(stickyViewHeightConstraint), stickyViewHeightConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (UIView *)stickyView {
    return objc_getAssociatedObject(self, @selector(stickyView));
}

- (void)setStickyView:(UIView *)stickyView {
    if (self.stickyView != stickyView) {
        [self.stickyView removeFromSuperview];
        objc_setAssociatedObject(self, @selector(stickyView), stickyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self updateStickyViewConstraints];
    }
}

- (void)setStickyView:(__kindof UIView *)stickyView withHeight:(CGFloat)height {
    self.stickyView = stickyView;
    self.stickyViewHeightConstraint.constant = height;
}

- (BOOL)isInsideTableView {
    return NO;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)updateStickyViewConstraints {
    if (self.stickyView) {
        [self.stickyView removeFromSuperview];
        [self.contentView addSubview:self.stickyView];
        
        self.stickyView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"v" : self.stickyView}]];
        
        NSLayoutAttribute attribute = (self.stickyViewPosition == VGParallaxHeaderStickyViewPositionTop)? NSLayoutAttributeTop : NSLayoutAttributeBottom;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.stickyView
                                                                     attribute:attribute
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:attribute
                                                                    multiplier:1
                                                                      constant:0]];
        
        [self.contentView addConstraint:self.stickyViewHeightConstraint];
    }
}
#pragma GCC diagnostic pop

@end
