//
//  ViewController.m
//  ObjectiveC2_Lesson4
//
//  Created by Admin on 16.05.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import "ViewController.h"
#import "SingleTone.h"


//--------------------------------------------------------------------------------------------------------------------------

/*ДЗ: доделать карту.
Создать два окна с картой, при этом сбор  адресов посредством лонгпресс реализуется в одном окне,
а вывод значений на карту делается при переходе во второе окно.
Получившийся массив адресов необходимо хранить в Синглтоне и вызывать его оттуда же.

Непосредственное добавления адреса необходимо реализовать посредством использования блока с передачей аргументов
(адрес/индекс/город/координаты) в другой метод.*/



//--------------------------------------------------------------------------------------------------------------------------

@interface ViewController (){
    BOOL isCurrentLocation;
}

- (IBAction)button_AddTable:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (strong, nonatomic) NSMutableArray * arrayAdress;
- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender;



@end

@implementation ViewController

//--------------------------------------------------------------------------------------------------------------------------

- (void) firstStart {
    //метод, который срабатывает один раз при первом запуске, если версия IOS = 8, или выше.
    NSString * ver = [[UIDevice currentDevice]systemVersion];
    
    if ([ver intValue] >=8) {
        [self.locationManager requestAlwaysAuthorization];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstStart"];
    }
    
}

//--------------------------------------------------------------------------------------------------------------------------


- (void)viewDidLoad {
    [super viewDidLoad];
    
    isCurrentLocation = NO;
    
    
    self.arrayAdress = [[NSMutableArray alloc]init];
    
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    //срабатывает только при первом запуске:
    BOOL isFirstStart = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstStart"];
    
    if (!isFirstStart) {
        [self firstStart];
    }
}

//--------------------------------------------------------------------------------------------------------------------------

#pragma mark - MKMapViewDelegate
    
    
- (void) mapViewWillStartLoadingMap:(MKMapView *)mapView{
        // метод, который можно использовать, пока загружается карта
    
    }
    
    
    
- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
        //метод, который работает после того, как полностью загружена карта
        
        if (fullyRendered) {
            [self.locationManager startUpdatingLocation];
        }
        
    }
    
    
    
- (void) setupMapView: (CLLocationCoordinate2D) coord {
        
        //увеличение карты с анимацией до масштаба карты 1000X1000 метров
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000);
        [self.mapView setRegion:region animated:YES];
    }
    
    
    
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
        
        //устанавливаем маркер при длительном нажатии на карту
        if (![annotation isKindOfClass:MKUserLocation.class]) {
            
            MKAnnotationView*annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
            annView.canShowCallout = NO;
            annView.image = [UIImage imageNamed:@"marker_apartments.png"];
            
            [annView addSubview:[self getCalloutView:annotation.title]]; //вызываем метод, который подписывает адрес над маркером
            
            return annView;
            
        }
        
        
        return nil;
    }
    
    
    
- (UIView*) getCalloutView: (NSString*) title { // метод, который подписывает данные над маркером
        
        //создаем вью для вывода адреса:
        UIView * callView = [[UIView alloc]initWithFrame:CGRectMake(-60, -50, 150, 50)];
        callView.backgroundColor = [UIColor yellowColor];
        callView.layer.borderWidth = 1.0;
        callView.layer.cornerRadius = 7.0;
        
        
        callView.tag = 1000;
        callView.alpha = 0; //делаем прозрачной вью с адресом, чтобы не высвечивалось на карте при установке маркеров
        
        //создаем лейбл для вывода адреса
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 150, 50)];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping; // перенос по словам
        label.textAlignment = NSTextAlignmentCenter; //выравнивание по центру
        label.textColor = [UIColor blackColor];
        label.text = title;
        label.font = [UIFont fontWithName: @"Arial" size: 10.0];
        
        [callView addSubview:label];
        
        return callView;
        
        
    }
    
//--------------------------------------------------------------------------------------------------------------------------
    
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
        //данный метод делает видимой вью с адресом при нажатии на маркер
        if (![view.annotation isKindOfClass:MKUserLocation.class]) {
            for (UIView * subView in view.subviews) {
                if (subView.tag == 1000) {
                    subView.alpha = 1;
                }
            }
        }
        
    }
    
    
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
        //данный метод делает невидимой вью с адресом при нажатии на другой элемент
        for (UIView * subView in view.subviews) {
            if (subView.tag == 1000) {
                subView.alpha = 0;
            }
        }
        
    }
    
//--------------------------------------------------------------------------------------------------------------------------
    
    
#pragma mark - CLLocationManagerDelegate
    
- (void)locationManager:(CLLocationManager *)manager
didUpdateToLocation:(CLLocation *)newLocation
fromLocation:(CLLocation *)oldLocation {
    //метод будет срабатывать, когда позиция пользователя изменилась
    
    
    if (!isCurrentLocation) { //использовать тогда, когда надо зафиксировать местоположение пользователя (можно так же подключить еще NSTimer -  чтобы фиксация действовала какое-то время)
        isCurrentLocation = YES;
        [self setupMapView:newLocation.coordinate];
    }
    
}
    
//--------------------------------------------------------------------------------------------------------------------------
    


- (IBAction)button_AddTable:(id)sender {
    //действие кнопки: при нажатии открывается следующее окно с картой и таблицей
    
    SingleTone * sing = [SingleTone sharedSingleTone];
    sing.arrayAdress = self.arrayAdress;
    
    ViewController * view = [self.storyboard instantiateViewControllerWithIdentifier:@"table"];
    [self.navigationController pushViewController:view animated:YES];
    
    
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {

    // метод, который срабатывает при длительном нажатии на карту
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        //получаем координаты точки нажатия:
        CLLocationCoordinate2D coordScreenPoint = [self.mapView convertPoint:[sender locationInView:self.mapView] toCoordinateFromView:self.mapView];
        CLGeocoder * geocoder = [[CLGeocoder alloc]init];
        
        //по координатам точки касания получаем адрес:
        CLLocation * tapLocation = [[CLLocation alloc] initWithLatitude:coordScreenPoint.latitude longitude:coordScreenPoint.longitude];
        [geocoder reverseGeocodeLocation:tapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            
            CLPlacemark * place = [placemarks objectAtIndex:0];
            
            
            //записываем адрес с индексом в NSString
            NSString * adressString = [[NSString alloc] initWithFormat:@"%@\n%@\nИндекс - %@", [place.addressDictionary valueForKey:@"City"],
                                                                                               [place.addressDictionary valueForKey:@"Street"],
                                                                                               [place.addressDictionary valueForKey:@"ZIP"]];
            
            MKPointAnnotation * annotation = [[MKPointAnnotation alloc]init];
            annotation.title = adressString;
            annotation.coordinate = coordScreenPoint;
            
            
            [self.mapView addAnnotation:annotation]; //добавляем на карту аннотацию
            
            
            //добавляем данные в массив для заполнения таблицы:
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                          [place.addressDictionary valueForKey:@"City"], @"City",
                                          [place.addressDictionary valueForKey:@"Street"], @"Street",
                                          [place.addressDictionary valueForKey:@"ZIP"], @"ZIP",
                                          tapLocation, @"location", nil];
            
            
            [self.arrayAdress addObject: dict];
            
            
            
        }];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
@end
