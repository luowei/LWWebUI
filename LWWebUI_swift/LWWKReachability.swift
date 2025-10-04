//
// LWWKReachability.swift
// LWWebUI
//
// Swift version of network reachability
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation
import SystemConfiguration

// MARK: - Network Status

public enum LWWKNetworkStatus: Int {
    case notReachable = 0
    case reachableViaWiFi = 2
    case reachableViaWWAN = 1
}

// MARK: - Notifications

public extension Notification.Name {
    static let lwwkReachabilityChanged = Notification.Name("kLWWKReachabilityChangedNotification")
}

// MARK: - Reachability Class

public class LWWKReachability {

    // MARK: - Type Aliases

    public typealias NetworkReachable = (LWWKReachability) -> Void
    public typealias NetworkUnreachable = (LWWKReachability) -> Void
    public typealias NetworkReachability = (LWWKReachability, SCNetworkReachabilityFlags) -> Void

    // MARK: - Properties

    public var reachableBlock: NetworkReachable?
    public var unreachableBlock: NetworkUnreachable?
    public var reachabilityBlock: NetworkReachability?

    public var reachableOnWWAN: Bool = true

    private var reachabilityRef: SCNetworkReachabilityRef?
    private var reachabilitySerialQueue: DispatchQueue
    private var reachabilityObject: AnyObject?

    // MARK: - Initialization

    private init(reachabilityRef: SCNetworkReachabilityRef) {
        self.reachabilityRef = reachabilityRef
        self.reachabilitySerialQueue = DispatchQueue(label: "com.wodedata.libLWWebUI.reachability")
    }

    deinit {
        stopNotifier()
        if let ref = reachabilityRef {
            CFRelease(ref)
            reachabilityRef = nil
        }
    }

    // MARK: - Factory Methods

    public static func reachability(withHostname hostname: String) -> LWWKReachability? {
        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else {
            return nil
        }
        return LWWKReachability(reachabilityRef: ref)
    }

    public static func reachabilityForInternetConnection() -> LWWKReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        return withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                guard let ref = SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress) else {
                    return nil
                }
                return LWWKReachability(reachabilityRef: ref)
            }
        }
    }

    public static func reachabilityForLocalWiFi() -> LWWKReachability? {
        var localWifiAddress = sockaddr_in()
        localWifiAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        localWifiAddress.sin_family = sa_family_t(AF_INET)
        localWifiAddress.sin_addr.s_addr = UInt32(0xA9FE0000).bigEndian // 169.254.0.0

        return withUnsafePointer(to: &localWifiAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { localWifiSockAddress in
                guard let ref = SCNetworkReachabilityCreateWithAddress(nil, localWifiSockAddress) else {
                    return nil
                }
                return LWWKReachability(reachabilityRef: ref)
            }
        }
    }

    // MARK: - Notifier Methods

    @discardableResult
    public func startNotifier() -> Bool {
        guard reachabilityObject == nil else {
            return true
        }

        guard let ref = reachabilityRef else {
            return false
        }

        var context = SCNetworkReachabilityContext(
            version: 0,
            info: Unmanaged.passRetained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        guard SCNetworkReachabilitySetCallback(ref, { (_, flags, info) in
            guard let info = info else { return }
            let reachability = Unmanaged<LWWKReachability>.fromOpaque(info).takeUnretainedValue()
            reachability.reachabilityChanged(flags: flags)
        }, &context) else {
            return false
        }

        guard SCNetworkReachabilitySetDispatchQueue(ref, reachabilitySerialQueue) else {
            SCNetworkReachabilitySetCallback(ref, nil, nil)
            return false
        }

        reachabilityObject = self
        return true
    }

    public func stopNotifier() {
        guard let ref = reachabilityRef else { return }

        SCNetworkReachabilitySetCallback(ref, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(ref, nil)

        reachabilityObject = nil
    }

    // MARK: - Reachability Tests

    private func isReachable(withFlags flags: SCNetworkReachabilityFlags) -> Bool {
        guard flags.contains(.reachable) else {
            return false
        }

        if flags.contains(.connectionRequired) && flags.contains(.transientConnection) {
            return false
        }

        #if os(iOS)
        if flags.contains(.isWWAN) && !reachableOnWWAN {
            return false
        }
        #endif

        return true
    }

    public var isReachable: Bool {
        guard let ref = reachabilityRef else { return false }

        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(ref, &flags) else {
            return false
        }

        return isReachable(withFlags: flags)
    }

    public var isReachableViaWWAN: Bool {
        #if os(iOS)
        guard let ref = reachabilityRef else { return false }

        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(ref, &flags) else {
            return false
        }

        return flags.contains(.reachable) && flags.contains(.isWWAN)
        #else
        return false
        #endif
    }

    public var isReachableViaWiFi: Bool {
        guard let ref = reachabilityRef else { return false }

        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(ref, &flags) else {
            return false
        }

        guard flags.contains(.reachable) else {
            return false
        }

        #if os(iOS)
        return !flags.contains(.isWWAN)
        #else
        return true
        #endif
    }

    public var isConnectionRequired: Bool {
        return connectionRequired
    }

    public var connectionRequired: Bool {
        guard let ref = reachabilityRef else { return false }

        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(ref, &flags) else {
            return false
        }

        return flags.contains(.connectionRequired)
    }

    public var isConnectionOnDemand: Bool {
        guard let ref = reachabilityRef else { return false }

        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(ref, &flags) else {
            return false
        }

        return flags.contains(.connectionRequired) &&
               (flags.contains(.connectionOnTraffic) || flags.contains(.connectionOnDemand))
    }

    public var isInterventionRequired: Bool {
        guard let ref = reachabilityRef else { return false }

        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(ref, &flags) else {
            return false
        }

        return flags.contains(.connectionRequired) && flags.contains(.interventionRequired)
    }

    // MARK: - Reachability Status

    public var currentReachabilityStatus: LWWKNetworkStatus {
        if isReachable {
            if isReachableViaWiFi {
                return .reachableViaWiFi
            }
            #if os(iOS)
            return .reachableViaWWAN
            #endif
        }
        return .notReachable
    }

    public var reachabilityFlags: SCNetworkReachabilityFlags {
        guard let ref = reachabilityRef else { return [] }

        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(ref, &flags) else {
            return []
        }

        return flags
    }

    public var currentReachabilityString: String {
        let status = currentReachabilityStatus

        switch status {
        case .reachableViaWWAN:
            return NSLocalizedString("Cellular", comment: "")
        case .reachableViaWiFi:
            return NSLocalizedString("WiFi", comment: "")
        case .notReachable:
            return NSLocalizedString("No Connection", comment: "")
        }
    }

    public var currentReachabilityFlagsString: String {
        let flags = reachabilityFlags

        #if os(iOS)
        let w = flags.contains(.isWWAN) ? "W" : "-"
        #else
        let w = "X"
        #endif

        let r = flags.contains(.reachable) ? "R" : "-"
        let c = flags.contains(.connectionRequired) ? "c" : "-"
        let t = flags.contains(.transientConnection) ? "t" : "-"
        let i = flags.contains(.interventionRequired) ? "i" : "-"
        let C = flags.contains(.connectionOnTraffic) ? "C" : "-"
        let D = flags.contains(.connectionOnDemand) ? "D" : "-"
        let l = flags.contains(.isLocalAddress) ? "l" : "-"
        let d = flags.contains(.isDirect) ? "d" : "-"

        return "\(w)\(r) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }

    // MARK: - Callback

    private func reachabilityChanged(flags: SCNetworkReachabilityFlags) {
        if isReachable(withFlags: flags) {
            reachableBlock?(self)
        } else {
            unreachableBlock?(self)
        }

        reachabilityBlock?(self, flags)

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .lwwkReachabilityChanged,
                object: self
            )
        }
    }
}

// MARK: - CustomStringConvertible

extension LWWKReachability: CustomStringConvertible {
    public var description: String {
        return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque()) (\(currentReachabilityFlagsString))>"
    }
}
