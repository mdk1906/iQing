//
//  BookCD.m
//  Qingwen
//
//  Created by Aimy on 7/11/15.
//  Copyright (c) 2015 iQing. All rights reserved.
//

#import "BookCD.h"

#import "BookVO.h"

@implementation BookCD

@dynamic url,title,like_url,nid,author_name,press,last_volume_title,last_chapter_title,views,cover,attention,attentionTime,updated_time,intro,created_time,status,end,last_volume_id,last_chapter_id,last_volume_url,last_chapter_url,volume_url,volume_count,author_url,press_url,chapter_url,chapter_count, read, lastReadTime, download, lastDownloadTime, chapterIndex, volumeIndex, location, follow_count, count, channel, bf_url, share_url, state_url, subscribe_url, unsubscribe_url, coin, gold, lastViewDiscuss, readingProgress, rank, lastViewDirectory,lastViewBookComments, game, cost_price, current_price, scene_count, content_url, check_url, buy_url, progress, need_pay, discount
;

- (void)updateWithBookVO:(BookVO *)vo
{
    self.nid = vo.nid;
    self.url = vo.url;
    self.intro = vo.intro;
    self.title = vo.title;
    self.cover = vo.cover;
    self.views = vo.views;
    self.count = vo.count;
    self.follow_count = vo.follow_count;
    self.updated_time = vo.updated_time;
    self.created_time = vo.created_time;
    self.author_name = vo.author_name;
    self.status = @(vo.status);
    self.press = vo.press;
    self.end = vo.end;
    self.channel = vo.channel;
    self.coin = vo.coin;
    self.gold = vo.gold;
    self.need_pay = vo.need_pay;
    self.discount = vo.discount;
    
    self.like_url = vo.like_url;
    self.bf_url = vo.bf_url;
    self.share_url = vo.share_url;
    self.state_url = vo.state_url;
    self.subscribe_url = vo.subscribe_url;
    self.unsubscribe_url = vo.unsubscribe_url;

    self.last_volume_id = vo.last_volume_id;
    self.last_chapter_id = vo.last_chapter_id;
    self.last_volume_title = vo.last_volume_title;
    self.last_chapter_title = vo.last_chapter_title;
    self.chapter_count = vo.chapter_count;
    self.volume_count = vo.volume_count;

    self.volume_url = vo.volume_url;
    self.chapter_url = vo.chapter_url;
    self.author_url = vo.author_url;
    self.press_url = vo.press_url;
    self.last_volume_url = vo.last_volume_url;
    self.last_chapter_url = vo.last_volume_url;

    self.rank = vo.rank;

    self.game = vo.game;
    self.content_url = vo.content_url;
    self.buy_url = vo.buy_url;
    self.check_url = vo.check_url;
    self.current_price = vo.current_price;
    self.cost_price = vo.cost_price;
}

- (BookVO *)toBookVO
{
    BookVO *bookVO = [BookVO new];
    bookVO.nid = self.nid;
    bookVO.url = self.url;
    bookVO.intro = self.intro;
    bookVO.title = self.title;
    bookVO.cover = self.cover;
    bookVO.views = self.views;
    bookVO.count = self.count;
    bookVO.follow_count = self.follow_count;
    bookVO.updated_time = self.updated_time;
    bookVO.created_time = self.created_time;
    bookVO.author_name = self.author_name;
    bookVO.status = [self.status intValue];
    bookVO.press = self.press;
    bookVO.end = self.end;
    bookVO.channel = self.channel;
    bookVO.coin = self.coin;
    bookVO.gold = self.gold;
    bookVO.need_pay = self.need_pay;
    bookVO.discount = self.discount;
    
    bookVO.like_url = self.like_url;
    bookVO.bf_url = self.bf_url;
    bookVO.share_url = self.share_url;
    bookVO.state_url = self.state_url;
    bookVO.subscribe_url = self.subscribe_url;
    bookVO.unsubscribe_url = self.unsubscribe_url;

    bookVO.last_volume_id = self.last_volume_id;
    bookVO.last_chapter_id = self.last_chapter_id;
    bookVO.last_volume_title = self.last_volume_title;
    bookVO.last_chapter_title = self.last_chapter_title;
    bookVO.chapter_count = self.chapter_count;
    bookVO.volume_count = self.volume_count;

    bookVO.volume_url = self.volume_url;
    bookVO.chapter_url = self.chapter_url;
    bookVO.author_url = self.author_url;
    bookVO.press_url = self.press_url;
    bookVO.last_volume_url = self.last_volume_url;
    bookVO.last_chapter_url = self.last_volume_url;

    bookVO.rank = self.rank;

    bookVO.game = self.game;
    bookVO.content_url = self.content_url;
    bookVO.buy_url = self.buy_url;
    bookVO.check_url = self.check_url;
    bookVO.current_price = self.current_price;
    bookVO.cost_price = self.cost_price;

    return bookVO;
}

- (void)setReading
{
    self.read = YES;
    self.lastReadTime = [NSDate date];
}

- (void)setDownloading
{
    self.download = YES;
    self.lastDownloadTime = [NSDate date];
}

- (void)setDeleted
{
    self.download = NO;
    self.lastDownloadTime = nil;
    [[QWFileManager qwContext] MR_saveToPersistentStoreWithCompletion:nil];
}

@end
