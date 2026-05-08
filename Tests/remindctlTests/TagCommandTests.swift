import Testing

@testable import remindctl

@MainActor
struct TagCommandTests {
  @Test("Tag helpers parse, merge, and compose tags")
  func tagHelpers() throws {
    let tags = try CommandHelpers.parseTags(["shopping,urgent", "#Work"])
    #expect(tags == ["shopping", "urgent", "Work"])

    let parsed = CommandHelpers.parseTitleTags("Buy milk #shopping #urgent")
    #expect(parsed.baseTitle == "Buy milk")
    #expect(parsed.tags == ["shopping", "urgent"])

    let merged = CommandHelpers.mergeTags(
      existing: parsed.tags,
      add: ["Work"],
      remove: ["urgent"],
      clear: false
    )
    #expect(merged == ["shopping", "Work"])
    #expect(CommandHelpers.composeTitle(baseTitle: parsed.baseTitle, tags: merged) == "Buy milk #shopping #Work")
  }

  @Test("Help includes tag options")
  func helpIncludesTagOptions() {
    let rootHelp = HelpPrinter.renderRoot(
      version: "0.0.0",
      rootName: "remindctl",
      commands: [ShowCommand.spec, TagsCommand.spec, AddCommand.spec, EditCommand.spec]
    ).joined(separator: "\n")
    let addHelp = HelpPrinter.renderCommand(rootName: "remindctl", spec: AddCommand.spec).joined(separator: "\n")
    let editHelp = HelpPrinter.renderCommand(rootName: "remindctl", spec: EditCommand.spec).joined(separator: "\n")
    let showHelp = HelpPrinter.renderCommand(rootName: "remindctl", spec: ShowCommand.spec).joined(separator: "\n")

    #expect(rootHelp.contains("tags"))
    #expect(addHelp.contains("--tag"))
    #expect(editHelp.contains("--remove-tag"))
    #expect(editHelp.contains("--clear-tags"))
    #expect(showHelp.contains("--tag"))
  }
}
