# Grimoire

Light weight generic dependency resolver. Supports weighted
solutions via scored units.

## Usage

Basic usage flow:

* Create a system

```ruby
system = Grimoire::System.new
```

* Add units

```ruby
system.add_units(
  Grimoire::Unit.new(
    :name => 'unit1',
    :version => '1.0.0'
  ),
  Grimoire::Unit.new(
    :name => 'unit1',
    :version => '1.1.0'
  ),
  ...
)
```

* Create a score keeper

_NOTE: Score keeper is optional and *must* be subclassed. This example will not actually work._

```ruby
score_keeper = Grimoire::ScoreKeeper.new
```

* Create solver

```ruby
solver = Grimoire::Solver.new(
  :system => system,
  :score_keeper => score_keeper,
  :requirements => [
    ['unit1', '> 2.0.0'],
    ['unit2', '> 1', '< 3']
  ]
)
```

* Generate solutions

```ruby
solutions = solver.generate!
p solutions.pop
```

The ideal solution will be the first path on the queue.

## Info

* Repository: https://github.com/spox/grimoire
