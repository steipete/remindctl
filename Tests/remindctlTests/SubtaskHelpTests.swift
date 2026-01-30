import Testing

@testable import remindctl

@MainActor
struct SubtaskHelpTests {
  @Test("Add/edit help includes parent options")
  func helpIncludesParent() {
    let addHelp = HelpPrinter.renderCommand(rootName: "remindctl", spec: AddCommand.spec).joined(separator: "\n")
    #expect(addHelp.contains("--parent"))
    #expect(addHelp.contains("--under"))

    let editHelp = HelpPrinter.renderCommand(rootName: "remindctl", spec: EditCommand.spec).joined(separator: "\n")
    #expect(editHelp.contains("--parent"))
    #expect(editHelp.contains("--under"))
  }
}
