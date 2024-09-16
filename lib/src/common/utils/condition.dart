abstract class Condition {
  const Condition();

  factory Condition.pattern(
      String pattern, {
        bool expectation = true,
      }) =>
      ConditionExp(exp: RegExp(pattern), expectation: expectation);

  factory Condition.exp(
      RegExp exp, {
        bool expectation = true,
      }) =>
      ConditionExp(exp: exp, expectation: expectation);

  factory Condition.any(List<Condition> subConditions) =>
      ConditionAny(subConditions);

  factory Condition.every(List<Condition> subConditions) =>
      ConditionEvery(subConditions);

  bool test(String source);
}

class ConditionExp extends Condition {
  const ConditionExp({
    required this.exp,
    this.expectation = true,
  });

  final RegExp exp;
  final bool expectation;

  @override
  bool test(String source) {
    return exp.hasMatch(source) == expectation;
  }
}

class ConditionAny extends Condition {
  const ConditionAny(this.subConditions);

  final List<Condition> subConditions;

  @override
  bool test(String source) {
    return subConditions.any((condition) => condition.test(source));
  }
}

class ConditionEvery extends Condition {
  const ConditionEvery(this.subConditions);

  final List<Condition> subConditions;

  @override
  bool test(String source) {
    return subConditions.every((condition) => condition.test(source));
  }
}