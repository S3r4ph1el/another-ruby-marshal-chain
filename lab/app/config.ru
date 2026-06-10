# Lab vulnerable on purpose: do NOT deploy this anywhere.
#
# Rack endpoint that Marshal.load's user-controlled base64 input. Real apps
# hit the same sink via ActiveRecord `serialize :col, MarshalSerializer`
# columns, encrypted cookies decoded into Marshal, cache stores, etc.

require 'base64'
require 'yaml'                        # present in any real Rails app
require 'rack'
require 'sprockets'                  # only needed by the alternative 5-gadget vector
require 'ostruct'                    # idem; OpenStruct left Ruby's default gems in 4.0
require 'active_support'             # autoloads ConfigurationFile (primary sink) + DIVP
require 'active_support/deprecation'

class VulnApp
  def call(env)
    req = Rack::Request.new(env)
    case [req.request_method, req.path]
    when ['GET', '/']
      [200, {'content-type' => 'text/plain'},
       ["Marshal gadget lab. POST base64-encoded Marshal payload to /marshal as 'p'.\n"]]
    when ['POST', '/marshal']
      blob = req.params['p'].to_s
      out, err = capture do
        begin
          Marshal.load(Base64.decode64(blob))
          nil
        rescue => e
          "#{e.class}: #{e.message}"
        end
      end
      body = "stdout:\n#{out}"
      body << "\nchain-raised: #{err}\n" if err
      [200, {'content-type' => 'text/plain'}, [body]]
    else
      [404, {'content-type' => 'text/plain'}, ["not found\n"]]
    end
  end

  # Capture stdout written by the gadget's `system()` and the optional second
  # return value (chain raise message). Survives exceptions inside the block.
  def capture
    r, w = IO.pipe
    old = $stdout.dup
    $stdout.reopen(w)
    err = yield
    $stdout.reopen(old); w.close
    [r.read, err]
  ensure
    $stdout.reopen(old) if old
  end
end

run VulnApp.new
