require 'tilt'
require 'tilt/erb'
require 'webrick'
require 'slim'

Tilt.register(Tilt::PlainTemplate, 'rb')

class Context
  def render(template)
    Tilt.new("templates/#{template}").render(self)
  end

  def code(lines: true, tall: false, fragment: false, id: nil, &block)
    text = yield
    classes = ["ruby", "hljs"]
    classes <<= "tall" if tall
    classes <<= "fragment" if fragment

    html = "<pre><code"
    html += " data-id=\"#{id}\"" if id
    html += " class=\"#{classes.join(" ")}\""
    if lines == true
      html += ' data-line-numbers'
    elsif lines
      html += " data-line-numbers=\"#{lines}\""
    end

    html + ">#{text.strip}</code></pre>"
  end
end


server = WEBrick::HTTPServer.new(Port: ENV.fetch('PORT', 8000), DocumentRoot: nil)

img = File.expand_path './public/img'

server.config[:MimeTypes]['css'] = 'text/css'
server.config[:MimeTypes]['js'] = 'application/javascript'
server.mount('/img', WEBrick::HTTPServlet::FileHandler, img)

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
