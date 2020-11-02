//
//  ActionViewController.m
//  timeGridActionExt
//
//  Created by HanLiu on 2019/5/23.
//  Copyright © 2019 HanLiu. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;
@property(strong,nonatomic) IBOutlet UILabel *label;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL found = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePlainText]) {//文本类型
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePlainText options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    __weak typeof(self)wself = self;
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        const char * s = object_getClassName(NSString.class);
                        const char * s1 = object_getClassName(item);
                        
                        NSString *itemstr = (NSString *)item;
                        itemstr = [itemstr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        NSData *data = [itemstr dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *error;
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                        [wself handle:dic];
                        
                        wself.label.text = itemstr;
                    }];
                }];
                found = YES;
                break;
            }
        }
        
        if (found) {
            // We only handle one image, so stop looking for more.
            
            break;
        }
    }
}

- (void)handle:(NSDictionary *)dic {
    NSArray *colors = (NSArray *)dic[@"colors"];
    NSString *colorsStr = [[colors componentsJoinedByString:@""] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "].invertedSet];
    NSString *url = [NSString stringWithFormat:@"colorShareDemo://color/custom/%@",colorsStr];
    [self openHostApp:url];
}

- (void)openHostApp:(NSString *)urlStr {
    
    NSURL *destinationURL = [NSURL URLWithString:urlStr];
    
    // Get "UIApplication" class name through ASCII Character codes.
    NSString *className = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x55, 0x49, 0x41, 0x70, 0x70, 0x6C, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E} length:13] encoding:NSASCIIStringEncoding];
    
    if (NSClassFromString(className))
    {
        id object = [NSClassFromString(className) performSelector:@selector(sharedApplication)];
        [object performSelector:@selector(openURL:) withObject:destinationURL];
    }
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self done];
    });

}
- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
