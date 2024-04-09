//
//  ZBMapViewController.swift
//  Sabrina
//
//  Created by apple on 2021/12/2.
//

import UIKit

class ZBMapViewController: BaseViewController {
    
    var search: AMapSearchAPI!
    var mapView: MAMapView!
    var startCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var naviRoute: MANaviRoute?
    var route: AMapRoute?
    var currentSearchType: AMapRoutePlanningType = AMapRoutePlanningType.drive
    
    var animatedCarAnnotation: AnimatedAnnotation!
    var animatedTrainAnnotation: AnimatedAnnotation!
    
    var gpsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false )
        self.view.backgroundColor = UIColor.gray
        // Do any additional setup after loading the view.
        
        setupUI()
        initSearch()
        
        NotificationCenter.default.addObserver(self, selector: #selector(planningRoute), name: NSNotification.Name(rawValue: "NotificationReceivedTaLocationChanged"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 开启定位
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MAUserTrackingMode.follow
        
        // 我的本地位置
        let melocalLat:Double = UserDefaults.standard.double(forKey: "MeLocationLat")
        let melocallong:Double = UserDefaults.standard.double(forKey: "MeLocationLong")
        
        // ta的本地位置
        let localLat:Double = UserDefaults.standard.double(forKey: "TaLocationLat")
        let locallong:Double = UserDefaults.standard.double(forKey: "TaLocationLong")
        
        destinationCoordinate  = CLLocationCoordinate2DMake(localLat, locallong)
        if localLat == 0 || locallong == 0 {
            destinationCoordinate  = CLLocationCoordinate2DMake(melocalLat, melocallong)
        }
        
        // 初始化开始/结束位置
        startCoordinate        = CLLocationCoordinate2DMake(melocalLat, melocallong)
        destinationCoordinate  = CLLocationCoordinate2DMake(melocalLat, melocallong)
        
        // 延迟2面动画
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.flyAction()
            // 延迟4秒规划路线
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
                self.planningRoute()
            }
        }
    }
    
    @objc func planningRoute() {
        
        // 本地存储定位
        let localLat:Double = UserDefaults.standard.double(forKey: "TaLocationLat")
        let locallong:Double = UserDefaults.standard.double(forKey: "TaLocationLong")
        print("本地位置\(localLat),\(locallong)")
        
        if localLat == 0 || locallong == 0 {
            return
        }
        
        startCoordinate        = CLLocationCoordinate2DMake(mapView.userLocation.coordinate.latitude, mapView.userLocation.coordinate.longitude)
        destinationCoordinate  = CLLocationCoordinate2DMake(localLat, locallong)
        
//
        let distance =  MAMetersBetweenMapPoints(MAMapPointForCoordinate(startCoordinate), MAMapPointForCoordinate(destinationCoordinate))
        
        searchRoutePlanningWalk()
//        if distance > 500 {
//            print("连点距离\(distance)")
//            
//            searchRoutePlanningWalk()
//        }else {
////            mapView.removeOverlays(naviRoute?.routePolylines)
//        }
        
    }
}

extension ZBMapViewController {
    private func setupUI() {
        
        mapView = MAMapView()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        gpsButton = self.makeGPSButtonView()
        gpsButton.center = CGPoint.init(x: gpsButton.bounds.width / 2 + 10, y:self.view.bounds.size.height -  gpsButton.bounds.width / 2 - 20)
        self.view.addSubview(gpsButton)
        gpsButton.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin , UIView.AutoresizingMask.flexibleRightMargin]
    }
    
    
    func initSearch() {
        search = AMapSearchAPI()
        search.delegate = self
    }
    
    //添加ta的头像 annod
    func addDefaultAnnotations() {
        
        let annod = MAPointAnnotation()
        annod.coordinate = destinationCoordinate
        annod.title = "Ta"

        mapView.addAnnotation(annod)
    }
    
    // 定位按钮
    func makeGPSButtonView() -> UIButton! {
        let ret = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        ret.backgroundColor = UIColor.white
        ret.layer.cornerRadius = 4
        
        ret.setImage(UIImage.init(named: "gpsStat1"), for: .normal)
        ret.addTarget(self, action: #selector(self.gpsAction), for: .touchUpInside)
        
        return ret
    }
    
    // 定位事件
    @objc func gpsAction() {
        if(self.mapView.userLocation.isUpdating && self.mapView.userLocation.location != nil) {
            self.mapView.setCenter(self.mapView.userLocation.location.coordinate, animated: true)
        }
    }
    
    // 驾车
    func searchRoutePlanningDrive() {
        let request = AMapDrivingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        request.requireExtension = true
        
        search.aMapDrivingRouteSearch(request)
    }
    
    // 步行
    func searchRoutePlanningWalk() {
        let request = AMapWalkingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        search.aMapWalkingRouteSearch(request)
    }
    
    // 公交
    func searchRoutePlanningBus() {
        let request = AMapTransitRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        request.requireExtension = true
        request.city = "北京"
        search.aMapTransitRouteSearch(request)
    }
    
    //骑行
    func searchRoutePlanningRiding() {
        let request = AMapRidingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        search.aMapRidingRouteSearch(request)
    }
    
    /* 展示当前路线方案. */
    func presentCurrentCourse() {
        let start = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        let end = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        if currentSearchType == .bus || currentSearchType == .busCrossCity {
            naviRoute = MANaviRoute(for: route?.transits.first, start: start, end: end)
        } else {
            let type = MANaviAnnotationType(rawValue: currentSearchType.rawValue)
            
            naviRoute = MANaviRoute(for: route?.paths.first, withNaviType: type!, showTraffic: true, start: start, end: end)
        }
        
        naviRoute?.add(to: mapView)
        
        mapView.showOverlays((naviRoute?.routePolylines)!, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
    }
}

extension ZBMapViewController: MAMapViewDelegate {
    
    /**
     * @brief 位置或者设备方向更新后，会调用此函数
     * @param mapView 地图View
     * @param userLocation 用户定位信息(包括位置与设备方向等数据)
     * @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
     */
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        
        // 当前定位
        let currentlat: Double = userLocation.coordinate.latitude.roundTo(places: 4)
        let currentlong: Double = userLocation.coordinate.longitude.roundTo(places: 4)
        print("当前位置\(currentlat),\(currentlong)")
        
        // 本地存储定位
        let localLat:Double = UserDefaults.standard.double(forKey: "MeLocationLat")
        let locallong:Double = UserDefaults.standard.double(forKey: "MeLocationLong")
        print("本地位置\(localLat),\(locallong)")
        
        if localLat != currentlat || locallong != currentlong {
            UserDefaults.standard.set(currentlat, forKey: "MeLocationLat")
            UserDefaults.standard.set(currentlong, forKey: "MeLocationLong")
            UserDefaults.standard.synchronize()
            
            IMManger.shared().send(userLocation.location)
            
            print("位置变化\(currentlat),\(currentlong)")
//            searchRoutePlanningWalk()
        }
    }
    
    //MARK: - MAMapViewDelegate
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if overlay.isKind(of: LineDashPolyline.self) {
            let naviPolyline: LineDashPolyline = overlay as! LineDashPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 8.0
            renderer.strokeColor = UIColor.red
            renderer.lineDashType = kMALineDashTypeSquare
            
            return renderer
        }
        if overlay.isKind(of: MANaviPolyline.self) {
            
            let naviPolyline: MANaviPolyline = overlay as! MANaviPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 8.0
            
            if naviPolyline.type == MANaviAnnotationType.walking {
                renderer.strokeColor = naviRoute?.walkingColor
            }
            else if naviPolyline.type == MANaviAnnotationType.railway {
                renderer.strokeColor = naviRoute?.railwayColor;
            }
            else {
                renderer.strokeColor = naviRoute?.routeColor;
            }
 
            return renderer
        }
        if overlay.isKind(of: MAMultiPolyline.self) {
            let renderer: MAMultiColoredPolylineRenderer = MAMultiColoredPolylineRenderer(multiPolyline: overlay as! MAMultiPolyline?)
            renderer.lineWidth = 8.0
            renderer.strokeColors = naviRoute?.multiPolylineColors
            
            return renderer
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        // 我的定位图标
        if annotation is MAUserLocation {
            let pointReuseIndetifier = "userLocationStyleReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView!.image = UIImage.init(named: "headimgSabrina.JPG")?.reSizeImage(reSize: CGSize(width: 30, height: 30))
            
            return (annotationView!)
        }
        
        // ta的定位图标
        if annotation is MAPointAnnotation {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)

            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView!.canShowCallout = true
                annotationView!.isDraggable = false
            }

            if annotation.title == "Ta" {
                annotationView!.image = UIImage(named: "headimgJumbo.JPG")?.reSizeImage(reSize: CGSize(width: 30, height: 30))
            }

            return annotationView!
        }
        return nil
    }
}

//MARK: - AMapSearchDelegate
extension ZBMapViewController: AMapSearchDelegate {
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
//        NSLog("Error:\(String(describing: error)) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        addDefaultAnnotations()
        
        self.route = nil
        if response.count > 0 {
            
            self.route = response.route
            presentCurrentCourse()
        }
    }
}


// MARK: - CoreAnimation
extension ZBMapViewController:CAAnimationDelegate {
    
    func centerMapPointAnimation() -> CAKeyframeAnimation! {
        
        let fromMapPoint = MAMapPointForCoordinate(startCoordinate)
        let toMapPoint = MAMapPointForCoordinate(destinationCoordinate)
//        let fromMapPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(39.989870, 116.480940))
//        let toMapPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(31.232992, 121.476773))
        
        let RATIO = 100.0
        
        let mapSize = MAMapSizeMake((toMapPoint.x - fromMapPoint.x) / RATIO, (toMapPoint.y - fromMapPoint.y) / RATIO)
        
        let centerAnimation = CAKeyframeAnimation.init(keyPath: kMAMapLayerCenterMapPointKey)
        centerAnimation.delegate = self
        centerAnimation.duration = 10.0
        centerAnimation.values =
        [NSValue(maMapPoint: fromMapPoint) as Any,
         NSValue(maMapPoint: MAMapPointMake(fromMapPoint.x + mapSize.width, fromMapPoint.y + mapSize.height)) as Any,
         NSValue(maMapPoint: MAMapPointMake(toMapPoint.x - mapSize.width, toMapPoint.y - mapSize.height)) as Any,
         NSValue(maMapPoint: toMapPoint) as Any]
        
        centerAnimation.timingFunctions = [CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeIn),
                                           CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear),
                                           CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)]
        centerAnimation.keyTimes = [0.0, 0.4, 0.6, 1.0]
        
        return centerAnimation
    }
    
    /* 生成 地图缩放级别的 CAKeyframeAnimation. */
    func zoomLevelAnimation() -> CAKeyframeAnimation {
        let zoomLevelAnimation = CAKeyframeAnimation.init(keyPath: kMAMapLayerZoomLevelKey)
        
        zoomLevelAnimation.delegate = self
        zoomLevelAnimation.duration = 10.0
        zoomLevelAnimation.values = [18, 5, 5, 18]
        zoomLevelAnimation.keyTimes = [0.0, 0.4, 0.6, 1.0]
        zoomLevelAnimation.timingFunctions = [CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeIn),
                                              CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear),
                                              CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)]
        
        return zoomLevelAnimation
    }
    
    /* 生成 地图摄像机俯视角度的 CABasicAnimation. */
    func cameraDegreeAnimation() -> CAKeyframeAnimation {
        let cameraDegreeAnimation = CAKeyframeAnimation.init(keyPath: kMAMapLayerCameraDegreeKey)
        cameraDegreeAnimation.delegate = self
        cameraDegreeAnimation.duration = 10.0
        cameraDegreeAnimation.values = [0, 45]
        cameraDegreeAnimation.keyTimes = [0.0, 1.0]
        cameraDegreeAnimation.timingFunctions = [CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)]
        
        return cameraDegreeAnimation
    }
    
    /*生成 地图旋转角度的 CABasicAnimation. */
    func rotationDegreeKey() -> CAKeyframeAnimation {
        let rotationDegreeAnimation = CAKeyframeAnimation.init(keyPath: kMAMapLayerRotationDegreeKey)
        rotationDegreeAnimation.delegate = self
        rotationDegreeAnimation.duration = 10.0
        rotationDegreeAnimation.values = [0, 180]
        rotationDegreeAnimation.keyTimes = [0.0, 1.0]
        rotationDegreeAnimation.timingFunctions = [CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)]
        
        return rotationDegreeAnimation
    }
 
    //MARK:- event handling
    @objc func flyAction() {
        self.mapView .addAnimation(with: self.centerMapPointAnimation(), zoom: self.zoomLevelAnimation(), rotateAnimation: self.rotationDegreeKey(), cameraDegreeAnimation: self.cameraDegreeAnimation())
    }
}


extension  UIImage  {
     /**
      *  重设图片大小
      */
     func  reSizeImage(reSize: CGSize )-> UIImage  {
         //UIGraphicsBeginImageContext(reSize);
         UIGraphicsBeginImageContextWithOptions (reSize, false , UIScreen.main.scale)
         self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
         let  reSizeImage: UIImage  =  UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
         UIGraphicsEndImageContext()
         return  reSizeImage
     }
     
     /**
      *  等比率缩放
      */
     func  scaleImage(scaleSize: CGFloat )-> UIImage  {
         let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
         return  reSizeImage(reSize: reSize)
     }
}

extension Double {
    /// Rounds the double to decimal places value

    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))

        return (self * divisor).rounded() / divisor

    }

}
