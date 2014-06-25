# Karma configuration
# http://karma-runner.github.io/0.12/config/configuration-file.html
# Generated on 2014-06-03 using
# generator-karma 0.8.1

module.exports = (config) ->
    config.set
        # base path, that will be used to resolve files and exclude
        basePath: '../'

        # testing framework to use (jasmine/mocha/qunit/...)
        frameworks: ['jasmine']

        # list of files / patterns to load in the browser
        files: [
            'app/bower_components/angular/angular.js',
            'app/bower_components/angular-mocks/angular-mocks.js',
            'app/bower_components/angular-cookies/angular-cookies.js',
            'app/bower_components/angular-resource/angular-resource.js',
            'app/bower_components/angular-sanitize/angular-sanitize.js',
            'app/bower_components/angular-route/angular-route.js',
            'app/bower_components/underscore/underscore.js',
            'app/bower_components/jquery/dist/jquery.js',
            'app/bower_components/jquery-ui/ui/jquery-ui.js',
            'app/bower_components/angular-bootstrap/ui-bootstrap-tpls.js',
            '.tmp/scripts/*.js',
            '.tmp/scripts/**/*.js',
            '.tmp/spec/**/*.js'
        ]

        # list of files / patterns to exclude
        exclude: []

        # web server port
        port: 8080

        # level of logging
        # possible values:
        #   LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
        logLevel: config.LOG_INFO

        # Start these browsers, currently available:
        # - Chrome
        # - ChromeCanary
        # - Firefox
        # - Opera
        # - Safari (only Mac)
        # - PhantomJS
        # - IE (only Windows)
        browsers: [
            'PhantomJS'
        ]

        # Which plugins to enable
        plugins: [
            'karma-coverage'
            'karma-phantomjs-launcher'
            'karma-jasmine'
        ]

        # enable / disable watching file and executing tests whenever
        # any file changes
        autoWatch: true

        # Continuous Integration mode
        # if true, it capture browsers, run tests and exit
        singleRun: false

        # Use color
        colors: true

        # Karma reports
        reporters: ['progress', 'coverage']

        coverageReporter:
            type : 'html'
            dir : 'coverage/'

        # source files, that you wanna generate coverage for
        # do not include tests or libraries
        preprocessors:
            # '**/.tmp/scripts/*.js': ['coverage']
            '**/.tmp/scripts/**/*.js': ['coverage']

        # Uncomment the following lines if you are using grunt's
        # server to run the tests:
        # proxies: '/': 'http://localhost:9000/'
        # URL root prevent conflicts with the site root
        # urlRoot: '_karma_'
