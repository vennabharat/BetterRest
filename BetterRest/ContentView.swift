//
//  ContentView.swift
//  BetterRest
//
//  Created by bharat venna on 28/09/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = Date.now
    @State private var desiredSleep = 8.0
    @State private var coffeeIntake = 1
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    func sleepAmount() {
        
        do {
            
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: desiredSleep, coffee: Double(coffeeIntake))
            
            let bedTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your estimated bed time is:"
            alertMessage = bedTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            
            alertTitle = "data not found"
            alertMessage = "Error"
            
        }
        
        showingAlert = true
    }
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                Text("When do you want to wakeup?")
                DatePicker("Select time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desire amount of sleep")
                Stepper("\(desiredSleep) hours", value: $desiredSleep, in: 4...16, step: 0.25)
                
                Text("Coffee intake")
                Stepper("\(coffeeIntake) cup", value: $coffeeIntake, in: 1...20)
            }
            .navigationTitle("Better Rest")
            .toolbar{
                Button("Calculate", action: sleepAmount)
            }
            .alert("\(alertTitle)", isPresented: $showingAlert){
                Button("ok"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
