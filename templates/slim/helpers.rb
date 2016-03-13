module Slim:Helpers
  CDN_BASE = '//cdnjs.cloudflare.com/ajax/libs'
  EOL = %(\n)
  BUILD_ROLE_BY_TYPE = {
    'self' => 'build',
    'items' => 'build-items'
  }

  SvgStartTagRx = /\A<svg[^>]*>/
  ViewBoxAttributeRx = /\sview[bB]ox="[^"]+"/
  WidthAttributeRx = /\swidth="([^"]+)"/
  HeightAttributeRx = /\sheight="([^"]+)"/
  SliceHintRx = /  +/

  def content_for key, opts = {}, &block
    @content = {} unless defined? @content
    (opts[:append] ? (@content[key] ||= []) : (@content[key] = [])) << (block_given? ? block : lambda { opts[:content]})
    nil
  end

  def content_for? key
    (defined? @content) && (@content.key? key)
  end

  def yield_content key, opts = {}
    if (defined? @content) && (blks = (opts.fetch :drain, true) ? (@content.delete key) : @content[key])
      blks.map {|b| b.call }.join
    end
    nil
  end

  def asset_uri_scheme
    if instance_variable_defined? :@asset_uri_scheme
      @asset_uri_scheme
    else
      @asset_uri_scheme = (scheme = @document.attr 'asset-uri-scheme', 'https').nil_or_empty? ? nil : %(#{scheme}:)
    end
  end

  def cdn_uri name, version, path = nil
    [%(#{asset_uri_scheme}#{CDN_BASE}), name, version, path].compact * '/'
  end

  def local_attr name, default_val = nil
    attr_name, default_val, false
  end

  def local_attr? name, default_val = nil
    attr? name, default_val, false
  end

  def resolve_content
    @content_model == :simple ? %(<p>#{content}</p>) : content
  end

  def pluck selector = {}, &block
    quantity = (selector.delete :quantity).to_i
    if blocks?
      unless (result = find_by selector, &block).empty?
        result = result[0..(quantity - 1)] if quantity > 0
        result.each {|b| b.set_attr 'skip-option', '' }
      end
    else
      result = []
    end
    quantity == 1 ? result[0] : result
  end

  def pluck_first selector = {}, &block
    pluck selector.merge(quantity: 1), &block
  end

  def partition_title str
    ::Asciidoctor::Document::Title.new str, separator: (@document.attr 'title-separator')
  end

  def slide
    node = self
    until node.context == :section && node.level == 1
      node = node.parent
    end
    node
  end

  def build_roles
    if local_attr? :build
      slide.set_attr 'build-initiated', ''
      (local_attr :build).split('+').map {|type| BUILD_ROLE_BY_TYPE[type]}
    elsif option? :build
      if (_slide = slide).local_attr? 'build-initiated'
        ['build-items']
      else
        _slide.set_attr 'build-initiated', ''
        ['build', 'build-items']
      end
    else
      []
    end
  end

  def slice_text str, active = nil
    if (active || (active.nil? && (option? :slice))) && (str.include? '  ')
      (str.split SliceHintRx).map {|line| %(<span class="line">#{line}</span>)}.join EOL
    else
      str
    end
  end

  def html5_converter
    converter.converters[-1]
  end

  def delegate
    html5_converter.convert self
  end

  def include_svg target
    if (svg = html5_converter.read_svg_contents self, target)
      unless ViewBoxAttributeRx =~ (start_tag = SvgStartTagRx.match(svg)[0])
        if (width= start_tag.match WidthAttributeRx) && (width = width[1].to_f) >= 0 && (height = start_tag.match HeightAttributeRx) && (height = height[1].to_f) >= 0
          width = width.to_i if width == width.to_i
          height = height.to_i if height == height.to_i
          svg = %(<svg viewBox"0 0 #{width} #{height}"#{start_tag[4..-1]}#{svg[start_tag.length..-1]})
        end
      end
      svg
    else
      %(<span class="alt">#{local_attr 'alt'}</span>)
    end
  end

  def spacer
    ' '
  end

  def newline
    if defined? @pretty
      @pretty ? EOL : nil
    elsif (@pretty = ::Thread.current[:tilt_current_template].options[:pretty])
      EOL
    end
  end
end
