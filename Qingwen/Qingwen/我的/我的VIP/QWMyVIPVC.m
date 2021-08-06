//
//  QWMyVIPVC.m
//  Qingwen
//
//  Created by qingwen on 2018/10/9.
//  Copyright © 2018年 iQing. All rights reserved.
//

#import "QWMyVIPVC.h"
#import "QWVIPView.h"
#import "QWVIPSectionVC.h"
#import <StoreKit/StoreKit.h>
@interface QWMyVIPVC ()<UITableViewDelegate,UITableViewDataSource,SKPaymentTransactionObserver,SKProductsRequestDelegate>
{
    NSString * _senderId;
    NSMutableArray *titleArr;
    NSMutableArray *contentArr;
    NSMutableArray *vipTitleArr;
    NSMutableArray *givingArr;
    NSMutableArray *moneyArr;
    NSMutableArray *deleteMoneyArr;
    NSMutableArray *idArr;
}
@property (nonatomic,strong) QWTableView *tableView;
@property (nonatomic,strong)QWVIPView *logisview;
@property (nonatomic,strong)NSString *productsId;
@property NSInteger quantity;
@property (nonatomic ,strong) NSString *currencyCode;
@end

@implementation QWMyVIPVC

- (void)viewDidLoad {
    [super viewDidLoad];
    titleArr = [NSMutableArray new];
    contentArr = [NSMutableArray new];
    vipTitleArr = [NSMutableArray new];
    givingArr = [NSMutableArray new];
    moneyArr = [NSMutableArray new];
    deleteMoneyArr = [NSMutableArray new];
    idArr = [NSMutableArray new];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的VIP";
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"VIP专区" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    self.tableView = [QWTableView new];
    if (ISIPHONEX) {
        self.tableView.frame = CGRectMake(0, 88, UISCREEN_WIDTH, UISCREEN_HEIGHT-88-59);
    }
    else{
        self.tableView.frame = CGRectMake(0, 64, UISCREEN_WIDTH, UISCREEN_HEIGHT-64-59);
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self getDataAd];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
}
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    // 第二种办法：在隐藏导航栏的时候要添加动画
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    // 第二种办法：在显示导航栏的时候要添加动画
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define Start_X 12.0f           // 第一label的X坐标
#define Start_Y 120.0f           // 第一个label的Y坐标
#define Width_Space 5.0f        // 2个按钮之间的横间距
#define Height_Space 5.0f      // 竖间距
#define Button_Height 52.0f    // 高
#define Button_Width (UISCREEN_WIDTH-24-3*5)/4      // 宽

-(void)createHeadView{
    UIView *headView = [UIView new];
    headView.frame = CGRectMake(0, 0, UISCREEN_WIDTH, 547);
    headView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = headView;
    
    UIImageView *backImg = [UIImageView new];
    backImg.frame = CGRectMake(0, 0, UISCREEN_WIDTH, 80);
    backImg.image = [UIImage imageNamed:@"底图"];
    [headView addSubview:backImg];
    
    UIImageView *iconImg = [UIImageView new];
    [iconImg qw_setImageUrlString:[QWConvertImageString convertPicURL:[QWGlobalValue sharedInstance].user.avatar imageSizeType:QWImageSizeTypeCover] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
    iconImg.frame = CGRectMake(15, 13, 54, 54);
    iconImg.layer.masksToBounds = YES;
    iconImg.layer.cornerRadius = 27;
    [backImg addSubview:iconImg];
    
    UIImageView *medalImg = [UIImageView new];
    [medalImg qw_setImageUrlString:[QWConvertImageString convertPicURL:[QWGlobalValue sharedInstance].user.adorn_medal imageSizeType:QWImageSizeTypeCover] placeholder:[UIImage imageNamed:@"mycenter_logo2"] animation:YES];
    medalImg.frame = CGRectMake(15, 51, 54, 16);
    [backImg addSubview:medalImg];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(kMaxX(iconImg.frame)+13, 17, UISCREEN_WIDTH, 20)];
    nameLab.textColor = HRGB(0xffffff);
    nameLab.font = [UIFont systemFontOfSize:16];
    nameLab.text = [QWGlobalValue sharedInstance].username;
    [backImg addSubview:nameLab];
    
    UILabel *VIPLab = [[UILabel alloc] initWithFrame:CGRectMake(kMaxX(iconImg.frame)+13, 44, UISCREEN_WIDTH, 20)];
    VIPLab.textColor = HRGB(0xffffff);
    VIPLab.font = [UIFont systemFontOfSize:14];
    if ([[QWGlobalValue sharedInstance].user.vip_date isEqualToString:@""]) {
        VIPLab.text = @"您还不是VIP";
    }
    else{
        VIPLab.text = [NSString stringWithFormat:@"VIP用户（还剩%@天）",[QWGlobalValue sharedInstance].user.vip_date];
    }
    
    [backImg addSubview:VIPLab];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 93, 200, 22)];
    titleLab.textColor = HRGB(0x6F6F6F);
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.text = @"VIP特权";
    [headView addSubview:titleLab];
    
    UIButton *VIPInfoBtn = [UIButton new];
    [VIPInfoBtn setTitle:@"了解更多VIP特权" forState:0];
    VIPInfoBtn.frame = CGRectMake(UISCREEN_WIDTH-13-120, 98, 120, 12);
    VIPInfoBtn.titleLabel.font = FONT(12);
    [VIPInfoBtn addTarget:self action:@selector(VIPInfoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [VIPInfoBtn setTitleColor:[UIColor colorQWPink] forState:0];
    [headView addSubview:VIPInfoBtn];
    
    //    titleArr = @[@"日常任务受益",@"充值赠送轻石",@"专享vip权益",@"百本原创小说",@"精品文库本",@"vip用户专属",@"vip用户专属",@"敬请期待"];
    //    contentArr = @[@"＋100%",@"＋200%",@"lv.4",@"免费畅读",@"免费畅读",@"头像勋章",@"额外等级经验",@""];
    
    for (int i = 0; i<titleArr.count; i++) {
        NSInteger index = i % 4;
        NSInteger page = i / 4;
        UIView *view = [UIView new];
        view.backgroundColor = HRGB(0xf9f9f9);
        view.layer.cornerRadius = 3;
        view.layer.masksToBounds = YES;
        view.frame = CGRectMake(index * (Button_Width + Width_Space) + Start_X, page  * (Button_Height + Height_Space)+Start_Y, Button_Width, Button_Height);
        [headView addSubview:view];
        
        UILabel *viewtitleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, (UISCREEN_WIDTH-24-3*5)/4, 17)];
        viewtitleLab.textColor = HRGB(0x6f6f6f);
        viewtitleLab.font = [UIFont systemFontOfSize:12];
        viewtitleLab.text = titleArr[i];
        viewtitleLab.textAlignment = 1;
        [view addSubview:viewtitleLab];
        
        UILabel *viewcontentLab = [[UILabel alloc] initWithFrame:CGRectMake(0, kMaxY(viewtitleLab.frame)+5, (UISCREEN_WIDTH-24-3*5)/4, 17)];
        viewcontentLab.textColor = HRGB(0xababab);
        viewcontentLab.font = [UIFont systemFontOfSize:12];
        viewcontentLab.text = contentArr[i];
        viewcontentLab.textAlignment = 1;
        [view addSubview:viewcontentLab];
        
//        if (i == titleArr.count-1) {
//            viewtitleLab.hidden = YES;
//            viewcontentLab.frame = CGRectMake(0, 0, Button_Width, Button_Height);
//        }
        
    }
    
    UIView *hui = [UIView new];
    hui.frame = CGRectMake(0, kMaxY(titleLab.frame)+titleArr.count/4*57+5, UISCREEN_WIDTH, 5);
    hui.backgroundColor = HRGB(0xf9f9f9);
    [headView addSubview:hui];
    
    UILabel *secondtitleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, kMaxY(hui.frame)+10, 200, 22)];
    secondtitleLab.textColor = HRGB(0x6F6F6F);
    secondtitleLab.font = [UIFont systemFontOfSize:16];
    secondtitleLab.text = @"VIP充值";
    [headView addSubview:secondtitleLab];
    
    //    NSArray *vipTitleArr = @[@"30天",@"3个月",@"6个月",@"12个月"];
    //    NSArray *givingArr = @[@"",@"赠送10天",@"赠送20天",@"赠送30天"];
    //    NSArray *moneyArr = @[@"9",@"27",@"54",@"108"];
    //    NSArray *deleteMoneyArr = @[@"",@"30",@"60",@"120"];
    //    NSArray *idArr =
    for (int i = 0; i<vipTitleArr.count; i++) {
        _logisview = [[QWVIPView alloc] initWithFrame:CGRectMake(0, kMaxY(secondtitleLab.frame)+9+ 63*i, UISCREEN_WIDTH, 58+5)];
        _logisview.backImg.image = [UIImage imageNamed:@""];
        [_logisview setTitle:vipTitleArr[i] give:givingArr[i] money:[NSString stringWithFormat:@"¥%@",moneyArr[i]]  deleteMoney:[NSString stringWithFormat:@"¥%@",deleteMoneyArr[i]]];
        _logisview.tag = 300+i;
        _logisview.productsId = idArr[i];
        [headView addSubview:_logisview];
        [_logisview addTarget:self selector:@selector(lpgisButton:)];
        if (i == 0) {
            _logisview.deleteMoneyLab.hidden = YES;
            _logisview.hui.hidden = YES;
        }
        if (i == 2) {
            _logisview.recommendedImg.hidden = NO;
            _senderId = [NSString stringWithFormat:@"%ld",_logisview.tag];
            _logisview.backImg.image = [UIImage imageNamed:@"渐变"];
            _logisview.titleLab.textColor = [UIColor whiteColor];
            _logisview.givingLab.textColor = [UIColor whiteColor];
            _logisview.moneyLab.textColor = [UIColor whiteColor];
            _logisview.deleteMoneyLab.textColor = [UIColor whiteColor];
            _logisview.hui.backgroundColor = HRGB(0xFFFFFF);
            UILabel *moneyLab = (UILabel*)[self.view viewWithTag:400];
            UILabel *reduceMoneyLab = (UILabel*)[self.view viewWithTag:500];
            reduceMoneyLab.text = @"已减21元";
            moneyLab.text = @"¥60";
            
            
            
        }
    }
}
-(void)lpgisButton:(QWVIPView *)but{
    _senderId = [NSString stringWithFormat:@"%ld",but.tag];
    but.backImg.image = [UIImage imageNamed:@"渐变"];
    but.titleLab.textColor = [UIColor whiteColor];
    but.givingLab.textColor = [UIColor whiteColor];
    but.moneyLab.textColor = [UIColor whiteColor];
    but.deleteMoneyLab.textColor = [UIColor whiteColor];
    but.hui.backgroundColor = HRGB(0xFFFFFF);
    UILabel *moneyLab = (UILabel*)[self.view viewWithTag:400];
    UILabel *reduceMoneyLab = (UILabel*)[self.view viewWithTag:500];
    moneyLab.text = but.moneyLab.text;
    NSString *delete = [but.deleteMoneyLab.text componentsSeparatedByString:@"¥"][1];
    NSString * money = [but.moneyLab.text componentsSeparatedByString:@"¥"][1];
    reduceMoneyLab.text = [NSString stringWithFormat:@"已减%d元",[delete intValue] - [money intValue]];
    if (([delete intValue] - [money intValue])<0) {
        reduceMoneyLab.text = @"已减0元";
    }
    for (int i = 0; i<4; i++) {
        if (i != but.tag-300) {
            QWVIPView *view =(QWVIPView *)[self.view viewWithTag:300+i];
            view.backImg.image = [UIImage imageNamed:@""];
            view.titleLab.textColor = HRGB(0x6f6f6f);
            view.givingLab.textColor = HRGB(0xF77590);
            view.moneyLab.textColor = HRGB(0xF77590);
            view.deleteMoneyLab.textColor = HRGB(0xB3B1B1);
            view.hui.backgroundColor = HRGB(0xb3b1b1);
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 0.5;
}
//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    return cell;
}


-(void)createBottomView{
    UIView *bottomView = [UIView new];
    bottomView.frame = CGRectMake(0, UISCREEN_HEIGHT-59, UISCREEN_WIDTH, 59);
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 35, 59)];
    titleLab.textColor = HRGB(0x6f6f6f);
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.text = @"总计";
    [bottomView addSubview:titleLab];
    
    UILabel *moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(kMaxX(titleLab.frame)+5, 0, 70, 59)];
    moneyLab.textColor = HRGB(0xF77590);
    moneyLab.tag = 400;
    moneyLab.font = [UIFont systemFontOfSize:18];
    moneyLab.text = @"¥";
    [bottomView addSubview:moneyLab];
    
    UILabel *reduceMoneyLab = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 100, 59)];
    reduceMoneyLab.textColor = HRGB(0xB3B1B1 );
    reduceMoneyLab.tag = 500;
    reduceMoneyLab.font = [UIFont systemFontOfSize:18];
    reduceMoneyLab.text = @"已减0元";
    [bottomView addSubview:reduceMoneyLab];
    
    UIButton *bottomBtn = [UIButton new];
    bottomBtn.frame = CGRectMake(UISCREEN_WIDTH-12-100, 9, 100, 42);
    [bottomBtn setBackgroundImage:[UIImage imageNamed:@"去支付"] forState:0];
    [bottomBtn addTarget:self action:@selector(payClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:bottomBtn];
    
}
-(void)getDataAd{
    titleArr = [NSMutableArray new];
    contentArr = [NSMutableArray new];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [self showLoading];
    NSString *url = [NSString stringWithFormat:@"%@/vip/ad/",[QWOperationParam currentPayDomain]];
    //        NSString *url = @"http://apidoc.iqing.com/mock/19/levels/";
    QWOperationParam *pm = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        [self hideLoading];
        if (aResponseObject != nil) {
            NSDictionary *dict = aResponseObject;
            NSArray *data = dict[@"data"];
            for (NSDictionary *res in data) {
                [self->titleArr addObject:res[@"black"]];
                [self->contentArr addObject:res[@"gray"]];
            }
            
            [self getDataVIP];
        }
    }];
    [self.operationManager requestWithParam:pm];
}
-(void)getDataVIP{
    vipTitleArr = [NSMutableArray new];
    givingArr = [NSMutableArray new];
    moneyArr = [NSMutableArray new];
    deleteMoneyArr = [NSMutableArray new];
    idArr = [NSMutableArray new];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [self showLoading];
    NSString *url = [NSString stringWithFormat:@"%@/vip/?api_version=v2",[QWOperationParam currentPayDomain]];
    //        NSString *url = @"http://apidoc.iqing.com/mock/19/levels/";
    QWOperationParam *pm = [QWInterface getWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
        [self hideLoading];
        if (aResponseObject != nil) {
            NSDictionary *dict = aResponseObject;
            NSArray *data = dict[@"data"];
            for (NSDictionary *res in data) {
                [self->vipTitleArr addObject:res[@"card_name"]];
                [self->givingArr addObject:res[@"card_intro_text"]];
                [self->moneyArr addObject:[res[@"discount"] stringValue]];
                [self->deleteMoneyArr addObject:[res[@"purchaseamount"] stringValue]];
                [self->idArr addObject:res[@"id"]];
            }
            [self createBottomView];
            [self createHeadView];
            
            [self.tableView reloadData];
        }
    }];
    [self.operationManager requestWithParam:pm];
}
#pragma mark - 支付
-(void)payClick{
    if (_senderId == nil) {
        [self showToastWithTitle:@"请选择VIP套餐" subtitle:nil type:ToastTypeAlert];
        return;
    }
    QWVIPView *btn = (QWVIPView*)[self.view viewWithTag:[_senderId intValue]];
    
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"请确认您的App内购项目" message:[NSString stringWithFormat:@"您想以%@的价格购买%@VIP吗？",btn.moneyLab.text,btn.titleLab.text]];
    [alertView bk_addButtonWithTitle:@"取消" handler:^{
        
        
    }];
    
    [alertView bk_addButtonWithTitle:@"确认" handler:^{
        [self buyProductsWithId:btn.productsId andQuantity:1];
        
    }];
    
    [alertView show];
}

-(void)dealloc{
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)buyProductsWithId:(NSString *)productsId andQuantity:(NSInteger)quantity {
    self.productsId = productsId;
    self.quantity = quantity;
    [self showLoading];
    if ([SKPaymentQueue canMakePayments]) {
        //允许程序内付费购买
        [self RequestProductData:@[productsId]];
    } else {
        //您的手机没有打开程序内付费购买
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"您的手机没有打开程序内付费购买" message:nil delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alerView show];
    }
}

- (void)RequestProductData:(NSArray *)productsIdArr {
    //请求对应的产品信息
    NSSet *nsset = [NSSet setWithArray:productsIdArr];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    //收到产品反馈信息
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", (int) [myProduct count]);
    // populate UI
    for (SKProduct *product in myProduct) {
        
        [self updateProductPriceWithId:product.productIdentifier andPrice:product.price];
        if ([[product.priceLocale objectForKey:NSLocaleCurrencyCode] isEqualToString:@"CNY"]) {
            self.currencyCode = @"￥";
        } else {
            self.currencyCode = [product.priceLocale objectForKey:NSLocaleCurrencySymbol];
        }
    }
    //发送购买请求
    for (SKProduct *prct in myProduct) {
        if ([self.productsId isEqualToString:prct.productIdentifier]) {
            SKMutablePayment *payment = nil;
            payment = [SKMutablePayment paymentWithProduct:prct];
            payment.quantity = self.quantity;
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }
}

- (void)updateProductPriceWithId:(NSString *)productIdentifier andPrice:(NSDecimalNumber *)price{
    NSLog(@"productIdentifier == %@",productIdentifier);
    NSLog(@"price == %@",price);
}

#pragma mark - SKPaymentTransactionObserver
//----监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    //交易结果
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                //交易完成
                [self hideLoading];
                [self completeTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed: {
                //交易失败
                [self hideLoading];
                [self failedTransaction:transaction];
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"交易失败" message:nil delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
                [alerView show];
            }
                break;
            case SKPaymentTransactionStateRestored: {
                //已经购买过该商品
                [self hideLoading];
                [self restoreTransaction:transaction];
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"已经购买过该商品" message:nil delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
                [alerView show];
            }
                break;
            case SKPaymentTransactionStatePurchasing: {
                //商品添加进列表
                NSLog(@"商品添加进列表");
            }
                break;
            case SKPaymentTransactionStateDeferred: {
                NSLog(@"SKPayment Transaction State Deferred");
            }
                break;
            default:
                break;
        }
    }
}
- (void)failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"失败");
    if (transaction.error.code != SKErrorPaymentCancelled) { }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易恢复处理");
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"-----completeTransaction--------");
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        //        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[[NSBundle mainBundle] appStoreReceiptURL]];//苹果推荐
        //        NSError *error = nil;
        ////        receiptData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:&error];
        
        //        NSString *result = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
        //        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        //        NSString *base64 = [data base64EncodedStringWithOptions:0];
        NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
        
        NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
        NSMutableDictionary *params = [NSMutableDictionary new];
        [self showLoading];
        params[@"goods"] = @"VIP";
        params[@"token"] = QWGlobalValue.sharedInstance.token;
        params[@"data"] = receiptString;
        QWVIPView *btn = (QWVIPView*)[self.view viewWithTag:[_senderId intValue]];
        NSString *url = [NSString stringWithFormat:@"%@/apple/receipt/",[QWOperationParam currentPayDomain]];
        NSLog(@"params = %@ url = %@",params,url);
        QWOperationParam *pm = [QWInterface postWithUrl:url params:params andCompleteBlock:^(id  _Nullable aResponseObject, NSError * _Nullable anError) {
            [self hideLoading];
            NSLog(@"res = %@",aResponseObject);
            if (aResponseObject != nil) {
                NSDictionary *dict = aResponseObject;
                if ([dict[@"code"] intValue] == 0) {
                    [self getDataAd];
                    NSMutableDictionary *params = @{}.mutableCopy;
                    params[@"token"] = [QWGlobalValue sharedInstance].token;
                    QWOperationParam *param = [QWInterface getWithDomainUrl:@"task/show/" params:params andCompleteBlock:^(id aResponseObject, NSError *anError) {
                        if (aResponseObject && !anError) {
                            NSDictionary *data = aResponseObject;
                            NSArray *dataArr = data[@"data"];
                            if (dataArr.count != 0) {
                                for (int i = 0; i<dataArr.count; i++) {
                                    NSDictionary *dict = dataArr[i];
                                    QWAchievementBounced *alert = [[QWAchievementBounced alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT) dict:dict];
                                    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                                    [keyWindow addSubview:alert];
                                }
                            }
                            
                        }
                        else {
                        }
                    }];
                    param.requestType = QWRequestTypePost;
                    [self.operationManager requestWithParam:param];
                    UIStoryboard *UpgradeHardware = [UIStoryboard storyboardWithName:@"QWWallet" bundle:nil];
                    QWPaySuccessVC *vc = (QWPaySuccessVC*)[UpgradeHardware instantiateViewControllerWithIdentifier:@"PaySuccess"];//跳转VC的名称
                    
                    int gold = [btn.titleLab.text intValue];
                    NSDictionary *prodactDict = @{@"name":@"VIP",@"vip_bonus":btn.moneyLab.text,@"gold":[NSNumber numberWithInt:gold]};
                    ProductVO *prodact = [ProductVO voWithDict:prodactDict];
                    vc.product = prodact;
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }
                else{
                    
                }
                
            }
        }];
        [self.operationManager requestWithParam:pm];
    }
}

//记录交易
- (void)recordTransaction:(NSString *)product{
    NSLog(@"记录交易--product == %@",product);
}

//处理下载内容
- (void)provideContent:(NSString *)product{
    NSLog(@"处理下载内容--product == %@",product);
}
#pragma mark - 更多特权点击
-(void)VIPInfoBtnClick{
#ifdef DEBUG
    [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://menma-gate.iqing.com/info/#/vip"]];
#else
    [[QWRouter sharedInstance] routerWithUrl:[NSURL URLWithString:@"https://www.iqing.com/info/#/vip"]];
#endif
    
}
@end
