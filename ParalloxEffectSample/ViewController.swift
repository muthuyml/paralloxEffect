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
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var tableview: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        paralloxView.delegate = self
	    tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.automaticallyAdjustsScrollViewInsets = false
		self.view.addGestureRecognizer(tableview.panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    func paralloxEffectProgress(paralloxView: ParalloxView, progress: CGFloat) {
		//imageView.alpha = (1-progress)
    }
}

extension ViewController:UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 30
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = "test \(indexPath.row)"
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
}

extension ViewController:UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		paralloxView?.scrolled(scrollView: scrollView)
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		paralloxView?.scrollDidStopped(at: scrollView.contentOffset)
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			paralloxView?.scrollDidStopped(at: scrollView.contentOffset)
		}
	}
}


