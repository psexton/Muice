Muice
=====

A service locator framework for MATLAB.

Overview
--------

Muice (pronounced 'moose') is based on the ideas and concepts found in [Google Guice] (https://code.google.com/p/google-guice/). I wanted the same thing for MATLAB code: modular pieces that can be swapped in and out without disturbing their surroundings. 

Matlab doesn't have annotations like Java does. But what it does have is function handles. So I built a framework using those. It's _technically_ not dependency injection, because the function has to be aware of Muice to make use of it. Muice is more accurately a Service Locator.

The end result is the same though. After a bit of extra work upfront, you can swap out what the implementations of your functions/classes, even built-in functions!

Installation
------------

Run the `onLoad` script to load this package onto the MATLAB path. Run the `onUnload` script to remove it from the path.

Versioning
----------

Versioning is done according to [Semantic Versioning](http://semver.org). Release tags are [Semanticly Versioned Names](http://semvername.org).

Dependencies
------------

Muice requires MATLAB 2009a or later.

Contributing
------------

1. Fork it ( https://github.com/psexton/Muice/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request 

License
-------

[BSD 2-Clause](http://opensource.org/licenses/bsd-license.php)
