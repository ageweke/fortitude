require 'active_support/concern'

module ::FortitudeRetinaImages
  extend ::ActiveSupport::Concern

  module ClassMethods
    def retina_image_base_directories(base_directory_path_to_prefix_map = nil)
      if base_directory_path_to_prefix_map
        @retina_image_base_directories ||= { }
        base_directory_path_to_prefix_map.each do |base_directory, prefix|
          prefix = prefix.to_s.strip
          unless prefix.length > 0
            raise TypeError, "Must path a non-empty subpath for #{base_directory.inspect}, not: #{prefix.inspect}"
          end
          base_directory = File.expand_path(base_directory)
          prefix = "/#{prefix}" unless prefix.start_with?("/")
          prefix = "#{prefix}/" unless prefix.end_with?("/")
          @retina_image_base_directories[base_directory] = prefix
        end
      else
        out = { }
        out.merge!(@retina_image_base_directories) if @retina_image_base_directories
        out.merge!(superclass.retina_image_base_directories) if superclass.respond_to?(:retina_image_base_directories)
        out
      end
    end

    alias_method :retina_image_base_directory, :retina_image_base_directories

    def retina_image_data(subpath)
      retina_image_base_directories.each do |directory, prefix|
        full_path = File.join(directory, subpath)
        if File.exist?(full_path)
          return { :file => full_path, :src => "#{prefix}#{subpath}" }
        end
      end
      nil
    end

    POSSIBLE_RETINA_SIZES = {
      1 => '',
      2 => '@2x',
      3 => '@3x'
    }

    def find_retina_sizes_available(base_image)
      dirname = File.dirname(base_image)
      extension = File.extname(base_image)
      filename = File.basename(base_image, extension)

      out = { }

      POSSIBLE_RETINA_SIZES.each do |size_factor, suffix|
        subpath = File.join(dirname, "#{filename}#{suffix}#{extension}")
        image_data = retina_image_data(subpath)

        if image_data
          dimensions = ::Dimensions.dimensions(image_data[:file])
          effective_width = retina_rounded_dimension(dimensions[0].to_f / size_factor.to_f)
          effective_height = retina_rounded_dimension(dimensions[1].to_f / size_factor.to_f)

          out[size_factor] = {
            :src => image_data[:src],
            :effective_width => effective_width,
            :effective_height => effective_height
          }
        end
      end

      out
    end

    RETINA_EPSILON = 0.01

    def retina_rounded_dimension(dimension)
      remainder = dimension - dimension.round
      if remainder < RETINA_EPSILON
        dimension.round
      else
        dimension
      end
    end

    def retina_sizes_available(base_image)
      @retina_sizes_available ||= { }
      @retina_sizes_available[base_image] ||= find_retina_sizes_available(base_image)
    end
  end

  def retina_image(attributes)
    attributes = attributes.dup
    source = [ attributes.delete(:src), attributes.delete('src') ].compact[0]
    raise "Must supply an image source, not: #{attributes.inspect}" unless source

    sizes = self.class.retina_sizes_available(source)
    if sizes.empty?
      raise Errno::ENOENT, "No image files could be found at all for: #{source.inspect}"
    end

    chosen_size = sizes[sizes.keys.last]
    $stderr.puts "chosen_size: #{chosen_size.inspect}"
    attributes = attributes.merge(
      :src => chosen_size[:src],
      :width => chosen_size[:effective_width],
      :height => chosen_size[:effective_height]
    )

    img(attributes)
  end
end
