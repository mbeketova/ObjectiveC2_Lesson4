//
//  TableMapViewController.m
//  ObjectiveC2_Lesson4
//
//  Created by Admin on 16.05.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import "TableMapViewController.h"
#import "ViewController.h"
#import "TableViewCell.h"
#import "SingleTone.h"

@interface TableMapViewController () {
    BOOL isCurrentLocation;
}

- (IBAction)button_Back:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * arrayAdress;
@property (nonatomic, strong) CLLocationManager * locationManager;


@end

@implementation TableMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isCurrentLocation = NO;
    
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    SingleTone * sing = [SingleTone sharedSingleTone];
    self.arrayAdress = sing.arrayAdress;

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
    
    //увеличение карты с анимацией до масштаба карты 500X500 метров
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 500, 500);
    [self.mapView setRegion:region animated:YES];
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

- (UIView*) getCalloutView: (NSString*) title { // метод, который подписывает данные над маркером
    
    //создаем вью для вывода адреса:
    UIView * callView = [[UIView alloc]initWithFrame:CGRectMake(-60, -50, 150, 50)];
    callView.backgroundColor = [UIColor yellowColor];
    callView.layer.borderWidth = 1.0;
    callView.layer.cornerRadius = 7.0;
    
    
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    //устанавливаем маркер на карту
    if (![annotation isKindOfClass:MKUserLocation.class]) {
        
        MKAnnotationView*annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        annView.canShowCallout = NO;
        annView.image = [UIImage imageNamed:@"marker_apartments.png"];
        
        [annView addSubview:[self getCalloutView:annotation.title]]; //вызываем метод, который подписывает адрес над маркером
        
        
        
        return annView;
        
    }
    
    return nil;
}




//--------------------------------------------------------------------------------------------------------------------------


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayAdress.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * simpleTaibleIndefir = @"Cell";
    TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:simpleTaibleIndefir];
    
    cell.label_City.text = [[self.arrayAdress objectAtIndex:indexPath.row]objectForKey:@"City"];
    cell.label_Street.text = [[self.arrayAdress objectAtIndex:indexPath.row]objectForKey:@"Street"];
    cell.label_ZIP.text = [[self.arrayAdress objectAtIndex:indexPath.row]objectForKey:@"ZIP"];
    
    
    
    
    return cell;
    
    
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //метод, который позволяет редактировать таблицу
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //этот метод будет срабатывать, если стиль редактирования: удалить
    if (editingStyle ==  UITableViewCellEditingStyleDelete) {
        UILocalNotification * notif = [self.arrayAdress objectAtIndex:indexPath.row];
        [self.arrayAdress removeObjectAtIndex:indexPath.row];
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
        [self removeAllAnnotations]; //удаляем аннотации с карты
        [self reloadTableView]; //перезагружаем таблицу
        
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self removeAllAnnotations]; //удаляем аннотацию при переходе на другую ячейку в таблице
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //по индексу ячейки находим координаты в массиве self.arrayAdress и устанавливаем данные координаты по центру карты
    NSDictionary * dict = [self.arrayAdress objectAtIndex:indexPath.row];
    CLLocation * newLocation = [[CLLocation alloc] init];
    newLocation = [dict objectForKey:@"location"];
    [self setupMapView:newLocation.coordinate];
    

    //по полученным координатам устанавливаем аннотацию:
    CLGeocoder * geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark * place = [placemarks objectAtIndex:0];
        //записываем адрес с индексом в NSString
        NSString * adressString = [[NSString alloc] initWithFormat:@"%@\n%@\nИндекс - %@", [place.addressDictionary valueForKey:@"City"], [place.addressDictionary valueForKey:@"Street"], [place.addressDictionary valueForKey:@"ZIP"]];
        
        MKPointAnnotation * annotation = [[MKPointAnnotation alloc]init];
        annotation.title = adressString;
        annotation.coordinate = newLocation.coordinate;
  
            
        [self.mapView addAnnotation:annotation]; //добавляем на карту аннотацию

    }];
    
}



//--------------------------------------------------------------------------------------------------------------------------

//метод, который перезагружает таблицу:
- (void) reloadTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];});
}

//--------------------------------------------------------------------------------------------------------------------------

//метод, который убирает аннотации с карты:
- (void) removeAllAnnotations {
    id userAnnotation = self.mapView.userLocation;
    NSMutableArray*annotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    [annotations removeObject:userAnnotation];
    [self.mapView removeAnnotations:annotations];
    
}

//--------------------------------------------------------------------------------------------------------------------------


- (IBAction)button_Back:(id)sender {
    //действие кнопки: при нажатии открывается предыдущее окно с картой
    TableMapViewController * view = [self.storyboard instantiateViewControllerWithIdentifier:@"super"];
    [self.navigationController pushViewController:view animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
@end
