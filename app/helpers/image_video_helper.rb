module ImageVideoHelper
  def lazy_image(media_item, options = {})
    return if media_item.blank?

    size = options.delete(:size) || :large
    data = options.delete(:data) || {}
    alt = options.delete(:alt) || media_item.try(:alternative_text).presence || media_item.try(:caption)
    options.merge!(alt: alt) if alt.present?
    size_mobile = options.delete(:size_mobile) || :medium
    css_style = options.delete(:style).presence || ''
    placeholder = options.delete(:no_placeholder) ? uri_image_placeholder : media_item.attachment_url(:small)

    if media_item.attachment_content_type =~ /svg\+xml/
      size = :original
      size_mobile = :original
    end

    data.merge!(src: media_item.attachment_url(size),
                src_mobile: media_item.attachment_url(size_mobile),
                src_full: media_item.attachment_url(:large),
                caption: md(media_item.try(:caption)))

    point_of_interest_x = options.fetch(:point_of_interest_x, media_item.try(:point_of_interest_x))
    point_of_interest_y = options.fetch(:point_of_interest_y, media_item.try(:point_of_interest_y))

    if point_of_interest_x.present? && point_of_interest_y.present?
      css_style << "background-position: #{point_of_interest_x}% #{point_of_interest_y}%;"
    end

    css_style << "background-image: url(#{placeholder});"

    if options.delete(:background)
      options.merge!('aria-label': alt) if alt.present?
      options.delete(:alt)
      content_tag :div,
                  nil,
                  class: "lazy-image lazyload background-image #{options.delete(:class)} #{options.delete(:wrapper_class)} content-type--#{media_item.attachment_content_type.parameterize}",
                  style: css_style,
                  role: 'img',
                  data: {
                    bg: data.delete(:src),
                    bg_mobile: data.delete(:src_mobile),
                    **data
                  },
                  **options
    else
      if options[:skip_jump_fix]
          image_tag placeholder, class: "lazy-image lazyload #{options.delete(:class)}", data: data, **options
      else
        image_jump_fix media_item, class: options.delete(:wrapper_class) do
          concat exif_data media_item
          concat image_tag(placeholder, class: "lazy-image lazyload #{options.delete(:class)}", data: data, **options)
        end
      end
    end
  end

  def background_image(media_item, options = {})
    size = options.delete(:size) || :large
    data = options.delete(:data) || {}
    alt = options.delete(:alt) || media_item.try(:alternative_text).presence || media_item.try(:caption)
    options.merge!(alt: alt) if alt.present?
    size_mobile = options.delete(:size_mobile) || :medium
    data.merge!(src: media_item.attachment_url(size),
                src_mobile: media_item.attachment_url(size_mobile),
                src_full: media_item.attachment_url(:large),
                caption: md(media_item.try(:caption)))
    options.merge!('aria-label': alt) if alt.present?
    options.delete(:alt)
    css_style = options.delete(:style).presence || ''

    if media_item.try(:point_of_interest_x).present? && media_item.try(:point_of_interest_y).present?
      point_of_interest_x = options.fetch(:point_of_interest_x, media_item.point_of_interest_x)
      point_of_interest_y = options.fetch(:point_of_interest_y, media_item.point_of_interest_y)
      css_style << "background-position: #{point_of_interest_x}% #{point_of_interest_y}%;"
    end

    content_tag :div,
                nil,
                class: "background-image #{options.delete(:class)} content-type--#{media_item.attachment_content_type.parameterize}",
                style: "background-image: url(#{data[:src]}); #{css_style}",
                role: 'img',
                data: {
                  **data
                },
                **options
  end

  def lazy_video(media_item, options = {})
    data = options.delete(:data) || {}
    options.merge!(poster: media_item.vimeo_video_thumbnail) if media_item.vimeo_video_thumbnail.present?
    autoplay = options.fetch(:autoplay, media_item.try(:autoplay))
    autoplay = autoplay.nil? ? false : autoplay
    playsinline = options.fetch(:playsinline, autoplay)
    controls = options.fetch(:controls, !autoplay)
    ratio = options.delete(:ratio) || media_item.vimeo_video_aspect_ratio
    video_loop = options.fetch(:loop, autoplay)
    video_tag_html = capture do
      video_tag '',
                class: "lazy-video #{options.delete(:class)}",
                controls: controls,
                playsinline: autoplay,
                autoplay: autoplay,
                muted: playsinline,
                loop: video_loop,
                data: {
                  src: (options.delete(:src) || media_item.try(:vimeo_video_file_url)),
                  src_mobile: (options.delete(:src_mobile) || media_item.try(:vimeo_video_file_url_mobile)),
                  object_fit: 'cover',
                  **data },
                **options
    end

    background_poster_image = "background-image: url(#{options[:poster]}); background-position: center center; background-size: cover;" if options[:poster].present?

    content_tag :div,
                nil,
                class: 'lazy-video-placeholder',
                style: "height: 0; padding-bottom: #{ratio * 100}%; #{background_poster_image}",
                data: {
                  video_tag_html: video_tag_html }
  end

  def lazy_asset(asset_path, options = {})
    data = options.delete(:data) || {}
    data.merge!(src: asset_path)
    blob = options.delete(:blob)
    width = options.delete(:width)
    height = options.delete(:height)
    limit_height = options.delete(:limit_height)

    if blob.present? && blob.metadata.present?
      width = blob.metadata[:width]
      height = blob.metadata[:height]
    end

    ratio = width.to_f / height.to_f

    if options.delete(:background)
      content_tag :div,
                  (block_given? ? yield : nil),
                  class: "lazy-image lazy-image--background lazyload #{options.delete(:class)}",
                  role: 'img',
                  data: {
                    bg: data.delete(:src),
                    **data
                  },
                  **options
    else
      image_tag_content = capture do
        image_tag uri_image_placeholder, class: "lazy-image lazyload #{options.delete(:class)}", data: data, **options
      end

      if [width, height].all?
        asset_jump_image_content = capture do
          asset_jump_fix width: width, height: height, wrapper_class: options.delete(:wrapper_class) do
            concat yield if block_given?
            concat image_tag_content
          end
        end
        if limit_height
          content_tag :div, class: options.delete(:outer_wrapper_class), style: "width: #{limit_height.to_f * ratio}px; max-width: 100%;" do
            asset_jump_image_content
          end
        else
          asset_jump_image_content
        end
      else
        image_tag_content
      end
    end
  end

  def uri_image_placeholder
    'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
  end

  def asset_jump_fix(options = {})
    width = options.delete(:width)
    height = options.delete(:height)
    tag_type = options.delete(:tag) || :div
    content_type = options.delete(:content_type)
    css_class = options.delete(:wrapper_class)

    if [width, height].all?
      # ratio = height.to_f / width.to_f * 100
      ratio = (height.to_f / width.to_f * 100 + 0.01).round(2)
      padding_bottom = "padding-bottom: #{ratio}%;"
    else
      raise 'Width and height must be defined'
    end

    content_tag tag_type, class: "forest-image-jump-fix #{('forest-image-jump-fix--' + content_type.parameterize) if content_type.present?} #{css_class}", style: padding_bottom, **options do
      yield
    end
  end
end
