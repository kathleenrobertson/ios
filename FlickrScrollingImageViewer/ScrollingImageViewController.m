//
//  ScrollingImageViewController.m
//  Shutterbug
//
//  Created by Kathleen Robertson on 3/5/13.
//

#import "ScrollingImageViewController.h"
#import "FlickrFetcher.h"

#define PLACE_INDEX 0
#define PHOTO_INDEX 0

@interface ScrollingImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) float savedZoomScale;

@end

@implementation ScrollingImageViewController

@synthesize photo = _photo;
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize savedZoomScale = _savedZoomScale;

#pragma mark - UIScrollViewDelegate Protocol Methods
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

#pragma mark - UIScrollView Subclass
-(BOOL)hidesBottomBarWhenPushed{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 10;
    self.scrollView.bounces = NO;
    self.scrollView.bouncesZoom = NO;    
}

- (IBAction)loadImage:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Photo Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        UIImage *flickrImage = [self imageFromURL:[FlickrFetcher urlForPhoto:[[FlickrFetcher photosInPlace:[[FlickrFetcher topPlaces] objectAtIndex:PLACE_INDEX] maxResults:1] objectAtIndex:PHOTO_INDEX] format:FlickrPhotoFormatLarge]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = flickrImage;
            [self zoomToFitImageWithNoExtraSpace];
            self.navigationItem.rightBarButtonItem = sender;
        });
    });
}

//This method calculates the CGRect to zoom to in order to display as much of the image on scren as possible, with no extra whitespace.
-(void)zoomToFitImageWithNoExtraSpace{
    float imageViewWidthHeightRatio = self.imageView.bounds.size.width/self.imageView.bounds.size.height;
    float imageResolutionWidthHeightRatio = self.imageView.image.size.width/self.imageView.image.size.height;
    CGRect zoomRect;
    
    if(imageResolutionWidthHeightRatio > imageViewWidthHeightRatio){
        zoomRect.size.width = (self.imageView.image.size.height * self.imageView.bounds.size.width * self.imageView.bounds.size.width)
                                /
                            (self.imageView.bounds.size.height * self.imageView.image.size.width);
        zoomRect.size.height = zoomRect.size.width / imageViewWidthHeightRatio;
    }
    else{
        zoomRect.size.height = (self.imageView.image.size.width * self.imageView.bounds.size.height * self.imageView.bounds.size.height)
                                /
                            (self.imageView.bounds.size.width * self.imageView.image.size.height);
        zoomRect.size.width = (zoomRect.size.height * imageViewWidthHeightRatio);
        [self.scrollView zoomToRect:zoomRect animated:NO];
    }
    zoomRect.origin.x = (self.imageView.bounds.size.width - zoomRect.size.width) / 2;
    zoomRect.origin.y = (self.imageView.bounds.size.height - zoomRect.size.height) / 2;
    [self.scrollView zoomToRect:zoomRect animated:NO];
}

-(UIImage *)imageFromURL:(NSURL *)imageURL{
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    return [UIImage imageWithData:imageData];
}

#pragma mark - Autorotation
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGSize newContentSize;
    newContentSize.height = self.scrollView.bounds.size.height * self.scrollView.zoomScale;
    newContentSize.width = self.scrollView.bounds.size.width * self.scrollView.zoomScale;
    self.scrollView.contentSize = newContentSize;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(BOOL)shouldAutorotate{
    return YES;
}

#pragma mark - Convenience Log Methods
-(void)displayAllBoundsInformation{
    NSLog(@"scrollView bounds height: %f",self.scrollView.bounds.size.height);
    NSLog(@"scrollView bounds width: %f",self.scrollView.bounds.size.width);
    NSLog(@"scrollView contentSize height: %f",self.scrollView.contentSize.height);
    NSLog(@"scrollView contentSize width: %f",self.scrollView.contentSize.width);
    NSLog(@"imageView height: %f",self.imageView.bounds.size.height/self.scrollView.zoomScale);
    NSLog(@"imageView width: %f",self.imageView.bounds.size.width/self.scrollView.zoomScale);
    NSLog(@"imageHeight: %f",self.imageView.image.size.height);
    NSLog(@"imageWidth: %f\n\n",self.imageView.image.size.width);
}

@end
