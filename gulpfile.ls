require! {
	'gulp'
	mocha: 'gulp-mocha'
}

do 
	<-! gulp .task 'mintest'
	gulp
		.src 'test/tests/*.ls'
			.pipe mocha reporter: 'min'

do 
	<-! gulp .task 'test'
	gulp
		.src 'test/tests/*.ls'
			.pipe mocha reporter: 'nyan'
do 
	<-! gulp .task 'watch'
	gulp
		.watch <[test/tests/*.ls lib/*.ls test/fixtures/*.ss test/fixtures/*.ss.js]>, <[mintest]>


gulp .task 'default', <[test]>