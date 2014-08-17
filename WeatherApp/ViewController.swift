//
//  ViewController.swift
//  WeatherApp
//
//  Created by jollen on 2014/8/16.
//  Copyright (c) 2014年 Mokoversity. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, NSURLConnectionDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var city: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var temperature: UILabel?
    
    // 使用 NSMutableData 儲存下載資料
    var data: NSMutableData = NSMutableData()
    
    // 使用 CLLocationManager
    var locationManager:CLLocationManager?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background image
        let background = UIImage(named: "Rainy-Wallpaper.jpg")
        self.view.backgroundColor = UIColor(patternImage: background)
        
        // Do any additional setup after loading the view, typically from a nib.
        self.city.text = "Taipei"
        self.icon.image = UIImage(named: "rainy")
      
        // Default location
        self.latitude = 56.15
        self.longitude = 9.30
        
        // Get my location
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        self.locationManager!.requestAlwaysAuthorization()
        self.locationManager!.requestWhenInUseAuthorization()
        self.locationManager!.startMonitoringSignificantLocationChanges()
        self.locationManager!.startUpdatingLocation()
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        self.view.addGestureRecognizer(singleFingerTap)
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.locationManager!.startUpdatingLocation()
        
        startConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startConnection() {
        var restAPIByCity: String = "http://api.openweathermap.org/data/2.5/weather?q=Taipei"
        var restAPIByLocation: String = "http://api.openweathermap.org/data/2.5/weather?lat="
                                + String(self.latitude!)
                                + "&lon="
                                + String(self.longitude!)
        var url: NSURL = NSURL(string: restAPIByLocation)
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        
        // 1. Delegation Pattern
        // 2. NSURLConnection.sendAsynchronousRequest
        
        println("start download")
    }
    
    // 下載中
    func connection(connection: NSURLConnection!, didReceiveData dataReceived: NSData!) {
        println("downloading")
        
        self.data.setData(dataReceived)
    }
    
    // 下載完成
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        println("download finished")
        
        var json = NSString(data: data, encoding: NSUTF8StringEncoding)
        println(json)

        // 解析 JSON
        // 使用 NSDictionary: NSDictionary 是一種 Associative Array 的資料結構
        var error: NSError?
        let jsonDictionary = NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        
        // 讀取各項天氣資訊
        let temp: AnyObject? = jsonDictionary["main"]?["temp"]
        let city: AnyObject? = jsonDictionary["name"]
        
        // use '?' to downcast optional type to NSArray
        if let weather = jsonDictionary["weather"]? as? NSArray {
            // Safe code 寫作觀念:
            // 使用 as? 轉型時，要把以下這行放進 if statement 裡處理
            let weatherDictionary = (weather[0] as NSDictionary)
            // 天氣狀態 (多雲、晴朗等等)
            let weatherId = weatherDictionary["id"] as Int
            println("Weather ID: \(weatherId)")
        }
        
        // 資料處理
        let weatherTempCelsius = Int(round((temp!.floatValue - 273.15)))
        let weatherTempFahrenheit = Int(round(((temp!.floatValue - 273.15) * 1.8) + 32))
        
        // 輸出到 UI
        self.temperature!.text = "\(weatherTempCelsius)℃"
        self.city.text = "\(city)"
    }
    
    
    //
    // Comform CLLocationManagerDelegate
    //
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:[AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        
        println("location got")
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
    
    func locationManager(manager: CLLocationManager!,
        didFailWithError error: NSError!) {
        println("can't get your location")
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("auth status: \(status)")
    }
}

