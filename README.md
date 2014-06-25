Webvis
======

A web-based visualizer for ACM SIG-Game written in Coffeescript


Setting Up Your Development Environment
---------------------------------------

### Tools ###

This project uses a few different tools to aid in the development of
the web visualizer:

NodeJS
: A server-side JavaScript interpreter. Basically, NodeJS allows us to
  run JavaScript on the command line instead of only in a
  browser. Most of the development tools that we're using are written
  in JavaScript, so we need node.

Yeoman
: A scaffolding tool for web projects. It was developed by some guys
  at Google to help with the development of Angular applications. It's
  nice because it can generate various Angular components
  (controllers, services, etc) exactly the same way every
  time. Consistent code is beautiful code.

Grunt
: A task runner. ``grunt`` is an alternative to ``make`` that does
  some fancy things. Along with compiling source, it can run a variety
  of other tasks that help with development. Try running ``grunt
  --help`` to see a list of available tasks.

Bower
: A package manager for the web. Instead of downloading copies of
  JavaScript and CSS libraries and keeping them under version control
  or using git submodules, bower uses a list of dependencies (with
  version numbers) to retrieve library dependencies. There's even a
  grunt task to add the appropriate ``link`` and ``script`` tags to
  ``index.html``, so that everything loads properly.

NPM
: A package manager for NodeJS. ``npm`` will install development
  packages for you in your project directory. Dependencies are
  specified in ``packages.json``, and installed in ``node_modules/``
  by ``npm``.


### Prerequisites ###

You need to have a few things installed before you can get started.

#### System Packages ####

* NodeJS ``sudo aptitude install nodejs``
* NPM ``sudo aptitude install npm``

#### Node Packages ####

If you don't want to install your NPM packages globally in /usr/local,
you can install them to a local location (such as ``~/.npm-packages``)
if you'd like. Just set ``prefix = ~/.npm-packages`` in your
``~/.npmrc`` file. For more information, refer to
[this](http://stackoverflow.com/a/13021677) StackOverflow post.

* Grunt Command Line tool ``npm install -g grunt-cli``
* Bower ``npm install -g bower``
* Yeoman ``npm install -g yo``
* Angular Generator for Yeoman ``npm install -g generator-angular``

### Setting Up ###

Once you have everything installed, it's pretty easy to set up your
development environment. Make sure that you have an Internet
connection. npm and bower will need to download packages.

* Change into your ng-webvis directory: ``cd ng-webvis``
* Install necessary node packages: ``npm install`` (just run this in
  the root of the ng-webvis project; the same directory as
  package.json)
* Install necessary application dependencies: ``bower install`` (just
  run this in the root of the ng-webvis project; the same directory as
  bower.json)

That's it! You're good to go.


Development
-----------

### Using Yeoman ###

TODO: explain how yeoman should be used
