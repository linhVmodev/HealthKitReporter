//
//  Extensions+HKCategoryValueMenstrualFlow.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import Foundation
import HealthKit

extension HKCategoryValueMenstrualFlow: CustomStringConvertible {
    public var description: String {
        "HKCategoryValueMenstrualFlow"
    }
    public var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .light:
            return "Light"
        case .medium:
            return "Medium"
        case .heavy:
            return "Heavy"
        case .none:
            return "None"
        @unknown default:
            return "Unknown"
        }
    }
}
