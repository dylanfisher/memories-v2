module ApplicationHelper
  def full_width?
    cookies[:full_width] == 'true'
  end

  def exif_data(media_item)
    d = media_item.attachment.metadata

    return unless %w(lens_model exposure_time aperture_value iso_speed_ratings).all? { |x| d[x].present? }

    is_zoom = d['lens_model'].match(/\d*-\d*mm/)
    zoom_focal_length = " at #{d['focal_length'].to_i}mm"

    data = [
      "#{d['exposure_time']} at f / #{d['aperture_value']}, ISO #{d['iso_speed_ratings']}",
      "#{d['lens_model']}#{is_zoom ? zoom_focal_length : ''}"
    ].join('<br>').html_safe
    content_tag :div, class: 'exif-data caption' do
      content_tag :span, data, class: 'exif-data__text'
    end
  end
end
