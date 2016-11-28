//
//  ViewController.swift
//  ParalloxEffectSample
//
//  Created by Muthuraj on 22/11/16.
//  Copyright © 2016 Muthuraj. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ParalloxViewDelegate {
    @IBOutlet weak var paralloxView: ParalloxView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        paralloxView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func paralloxEffectStarted(paralloxView: ParalloxView, direction: ParalloxDirection) {
        
    }
    
    func paralloxEffectProgress(paralloxView: ParalloxView, progress: CGFloat, direction: ParalloxDirection) {
        print("percentage : \(progress*100)")
    }
    
    func paralloxEffectEnded(paralloxView: ParalloxView, direction: ParalloxDirection) {
        
    }

}

