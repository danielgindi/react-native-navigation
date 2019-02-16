#import "RNNReactView.h"
#import "RCTHelpers.h"
#import <React/RCTUIManager.h>

@implementation RNNReactView

- (instancetype)initWithBridge:(RCTBridge *)bridge moduleName:(NSString *)moduleName initialProperties:(NSDictionary *)initialProperties reactViewReadyBlock:(RNNReactViewReadyCompletionBlock)reactViewReadyBlock {
	self = [super initWithBridge:bridge moduleName:moduleName initialProperties:initialProperties];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentDidAppear:) name:RCTContentDidAppearNotification object:nil];
	 _reactViewReadyBlock = reactViewReadyBlock;
	
	return self;
}

- (void)contentDidAppear:(NSNotification *)notification {
#ifdef DEBUG
	if ([((RNNReactView *)notification.object).moduleName isEqualToString:self.moduleName]) {
		[RCTHelpers removeYellowBox:self];
	}
#endif
	
	RNNReactView* appearedView = notification.object;
	
	if (![appearedView.appProperties[@"componentId"] isEqual:_self.appProperties[@"componentId"]])
	{
		return;
	}
	
	__weak __typeof(self) _wself = self;
	
	// UIManager methods could only be called on the UIManager queue
	dispatch_async(appearedView.bridge.uiManager.methodQueue, ^{
		
		// Make this the first call that happens with the UI on the view that was just added
		[appearedView.bridge.uiManager prependUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
			
			__typeof(self) _self = _wself;
			if (_self == nil) return;
			
			if (_reactViewReadyBlock) {
				_reactViewReadyBlock();
				_reactViewReadyBlock = nil;
				[[NSNotificationCenter defaultCenter] removeObserver:self];
			}
			
		}];
		
	});
}

- (void)setRootViewDidChangeIntrinsicSize:(void (^)(CGSize))rootViewDidChangeIntrinsicSize {
	_rootViewDidChangeIntrinsicSize = rootViewDidChangeIntrinsicSize;
	self.delegate = self;
}

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
	if (_rootViewDidChangeIntrinsicSize) {
		_rootViewDidChangeIntrinsicSize(rootView.intrinsicContentSize);
	}
}

- (void)setAlignment:(NSString *)alignment {
	if ([alignment isEqualToString:@"fill"]) {
		self.sizeFlexibility = RCTRootViewSizeFlexibilityNone;
	} else {
		self.sizeFlexibility = RCTRootViewSizeFlexibilityWidthAndHeight;
	}
}

@end
