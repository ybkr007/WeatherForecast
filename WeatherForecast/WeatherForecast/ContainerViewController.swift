//
//  ContainerViewController.swift
//  WeatherForecast
//
//  Created by Bharath Yeddula on 08/11/16.
//  Copyright © 2016 Bharath Yeddula. All rights reserved.
//

import UIKit
import OpenWeatherMapAPI
import PermissionScope

class ContainerViewController: UIViewController,CLLocationManagerDelegate {

    enum TabIndex : Int {
        case CurrentForecast = 0
        case WeeklyForecast = 1
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var locationManager = CLLocationManager()
    var currentForecastViewController:UIViewController?
    var weeklyForecastViewController:UIViewController?
    var currentViewController:UIViewController?
    
    var weatherData:NSDictionary?{
        didSet{
            self.reloadCurrentVC()
        }

    }
    var weatherApi:OWMWeatherAPI?
    let pscope = PermissionScope()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        weatherApi = OWMWeatherAPI(apiKey: "ff7cd2b18a5cbd0b578622ce8c517853")
        weatherApi?.setTemperatureFormat(kOWMTempCelcius)
        
        // Set up permissions
        pscope.addPermission(LocationWhileInUsePermission(),
                             message: "We use this to track\r\nwhere you live")
        
        segmentedControl.selectedSegmentIndex = TabIndex.CurrentForecast.rawValue
        displayCurrentTab(tabIndex: TabIndex.CurrentForecast.rawValue)
        
        // Show dialog with callbacks
        pscope.show({ finished, results in
            print("got results \(results)")

            self.locationManager.startUpdatingLocation()

            }, cancelled: { (results) -> Void in
                print("thing was cancelled")
        })
        
        // Do any additional setup after loading the view.
        /*weatherApi = OWMWeatherAPI(apiKey: "ff7cd2b18a5cbd0b578622ce8c517853")
        weatherApi?.setTemperatureFormat(kOWMTempCelcius)
        weatherApi?.currentWeather(by: <#T##CLLocationCoordinate2D#>, withCallback: { (error, result) in
            
        })*/
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Switching Tab Functions
    
    @IBAction func switchTabs(sender: UISegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(tabIndex: sender.selectedSegmentIndex)
    }
    
    func reloadCurrentVC(){
        if(segmentedControl.selectedSegmentIndex == TabIndex.CurrentForecast.rawValue){
            if let currentVC = viewControllerForSelectedSegmentIndex(index: segmentedControl.selectedSegmentIndex) as? CurrentForecastViewController{
                currentVC.weatherData = self.weatherData
            }
        }else{
            if let currentVC = viewControllerForSelectedSegmentIndex(index: segmentedControl.selectedSegmentIndex) as? WeeklyForecastViewController{
                currentVC.weatherData = self.weatherData
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[0]
        let userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        self.locationManager.stopUpdatingLocation()
        weatherApi?.dailyForecastWeather(by: userLocation, withCount: 7, andCallback: { (error, result) in
            if(error == nil){
                self.weatherData = result as NSDictionary?
            }
        })

    }
    func displayCurrentTab(tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(index: tabIndex) {
            
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
            vc.viewWillAppear(true)
        }
    }

    func viewControllerForSelectedSegmentIndex(index: Int) ->UIViewController? {
    var vc: UIViewController?
    switch index {
    case TabIndex.CurrentForecast.rawValue :
    if currentForecastViewController == nil {
    currentForecastViewController = (self.storyboard?.instantiateViewController(withIdentifier: "CurrentForecast"))! as UIViewController
    }
    vc = currentForecastViewController
    case TabIndex.WeeklyForecast.rawValue :
    if weeklyForecastViewController == nil {
    weeklyForecastViewController = (self.storyboard?.instantiateViewController(withIdentifier: "WeeklyForecast"))! as UIViewController
    }
    vc = weeklyForecastViewController
    default:
    return nil
    }
    
    return vc
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
