//
//  BaseViewController.swift
//  SpeedierSloth
//
//  Created by Adam on 5/16/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
	
	let appDelegate : AppDelegate? = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
		if let nav = self.navigationController {
			nav.navigationBar.barTintColor = UIColor.black
			nav.navigationBar.backgroundColor = UIColor.black
			nav.navigationBar.isTranslucent = false
			nav.navigationBar.prefersLargeTitles = true
			nav.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		PhoneWCSessionManager.shared.checkForWorkoutInProgress()
	}

}
