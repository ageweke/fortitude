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

    POSSIBLE_RETINA_PIXEL_RATIOS = {
      1 => '',
      2 => '@2x',
      3 => '@3x'
    }

    def find_retina_pixel_ratio_data_available(base_image)
      dirname = File.dirname(base_image)
      extension = File.extname(base_image)
      filename = File.basename(base_image, extension)

      out = { }

      POSSIBLE_RETINA_PIXEL_RATIOS.each do |pixel_ratio, suffix|
        subpath = File.join(dirname, "#{filename}#{suffix}#{extension}")
        image_data = retina_image_data(subpath)

        if image_data
          dimensions = ::Dimensions.dimensions(image_data[:file])
          effective_width = retina_rounded_dimension(dimensions[0].to_f / pixel_ratio.to_f)
          effective_height = retina_rounded_dimension(dimensions[1].to_f / pixel_ratio.to_f)

          out[pixel_ratio] = {
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

    def retina_pixel_ratio_data_available(base_image)
      @retina_pixel_ratio_data_available ||= { }
      @retina_pixel_ratio_data_available[base_image] ||= find_retina_pixel_ratio_data_available(base_image)
    end

    def retina_image_css_class(image_subpath)
      image_subpath = $1 if image_subpath =~ %r{^/?(.*?)/*$}
      out = image_subpath.gsub(/[^A-Za-z_0-9\-]/, '_')
      "retina_image_#{out}"
    end

    RETINA_ASSUME_10_PIXEL_RATIO_DPI = 96
    RETINA_SPLIT_BETWEEN_RATIOS_AT_PERCENTAGE = 25

    def retina_image_css_pixel_ratio_ranges(pixel_ratios_available)
      pixel_ratios_available = pixel_ratios_available.sort

      out = { }

      pixel_ratios_available.each_with_index do |pixel_ratio, index|
        next_bigger_pixel_ratio = pixel_ratios_available[index + 1] if (index + 1) < pixel_ratios_available.length
        next_smaller_pixel_ratio = pixel_ratios_available[index - 1] if index > 0

        minimum_pixel_ratio = maximum_pixel_ratio = nil

        if index > 0
          if next_smaller_pixel_ratio
            minimum_pixel_ratio = next_smaller_pixel_ratio.to_f +
              ((pixel_ratio.to_f - next_smaller_pixel_ratio.to_f) * (RETINA_SPLIT_BETWEEN_RATIOS_AT_PERCENTAGE.to_f / 100.0))
          end
          if next_bigger_pixel_ratio
            maximum_pixel_ratio = pixel_ratio.to_f +
              ((next_bigger_pixel_ratio.to_f - pixel_ratio.to_f) * (RETINA_SPLIT_BETWEEN_RATIOS_AT_PERCENTAGE.to_f / 100.0))
          end
        end

        out[pixel_ratio] = [ minimum_pixel_ratio, maximum_pixel_ratio ]
      end

      out
    end

    def retina_pixel_ratio_to_dpi(pixel_ratio)
      (pixel_ratio.to_f * RETINA_ASSUME_10_PIXEL_RATIO_DPI.to_f).round
    end

    def retina_image_css(image_subpath)
      css_class = retina_image_css_class(image_subpath)
      pixel_ratio_data_available = retina_pixel_ratio_data_available(image_subpath)

      available_ratios = pixel_ratio_data_available.keys.sort
      highest_ratio_data = pixel_ratio_data_available[available_ratios[-1]]
      lowest_ratio_data = pixel_ratio_data_available[available_ratios[0]]

      out = <<-EOS
.#{css_class} {
  width: #{highest_ratio_data[:effective_width]}px;
  height: #{highest_ratio_data[:effective_height]}px;
  background-image: url(#{lowest_ratio_data[:src]});
}
EOS

      retina_image_css_pixel_ratio_ranges(pixel_ratio_data_available.keys).each do |pixel_ratio, (minimum_pixel_ratio, maximum_pixel_ratio)|
        pixel_ratio_data = pixel_ratio_data_available[pixel_ratio]
        if minimum_pixel_ratio || maximum_pixel_ratio
          prefix = "@media ("
          if minimum_pixel_ratio
            prefix << "-webkit-min-device-pixel-ratio: #{minimum_pixel_ratio}"
            prefix << " and " if maximum_pixel_ratio
          end
          if maximum_pixel_ratio
            prefix << "-webkit-max-device-pixel-ratio: #{maximum_pixel_ratio}"
          end
          prefix << "), ("
          if minimum_pixel_ratio
            prefix << "min-resolution: #{retina_pixel_ratio_to_dpi(minimum_pixel_ratio)}dpi"
            prefix << " and " if maximum_pixel_ratio
          end
          if maximum_pixel_ratio
            prefix << "max-resolution: #{retina_pixel_ratio_to_dpi(maximum_pixel_ratio)}dpi"
          end
          prefix << ")"

          out << <<-EOS
#{prefix} {
  .#{css_class} {
    background-image: url(#{pixel_ratio_data[:src]});
    background-size: #{pixel_ratio_data[:effective_width]}px #{pixel_ratio_data[:effective_height]}px;
  }
}
EOS
        end
      end

      out
    end
  end

  def retina_image(attributes)
    attributes = attributes.dup
    source = [ attributes.delete(:src), attributes.delete('src') ].compact[0]
    raise "Must supply an image source, not: #{attributes.inspect}" unless source

    pixel_ratio_data = self.class.retina_pixel_ratio_data_available(source)
    if pixel_ratio_data.empty?
      raise Errno::ENOENT, "No image files could be found at all for: #{source.inspect}"
    end

    chosen_size = pixel_ratio_data[pixel_ratio_data.keys.last]
    $stderr.puts "chosen_size: #{chosen_size.inspect}"
    attributes = attributes.merge(
      :src => chosen_size[:src],
      :width => chosen_size[:effective_width],
      :height => chosen_size[:effective_height]
    )

    $stderr.puts "CSS FOR #{source}:"
    $stderr.puts self.class.retina_image_css(source)

    img(attributes)
  end
end
