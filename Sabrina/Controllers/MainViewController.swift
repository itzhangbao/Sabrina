//
//  MainViewController.swift
//  Sabrina
//
//  Created by Jumbo on 2021/2/7.
//

import UIKit
import LTMorphingLabel

var _mainVC: MainViewController!

class MainViewController: BaseViewController {
    
    weak var _315VC: UIViewController!
    weak var chatVC: UIViewController!
    weak var mapVC: UIViewController!
    
    lazy var _leftButton: UIButton = {
        let button: UIButton = UIButton()
        button.backgroundColor = .red
        return button
    }()
    lazy var _rightButton: UIButton = {
        let button: UIButton = UIButton()
        button.backgroundColor = .red
        return button
    }()
    
    lazy var _navTitle: LTMorphingLabel = {
        let label: LTMorphingLabel = LTMorphingLabel()
        label.textColor = UIColor.init(hex: "01579b")
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.morphingEffect = .pixelate
        label.text = "DaysLove"
        return label
    }()
    
    lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _mainVC = self;
        
        addChilds()
        
        setupUI()
        
        mainScrollView.setContentOffset(CGPoint(x: view.bounds.size.width, y: 0), animated: false)
    }
}

extension MainViewController {
    
    private func addChilds() {
        mapVC = _addChild(ZBMapViewController())
        
        _315VC = _addChild(_315DAYViewController())
        
//        chatVC = _addChild(BaseNavigationController(rootViewController: ChatViewController()))
        chatVC = _addChild(ChatViewController())
    }
    
    private func _addChild(_ vc: UIViewController) -> UIViewController {
        vc.willMove(toParent: self)
        addChild(vc)
        vc.didMove(toParent: self)
        return vc
    }
    
    private func setupUI() {
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        mainScrollView.addSubview(_315VC.view)
        _315VC.view.snp.makeConstraints({
            $0.top.left.equalToSuperview()
            $0.size.equalTo(view.bounds.size)
        })
        
        mainScrollView.addSubview( mapVC.view)
        mapVC.view.snp.makeConstraints({
            $0.left.equalTo(_315VC.view.snp.right)
            $0.size.equalTo(view.bounds.size)
        })
        
        mainScrollView.addSubview(chatVC.view)
        chatVC.view.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.left.equalTo(mapVC.view.snp.right)
            $0.size.equalTo(view.bounds.size)
            $0.right.equalToSuperview()
        })
        
        view.addSubview(_navTitle)
        _navTitle.snp.makeConstraints({
            $0.top.equalTo(UIDevice.phoneAreaTop())
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
        })
        
        
        // left right button
        view.addSubview(_leftButton)
        _leftButton.snp.makeConstraints({
            $0.left.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 50, height: 50))
        })
        view.addSubview(_rightButton)
        _rightButton.snp.makeConstraints({
            $0.right.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(_leftButton)
        })
        
        view.layoutIfNeeded()
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
//        print("----------%@",offset/UIDevice.screenWidth())
        let page = offset/UIDevice.screenWidth()
        if page < 0.5 {
            _navTitle.text = "DaysLove"
        }else if page < 1.5 {
            _navTitle.text = "Map"
        }else {
            _navTitle.text = "Chat"
        }
    }
}
