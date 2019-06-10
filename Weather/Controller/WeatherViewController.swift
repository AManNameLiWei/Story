//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
  
  //Constants
  let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
  let APP_ID = "e72ca729af228beabd5d20e3b7749713"
  
  
  //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    
    let weatherDataModel = WeatherDataModel()
    
  
  
  //Pre-linked IBOutlets
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var weatherIcon: UIImageView!
  @IBOutlet weak var cityLabel: UILabel!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    //TODO:Set up the location manager here.
    
    //设置代理
    locationManager.delegate = self
    
    //设置精度
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    
    //询问是否打开获取位置数据的权限  程序使用时
    locationManager.requestWhenInUseAuthorization()
    
    //开始定位
    locationManager.startUpdatingLocation()
    
    
  }
  
  
  
  //MARK: - Networking
  /***************************************************************/
  
  //Write the getWeatherData method here:
    //发起请求获取数据
    func getWeatherData(url: String, parameters: [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                print("成功获取气象数据")
                
                let weatherJSON: JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)
                
            }else{
                print("错误: \(String(describing: response.result.error))")
                self.cityLabel.text = "连接问题"
            }
        }
        
    }
  
  
  //MARK: - JSON Parsing
  /***************************************************************/
  
  //Write the updateWeatherData method here:
        //解析数据
    func updateWeatherData(json: JSON){
        //用可选绑定方式获取main里面temp的值    main 和  temp都是字典
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            //通过传回的气象数值判断天气
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            //更新控件
            updateUIWithWeatherData()
        }else{
            cityLabel.text = "气象信息不可用"
        }

    }
  
  
  //MARK: - UI Updates
  /***************************************************************/
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = weatherDataModel.temperature.description
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
  
  //Write the updateUIWithWeatherData method here:
  
  
  
  
  
  
  //MARK: - Location Manager Delegate Methods
  /***************************************************************/
  
  
  //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //获取地点数组里最后一个位置  是最精确的
        let location = locations[locations.count - 1]
        
        //如果用户所在位置的属性值大于0 ，地点就存在
        if location.horizontalAccuracy > 0 {
            //停止定位
            locationManager.stopUpdatingLocation()
            
            //将代理设为nil  不再需要了
            locationManager.delegate = nil
            
            print("经度：\(location.coordinate.longitude)  纬度：\(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
        
    }
  
  
  
  //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "定位失败"
    }
  
  
  
  //MARK: - Change City Delegate methods
  /***************************************************************/
  
  
  //Write the userEnteredANewCityName Delegate method here:
    func userDidEnterANewCityName(city: String) {
        let params: [String: String] = ["q": city, "appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }
  
  
  //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
}


