# Contributors to Fortitude

Fortitude is written by [Andrew Geweke](https://github.com/ageweke), with contributions from:

* [Ahto Jussila](https://github.com/ahto): a patch to provide separate MRI and JRuby gems, so that
  `gem install fortitude` works properly no matter which platform you're on.
* [Roman Heinrich](https://github.com/mindreframer): reporting a bug where trying to use Fortitude as a Tilt
  engine to render would fail if the locals passed in were `nil`.
