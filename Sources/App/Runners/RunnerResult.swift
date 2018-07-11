enum RunnerResult {
    case success([ResultCase])
    case compileFailure(String)
    case unknownFailure
}
