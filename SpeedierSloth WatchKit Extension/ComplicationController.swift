//
//  ComplicationController.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/15/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
		if complication.family == .modularSmall {
			let template = CLKComplicationTemplateModularSmallSimpleImage()
			template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!)
			let entry : CLKComplicationTimelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
			handler(entry)
		}
		else {
			handler(nil)
		}
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
		if complication.family == .modularSmall {
			let template = CLKComplicationTemplateModularSmallSimpleImage()
			template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!)
			handler(template)
		}
		else {
			handler(nil)
		}
    }
    
}
