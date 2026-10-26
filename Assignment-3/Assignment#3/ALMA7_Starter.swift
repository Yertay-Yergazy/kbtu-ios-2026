// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, text) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(text),
          value >= 0 || sensor == "TEMP"
    else { return nil }
    return (sensor: sensor, value: value)
}

print("--- 1.1 parseReading ---")
print(parseReading("O2:87") as Any)
print(parseReading("TEMP:-12") as Any)
print(parseReading("RAD:-1") as Any)
print(parseReading(":55") as Any)
print(parseReading("hello") as Any)

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid, invalidCount)
}

let parsed = parseLog(rawLog)
print("--- 1.2 parseLog ---")
print("valid: \(parsed.valid)")
print("invalid: \(parsed.invalidCount)")
print(parseLog([]))
print(parseLog(["O2:1", "junk"]))

let A = parsed.invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let o2Readings = select(parsed.valid) { $0.sensor == "O2" }
print("--- 2.1 select / values ---")
print("O2 readings: \(o2Readings)")
print("O2 values: \(values(of: o2Readings))")
print("TEMP values: \(values(of: select(parsed.valid) { $0.sensor == "TEMP" }))")

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
        sum += value
    }
    return (minValue, maxValue, Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print("--- 2.2 stats ---")
print(stats(3, 8, 1) as Any)
print(stats() as Any)
print(stats(of: [10, 20]) as Any)
print(stats(of: values(of: o2Readings)) as Any)

let o2Stats = stats(of: values(of: o2Readings))
let B = Int(o2Stats?.average ?? 0)

func sameReadings(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else { return false }
    for index in 0..<a.count {
        if a[index].sensor != b[index].sensor || a[index].value != b[index].value {
            return false
        }
    }
    return true
}

let valid = parsed.valid

let sorted1 = valid.sorted(by: { (lhs: Reading, rhs: Reading) -> Bool in
    return lhs.value > rhs.value
})
let sorted2 = valid.sorted(by: { lhs, rhs -> Bool in
    return lhs.value > rhs.value
})
let sorted3 = valid.sorted(by: { lhs, rhs in lhs.value > rhs.value })
let sorted4 = valid.sorted(by: { $0.value > $1.value })
let sorted5 = valid.sorted { $0.value > $1.value }

print("--- 2.3 Closure Ladder ---")
print("sorted: \(sorted5)")
print("1 == 2: \(sameReadings(sorted1, sorted2))")
print("2 == 3: \(sameReadings(sorted2, sorted3))")
print("3 == 4: \(sameReadings(sorted3, sorted4))")
print("4 == 5: \(sameReadings(sorted4, sorted5))")


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

print("--- 3.1 chooseProtocol ---")
print(chooseProtocol(for: 10)(10))
print(chooseProtocol(for: 30)(30))
print(chooseProtocol(for: 20)(20))

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let step = chooseProtocol(for: temp)
        temp = step(temp)
        steps += 1
    }
    return (temp, steps, temp >= 18 && temp <= 24)
}

print("--- 3.2 runUntilStable ---")
print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))
print(runUntilStable(from: 20))

let temperatures = values(of: select(valid) { $0.sensor == "TEMP" })
let C: Int
if let tempStats = stats(of: temperatures) {
    C = runUntilStable(from: tempStats.min).steps
} else {
    C = 0
}


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print("--- 4.1 oxygenLevel ---")
for member in crew {
    print("\(member.name): \(oxygenLevel(of: member) as Any)")
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    return level < 20 ? "\(member.name): \(level)% CRITICAL" : "\(member.name): \(level)% OK"
}

print("--- 4.2 status ---")
for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    let moved = max(0, min(amount, source, 100 - target))
    source -= moved
    target += moved
    return moved
}

print("--- 4.3 transferOxygen ---")
var testA = 50
var testB = 90
print("moved \(transferOxygen(from: &testA, to: &testB, amount: 30)): a=\(testA) b=\(testB)")
print("moved \(transferOxygen(from: &testA, to: &testB, amount: -5)): a=\(testA) b=\(testB)")

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Lab -> Hab moved \(moved): Lab=\(labTank.level) Hab=\(habTank.level)")
}

let D = hab.oxygenTank?.level ?? 0

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let ordered = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in ordered {
        result.append(member.name)
    }
    return result
}

print("--- 4.4 evacuationOrder ---")
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Dana", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/

// PROBLEMS in the saboteur's code:
//
// reportOxygen(for:)
//  1. `member.module!` crashes when the member has no module (Nurlan, in open space):
//     force-unwrapping nil -> fatal error "Unexpectedly found nil".
//  2. `.oxygenTank!` crashes when the module has no tank (Dana, in Dock): same crash.
//
// firstCritical(in:)
//  3. `oxygenLevel(of: member)!` crashes for any member with no oxygen data
//     (Dana is the second in `crew`, so it crashes before reaching Aigerim).
//  4. `result!` crashes when nobody is critical, or the crew is empty (result is still nil).
//  5. Logic bug: the loop never stops at the first match, so `result` is overwritten by every
//     later critical member. The function returns the LAST critical member, not the first.
//     With the starter data only Aigerim is critical, so the bug is invisible there.
//  6. The return type `String` cannot say "nobody is critical", which is the reason for the `result!` crash.

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

print("--- Level 5 fixed saboteur code ---")
for member in crew {
    print(reportOxygen(for: member))
}
print("firstCritical (starter crew): \(firstCritical(in: crew) as Any)")
print("firstCritical (empty crew): \(firstCritical(in: []) as Any)")

let weakModuleA = Module(name: "TestA", oxygenTank: Tank(level: 5))
let weakModuleB = Module(name: "TestB", oxygenTank: Tank(level: 10))
let testCrew = [
    CrewMember(name: "Anna", role: "Medic",  priority: 1, module: weakModuleA),
    CrewMember(name: "Boris", role: "Cook",  priority: 2, module: weakModuleB)
]
let firstName = firstCritical(in: testCrew)
print("firstCritical (two critical): \(firstName as Any)")
print("logic bug fixed: \(firstName == "Anna")")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        guard level < threshold else { return false }
        count += 1
        print("Alarm #\(count)")
        return true
    }
}

print("--- Bonus makeAlarm ---")
let alarm = makeAlarm(threshold: 20)
print(alarm(12))
print(alarm(40))
print(alarm(5))
let otherAlarm = makeAlarm(threshold: 50)
print(otherAlarm(10))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    `if let` makes the unwrapped value live only inside its own { } block, so the
    "happy path" gets nested deeper with every optional. `guard let` unwraps for the
    rest of the scope and the else branch must exit (return / continue / throw), so
    the failure cases are handled first and the main logic stays flat. Example where
    `if let` is worse: parseReading with three checks would become three nested
    `if let`s with the real return buried inside and a repeated `return nil` at
    every level. With `guard let a, let b, cond else { return nil }` it is one line.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    Inside the function a variadic parameter is an [Int], but from the caller's side
    it is a list of separate arguments: stats(1, 2, 3). Swift doesn't unpack an array
    into variadic arguments, so the types don't match. For an array, call the other
    overload: stats(of: someArray).

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    inout gives the function exclusive access to the variable for the whole call.
    Passing &x twice would be two overlapping accesses to the same memory, and
    Swift's exclusivity rule forbids that. It prevents the bug where source and
    target are the same variable: the function would read and write one value
    through two names and the result (and the "amount moved") would be wrong.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    `??` needs the default to have the same type as the wrapped value. oxygenLevel
    returns Int?, so the default must be an Int; "no data" is a String. Fix: use an
    Int default (`?? 0`), or unwrap with guard let and build the String yourself,
    as status(of:) does: guard let level = oxygenLevel(of: dana) else { return "no data" }.

 5. Full type of chooseProtocol and how to read it:
    (Int) -> (Int) -> Int, more precisely chooseProtocol(for:) has the type
    (Int) -> ((Int) -> Int). Read it from the left: "takes an Int (the temperature)
    and returns a function which takes an Int and returns an Int". The arrow is
    right-associative, so the second pair of parentheses is optional. Called as
    chooseProtocol(for: 30)(30): the first call picks the protocol, the second applies it.

 Bonus. Where does the alarm counter live after makeAlarm returns?
    The closure captures the local variable `count`. Swift moves it from the stack to
    the heap (a box) that is owned by the closure, so it lives as long as the closure
    does. Every call of makeAlarm creates a new box, which is why `otherAlarm` starts
    from Alarm #1 again.

*/
