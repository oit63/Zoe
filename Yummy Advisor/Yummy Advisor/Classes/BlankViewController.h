#import <UIKit/UIKit.h>

@interface BlankViewController : UIViewController<UITableViewDelegate>
{
    UINavigationBar *navigationBar;
    id detailItem;
    NSString *languageString;
}

- (void)showNavigationButton:(UIBarButtonItem *)button;
- (void)hideNavigationButton:(UIBarButtonItem *)button;

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@end