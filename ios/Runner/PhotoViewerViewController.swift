//
//  PhotoViewerViewController.swift
//  Blink
//
//  Created by Murat BAKIRTAS on 6.08.2020.
//  Copyright © 2020 Murat BAKIRTAS. All rights reserved.
//

import UIKit

class PhotoViewerViewController: UIViewController {
    
    private let url = URL(string: "https://docs.flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(scrollView)
        view.backgroundColor = UIColor.blue;
        //scrollView.addSubview(imageView)
        //view.backgroundColor = .black
        imageView.image = UIImage(named: "");
        view.addSubview(navigationBarExitButton)
        viewdidlayout()
        
        scrollView.contentSize = self.imageView.frame.size
        
        scrollView.delegate = self
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
    }
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            })
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                navigationController?.popViewController(animated: true)

                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private let navigationBarExitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "person"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.addTarget(PhotoViewerViewController.self, action: #selector(exitConversation(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        imageView.frame = scrollView.bounds
        
    }
    
    func viewdidlayout(){
        navigationBarExitButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        navigationBarExitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        navigationBarExitButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        navigationBarExitButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    @objc func exitConversation(_ sender: UIButton!){
        
        
        //        burada hem dismiss hem geri git kullandim ayni buton icin cunku dismiss chatten dm kutusuna donerken, popview(geri don) chatten profile donerken icin
        //        yani bu fonk profilden chate gidenler icin dismiss
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoViewerViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1{
            if let image = imageView.image{
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth*scrollView.zoomScale > imageView.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - imageView.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight*scrollView.zoomScale > imageView.frame.height
                
                let top = 0.5 * (conditioTop ? newHeight - imageView.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
}

