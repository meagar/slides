require 'tilt'
require 'tilt/erb'
require 'webrick'

Tilt.register(Tilt::PlainTemplate, 'rb')

class Context
  def render(template)
    Tilt.new("templates/#{template}").render(self)
  end

  def code(lines: nil,  &block)
    text = yield
    html = '<pre><code class="ruby hljs"'
    if lines == true
      html += ' data-line-numbers'
    elsif lines
      html += " data-line-numbers=\"#{lines}\""
    end

    html + ">#{text}</code></pre>"
  end
end

server = WEBrick::HTTPServer.new(Port: ENV.fetch('PORT', 8000), DocumentRoot: nil)

dist = File.expand_path './reveal.js/dist'
plugin = File.expand_path './reveal.js/plugin'

server.config[:MimeTypes]['css'] = 'text/css'
server.config[:MimeTypes]['js'] = 'application/javascript'
server.mount('/dist', WEBrick::HTTPServlet::FileHandler, dist)
server.mount('/plugin', WEBrick::HTTPServlet::FileHandler, plugin)

class Presentation < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    response.status = 200
    response['Content-Type'] = 'text/html'
    response.body = Tilt.new('templates/index.slim').render(Context.new)
  end
end

server.mount('/', Presentation)

trap 'INT' do
  server.shutdown
end

server.start
