//
//  ContentView.swift
//  BetterRest
//
//  Created by bharat venna on 28/09/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeupTime
    @State private var sleepAmount = 8.0
    @State private var coffeeConsumed = 1
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    static var defaultWakeupTime: Date {
        var components = DateComponents()
        components.hour = 4
        components.minute = 0
        let date = Calendar.current.date(from: components)
        return date ?? Date.now
    }
    
    func actualSleep() {
        do{
            
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60 * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeConsumed+1))
            
            let bedTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your estimated bed time is"
            alertMessage = bedTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Data error"
        }
        
        showingAlert.toggle()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When do you want to wakeup?")
                        DatePicker("select time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("How long do you want to sleep?")
                        Stepper("Required sleep in hours: \(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Cups of coffee consumed")
                        //                    Stepper("Coffee cups: \(coffeeConsumed)", value: $coffeeConsumed, in: 1...20)
                        Picker("Coffee consumed", selection: $coffeeConsumed){
                            ForEach(1..<21){
                                Text("\($0)")
                            }
                        }
                    }
                }
                Section {
                    Text("Your bed time is \n \(alertMessage)")
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .font(.title2)
                .foregroundStyle(.primary)
                .background(.indigo)
                .cornerRadius(15)
                
            }
            .navigationTitle("Better Rest")
            .toolbar{
                Button("Calculate") {
                    actualSleep()
                }
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("ok"){}
            }message: {
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
