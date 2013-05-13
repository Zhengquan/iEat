### references
* [32 Rack Resources to Get You Started](http://jasonseifer.com/2009/04/08/32-rack-resources-to-get-you-started)
* [Ruby On Rack : the Builder](http://m.onkey.org/ruby-on-rack-2-the-builder)
* [Rack::Sendfile](http://rack.rubyforge.org/doc/Rack/Sendfile.html)
* [Mongrel vs. Passenger vs. Unicorn](http://labs.revelationglobal.com/2009/10/06/mongrel_passenger_unicorn.html)
* [HTTP协议 (四) 缓存](http://www.cnblogs.com/TankXiao/archive/2012/11/28/2793365.html)
* [Capistrano wiki pages](https://github.com/capistrano/capistrano/wiki/_pages)
* [3 ways to speedup asset pipeline](http://blog.xdite.net/posts/2012/07/09/3-way-to-speedup-asset-pipeline/)
* [Unicorn Signals](http://unicorn.bogomips.org/SIGNALS.html)


附：

Rails使用`Rack::ConditionalGet`，根据`If-None-Match`和`If-Modified-Since`返回304并置空body，从而减少网络传输

	….
	use ActionDispatch::ParamsParser
	use ActionDispatch::Head
	use Rack::ConditionalGet
	use Rack::ETag
	use ActionDispatch::BestStandardsSupport
	use Warden::Manager
	run WsRails::Application.routes
	
