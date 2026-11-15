// The HarmonyOS counterpart of iOS CYLPlaceholderNetworkMonitor (behavior from android/placeholder's
// CYLPlaceholderStatus.kt and the iOS NWPathMonitor rules): watches whether the device has a network through
// @kit.NetworkKit's connection (a NetConnection on the default network), so the status bar can follow it. An unknown
// status (before the first update, or not monitoring) counts as reachable, so no bar flashes at launch. Every start
// makes a new NetConnection and stop unregisters it; updates of a stopped one are ignored. The HAR declares
// ohos.permission.GET_NETWORK_INFO.
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

/** The network status (iOS `CYLPlaceholderNetworkStatus`, the same raw values). */
export enum CYLPlaceholderNetworkStatus {
  /** Not known yet (before the first update, or not monitoring). */
  Unknown = -1,
  /** No usable network. */
  NotReachable = 0,
  /** Through cellular data. */
  ReachableViaWWAN = 1,
  /** Through Wi-Fi. */
  ReachableViaWiFi = 2,
  /** Through wired Ethernet. */
  ReachableViaWiredEthernet = 3,
  /** Through another bearer (a VPN, Bluetooth). */
  ReachableViaOther = 4
}

/** Runs with the new status when it changes (iOS `CYLPlaceholderNetworkStatusBlock`). */
export type CYLPlaceholderNetworkStatusBlock = (status: CYLPlaceholderNetworkStatus) => void;

/** Observers of CYLPlaceholderNetworkStatusDidChangeNotification receive the monitor. */
export type CYLPlaceholderNetworkMonitorObserver = (monitor: CYLPlaceholderNetworkMonitor) => void;

/** The name of the change notification (iOS `CYLPlaceholderNetworkStatusDidChangeNotification`). */
export const CYLPlaceholderNetworkStatusDidChangeNotification: string = 'CYLPlaceholderNetworkStatusDidChangeNotification';

/** NetBearType values (connection.NetBearType), kept as numbers so the rules are testable on the host. */
const BEARER_CELLULAR = 0;
const BEARER_WIFI = 1;
const BEARER_ETHERNET = 3;
/** connection.NetCap.NET_CAPABILITY_NOT_METERED. */
const NET_CAPABILITY_NOT_METERED = 11;

/** Watches the network (iOS `CYLPlaceholderNetworkMonitor`). */
export class CYLPlaceholderNetworkMonitor {
  private static shared: CYLPlaceholderNetworkMonitor | null = null;
  private statusValue: CYLPlaceholderNetworkStatus = CYLPlaceholderNetworkStatus.Unknown;
  private constrainedValue: boolean = false;
  private expensiveValue: boolean = false;
  private block: CYLPlaceholderNetworkStatusBlock | null = null;
  private observers: CYLPlaceholderNetworkMonitorObserver[] = [];
  private netConnection: connection.NetConnection | null = null;
  private generation: number = 0;
  /** Whether monitoring is on (also true in tests that drive updates by hand). */
  private started: boolean = false;

  /** The shared monitor; it starts on startMonitoring (iOS `sharedMonitor`). */
  static get sharedMonitor(): CYLPlaceholderNetworkMonitor {
    if (CYLPlaceholderNetworkMonitor.shared === null) {
      CYLPlaceholderNetworkMonitor.shared = new CYLPlaceholderNetworkMonitor();
    }
    return CYLPlaceholderNetworkMonitor.shared;
  }

  /** The current status; Unknown before the first update (iOS `networkStatus`). */
  get networkStatus(): CYLPlaceholderNetworkStatus {
    return this.statusValue;
  }

  /** false only when the status is NotReachable; Unknown counts as reachable (iOS `reachable`). */
  get reachable(): boolean {
    return this.statusValue !== CYLPlaceholderNetworkStatus.NotReachable;
  }

  /** Whether the system restricts data use (iOS `constrained`, Low Data Mode). HarmonyOS reports no such mode to apps: always false. */
  get constrained(): boolean {
    return this.constrainedValue;
  }

  /** Whether the network is metered: cellular or a metered Wi-Fi (iOS `expensive`). */
  get expensive(): boolean {
    return this.expensiveValue;
  }

  /** Whether the monitor is watching (iOS `monitoring`). */
  get monitoring(): boolean {
    return this.started;
  }

  /** Starts watching the default network (iOS `startMonitoring`); calling it again does nothing. */
  startMonitoring(): void {
    if (this.started) {
      return;
    }
    this.started = true;
    const generation = ++this.generation;
    try {
      const netConnection = connection.createNetConnection();
      this.netConnection = netConnection;
      netConnection.on('netCapabilitiesChange', (info: connection.NetCapabilityInfo) => {
        if (generation === this.generation) {
          this.applyCapabilities(info.netCap.bearerTypes, info.netCap.networkCap);
        }
      });
      netConnection.on('netLost', () => {
        if (generation === this.generation) {
          this.readDefaultNetwork();
        }
      });
      netConnection.on('netUnavailable', () => {
        if (generation === this.generation) {
          this.applyCapabilities(null, null);
        }
      });
      netConnection.register((error: BusinessError) => {
        if (error !== undefined && error !== null && error.code !== undefined && error.code !== 0) {
          console.warn('CYLPlaceholderNetworkMonitor: register failed ' + error.code);
        }
      });
    } catch (e) {
      console.warn('CYLPlaceholderNetworkMonitor: ' + JSON.stringify(e));
    }
    this.readDefaultNetwork();
  }

  /** Stops watching; the status goes back to Unknown (iOS `stopMonitoring`). */
  stopMonitoring(): void {
    if (!this.started) {
      return;
    }
    this.started = false;
    this.generation++;
    const netConnection = this.netConnection;
    this.netConnection = null;
    if (netConnection !== null) {
      try {
        netConnection.unregister((error: BusinessError) => {
        });
      } catch (e) {
        console.warn('CYLPlaceholderNetworkMonitor: ' + JSON.stringify(e));
      }
    }
    this.setStatus(CYLPlaceholderNetworkStatus.Unknown, false, false);
  }

  /** Runs block with the new status when it changes; null removes it (iOS `-setNetworkStatusChangeBlock:`). */
  setNetworkStatusChangeBlock(block: CYLPlaceholderNetworkStatusBlock | null): void {
    this.block = block;
  }

  /**
   * Adds an observer of CYLPlaceholderNetworkStatusDidChangeNotification: called when the status, `constrained` or
   * `expensive` changes (iOS NSNotificationCenter).
   */
  addObserver(observer: CYLPlaceholderNetworkMonitorObserver): void {
    if (this.observers.indexOf(observer) < 0) {
      this.observers.push(observer);
    }
  }

  /** Removes an observer added by addObserver. */
  removeObserver(observer: CYLPlaceholderNetworkMonitorObserver): void {
    this.observers = this.observers.filter((o: CYLPlaceholderNetworkMonitorObserver) => o !== observer);
  }

  /** The status's name for logs (iOS `+nameForStatus:`). */
  static nameForStatus(status: CYLPlaceholderNetworkStatus): string {
    switch (status) {
      case CYLPlaceholderNetworkStatus.NotReachable:
        return 'not reachable';
      case CYLPlaceholderNetworkStatus.ReachableViaWWAN:
        return 'cellular';
      case CYLPlaceholderNetworkStatus.ReachableViaWiFi:
        return 'Wi-Fi';
      case CYLPlaceholderNetworkStatus.ReachableViaWiredEthernet:
        return 'wired Ethernet';
      case CYLPlaceholderNetworkStatus.ReachableViaOther:
        return 'other';
      default:
        return 'unknown';
    }
  }

  /** The status of a network with these bearer types (connection.NetBearType values); null for no network. */
  static statusForBearerTypes(bearerTypes: number[] | null): CYLPlaceholderNetworkStatus {
    if (bearerTypes === null) {
      return CYLPlaceholderNetworkStatus.NotReachable;
    }
    if (bearerTypes.indexOf(BEARER_WIFI) >= 0) {
      return CYLPlaceholderNetworkStatus.ReachableViaWiFi;
    }
    if (bearerTypes.indexOf(BEARER_CELLULAR) >= 0) {
      return CYLPlaceholderNetworkStatus.ReachableViaWWAN;
    }
    if (bearerTypes.indexOf(BEARER_ETHERNET) >= 0) {
      return CYLPlaceholderNetworkStatus.ReachableViaWiredEthernet;
    }
    return CYLPlaceholderNetworkStatus.ReachableViaOther;
  }

  /**
   * Applies a network's capabilities (bearer types and NetCap values; null bearers for no network). Public so tests
   * and apps with their own detection can drive the monitor; ignored while not monitoring.
   */
  applyCapabilities(bearerTypes: number[] | null, networkCap: number[] | null | undefined): void {
    if (!this.started) {
      return;
    }
    const status = CYLPlaceholderNetworkMonitor.statusForBearerTypes(bearerTypes);
    const caps: number[] = networkCap !== null && networkCap !== undefined ? networkCap : [];
    const expensive = bearerTypes !== null && (caps.indexOf(NET_CAPABILITY_NOT_METERED) < 0 ||
      bearerTypes.indexOf(BEARER_CELLULAR) >= 0);
    this.setStatus(status, false, expensive);
  }

  /** Begins monitoring without a system connection (unit tests). */
  beginManualMonitoringForTesting(): void {
    this.started = true;
    this.generation++;
  }

  private readDefaultNetwork(): void {
    try {
      const handle = connection.getDefaultNetSync();
      if (handle === undefined || handle === null || handle.netId === 0) {
        this.applyCapabilities(null, null);
        return;
      }
      const caps = connection.getNetCapabilitiesSync(handle);
      this.applyCapabilities(caps.bearerTypes, caps.networkCap);
    } catch (e) {
      // No permission or no network service: stay Unknown.
    }
  }

  private setStatus(status: CYLPlaceholderNetworkStatus, constrained: boolean, expensive: boolean): void {
    const statusChanged = status !== this.statusValue;
    const costChanged = constrained !== this.constrainedValue || expensive !== this.expensiveValue;
    this.constrainedValue = constrained;
    this.expensiveValue = expensive;
    this.statusValue = status;
    const block = this.block;
    if (statusChanged && block !== null) {
      block(status);
    }
    if (statusChanged || costChanged) {
      this.observers.slice().forEach((o: CYLPlaceholderNetworkMonitorObserver) => o(this));
    }
  }
}
