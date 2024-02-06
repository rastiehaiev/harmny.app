//
//  ActivityView.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 04.01.2024.
//

import SwiftUI

struct ActivityView: View {
    @ObservedObject private var activityViewModel: ActivityViewModel
    @ObservedObject private var activitiesViewModel: ActivitiesViewModel
    
    @State private var isTimerRunning: Bool = false
    @State private var stopwatchValue: String = ""
    @State private var buttonsDisabled: Bool = false
    @State private var timerValue: TimerValue = TimerValue.from(0)
    
    @State private var selectedNumber: Int = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(_ activityViewModel: ActivityViewModel, _ activitiesViewModel: ActivitiesViewModel) {
        self.activityViewModel = activityViewModel
        self.activitiesViewModel = activitiesViewModel
    }
    
    var body: some View {
        VStack {
            switch activityViewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5, anchor: .center)
            case .unauthenticated:
                // this will trigger whole view reload
                Text("Unauthenticated")
            case .failedToLoad:
                // this will trigger whole view reload
                Text("Failed to load activity")
            case .loaded(let model):
                VStack {
                    VStack {
                        Spacer()
                        Text(stopwatchValue)
                            .animation(.easeInOut(duration: 0.2), value: getTimerTextSize(model)    )
                            .font(Font.custom("Menlo-Regular", size: getTimerTextSize(model)))
                            .onReceive(timer) { _ in
                                if self.isTimerRunning {
                                    self.stopwatchValue = self.timerValue.incrementAndGet()
                                }
                            }
                        if (model.status == .paused) {
                            NumberPickerView(selectedNumber: $selectedNumber)
                        } else if (selectedNumber > 0) {
                            Text("Count: \(selectedNumber)")
                                .font(Font.custom("Menlo-Regular", size: 16))
                        }
                        Spacer()
                    }
                    HStack {
                        if (model.status == .unstarted) {
                            Spacer()
                        } else {
                            CircleButtonView(color: .red, imageName: "trash.circle.fill", delete).disabled(buttonsDisabled)
                            Spacer()
                        }
                        if (model.status == .paused) {
                            CircleButtonView(color: .blue, imageName: "checkmark.circle.fill", complete).disabled(buttonsDisabled)
                            Spacer()
                        }
                        if (model.status == .started) {
                            CircleButtonView(color: .orange, imageName: "pause.circle.fill", pause).disabled(buttonsDisabled)
                        } else {
                            CircleButtonView(color: .green, imageName: "play.circle.fill", play).disabled(buttonsDisabled)
                        }
                    }
                }
            }
        }.onReceive(activityViewModel.$state, perform: { state in
            self.buttonsDisabled = false
            switch state {
            case .unauthenticated:
                fallthrough
            case .failedToLoad:
                activitiesViewModel.initialise()
            case .loaded(let info):
                enableButtons()
                updateTimer(info)
            default:
                break
            }
        })
    }
    
    private func enableButtons() {
        self.buttonsDisabled = false
    }
    
    private func disableButtons() {
        self.buttonsDisabled = true
    }
    
    private func play() {
        disableButtons()
        activityViewModel.startOrResume(getCount())
    }
    
    private func pause() {
        disableButtons()
        activityViewModel.pause()
    }
    
    private func delete() {
        disableButtons()
        activityViewModel.delete()
    }
    
    private func complete() {
        disableButtons()
        activityViewModel.complete(getCount())
    }
    
    private func getCount() -> Int? {
        return if selectedNumber > 0 { selectedNumber } else { nil }
    }
    
    private func updateTimer(_ stopwatchInfo: ActivityStopwatchInfo) {
        let timerValue = TimerValue.from(stopwatchInfo.elapsedTimeSec)
        self.timerValue = timerValue
        self.stopwatchValue = timerValue.stringValue
        self.isTimerRunning = stopwatchInfo.status == .started
        self.selectedNumber = stopwatchInfo.count ?? 0
    }
    
    private func getTimerTextSize(_ model: ActivityStopwatchInfo) -> CGFloat {
        return if model.status == .paused { 28 } else { 36 }
    }
}
