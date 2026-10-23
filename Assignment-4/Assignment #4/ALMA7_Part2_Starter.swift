// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

print("--- 1.1 Deck ---")
for deck in Deck.allCases {
    print("\(deck) (\(deck.rawValue)): priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let steps = max(0, min(mass / 500, 3))
        return AlarmLevel(rawValue: steps) ?? .red
    }
}

print("--- 1.2 AlarmLevel ---")
print(AlarmLevel.level(forTotalMass: 0))
print(AlarmLevel.level(forTotalMass: 940))
print(AlarmLevel.level(forTotalMass: 1499))
print(AlarmLevel.level(forTotalMass: 4000))


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else { return .unknown(raw: line) }

    switch (tag, parts.count) {
    case ("crate", 3):
        if let id = Int(parts[1]), let massKg = Int(parts[2]) {
            return .crate(id: id, massKg: massKg)
        }
    case ("container", 3):
        if let massKg = Int(parts[2]) {
            return .container(code: parts[1], massKg: massKg)
        }
    case ("livestock", 4):
        if let count = Int(parts[2]), let massPerUnitKg = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)
        }
    default:
        break
    }
    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("--- 2 Manifest ---")
var totalMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    totalMass += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
    print("\"\(line)\" -> \(entry), mass \(mass(of: entry))")
}
print("Total mass: \(totalMass) kg, unknown lines: \(unknownCount)")

let A = totalMass


// MARK: Level 3 · Crew Snapshots

// 3.1
// no init, struct gets one for free
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

print("--- 3.1 CrewSnapshot ---")
var rookie = CrewSnapshot.rookie(named: "Aru")
print(rookie)
rookie.breathe(30)
rookie.move(to: .cargo)
print(rookie)
rookie.breathe(500)
print("after breathing too much: \(rookie.oxygen)")
rookie.reviveInMedbay()
print("after revive: \(rookie)")

// 3.2
func buildRoster(from records: [(name: String, deck: String, oxygen: Int)]) -> [CrewSnapshot] {
    var result: [CrewSnapshot] = []
    for record in records {
        guard let deck = Deck(rawValue: record.deck) else {
            print("Warning: \(record.name) is on unknown deck '\(record.deck)', skipped")
            continue
        }
        result.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    }
    return result
}

let crewRoster: [CrewSnapshot] = buildRoster(from: crewData)
print("--- 3.2 roster ---")
print(crewRoster)
print(buildRoster(from: [(name: "Ghost", deck: "attic", oxygen: 50)]))

// 3.3 · Value-semantics demonstration
func drainPlain(_ snapshot: CrewSnapshot) {
    var local = snapshot
    local.breathe(30)
    print("   inside drainPlain: \(local.name) oxygen = \(local.oxygen)")
}

func drainInPlace(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(30)
    print("   inside drainInPlace: \(snapshot.name) oxygen = \(snapshot.oxygen)")
}

print("--- 3.3 value semantics ---")
var original = crewRoster[0]
print("1) copy: before: original = \(original.oxygen)")
var copy = original
copy.breathe(20)
print("   after:  copy = \(copy.oxygen), original = \(original.oxygen)")

print("2) plain function: before: original = \(original.oxygen)")
drainPlain(original)
print("   after:  original = \(original.oxygen)")

print("3) inout function: before: original = \(original.oxygen)")
drainInPlace(&original)
print("   after:  original = \(original.oxygen)")


// MARK: Level 4 · The Teleport Pod

// 4.1
// class has no free init
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }

    deinit {
        print("   deinit: pod \(id) is gone")
    }
}

// 4.2 · Charge ledger
func snapshot(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for member in roster {
        if member.name == name { return member }
    }
    return nil
}

print("--- 4.2 charge ledger ---")
let pod = TeleportPod(id: "P-1", chargeLevel: 100)
print("start: charge \(pod.chargeLevel)")

var step = 1
for name in ["Timur", "Dana", "Nurlan"] {
    if let member = snapshot(named: name, in: crewRoster) {
        let loaded = pod.load(member)
        let sent = pod.fire()
        print("\(step). load \(name): \(loaded), fire: \(sent?.name ?? "nobody"), charge \(pod.chargeLevel)")
    }
    step += 1
}
let emptyShot = pod.fire()
print("\(step). fire empty pod: \(emptyShot?.name ?? "nobody"), charge \(pod.chargeLevel)")

let C = pod.chargeLevel

// 4.3 · Reference-semantics demonstration
print("--- 4.3 reference semantics ---")
// class copies the reference, struct copies the value
let podAlias = pod
podAlias.chargeLevel = 5
print("class:  pod = \(pod.chargeLevel), podAlias = \(podAlias.chargeLevel)")
pod.chargeLevel = C

var snapshotCopy = crewRoster[0]
snapshotCopy.oxygen = 5
print("struct: roster[0] = \(crewRoster[0].oxygen), snapshotCopy = \(snapshotCopy.oxygen)")


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String

    var hullIntegrity: Int = 100 {
        willSet {
            print("   hull: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            hullIntegrity = min(max(hullIntegrity, 0), 100)
        }
    }

    var oxygenByDeck: [Deck: Int] = [:]

    lazy var fullDiagnostics: String = {
        print("   Running full scan...")
        return "\(self.callSign): hull \(self.hullIntegrity)%, decks online: \(self.oxygenByDeck.count)"
    }()

    var totalOxygen: Int {
        var sum = 0
        for oxygen in oxygenByDeck.values {
            sum += oxygen
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            oxygenByDeck.isEmpty ? 0 : totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else { continue }
            oxygenByDeck[deck] = reading.oxygen
        }
    }
}

print("--- 5.1 Station ---")
let station = Station(callSign: "ALMA-7", readings: deckReadings)
let B = station.averageOxygen
print("decks: \(station.oxygenByDeck.count), total oxygen: \(station.totalOxygen), average: \(station.averageOxygen)")

print("diagnostics not touched yet")
print("first access:")
print("   \(station.fullDiagnostics)")
print("second access:")
print("   \(station.fullDiagnostics)")

station.averageOxygen = 70
print("after averageOxygen = 70: \(station.oxygenByDeck.count) decks, total \(station.totalOxygen), average \(station.averageOxygen)")

let quietStation = Station(callSign: "ALMA-QUIET", readings: [])
print("\(quietStation.callSign) created, diagnostics never accessed (no scan message above)")

// 5.2 · The clamp trap
// assigning inside its own observer doesn't call the observer again
print("--- 5.2 clamp trap ---")
station.hullIntegrity = 130
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = -40
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = 55
print("hull = \(station.hullIntegrity)")


// MARK: Level 6 · Incident Reports

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

// Report 1: struct copy in the loop, change by index
print("--- Report 1 fixed ---")
var fixedRoster = crewRoster
for index in fixedRoster.indices {
    fixedRoster[index].oxygen -= 10
}
print("before: \(crewRoster[0].oxygen), after: \(fixedRoster[0].oxygen)")

// Report 2: class is shared by reference, make a new pod
print("--- Report 2 fixed ---")
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = TeleportPod(id: "B-copy", chargeLevel: podA.chargeLevel)
podB.chargeLevel = 0
print("podA = \(podA.chargeLevel), podB = \(podB.chargeLevel)")

// Report 3: doesn't compile, needs mutating
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
print("--- Report 3 fixed ---")
var logbook = Logbook()
logbook.add("Day ten: teleporter reports success")
print(logbook.entries)

// Report 4: let freezes the whole struct, but only the reference of a class (snapshot is an error, pod is fine)
print("--- Report 4 fixed ---")
var dana = CrewSnapshot.rookie(named: "Dana")
dana.oxygen = 40
let podB4 = TeleportPod(id: "B", chargeLevel: 50)
podB4.chargeLevel = 10
print("\(dana.name) oxygen \(dana.oxygen), pod \(podB4.id) charge \(podB4.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box


// internal: usable in the module
internal final class FlightRecorder {
    // private: nobody outside can touch entries
    private var entries: [String] = []

    // private(set): can't be un-sealed from outside
    private(set) var isSealed = false

    internal var count: Int {
        entries.count
    }

    @discardableResult
    internal func add(_ entry: String) -> Bool {
        guard !isSealed else { return false }
        entries.append(entry)
        return true
    }

    internal func seal() {
        isSealed = true
    }

    internal var transcript: String {
        var text = ""
        for index in entries.indices {
            text += numberedLine(at: index) + "\n"
        }
        return text
    }

    // fileprivate: auditTranscript below needs it
    fileprivate func numberedLine(at index: Int) -> String {
        "#\(index + 1) \(entries[index])"
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    var lines: [String] = []
    for index in 0..<recorder.count {
        lines.append(recorder.numberedLine(at: index))
    }
    let state = recorder.isSealed ? "SEALED" : "OPEN"
    return "[\(state)] " + lines.joined(separator: " | ")
}

print("--- 7 FlightRecorder ---")
let recorder = FlightRecorder()
recorder.add("Teleporter online")
recorder.add("Crew transferred")
print("count: \(recorder.count)")
print(recorder.transcript, terminator: "")
recorder.seal()
print("add after seal: \(recorder.add("Too late"))")
print("count after seal: \(recorder.count), sealed: \(recorder.isSealed)")
print(auditTranscript(of: recorder))
// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus


print("--- Bonus: lifetime ---")
var secondReference: TeleportPod?
do {
    let inner = TeleportPod(id: "TMP-1", chargeLevel: 100)
    secondReference = inner
    print("inside do block, two references to \(inner.id)")
}
print("after do block: pod still alive, secondReference = \(secondReference?.id ?? "nil")")
secondReference = nil
print("after secondReference = nil")

do {
    let lonely = TeleportPod(id: "TMP-2", chargeLevel: 100)
    print("inside do block, one reference to \(lonely.id)")
}
print("after second do block")

func relation(of first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "same pod (one object, two references)"
    } else if first.id == second.id && first.chargeLevel == second.chargeLevel {
        return "two different pods with equal contents"
    } else {
        return "two different pods"
    }
}

print("--- Bonus: identity ---")
let samePod = pod
let lookalike = TeleportPod(id: pod.id, chargeLevel: pod.chargeLevel)
print(relation(of: pod, samePod))
print(relation(of: pod, lookalike))
print(relation(of: pod, podA))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    Structs get a memberwise init, classes don't.

 2. What does `mutating` do to self, and why do classes never need it?
    It lets a struct method change self. A class is a reference.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
    Struct: the whole value. Class: only the reference.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
    It gets its value after init. It runs on first access only, not at creation.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
    numberedLine, because auditTranscript is outside the class.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
    When the last reference is gone. A struct has no identity.

*/
