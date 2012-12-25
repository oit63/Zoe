//
//  CategoryBox.m
//  Yummy
//
//  Created by ttron on 1/25/12.
//  Copyright (c) 2012 Tsst Corp. All rights reserved.
//

#import "YummyCell.h"
#import "YummyOnMeAppDelegate.h"
#import "YummyMetroViewController.h"
#import "ASIHTTPRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>

@implementation YummyCell

@synthesize reuseIdentifier=_reuseIdentifier;
@synthesize contentView=_contentView;
@synthesize uid=_uid;
@synthesize yummyItem=_yummyItem;
@synthesize padding=_padding;

-(void)dealloc
{
    [self.contentView release];
    [_imageView release];
    [_titleLabel release];
    [_indexLabel release];
    [super dealloc];
}

- (void) _sharedInit
{
    _padding=3;
    //self.autoresizesSubviews = YES;
    //self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _imageView = [[UIImageView alloc] initWithFrame: CGRectZero];
    [self.contentView addSubview: _imageView];//@_@
    
    
    _titleLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    [self.contentView insertSubview:_titleLabel aboveSubview:_imageView];
    
    _indexLabel=[[UILabel alloc] init];//XXX
    [self.contentView insertSubview:_indexLabel aboveSubview:_imageView];//XXX
}

- (id) initWithItem:(YummyItem *)yummyItem
{
    self = [super initWithFrame:CGRectZero];
    
	if ( self == nil )
        return ( nil );
    self.yummyItem=yummyItem;
	//self = [super initWithFrame:CGRectMake(0, 0, 256, 256)];//FIXME
    
	self.reuseIdentifier = yummyItem.uid;
    [self _sharedInit];   
    return ( self );
}

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) reuseIdentifier
{
    self = [super initWithFrame: frame];
	if ( self == nil )
		return ( nil );
    self.yummyItem=nil;
	self.reuseIdentifier = reuseIdentifier;
    [self _sharedInit];  
    
    return ( self );
}

- (NSString *) md5:(NSString*) str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

- (NSString*)md50:(NSData*) array
{
    unsigned char result[16];
    CC_MD5( array, [array length], result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}


-(UIColor*) getBgColor
{
    if(self.yummyItem!=nil)
    {
        NSString *bgColorString=self.yummyItem.bgColorString;
        if([bgColorString length]>=7)
        {
            NSString *s=[bgColorString substringWithRange:NSMakeRange(1,2)];
            unsigned long l=strtoul([s UTF8String], 0, 16);
            float redf=l/255.0;
            
            s=[bgColorString substringWithRange:NSMakeRange(3,2)];
            l=strtoul([s UTF8String], 0, 16);
            float greenf=l/255.0;
            
            s=[bgColorString substringWithRange:NSMakeRange(5,2)];
            l=strtoul([s UTF8String], 0, 16);
            float bluef=l/255.0;
            
            float alphaf=1;
            if([bgColorString length]>=9)
            {
                s=[bgColorString substringWithRange:NSMakeRange(7,2)];
                l=strtoul([s UTF8String], 0, 16);
                alphaf=l/255.0;
            }
            
            return  [UIColor colorWithRed:redf green:greenf blue:bluef alpha:alphaf];
        }
    }
    return [UIColor orangeColor];
}


- (NSUInteger) displayIndex
{
	return ( _displayIndex );
}

- (void) setDisplayIndex: (NSUInteger) index
{
	_displayIndex = index;
}


- (CALayer *) glowSelectionLayer
{
	return ( _contentView.layer );
}

- (UIImage *) image
{
    return ( _imageView.image );
}

- (UIView *) contentView
{
	if ( _contentView == nil )
    {
		_contentView = [[UIView alloc] initWithFrame: self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _contentView.autoresizesSubviews = YES;
        
        //CGRect frame=CGRectMake(_padding, _padding, 256-_padding*2, 256-_padding*2);
        //_contentView.frame=frame;
        
        //_contentView.backgroundColor = [self getBgColor];
		[_contentView.layer setValue: [NSNumber numberWithBool: YES] forKey: @"KoboHackInterestingLayer"];
        [self addSubview: _contentView];
    }
	return ( _contentView );
}

- (void) setImage: (UIImage *) anImage
{
    _imageView.image = anImage;
    [self setNeedsLayout];
}

//- (void)startIconDownload:(YummyCell *)appRecord forIndexPath:(YummyCell*)indexPath
//{
//    YummyMetroViewController *viewController=((YummyAppDelegate*)[[UIApplication sharedApplication] delegate]).viewController;
//    NSMutableDictionary *imageDownloadsInProgress=viewController.imageDownloadsInProgress;
//    ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:self];
//    if (imageDownloader == nil) 
//    {
//        imageDownloader = [[ImageDownloader alloc] init];
//        imageDownloader.cell = self;
//        //imageDownloader.delegate = self;
//        [imageDownloadsInProgress setObject:imageDownloader forKey:self];
//        [imageDownloader startDownload];
//        [imageDownloader release];   
//    }
//}


- (void)startIconDownload:(YummyCell *)cell forIndexPath:(YummyCell*)indexPath
{
    YummyMetroViewController *viewController=((YummyOnMeAppDelegate*)[[UIApplication sharedApplication] delegate]).viewController;
    NSMutableDictionary *imageDownloadsInProgress=viewController.imageDownloadsInProgress;
    ASIHTTPRequest *request = [imageDownloadsInProgress objectForKey:self];
    
    if (request == nil) 
    {
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.yummyItem.imageURLString]];
        //[request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        //[request setDownloadCache:viewController.cache];
        //NSRange range=[self.yummyItem.imageURLString rangeOfString:@"s/"];
        //NSString *name=[self.yummyItem.imageURLString substringFromIndex:(range.location+range.length )];
        //useless 'cause you've implement your own delegate
        //[request setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:name]];
        //[request setUserInfo:[NSDictionary dictionaryWithObject:@"request1" forKey:@"name"]];
        //[request setDidFailSelector:@selector(webPageFetchFailed:)];
        //[request setDidFinishSelector:@selector(webPageFetchSucceeded:)];
        [request setDelegate:self];
        [request startAsynchronous];
    }
}

-(CGRect) getContentBounds
{
    //CGSize cellSize=self.bounds.size;
    //CGRect contentRect=CGRectMake(_padding, _padding, cellSize.width-_padding*2, cellSize.height-_padding*2);
    CGRect contentRect = CGRectInset( self.bounds, _padding, _padding );//this a simple way
    return contentRect;
}

-(void) checkImage
{
    if (!_imageView.image)
    {
        NSString* docPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents"];
        NSString* imagePath =[NSString stringWithFormat: @"%@/%@.png", docPath, [self md5:self.yummyItem.imageURLString]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) 
        {  
            //NSArray *array = [[NSArray alloc] initWithContentsOfFile:imagePath];  
            NSData *data = [[NSMutableData alloc] initWithContentsOfFile: imagePath];
            UIImage *image = [[UIImage alloc] initWithData:data];
            [self setImage:image];
        }
        else
        {
            [self startIconDownload:self forIndexPath:self];
            // if a download is deferred or in progress, return a placeholder image
            //_imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            _imageView.image = [UIImage imageNamed:@"alien.png"];
        }
    }
}

-(void) layoutIcon:(CGRect)contentBounds
{
    CGSize contentSize=contentBounds.size;
    
    [self checkImage];
    
    // scale it down to fit
    CGRect frame=_imageView.frame;
    CGSize imageSize=_imageView.image.size;
    CGFloat hRatio = contentSize.width / imageSize.width;
    CGFloat vRatio = contentSize.height / imageSize.height;
    CGFloat ratio = MIN(hRatio, vRatio);
    
    frame.size.width =floorf(imageSize.width * ratio);
    frame.size.height = floorf(imageSize.height * ratio);
    frame.origin.x =floorf((contentSize.width - frame.size.width) * 0.5);
    frame.origin.y =floorf((contentSize.height - frame.size.height) * 0.5);
    //NSLog(@"icon new Frame(%f,%f,%f,%f)",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    _imageView.frame = frame;
}


-(void) layoutLabels:(CGRect)contentBounds
{
    [_indexLabel setText:[NSString stringWithFormat:@"%d",_displayIndex]];
    _indexLabel.font = [UIFont boldSystemFontOfSize: 24.0];
    CGRect frame00=CGRectMake(210, 0, 40, 40);
    _indexLabel.frame=frame00;
    _indexLabel.textAlignment=UITextAlignmentRight;
    NSLog(@"layoutLabels,Title:%@",self.yummyItem.title);//XXX
    
    
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4]; 
    _titleLabel.font = [UIFont boldSystemFontOfSize: 24.0];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    //_titleLabel.minimumFontSize = 16.0;
    
    
    CGRect bounds = CGRectMake(0, 210, 250, 40);//FIXME
    //NSLog(@"Label Bounds(%f,%f,%f,%f)",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);//XXX
    
    [_titleLabel setText:self.yummyItem.title];
    
    CGRect frame = _titleLabel.frame;
    frame.size.width = MIN(frame.size.width, bounds.size.width);
    frame.origin.y = CGRectGetMaxY(bounds) - frame.size.height;
    frame.origin.x = floorf((bounds.size.width - frame.size.width) * 0.5);
    _titleLabel.frame = frame;
    _titleLabel.frame = bounds;
    //[_titleLabel sizeToFit];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentBounds = [self getContentBounds];
    
    _contentView.backgroundColor = [self getBgColor];  
    _contentView.frame=contentBounds;
    
    [self layoutLabels:contentBounds];
    [self layoutIcon:contentBounds];
}

-(void) touchAtPoint:(CGPoint)point
{
    [self setHighlighted: YES animated:YES];
}

- (void) setHighlighted: (BOOL) value animated: (BOOL) animated
{
    CALayer * theLayer = self.glowSelectionLayer;
    
    //if ([theLayer respondsToSelector: @selector(setShadowPath:)] && [theLayer respondsToSelector: @selector(shadowPath)])
    //{
//        if ( _cellFlags.setShadowPath == 0 )
//        {
//            CGMutablePathRef path = CGPathCreateMutable();
//            CGPathAddRect( path, NULL, theLayer.bounds );
//            theLayer.shadowPath = path;
//            CGPathRelease( path );
//            _cellFlags.setShadowPath = 1;
//        }
        
        theLayer.shadowOffset = CGSizeZero;
        
        //if ( _cellFlags.selectionGlowColorSet == 1 )
        //    theLayer.shadowColor = self.selectionGlowColor.CGColor;
        //else
        theLayer.shadowColor = [[UIColor greenColor] CGColor];
        
        theLayer.shadowRadius = 15.0f;//self.selectionGlowShadowRadius;
        
        // add or remove the 'shadow' as appropriate
        if ( value )
            theLayer.shadowOpacity = 1.0;
        else
            theLayer.shadowOpacity = 0.0;
    //}
}

- (void) prepareForReuse
{
    //_cellFlags.setShadowPath = 0;
}




- (NSString *) findUniqueSavePath
{
	//int i = 1;
	NSString *path; 
	//do 
    // {
    //   //iterate until a name does not match an existing file
    //    path = [NSString stringWithFormat:@"%@/Documents/IMAGE_%04d.PNG", NSHomeDirectory(), i++];
	//} while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
    NSString *name=[self md5:self.yummyItem.imageURLString];
	path = [NSString stringWithFormat:@"%@/Documents/%@.png", NSHomeDirectory(), name];
	return path;
}


//****************************************************************************************************

- (void)requestStarted:(ASIHTTPRequest *)request
{
	
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
	
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSMutableData *raw=request.rawResponseData;
    UIImage *image = [[UIImage alloc] initWithData:raw];
    
    // Write to file
	// [UIImageJPEGRepresentation(image, 1.0f) writeToFile:[self findUniqueSavePath] atomically:YES];
    //NSLog(@"Write file{%@} to Documents",[self findUniqueSavePath]);
	[UIImagePNGRepresentation(image) writeToFile:[self findUniqueSavePath] atomically:YES];
    
    [self setImage:image];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
		
}


- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
	
}
@end