//
//  ViewController.swift
//  Clima
//


import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON



struct  WeatherDataModel {
    
    var temperature = Int()
    var city = String()
    var weatherIconName = String()

}

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: OUTLETS
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var changeCityTextField: UITextField!
    
    //MARK: Constants
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "4fe76d6d3ca3d145536320183e9e51a0"
    
    //MARK: INSTANCES
    let locationManager = CLLocationManager()
    var weatherDataModel = WeatherDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        // Do any additional setup after loading the view.

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    //MARK: Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if  location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longtitude = String(location.coordinate.longitude)
            
            let params : [String : String] = [
                "lat": latitude,
                "lon" : longtitude,
                "appid" : APP_ID
            ]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    //MARK: NETWORKING
    //could be used to request any API(networking)
    func getWeatherData(url: String, parameters: [String : String]) {
        
        AF.request(url, method: .get, parameters: parameters).responseJSON {  response in
            
            if response.result.isSuccess {
                
                let weatherJSON : JSON = JSON(response.value!)
//                print(weatherJSON)
//                print(response.value!)
                self.updateWeatherData(json: weatherJSON)
                
            } else {
               print("Faced error \(response.error)")
            }
            
        }
        
    }
    
    
    func updateWeatherData(json: JSON) {
        //main.temp
        var temperature = json["main"]["temp"].doubleValue - 273.15
        //print(temperature)//prints key of the main as map in C++
        
        //city name
        let cityName = json["name"].stringValue
        
        //weather[0]
        let condition = json["weather"][0]["id"].intValue
  
        let weatherIconImage = updateWeatherIcon(condition: condition)
        
        weatherDataModel.temperature = Int(temperature)
        weatherDataModel.city = cityName
        weatherDataModel.weatherIconName = weatherIconImage
        
        updateUIWithWeatherData()
    }
    
  
    
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
            
                case 0...300 :
                    return "tropicalstorm"
                
                case 301...500 :
                    return "cloud.rain"
                
                case 501...600 :
                    return "cloud.heavyrain.fill"
                
                case 601...700 :
                    return "snowflake"
                
                case 701...771 :
                    return "cloud.fog"
                
                case 772...799 :
                    return "tropicalstorm.circle.fill"
                
                case 800 :
                    return "sun.min"
                
                case 801...804 :
                    return "cloud"
                
                case 900...903, 905...1000  :
                    return "tropicalstorm.circle"
                
                case 903 :
                    return "cloud.snow"
                
                case 904 :
                    return "sun.max"
                
                default :
                    return "dunno"
                }
        
        
    }
    //MARK:Update UI
    func updateUIWithWeatherData() {
        temperatureLabel.text = String(weatherDataModel.temperature)
        cityLabel.text = weatherDataModel.city
        conditionImageView.image = UIImage(systemName: weatherDataModel.weatherIconName)
        
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        let cityName = changeCityTextField.text!
        
        let params : [String : String] = [
            "q": cityName,
            "appid": APP_ID
        ]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }
    
}

