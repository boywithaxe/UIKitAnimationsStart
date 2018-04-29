//
//  ViewController.swift
//  UIKitAnimations
//
//  Created by Brian Advent on 02.09.17.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import UIKit

enum AnimationState {
    case fullscreen
    case thumbnail
}

class ViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var darkView: UIView!
    
    var animator:UIViewPropertyAnimator?
    var currentState:AnimationState!
    var thumbnailFrame:CGRect!
    var panGestureRecognizer:UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan(recognizer:)))
        
        photoView.addGestureRecognizer(panGestureRecognizer)
        thumbnailFrame = photoView.frame
        currentState = .thumbnail
        
        
    }
    
    
    @objc func handlePan (recognizer:UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view.superview)
        switch recognizer.state {
        case .began:
            startPanning()
        case .changed:
            scrub(translation: translation)
        case .ended:
            let velocity = recognizer.velocity(in: self.view.superview)
            endAnimation(translation: translation, velocity: velocity)
        default:
            print("Something went wrong")
        }
    }
    
    func startPanning() {
    
        var finalFrame: CGRect = CGRect()
        switch currentState {
        case .fullscreen:
            finalFrame = thumbnailFrame
        case .thumbnail:
            finalFrame = self.view.frame
        default:
            print("Unknown state")
        }
        
        animator = UIViewPropertyAnimator(duration: 1, dampingRatio: 0.8, animations: {
            self.photoView.frame = finalFrame
        })
    }
    
    func scrub(translation: CGPoint) {
        if let animator = self.animator {
            let yTranslation = self.view.center.y + translation.y
            
            var progress: CGFloat = 0
            
            switch currentState {
            case .thumbnail:
                progress = 1 - (yTranslation / self.view.center.y)
            case .fullscreen:
                progress = (yTranslation / self.view.center.y) - 1
            default:
                print("Unknown state")
            }
            
            progress = max(0.0001, min(0.9999, progress))
            
            animator.fractionComplete = progress
            
        }
    }

    func endAnimation(translation: CGPoint, velocity: CGPoint) {
        
        if let animator = self.animator {
            
            let screenHeight = self.view.frame.size.height
            switch currentState {
            case .thumbnail:
                if translation.y <= -screenHeight / 3 || velocity.y <= -100 {
                    animator.isReversed = false
                    animator.addCompletion ({ (position: UIViewAnimatingPosition) in
                        self.currentState = .fullscreen
                        self.panGestureRecognizer.isEnabled = true
                    })
                } else {
                    animator.isReversed = true
                    animator.addCompletion ({ (position: UIViewAnimatingPosition) in
                        self.currentState = .thumbnail
                        self.panGestureRecognizer.isEnabled = true
                    })
                }
            case .fullscreen:
                if translation.y <= screenHeight / 3 || velocity.y <= 100 {
                    animator.isReversed = false
                    animator.addCompletion ({ (position: UIViewAnimatingPosition) in
                        self.currentState = .thumbnail
                        self.panGestureRecognizer.isEnabled = true
                    })
                } else {
                    animator.isReversed = true
                    animator.addCompletion ({ (position: UIViewAnimatingPosition) in
                        self.currentState = .fullscreen
                        self.panGestureRecognizer.isEnabled = true
                    })
                }
            default:
                print("Unknown state")
            }
            
            let vector = CGVector(dx: velocity.x / 100, dy: velocity.y / 100)
            let springParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: vector)
            
            animator.continueAnimation(withTimingParameters: springParameters, durationFactor: 1)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

