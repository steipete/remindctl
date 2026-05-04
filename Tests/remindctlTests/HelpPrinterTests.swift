import Testing

@testable import remindctl

@MainActor
struct HelpPrinterTests {
  @Test("Root help includes commands")
  func rootHelp() {
    let specs = [
      ShowCommand.spec,
      ListCommand.spec,
      AddCommand.spec,
      StatusCommand.spec,
      AuthorizeCommand.spec,
    ]
    let lines = HelpPrinter.renderRoot(version: "0.0.0", rootName: "remindctl", commands: specs)
    let joined = lines.joined(separator: "\n")
    #expect(joined.contains("show"))
    #expect(joined.contains("list"))
    #expect(joined.contains("add"))
    #expect(joined.contains("status"))
    #expect(joined.contains("authorize"))
  }

  @Test("Add and edit help include alarm, location, and repeat options")
  func alarmLocationAndRepeatHelp() {
    let addHelp = HelpPrinter.renderCommand(rootName: "remindctl", spec: AddCommand.spec).joined(separator: "\n")
    let editHelp = HelpPrinter.renderCommand(rootName: "remindctl", spec: EditCommand.spec).joined(separator: "\n")

    #expect(addHelp.contains("--alarm"))
    #expect(addHelp.contains("--location"))
    #expect(addHelp.contains("--leaving"))
    #expect(addHelp.contains("--repeat"))
    #expect(editHelp.contains("--alarm"))
    #expect(editHelp.contains("--clear-alarm"))
    #expect(editHelp.contains("--repeat"))
    #expect(editHelp.contains("--no-repeat"))
  }
}
