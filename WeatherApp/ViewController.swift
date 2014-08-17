//
//  ViewController.swift
//  WeatherApp
//
//  Created by jollen on 2014/8/16.
//  Copyright (c) 2014年 Mokoversity. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLConnectionDelegate {
    
    @IBOutlet var city: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var temperature: UILabel!
    
    // 使用 NSMutableData 儲存下載資料
    var data: NSMutableData = NSMutableData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background image
        let background = UIImage(named: "Rainy-Wallpaper.jpg")
        self.view.backgroundColor = UIColor(patternImage: background)
        
        // Do any additional setup after loading the view, typically from a nib.
        self.city.text = "Taipei"
        self.icon.image = UIImage(named: "rainy")
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        self.view.addGestureRecognizer(singleFingerTap)
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        startConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startConnection() {
        var restAPI: String = "http://api.openweathermap.org/data/2.5/weather?q=Taipei"
        var url: NSURL = NSURL(string: restAPI)
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        
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
        
        // 資料處理
        let weatherTempCelsius = Int(round((temp!.floatValue - 273.15)))
        let weatherTempFahrenheit = Int(round(((temp!.floatValue - 273.15) * 1.8) + 32))
        
        // 輸出到 UI
        self.temperature.text = "\(weatherTempCelsius)℃"
    }
}

