# v0.2.16
* Fix constraint validator to check full unit collection

# v0.2.14
* Relax constraints on dependency libraries

# v0.2.12
* Raise solution error on world prune if no units available for requirements

# v0.2.10
* Remove units that do not satisfy requirements prior to world prune

# v0.2.8
* Provide helpful error when world contains no units to satisfy requirement

# v0.2.6
* Add support for external constraint set within solver
* Allow Solver#requirements to be coerced from Array

# v0.2.4
* No longer force error when no requested units are within system
* Discard no solution errors when pruning the world instead of failing

# v0.2.2
* Provide origin solver to score keeper when requesting unit score
* Introduce Solver#prune_world! to remove extraneous units

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
