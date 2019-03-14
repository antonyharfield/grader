import Command

public func commands(_ commandConfig: inout CommandConfig) {
    commandConfig.use(SeedCommand(), as: "seed")
}
