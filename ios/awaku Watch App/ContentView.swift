//
//  ContentView.swift
//  awaku Watch App
//
//  Created by fiaz on 03/08/23.
//

import SwiftUI
import WatchConnectivity
import HealthKit

struct ContentView: View {
//    @ObservedObject var session = WatchSessionDelegate()
    private let session = WCSession.default
    @State var count = 0
    
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
        
    @State private var value = 0

    var body: some View {
        VStack{
               HStack{
                   Text("❤️")
                       .font(.system(size: 50))
                   Spacer()
                  
               }
               HStack{
                   Text("\(value)")
                       .fontWeight(.regular)
                       .font(.system(size: 70))
                   
                   Text("BPM")
                       .font(.headline)
                       .fontWeight(.bold)
                       .foregroundColor(Color.red)
                       .padding(.bottom, 28.0)
                   
                   Spacer()
                   
               }

           }
           .padding()
           .onAppear(perform: start)
//        ScrollView {
//            Text("Reachable: \(session.reachable.description)")
//            Text("Context: \(session.context.description)")
//            Text("Received context: \(session.receivedContext.description)")
//            Button("Refresh") { session.refresh() }
//            Spacer().frame(height: 8)
//            Text("Send")
//            HStack {
//                Button("Message") { session.sendMessage(["data": "Hello"]) }
//                Button("Context") {
//                    count += 1
//                    session.updateApplicationContext(["data": count])
//                }
//            }
//            Spacer().frame(height: 8)
//            Text("Log")
//            ForEach(session.log.reversed(), id: \.self) {
//                Text($0)
//            }
//        }
    }
    func start() {
        autorizeHealthKit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }
    
    func autorizeHealthKit() {
        let healthKitTypes: Set = [
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]

        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
        // 1
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        // 2
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
            // 3
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
            
        self.process(samples, type: quantityTypeIdentifier)

        }
        
        // 4
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        
        // 5
        
        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            self.value = Int(lastHeartRate)
        }
        try? session.updateApplicationContext(["heart_rate": lastHeartRate])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
