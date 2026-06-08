import Foundation
import CallKit
import Combine

class CallDetectionService: NSObject, ObservableObject {
    @Published var isOnCall = false
    @Published var currentCallInfo: CallInfo?

    private let callObserver = CXCallObserver()
    private var onCallStarted: ((CallInfo) -> Void)?
    private var onCallEnded: ((CallInfo) -> Void)?

    override init() {
        super.init()
        callObserver.setDelegate(self, queue: nil)
    }

    func setCallbacks(onStarted: @escaping (CallInfo) -> Void, onEnded: @escaping (CallInfo) -> Void) {
        self.onCallStarted = onStarted
        self.onCallEnded = onEnded
    }
}

extension CallDetectionService: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        DispatchQueue.main.async {
            if call.hasConnected && !self.isOnCall {
                self.isOnCall = true
                let callType: CallInfo.CallType = call.isOutgoing ? .outgoing : .incoming
                let info = CallInfo(
                    callId: UUID(),
                    phoneNumber: nil,
                    contactName: nil,
                    callType: callType,
                    startDate: Date(),
                    endDate: nil
                )
                self.currentCallInfo = info
                self.onCallStarted?(info)
            } else if !call.hasConnected && self.isOnCall {
                self.isOnCall = false
                if var info = self.currentCallInfo {
                    info = CallInfo(
                        callId: info.callId,
                        phoneNumber: info.phoneNumber,
                        contactName: info.contactName,
                        callType: info.callType,
                        startDate: info.startDate,
                        endDate: Date()
                    )
                    self.currentCallInfo = info
                    self.onCallEnded?(info)
                }
                self.currentCallInfo = nil
            }
        }
    }
}
