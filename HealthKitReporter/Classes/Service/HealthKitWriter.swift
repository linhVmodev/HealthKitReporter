//
//  HealthKitWriter.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import Foundation
import HealthKit

/// **HealthKitWriter** class for HK writing operations
public class HealthKitWriter {
    /**
     - Parameters:
        - success: the status
        - error: error (optional)
    */
    public typealias StatusCompletionBlock = (_ success: Bool, _ error: Error?) -> Void
    /**
     - Parameters:
        - success: the status
        - id: the deleted object id
        - error: error (optional)
    */
    public typealias DeletionCompletionBlock = (_ success: Bool, _ id: Int, _ error: Error?) -> Void

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Checks authorization for writing Objects in HK.
     - Parameter type: **HealthKitType** type to check
     - Throws: `HealthKitError.notAvailable` `HealthKitError.invalidType`
     - Returns: true if allowed to write and false if  not
     */
    public func isAuthorizedToWrite<T>(type: T) throws -> Bool where T: ObjectType {
        guard let objectType = type.original else {
            throw HealthKitError.invalidType("Invalid type: \(type)")
        }
        let status = healthStore.authorizationStatus(for: objectType)
        switch status {
        case .notDetermined, .sharingDenied:
            return false
        case .sharingAuthorized:
            return true
        @unknown default:
            throw HealthKitError.notAvailable("Invalid status")
        }
    }
    /**
     Adds category samples from device to a workout
     - Parameter samples: **Category** samples
     - Parameter from: **Device** device (optional)
     - Parameter workout: **Workout** workout
     - Parameter completion: block notifies about operation status
     */
    public func addCategory(
        _ samples: [Category],
        from: Device?,
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            let categorySamples = try samples.map { try $0.asOriginal() }
            healthStore.add(
                categorySamples,
                to: try workout.asOriginal(),
                completion: completion
            )
        } catch {
            completion(false, error)
        }
    }
    /**
     Adds quantitiy samples from device to a workout
     - Parameter samples: **Quantitiy** samples
     - Parameter from: **Device** device (optional)
     - Parameter workout: **Workout** workout
     - Parameter completion: block notifies about operation status
     */
    public func addQuantitiy(
        _ samples: [Quantity],
        from: Device?,
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            let quantitySamples = try samples.map { try $0.asOriginal() }
            healthStore.add(
                quantitySamples,
                to: try workout.asOriginal(),
                completion: completion
            )
        } catch {
            completion(false, error)
        }
    }
    /**
     Deletes the previosly created sample
     - Parameter sample: **Sample** sample
     - Parameter completion: block notifies about operation status
     */
    func delete(
        sample: Sample,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            if let quantity = sample as? Quantity {
                healthStore.delete(try quantity.asOriginal(), withCompletion: completion)
            }
            if let category = sample as? Category {
                healthStore.delete(try category.asOriginal(), withCompletion: completion)
            }
            if let workout = sample as? Workout {
                healthStore.delete(try workout.asOriginal(), withCompletion: completion)
            }
        } catch {
            completion(false, error)
        }
    }
    /**
     Deletes objects of type with predicate
     - Parameter objectType: **HealthKitType** type
     - Parameter predicate: **NSPredicate** predicate for deletion
     - Parameter completion: block notifies about deletion operation status
     */
    @available(iOS, introduced: 9.0, deprecated: 12.0, message: "No longer supported")
    public func deleteObjects<T>(
        of objectType: T,
        predicate: NSPredicate,
        completion: @escaping DeletionCompletionBlock
    ) where T: ObjectType {
        guard let type = objectType.original else {
            completion(
                false,
                -1,
                HealthKitError.invalidType("Object type was invalid: \(objectType)")
            )
            return
        }
        healthStore.deleteObjects(of: type, predicate: predicate, withCompletion: completion)
    }
    /**
     Saves the created sample
     - Parameter sample: **Sample** sample
     - Parameter completion: block notifies about operation status
     */
    public func save(
        sample: Sample,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            if let quantity = sample as? Quantity {
                healthStore.save(try quantity.asOriginal(), withCompletion: completion)
            }
            if let category = sample as? Category {
                healthStore.save(try category.asOriginal(), withCompletion: completion)
            }
            if let workout = sample as? Workout {
                healthStore.save(try workout.asOriginal(), withCompletion: completion)
            }
        } catch {
            completion(false, error)
        }
    }
}
