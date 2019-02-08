public enum MeowVaporError: Error {
    case modelInParameterNotFound
    
    @available(*, deprecated, message: "Don't switch over this enum without a default case, because we may add more cases in the futrure, and that will break your code")
    case dontSwitchOverThisEnumWithoutADefaultCaseBecauseWeMayAddMoreCasesInTheFutureAndThatWillBreakYourCode
}
