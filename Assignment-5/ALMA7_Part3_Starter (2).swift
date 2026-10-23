// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// class: one cell is shared by reference
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(charge + amount, 100)
    }
}

print("--- Level 1 PowerCell ---")
let cell = PowerCell(charge: 150)
print("start (150 clamped): \(cell.level())")
print("spend 30: \(cell.spend(30)), level \(cell.level())")
print("spend 0: \(cell.spend(0)), spend -5: \(cell.spend(-5)), spend 500: \(cell.spend(500)), level \(cell.level())")
cell.recharge(by: -10)
print("recharge -10: level \(cell.level())")
cell.recharge(by: 500)
print("recharge 500: level \(cell.level())")

// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  final: subclasses can't change the ritual
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    var canRunAgain: Bool {
        cell.level() >= powerCost
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }

    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welds a seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }

    override func performTask() -> Int { 15 }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }

    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    guard let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) else {
        print("Warning: unknown drone kind '\(record.kind)' (\(record.id)), skipped")
        continue
    }
    fleet.append(drone)
}
print("--- Level 2 fleet ---")
print("fleet size: \(fleet.count)")
for drone in fleet {
    print(drone.statusLine)
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

print("--- Level 3 shift ---")
let A = runShift(fleet, rounds: 3)
print("work units: \(A)")
for drone in fleet {
    print(drone.statusLine)
}

var chargeSum = 0
var readyCount = 0
for drone in fleet {
    chargeSum += drone.cell.level()
    if drone.canRunAgain {
        readyCount += 1
    }
}
print("drones ready for one more task: \(readyCount)")

let B = chargeSum
let C = readyCount


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

extension Diagnosable {
    static func healthCode(forLevel level: Int) -> Int {
        switch level {
        case ..<20:   return 2
        case 20..<50: return 1
        default:      return 0
        }
    }

    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }
}

// class: no mutating, self is a reference
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }

    var statusCode: Int {
        Drone.healthCode(forLevel: cell.level())
    }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int

    var statusCode: Int {
        SensorModule.healthCode(forLevel: chargeLevel)
    }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(componentID: record.id, chargeLevel: record.charge))
}

print("--- Level 4 sensors ---")
print(sensors)
var spareSensor = sensors[0]
spareSensor.recharge(by: 30)
print("spare hull-cam after recharge(30): \(spareSensor.chargeLevel), code \(spareSensor.statusCode)")
spareSensor.recharge(by: 500)
print("spare hull-cam after recharge(500): \(spareSensor.chargeLevel), original still \(sensors[0].chargeLevel)")

// 4.3
// [Drone] can't hold a struct
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}
print("--- Level 4 diagnostics report ---")
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1

// 5.2
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }

    var statusCode: Int {
        LegacyBeacon.healthCode(forLevel: signalStrength)
    }

    func diagnose() -> String {
        "[LEGACY] \(name): signal \(signalStrength), code \(statusCode)"
    }
}

components.append(beacon)
print("--- Level 5 report with beacon ---")
print(diagnosticsReport(components))

var totalStatus = 0
for component in components {
    totalStatus += component.statusCode
}
let D = totalStatus

// 5.3
extension Int {
    var powerBar: String {
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }
}

print("--- Level 5 powerBar ---")
print("42 -> \(42.powerBar)")
print("-5 -> \((-5).powerBar)")
print("250 -> \(250.powerBar)")
print("100 -> \(100.powerBar)")


// MARK: Level 6 · Incident Reports

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

// Report 1: missing override, doesn't compile
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}

// Report 2: WelderDrone and runOnce are final, doesn't compile
class HeavyDrone: Drone {
    override var powerCost: Int { 30 }
    override func performTask() -> Int { 999 }
}

let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
// Report 3: Drone has no weldSeam, doesn't compile. as? is optional because the cast can fail
print("--- Report 3 fixed ---")
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}
if let scanner = first as? ScannerDrone {
    print(scanner.statusLine)
} else {
    print("W-9 is not a ScannerDrone, as? gave nil")
}

// Report 4: label() wasn't a requirement so it used the variable's type, added to protocol
protocol Labelled {
    var componentID: String { get }
    func label() -> String
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("--- Report 4 fixed ---")
print(parts[0].label())


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// bonus 1: runtime
class RuntimeAbstractDrone {
    init() {
        precondition(type(of: self) != RuntimeAbstractDrone.self, "RuntimeAbstractDrone is abstract, subclass it")
    }
    func performTask() -> Int { fatalError("subclass must override performTask()") }
}
final class ConcreteDrone: RuntimeAbstractDrone {
    override func performTask() -> Int { 1 }
}
// bonus 1: compile time
protocol Worker {
    var powerCost: Int { get }
    func performTask() -> Int
}

protocol FleetDrone {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension FleetDrone {
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

struct StructWelder: FleetDrone {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}

struct StructScanner: FleetDrone {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 10 }
    func performTask() -> Int { 15 }
}

let protocolFleet: [FleetDrone] = [
    StructWelder(id: "SW-1", cell: PowerCell(charge: 80)),
    StructScanner(id: "SS-1", cell: PowerCell(charge: 45))
]
var protocolTotal = 0
for _ in 0..<3 {
    for drone in protocolFleet {
        protocolTotal += drone.runOnce()
    }
}
// bonus 3: protocols are better here, classes if state is shared
print("--- Bonus: protocol fleet ---")
print("protocol fleet work units: \(protocolTotal)")


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    A class is a reference, a struct has to write self back.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Inheritance shares stored properties. Protocols unite a class and a struct.

 3. What does `final` prevent, and what did it protect in runOnce()?
    Overriding and subclassing. The runOnce() ritual stays the same.

 4. In Report 4, why did the protocol extension's method win?
    label() wasn't a requirement, so the variable's type decided.

*/
