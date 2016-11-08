//
//  CurrentForecastViewController.swift
//  WeatherForecast
//
//  Created by Bharath Yeddula on 08/11/16.
//  Copyright © 2016 Bharath Yeddula. All rights reserved.
//

import UIKit

class CurrentForecastViewController: UIViewController {

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    var weatherData:NSDictionary? {
        
        didSet{
            self.reloadView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadView(){
        var currentWeather = (weatherData?["list"] as? NSArray)?[0] as? NSDictionary
        print(currentWeather)
        self.descriptionLabel.text = ((currentWeather?["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String
        let icon = ((currentWeather?["weather"] as? NSArray)?[0] as? NSDictionary)?["icon"] as? String
        self.iconImageView.downloadedFrom(link: "http://openweathermap.org/img/w/\(icon!).png")
        
        let temparature = (currentWeather?["temp"] as? NSDictionary)? ["day"] as? Int
        self.tempLabel.text = "\(temparature!) degree C"
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
