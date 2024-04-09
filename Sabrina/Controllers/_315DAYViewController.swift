//
//  ViewController.swift
//  Sabrina
//
//  Created by Jumbo on 2021/2/5.
//

import UIKit
import Lottie
import SnapKit
import LTMorphingLabel

fileprivate let _315DAY = "2019-3-15 00:00:00"

class _315DAYViewController: BaseViewController {
    
    var _timer: Timer!
    
    lazy var _animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.backgroundColor = .black
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.contentMode = .scaleAspectFit
        animationView.animation = Animation.named("good-night", subdirectory: "Lotties")
        animationView.loopMode = .loop
        return animationView
    }()
    
    lazy var _315Label: LTMorphingLabel = {
        let label: LTMorphingLabel = LTMorphingLabel()
        label.textColor = UIColor.init(hex: "01579b")
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.morphingEffect = .sparkle
        label.text = _315DaysOfLove()
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _setupUI()
        
//        _timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[unowned self] (ktimer) in
//            _315Label.text = _315DaysOfLove()
//        }
//        RunLoop.current.add(_timer, forMode: .common)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        _animationView.play()
//        _timer.fireDate = NSDate.distantPast
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        _animationView.stop()
//        _timer.fireDate = NSDate.distantFuture
    }
}

extension _315DAYViewController {
    
    private func _setupUI() {
        
        view.addSubview(_animationView)
        _animationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(_315Label)
        _315Label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func _315DaysOfLove() -> String {
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let _315Date: Date = dateFormater.date(from: _315DAY)!
        
        let comps: DateComponents = Calendar.current.dateComponents([Calendar.Component.day,Calendar.Component.hour,Calendar.Component.minute,Calendar.Component.second], from: _315Date, to: Date())
        
        let days = String.init(format: "%02ld", comps.day!)
        let hours = String.init(format: "%02ld", comps.hour!)
        let mins = String.init(format: "%02ld", comps.minute!)
        let second = String.init(format: "%02ld", comps.second!)
        
        return "\(days)天\(hours)时\(mins)分\(second)秒"
    }
}
