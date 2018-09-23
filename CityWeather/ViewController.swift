//
//  ViewController.swift
//  CityWeather
//
//  Created by Seif Yasser on 9/21/18.
//  Copyright © 2018 Seif Yasser. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var laCityName: UITextField!
    @IBOutlet weak var laSunRise: UILabel!
    @IBOutlet weak var laSunSet: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var laTitle: UILabel!
    
    var forecastItemModel = [ForecastModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadURL(url : String) {
        
        do {
            let appURL = URL(string: url)!
            let data = try Data(contentsOf: appURL)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                else {
                    print("Error to parse json")
                    return
            }
            guard let query = json["query"] as? [String : Any]
                else {
                    print("Error to parse query")
                    return
            }
            guard let results = query["results"] as? [String : Any]
                else {
                    print("Error to parse results")
                    return
            }
            guard let channel = results["channel"] as? [String : Any]
                else {
                    print("Error to parse channel")
                    return
            }
            
            guard let item = channel["item"] as? [String : Any]
                else {
                    print("Error to parse item")
                    return
            }
            let pubDate = item["pubDate"] as! String
            laTitle.text = pubDate
            
            
            guard let astronomy = channel["astronomy"] as? [String : Any]
                else {
                    print("Error to parse astronomy")
                    return
            }
            let sunrise = astronomy["sunrise"] as! String
            let sunset = astronomy["sunset"] as! String
            laSunRise.text = sunrise
            laSunSet.text = sunset
            
            
            guard let forecast = item["forecast"] as? [[String : Any]]
                else {
                    print("Error to parse forecast")
                    return
            }
            for forecastItem in forecast {
                let day = forecastItem["day"] as! String
                let date = forecastItem["date"] as! String
                let text = forecastItem["text"] as! String
                let high = "\(forecastItem["high"] as! String) F"
                let low = "\(forecastItem["low"] as! String) F"
                
                forecastItemModel.append(ForecastModel(text: text, day: day, date: date, high: high, low: low))
            }
            self.tableView.reloadData()
            
            
            laSunRise.text = sunrise
            laSunSet.text = sunset
            
        }
        catch {
            print(error)
        }
    }

    @IBAction func buSearch(_ sender: UIButton) {
        let url = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22\(laCityName.text!)%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
        loadURL(url: url)
    }

}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastItemModel.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forcastCell", for: indexPath)
        
        let textLabel = cell.viewWithTag(1) as! UILabel
        let dayLabel = cell.viewWithTag(2) as! UILabel
        let dateLabel = cell.viewWithTag(3) as! UILabel
        let highLabel = cell.viewWithTag(4) as! UILabel
        let lowLabel = cell.viewWithTag(5) as! UILabel
        
        textLabel.text = forecastItemModel[indexPath.row].text
        dayLabel.text = forecastItemModel[indexPath.row].day
        dateLabel.text = forecastItemModel[indexPath.row].date
        highLabel.text = forecastItemModel[indexPath.row].high
        lowLabel.text = forecastItemModel[indexPath.row].low
        
        return cell
        
    }
}

