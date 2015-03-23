# v0.2.0
* Use direct `#to_json` to prevent conversion errors on older ruby
* Add `UnitScoreKeeper#preferred_score` to provide some score meaning
* Pass scoring preference through to queue init
* Provide current index to score keeper when requesting score

_ BREAKING CHANGES_: `UnitScoreKeeper#score_for` must now accept two parameters

# v0.1.6
* Add debug output if UI is available for output
* Update exception errors to provide more detail/context
* Provide better type checking prior to processing

# v0.1.4
* Provide simple system serialization support
* Fix dependency listing from units within path
* Allow checking existing path for constraint satisfaction

# v0.1.2
* Add JSON serialization support to utility instances
* Add abstract for unit scoring
* Populate queues in single push

# v0.1.0
* Initial commit
