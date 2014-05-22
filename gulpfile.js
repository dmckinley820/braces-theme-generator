// Plugins
var gulp = require('gulp');
		watch = require('gulp-watch');
		sass = require('gulp-ruby-sass');
		autoprefixer = require('gulp-autoprefixer');
		concat = require('gulp-concat');
		uglify = require('gulp-uglify');
		rem = require('gulp-pixrem');
		compass = require('gulp-compass');


// Order in which js files should be processed
var footer_js_order = [
		'javascripts/customizer.js',
		'javascripts/keyboard-image-navigation.js',
		'javascripts/navigation.js',
		'javascripts/skip-link-focus-fix.js'
	];

var header_js_order = [ 'javascripts/modernizr.js' ];{{{SASSGULP}}}

// Styles
gulp.task('styles', function() {
	gulp.src('sass/styles.scss'){{{GULPCOMPASS}}}
		.pipe(compass({
				config_file: './config.rb',
				css: 'css',
				sass: 'sass'
		})){{{/GULPCOMPASS}}}{{{GULPNONCOMPASS}}}
		.pipe(sass({style: 'compressed'})){{{/GULPNONCOMPASS}}}
		.pipe(autoprefixer('last 1 version', '> 1%', 'ie 9', 'ie 8', 'ie 7'))
		.pipe(rem())
		.pipe(gulp.dest('css/'));
});{{{/SASSGULP}}}

// Footer Scripts
gulp.task('footer_scripts', function() {
	gulp.src(footer_js_order)
		.pipe(concat('footer.js'))
		.pipe(uglify())
		.pipe(gulp.dest('javascripts/compiled'));
});

// Header Scripts
gulp.task('header_scripts', function() {
	gulp.src(header_js_order)
		.pipe(concat('header.js'))
		.pipe(uglify())
		.pipe(gulp.dest('javascripts/compiled'));
});


gulp.task('watch', function() {
	// Watch the sass files
	gulp.watch('sass/**/*.scss', ['styles']);
	gulp.watch('javascripts/*.js', ['footer_scripts', 'header_scripts']);
});

// Make all tasks run and then watch for the rest
gulp.task('default', ['styles', 'footer_scripts', 'header_scripts', 'watch']);
