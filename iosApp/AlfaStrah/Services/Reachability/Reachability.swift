/*
 Copyright (c) 2014, Ashley Mills
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Source: https://github.com/ashleymills/Reachability.swift
 */

import SystemConfiguration
import Foundation

public enum ReachabilityError: Error {
    case failedToCreateWithAddress(sockaddr_in)
    case failedToCreateWithHostname(String)
    case unableToSetCallback
    case unableToSetDispatchQueue
}

@available(*, unavailable, renamed: "Notification.Name.reachabilityChanged")
public let reachabilityChangedNotification = NSNotification.Name("ReachabilityChangedNotification")

extension Notification.Name {
    public static let reachabilityChanged = Notification.Name("reachabilityChanged")
}

func callback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    guard let info = info else { return }

    let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
    reachability.reachabilityChanged()
}

public class Reachability {
    public typealias NetworkReachable = (Reachability) -> Void
    public typealias NetworkUnreachable = (Reachability) -> Void

    @available(*, unavailable, renamed: "Conection")
    public enum NetworkStatus: CustomStringConvertible {
        case notReachable, reachableViaWiFi, reachableViaWWAN
        public var description: String {
            switch self {
                case .reachableViaWWAN: return "Cellular"
                case .reachableViaWiFi: return "WiFi"
                case .notReachable: return "No Connection"
            }
        }
    }

    public enum Connection: CustomStringConvertible {
        case none, wifi, cellular
        public var description: String {
            switch self {
                case .cellular: return "Cellular"
                case .wifi: return "WiFi"
                case .none: return "No Connection"
            }
        }
    }

    public var whenReachable: NetworkReachable?
    public var whenUnreachable: NetworkUnreachable?

    /// Set to `false` to force Reachability.connection to .none when on cellular connection (default value `true`)
    public var allowsCellularConnection: Bool

    // The notification center on which "reachability changed" events are being posted
    public var notificationCenter: NotificationCenter = NotificationCenter.default

    @available(*, unavailable, renamed: "connection")
    public var currentReachabilityStatus: Connection {
        connection
    }

    public var connection: Connection {

        guard isReachableFlagSet else { return .none }

        // If we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        guard isRunningOnDevice else { return .wifi }

        var connection = Connection.none

        if !isConnectionRequiredFlagSet {
            connection = .wifi
        }

        if isConnectionOnTrafficOrDemandFlagSet {
            if !isInterventionRequiredFlagSet {
                connection = .wifi
            }
        }

        if isOnWWANFlagSet {
            if !allowsCellularConnection {
                connection = .none
            } else {
                connection = .cellular
            }
        }

        return connection
    }

    private var previousFlags: SCNetworkReachabilityFlags?

    private var isRunningOnDevice: Bool = {
        #if targetEnvironment(simulator)
            return false
        #else
            return true
        #endif
    }()

    private var notifierRunning = false
    private let reachabilityRef: SCNetworkReachability

    private let reachabilitySerialQueue = DispatchQueue(label: "uk.co.ashleymills.reachability")

    required public init(reachabilityRef: SCNetworkReachability) {
        allowsCellularConnection = true
        self.reachabilityRef = reachabilityRef
    }

    public convenience init?(hostname: String) {

        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else { return nil }

        self.init(reachabilityRef: ref)
    }

    public convenience init?() {

        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)

        guard let ref = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else { return nil }

        self.init(reachabilityRef: ref)
    }

    deinit {
        stopNotifier()
    }

    // MARK: - *** Notifier methods ***
    func startNotifier() throws {
        guard !notifierRunning else { return }

        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
        if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            stopNotifier()
            throw ReachabilityError.unableToSetCallback
        }

        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
            stopNotifier()
            throw ReachabilityError.unableToSetDispatchQueue
        }

        // Perform an initial check
        reachabilitySerialQueue.async {
            self.reachabilityChanged()
        }

        notifierRunning = true
    }

    func stopNotifier() {
        defer { notifierRunning = false }

        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
    }

    var description: String {

        let WWW = isRunningOnDevice ? (isOnWWANFlagSet ? "W" : "-") : "X"
        let RRR = isReachableFlagSet ? "R" : "-"
        let ccc = isConnectionRequiredFlagSet ? "c" : "-"
        let ttt = isTransientConnectionFlagSet ? "t" : "-"
        let iii = isInterventionRequiredFlagSet ? "i" : "-"
        let CCC = isConnectionOnTrafficFlagSet ? "C" : "-"
        let DDD = isConnectionOnDemandFlagSet ? "D" : "-"
        let lll = isLocalAddressFlagSet ? "l" : "-"
        let ddd = isDirectFlagSet ? "d" : "-"

        return "\(WWW)\(RRR) \(ccc)\(ttt)\(iii)\(CCC)\(DDD)\(lll)\(ddd)"
    }

    func reachabilityChanged() {
        guard previousFlags != flags else { return }

        let block = connection != .none ? whenReachable : whenUnreachable

        DispatchQueue.main.async {
            block?(self)
            self.notificationCenter.post(name: .reachabilityChanged, object: self)
        }

        previousFlags = flags
    }

    private var isOnWWANFlagSet: Bool {
        #if os(iOS)
            return flags.contains(.isWWAN)
        #else
            return false
        #endif
    }
    private var isReachableFlagSet: Bool {
        flags.contains(.reachable)
    }
    private var isConnectionRequiredFlagSet: Bool {
        flags.contains(.connectionRequired)
    }
    private var isInterventionRequiredFlagSet: Bool {
        flags.contains(.interventionRequired)
    }
    private var isConnectionOnTrafficFlagSet: Bool {
        flags.contains(.connectionOnTraffic)
    }
    private var isConnectionOnDemandFlagSet: Bool {
        flags.contains(.connectionOnDemand)
    }
    private var isConnectionOnTrafficOrDemandFlagSet: Bool {
        !flags.intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
    private var isTransientConnectionFlagSet: Bool {
        flags.contains(.transientConnection)
    }
    private var isLocalAddressFlagSet: Bool {
        flags.contains(.isLocalAddress)
    }
    private var isDirectFlagSet: Bool {
        flags.contains(.isDirect)
    }
    private var isConnectionRequiredAndTransientFlagSet: Bool {
        flags.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }

    private var flags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachabilityRef, &flags) {
            return flags
        } else {
            return SCNetworkReachabilityFlags()
        }
    }
}
