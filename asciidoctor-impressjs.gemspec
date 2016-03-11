# -*- encoding: utf-8 -*-
require File.expand_path '../lib/asciidoctor-impressjs/version', __FILE__

Gem::Specification.new do |s|
  s.name = 'asciidoctor-impressjs'
  s.version = Asciidoctor::Impressjs::VERSION
  s.authors = ['Daniel Grycman']
  s.email = ['danielgrycman@icloud.com']
  s.homepage = 'https://github.com/danielgrycman/asciidoctor-impressjs'
  s.summary = 'Converts AsciiDoc to the HTML part of a Impress.js presentation'
  s.description = 'A converter for Asciidoctor that produces the HTML part of a Impress.js presentation from an AsciiDoc source file.'
  s.license = 'MIT'
  s.required_ruby_version = '>= 1.9.3'

  begin
    s.files = `git ls-files -z -- {bin,lib,templates}/* {LICENSE,README}.adoc Rakefile`.split "\0"
  rescue
    s.files = Dir['**/*']
  end

  s.executables = ['asciidoctor-impressjs']
  s.extra_rdoc_files = Dir['README.adoc', 'LICENSE.adoc']
  s.require_paths = ['lib']

  #s.add_runtime_dependency 'asciidoctor', '~> 1.5.0'

  s.add_development_dependency 'asciidoctor', '~> 1.5.0'
  s.add_development_dependency 'rake', '~> 10.4.2'
  s.add_development_dependency 'slim', '~> 3.0.6'
  s.add_development_dependency 'thread_safe', '~> 0.3.5'
  s.add_development_dependency 'tilt', '~> 2.0.2'
end