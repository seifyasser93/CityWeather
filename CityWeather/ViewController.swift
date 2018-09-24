//
//  ViewController.swift
//  CityWeather
//
//  Created by Seif Yasser on 9/21/18.
//  Copyright © 2018 Seif Yasser. All rights reserved.
//

import UIKit
import RevealingSplashView

class ViewController: UIViewController {

    @IBOutlet weak var laCityName: UITextField!
    @IBOutlet weak var laSunRise: UILabel!
    @IBOutlet weak var laSunSet: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var forecastItemModel = [ForecastModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        
        //Initialize a revealing Splash with with the iconImage, the initial size and the background color
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Weather")!,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor.white)
        
        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        
        //Starts animation
        revealingSplashView.startAnimation()
        
        revealingSplashView.animationType = SplashAnimationType.squeezeAndZoomOut
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadURL(url : String) {
        DispatchQueue.main.async {
            do {
                let appURL = URL(string: url)!
                let data = try Data(contentsOf: appURL)
                
                let showAcivityInd = self.showActivityIndicator()
                
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
                
                guard let astronomy = channel["astronomy"] as? [String : Any]
                    else {
                        print("Error to parse astronomy")
                        return
                }
                let sunrise = astronomy["sunrise"] as! String
                let sunset = astronomy["sunset"] as! String
                self.laSunRise.text = sunrise
                self.laSunSet.text = sunset
                
                
                guard let forecast = item["forecast"] as? [[String : Any]]
                    else {
                        print("Error to parse forecast")
                        return
                }
                for forecastItem in forecast {
                    let day = forecastItem["day"] as! String
                    let date = forecastItem["date"] as! String
                    let text = forecastItem["text"] as! String
                    let highF = "\(forecastItem["high"] as! String) F"
                    let lowF = "\(forecastItem["low"] as! String) F"
                    let highC = "\(String(Int(forecastItem["high"] as! String)! - 32 * 5 / 9)) C"
                    let lowC = "\(String(Int(forecastItem["low"] as! String)! - 32 * 5 / 9)) C"
                    
                    self.forecastItemModel.append(ForecastModel(text: text, day: day, date: date, highF: highF, highC: highC, lowF: lowF, lowC: lowC))
                }
                
                self.hideActivityIndicator(activityIndicator: showAcivityInd)
                
                self.tableView.reloadData()
                
                self.laSunRise.text = sunrise
                self.laSunSet.text = sunset
                
            }
            catch {
                print(error)
            }
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
        let highCLabel = cell.viewWithTag(4) as! UILabel
        let highFLabel = cell.viewWithTag(5) as! UILabel
        let lowCLabel = cell.viewWithTag(6) as! UILabel
        let lowFLabel = cell.viewWithTag(7) as! UILabel
        
        textLabel.text = forecastItemModel[indexPath.row].text
        dayLabel.text = forecastItemModel[indexPath.row].day
        dateLabel.text = forecastItemModel[indexPath.row].date
        highCLabel.text = forecastItemModel[indexPath.row].highC
        highFLabel.text = forecastItemModel[indexPath.row].highF
        lowCLabel.text = forecastItemModel[indexPath.row].lowC
        lowFLabel.text = forecastItemModel[indexPath.row].lowF
        
        return cell
        
    }
    
    func showActivityIndicator () -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.color = UIColor.gray
        activityIndicator.center = self.view.center
        tableView.isHidden = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        return activityIndicator
    }
    func hideActivityIndicator (activityIndicator : UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        tableView.isHidden = false
    }
}

