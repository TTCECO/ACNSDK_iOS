//
//  TTCLocationManager.swift
//  TTCSDK
//
//  Created by chenchao on 2019/1/16.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit
import CoreLocation

class TTCLocationManager: NSObject {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var countryCode = Locale.current.regionCode ?? ""
    
    static func isCanLocation() -> Bool {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        // denied = 拒绝，notDetermined = 未做出选择
        if status == .denied || status == .notDetermined {
            return false
        }
        
        return true
    }
    
    func locate() {
        
        if TTCLocationManager.isCanLocation() {
            loadLocation()
        }
//        else {
//            //始终允许访问位置信息
//            locationManager.requestAlwaysAuthorization()
//            //使用应用程序期间允许访问位置数据
//            locationManager.requestWhenInUseAuthorization()
//            loadLocation()
//        }
    }
    
    //打开定位
    fileprivate func loadLocation() {
        
        locationManager.delegate = self
        //定位方式
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //开启定位
        locationManager.startUpdatingLocation()
    }
    
    ///将经纬度转换为城市名
    fileprivate func getCurrencyCode(currLocation: CLLocation) {
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currLocation) { (placemark, error) -> Void in
            
            if error == nil, let mark = placemark?[0], let countryCode = mark.isoCountryCode {
                self.countryCode = countryCode
                print(countryCode)
            }
        }
    }
}

extension TTCLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            getCurrencyCode(currLocation: location)
        }
    }
}
