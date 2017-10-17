import Foundation
import Vapor
import HTTP

final class EventsController: ResourceRepresentable {

    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    /// GET /events
    func index(_ req: Request) throws -> ResponseRepresentable {
        let activeEvents = try Event.makeQuery().filter(raw: "(starts_at is null OR starts_at < CURRENT_TIMESTAMP) AND (ends_at is null OR ends_at > CURRENT_TIMESTAMP)").all()
        let pastEvents = try Event.makeQuery().filter(raw: "ends_at < CURRENT_TIMESTAMP").all()

        return try render("Events/events", ["activeEvents": activeEvents, "pastEvents": pastEvents], for: req, with: view)
    }

    /// GET /events/:id
    func show(_ request: Request, _ id: String) throws -> ResponseRepresentable {
        if request.auth.isAuthenticated(User.self) {
            return Response(redirect: "/events/\(id)/problems")
        }

        guard let event = try Event.find(id) else {
            throw Abort.notFound
        }

        guard event.isPubliclyVisible() else {
            throw Abort.unauthorized
        }

        let problems = try event.eventProblems.sort("sequence", .ascending).all()
        return try render("Events/event-logged-out", ["event": event, "problems": problems], for: request, with: view)
    }

    func makeResource() -> Resource<String> {
        return Resource(index: index, show: show)
    }

    /// GET /events/new
    func eventNew(request: Request) throws -> ResponseRepresentable {
        return try render("Events/Teacher/event-new", for: request, with: view)
    }

    /// POST /events/new
    func eventNewSubmit(request: Request) throws -> ResponseRepresentable {
        guard
            let userId = request.user?.id,
            let name = request.data["name"]?.string
        else {
            throw Abort.badRequest
        }

        // Extract
        // TBD: How do we handle invalid dates? (I think I'm just consuming them as nil)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let startsAt = request.data["starts_at_date"]?.string
            .flatMap { rawDate in rawDate + " " + (request.data["starts_at_time"]?.string ?? "0:00") }
            .flatMap { rawDateTime in formatter.date(from: rawDateTime) }

        let endsAt = request.data["ends_at_date"]?.string
            .flatMap { rawDate in rawDate + " " + (request.data["ends_at_time"]?.string ?? "0:00") }
            .flatMap { rawDateTime in formatter.date(from: rawDateTime) }

        let languageRestriction = request.data["language_restriction"]?.string.flatMap { raw in Language(rawValue: raw) }

        // Save & continue
        let event = Event(
            name: name,
            userID: userId,
            startsAt: startsAt,
            endsAt: endsAt,
            languageRestriction: languageRestriction
        )
        try event.save()
        return Response(redirect: "/events/\(event.id!.string!)/problems/new")
    }

    /// GET /events/:id/problems/new
    func eventProblemNew(request: Request) throws -> ResponseRepresentable {
        return try render("Events/Teacher/event-problem-new", for: request, with: view)
    }

    /// GET /events/:id/problems/:seq/edit
    func eventProblemEdit(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)
        let eventProblemSeq = request.parameters["eventProblemSeq"]!
        let eventProblem = try EventProblem.makeQuery()
            .filter(EventProblem.self, "event_id", event.id)
            .filter(EventProblem.self, "sequence", eventProblemSeq)
            .first()!

        let problem = try eventProblem.problem.get()!
        let cases = try problem.cases.all()
        return try render("Events/Teacher/event-problem-new", ["eventProblem": eventProblem, "problem": problem, "cases": cases], for: request, with: view)
    }

    /// POST /events/:id/problems/new
    /// POST /events/:id/problems/:seq/edit
    func eventProblemNewSubmit(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)

        // Extract
        guard
            let eventId = event.id,
            let name = request.data["name"]?.string,
            let description = request.data["description"]?.string,
            let comparisonMethodRaw = request.data["comparison_method"]?.string,
            let comparisonMethod = ComparisonMethod(rawValue: comparisonMethodRaw)
        else {
            throw Abort.badRequest
        }

        let comparisonIgnoreSpaces = (request.data["comparison_ignore_spaces"]?.string == "true")
        let comparisonIgnoreBreaks = (request.data["comparison_ignore_breaks"]?.string == "true")

        // Save EventProblem & Problem
        let eventProblemSeq = request.parameters["eventProblemSeq"]
        let eventProblem: EventProblem
        let problem: Problem

        if(eventProblemSeq == nil) {
            // New
            problem = Problem(name: name, description: description, comparisonMethod: comparisonMethod, comparisonIgnoresSpaces: comparisonIgnoreSpaces, comparisonIgnoresBreaks: comparisonIgnoreBreaks)
            try problem.save()

            // TBD: Probably need a better way to define sequence
            let seq = try EventProblem.makeQuery()
                .filter(EventProblem.self, "event_id", eventId).count() + 1

            eventProblem = EventProblem(eventID: eventId, problemID: problem.id!, sequence: seq)
            try eventProblem.save()
        } else {
            // Edit
            eventProblem = try EventProblem.makeQuery()
                .filter(EventProblem.self, "event_id", event.id)
                .filter(EventProblem.self, "sequence", eventProblemSeq!)
                .first()!

            problem = try eventProblem.problem.get()!
            problem.name = name
            problem.description = description
            problem.comparisonMethod = comparisonMethod
            problem.comparisonIgnoresSpaces = comparisonIgnoreSpaces
            problem.comparisonIgnoresBreaks = comparisonIgnoreBreaks
            try problem.save()
        }

        // Save ProblemCases
        if let ids = request.data["case_ids"]?.array {
            for idNode in ids {
                if let id = idNode.string {
                    // Extract
                    let caseInput = request.data["case_inputs"]?[id]?.string ?? ""
                    let caseOutput = request.data["case_outputs"]?[id]?.string ?? ""
                    let visibilityRaw = request.data["case_visibilities"]?[id]?.int
                    let visibility = (visibilityRaw.flatMap { ProblemCaseVisibility(rawValue: $0) }) ?? .hide

                    // Save
                    if(id.hasPrefix("new-")) {
                        // New
                        let problemCase = ProblemCase(input: caseInput, output: caseOutput, visibility: visibility, problemID: problem.id)
                        try problemCase.save()
                    } else {
                        // Edit
                        let problemCase = try ProblemCase.makeQuery()
                            .filter(ProblemCase.self, "id", id)
                            .first()!

                        problemCase.input = caseInput
                        problemCase.output = caseOutput
                        problemCase.visibility = visibility
                        try problemCase.save()
                    }
                }
            }
        }

        return Response(redirect: "/events/\(eventId.string!)/problems/\(eventProblem.sequence)")
    }

    /// GET /events/:id/edit
    func eventEditForm(request: Request) throws -> ResponseRepresentable {
        let event = try request.parameters.next(Event.self)

        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"

        return try render("Events/Teacher/event-edit", [
            "event": event,
            "startsAtDate": event.startsAt == nil ? "" : dateformatter.string(from: event.startsAt!),
            "startsAtTime": event.startsAt == nil ? "" : timeformatter.string(from: event.startsAt!),
            "endsAtDate": event.endsAt == nil ? "" : dateformatter.string(from: event.endsAt!),
            "endsAtTime": event.endsAt == nil ? "" : timeformatter.string(from: event.endsAt!)], for: request, with: view)
    }

    /// POST /events/:id/edit
    func eventEdit(request: Request) throws -> ResponseRepresentable {
        guard let name = request.data["name"]?.string, let shortDescription = request.data["short_description"]?.string,
            let status = EventStatus(rawValue: Int(request.data["status"]?.string ?? "") ?? 0) else {
                throw Abort.badRequest
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let startsAt = request.data["starts_at_date"]?.string
            .flatMap { rawDate in rawDate + " " + (request.data["starts_at_time"]?.string ?? "0:00") }
            .flatMap { rawDateTime in formatter.date(from: rawDateTime) }

        let endsAt = request.data["ends_at_date"]?.string
            .flatMap { rawDate in rawDate + " " + (request.data["ends_at_time"]?.string ?? "0:00") }
            .flatMap { rawDateTime in formatter.date(from: rawDateTime) }

        let languageRestriction = request.data["language_restriction"]?.string.flatMap { raw in Language(rawValue: raw) }
        let scoringSystem = ScoringSystem(rawValue: Int(request.data["scoring_system"]?.string ?? "") ?? 0) ?? ScoringSystem.default
        let scoresHiddenBeforeEnd = Int(request.data["scores_hidden_before_end"]?.string ?? "") ?? 0
        
        let event = try request.parameters.next(Event.self)
        event.name = name
        event.shortDescription = shortDescription
        event.status = status
        event.startsAt = startsAt
        event.endsAt = endsAt
        event.languageRestriction = languageRestriction
        event.scoringSystem = scoringSystem
        event.scoresHiddenBeforeEnd = scoresHiddenBeforeEnd
        
        try event.save()

        return Response(redirect: "/events/#(event.eventId)/problems")
    }

}
